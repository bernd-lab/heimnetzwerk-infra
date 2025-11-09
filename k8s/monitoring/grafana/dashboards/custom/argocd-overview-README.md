# ArgoCD Overview Dashboard

## Beschreibung

Dieses Dashboard überwacht ArgoCD, die GitOps-Continuous-Delivery-Plattform für Kubernetes. ArgoCD automatisiert die Deployment-Synchronisation zwischen Git-Repositories und Kubernetes-Clustern.

## Überwachte Komponenten

- **ArgoCD Server**: Web-UI und API-Server
- **Application Controller**: Verwaltet Application-Synchronisation
- **Repo Server**: Git-Repository-Synchronisation
- **Dex Server**: Authentication-Server

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `argocd_app_info` | Application-Informationen mit Health- und Sync-Status | Info |
| `argocd_app_k8s_request_total` | Kubernetes API-Anfragen nach Component, Verb und Resource | Requests |

## Panels

1. **Total Applications**: Gesamtanzahl verwalteter Applications
2. **Healthy Applications**: Anzahl gesunder Applications
3. **Synced Applications**: Anzahl synchronisierter Applications
4. **Out of Sync Applications**: Anzahl nicht synchronisierter Applications
5. **Application Health Status**: Verteilung nach Health-Status (Pie Chart)
6. **Application Sync Status**: Verteilung nach Sync-Status (Pie Chart)
7. **Kubernetes Request Rate**: Rate der Kubernetes API-Anfragen nach Component
8. **Kubernetes Requests by Response Code**: Request-Rate nach HTTP-Response-Code

## Architektur

```
┌─────────────────────────────────────────────────────────┐
│              ArgoCD GitOps Platform                    │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │   ArgoCD     │  │  Application │                  │
│  │   Server     │  │  Controller  │                  │
│  └──────┬───────┘  └──────┬───────┘                  │
│         │                  │                           │
│         └────────┬─────────┘                           │
│                  │                                     │
│         ┌────────▼─────────┐                         │
│         │  Repo Server     │                         │
│         │  (Git Sync)      │                         │
│         └──────────────────┘                         │
│                  │                                     │
│         ┌────────▼─────────┐                         │
│         │  Kubernetes API  │                         │
│         │  (Deployments)   │                         │
│         └──────────────────┘                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## PromQL Queries

### Total Applications
```promql
count(argocd_app_info)
```

### Healthy Applications
```promql
count(argocd_app_info{health_status="Healthy"})
```

### Application Health Distribution
```promql
count by (health_status) (argocd_app_info)
```

### Kubernetes Request Rate
```promql
rate(argocd_app_k8s_request_total[5m])
```

## Troubleshooting

Falls keine Metriken angezeigt werden:

1. **Prüfen Sie ob ArgoCD installiert ist:**
   ```bash
   kubectl get pods -n argocd
   ```

2. **Prüfen Sie ServiceMonitors:**
   ```bash
   kubectl get servicemonitor -n monitoring | grep argocd
   ```

3. **Prüfen Sie Prometheus Targets:**
   ```bash
   curl -k https://prometheus.k8sops.online/api/v1/targets | jq '.data.activeTargets[] | select(.labels.job | contains("argocd"))'
   ```

4. **Prüfen Sie verfügbare Metriken:**
   ```bash
   curl -k https://prometheus.k8sops.online/api/v1/label/__name__/values | jq '.data[] | select(. | contains("argocd"))'
   ```

## Referenzen

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Metrics](https://argo-cd.readthedocs.io/en/stable/operator-manual/metrics/)

