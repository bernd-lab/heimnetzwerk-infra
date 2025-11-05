# GitLab 502-Fehler Analyse und Fix

**Erstellt**: 2025-11-05 18:30
**Analysiert von**: Kubernetes-Expert + GitLab/GitHub-Expert

## Problem-Beschreibung

- **Symptom**: Nach Login-Versuch kommt HTTP 502 Bad Gateway
- **URL**: https://gitlab.k8sops.online
- **Credentials**: root / TempPass123!
- **Pod**: `gitlab-7f86dc7f4f-v429r` (wird ständig neu gestartet)

## Root Cause Analyse

### Erkanntes Problem

1. **Liveness-Probe schlägt fehl**:
   - Liveness-Probe verwendet `httpGet` mit Host-Header `gitlab.k8sops.online`
   - GitLab gibt 404 zurück, wenn die Liveness-Probe ausgeführt wird
   - Kubernetes tötet den Pod wegen fehlgeschlagener Liveness-Probe (Exit Code 137 = SIGKILL)

2. **Pod-Restarts**:
   - 5 Restarts in 68 Minuten
   - Pod wird ständig getötet und neu gestartet
   - Wenn Login-Request kommt, während Pod neu startet → 502 Bad Gateway

3. **Health-Endpoints funktionieren intern**:
   - `curl http://localhost:80/-/health` → `GitLab OK`
   - `curl http://localhost:80/-/readiness` → `{"status":"ok","master_check":[{"status":"ok"}]}`
   - Problem: Nur mit `httpGet` und Host-Header schlägt es fehl

### Technische Details

**Vorher (fehlerhaft)**:
```yaml
livenessProbe:
  httpGet:
    httpHeaders:
    - name: Host
      value: gitlab.k8sops.online
    path: /-/health
    port: 80
    scheme: HTTP
  failureThreshold: 12
  initialDelaySeconds: 600
  periodSeconds: 10
  timeoutSeconds: 5
```

**Nachher (korrigiert)**:
```yaml
livenessProbe:
  exec:
    command:
    - /bin/bash
    - -c
    - 'curl -sf http://localhost:80/-/health > /dev/null'
  failureThreshold: 12
  initialDelaySeconds: 600
  periodSeconds: 10
  timeoutSeconds: 5
```

## Lösung

### Fix implementiert

Die Liveness-Probe wurde von `httpGet` auf `exec` umgestellt, analog zur Readiness-Probe:

```bash
kubectl patch deployment -n gitlab gitlab --type='json' -p='[
  {
    "op": "replace",
    "path": "/spec/template/spec/containers/0/livenessProbe",
    "value": {
      "exec": {
        "command": ["/bin/bash", "-c", "curl -sf http://localhost:80/-/health > /dev/null"]
      },
      "failureThreshold": 12,
      "initialDelaySeconds": 600,
      "periodSeconds": 10,
      "successThreshold": 1,
      "timeoutSeconds": 5
    }
  }
]'
```

### Warum funktioniert das?

1. **Readiness-Probe funktioniert**: Verwendet bereits `exec` mit `curl` und funktioniert zuverlässig
2. **Kein Host-Header-Problem**: `curl` auf `localhost` umgeht Host-Header-Validierung
3. **Konsistenz**: Beide Probes verwenden jetzt den gleichen Ansatz

## Erwartetes Ergebnis

Nach dem Fix:
- ✅ Pod wird nicht mehr wegen fehlgeschlagener Liveness-Probe getötet
- ✅ Pod läuft stabil ohne Restarts
- ✅ Login funktioniert ohne 502-Fehler
- ✅ GitLab ist vollständig funktionsfähig

## Nächste Schritte

1. **Pod-Status überwachen**:
   ```bash
   kubectl get pod -n gitlab -l app=gitlab -w
   ```

2. **Login-Test durchführen**:
   - URL: https://gitlab.k8sops.online
   - Login: root / TempPass123!
   - Erwartung: Erfolgreicher Login ohne 502

3. **Stabilität beobachten**:
   - Mindestens 24h ohne Restarts
   - Dann als "stabil" markieren

## Status

- **Problem identifiziert**: ✅ Liveness-Probe-Fehler
- **Fix implementiert**: ✅ Liveness-Probe auf `exec` umgestellt
- **Pod-Status**: ⏳ Wird neu erstellt
- **Login-Test**: ⏳ Ausstehend

## Referenzen

- **GitLab Health-Endpoints**: https://docs.gitlab.com/ee/administration/monitoring/health_check.html
- **Kubernetes Liveness Probes**: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/
- **Exit Code 137**: SIGKILL (Pod wurde von Kubernetes getötet)

