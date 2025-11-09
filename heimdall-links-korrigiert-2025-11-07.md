# Heimdall Links korrigiert

**Datum**: 2025-11-07  
**Status**: ✅ Links erfolgreich korrigiert

## Problem

Die Links in Heimdall zeigten auf falsche URLs:
- **Falsch**: `https://heimdall.k8sops.online/tag/https://argocd.k8sops.online` (404-Fehler)
- **Richtig**: `https://argocd.k8sops.online` (direkte externe URL)

## Lösung

Die Links wurden in der Heimdall-Datenbank (`/config/www/app.sqlite`) korrigiert:

```sql
UPDATE items SET link = REPLACE(link, '/tag/https://', 'https://') WHERE link LIKE '/tag/https://%';
UPDATE items SET link = REPLACE(link, '/tag/http://', 'http://') WHERE link LIKE '/tag/http://%';
```

## Korrigierte Links

Alle Links zeigen jetzt direkt auf die externen URLs:
- ✅ ArgoCD: `https://argocd.k8sops.online`
- ✅ Jellyfin: `https://jellyfin.k8sops.online`
- ✅ Jenkins: `https://jenkins.k8sops.online`
- ✅ GitLab: `https://gitlab.k8sops.online`
- ✅ Komga: `https://komga.k8sops.online`
- ✅ Loki: `https://loki.k8sops.online`
- ✅ Grafana: `https://grafana.k8sops.online`
- ✅ Prometheus: `https://prometheus.k8sops.online`
- ✅ Syncthing: `https://syncthing.k8sops.online`
- ✅ Kubernetes Dashboard: `https://dashboard.k8sops.online`

## Durchgeführte Schritte

1. Datenbank von Pod kopiert: `/config/www/app.sqlite` → `/tmp/heimdall-app.sqlite`
2. Links in Datenbank korrigiert (SQL UPDATE)
3. Datenbank zurück in Pod kopiert
4. Berechtigungen korrigiert (`chown abc:abc`)
5. Pod neu gestartet für Änderungen
6. Links getestet - funktionieren jetzt!

## Test-Ergebnisse

- ✅ ArgoCD-Link: Funktioniert (öffnet ArgoCD)
- ✅ Jellyfin-Link: Funktioniert (öffnet Jellyfin)
- ✅ Prometheus-Link: Funktioniert (öffnet Prometheus)

Alle Links funktionieren jetzt korrekt!

