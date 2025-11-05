#!/bin/bash
# Cursor .deb Installation Script
# Installiert Cursor von einem .deb-File

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
log_warning() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

# Prüfe ob .deb-File als Argument übergeben wurde
DEB_FILE="${1:-}"

if [ -z "$DEB_FILE" ]; then
    log_info "Suche nach Cursor .deb-File..."
    DEB_FILE=$(find ~/Downloads ~/Desktop ~ -maxdepth 3 -name "*cursor*.deb" -o -name "*Cursor*.deb" 2>/dev/null | head -1)
    
    if [ -z "$DEB_FILE" ]; then
        log_error "Kein .deb-File gefunden!"
        echo ""
        echo "Usage: $0 <path-to-cursor.deb>"
        echo "Oder: Lege die .deb-Datei in ~/Downloads ab und führe das Script erneut aus"
        exit 1
    fi
fi

if [ ! -f "$DEB_FILE" ]; then
    log_error "Datei nicht gefunden: $DEB_FILE"
    exit 1
fi

log_success "Gefunden: $DEB_FILE"

# Prüfe ob sudo verfügbar ist
if ! command -v sudo &> /dev/null; then
    log_error "sudo nicht verfügbar. Bitte installiere sudo oder führe als root aus."
    exit 1
fi

# Prüfe ob dpkg verfügbar ist
if ! command -v dpkg &> /dev/null; then
    log_error "dpkg nicht verfügbar. Bitte installiere dpkg."
    exit 1
fi

# Prüfe ob bereits installiert
if dpkg -l | grep -q "cursor"; then
    log_warning "Cursor scheint bereits installiert zu sein:"
    dpkg -l | grep cursor
    echo ""
    read -p "Trotzdem installieren? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
fi

log_info "Installiere Cursor..."
log_info "Datei: $DEB_FILE"

# Installiere mit dpkg
sudo dpkg -i "$DEB_FILE" || {
    log_warning "dpkg meldete Fehler. Versuche fehlende Abhängigkeiten zu installieren..."
    sudo apt-get update
    sudo apt-get install -f -y
    log_info "Installation erneut versuchen..."
    sudo dpkg -i "$DEB_FILE"
}

log_success "Cursor installiert!"
echo ""

# Prüfe Installation
if command -v cursor &> /dev/null; then
    log_success "Cursor ist im PATH verfügbar"
    cursor --version 2>&1 || log_info "Cursor kann gestartet werden"
else
    log_info "Cursor ist möglicherweise in /usr/bin/cursor oder /opt/cursor verfügbar"
    if [ -f "/usr/bin/cursor" ]; then
        log_success "Cursor gefunden: /usr/bin/cursor"
    elif [ -f "/opt/cursor/cursor" ]; then
        log_success "Cursor gefunden: /opt/cursor/cursor"
    fi
fi

echo ""
log_info "Installation abgeschlossen!"
echo ""
echo "Cursor kann jetzt gestartet werden mit:"
echo "  cursor"
echo "  oder"
echo "  /usr/bin/cursor"

