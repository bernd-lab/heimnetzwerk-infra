# Prometheus Stats Dashboard

## Beschreibung

Dieses Dashboard überwacht die Gesundheit und Performance des Prometheus-Servers selbst. Es zeigt Metriken über die interne Funktionsweise von Prometheus, einschließlich Time Series Database (TSDB), HTTP-Anfragen, Query-Performance und System-Ressourcen.

## Überwachte Komponenten

- **Prometheus Server**: Core-Metriken des Prometheus-Servers
- **TSDB**: Time Series Database Status und Performance
- **HTTP API**: Request-Rate und -Dauer
- **Query Engine**: Query-Performance und aktive Queries
- **Alerting Rules**: Rule Evaluation Performance
- **Go Runtime**: Memory und Goroutines

## Metriken

### Overview Section

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `process_start_time_seconds` | Startzeit des Prometheus-Prozesses | Sekunden |
| `prometheus_tsdb_head_series` | Anzahl aktiver Time Series in TSDB | Anzahl |
| `prometheus_engine_queries` | Aktuell ausgeführte Queries | Anzahl |
| `prometheus_config_last_reload_successful` | Status des letzten Config-Reloads (1=Erfolg, 0=Fehler) | Boolean |

### Ingestion Section

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `prometheus_tsdb_head_samples_appended_total` | Gesamtanzahl Samples, die zu TSDB hinzugefügt wurden | Samples |
| `prometheus_target_interval_length_seconds_count` | Anzahl Scrapes pro Job | Anzahl |

### HTTP Section

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `prometheus_http_requests_total` | Gesamtanzahl HTTP-Anfragen nach Handler und Status-Code | Requests |
| `prometheus_http_request_duration_seconds` | Dauer von HTTP-Anfragen nach Handler | Sekunden |

### Performance Section

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `prometheus_rule_evaluation_duration_seconds` | Dauer der Alerting-Rule-Evaluierung nach Rule-Group | Sekunden |
| `prometheus_engine_query_duration_seconds` | Dauer von PromQL-Queries | Sekunden |

### System Section

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `process_resident_memory_bytes` | Resident Memory des Prozesses | Bytes |
| `go_memstats_heap_alloc_bytes` | Go Heap Memory allokiert | Bytes |
| `go_goroutines` | Anzahl aktiver Goroutines | Anzahl |

## Panels

### Overview Panels

1. **Uptime**: Zeigt die Laufzeit des Prometheus-Servers seit dem Start
2. **Time Series**: Anzahl der gespeicherten Time Series in der TSDB
3. **Active Queries**: Anzahl der aktuell ausgeführten PromQL-Queries
4. **Config Reload**: Status des letzten Konfigurations-Reloads (Success/Failed)

### Ingestion Panels

5. **Samples Ingested Rate**: Rate der Samples, die in die TSDB geschrieben werden
6. **Target Scrapes Rate**: Rate der Target-Scrapes nach Job

### HTTP Panels

7. **HTTP Request Rate**: Request-Rate nach Handler und HTTP-Status-Code
8. **HTTP Request Duration**: Durchschnittliche Request-Dauer nach Handler

### Performance Panels

9. **Rule Evaluation Duration**: Zeit für die Evaluierung von Alerting-Rules nach Rule-Group
10. **Query Duration**: Zeit für die Ausführung von PromQL-Queries

### System Panels

11. **Memory Usage**: Resident Memory und Go Heap Allocations über Zeit
12. **Go Goroutines**: Anzahl aktiver Goroutines über Zeit

## PromQL Queries

### Uptime
```promql
(time() - process_start_time_seconds{job="prometheus"})
```

### Samples Ingested Rate
```promql
rate(prometheus_tsdb_head_samples_appended_total[5m])
```

### HTTP Request Rate
```promql
rate(prometheus_http_requests_total[5m])
```

### Average HTTP Request Duration
```promql
rate(prometheus_http_request_duration_seconds_sum[5m]) / rate(prometheus_http_request_duration_seconds_count[5m])
```

## Alerts

Dieses Dashboard selbst generiert keine Alerts, aber die folgenden Metriken können für Alerting verwendet werden:

- `prometheus_config_last_reload_successful == 0` - Config Reload fehlgeschlagen
- `prometheus_tsdb_head_series > 10000000` - Zu viele Time Series (Warnung)
- `go_goroutines > 10000` - Zu viele Goroutines (mögliches Memory-Leak)

## Visualisierung

```
┌─────────────────────────────────────────────────────────┐
│              Prometheus Server                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │  TSDB    │  │  Query   │  │  HTTP    │            │
│  │  Head    │  │  Engine  │  │  API     │            │
│  └──────────┘  └──────────┘  └──────────┘            │
│       │             │             │                     │
│       └─────────────┴─────────────┘                     │
│                    │                                    │
│              ┌─────▼─────┐                            │
│              │  Scraping  │                            │
│              │  Targets   │                            │
│              └────────────┘                            │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Referenzen

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Prometheus Metrics](https://prometheus.io/docs/instrumenting/exporters/)
- [TSDB Documentation](https://prometheus.io/docs/prometheus/latest/storage/)

