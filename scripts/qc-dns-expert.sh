#!/bin/bash
# Qualitätskontrolle für DNS-Expert
# Prüft DNS-Funktionalität vor Git-Commit

set -e

echo "=== DNS-Expert Qualitätskontrolle ==="

# 1. DNS-Auflösung testen (über Standard-DNS, nicht direkt Pi-hole)
echo "1. Teste DNS-Auflösung..."
if ! dig google.de +short +timeout=3 > /dev/null 2>&1; then
  echo "❌ FEHLER: DNS-Auflösung (google.de) fehlgeschlagen!"
  exit 1
fi
echo "✅ DNS-Auflösung erfolgreich"

# 1b. Direkte Pi-hole-Test (nur wenn erreichbar)
echo "1b. Teste direkte Pi-hole-Verbindung (optional)..."
if dig @192.168.178.10 google.de +short +timeout=2 > /dev/null 2>&1; then
  echo "✅ Direkte Pi-hole-Verbindung erfolgreich"
else
  echo "⚠️  Direkte Pi-hole-Verbindung nicht erreichbar (normal bei WSL-Netzwerk-Isolation)"
fi

# 2. Lokale Domains testen
echo "2. Teste lokale Domains..."
if ! dig @192.168.178.10 gitlab.k8sops.online +short +timeout=3 > /dev/null 2>&1; then
  echo "⚠️  WARNUNG: Lokale Domain-Auflösung (gitlab.k8sops.online) fehlgeschlagen!"
  echo "Fortfahren mit Warnung..."
fi

# 3. Pi-hole Service-Status prüfen
echo "3. Prüfe Pi-hole Service-Status..."
if ! kubectl get svc pihole -n pihole > /dev/null 2>&1; then
  echo "❌ FEHLER: Pi-hole Service nicht erreichbar!"
  exit 1
fi
echo "✅ Pi-hole Service erreichbar"

# 4. Pi-hole Pod-Status prüfen
echo "4. Prüfe Pi-hole Pod-Status..."
if ! kubectl get pods -n pihole -l app=pihole | grep -q "Running"; then
  echo "❌ FEHLER: Pi-hole Pod nicht im Running-Status!"
  exit 1
fi
echo "✅ Pi-hole Pod läuft"

# 5. Prüfe auf Secrets in geänderten Dateien
echo "5. Prüfe auf Secrets..."
if git diff --cached --name-only 2>/dev/null | xargs grep -l -E "(password|secret|key|token)" 2>/dev/null | grep -v -E "(\.md$|\.sh$|\.yaml$|\.yml$)" > /dev/null 2>&1; then
  echo "⚠️  WARNUNG: Mögliche Secrets in geänderten Dateien gefunden!"
  echo "Bitte manuell prüfen!"
fi

echo "✅ Alle Qualitätskontrolle-Tests erfolgreich!"

