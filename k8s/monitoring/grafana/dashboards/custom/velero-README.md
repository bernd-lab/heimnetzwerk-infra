# Velero Dashboard

## Beschreibung

Dieses Dashboard überwacht Velero, das Backup- und Disaster-Recovery-Tool für Kubernetes. Velero ermöglicht Backups von Kubernetes-Ressourcen und persistenten Volumes.

## Überwachte Komponenten

- **Velero Server**: Backup-Server
- **Backups**: Kubernetes-Ressourcen-Backups
- **Restores**: Backup-Wiederherstellungen
- **Schedules**: Geplante Backups
- **Volume Snapshots**: Persistent Volume Snapshots

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `velero_backup_total` | Gesamtanzahl Backups | Count |
| `velero_backup_duration_seconds` | Dauer von Backups | Sekunden |
| `velero_backup_success_total` | Anzahl erfolgreicher Backups | Count |
| `velero_backup_failure_total` | Anzahl fehlgeschlagener Backups | Count |
| `velero_restore_total` | Gesamtanzahl Restores | Count |
| `velero_restore_success_total` | Anzahl erfolgreicher Restores | Count |
| `velero_restore_failure_total` | Anzahl fehlgeschlagener Restores | Count |

## Panels

1. **Total Backups**: Gesamtanzahl durchgeführter Backups
2. **Successful Backups**: Anzahl erfolgreicher Backups
3. **Failed Backups**: Anzahl fehlgeschlagener Backups
4. **Backup Duration**: Dauer der Backups über Zeit
5. **Backup Status**: Verteilung nach Status (Pie Chart)
6. **Restore Status**: Verteilung nach Status (Pie Chart)

## PromQL Queries

### Total Backups
```promql
sum(velero_backup_total)
```

### Successful Backups
```promql
sum(velero_backup_success_total)
```

### Backup Duration
```promql
velero_backup_duration_seconds
```

### Backup Status Distribution
```promql
sum by (status) (velero_backup_total)
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `sum(velero_backup_failure_total) > 0` - Backup-Fehler aufgetreten
- `velero_backup_duration_seconds > 3600` - Backup-Dauer zu lang (>1 Stunde)
- `sum(velero_restore_failure_total) > 0` - Restore-Fehler aufgetreten

## Referenzen

- [Velero Documentation](https://velero.io/docs/)
- [Velero Metrics](https://velero.io/docs/main/monitoring/)

