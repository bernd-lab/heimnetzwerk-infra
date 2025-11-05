# Fritzbox-Kubernetes Integration: Umfassende Analyse

**Erstellt**: 2025-11-05  
**Analysiert von**: Fritzbox-Expert mit Fokus auf Kubernetes-Heim-Cluster

## Übersicht

Die FRITZ!Box 7590 AX ist das zentrale Netzwerk-Gateway für den Kubernetes-Heim-Cluster. Diese Analyse dokumentiert alle Fritzbox-Funktionen, die für Kubernetes und die Heimnetzwerk-Infrastruktur relevant sind.

## Kritische Konfigurationen für Kubernetes

### 1. DHCP-Konfiguration

**Aktuelle Einstellungen:**
- **DHCP-Server**: ✅ Aktiviert
- **IP-Bereich**: 192.168.178.20 - 192.168.178.200
- **Lease-Zeit**: 1 Tag
- **Lokaler DNS-Server**: 192.168.178.10 (Pi-hole)

**Kubernetes-Integration:**
- **Kubernetes LoadBalancer IPs**:
  - `192.168.178.54` - Ingress-Controller (nginx-ingress)
  - `192.168.178.10` - Pi-hole Service
- **⚠️ KRITISCHER KONFLIKT**: 192.168.178.54 liegt im DHCP-Bereich (20-200)
  - **Risiko**: DHCP könnte versehentlich diese IP an ein Gerät vergeben
  - **Lösung**: DHCP-Bereich anpassen auf 20-50, 60-200 (oder statische Reservierung)

**Menü-Pfad**: Heimnetz → Netzwerk → IPv4-Adressen (`#/network/ipv4`)

### 2. DNS-Integration

**Aktuelle Konfiguration:**
- **Lokaler DNS-Server**: 192.168.178.10 (Pi-hole)
- **Alle DHCP-Clients** erhalten diese IP als DNS-Server
- **Pi-hole** läuft in Kubernetes als LoadBalancer Service

**DNS-Flow für Kubernetes:**
```
Clients → Fritzbox DHCP (192.168.178.10) → Pi-hole (K8s Service) → Cloudflare → Internet
Kubernetes Pods → CoreDNS → Pi-hole (192.168.178.10) → Cloudflare → Internet
```

**Wichtige Punkte:**
- Pi-hole ist zentraler DNS-Server für alle Geräte
- Pi-hole kann lokale DNS-Records für `*.k8sops.online` → `192.168.178.54` bereitstellen
- CoreDNS forwardet an Pi-hole

**Menü-Pfad**: Internet → Zugangsdaten → DNS-Server (`#/internet/dns`)

### 3. Port-Freigaben und Firewall

**Kubernetes Services benötigen:**
- **Ingress-Controller**: Port 80/443 (HTTP/HTTPS)
  - Läuft auf 192.168.178.54 (LoadBalancer)
  - MetalLB Layer 2 arbeitet auf Layer 2, keine Port-Freigabe nötig
- **Externe Zugriffe**: Keine Port-Freigaben nötig (alles intern)

**Fritzbox Firewall:**
- Firewall blockiert automatisch eingehende Verbindungen aus dem Internet
- Interne Kommunikation (LAN) funktioniert ohne Einschränkungen
- VPN-Verbindungen (WireGuard) ermöglichen Zugriff von außen

**Menü-Pfad**: Internet → Freigaben → Portfreigaben (`#/access`)

### 4. VPN-Konfiguration (WireGuard)

**Aktuelle WireGuard-Verbindungen:**
- **Pixel**: ✅ Aktiv (192.168.178.202/32, Endpunkt: 61.8.147.74:1486)
- **S7plus**: ❌ Inaktiv (192.168.178.203/32)
- **z13**: ❌ Inaktiv (192.168.178.204/32)

**VPN-Integration mit Kubernetes:**
- VPN-Clients erhalten IPs im Heimnetz (192.168.178.202-204)
- Können auf Kubernetes Services zugreifen (über interne IPs oder Domains)
- Können auf Pi-hole (192.168.178.10) zugreifen
- Können auf Ingress-Controller (192.168.178.54) zugreifen

**Menü-Pfad**: Internet → Freigaben → VPN (WireGuard) (`#/access/wireguard`)

## Netzwerk-Topologie

### Heimnetzwerk (192.168.178.0/24)

**Statische IPs (außerhalb DHCP):**
- `192.168.178.1` - FRITZ!Box Router
- `192.168.178.54` - Kubernetes Ingress LoadBalancer ⚠️ (Konflikt mit DHCP!)
- `192.168.178.10` - Pi-hole LoadBalancer ✅ (außerhalb DHCP-Bereich)

**DHCP-Bereich:**
- `192.168.178.20` - `192.168.178.200`
- ⚠️ **Problematisch**: 192.168.178.54 liegt in diesem Bereich

**Empfohlener DHCP-Bereich:**
- Option 1: `192.168.178.20` - `192.168.178.50`, `192.168.178.60` - `192.168.178.200`
- Option 2: Statische DHCP-Reservierung für 192.168.178.54

**VPN-IPs:**
- `192.168.178.201` - IPSec VPN (inaktiv)
- `192.168.178.202` - WireGuard VPN (aktiv - Pixel)
- `192.168.178.203` - WireGuard VPN (inaktiv - S7plus)
- `192.168.178.204` - WireGuard VPN (inaktiv - z13)

### Gastnetzwerk (192.168.179.0/24)

- **IP-Adresse**: 192.168.179.1
- **DHCP-Bereich**: Automatisch (nicht konfigurierbar)
- **Lease-Zeit**: 1 Stunde
- **Isolation**: Kein Zugriff auf Heimnetz (nur Internet)

## Wichtige Fritzbox-Funktionen für Kubernetes

### 1. DHCP-Server
- **Zweck**: IP-Adressen für alle Netzwerkgeräte
- **DNS-Integration**: Weist DNS-Server an Clients zu (Pi-hole: 192.168.178.10)
- **Relevanz für Kubernetes**: 
  - Alle Clients erhalten automatisch Pi-hole als DNS
  - Kubernetes Services können über Domains erreichbar sein (wenn Pi-hole konfiguriert)

### 2. DNS-Weiterleitung
- **Konfiguration**: Internet → Zugangsdaten → DNS-Server
- **Aktuell**: Lokaler DNS-Server: 192.168.178.10 (Pi-hole)
- **Upstream-DNS**: Cloudflare (1.1.1.1, 1.0.0.1) oder Anbieter-DNS
- **DNS over TLS**: Aktiviert (dns.google)

### 3. Port-Freigaben
- **Zweck**: Externe Zugriffe auf interne Services
- **Für Kubernetes**: Normalerweise nicht nötig (alles intern)
- **Ausnahme**: Falls externe Services benötigt werden (z.B. SSH, spezielle Ports)

### 4. VPN (WireGuard)
- **Zweck**: Sicherer Fernzugriff auf Heimnetzwerk
- **Integration**: VPN-Clients können auf Kubernetes Services zugreifen
- **Verwendung**: Fernzugriff auf GitLab, Grafana, etc. über VPN

### 5. Priorisierung (Echtzeitpriorisierung)
- **Aktuelle Priorisierungen**:
  - `zuhause` (192.168.178.54) - Kubernetes Node
  - `DESKTOP-6QKGRU3` (192.168.178.25)
  - `Galaxy-Tab-S7` (192.168.178.49)
- **Relevanz**: Kubernetes Node hat Priorisierung für bessere Performance

### 6. TR-064 (App-Zugriff)
- **Status**: ✅ Aktiviert (wird genutzt für FRITZ!App Fon)
- **Zweck**: Apps können Router-Funktionen steuern
- **Sicherheit**: Aktiviert, aber nur für vertrauenswürdige Apps

### 7. UPnP Statusinformationen
- **Status**: ✅ Aktiviert
- **Zweck**: Statusinformationen über Netzwerk und Portfreigaben
- **Sicherheit**: Nur Lesen, keine automatischen Port-Öffnungen

## Optimierungsempfehlungen

### Kritisch (sofort)

1. **DHCP-Bereich anpassen**
   - **Problem**: 192.168.178.54 liegt im DHCP-Bereich
   - **Lösung**: DHCP-Bereich auf 20-50, 60-200 ändern
   - **Menü**: Heimnetz → Netzwerk → IPv4-Adressen

2. **Statische IP-Reservierung für Kubernetes**
   - **IP**: 192.168.178.54
   - **Gerät**: `zuhause` (Kubernetes Node)
   - **Zweck**: Verhindert IP-Konflikte

### Wichtig (bald)

3. **DNS-Rebind-Schutz aktivieren**
   - **Zweck**: Schutz vor DNS-Rebinding-Angriffen
   - **Menü**: Erweiterte Netzwerkeinstellungen → DNS-Rebind-Schutz

4. **Pi-hole lokale DNS-Records prüfen**
   - **Zweck**: `*.k8sops.online` → `192.168.178.54` sollte in Pi-hole konfiguriert sein
   - **Relevanz**: Clients können dann Kubernetes Services über Domains erreichen

## Menü-Navigation für Kubernetes-Integration

### DHCP-Konfiguration
**Heimnetz → Netzwerk → IPv4-Adressen** (`#/network/ipv4`)
- DHCP-Bereich anpassen
- Statische Reservierungen
- Lokaler DNS-Server konfigurieren

### DNS-Konfiguration
**Internet → Zugangsdaten → DNS-Server** (`#/internet/dns`)
- DNS-Server-Einstellungen
- DNS over TLS
- Upstream-DNS-Server

### Port-Freigaben
**Internet → Freigaben → Portfreigaben** (`#/access`)
- Externe Port-Weiterleitungen
- Firewall-Regeln

### VPN-Konfiguration
**Internet → Freigaben → VPN (WireGuard)** (`#/access/wireguard`)
- WireGuard-Verbindungen verwalten
- VPN-Client-IPs konfigurieren

### Netzwerk-Einstellungen
**Heimnetz → Netzwerk → Netzwerkeinstellungen** (`#/network/settings`)
- LAN-Port-Konfiguration
- Gastzugang
- Erweiterte Netzwerkeinstellungen

### Erweiterte Netzwerkeinstellungen
**Heimnetz → Netzwerk → Netzwerkeinstellungen → Erweiterte Netzwerkeinstellungen** (`#/network/settings/critical`)
- Heimnetzfreigaben (TR-064, UPnP)
- DNS-Rebind-Schutz
- IPv4/IPv6-Konfiguration
- Statische Routen

## Integration mit Kubernetes-Services

### Services über Ingress erreichbar

Alle Services sind über `*.k8sops.online` Domains erreichbar:
- `gitlab.k8sops.online` → 192.168.178.54:80/443
- `jenkins.k8sops.online` → 192.168.178.54:80/443
- `jellyfin.k8sops.online` → 192.168.178.54:80/443
- `argocd.k8sops.online` → 192.168.178.54:80/443
- `grafana.k8sops.online` → 192.168.178.54:80/443
- `prometheus.k8sops.online` → 192.168.178.54:80/443
- `heimdall.k8sops.online` → 192.168.178.54:80/443
- `komga.k8sops.online` → 192.168.178.54:80/443
- `loki.k8sops.online` → 192.168.178.54:80/443
- `syncthing.k8sops.online` → 192.168.178.54:80/443
- `test.k8sops.online` → 192.168.178.54:80/443

### DNS-Auflösung

**Für Clients im Heimnetz:**
- DNS-Server: 192.168.178.10 (Pi-hole)
- Pi-hole sollte lokale DNS-Records für `*.k8sops.online` → `192.168.178.54` haben
- Falls nicht: Pi-hole-Konfiguration prüfen

**Für Kubernetes Pods:**
- CoreDNS forwardet an Pi-hole (192.168.178.10)
- Service Discovery: `*.svc.cluster.local` → CoreDNS
- Externe Domains: CoreDNS → Pi-hole → Cloudflare

## Sicherheits-Einstellungen

### Aktiviert
- ✅ Firewall im Stealth Mode
- ✅ E-Mail-Filter über Port 25
- ✅ NetBIOS-Filter
- ✅ Teredo-Filter
- ✅ WPAD-Filter
- ✅ UPnP-Filter (Port 1900)
- ✅ TR-064 (App-Zugriff) - für FRITZ!App Fon benötigt

### Zu prüfen/aktivieren
- ⚠️ DNS-Rebind-Schutz - noch nicht aktiviert
- ⚠️ UPnP Statusinformationen - aktiviert (nur Lesen, weniger kritisch)

## Best Practices für Kubernetes-Integration

1. **DHCP-Bereich**: Außerhalb statischer IPs halten (LoadBalancer IPs)
2. **DNS-Konfiguration**: Pi-hole als zentraler DNS-Server
3. **Statische Reservierungen**: Für Kubernetes Node und LoadBalancer IPs
4. **VPN**: WireGuard für sicheren Fernzugriff auf Kubernetes Services
5. **Monitoring**: Priorisierung für Kubernetes Node (bereits aktiv)
6. **Sicherheit**: DNS-Rebind-Schutz aktivieren, unnötige Dienste deaktivieren

## Wichtige Erkenntnisse (2025-11-05)

### DNS-Server-Konfiguration
- **Aktuell**: Lokaler DNS-Server = 192.168.178.10 (Pi-hole)
- **NICHT**: 192.168.178.54 (wie ursprünglich dokumentiert)
- **Korrektur**: Dokumentation wurde aktualisiert

### DHCP-Konflikt
- **Problem**: 192.168.178.54 (Kubernetes Ingress) liegt im DHCP-Bereich (20-200)
- **Risiko**: DHCP könnte diese IP versehentlich vergeben
- **Lösung**: DHCP-Bereich anpassen oder statische Reservierung

### VPN-Integration
- **WireGuard aktiv**: Pixel (192.168.178.202)
- **VPN-Clients** können auf Kubernetes Services zugreifen
- **Verwendung**: Fernzugriff auf GitLab, Grafana, etc.

### Menü-Struktur
- **IPv4-Adressen**: `#/network/ipv4` (DHCP-Konfiguration)
- **DNS-Server**: `#/internet/dns` (DNS-Konfiguration)
- **WireGuard**: `#/access/wireguard` (VPN-Verwaltung)
- **Erweiterte Einstellungen**: `#/network/settings/critical` (TR-064, UPnP, DNS-Rebind-Schutz)

## Zusammenarbeit mit anderen Experten

- **DNS-Expert**: Pi-hole-Konfiguration, lokale DNS-Records
- **K8s-Expert**: LoadBalancer IPs, Ingress-Controller, Service-Erreichbarkeit
- **Infrastructure-Expert**: Gesamtübersicht Netzwerk-Topologie
- **Security-Expert**: DNS-Rebind-Schutz, Firewall-Regeln

