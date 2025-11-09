# Claude Code Agent-Konfiguration

Dieses Verzeichnis enthält die Konfiguration für Claude Code Agents, parallel zur Cursor.ai Agent-Struktur.

## Struktur

```
.claude/
├── agents/              # Agent-Definitionen (parallel zu .cursor/commands/)
│   ├── monitoring-expert.md
│   ├── k8s-expert.md
│   ├── gitops-expert.md
│   └── ...
├── claude_desktop_config.json  # Claude Desktop Konfiguration
├── claudeignore         # Dateien die Claude ignorieren soll
└── README.md           # Diese Datei
```

## Verwendung in Claude Code

### 1. Agent-Definitionen laden

Claude Code kann Agent-Definitionen aus `.claude/agents/` laden. Verwende diese Prompts:

**Monitoring-Experte aktivieren:**
```
Lade die Agent-Definition aus .claude/agents/monitoring-expert.md und arbeite als Monitoring-Experte.
```

**Kubernetes-Experte aktivieren:**
```
Lade die Agent-Definition aus .claude/agents/k8s-expert.md und arbeite als Kubernetes-Experte.
```

**GitOps-Experte aktivieren:**
```
Lade die Agent-Definition aus .claude/agents/gitops-expert.md und arbeite als GitOps-Experte.
```

### 2. Multi-Agent-Workflow

Für komplexe Tasks mehrere Agenten kombinieren:

```
Ich habe ein Problem mit ArgoCD Monitoring. Bitte:
1. Lade .claude/agents/monitoring-expert.md und analysiere das Monitoring-Setup
2. Lade .claude/agents/gitops-expert.md und prüfe die ArgoCD-Konfiguration
3. Lade .claude/agents/k8s-expert.md und prüfe die Kubernetes-Ressourcen
4. Arbeite zusammen, um das Problem zu lösen
```

### 3. Handover-Dokumente verwenden

Für Thread-Wechsel oder neue Sessions:

```
Lade HANDOVER-ARGOCD-MONITORING-2025-11-09.md und arbeite dich in die Situation ein.
Dann lade .claude/agents/monitoring-expert.md und behebe den "Degraded"-Status.
```

## Claude Desktop Einstellungen

### Custom Instructions

Füge diese Custom Instructions in Claude Desktop hinzu:

```
Du arbeitest in einem Kubernetes Home-Infrastructure-Projekt. 

Agent-System:
- Agent-Definitionen befinden sich in .claude/agents/
- Verwende die entsprechenden Agent-Definitionen für spezialisierte Aufgaben
- Kombiniere mehrere Agenten für komplexe Tasks

Wichtige Dokumente:
- HANDOVER-ARGOCD-MONITORING-2025-11-09.md - ArgoCD Monitoring Handover
- HANDOVER-NEU.md - Allgemeines Handover-Dokument
- ARGOCD-OUT-OF-SYNC-ANALYSE.md - Out-of-Sync Analyse

Git-Workflow:
- Nach jeder Änderung automatisch committen
- Verwende scripts/auto-git-commit.sh für sichere Commits
- Prüfe immer auf Secrets vor dem Commit

Kontext-Aktualisierung:
- Aktualisiere Agent-Definitionen nach wichtigen Änderungen
- Dokumentiere neue Erkenntnisse in den entsprechenden Agent-Dateien
```

### Workspace Settings

In Claude Desktop Workspace Settings:

1. **Workspace Root**: `/home/bernd/infra-0511`
2. **Agent Directory**: `.claude/agents/`
3. **Context Files**: 
   - `HANDOVER-ARGOCD-MONITORING-2025-11-09.md`
   - `HANDOVER-NEU.md`
   - `ARGOCD-OUT-OF-SYNC-ANALYSE.md`

## Unterschiede zu Cursor.ai

| Feature | Cursor.ai | Claude Code |
|---------|-----------|-------------|
| Agent-Definitionen | `.cursor/commands/*.md` | `.claude/agents/*.md` |
| Aufruf | `/monitoring-expert` | Prompt: "Lade .claude/agents/monitoring-expert.md" |
| Konfiguration | `.cursor/worktrees.json` | `.claude/claude_desktop_config.json` |
| Context | `.cursor/context/` | `.claude/context/` (optional) |

## Verfügbare Agenten

- **monitoring-expert.md** - Grafana, Prometheus, Logging
- **k8s-expert.md** - Kubernetes Cluster-Management
- **gitops-expert.md** - ArgoCD, CI/CD
- **gitlab-github-expert.md** - Repository-Management
- **dns-expert.md** - DNS-Konfiguration
- **security-expert.md** - Sicherheit, SSL/TLS
- **infrastructure-expert.md** - Gesamtübersicht
- **secrets-expert.md** - Secret-Management

## Best Practices

1. **Agent-Definitionen synchron halten**: Beide Strukturen (.cursor und .claude) sollten parallel aktualisiert werden
2. **Handover-Dokumente nutzen**: Für Thread-Wechsel immer Handover-Dokumente verwenden
3. **Multi-Agent-Workflows**: Kombiniere mehrere Agenten für komplexe Tasks
4. **Git-Commit**: Nach jeder Änderung automatisch committen

## Troubleshooting

### Agent wird nicht geladen

```bash
# Prüfe ob Datei existiert
ls -la .claude/agents/monitoring-expert.md

# Prüfe Datei-Inhalt
head -20 .claude/agents/monitoring-expert.md
```

### Claude Desktop findet Agenten nicht

1. Prüfe Workspace Root in Claude Desktop Settings
2. Prüfe ob `.claude/` Verzeichnis im Workspace Root ist
3. Prüfe Custom Instructions in Claude Desktop

### Agent-Definitionen sind veraltet

```bash
# Synchronisiere von .cursor/commands/ zu .claude/agents/
cp .cursor/commands/monitoring-expert.md .claude/agents/monitoring-expert.md
```

