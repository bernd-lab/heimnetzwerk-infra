# Claude Code Einstellungen - Zusammenfassung

## 🎯 Custom Instructions für Claude Desktop

Kopiere diese Custom Instructions in Claude Desktop → Settings → Custom Instructions:

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
- CLAUDE-CODE-PROMPTS.md - Wiederverwendbare Prompts

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

## 📁 Workspace Settings

In Claude Desktop → Workspace Settings:

1. **Workspace Root**: `/home/bernd/infra-0511`
2. **Agent Directory**: `.claude/agents/`
3. **Context Files**: 
   - `HANDOVER-ARGOCD-MONITORING-2025-11-09.md`
   - `HANDOVER-NEU.md`
   - `ARGOCD-OUT-OF-SYNC-ANALYSE.md`
   - `MONITORING-LANDSCHAFT.md`

## 🚀 Schnellstart-Prompt

Für neue Sessions oder Threads:

```
Lade HANDOVER-ARGOCD-MONITORING-2025-11-09.md und arbeite dich in die Situation ein.

Dann lade .claude/agents/monitoring-expert.md und behebe den "Degraded"-Status der Monitoring-Application.

Siehe CLAUDE-CODE-PROMPTS.md für weitere Prompts.
```

## 🔄 Synchronisation

Agent-Definitionen synchronisieren:

```bash
./scripts/sync-claude-agents.sh
```

Oder manuell:

```bash
cp .cursor/commands/monitoring-expert.md .claude/agents/monitoring-expert.md
```

## 📚 Weitere Informationen

- **CLAUDE-CODE-SETUP.md** - Vollständige Setup-Anleitung
- **CLAUDE-CODE-PROMPTS.md** - Wiederverwendbare Prompts
- **.claude/README.md** - Agent-Struktur Dokumentation
