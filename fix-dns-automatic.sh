#!/bin/bash
# Script zum Entfernen manueller DNS-Konfigurationen
# Damit Geräte automatisch DNS von der Fritzbox erhalten

set -e

echo "=== DNS-Konfiguration auf automatisch setzen ==="
echo ""

# Fedora/Linux: NetworkManager DNS-Konfiguration entfernen
if command -v nmcli &> /dev/null; then
    echo "[1/2] Fedora/Linux: Entferne manuelle DNS-Konfiguration..."
    
    # Aktive Verbindung finden
    ACTIVE_CONN=$(nmcli -t -f NAME connection show --active | grep -v lo | head -1)
    
    if [ -z "$ACTIVE_CONN" ]; then
        echo "⚠️  Keine aktive Verbindung gefunden!"
        exit 1
    fi
    
    echo "   Aktive Verbindung: $ACTIVE_CONN"
    
    # Manuelle DNS-Einstellungen entfernen
    sudo nmcli connection modify "$ACTIVE_CONN" ipv4.dns ""
    sudo nmcli connection modify "$ACTIVE_CONN" ipv6.dns ""
    
    # Verbindung neu starten
    echo "   Starte Verbindung neu..."
    sudo nmcli connection down "$ACTIVE_CONN"
    sudo nmcli connection up "$ACTIVE_CONN"
    
    echo "✅ Fedora/Linux: DNS-Konfiguration entfernt"
    echo ""
    
    # DNS-Test
    echo "   Teste DNS-Auflösung..."
    sleep 2
    if dig google.de +short | grep -q "142\|172\|216"; then
        echo "✅ DNS funktioniert!"
    else
        echo "⚠️  DNS-Test fehlgeschlagen, prüfe manuell"
    fi
else
    echo "⚠️  nmcli nicht gefunden (kein NetworkManager)"
fi

echo ""
echo "=== Fertig ==="
echo ""
echo "Bitte prüfe:"
echo "  - DNS sollte jetzt automatisch von der Fritzbox kommen"
echo "  - resolvectl status (Linux) oder ipconfig /all (Windows)"

