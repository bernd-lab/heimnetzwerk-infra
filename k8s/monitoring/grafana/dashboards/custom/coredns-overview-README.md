# CoreDNS Overview Dashboard

## Beschreibung

Dieses Dashboard überwacht die Performance und Gesundheit von CoreDNS, dem DNS-Server für den Kubernetes-Cluster. CoreDNS ist verantwortlich für die DNS-Auflösung innerhalb des Clusters.

## Überwachte Komponenten

- **CoreDNS Server**: DNS-Server für Kubernetes
- **DNS Cache**: Cache für DNS-Antworten
- **Kubernetes DNS Records**: Service- und Pod-DNS-Einträge

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `coredns_dns_requests_total` | Gesamtanzahl DNS-Anfragen | Requests |
| `coredns_dns_responses_total` | Gesamtanzahl DNS-Antworten | Responses |
| `coredns_cache_hits_total` | Anzahl Cache-Treffer | Hits |
| `coredns_cache_misses_total` | Anzahl Cache-Fehltreffer | Misses |
| `coredns_cache_entries` | Anzahl Einträge im Cache | Entries |
| `coredns_dns_request_duration_seconds` | Dauer von DNS-Anfragen (Summe und Count) | Sekunden |
| `up{job="coredns"}` | CoreDNS Server Status (1=Up, 0=Down) | Boolean |

## Panels

1. **DNS Requests Rate**: Rate der eingehenden DNS-Anfragen über Zeit
2. **DNS Responses Rate**: Rate der DNS-Antworten über Zeit
3. **Cache Hits Rate**: Rate der Cache-Treffer über Zeit
4. **Cache Misses Rate**: Rate der Cache-Fehltreffer über Zeit
5. **DNS Request Duration**: Durchschnittliche Dauer einer DNS-Anfrage
6. **Cache Entries**: Aktuelle Anzahl der Einträge im Cache
7. **CoreDNS Status**: Verfügbarkeit des CoreDNS-Servers

## Architektur

```
┌─────────────────────────────────────────────────────────┐
│              CoreDNS DNS Server                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────┐  ┌──────────────┐                  │
│  │   DNS        │  │    Cache     │                  │
│  │  Requests    │  │   (Hits/     │                  │
│  │              │  │   Misses)    │                  │
│  └──────┬───────┘  └──────┬───────┘                  │
│         │                  │                           │
│         └────────┬─────────┘                           │
│                  │                                     │
│         ┌────────▼─────────┐                         │
│         │  Kubernetes     │                         │
│         │  DNS Records    │                         │
│         └──────────────────┘                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## PromQL Queries

### DNS Requests Rate
```promql
rate(coredns_dns_requests_total[5m])
```

### Cache Hit Rate
```promql
rate(coredns_cache_hits_total[5m])
```

### Average DNS Request Duration
```promql
rate(coredns_dns_request_duration_seconds_sum[5m]) / rate(coredns_dns_request_duration_seconds_count[5m])
```

### Cache Hit Ratio
```promql
rate(coredns_cache_hits_total[5m]) / (rate(coredns_cache_hits_total[5m]) + rate(coredns_cache_misses_total[5m]))
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `up{job="coredns"} == 0` - CoreDNS ist nicht verfügbar
- `rate(coredns_dns_request_duration_seconds_sum[5m]) / rate(coredns_dns_request_duration_seconds_count[5m]) > 1` - DNS-Anfragen dauern zu lange (>1 Sekunde)
- `rate(coredns_cache_misses_total[5m]) / rate(coredns_dns_requests_total[5m]) > 0.5` - Cache-Hit-Rate zu niedrig (<50%)

## Referenzen

- [CoreDNS Documentation](https://coredns.io/)
- [CoreDNS Metrics](https://github.com/coredns/coredns/blob/master/plugin/metrics/README.md)

