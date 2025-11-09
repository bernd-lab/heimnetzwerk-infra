# Claude Code Setup-Anleitung

**Erstellt**: 2025-11-09  
**Zweck**: Parallele Agent-Struktur für Claude Code neben Cursor.ai

---

## Übersicht

Dieses Projekt verwendet zwei parallele Agent-Strukturen:
- **Cursor.ai**: `.cursor/commands/` - Für Cursor.ai Agents
- **Claude Code**: `.claude/agents/` - Für Claude Code Agents

Beide Strukturen enthalten die gleichen Agent-Definitionen und sollten parallel aktualisiert werden.

---

## Installation

### 1. Claude Desktop installieren

Falls noch nicht installiert:
- Download: https://claude.ai/download
- Installation gemäß Anleitung

### 2. Workspace öffnen

```bash
# Repository öffnen
cd /home/bernd/infra-0511

# Claude Desktop öffnen (falls CLI verfügbar)
claude-desktop .
```

Oder in Claude Desktop:
- **File** → **Open Folder...**
- Verzeichnis `/home/bernd/infra-0511` auswählen

---

## Claude Desktop Konfiguration

### Custom Instructions

In Claude Desktop Settings → **Custom Instructions**:

```
Du arbeitest in einem Kubernetes Home-Infrastructure-Projekt mit ArgoCD als GitOps-Tool.

AGENT-SYSTEM:
- Agent-Definitionen befinden sich in .claude/agents/
- Verwende die entsprechenden Agent-Definitionen für spezialisierte Aufgaben
- Kombiniere mehrere Agenten für komplexe Tasks
- Lade Agent-Definitionen mit: "Lade .claude/agents/[agent-name].md"

VERFÜGBARE AGENTEN:
- monitoring-expert.md - Grafana, Prometheus, Logging
- k8s-expert.md - Kubernetes Cluster-Management
- gitops-expert.md - ArgoCD, CI/CD
- gitlab-github-expert.md - Repository-Management
- dns-expert.md - DNS-Konfiguration
- security-expert.md - Sicherheit, SSL/TLS
- infrastructure-expert.md - Gesamtübersicht
- secrets-expert.md - Secret-Management

WICHTIGE DOKUMENTE:
- HANDOVER-ARGOCD-MONITORING-2025-11-09.md - ArgoCD Monitoring Handover
- HANDOVER-NEU.md - Allgemeines Handover-Dokument
- ARGOCD-OUT-OF-SYNC-ANALYSE.md - Out-of-Sync Analyse
- THREAD-PROMPT-ARGOCD-MONITORING.md - Prompt für neue Threads

GIT-WORKFLOW:
- Nach jeder Änderung automatisch committen
- Verwende scripts/auto-git-commit.sh für sichere Commits
- Prüfe immer auf Secrets vor dem Commit
- Commits sollten klar beschreiben was geändert wurde

KONTEXT-AKTUALISIERUNG:
- Aktualisiere Agent-Definitionen nach wichtigen Änderungen
- Dokumentiere neue Erkenntnisse in den entsprechenden Agent-Dateien
- Synchronisiere .cursor/commands/ und .claude/agents/ parallel

SPRACHE:
- Antworte immer auf Deutsch
- Verwende technische Begriffe korrekt
- Erkläre komplexe Konzepte wenn nötig
```

### Workspace Settings

In Claude Desktop → **Workspace Settings**:

1. **Workspace Root**: `/home/bernd/infra-0511`
2. **Agent Directory**: `.claude/agents/`
3. **Context Files**: 
   - `HANDOVER-ARGOCD-MONITORING-2025-11-09.md`
   - `HANDOVER-NEU.md`
   - `ARGOCD-OUT-OF-SYNC-ANALYSE.md`
   - `MONITORING-LANDSCHAFT.md`

---

## Verwendung

### Einzelner Agent

**Monitoring-Experte aktivieren:**
```
Lade die Agent-Definition aus .claude/agents/monitoring-expert.md und arbeite als Monitoring-Experte.

Aufgabe: Analysiere den aktuellen Status der ArgoCD Monitoring-Application und behebe den "Degraded"-Status.
```

**Kubernetes-Experte aktivieren:**
```
Lade die Agent-Definition aus .claude/agents/k8s-expert.md und arbeite als Kubernetes-Experte.

Aufgabe: Prüfe die Kubernetes-Ressourcen im monitoring Namespace.
```

### Multi-Agent-Workflow

```
Ich habe ein Problem mit ArgoCD Monitoring. Bitte:

1. Lade .claude/agents/monitoring-expert.md und analysiere das Monitoring-Setup
2. Lade .claude/agents/gitops-expert.md und prüfe die ArgoCD-Konfiguration
3. Lade .claude/agents/k8s-expert.md und prüfe die Kubernetes-Ressourcen

Arbeite zusammen, um das Problem zu lösen:
- Monitoring-Experte: Prüfe Grafana/Prometheus Status
- GitOps-Experte: Prüfe ArgoCD Application Status
- K8s-Experte: Prüfe Pods, Deployments, Services
```

### Handover für neue Threads

```
Lade HANDOVER-ARGOCD-MONITORING-2025-11-09.md und arbeite dich in die Situation ein.

Dann lade .claude/agents/monitoring-expert.md und behebe den "Degraded"-Status der Monitoring-Application.

Wichtige Informationen:
- Alle Pods laufen korrekt
- Änderungen wurden committed (Commit: 0b9d64c)
- ArgoCD synchronisiert gerade die neue Revision
```

---

## Prompt-Vorlagen

### Standard-Prompt für Monitoring

```
Lade .claude/agents/monitoring-expert.md und arbeite als Monitoring-Experte.

Kontext:
- ArgoCD Application: monitoring (Namespace: argocd)
- Status: Degraded (sollte Healthy sein)
- Alle Pods laufen korrekt

Aufgabe:
1. Prüfe den aktuellen Status der Monitoring-Application
2. Identifiziere die Ursache für "Degraded"
3. Behebe das Problem
4. Verifiziere dass Status jetzt "Healthy" ist
```

### Standard-Prompt für ArgoCD

```
Lade .claude/agents/gitops-expert.md und arbeite als GitOps-Experte.

Kontext:
- ArgoCD Application: monitoring
- Sync Status: Unknown
- Health Status: Degraded

Aufgabe:
1. Prüfe ArgoCD Application Status
2. Prüfe ob neue Revision geladen wurde
3. Führe Hard Refresh durch falls nötig
4. Prüfe Health-Checks
```

### Standard-Prompt für Kubernetes

```
Lade .claude/agents/k8s-expert.md und arbeite als Kubernetes-Experte.

Kontext:
- Namespace: monitoring
- Pods: Alle laufen (1/1 Ready)

Aufgabe:
1. Prüfe Pod-Status
2. Prüfe Deployment-Status
3. Prüfe Service-Status
4. Prüfe ob alle Ressourcen korrekt sind
```

---

## Synchronisation

### Agent-Definitionen synchronisieren

Wenn Agent-Definitionen in `.cursor/commands/` aktualisiert werden:

```bash
# Synchronisiere alle Agenten
cd /home/bernd/infra-0511

# Monitoring-Experte
cp .cursor/commands/monitoring-expert.md .claude/agents/monitoring-expert.md

# K8s-Experte
cp .cursor/commands/k8s-expert.md .claude/agents/k8s-expert.md

# GitOps-Experte
cp .cursor/commands/gitops-expert.md .claude/agents/gitops-expert.md

# GitLab/GitHub-Experte
cp .cursor/commands/gitlab-github-expert.md .claude/agents/gitlab-github-expert.md

# Alle anderen Agenten
for agent in .cursor/commands/*.md; do
    cp "$agent" ".claude/agents/$(basename $agent)"
done
```

### Script für automatische Synchronisation

Erstelle `scripts/sync-claude-agents.sh`:

```bash
#!/bin/bash
# Synchronisiert Agent-Definitionen von Cursor zu Claude Code

cd "$(dirname "$0")/.."

echo "Synchronisiere Agent-Definitionen..."

for agent in .cursor/commands/*.md; do
    agent_name=$(basename "$agent")
    echo "  - $agent_name"
    cp "$agent" ".claude/agents/$agent_name"
done

echo "✅ Synchronisation abgeschlossen"
```

---

## Unterschiede zu Cursor.ai

| Feature | Cursor.ai | Claude Code |
|---------|-----------|-------------|
| **Agent-Definitionen** | `.cursor/commands/*.md` | `.claude/agents/*.md` |
| **Aufruf** | `/monitoring-expert` | Prompt: "Lade .claude/agents/monitoring-expert.md" |
| **Konfiguration** | `.cursor/worktrees.json` | `.claude/claude_desktop_config.json` |
| **Context** | `.cursor/context/` | `.claude/context/` (optional) |
| **Ignore** | `.cursorignore` | `.claude/claudeignore` |

---

## Troubleshooting

### Agent wird nicht geladen

**Problem**: Claude findet Agent-Definition nicht

**Lösung**:
```bash
# Prüfe ob Datei existiert
ls -la .claude/agents/monitoring-expert.md

# Prüfe Datei-Inhalt
head -20 .claude/agents/monitoring-expert.md

# Prüfe Workspace Root in Claude Desktop Settings
```

### Custom Instructions werden nicht befolgt

**Problem**: Claude ignoriert Custom Instructions

**Lösung**:
1. Prüfe Custom Instructions in Claude Desktop Settings
2. Stelle sicher dass Workspace Root korrekt ist
3. Starte Claude Desktop neu

### Agent-Definitionen sind veraltet

**Problem**: `.claude/agents/` ist nicht synchron mit `.cursor/commands/`

**Lösung**:
```bash
# Manuelle Synchronisation
cp .cursor/commands/monitoring-expert.md .claude/agents/monitoring-expert.md

# Oder alle synchronisieren
scripts/sync-claude-agents.sh
```

---

## Best Practices

1. **Parallele Aktualisierung**: Beide Strukturen (.cursor und .claude) sollten parallel aktualisiert werden
2. **Handover-Dokumente**: Für Thread-Wechsel immer Handover-Dokumente verwenden
3. **Multi-Agent-Workflows**: Kombiniere mehrere Agenten für komplexe Tasks
4. **Git-Commit**: Nach jeder Änderung automatisch committen
5. **Dokumentation**: Aktualisiere Agent-Definitionen nach wichtigen Änderungen

---

## Nächste Schritte

1. ✅ Claude Desktop installieren
2. ✅ Workspace öffnen
3. ✅ Custom Instructions konfigurieren
4. ✅ Erste Agenten testen
5. ✅ Synchronisations-Script erstellen (optional)

---

**Ende der Setup-Anleitung**

