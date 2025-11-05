## Git-Commit

**WICHTIG**: Nach jeder Änderung automatisch in Git einchecken!

Am Ende jeder Agent-Ausführung:

```bash
AGENT_NAME="<agent-name>" \
COMMIT_MESSAGE="<agent-name>: $(date '+%Y-%m-%d %H:%M') - <kurzbeschreibung>" \
scripts/auto-git-commit.sh
```

**Das Script prüft automatisch**:
- ✅ Ob Secrets versehentlich committet würden (stoppt falls ja!)
- ✅ Ob Git-Repository vorhanden ist
- ✅ Ob Remote (GitHub/GitLab) konfiguriert ist
- ✅ Ob Push erfolgreich war

**Bei Problemen meldet das Script klar**:
- ❌ Was das Problem ist
- ❌ Warum es auftritt  
- ❌ Wie es behoben werden kann

**Falls Git-Commit nicht möglich ist**:
- Dokumentiere das Problem klar
- Erkläre warum (kein Repository, keine Berechtigung, etc.)
- Gib konkrete Lösungsschritte

Siehe: `.cursor/context/git-auto-commit-context.md` für Details.

