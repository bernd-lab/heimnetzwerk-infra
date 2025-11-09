#!/bin/bash
# Pi-hole DNS-Fix anwenden
# Datum: 2025-11-07
# Zweck: Lösung für "ignoring query from non-local network" Problem anwenden

set -e

echo "=========================================="
echo "Pi-hole DNS-Fix anwenden"
echo "=========================================="
echo ""

# Prüfe ob kubectl verfügbar ist
if ! command -v kubectl &> /dev/null; then
    echo "FEHLER: kubectl ist nicht verfügbar"
    exit 1
fi

# Prüfe Cluster-Verbindung
if ! kubectl cluster-info &> /dev/null; then
    echo "FEHLER: Keine Verbindung zum Kubernetes-Cluster"
    exit 1
fi

echo "1. ConfigMap aktualisieren..."
kubectl apply -f k8s/pihole/dnsmasq-configmap.yaml
echo "   ✅ ConfigMap aktualisiert"
echo ""

echo "2. Service aktualisieren..."
kubectl apply -f k8s/pihole/service.yaml
echo "   ✅ Service aktualisiert"
echo ""

echo "3. Deployment aktualisieren..."
kubectl apply -f k8s/pihole/deployment.yaml
echo "   ✅ Deployment aktualisiert"
echo ""

echo "4. Warte auf Pod-Neustart..."
kubectl rollout status deployment/pihole -n pihole --timeout=120s
echo "   ✅ Pod läuft"
echo ""

echo "5. Prüfe Init-Container-Logs..."
INIT_LOG=$(kubectl logs -n pihole -l app=pihole -c fix-pihole-config --tail=20 2>/dev/null || echo "")
if echo "$INIT_LOG" | grep -q "SUCCESS: pihole.toml configured correctly"; then
    echo "   ✅ Init-Container erfolgreich"
else
    echo "   ⚠️  Init-Container-Logs prüfen:"
    echo "$INIT_LOG"
fi
echo ""

echo "6. Prüfe Pi-hole-Logs auf Warnungen..."
POD=$(kubectl get pods -n pihole -l app=pihole -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "$POD" ]; then
    WARNINGS=$(kubectl logs -n pihole $POD --tail=100 2>/dev/null | grep -i "ignoring query from non-local network" || echo "")
    if [ -z "$WARNINGS" ]; then
        echo "   ✅ Keine 'ignoring query from non-local network' Warnungen gefunden"
    else
        echo "   ⚠️  Warnungen gefunden:"
        echo "$WARNINGS"
    fi
else
    echo "   ⚠️  Pod nicht gefunden"
fi
echo ""

echo "7. Verifiziere pihole.toml Konfiguration..."
if [ -n "$POD" ]; then
    TOML_CONTENT=$(kubectl exec -n pihole $POD -- cat /etc/pihole/pihole.toml 2>/dev/null || echo "")
    if echo "$TOML_CONTENT" | grep -q 'dns_listeningMode = "all"'; then
        echo "   ✅ dns_listeningMode = all gefunden"
    else
        echo "   ⚠️  dns_listeningMode = all NICHT gefunden"
        echo "   Aktuelle Konfiguration:"
        echo "$TOML_CONTENT"
    fi
    if echo "$TOML_CONTENT" | grep -q 'interface = "eth0"'; then
        echo "   ✅ interface = eth0 gefunden"
    else
        echo "   ⚠️  interface = eth0 NICHT gefunden"
    fi
else
    echo "   ⚠️  Pod nicht gefunden, kann nicht verifizieren"
fi
echo ""

echo "8. DNS-Test..."
if command -v dig &> /dev/null; then
    if dig @192.168.178.10 google.de +short +timeout=2 &> /dev/null; then
        echo "   ✅ DNS-Abfrage erfolgreich"
    else
        echo "   ⚠️  DNS-Abfrage fehlgeschlagen"
    fi
else
    echo "   ⚠️  dig nicht verfügbar, DNS-Test übersprungen"
fi
echo ""

echo "=========================================="
echo "Pi-hole DNS-Fix angewendet"
echo "=========================================="
echo ""
echo "Nächste Schritte:"
echo "1. Prüfe Logs: kubectl logs -n pihole -l app=pihole --tail=100"
echo "2. Teste DNS von Windows-Client: nslookup google.de 192.168.178.10"
echo "3. Prüfe auf Warnungen: kubectl logs -n pihole -l app=pihole | grep -i warning"
echo ""

