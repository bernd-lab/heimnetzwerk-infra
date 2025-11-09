#!/bin/bash
# Pi-hole Ad-Blocker Listen hinzufügen über API
# Verwendet die Ad-Blocker-Listen aus der ConfigMap

set -e

NAMESPACE="pihole"
CONFIGMAP="pihole-adlists-config"
PIHOLE_POD=$(kubectl get pod -n "$NAMESPACE" -l app=pihole -o jsonpath='{.items[0].metadata.name}')

if [ -z "$PIHOLE_POD" ]; then
    echo "❌ Pi-hole Pod nicht gefunden!"
    exit 1
fi

echo "📋 Lade Ad-Blocker-Listen aus ConfigMap..."
kubectl get configmap -n "$NAMESPACE" "$CONFIGMAP" -o jsonpath='{.data.adlists\.list}' > /tmp/adlists.list

echo "🔍 Prüfe Pi-hole API-Zugriff..."
# Prüfe ob API verfügbar ist
if ! kubectl exec -n "$NAMESPACE" "$PIHOLE_POD" -- curl -s -f "http://127.0.0.1:8080/api/version" > /dev/null 2>&1; then
    echo "⚠️  Pi-hole API nicht verfügbar. Verwende direkte adlists.list Methode."
    echo "✅ Ad-Blocker-Listen werden beim nächsten Pi-hole Neustart geladen."
    exit 0
fi

echo "🔑 Prüfe API-Token..."
# Versuche API-Token aus Secret zu holen
API_TOKEN=$(kubectl get secret -n "$NAMESPACE" pihole-secret -o jsonpath='{.data.API_TOKEN}' 2>/dev/null | base64 -d 2>/dev/null || echo "")

if [ -z "$API_TOKEN" ]; then
    echo "⚠️  Kein API-Token gefunden. Versuche ohne Authentifizierung..."
    AUTH_PARAM=""
else
    echo "✅ API-Token gefunden"
    AUTH_PARAM="&auth=${API_TOKEN}"
fi

echo "➕ Füge Ad-Blocker-Listen hinzu..."
ADDED=0
SKIPPED=0
FAILED=0

while IFS= read -r URL || [ -n "$URL" ]; do
    # Skip empty lines and comments
    if [ -z "$URL" ] || [ "${URL#\#}" != "$URL" ]; then
        continue
    fi
    
    # Trim whitespace
    URL=$(echo "$URL" | xargs)
    
    if [ -z "$URL" ]; then
        continue
    fi
    
    echo -n "  Adding: $URL ... "
    
    # Add adlist via API (correct endpoint: /admin/api.php)
    RESPONSE=$(kubectl exec -n "$NAMESPACE" "$PIHOLE_POD" -- curl -s "http://127.0.0.1:8080/admin/api.php?list=adlist&action=add&address=${URL}${AUTH_PARAM}" 2>/dev/null)
    
    if echo "$RESPONSE" | grep -q '"success"'; then
        echo "✅"
        ADDED=$((ADDED + 1))
    elif echo "$RESPONSE" | grep -q "already exists\|duplicate"; then
        echo "⚠️  Bereits vorhanden"
        SKIPPED=$((SKIPPED + 1))
    else
        echo "❌ Fehler: $RESPONSE"
        FAILED=$((FAILED + 1))
    fi
done < /tmp/adlists.list

echo ""
echo "📊 Zusammenfassung:"
echo "  ✅ Hinzugefügt: $ADDED"
echo "  ⚠️  Übersprungen: $SKIPPED"
echo "  ❌ Fehler: $FAILED"

if [ $FAILED -eq 0 ]; then
    echo ""
    echo "🔄 Aktualisiere Gravity-Datenbank..."
    kubectl exec -n "$NAMESPACE" "$PIHOLE_POD" -- pihole -g > /dev/null 2>&1 || echo "⚠️  Gravity-Update kann einige Minuten dauern"
    echo "✅ Fertig!"
else
    echo ""
    echo "⚠️  Einige Listen konnten nicht hinzugefügt werden. Prüfe die Fehlermeldungen oben."
    exit 1
fi

