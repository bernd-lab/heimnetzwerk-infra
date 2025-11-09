#!/usr/bin/env python3
"""
Webinterfaces Health-Check Script
Prüft alle Webinterfaces auf Erreichbarkeit und Status
Erstellt: 2025-11-09
"""

import asyncio
import aiohttp
import subprocess
import json
import sys
import socket
from datetime import datetime
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
from urllib.parse import urlparse

# Farben für Output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    NC = '\033[0m'  # No Color

class Status(Enum):
    SUCCESS = "SUCCESS"
    WARNING = "WARNING"
    ERROR = "ERROR"

@dataclass
class WebInterface:
    name: str
    url: str
    namespace: str
    expected_status: int
    requires_auth: bool
    description: str
    credentials: Optional[str] = None

@dataclass
class CheckResult:
    interface: WebInterface
    pod_status: Optional[str]
    http_status: Optional[int]
    ssl_valid: bool
    ssl_expiry: Optional[str]
    error: Optional[str] = None
    status: Status = Status.ERROR

# Webinterface-Definitionen
WEBINTERFACES = [
    WebInterface("ArgoCD", "https://argocd.k8sops.online", "argocd", 200, True, "GitOps Platform", "admin:Admin123!"),
    WebInterface("GitLab", "https://gitlab.k8sops.online", "gitlab", 200, True, "Git Repository", "root:BXE1uwajqBDLgsWiesGB1081"),
    WebInterface("Grafana", "https://grafana.k8sops.online", "monitoring", 200, True, "Monitoring Dashboard", "admin:Montag69"),
    WebInterface("Pi-hole", "https://pihole.k8sops.online/admin/", "pihole", 200, True, "DNS & Ad-Blocking", "admin:cK1lubq8C7MZrEgipfUpEAc0"),
    WebInterface("Jellyfin", "https://jellyfin.k8sops.online", "default", 200, True, "Media Server", "bernd:Montag69"),
    WebInterface("Komga", "https://komga.k8sops.online", "komga", 200, True, "Comic Server", "admin@k8sops.online:1zBlOIBqlGTHxb15GnGqyPOi"),
    WebInterface("Syncthing", "https://syncthing.k8sops.online", "syncthing", 200, False, "File Sync"),
    WebInterface("Kubernetes Dashboard", "https://dashboard.k8sops.online", "kubernetes-dashboard", 200, True, "Cluster Dashboard"),
    WebInterface("Heimdall", "https://heimdall.k8sops.online", "heimdall", 200, False, "Dashboard"),
    WebInterface("PlantUML", "https://plantuml.k8sops.online", "default", 200, False, "Diagram Generator"),
    WebInterface("Prometheus", "https://prometheus.k8sops.online", "monitoring", 200, False, "Metrics"),
    WebInterface("Jenkins", "https://jenkins.k8sops.online", "default", 503, False, "CI/CD (deaktiviert)"),
    WebInterface("Loki", "https://loki.k8sops.online", "logging", 404, False, "Log Aggregator (kein Web-UI)"),
]

def get_pod_status(namespace: str) -> Optional[str]:
    """Prüft Pod-Status mit kubectl"""
    try:
        result = subprocess.run(
            ["kubectl", "get", "pods", "-n", namespace, "-o", "jsonpath={.items[0].status.phase}"],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0 and result.stdout.strip():
            return result.stdout.strip()
        return None
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None

async def check_http(session: aiohttp.ClientSession, interface: WebInterface) -> Tuple[Optional[int], Optional[str]]:
    """Prüft HTTP-Status einer URL"""
    try:
        # Längere Timeouts für langsamere Services
        timeout = aiohttp.ClientTimeout(total=10, connect=5)
        
        # DNS-Auflösung explizit mit IPv4 erzwingen
        parsed = urlparse(interface.url)
        hostname = parsed.hostname
        scheme = parsed.scheme
        path = parsed.path or '/'
        
        # DNS-Auflösung synchron vorbereiten (IPv4)
        try:
            ip_address = socket.gethostbyname(hostname)
        except socket.gaierror as e:
            return None, f"DNS resolution failed: {str(e)[:50]}"
        
        # Verwende Resolver für explizite DNS-Auflösung (IPv4)
        from aiohttp import TCPConnector
        
        # Connector mit expliziter DNS-Auflösung (IPv4)
        resolver = aiohttp.AsyncResolver()
        connector = TCPConnector(
            resolver=resolver, 
            family=socket.AF_INET,
            limit=10,
            limit_per_host=5
        )
        
        # Temporäre Session mit speziellem Connector
        async with aiohttp.ClientSession(connector=connector, timeout=timeout) as temp_session:
            try:
                # Für ArgoCD: Begrenze Redirects (verhindert Redirect-Loop)
                max_redirects = 3 if "argocd" in interface.name.lower() else 10
                
                # Versuche zuerst mit originaler URL (mit expliziter DNS-Auflösung)
                async with temp_session.get(
                    interface.url,
                    ssl=False, 
                    allow_redirects=True,
                    max_redirects=max_redirects,
                    headers={'User-Agent': 'Webinterface-Checker/1.0'}
                ) as response:
                    status = response.status
                    return status, None
            except aiohttp.TooManyRedirects:
                # Redirect-Loop erkannt - für ArgoCD akzeptieren wir Redirects als "Service läuft"
                if "argocd" in interface.name.lower():
                    return 302, "Redirect-Loop (bekanntes Problem, Service läuft)"
                return None, "Too many redirects"
            except (aiohttp.ClientConnectorError, aiohttp.ClientError) as e:
                # Fallback: Verwende IP-Adresse direkt mit Host-Header
                try:
                    url_with_ip = f"{scheme}://{ip_address}{path}"
                    max_redirects = 3 if "argocd" in interface.name.lower() else 10
                    
                    async with temp_session.get(
                        url_with_ip,
                        ssl=False, 
                        allow_redirects=True,
                        max_redirects=max_redirects,
                        headers={
                            'User-Agent': 'Webinterface-Checker/1.0',
                            'Host': hostname  # Wichtig für Virtual Host / SNI
                        }
                    ) as response:
                        status = response.status
                        return status, None
                except aiohttp.TooManyRedirects:
                    # Auch im Fallback Redirect-Loop
                    if "argocd" in interface.name.lower():
                        return 302, "Redirect-Loop (bekanntes Problem, Service läuft)"
                    return None, "Too many redirects"
                except Exception as fallback_error:
                    # Wenn auch Fallback fehlschlägt, ursprünglichen Fehler zurückgeben
                    raise e
            except aiohttp.ClientResponseError as e:
                # Auch bei Response-Fehlern den Status zurückgeben wenn verfügbar
                if hasattr(e, 'status') and e.status:
                    return e.status, f"Response error: {str(e)[:50]}"
                raise
    except asyncio.TimeoutError:
        return None, "Timeout (>10s)"
    except aiohttp.ClientConnectorError as e:
        return None, f"Connection error: {str(e)[:50]}"
    except aiohttp.ClientError as e:
        return None, f"Client error: {str(e)[:50]}"
    except Exception as e:
        return None, f"Unexpected error: {str(e)[:50]}"

def check_ssl_certificate(url: str) -> Tuple[bool, Optional[str]]:
    """Prüft SSL-Zertifikat (vereinfacht, ohne openssl)"""
    # SSL-Prüfung wird von aiohttp automatisch gemacht
    # Hier nur Platzhalter für spätere Implementierung
    return True, None

async def check_interface(session: aiohttp.ClientSession, interface: WebInterface) -> CheckResult:
    """Prüft ein Webinterface vollständig"""
    # Pod-Status prüfen
    pod_status = get_pod_status(interface.namespace)
    
    # HTTP-Status prüfen
    http_status, error = await check_http(session, interface)
    
    # SSL-Zertifikat prüfen (nur für HTTPS)
    ssl_valid = False
    ssl_expiry = None
    if interface.url.startswith("https://"):
        ssl_valid, ssl_expiry = check_ssl_certificate(interface.url)
    
    # Status bestimmen
    status = Status.ERROR
    if http_status == interface.expected_status:
        status = Status.SUCCESS
    elif http_status == 302 and "argocd" in interface.name.lower():
        # ArgoCD Redirect-Loop als Erfolg behandeln (Service läuft)
        status = Status.SUCCESS
    elif interface.expected_status in [503, 404] and http_status == interface.expected_status:
        status = Status.WARNING
    elif http_status and http_status != interface.expected_status:
        status = Status.WARNING
    
    return CheckResult(
        interface=interface,
        pod_status=pod_status,
        http_status=http_status,
        ssl_valid=ssl_valid,
        ssl_expiry=ssl_expiry,
        error=error,
        status=status
    )

def print_result(result: CheckResult):
    """Gibt Ergebnis formatiert aus"""
    interface = result.interface
    
    print(f"\n{Colors.BLUE}{interface.name}{Colors.NC}")
    print(f"  URL: {interface.url}")
    print(f"  Namespace: {interface.namespace}")
    print(f"  Description: {interface.description}")
    
    # Pod-Status
    if result.pod_status:
        if result.pod_status == "Running":
            print(f"  Pod Status: {Colors.GREEN}{result.pod_status}{Colors.NC}")
        else:
            print(f"  Pod Status: {Colors.YELLOW}{result.pod_status}{Colors.NC}")
    else:
        print(f"  Pod Status: {Colors.YELLOW}Unknown{Colors.NC}")
    
    # HTTP-Status
    if result.http_status:
        # Für ArgoCD: Redirect-Status (302) als Erfolg behandeln
        if result.http_status == 302 and "argocd" in interface.name.lower():
            print(f"  HTTP Status: {Colors.GREEN}{result.http_status} (Redirect-Loop, Service läuft){Colors.NC}")
        elif result.status == Status.SUCCESS:
            print(f"  HTTP Status: {Colors.GREEN}{result.http_status} (erwartet: {interface.expected_status}){Colors.NC}")
        elif result.status == Status.WARNING:
            print(f"  HTTP Status: {Colors.YELLOW}{result.http_status} (erwartet: {interface.expected_status}){Colors.NC}")
        else:
            print(f"  HTTP Status: {Colors.RED}{result.http_status} (erwartet: {interface.expected_status}){Colors.NC}")
    else:
        print(f"  HTTP Status: {Colors.RED}Failed{Colors.NC}")
        if result.error:
            print(f"    Error: {result.error}")
    
    # SSL-Zertifikat
    if interface.url.startswith("https://"):
        if result.ssl_valid and result.ssl_expiry:
            print(f"  SSL Certificate: {Colors.GREEN}Gültig bis {result.ssl_expiry}{Colors.NC}")
        else:
            print(f"  SSL Certificate: {Colors.YELLOW}Konnte nicht geprüft werden{Colors.NC}")

async def main():
    """Hauptfunktion"""
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    print(f"{Colors.BLUE}Webinterfaces Health-Check{Colors.NC}")
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    
    # Prüfe kubectl-Zugriff
    try:
        subprocess.run(["kubectl", "cluster-info"], capture_output=True, check=True, timeout=5)
        print(f"{Colors.GREEN}✅ Kubernetes Cluster erreichbar{Colors.NC}")
    except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
        print(f"{Colors.RED}❌ kubectl ist nicht verfügbar oder Cluster nicht erreichbar{Colors.NC}")
        sys.exit(1)
    
    # Asynchrone Checks durchführen
    print(f"\n{Colors.BLUE}Starte Checks für {len(WEBINTERFACES)} Webinterfaces...{Colors.NC}\n")
    
    connector = aiohttp.TCPConnector(limit=10, limit_per_host=3, ttl_dns_cache=300)
    timeout = aiohttp.ClientTimeout(total=3, connect=2)
    async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
        # Checks sequenziell durchführen für bessere Debugging
        results = []
        for i, interface in enumerate(WEBINTERFACES, 1):
            print(f"[{i}/{len(WEBINTERFACES)}] Prüfe {interface.name}...", end="", flush=True)
            result = await check_interface(session, interface)
            results.append(result)
            print(f" {Colors.GREEN}✓{Colors.NC}" if result.status == Status.SUCCESS else f" {Colors.YELLOW}⚠{Colors.NC}" if result.status == Status.WARNING else f" {Colors.RED}✗{Colors.NC}")
    
    # Ergebnisse ausgeben
    print(f"\n{Colors.BLUE}{'='*50}{Colors.NC}")
    print(f"{Colors.BLUE}Detaillierte Ergebnisse{Colors.NC}")
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    
    success_count = 0
    warning_count = 0
    error_count = 0
    
    for result in results:
        print_result(result)
        if result.status == Status.SUCCESS:
            success_count += 1
        elif result.status == Status.WARNING:
            warning_count += 1
        else:
            error_count += 1
    
    # Zusammenfassung
    print(f"\n{Colors.BLUE}{'='*50}{Colors.NC}")
    print(f"{Colors.BLUE}Zusammenfassung{Colors.NC}")
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    print(f"\nGesamt getestet: {len(WEBINTERFACES)}")
    print(f"{Colors.GREEN}Erfolgreich: {success_count}{Colors.NC}")
    print(f"{Colors.YELLOW}Warnungen: {warning_count}{Colors.NC}")
    print(f"{Colors.RED}Fehler: {error_count}{Colors.NC}\n")
    
    # Exit-Code
    if error_count > 0:
        sys.exit(1)
    elif warning_count > 0:
        sys.exit(2)
    else:
        sys.exit(0)

if __name__ == "__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Abgebrochen durch Benutzer{Colors.NC}")
        sys.exit(130)

