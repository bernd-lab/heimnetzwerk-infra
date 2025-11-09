# Node Exporter Dashboard

## Beschreibung

Dieses Dashboard überwacht System-Metriken der Kubernetes-Nodes über Node Exporter. Node Exporter sammelt Hardware- und OS-Metriken von Linux-Systemen.

## Überwachte Komponenten

- **CPU**: CPU-Auslastung und Load Average
- **Memory**: Speicherverbrauch und Swap
- **Disk**: Disk I/O und Speicherplatz
- **Network**: Netzwerk-Traffic und Fehler

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `node_cpu_seconds_total` | CPU-Zeit nach Mode (user, system, idle, etc.) | Sekunden |
| `node_memory_MemTotal_bytes` | Gesamter Speicher | Bytes |
| `node_memory_MemAvailable_bytes` | Verfügbarer Speicher | Bytes |
| `node_memory_SwapTotal_bytes` | Gesamter Swap-Speicher | Bytes |
| `node_memory_SwapFree_bytes` | Freier Swap-Speicher | Bytes |
| `node_disk_read_bytes_total` | Gelesene Bytes von Disk | Bytes |
| `node_disk_written_bytes_total` | Geschriebene Bytes zu Disk | Bytes |
| `node_disk_io_now` | Aktuelle Disk I/O-Operationen | Operations |
| `node_network_receive_bytes_total` | Empfangene Netzwerk-Bytes | Bytes |
| `node_network_transmit_bytes_total` | Gesendete Netzwerk-Bytes | Bytes |
| `node_load1` | System Load Average (1 Minute) | Load |
| `node_load5` | System Load Average (5 Minuten) | Load |
| `node_load15` | System Load Average (15 Minuten) | Load |
| `node_filesystem_size_bytes` | Größe des Filesystems | Bytes |
| `node_filesystem_avail_bytes` | Verfügbarer Speicherplatz | Bytes |

## Panels

1. **CPU Usage**: CPU-Auslastung in Prozent über Zeit
2. **Memory Usage**: Speicherverbrauch in Prozent über Zeit
3. **Disk I/O Rate**: Disk Lese-/Schreib-Rate über Zeit
4. **Network Traffic**: Netzwerk-Empfang/Send-Rate über Zeit
5. **System Load**: Load Average (1m, 5m, 15m) über Zeit
6. **Disk Space Usage**: Speicherplatz-Verwendung in Prozent nach Mountpoint

## PromQL Queries

### CPU Usage Percentage
```promql
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

### Memory Usage Percentage
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

### Disk Read Rate
```promql
rate(node_disk_read_bytes_total[5m])
```

### Network Receive Rate
```promql
rate(node_network_receive_bytes_total[5m])
```

### Disk Space Usage Percentage
```promql
(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90` - CPU-Auslastung > 90%
- `(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90` - Memory-Auslastung > 90%
- `(1 - (node_filesystem_avail_bytes / node_filesystem_size_bytes)) * 100 > 85` - Disk-Speicherplatz > 85%
- `node_load1 > count(node_cpu_seconds_total{mode="idle"}) * 2` - Load Average zu hoch

## Referenzen

- [Node Exporter Documentation](https://github.com/prometheus/node_exporter)
- [Node Exporter Metrics](https://github.com/prometheus/node_exporter#collectors)

