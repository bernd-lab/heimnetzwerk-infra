#!/bin/bash
# Git-Commit mit Qualitätskontrolle
# Führt Qualitätskontrolle-Tests durch und committet nur bei Erfolg

set -e

AGENT_NAME="${1:-unknown}"
COMMIT_MESSAGE="${2:-$(date '+%Y-%m-%d %H:%M') - Änderungen}"

echo "=== Git-Commit mit Qualitätskontrolle ==="
echo "Agent: $AGENT_NAME"
echo "Commit-Message: $COMMIT_MESSAGE"
echo ""

# 1. Qualitätskontrolle durchführen
echo "=== Schritt 1: Qualitätskontrolle ==="

# Prüfe ob Qualitätskontrolle-Script für Agent existiert
QC_SCRIPT="scripts/qc-${AGENT_NAME}.sh"
if [ -f "$QC_SCRIPT" ]; then
  echo "Führe Agent-spezifische Qualitätskontrolle durch..."
  bash "$QC_SCRIPT" || {
    echo "❌ FEHLER: Qualitätskontrolle fehlgeschlagen!"
    exit 1
  }
else
  echo "⚠️  Kein Agent-spezifisches Qualitätskontrolle-Script gefunden: $QC_SCRIPT"
  echo "Führe Standard-Qualitätskontrolle durch..."
  
  # Standard-Qualitätskontrolle
  echo "Prüfe Git-Status..."
  if ! git status > /dev/null 2>&1; then
    echo "❌ FEHLER: Kein Git-Repository gefunden!"
    exit 1
  fi
  
  echo "Prüfe auf Secrets..."
  if git diff --cached --name-only | grep -E "(secret|password|key|token)" > /dev/null 2>&1; then
    echo "⚠️  WARNUNG: Mögliche Secrets in geänderten Dateien gefunden!"
    echo "Bitte manuell prüfen!"
  fi
fi

echo "✅ Qualitätskontrolle erfolgreich!"
echo ""

# 2. Git-Commit durchführen
echo "=== Schritt 2: Git-Commit ==="

# Prüfe ob es Änderungen gibt
if [ -z "$(git status --porcelain)" ]; then
  echo "⚠️  Keine Änderungen zum Committen gefunden."
  exit 0
fi

# Führe Commit durch
echo "Führe Git-Commit durch..."
git add -A
git commit -m "$COMMIT_MESSAGE" || {
  echo "❌ FEHLER: Git-Commit fehlgeschlagen!"
  exit 1
}

echo "✅ Git-Commit erfolgreich!"
echo ""

# 3. Push durchführen (falls Remote konfiguriert)
echo "=== Schritt 3: Git-Push ==="
if git remote | grep -q "origin"; then
  echo "Führe Git-Push durch..."
  git push || {
    echo "❌ FEHLER: Git-Push fehlgeschlagen!"
    exit 1
  }
  echo "✅ Git-Push erfolgreich!"
else
  echo "⚠️  Kein Remote-Repository konfiguriert. Push übersprungen."
fi

echo ""
echo "=== Erfolgreich abgeschlossen ==="

