#!/bin/bash
# Automatischer Git-Commit für Agenten
# Versucht alle Änderungen zu committen und meldet Probleme

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Git-Status prüfen..."

# Prüfe ob Git-Repository vorhanden
if [ ! -d .git ]; then
    echo -e "${RED}❌ Kein Git-Repository gefunden${NC}"
    echo "   Problem: .git Verzeichnis existiert nicht"
    echo "   Lösung: 'git init' ausführen oder in existierendes Repository wechseln"
    exit 1
fi

# Prüfe ob Remote konfiguriert ist
REMOTE_COUNT=$(git remote | wc -l)
if [ "$REMOTE_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Kein Git-Remote konfiguriert${NC}"
    echo "   Problem: Kein Remote-Repository (GitHub/GitLab) konfiguriert"
    echo "   Lösung: 'git remote add origin <URL>' ausführen"
    echo "   Hinweis: Commits werden lokal gemacht, aber nicht gepusht"
fi

# Prüfe uncommittete Änderungen
UNCOMMITTED=$(git status --porcelain | wc -l)
if [ "$UNCOMMITTED" -eq 0 ]; then
    echo -e "${GREEN}✅ Keine uncommitteten Änderungen${NC}"
    exit 0
fi

echo "📋 Uncommittete Änderungen gefunden: $UNCOMMITTED Dateien"

# Zeige Änderungen
echo ""
echo "📝 Änderungen:"
git status --short | head -20
if [ "$UNCOMMITTED" -gt 20 ]; then
    echo "... und $((UNCOMMITTED - 20)) weitere Dateien"
fi

# Prüfe ob .gitignore korrekt ist
if [ ! -f .gitignore ]; then
    echo -e "${YELLOW}⚠️  .gitignore fehlt${NC}"
    echo "   Problem: Secrets könnten versehentlich committet werden"
    echo "   Lösung: .gitignore erstellen"
fi

# Prüfe ob Secrets versehentlich committet werden würden
SECRETS_FOUND=$(git status --porcelain | grep -E "\.age$|\.key$|\.pem$|secrets/.*\.age" | wc -l || true)
if [ "$SECRETS_FOUND" -gt 0 ]; then
    echo -e "${RED}❌ VERSCHLÜSSELTE SECRETS WÜRDEN COMMITTET WERDEN!${NC}"
    echo "   Problem: Secrets-Dateien (.age, .key, .pem) sind in den Änderungen"
    echo "   Lösung: .gitignore aktualisieren oder Secrets aus Staging entfernen"
    echo ""
    echo "   Gefährliche Dateien:"
    git status --porcelain | grep -E "\.age$|\.key$|\.pem$|secrets/.*\.age" || true
    exit 1
fi

# Prüfe Git-Identität
GIT_USER=$(git config user.name || echo "")
GIT_EMAIL=$(git config user.email || echo "")

if [ -z "$GIT_USER" ] || [ -z "$GIT_EMAIL" ]; then
    echo -e "${YELLOW}⚠️  Git-Identität nicht konfiguriert${NC}"
    echo "   Problem: user.name oder user.email nicht gesetzt"
    echo "   Lösung: 'git config user.name \"Name\"' und 'git config user.email \"email\"'"
    echo "   Hinweis: Commit wird trotzdem versucht"
fi

# Erstelle Commit-Nachricht
AGENT_NAME="${AGENT_NAME:-Auto-Git-Commit}"
COMMIT_MESSAGE="${COMMIT_MESSAGE:-Auto-commit: ${AGENT_NAME} - $(date '+%Y-%m-%d %H:%M:%S')}"

echo ""
echo "📝 Commit-Nachricht: $COMMIT_MESSAGE"

# Versuche zu committen
echo ""
echo "💾 Committe Änderungen..."

if git add -A; then
    echo "✅ Dateien zum Staging hinzugefügt"
else
    echo -e "${RED}❌ Fehler beim Hinzufügen von Dateien${NC}"
    exit 1
fi

if git commit -m "$COMMIT_MESSAGE"; then
    echo -e "${GREEN}✅ Commit erfolgreich erstellt${NC}"
    COMMIT_HASH=$(git rev-parse --short HEAD)
    echo "   Commit-Hash: $COMMIT_HASH"
else
    echo -e "${RED}❌ Fehler beim Erstellen des Commits${NC}"
    echo "   Mögliche Ursachen:"
    echo "   - Keine Änderungen zum Committen"
    echo "   - Git-Repository beschädigt"
    echo "   - Berechtigungsprobleme"
    exit 1
fi

# Versuche zu pushen (wenn Remote konfiguriert)
if [ "$REMOTE_COUNT" -gt 0 ]; then
    echo ""
    echo "🚀 Versuche zu pushen..."
    
    # Prüfe welches Remote (GitHub oder GitLab)
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    
    if echo "$REMOTE_URL" | grep -q "github.com"; then
        REMOTE_TYPE="GitHub"
    elif echo "$REMOTE_URL" | grep -q "gitlab"; then
        REMOTE_TYPE="GitLab"
    else
        REMOTE_TYPE="Unbekannt"
    fi
    
    if git push 2>&1; then
        echo -e "${GREEN}✅ Push erfolgreich zu $REMOTE_TYPE${NC}"
    else
        PUSH_ERROR=$?
        echo -e "${YELLOW}⚠️  Push fehlgeschlagen${NC}"
        echo "   Remote: $REMOTE_TYPE ($REMOTE_URL)"
        echo "   Exit-Code: $PUSH_ERROR"
        echo ""
        echo "   Mögliche Ursachen:"
        echo "   - Keine Berechtigung zum Pushen"
        echo "   - Remote-Repository nicht erreichbar"
        echo "   - Authentifizierung fehlgeschlagen (Token/SSH-Key)"
        echo "   - Branch ist geschützt"
        echo ""
        echo "   Hinweis: Commit wurde lokal erstellt, aber nicht gepusht"
        echo "   Lösung: Manuell pushen mit 'git push'"
    fi
else
    echo ""
    echo "ℹ️  Kein Remote konfiguriert - Commit nur lokal"
fi

echo ""
echo -e "${GREEN}✅ Git-Commit abgeschlossen${NC}"

