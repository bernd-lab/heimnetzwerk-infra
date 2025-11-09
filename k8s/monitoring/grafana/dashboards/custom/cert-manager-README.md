# Cert-Manager Dashboard

## Beschreibung

Dieses Dashboard überwacht Cert-Manager, den automatischen TLS-Zertifikat-Manager für Kubernetes. Cert-Manager verwaltet TLS-Zertifikate von verschiedenen Issuern (Let's Encrypt, ACME, Vault, etc.).

## Überwachte Komponenten

- **Cert-Manager Controller**: Zertifikat-Verwaltung
- **Certificate Resources**: Kubernetes Certificate-Ressourcen
- **ACME Issuer**: Let's Encrypt / ACME Issuer
- **Certificate Expiry**: Ablaufzeit der Zertifikate

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `cert_manager_certificate_expiration_timestamp_seconds` | Ablaufzeit der Zertifikate | Unix Timestamp |
| `cert_manager_certificate_ready_status` | Ready-Status der Zertifikate (1=Ready, 0=NotReady) | Boolean |
| `cert_manager_acme_challenge_duration_seconds` | Dauer von ACME-Challenges | Sekunden |
| `cert_manager_acme_client_request_count` | Anzahl ACME-API-Anfragen | Requests |

## Panels

1. **Total Certificates**: Gesamtanzahl verwalteter Zertifikate
2. **Ready Certificates**: Anzahl bereiter Zertifikate
3. **Certificates Expiring Soon**: Anzahl Zertifikate, die in < 30 Tagen ablaufen
4. **Certificate Expiry**: Verbleibende Tage bis zum Ablauf nach Zertifikat
5. **Certificate Status**: Verteilung nach Status (Pie Chart)

## PromQL Queries

### Total Certificates
```promql
count(cert_manager_certificate_expiration_timestamp_seconds)
```

### Ready Certificates
```promql
count(cert_manager_certificate_ready_status == 1)
```

### Certificates Expiring Soon (< 30 days)
```promql
count((cert_manager_certificate_expiration_timestamp_seconds - time()) < 2592000)
```

### Days Until Expiry
```promql
(cert_manager_certificate_expiration_timestamp_seconds - time()) / 86400
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `(cert_manager_certificate_expiration_timestamp_seconds - time()) / 86400 < 7` - Zertifikat läuft in < 7 Tagen ab
- `cert_manager_certificate_ready_status == 0` - Zertifikat ist nicht Ready

## Referenzen

- [Cert-Manager Documentation](https://cert-manager.io/docs/)
- [Cert-Manager Metrics](https://cert-manager.io/docs/usage/metrics/)

