#!/bin/bash
# Verschlüsselt ein Secret mit System-Key
# Usage: ./encrypt-secret.sh <secret-name> <secret-value>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_DIR="$HOME/.cursor/secrets"
SYSTEM_KEY_FILE="$SECRETS_DIR/system-key.txt"
SYSTEM_KEY_DIR="$SECRETS_DIR/system-key"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <secret-name> <secret-value>"
    echo "Example: $0 FRITZBOX_PASSWORD 'mysecret'"
    exit 1
fi

SECRET_NAME="$1"
SECRET_VALUE="$2"

# Prüfe ob System-Key existiert
if [ ! -f "$SYSTEM_KEY_FILE" ]; then
    echo "Error: System-Key nicht gefunden: $SYSTEM_KEY_FILE"
    echo "Bitte zuerst 'age-keygen -o $SYSTEM_KEY_FILE' ausführen"
    exit 1
fi

# Extrahiere Public Key aus System-Key
PUBLIC_KEY=$(grep "public key:" "$SYSTEM_KEY_FILE" | cut -d' ' -f4)

if [ -z "$PUBLIC_KEY" ]; then
    echo "Error: Konnte Public Key nicht aus System-Key extrahieren"
    exit 1
fi

# Verschlüssele Secret
ENCRYPTED_FILE="$SYSTEM_KEY_DIR/${SECRET_NAME}.age"
echo "$SECRET_VALUE" | age -r "$PUBLIC_KEY" -o "$ENCRYPTED_FILE"

# Setze sichere Berechtigungen
chmod 600 "$ENCRYPTED_FILE"

echo "✅ Secret '$SECRET_NAME' verschlüsselt gespeichert: $ENCRYPTED_FILE"

