# Monitoring-Landschaft Übersicht

## Zusammenfassung

**Status**: Prometheus scraped aktuell nur sich selbst. Die anderen Targets (Node Exporter, kube-state-metrics, CoreDNS, etc.) werden nicht gefunden, obwohl die Konfiguration vorhanden ist.

## 1. Prometheus Status

- **API**: Erreichbar unter `https://prometheus.k8sops.online`
- **Aktive Targets**: 1 (nur Prometheus selbst)
- **Gesamt Metriken**: 742 Metriken bekannt
- **Verfügbare Samples**: Nur Prometheus-interne Metriken

## 2. Verfügbare Metriken-Gruppen

| Gruppe | Anzahl Metriken | Verfügbare Samples | Status |
|--------|----------------|-------------------|--------|
| `prometheus_*` | 188 | ✓ Ja | Funktioniert |
| `go_*` | 32 | ✓ Ja | Funktioniert |
| `process_*` | 9 | ✓ Ja | Funktioniert |
| `node_*` | 296 | ✗ Nein | Targets nicht gefunden |
| `kube_*` | 159 | ✗ Nein | Targets nicht gefunden |
| `coredns_*` | 44 | ✗ Nein | Targets nicht gefunden |
| `alertmanager_*` | 0 | ✗ Nein | Targets nicht gefunden |
| `argocd_*` | 0 | ✗ Nein | Targets nicht gefunden |
| `cert_manager_*` | 0 | ✗ Nein | Targets nicht gefunden |
| `velero_*` | 0 | ✗ Nein | Targets nicht gefunden |
| `nginx_*` | 0 | ✗ Nein | Targets nicht gefunden |

## 3. Kubernetes Services mit Metrics-Endpoints

| Namespace | Service | Port | Status |
|-----------|---------|------|--------|
| `monitoring` | `node-exporter` | 9100 | Pod läuft, Endpoint vorhanden |
| `monitoring` | `kube-state-metrics` | 8080 | Pod läuft, Endpoint vorhanden |
| `kube-system` | `kube-dns` | 9153 | Pod läuft, Endpoint vorhanden |
| `argocd` | `argocd-dex-server` | 5558 | Pod läuft, Endpoint vorhanden |

## 4. ServiceMonitors

**Gesamt**: 12 ServiceMonitors konfiguriert

| Namespace | ServiceMonitor | Target Service | Status |
|-----------|---------------|----------------|--------|
| `monitoring` | `node-exporter` | `node-exporter` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `kube-state-metrics` | `kube-state-metrics` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `coredns` | `kube-dns` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `alertmanager` | `alertmanager` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `argocd` | `argocd-server` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `cert-manager` | `cert-manager` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `nginx-ingress` | `ingress-nginx-controller` | Konfiguriert, aber nicht verwendet |
| `monitoring` | `velero` | `velero` | Konfiguriert, aber nicht verwendet |

**Hinweis**: Prometheus verwendet keine ServiceMonitors (kein Prometheus Operator). Die Scrape-Konfiguration erfolgt direkt über `prometheus.yml`.

## 5. Prometheus Scrape-Konfiguration

**Konfigurierte Jobs**:
1. `prometheus` - ✓ Funktioniert
2. `kubernetes-apiservers` - ✗ Keine Targets gefunden
3. `kubernetes-nodes` - ✗ Keine Targets gefunden
4. `kubernetes-pods` - ✗ Keine Targets gefunden
5. `kubernetes-services` - ✗ Keine Targets gefunden
6. `node-exporter` - ✗ Keine Targets gefunden
7. `kube-state-metrics` - ✗ Keine Targets gefunden
8. `coredns` - ✗ Keine Targets gefunden
9. `kubelet` - ✗ Keine Targets gefunden
10. `cert-manager` - ✗ Keine Targets gefunden
11. `nginx-ingress` - ✗ Keine Targets gefunden
12. `argocd` - ✗ Keine Targets gefunden
13. `velero` - ✗ Keine Targets gefunden
14. `alertmanager` - ✗ Keine Targets gefunden

## 6. Pods Status

| Namespace | Pod | Status | IP |
|-----------|-----|--------|-----|
| `monitoring` | `prometheus-*` | Running | 10.244.0.242 |
| `monitoring` | `grafana-*` | Running | 10.244.0.254 |
| `monitoring` | `alertmanager-*` | Running | 10.244.0.253 |
| `monitoring` | `node-exporter-*` | Running | 192.168.178.54 |
| `monitoring` | `kube-state-metrics-*` | Running | 10.244.0.231 |

## 7. Problem-Analyse

**Hauptproblem**: Prometheus findet die Targets nicht, obwohl:
- ✅ Die Pods laufen
- ✅ Die Endpoints existieren
- ✅ Die Scrape-Konfiguration vorhanden ist
- ✅ Die ServiceMonitors konfiguriert sind

**Mögliche Ursachen**:
1. Prometheus hat keine RBAC-Berechtigungen für `kubernetes_sd_configs`
2. Die `relabel_configs` sind zu restriktiv
3. Prometheus hat die Config nicht neu geladen
4. Die Endpoint-Namen stimmen nicht mit den Regex-Patterns überein

## 8. Dashboard-Status

| Dashboard | Verfügbare Metriken | Status | Maßnahmen |
|-----------|-------------------|--------|-----------|
| Prometheus Stats | ✓ `prometheus_*`, `go_*`, `process_*` | ✅ Funktioniert | - |
| Infrastructure Overview | ✓ `prometheus_*`, `go_*`, `process_*` | ✅ Funktioniert | - |
| Node Exporter | ✗ `node_*` | ⚠️ Warnung + Ersatz | Warnung hinzugefügt, Ersatz-Metriken (Prometheus Memory) |
| Kubernetes Cluster | ✗ `kube_*` | ⚠️ Warnung + Ersatz | Warnung hinzugefügt, Ersatz-Metriken (Prometheus Time Series) |
| CoreDNS Overview | ✗ `coredns_*` | ⚠️ Warnung | Warnung hinzugefügt |
| Alertmanager | ✗ `alertmanager_*` | ⚠️ Warnung | Warnung hinzugefügt |
| ArgoCD Overview | ✗ `argocd_*` | ⚠️ Warnung | Warnung hinzugefügt |
| Cert-Manager | ✗ `cert_manager_*` | ⚠️ Warnung | Warnung hinzugefügt |
| NGINX Ingress | ✗ `nginx_*` | ⚠️ Warnung | Warnung hinzugefügt |
| Velero | ✗ `velero_*` | ⚠️ Warnung | Warnung hinzugefügt |

## 9. Nächste Schritte

1. **Prometheus RBAC erstellen**: ServiceAccount mit ClusterRole für Kubernetes API-Zugriff
2. **Prometheus Deployment anpassen**: ServiceAccount zuweisen
3. **Targets prüfen**: Nach RBAC-Fix sollten Targets automatisch gefunden werden
4. **Dashboards aktualisiert**: ✅ Alle Dashboards haben jetzt Warnungen und Ersatz-Metriken wo möglich

## 10. Verfügbare Metriken für Dashboards

**Aktuell funktionierende Metriken**:
- `prometheus_http_requests_total` - 53 Samples
- `prometheus_tsdb_head_series` - 1 Sample
- `go_goroutines` - 1 Sample
- `process_resident_memory_bytes` - 1 Sample

**Nicht verfügbare Metriken** (aber in Prometheus bekannt):
- `node_cpu_seconds_total` - 0 Samples
- `kube_node_info` - 0 Samples
- `coredns_dns_requests_total` - 0 Samples
- `alertmanager_build_info` - 0 Samples
- `argocd_app_info` - 0 Samples

