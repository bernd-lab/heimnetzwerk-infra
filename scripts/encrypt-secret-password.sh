#!/bin/bash
# Verschlüsselt ein Secret mit Passphrase (für kritische Secrets)
# Usage: ./encrypt-secret-password.sh <secret-name>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SECRETS_DIR="$HOME/.cursor/secrets"
PASSWORD_DIR="$SECRETS_DIR/password"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <secret-name>"
    echo "Example: $0 FRITZBOX_PASSWORD"
    echo ""
    echo "Das Secret wird interaktiv abgefragt und mit Passphrase verschlüsselt."
    exit 1
fi

SECRET_NAME="$1"
ENCRYPTED_FILE="$PASSWORD_DIR/${SECRET_NAME}.age"

# Frage Secret-Wert ab (ohne Echo)
echo -n "Secret-Wert für '$SECRET_NAME': "
read -s SECRET_VALUE
echo ""

if [ -z "$SECRET_VALUE" ]; then
    echo "Error: Secret-Wert darf nicht leer sein"
    exit 1
fi

# Verschlüssele mit Passphrase (interaktiv)
echo "$SECRET_VALUE" | age -p -o "$ENCRYPTED_FILE"

# Setze sichere Berechtigungen
chmod 600 "$ENCRYPTED_FILE"

echo "✅ Secret '$SECRET_NAME' mit Passphrase verschlüsselt gespeichert: $ENCRYPTED_FILE"
echo "⚠️  Wichtig: Passphrase sicher aufbewahren!"

