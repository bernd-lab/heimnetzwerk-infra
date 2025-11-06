# Jellyfin Ressourcen-Analyse und Optimierung

**Datum**: 2025-11-06  
**Status**: Analyse und Optimierungsvorschläge

## Aktuelle Ressourcen-Konfiguration

### Jellyfin Container
- **CPU Request**: 500m (0.5 cores)
- **CPU Limit**: 2 cores
- **Memory Request**: 512Mi
- **Memory Limit**: 2Gi

### Server-Ressourcen
- **CPU**: 4 cores
- **RAM**: 31GB gesamt, 16GB benutzt, 14GB verfügbar
- **Disk**: 227GB gesamt, 148GB benutzt, 68GB frei (69% belegt)

## Analyse

### CPU-Verhältnis
- **Request/Limit Ratio**: 500m / 2000m = 25% (sehr niedrig)
- **Bedeutung**: Container kann bei Bedarf auf 4x mehr CPU zugreifen
- **Bewertung**: ✅ Gut für Burst-Workloads (Transcoding)

### Memory-Verhältnis
- **Request/Limit Ratio**: 512Mi / 2048Mi = 25% (sehr niedrig)
- **Bedeutung**: Container kann bei Bedarf auf 4x mehr RAM zugreifen
- **Bewertung**: ✅ Gut für variable Workloads

### Cluster-Auslastung
- **Laufende Pods**: 39 Pods
- **Verfügbare CPU**: 4 cores
- **Verfügbare RAM**: ~14GB verfügbar

## Optimierungsvorschläge

### 1. CPU-Optimierung

**Aktuell**: 500m Request / 2 cores Limit

**Option A: Konservativ (empfohlen für Single-Node)**
```yaml
resources:
  requests:
    cpu: 1000m      # 1 core garantiert
    memory: 1Gi     # 1GB garantiert
  limits:
    cpu: 2          # 2 cores max (50% des Clusters)
    memory: 2Gi     # 2GB max
```

**Option B: Aggressiv (wenn viel Transcoding)**
```yaml
resources:
  requests:
    cpu: 1500m      # 1.5 cores garantiert
    memory: 1.5Gi   # 1.5GB garantiert
  limits:
    cpu: 3          # 3 cores max (75% des Clusters)
    memory: 3Gi     # 3GB max
```

**Option C: Minimal (wenn wenig Transcoding)**
```yaml
resources:
  requests:
    cpu: 500m       # 0.5 cores garantiert (aktuell)
    memory: 512Mi   # 512MB garantiert (aktuell)
  limits:
    cpu: 1500m      # 1.5 cores max (reduziert)
    memory: 1.5Gi   # 1.5GB max (reduziert)
```

### 2. Memory-Optimierung

**Aktuell**: 512Mi Request / 2Gi Limit

**Empfehlung**: Memory-Request erhöhen für bessere Planung
- **Request**: 1Gi (bessere Planung, weniger OOM-Risiko)
- **Limit**: 2Gi (ausreichend für Media-Server)

### 3. InitContainer-Optimierung

**Aktuell**: Keine Ressourcen-Limits für initContainer

**Empfehlung**: Ressourcen für initContainer setzen
```yaml
initContainers:
- name: fix-permissions
  resources:
    requests:
      cpu: 10m
      memory: 16Mi
    limits:
      cpu: 100m
      memory: 64Mi
```

### 4. Liveness/Readiness Probes

**Aktuell**: Nicht konfiguriert

**Empfehlung**: Probes hinzufügen für bessere Health-Checks
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8096
  initialDelaySeconds: 60
  periodSeconds: 30
readinessProbe:
  httpGet:
    path: /health
    port: 8096
  initialDelaySeconds: 30
  periodSeconds: 10
```

## Empfohlene Konfiguration

Basierend auf der Analyse empfehle ich **Option A (Konservativ)**:

```yaml
resources:
  requests:
    cpu: 1000m      # 1 core garantiert (25% des Clusters)
    memory: 1Gi     # 1GB garantiert
  limits:
    cpu: 2          # 2 cores max (50% des Clusters)
    memory: 2Gi     # 2GB max
```

**Begründung**:
- ✅ Garantiert genug CPU für normale Operationen
- ✅ Ermöglicht Burst auf 2 cores für Transcoding
- ✅ Memory-Request erhöht für bessere Planung
- ✅ Lässt genug Ressourcen für andere Pods (39 Pods laufen)
- ✅ Balance zwischen Performance und Cluster-Kapazität

## Monitoring-Empfehlungen

1. **Metrics Server installieren** für echte Auslastungsdaten
2. **Prometheus/Grafana** für langfristiges Monitoring
3. **Alerts** bei hoher CPU/Memory-Auslastung

## Nächste Schritte

1. ✅ Ressourcen-Optimierung anwenden
2. ⏳ Liveness/Readiness Probes hinzufügen
3. ⏳ Metrics Server installieren
4. ⏳ Langfristiges Monitoring einrichten

