# Claude Code Prompts - Schnellreferenz

**Erstellt**: 2025-11-09  
**Zweck**: Wiederverwendbare Prompts für Claude Code

---

## 🎯 Standard-Prompts

### Monitoring-Experte aktivieren

```
Lade die Agent-Definition aus .claude/agents/monitoring-expert.md und arbeite als Monitoring-Experte.

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

### Kubernetes-Experte aktivieren

```
Lade die Agent-Definition aus .claude/agents/k8s-expert.md und arbeite als Kubernetes-Experte.

Kontext:
- Namespace: monitoring
- Pods: Alle laufen (1/1 Ready)

Aufgabe:
1. Prüfe Pod-Status
2. Prüfe Deployment-Status
3. Prüfe Service-Status
4. Prüfe ob alle Ressourcen korrekt sind
```

### GitOps-Experte aktivieren

```
Lade die Agent-Definition aus .claude/agents/gitops-expert.md und arbeite als GitOps-Experte.

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

---

## 🔄 Handover-Prompts

### Neuer Thread mit Handover

```
Lade HANDOVER-ARGOCD-MONITORING-2025-11-09.md und arbeite dich in die Situation ein.

Dann lade .claude/agents/monitoring-expert.md und behebe den "Degraded"-Status der Monitoring-Application.

Wichtige Informationen:
- Alle Pods laufen korrekt
- Änderungen wurden committed (Commit: 0b9d64c)
- ArgoCD synchronisiert gerade die neue Revision
```

### Allgemeiner Handover

```
Lade HANDOVER-NEU.md für den allgemeinen Kontext des Projekts.

Dann lade die entsprechenden Agent-Definitionen aus .claude/agents/ für deine Aufgabe.
```

---

## 🛠️ Troubleshooting-Prompts

### ArgoCD Application Status prüfen

```
Lade .claude/agents/gitops-expert.md und prüfe den Status der ArgoCD Application "monitoring".

Führe folgende Checks durch:
1. kubectl get application monitoring -n argocd -o wide
2. Prüfe Sync Status
3. Prüfe Health Status
4. Prüfe Revision
5. Prüfe ob alle Resources erkannt werden
```

### Monitoring Pods prüfen

```
Lade .claude/agents/monitoring-expert.md und prüfe alle Monitoring-Pods.

Führe folgende Checks durch:
1. kubectl get pods -n monitoring
2. Prüfe Pod-Status (Ready, Running, etc.)
3. Prüfe Pod-Logs falls Probleme
4. Prüfe Deployment-Status
```

### Kustomization prüfen

```
Lade .claude/agents/k8s-expert.md und prüfe die Kustomization-Struktur.

Führe folgende Checks durch:
1. Prüfe k8s/monitoring/kustomization.yaml
2. Prüfe ob alle Ressourcen korrekt referenziert sind
3. Teste Kustomization lokal: kustomize build k8s/monitoring/
4. Prüfe auf Fehler
```

---

## 📋 Task-spezifische Prompts

### ArgoCD Monitoring "Degraded" beheben

```
Lade HANDOVER-ARGOCD-MONITORING-2025-11-09.md für den vollständigen Kontext.

Dann lade .claude/agents/monitoring-expert.md und .claude/agents/gitops-expert.md.

Aufgabe: Behebe den "Degraded"-Status der Monitoring-Application.

Schritte:
1. Prüfe aktuellen Status (Sync, Health, Revision)
2. Prüfe ob alle Deployments erkannt werden
3. Prüfe Health-Checks
4. Führe Hard Refresh durch falls nötig
5. Verifiziere dass Status jetzt "Healthy" ist
```

### Out-of-Sync Applications analysieren

```
Lade ARGOCD-OUT-OF-SYNC-ANALYSE.md für die Analyse.

Dann lade .claude/agents/gitops-expert.md.

Aufgabe: Analysiere warum einige Applications "Out of Sync" sind.

Schritte:
1. Prüfe alle Applications: kubectl get applications -A -o wide
2. Identifiziere Out-of-Sync Applications
3. Prüfe Unterschiede zwischen Git und Cluster
4. Entscheide ob Sync notwendig ist oder ignoriert werden kann
```

### Neue Dashboards erstellen

```
Lade .claude/agents/monitoring-expert.md und erstelle neue Grafana-Dashboards.

Aufgabe: Erstelle Dashboard für [SERVICE_NAME]

Schritte:
1. Prüfe verfügbare Metriken für [SERVICE_NAME]
2. Erstelle Dashboard-ConfigMap in k8s/monitoring/grafana/dashboards/custom/
3. Füge Dashboard zur kustomization.yaml hinzu
4. Füge Volume-Mount zur Grafana Deployment hinzu
5. Teste Dashboard in Grafana
```

---

## 🔧 Wartungs-Prompts

### Agent-Definitionen synchronisieren

```
Führe das Synchronisations-Script aus:

```bash
./scripts/sync-claude-agents.sh
```

Dies synchronisiert alle Agent-Definitionen von .cursor/commands/ zu .claude/agents/.
```

### Git-Commit nach Änderungen

```
Nach jeder Änderung automatisch committen:

```bash
AGENT_NAME="monitoring-expert" \
COMMIT_MESSAGE="monitoring-expert: $(date '+%Y-%m-%d %H:%M') - [Beschreibung]" \
scripts/auto-git-commit.sh
```
```

---

## 📚 Verfügbare Agenten

- **monitoring-expert.md** - Grafana, Prometheus, Logging
- **k8s-expert.md** - Kubernetes Cluster-Management
- **gitops-expert.md** - ArgoCD, CI/CD
- **gitlab-github-expert.md** - Repository-Management
- **dns-expert.md** - DNS-Konfiguration
- **security-expert.md** - Sicherheit, SSL/TLS
- **infrastructure-expert.md** - Gesamtübersicht
- **secrets-expert.md** - Secret-Management

---

## 💡 Best Practices

1. **Immer Agent-Definitionen laden**: Beginne mit "Lade .claude/agents/[agent].md"
2. **Handover-Dokumente nutzen**: Für Thread-Wechsel immer Handover-Dokumente verwenden
3. **Multi-Agent-Workflows**: Kombiniere mehrere Agenten für komplexe Tasks
4. **Klare Aufgaben**: Formuliere klare, spezifische Aufgaben
5. **Verifikation**: Prüfe immer das Ergebnis nach der Aufgabe

---

**Ende der Prompt-Referenz**

