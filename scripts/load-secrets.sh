#!/bin/bash
# Lädt alle Secrets und exportiert sie als Environment-Variablen
# Usage: source scripts/load-secrets.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_DIR="$HOME/.cursor/secrets"
SYSTEM_KEY_FILE="$SECRETS_DIR/system-key.txt"
SYSTEM_KEY_DIR="$SECRETS_DIR/system-key"
PASSWORD_DIR="$SECRETS_DIR/password"

# Funktion zum Laden eines Secrets
load_secret() {
    local secret_name="$1"
    local encryption_type="${2:-system-key}"
    
    if [ "$encryption_type" = "system-key" ]; then
        local encrypted_file="$SYSTEM_KEY_DIR/${secret_name}.age"
        if [ -f "$encrypted_file" ]; then
            export "$secret_name=$(age -d -i "$SYSTEM_KEY_FILE" "$encrypted_file")"
        fi
    elif [ "$encryption_type" = "password" ]; then
        local encrypted_file="$PASSWORD_DIR/${secret_name}.age"
        if [ -f "$encrypted_file" ]; then
            # Für Passwort-verschlüsselte Secrets muss der Benutzer die Passphrase eingeben
            # Diese werden nicht automatisch geladen, da sie interaktive Eingabe benötigen
            echo "⚠️  Passwort-verschlüsseltes Secret '$secret_name' wird übersprungen (benötigt interaktive Passphrase)" >&2
        fi
    fi
}

# Lade alle System-Key-verschlüsselten Secrets
if [ -d "$SYSTEM_KEY_DIR" ]; then
    for encrypted_file in "$SYSTEM_KEY_DIR"/*.age; do
        if [ -f "$encrypted_file" ]; then
            secret_name=$(basename "$encrypted_file" .age)
            load_secret "$secret_name" "system-key"
        fi
    done
fi

# Info über Passwort-verschlüsselte Secrets
if [ -d "$PASSWORD_DIR" ]; then
    password_secrets=$(find "$PASSWORD_DIR" -name "*.age" -type f 2>/dev/null | wc -l)
    if [ "$password_secrets" -gt 0 ]; then
        echo "ℹ️  $password_secrets Passwort-verschlüsselte Secrets gefunden (nicht automatisch geladen)" >&2
        echo "   Verwende decrypt-secret.sh für einzelne Secrets" >&2
    fi
fi

