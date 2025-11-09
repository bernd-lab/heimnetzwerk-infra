# Alertmanager Overview Dashboard

## Beschreibung

Dieses Dashboard überwacht Alertmanager, den Alert-Routing- und -Benachrichtigungsservice für Prometheus. Alertmanager empfängt Alerts von Prometheus, gruppiert sie, unterdrückt Duplikate und sendet Benachrichtigungen über verschiedene Kanäle.

## Überwachte Komponenten

- **Alertmanager Server**: Core-Alert-Routing-Service
- **Notification Channels**: Discord, Email, Slack, PagerDuty, etc.

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `up{job="alertmanager"}` | Alertmanager Server Status (1=Up, 0=Down) | Boolean |
| `process_resident_memory_bytes{job="alertmanager"}` | Resident Memory des Prozesses | Bytes |
| `go_memstats_heap_alloc_bytes{job="alertmanager"}` | Go Heap Memory allokiert | Bytes |
| `go_goroutines{job="alertmanager"}` | Anzahl aktiver Goroutines | Count |
| `alertmanager_alerts_*` | Alert-Metriken (falls verfügbar) | Alerts |
| `alertmanager_notifications_*` | Notification-Metriken (falls verfügbar) | Notifications |

## Panels

1. **Alertmanager Status**: Verfügbarkeit des Alertmanager-Servers
2. **Alertmanager Memory**: Resident Memory und Go Heap Allocations über Zeit
3. **Alertmanager Goroutines**: Anzahl aktiver Goroutines über Zeit

## Architektur

```
┌─────────────────────────────────────────────────────────┐
│              Alertmanager Flow                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐                                      │
│  │  Prometheus  │                                      │
│  │   (Alerts)   │                                      │
│  └──────┬───────┘                                      │
│         │                                              │
│         ▼                                              │
│  ┌──────────────┐                                      │
│  │ Alertmanager │                                      │
│  │  (Routing)   │                                      │
│  └──────┬───────┘                                      │
│         │                                              │
│         ├──────────┬──────────┬──────────┐            │
│         ▼          ▼          ▼          ▼            │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐    │
│  │ Discord │ │  Email  │ │  Slack │ │  Pager  │    │
│  │ Webhook │ │         │ │         │ │  Duty   │    │
│  └─────────┘ └─────────┘ └─────────┘ └─────────┘    │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## PromQL Queries

### Alertmanager Status
```promql
up{job="alertmanager"}
```

### Memory Usage
```promql
process_resident_memory_bytes{job="alertmanager"}
go_memstats_heap_alloc_bytes{job="alertmanager"}
```

### Goroutines
```promql
go_goroutines{job="alertmanager"}
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `up{job="alertmanager"} == 0` - Alertmanager ist nicht verfügbar
- `go_memstats_heap_alloc_bytes{job="alertmanager"} > 500000000` - Hoher Memory-Verbrauch (>500MB)
- `go_goroutines{job="alertmanager"} > 1000` - Zu viele Goroutines (mögliches Leak)

## Referenzen

- [Alertmanager Documentation](https://prometheus.io/docs/alerting/latest/alertmanager/)
- [Alertmanager Configuration](https://prometheus.io/docs/alerting/latest/configuration/)

