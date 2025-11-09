#!/bin/bash
# Synchronisiert Agent-Definitionen von Cursor.ai zu Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

echo "🔄 Synchronisiere Agent-Definitionen von Cursor.ai zu Claude Code..."
echo ""

# Erstelle .claude/agents/ falls nicht vorhanden
mkdir -p .claude/agents

# Synchronisiere alle Agent-Definitionen
COPIED=0
SKIPPED=0

for agent in .cursor/commands/*.md; do
    if [ ! -f "$agent" ]; then
        continue
    fi
    
    agent_name=$(basename "$agent")
    target=".claude/agents/$agent_name"
    
    # Prüfe ob Datei unterschiedlich ist
    if [ -f "$target" ] && cmp -s "$agent" "$target"; then
        echo "  ⏭️  $agent_name (unverändert)"
        ((SKIPPED++))
    else
        cp "$agent" "$target"
        echo "  ✅ $agent_name"
        ((COPIED++))
    fi
done

echo ""
echo "📊 Zusammenfassung:"
echo "  ✅ Kopiert: $COPIED"
echo "  ⏭️  Übersprungen: $SKIPPED"
echo ""
echo "✅ Synchronisation abgeschlossen!"

