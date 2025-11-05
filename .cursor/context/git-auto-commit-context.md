# Git Auto-Commit Context für Agenten

## Übersicht

Alle Agenten sollten nach ihrer Arbeit automatisch alle Änderungen in Git einchecken. Falls das nicht möglich ist, muss das Problem klar identifiziert und gemeldet werden.

## Automatischer Git-Commit

### Script: `scripts/auto-git-commit.sh`

Das Script führt automatisch aus:
1. Prüft Git-Repository-Status
2. Identifiziert uncommittete Änderungen
3. Prüft ob Secrets versehentlich committet würden
4. Erstellt Commit mit automatischer Nachricht
5. Versucht zu pushen (GitHub/GitLab)
6. Meldet Probleme klar und spezifisch

### Verwendung in Agenten

```bash
# Am Ende jeder Agent-Ausführung:
source scripts/auto-git-commit.sh
```

Oder mit Custom-Message:
```bash
AGENT_NAME="dns-expert" \
COMMIT_MESSAGE="DNS-Konfiguration aktualisiert" \
scripts/auto-git-commit.sh
```

## Git-Commit-Strategie

### Dateien die committet werden sollen:
- ✅ `.cursor/commands/` - Alle Agenten und Commands
- ✅ `.cursor/context/` - Shared Context
- ✅ `.cursor/worktrees.json` - Worktree-Konfiguration
- ✅ `scripts/` - Alle Scripts
- ✅ `secrets/secrets.metadata.yaml` - Secret-Metadaten (OHNE Werte!)
- ✅ `secrets/secrets-template.yaml` - Templates
- ✅ Dokumentation (`.md` Dateien)
- ✅ `.gitignore` - Git-Ignore-Konfiguration

### Dateien die NICHT committet werden sollen:
- ❌ `~/.cursor/secrets/` - Verschlüsselte Secrets
- ❌ `secrets/*.age` - Verschlüsselte Secret-Dateien
- ❌ `*.key`, `*.pem` - Private Keys
- ❌ `secrets-inventory.yaml` - Falls Secrets enthalten

## Commit-Nachrichten

### Format
```
<Agent-Name>: <Kurzbeschreibung>

<Detaillierte Beschreibung>
```

### Beispiele
```
dns-expert: DNS-Konfiguration aktualisiert

- Pi-hole DNS-Einstellungen dokumentiert
- Cloudflare API Token-Metadaten aktualisiert
- DNS-Flow Diagramm erstellt
```

```
k8s-expert: GitLab Pod-Status analysiert

- GitLab Pod läuft stabil (1/1 Ready)
- Health-Check: 200 OK
- Restarts: 3 (letzter vor 5m42s)
```

## Fehlerbehandlung

### Problem: Kein Git-Repository
**Meldung:**
```
❌ Kein Git-Repository gefunden
   Problem: .git Verzeichnis existiert nicht
   Lösung: 'git init' ausführen oder in existierendes Repository wechseln
```

### Problem: Secrets würden committet
**Meldung:**
```
❌ VERSCHLÜSSELTE SECRETS WÜRDEN COMMITTET WERDEN!
   Problem: Secrets-Dateien (.age, .key, .pem) sind in den Änderungen
   Lösung: .gitignore aktualisieren oder Secrets aus Staging entfernen
```

### Problem: Push fehlgeschlagen
**Meldung:**
```
⚠️  Push fehlgeschlagen
   Remote: GitHub (https://github.com/bernd-lab/heimnetzwerk-infra)
   Mögliche Ursachen:
   - Keine Berechtigung zum Pushen
   - Remote-Repository nicht erreichbar
   - Authentifizierung fehlgeschlagen (Token/SSH-Key)
   - Branch ist geschützt
```

## Integration in Agenten

### Standard-Integration
Jeder Agent sollte am Ende seiner Ausführung:

```bash
# Am Ende der Agent-Ausführung
AGENT_NAME="agent-name" \
COMMIT_MESSAGE="Agent-Name: Kurzbeschreibung der Änderungen" \
scripts/auto-git-commit.sh
```

### Beispiel: DNS-Expert
```bash
# Am Ende von .cursor/commands/dns-expert.md
## Git-Commit
Nach jeder Änderung:
```bash
AGENT_NAME="dns-expert" \
COMMIT_MESSAGE="dns-expert: $(date '+%Y-%m-%d %H:%M') - DNS-Konfiguration aktualisiert" \
scripts/auto-git-commit.sh
```

## Wichtige Hinweise

1. **Secrets schützen**: Script prüft automatisch ob Secrets committet würden
2. **Klare Fehlermeldungen**: Jedes Problem wird klar identifiziert
3. **Automatische Commit-Nachrichten**: Falls keine angegeben, wird automatische erstellt
4. **Push-Versuche**: Script versucht automatisch zu pushen, meldet aber Fehler klar
5. **Lokale Commits**: Auch wenn Push fehlschlägt, wird lokal committed

## Troubleshooting

### Problem: "Keine Berechtigung zum Pushen"
- Prüfe GitHub/GitLab Token
- Prüfe SSH-Keys
- Prüfe Branch-Protection-Regeln

### Problem: "Secrets würden committet"
- Prüfe `.gitignore`
- Prüfe ob Secrets in `secrets/` Verzeichnis sind
- Entferne Secrets aus Staging: `git reset HEAD <file>`

### Problem: "Git-Identität nicht konfiguriert"
- Setze: `git config user.name "Name"`
- Setze: `git config user.email "email"`

