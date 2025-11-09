# Prompt für neuen Thread: ArgoCD Monitoring Degraded Status

## Kontext

Ich arbeite an einem Kubernetes Home-Infrastructure-Projekt mit ArgoCD als GitOps-Tool. Die Monitoring-Application zeigt aktuell den Status "Degraded" an, obwohl alle Pods laufen und funktionieren.

## Aufgabe

Bitte analysiere den aktuellen Status der ArgoCD Monitoring-Application und behebe den "Degraded"-Status. Die Application sollte "Synced" und "Healthy" sein.

## Wichtige Informationen

### Handover-Dokumente
- **`HANDOVER-ARGOCD-MONITORING-2025-11-09.md`** - Vollständiges Handover mit allen Details
- **`ARGOCD-OUT-OF-SYNC-ANALYSE.md`** - Analyse der Out-of-Sync-Applications
- **`MONITORING-LANDSCHAFT.md`** - Monitoring-Landschaft Übersicht

### Aktueller Status
- **ArgoCD Application**: `monitoring` im Namespace `argocd`
- **Sync Status**: `Unknown` (sollte zu `Synced` wechseln)
- **Health Status**: `Degraded` (sollte zu `Healthy` wechseln)
- **Revision**: Keine (ArgoCD hat neue Revision noch nicht geladen)

### Durchgeführte Maßnahmen
1. ✅ Kustomization-Fehler behoben (alle Ressourcen direkt referenziert)
2. ✅ Grafana und Prometheus Deployments/Services hinzugefügt
3. ✅ Alte Pods bereinigt
4. ✅ Änderungen committed und gepusht (Commit: `0b9d64c`)

### Wichtige Dateien
- `k8s/monitoring/kustomization.yaml` - Haupt-Kustomization (aktualisiert)
- `k8s/monitoring/grafana/deployment.yaml` - Neu erstellt
- `k8s/monitoring/grafana/service.yaml` - Neu erstellt
- `k8s/monitoring/prometheus/deployment.yaml` - Neu erstellt
- `k8s/monitoring/prometheus/service.yaml` - Neu erstellt

### Pod-Status
Alle Pods laufen korrekt:
- `alertmanager-657867fbd6-s7xkx`: Running (1/1)
- `grafana-86bd9dd8f4-stjcc`: Running (1/1)
- `kube-state-metrics-64ccc748f6-stm46`: Running (1/1)
- `node-exporter-8c6nf`: Running (1/1)
- `prometheus-76f94b4799-dgf74`: Running (1/1)

## Erwartete Schritte

1. **Status prüfen**: Aktuellen ArgoCD Application-Status abfragen
2. **Revision prüfen**: Ob ArgoCD die neue Revision (`0b9d64c`) geladen hat
3. **Sync durchführen**: Falls nötig, Hard Refresh oder Application-Neuerstellung
4. **Health-Checks prüfen**: Warum zeigt ArgoCD "Degraded"?
5. **Problem beheben**: Falls weiterhin Probleme bestehen, diese identifizieren und beheben
6. **Verifikation**: Finalen Status prüfen und bestätigen

## Wichtige Commands

```bash
# Application-Status prüfen
kubectl get application monitoring -n argocd -o wide

# Health- und Sync-Status
kubectl get application monitoring -n argocd -o jsonpath='{.status.health.status}'
kubectl get application monitoring -n argocd -o jsonpath='{.status.sync.status}'

# Revision prüfen
kubectl get application monitoring -n argocd -o jsonpath='{.status.sync.comparedTo.source.revision}'

# Hard Refresh
kubectl patch application monitoring -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Sync durchführen
kubectl patch application monitoring -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"main"}}}'

# Pods prüfen
kubectl get pods -n monitoring
```

## Erwartetes Ergebnis

Die Monitoring-Application sollte:
- ✅ **Sync Status**: `Synced`
- ✅ **Health Status**: `Healthy`
- ✅ **Revision**: `0b9d64c` (oder neuer)
- ✅ Alle Deployments erkannt (Grafana, Prometheus, Alertmanager, Kube-State-Metrics)

## Weitere Informationen

- **Repository**: https://github.com/bernd-lab/heimnetzwerk-infra.git
- **Branch**: `main`
- **Path**: `k8s/monitoring/`
- **Agent-Dokumente**: `.cursor/commands/monitoring-expert.md`, `.cursor/commands/k8s-expert.md`, `.cursor/commands/gitops-expert.md`

Bitte arbeite dich mit Hilfe der Handover-Dokumente in die Situation ein und behebe den "Degraded"-Status der Monitoring-Application.

