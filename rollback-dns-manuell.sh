#!/bin/bash
# Rollback-Script: Zurück zu manuellem DNS falls automatische DNS nicht funktioniert

set -e

echo "=== DNS Rollback: Zurück zu manuellem DNS ==="
echo ""

# Fedora/Linux: NetworkManager DNS auf manuell setzen
if command -v nmcli &> /dev/null; then
    echo "[1/2] Fedora/Linux: Setze DNS auf manuell (8.8.8.8, 1.1.1.1)..."
    
    # Aktive Verbindung finden
    ACTIVE_CONN=$(nmcli -t -f NAME connection show --active | grep -v lo | head -1)
    
    if [ -z "$ACTIVE_CONN" ]; then
        echo "⚠️  Keine aktive Verbindung gefunden!"
        exit 1
    fi
    
    echo "   Aktive Verbindung: $ACTIVE_CONN"
    
    # Manuelle DNS-Einstellungen setzen (Google + Cloudflare)
    sudo nmcli connection modify "$ACTIVE_CONN" ipv4.dns "8.8.8.8 1.1.1.1"
    
    # Verbindung neu starten
    echo "   Starte Verbindung neu..."
    sudo nmcli connection down "$ACTIVE_CONN"
    sudo nmcli connection up "$ACTIVE_CONN"
    
    echo "✅ Fedora/Linux: DNS auf manuell gesetzt"
    echo ""
    
    # DNS-Test
    echo "   Teste DNS-Auflösung..."
    sleep 2
    if dig google.de +short | grep -q "142\|172\|216"; then
        echo "✅ DNS funktioniert wieder!"
    else
        echo "⚠️  DNS-Test fehlgeschlagen, prüfe manuell"
    fi
else
    echo "⚠️  nmcli nicht gefunden (kein NetworkManager)"
fi

echo ""
echo "=== Fertig ==="
echo ""
echo "DNS ist jetzt wieder auf manuell gesetzt:"
echo "  - Primär: 8.8.8.8 (Google)"
echo "  - Sekundär: 1.1.1.1 (Cloudflare)"

