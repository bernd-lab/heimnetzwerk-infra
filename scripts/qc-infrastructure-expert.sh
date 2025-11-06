#!/bin/bash
# Qualitätskontrolle für Infrastructure-Expert
# Prüft Infrastruktur-Funktionalität vor Git-Commit

set -e

echo "=== Infrastructure-Expert Qualitätskontrolle ==="

# 1. Netzwerk-Konnektivität testen
echo "1. Teste Netzwerk-Konnektivität..."
if ! ping -c 2 192.168.178.1 > /dev/null 2>&1; then
  echo "❌ FEHLER: Netzwerk-Konnektivität (Fritzbox) fehlgeschlagen!"
  exit 1
fi
echo "✅ Netzwerk-Konnektivität erfolgreich"

# 2. DNS-Auflösung testen
echo "2. Teste DNS-Auflösung..."
if ! nslookup google.de > /dev/null 2>&1; then
  echo "❌ FEHLER: DNS-Auflösung fehlgeschlagen!"
  exit 1
fi
echo "✅ DNS-Auflösung erfolgreich"

# 3. Kubernetes-Services prüfen
echo "3. Prüfe Kubernetes-Services..."
if ! kubectl get svc -A > /dev/null 2>&1; then
  echo "❌ FEHLER: Kubernetes-Services nicht erreichbar!"
  exit 1
fi
echo "✅ Kubernetes-Services erreichbar"

# 4. Prüfe auf Secrets in geänderten Dateien
echo "4. Prüfe auf Secrets..."
if git diff --cached --name-only 2>/dev/null | xargs grep -l -E "(password|secret|key|token)" 2>/dev/null | grep -v -E "(\.md$|\.sh$|\.yaml$|\.yml$)" > /dev/null 2>&1; then
  echo "⚠️  WARNUNG: Mögliche Secrets in geänderten Dateien gefunden!"
  echo "Bitte manuell prüfen!"
fi

echo "✅ Alle Qualitätskontrolle-Tests erfolgreich!"

