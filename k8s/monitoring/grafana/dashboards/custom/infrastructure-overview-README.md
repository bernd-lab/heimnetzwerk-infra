# Infrastructure Overview Dashboard

## Beschreibung

Dieses Dashboard bietet einen Überblick über die gesamte Infrastruktur, insbesondere den Prometheus Monitoring-Stack. Es zeigt die wichtigsten Metriken zur Gesundheit und Performance des Monitoring-Systems.

## Überwachte Komponenten

- **Prometheus**: Metriken-Sammlung und -Speicherung
- **Grafana**: Dashboard-Visualisierung
- **Alertmanager**: Alert-Verarbeitung
- **Node Exporter**: Node-Metriken
- **Kube-State-Metrics**: Kubernetes Resource-Metriken

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `up{job="prometheus"}` | Prometheus Server Status (1=Up, 0=Down) | Boolean |
| `prometheus_tsdb_head_series` | Anzahl Time Series in TSDB | Count |
| `prometheus_config_last_reload_successful` | Config Reload Status (1=Success, 0=Failed) | Boolean |
| `prometheus_http_requests_total` | HTTP Requests nach Handler und Status-Code | Requests |
| `process_resident_memory_bytes` | Resident Memory des Prometheus-Prozesses | Bytes |
| `go_memstats_heap_alloc_bytes` | Go Heap Memory allokiert | Bytes |
| `go_memstats_heap_sys_bytes` | Go Heap Memory vom System angefordert | Bytes |
| `go_memstats_heap_idle_bytes` | Go Heap Memory idle | Bytes |
| `go_goroutines` | Anzahl aktiver Goroutines | Count |

## Panels

1. **Prometheus Status**: Verfügbarkeit des Prometheus-Servers
2. **Time Series**: Anzahl gespeicherter Time Series in der TSDB
3. **Config Reload Status**: Status des letzten Konfigurations-Reloads
4. **HTTP Request Rate**: Rate der HTTP-Anfragen an Prometheus nach Handler und Status-Code
5. **Memory Usage**: Resident Memory und Go Allocated Memory über Zeit
6. **Go Goroutines**: Anzahl aktiver Goroutines über Zeit
7. **Go Memory Stats**: Detaillierte Go Heap Memory Statistiken

## Architektur

```
┌─────────────────────────────────────────────────────────┐
│              Kubernetes Cluster                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │  Prometheus  │  │   Grafana    │                  │
│  │   (Metrics)  │  │ (Dashboards) │                  │
│  └──────┬───────┘  └──────┬───────┘                  │
│         │                  │                           │
│         └────────┬─────────┘                           │
│                  │                                     │
│         ┌────────▼─────────┐                         │
│         │  Alertmanager    │                         │
│         │   (Alerts)       │                         │
│         └──────────────────┘                         │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │ Node         │  │ Kube-State   │                  │
│  │ Exporter     │  │ Metrics      │                  │
│  └──────────────┘  └──────────────┘                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## PromQL Queries

### Prometheus Status
```promql
up{job="prometheus"}
```

### HTTP Request Rate
```promql
rate(prometheus_http_requests_total[5m])
```

### Memory Usage
```promql
process_resident_memory_bytes
go_memstats_heap_alloc_bytes
```

## Referenzen

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)

