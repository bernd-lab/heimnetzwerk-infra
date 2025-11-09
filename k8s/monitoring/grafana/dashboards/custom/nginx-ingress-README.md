# NGINX Ingress Controller Dashboard

## Beschreibung

Dieses Dashboard überwacht den NGINX Ingress Controller, der eingehenden HTTP/HTTPS-Traffic zu Kubernetes-Services routet.

## Überwachte Komponenten

- **NGINX Ingress Controller**: Load Balancer und Reverse Proxy
- **Ingress Rules**: Routing-Regeln für Services
- **Upstream Services**: Backend-Services

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `nginx_ingress_controller_requests` | Anzahl HTTP-Anfragen nach Ingress, Service, Status-Code | Requests |
| `nginx_ingress_controller_request_duration_seconds` | Dauer von HTTP-Anfragen (Summe und Count) | Sekunden |
| `nginx_ingress_controller_connections` | Aktive Verbindungen nach State (active, reading, writing, waiting) | Connections |
| `nginx_ingress_controller_ingress_upstream_latency_seconds` | Upstream-Latenz | Sekunden |

## Panels

1. **Request Rate**: Rate der HTTP-Anfragen nach Ingress und Service
2. **Response Codes**: Rate der Anfragen nach HTTP-Status-Code
3. **Request Duration**: Durchschnittliche Dauer von HTTP-Anfragen
4. **Active Connections**: Aktive Verbindungen nach State

## PromQL Queries

### Request Rate
```promql
rate(nginx_ingress_controller_requests[5m])
```

### Average Request Duration
```promql
rate(nginx_ingress_controller_request_duration_seconds_sum[5m]) / rate(nginx_ingress_controller_request_duration_seconds_count[5m])
```

### Active Connections
```promql
nginx_ingress_controller_connections
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `rate(nginx_ingress_controller_requests{status=~\"5..\"}[5m]) > 10` - Zu viele 5xx-Fehler (>10/s)
- `rate(nginx_ingress_controller_request_duration_seconds_sum[5m]) / rate(nginx_ingress_controller_request_duration_seconds_count[5m]) > 1` - Request-Dauer zu hoch (>1s)

## Referenzen

- [NGINX Ingress Controller Documentation](https://kubernetes.github.io/ingress-nginx/)
- [NGINX Ingress Metrics](https://kubernetes.github.io/ingress-nginx/user-guide/monitoring/)

