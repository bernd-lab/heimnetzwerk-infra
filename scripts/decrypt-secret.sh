#!/bin/bash
# Entschlüsselt ein Secret (für Agenten)
# Usage: ./decrypt-secret.sh <secret-name> [system-key|password]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_DIR="$HOME/.cursor/secrets"
SYSTEM_KEY_FILE="$SECRETS_DIR/system-key.txt"
SYSTEM_KEY_DIR="$SECRETS_DIR/system-key"
PASSWORD_DIR="$SECRETS_DIR/password"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <secret-name> [system-key|password]"
    echo "Example: $0 FRITZBOX_PASSWORD system-key"
    exit 1
fi

SECRET_NAME="$1"
ENCRYPTION_TYPE="${2:-system-key}"

if [ "$ENCRYPTION_TYPE" = "system-key" ]; then
    ENCRYPTED_FILE="$SYSTEM_KEY_DIR/${SECRET_NAME}.age"
    
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "Error: Secret '$SECRET_NAME' nicht gefunden: $ENCRYPTED_FILE" >&2
        exit 1
    fi
    
    if [ ! -f "$SYSTEM_KEY_FILE" ]; then
        echo "Error: System-Key nicht gefunden: $SYSTEM_KEY_FILE" >&2
        exit 1
    fi
    
    # Entschlüssele mit System-Key
    age -d -i "$SYSTEM_KEY_FILE" "$ENCRYPTED_FILE"
    
elif [ "$ENCRYPTION_TYPE" = "password" ]; then
    ENCRYPTED_FILE="$PASSWORD_DIR/${SECRET_NAME}.age"
    
    if [ ! -f "$ENCRYPTED_FILE" ]; then
        echo "Error: Secret '$SECRET_NAME' nicht gefunden: $ENCRYPTED_FILE" >&2
        exit 1
    fi
    
    # Entschlüssele mit Passphrase (interaktiv)
    age -d "$ENCRYPTED_FILE"
    
else
    echo "Error: Ungültiger Verschlüsselungstyp: $ENCRYPTION_TYPE" >&2
    echo "Erlaubt: system-key, password" >&2
    exit 1
fi

