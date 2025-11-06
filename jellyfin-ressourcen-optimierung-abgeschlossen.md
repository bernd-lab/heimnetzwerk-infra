# Jellyfin Ressourcen-Optimierung - Abgeschlossen

**Datum**: 2025-11-06  
**Status**: ✅ Optimierungen implementiert

## Durchgeführte Optimierungen

### 1. CPU-Requests erhöht
- **Vorher**: 500m (0.5 cores)
- **Nachher**: 1000m (1 core)
- **Begründung**: Bessere Planung, garantiert genug CPU für normale Operationen

### 2. Memory-Requests erhöht
- **Vorher**: 512Mi
- **Nachher**: 1Gi
- **Begründung**: Bessere Planung, reduziert OOM-Risiko

### 3. Liveness Probe hinzugefügt
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8096
  initialDelaySeconds: 60
  periodSeconds: 30
  timeoutSeconds: 10
```
- **Zweck**: Automatischer Neustart bei Problemen

### 4. Readiness Probe hinzugefügt
```yaml
readinessProbe:
  httpGet:
    path: /health
    port: 8096
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
```
- **Zweck**: Traffic nur wenn Container bereit

### 5. InitContainer-Ressourcen gesetzt
- **CPU Request**: 10m
- **CPU Limit**: 100m
- **Memory Request**: 16Mi
- **Memory Limit**: 64Mi
- **Begründung**: Ressourcen-Kontrolle auch für Init-Container

## Aktuelle Ressourcen-Konfiguration

### Jellyfin Container
- **CPU Request**: 1000m (1 core) - 25% des Clusters
- **CPU Limit**: 2 cores - 50% des Clusters
- **Memory Request**: 1Gi
- **Memory Limit**: 2Gi

### Cluster-Auslastung (nach Optimierung)
- **CPU Requests**: ~3900m (97.5% von 4 cores)
- **CPU Limits**: 7 cores (175% - overcommitted, aber OK)
- **Memory Requests**: ~6.4Gi (20% von 31GB)
- **Memory Limits**: ~10.3Gi (33% von 31GB)

## Vorteile der Optimierung

1. ✅ **Bessere Planung**: Höhere Requests = bessere Scheduler-Entscheidungen
2. ✅ **Weniger OOM-Risiko**: Mehr garantierter Memory
3. ✅ **Automatische Health-Checks**: Probes für bessere Verfügbarkeit
4. ✅ **Ressourcen-Kontrolle**: Auch InitContainer haben Limits
5. ✅ **Balance**: Genug für Jellyfin, aber auch Platz für andere Pods

## Monitoring-Empfehlungen

1. **Metrics Server installieren** für echte Auslastungsdaten:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

2. **Prometheus/Grafana** für langfristiges Monitoring

3. **Alerts** bei:
   - CPU-Auslastung > 80% für > 5 Minuten
   - Memory-Auslastung > 90%
   - Pod-Restarts > 3 in 10 Minuten

## Nächste Schritte

1. ✅ Ressourcen-Optimierung angewendet
2. ✅ Health Probes hinzugefügt
3. ⏳ Metrics Server installieren
4. ⏳ Langfristiges Monitoring einrichten
5. ⏳ Performance-Tests durchführen

