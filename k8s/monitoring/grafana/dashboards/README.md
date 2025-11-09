# Grafana Dashboards

## Übersicht

Dieses Verzeichnis enthält alle Grafana-Dashboards für das Monitoring-Setup. Die Dashboards sind in zwei Kategorien unterteilt:

- **Standard Dashboards**: Allgemeine Monitoring-Dashboards für Prometheus, Alertmanager, Node Exporter und Kubernetes
- **Custom Dashboards**: Spezifische Dashboards für Infrastruktur-Komponenten wie ArgoCD, CoreDNS, NGINX Ingress, Cert-Manager und Velero

## Dashboard-Liste

### Standard Dashboards

1. **[Prometheus Stats](standard/prometheus-stats-README.md)**
   - Überwacht die Gesundheit und Performance des Prometheus-Servers
   - Metriken: TSDB, HTTP-Anfragen, Query-Performance, Memory, Goroutines

2. **[Alertmanager Overview](standard/alertmanager-README.md)**
   - Überwacht Alertmanager, den Alert-Routing-Service
   - Metriken: Status, Memory, Goroutines, Alerts, Notifications

3. **[Node Exporter Full](standard/node-exporter-README.md)**
   - Überwacht System-Metriken der Kubernetes-Nodes
   - Metriken: CPU, Memory, Disk I/O, Network Traffic, System Load

4. **[Kubernetes Cluster Monitoring](standard/kubernetes-cluster-README.md)**
   - Überwacht den Kubernetes-Cluster über kube-state-metrics
   - Metriken: Pod-Status, Node-Status, Deployment-Status, Resource-Usage

### Custom Dashboards

5. **[Infrastructure Overview](custom/infrastructure-overview-README.md)**
   - Überblick über die gesamte Infrastruktur
   - Metriken: Prometheus-Status, Time Series, HTTP-Anfragen, Memory

6. **[ArgoCD Overview](custom/argocd-overview-README.md)**
   - Überwacht ArgoCD, die GitOps-Continuous-Delivery-Plattform
   - Metriken: Application-Status, Sync-Status, Kubernetes-API-Anfragen

7. **[CoreDNS Overview](custom/coredns-overview-README.md)**
   - Überwacht CoreDNS, den DNS-Server für Kubernetes
   - Metriken: DNS-Anfragen, Cache-Performance, Request-Duration

8. **[NGINX Ingress Controller](custom/nginx-ingress-README.md)**
   - Überwacht den NGINX Ingress Controller
   - Metriken: Request-Rate, Response-Codes, Request-Duration, Connections

9. **[Cert-Manager](custom/cert-manager-README.md)**
   - Überwacht Cert-Manager, den TLS-Zertifikat-Manager
   - Metriken: Certificate-Status, Expiry, ACME-Challenges

10. **[Velero](custom/velero-README.md)**
    - Überwacht Velero, das Backup- und Disaster-Recovery-Tool
    - Metriken: Backup-Status, Restore-Status, Backup-Duration

## Dashboard-Provisioning

Die Dashboards werden automatisch über Grafana Dashboard Provisioning geladen. Die Konfiguration befindet sich in:

- `grafana/dashboard-provisioning.yaml` - Provisioning-Konfiguration
- `grafana/dashboards/standard/*.yaml` - Standard-Dashboards als ConfigMaps
- `grafana/dashboards/custom/*.yaml` - Custom-Dashboards als ConfigMaps

## Metriken-Verfügbarkeit

Nicht alle Dashboards zeigen sofort Daten an. Die Verfügbarkeit hängt ab von:

1. **ServiceMonitors**: Ob ServiceMonitors für die jeweiligen Services konfiguriert sind
2. **Prometheus Scraping**: Ob Prometheus die Services erfolgreich scraped
3. **Metriken-Export**: Ob die Services Metriken exportieren

### Verfügbare Metriken prüfen

```bash
# Alle verfügbaren Metriken auflisten
curl -k 'https://prometheus.k8sops.online/api/v1/label/__name__/values' | jq '.data[]'

# Spezifische Metrik prüfen
curl -k 'https://prometheus.k8sops.online/api/v1/query?query=up'
```

## Dashboard-Struktur

Jedes Dashboard besteht aus:

1. **Text-Panel**: Übersicht und Beschreibung der Metriken (oben)
2. **Stat-Panels**: Wichtige Metriken als einzelne Werte
3. **Time Series Panels**: Metriken über Zeit
4. **Pie Charts**: Verteilungen (falls anwendbar)

## Metriken-Übersicht

### Prometheus-Metriken
- `prometheus_*` - Prometheus-interne Metriken
- `go_*` - Go Runtime-Metriken

### Node-Metriken
- `node_*` - System-Metriken (CPU, Memory, Disk, Network)

### Kubernetes-Metriken
- `kube_*` - Kubernetes Resource-Metriken (von kube-state-metrics)

### Service-Metriken
- `coredns_*` - CoreDNS-Metriken
- `nginx_ingress_*` - NGINX Ingress-Metriken
- `cert_manager_*` - Cert-Manager-Metriken
- `velero_*` - Velero-Metriken
- `argocd_*` - ArgoCD-Metriken
- `alertmanager_*` - Alertmanager-Metriken

## Troubleshooting

### Dashboard zeigt keine Daten

1. **Prüfen Sie Prometheus Targets:**
   ```bash
   kubectl get servicemonitor -n monitoring
   curl -k https://prometheus.k8sops.online/api/v1/targets
   ```

2. **Prüfen Sie verfügbare Metriken:**
   ```bash
   curl -k 'https://prometheus.k8sops.online/api/v1/label/__name__/values' | jq '.data[] | select(. | contains("METRIC_NAME"))'
   ```

3. **Prüfen Sie Service-Status:**
   ```bash
   kubectl get pods -n <namespace> -l app=<service-name>
   ```

4. **Prüfen Sie ServiceMonitor-Konfiguration:**
   ```bash
   kubectl get servicemonitor <service-monitor-name> -n monitoring -o yaml
   ```

### Dashboard wird nicht angezeigt

1. **Prüfen Sie Grafana Pod-Logs:**
   ```bash
   kubectl logs -n monitoring -l app.kubernetes.io/name=grafana | grep -i dashboard
   ```

2. **Prüfen Sie ConfigMap-Mounts:**
   ```bash
   kubectl get deployment grafana -n monitoring -o yaml | grep -A 5 volumeMounts
   ```

3. **Prüfen Sie Dashboard Provisioning:**
   ```bash
   kubectl get configmap grafana-dashboard-provisioning -n monitoring -o yaml
   ```

## Weitere Informationen

Für detaillierte Informationen zu jedem Dashboard siehe die jeweiligen README-Dateien:

- [Prometheus Stats README](standard/prometheus-stats-README.md)
- [Alertmanager README](standard/alertmanager-README.md)
- [Node Exporter README](standard/node-exporter-README.md)
- [Kubernetes Cluster README](standard/kubernetes-cluster-README.md)
- [Infrastructure Overview README](custom/infrastructure-overview-README.md)
- [ArgoCD Overview README](custom/argocd-overview-README.md)
- [CoreDNS Overview README](custom/coredns-overview-README.md)
- [NGINX Ingress README](custom/nginx-ingress-README.md)
- [Cert-Manager README](custom/cert-manager-README.md)
- [Velero README](custom/velero-README.md)

## Referenzen

- [Grafana Dashboard Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)
- [Prometheus Metrics](https://prometheus.io/docs/instrumenting/exporters/)
- [Grafana Dashboard JSON Model](https://grafana.com/docs/grafana/latest/dashboards/json-model/)

