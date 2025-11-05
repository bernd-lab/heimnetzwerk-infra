# GitLab Login-Problem: Debugging Report

**Erstellt**: 2025-11-05 18:16
**Analysiert von**: Kubernetes-Expert + GitLab/GitHub-Expert

## Problem-Beschreibung

- **Symptom**: Login-Interface wird angezeigt, aber Login-Versuch schlägt fehl
- **URL**: https://gitlab.k8sops.online
- **Credentials**: root / TempPass123!

## Analyse-Ergebnisse

### ✅ Was funktioniert

1. **GitLab Pod läuft**:
   - Pod: `gitlab-fff89c66b-lxgh5`
   - Status: Running (1/1 Ready)
   - Health-Check intern: 200 OK

2. **Ingress funktioniert**:
   - HTTP/2 302 Redirect zu `/users/sign_in`
   - TLS-Zertifikat gültig
   - Routing korrekt

3. **Login-Seite wird angezeigt**:
   - HTML wird korrekt ausgeliefert
   - Interface ist erreichbar

### ⚠️ Erkannte Probleme

1. **Liveness-Probe schlägt fehl**:
   - Statuscode: 404
   - Endpoint: `http://:80/-/health`
   - Problem: Endpoint möglicherweise falsch oder nicht verfügbar

2. **Pod-Restarts**:
   - 4 Restarts in 55 Minuten
   - Letzte Restart: vor 5m52s
   - Ursache: Liveness-Probe-Fehler

3. **GitLab-Konfiguration**:
   - `external_url`: `https://gitlab.k8sops.online` (HTTPS)
   - `trusted_proxies`: Korrekt konfiguriert (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
   - Aber: GitLab erwartet HTTPS, könnte CSRF-Token-Probleme verursachen

## Mögliche Ursachen

### 1. CSRF-Token-Problem
- GitLab erwartet HTTPS (`external_url` ist HTTPS)
- Aber Ingress könnte HTTP-zu-HTTPS-Redirect verwenden
- CSRF-Token-Validierung könnte fehlschlagen

### 2. Session-Problem
- Session-Cookies werden möglicherweise nicht korrekt gesetzt
- Cross-Domain-Probleme zwischen HTTP und HTTPS

### 3. Liveness-Probe-Konfiguration
- Endpoint `/-/health` gibt 404 zurück
- GitLab startet möglicherweise nicht vollständig

## Empfohlene Lösungen

### Lösung 1: Liveness-Probe-Endpoint korrigieren

```bash
# Prüfe verfügbare Health-Endpoints
kubectl exec -n gitlab gitlab-fff89c66b-lxgh5 -- curl -s http://localhost:80/-/health
kubectl exec -n gitlab gitlab-fff89c66b-lxgh5 -- curl -s http://localhost:80/-/readiness
kubectl exec -n gitlab gitlab-fff89c66b-lxgh5 -- curl -s http://localhost:80/api/v4/version
```

### Lösung 2: GitLab-Konfiguration anpassen

```bash
# ConfigMap aktualisieren
kubectl edit configmap -n gitlab gitlab-config

# Oder Deployment patchen
kubectl patch deployment -n gitlab gitlab -p '{"spec":{"template":{"spec":{"containers":[{"name":"gitlab","livenessProbe":{"httpGet":{"path":"/api/v4/version"}}}]}}}}'
```

### Lösung 3: External URL auf HTTP ändern (temporär)

```yaml
# In ConfigMap gitlab-config
external_url 'http://gitlab.k8sops.online'
```

HTTPS wird dann vom Ingress übernommen.

## Nächste Schritte

1. **Health-Endpoints testen**:
   ```bash
   kubectl exec -n gitlab gitlab-fff89c66b-lxgh5 -- curl -v http://localhost:80/-/health
   ```

2. **GitLab-Logs prüfen**:
   ```bash
   kubectl logs -n gitlab gitlab-fff89c66b-lxgh5 --tail=200 | grep -i "csrf\|session\|auth"
   ```

3. **Browser-Console prüfen**:
   - Browser DevTools öffnen
   - Network-Tab: Login-Request analysieren
   - Console: JavaScript-Fehler prüfen

4. **ConfigMap prüfen**:
   ```bash
   kubectl get configmap -n gitlab gitlab-config -o yaml
   ```

## Status

- **Pod**: ✅ Läuft
- **Ingress**: ✅ Funktioniert
- **Login-Seite**: ✅ Wird angezeigt
- **Login-Prozess**: ❌ Schlägt fehl
- **Liveness-Probe**: ❌ 404-Fehler

