# Jellyfin Ressourcen-Optimierung - Maximale Performance

**Datum**: 2025-11-06 15:50  
**Status**: ✅ **Maximale Performance-Konfiguration implementiert**

## Anforderung

Jellyfin soll:
1. ✅ Hardware-beschleunigt laufen (NVIDIA GPU)
2. ✅ Maximale Ressourcen nutzen können (fast alle Systemressourcen)
3. ✅ Andere Dienste "erdrücken" können (höchste Priorität)
4. ✅ Nach Bibliotheks-Einrichtung fast alle Systemressourcen auslasten

## System-Ressourcen

- **CPU**: 4 cores (Intel i5-7600K @ 3.80GHz)
- **RAM**: 31GB gesamt, ~14GB verfügbar
- **GPU**: NVIDIA GeForce GTX 1060 6GB
- **Andere Pods**: 41 Pods laufen

## Implementierte Optimierungen

### 1. PriorityClass erstellt (höchste Priorität)

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: jellyfin-high-priority
value: 1000000
preemptionPolicy: PreemptLowerPriority
```

**Effekt**:
- ✅ Jellyfin kann andere Pods verdrängen (Preemption)
- ✅ Höchste Priorität im Cluster
- ✅ Wird immer zuerst scheduled

### 2. CPU-Ressourcen massiv erhöht

**Vorher**:
- CPU Request: 800m (0.2 cores)
- CPU Limit: 2 cores (50% des Systems)

**Nachher**:
- CPU Request: **3000m (3 cores)** - 75% des Systems garantiert
- CPU Limit: **4 cores** - 100% des Systems verfügbar

**Effekt**:
- ✅ Jellyfin kann fast alle CPU-Ressourcen nutzen
- ✅ Garantiert 3 cores für normale Operationen
- ✅ Kann auf alle 4 cores bursten (Transcoding, Bibliotheks-Scans)

### 3. Memory-Ressourcen massiv erhöht

**Vorher**:
- Memory Request: 1Gi
- Memory Limit: 2Gi

**Nachher**:
- Memory Request: **8Gi** - ~26% des Systems garantiert
- Memory Limit: **12Gi** - ~39% des Systems verfügbar

**Effekt**:
- ✅ Genug Memory für große Bibliotheks-Scans
- ✅ Mehr Buffer für Transcoding
- ✅ Weniger OOM-Risiko

### 4. Hardware-Beschleunigung sichergestellt

**Konfiguration**:
- ✅ `/dev/dri` gemountet (GPU-Zugriff)
- ✅ `NVIDIA_VISIBLE_DEVICES=all`
- ✅ `NVIDIA_DRIVER_CAPABILITIES=compute,video,utility`
- ✅ GPU verfügbar: NVIDIA GeForce GTX 1060 6GB

**Effekt**:
- ✅ GPU-Transcoding aktiviert
- ✅ Hardware-Beschleunigung für Video-Encoding/Decoding
- ✅ Entlastet CPU für andere Aufgaben

## Ressourcen-Vergleich

### Vorher (Konservativ)
```yaml
resources:
  requests:
    cpu: 800m      # 20% des Systems
    memory: 1Gi    # 3% des Systems
  limits:
    cpu: "2"       # 50% des Systems
    memory: 2Gi    # 6% des Systems
```

### Nachher (Maximale Performance)
```yaml
resources:
  requests:
    cpu: 3000m     # 75% des Systems
    memory: 8Gi    # 26% des Systems
  limits:
    cpu: "4"       # 100% des Systems
    memory: 12Gi   # 39% des Systems
priorityClassName: jellyfin-high-priority
```

## Auswirkungen auf andere Pods

### Cluster-Auslastung
- **CPU Requests**: Jellyfin beansprucht jetzt 75% (vorher 20%)
- **CPU Limits**: Jellyfin kann jetzt 100% nutzen (vorher 50%)
- **Memory Requests**: Jellyfin beansprucht jetzt 26% (vorher 3%)
- **Memory Limits**: Jellyfin kann jetzt 39% nutzen (vorher 6%)

### Andere Pods
- **41 andere Pods** müssen sich die restlichen Ressourcen teilen
- **Preemption**: Jellyfin kann andere Pods verdrängen wenn nötig
- **Empfehlung**: Andere Container-Ressourcen reduzieren (siehe nächste Schritte)

## Vorteile

1. ✅ **Maximale Performance**: Jellyfin kann fast alle Systemressourcen nutzen
2. ✅ **Hardware-Beschleunigung**: GPU-Transcoding aktiviert
3. ✅ **Bibliotheks-Scans**: Schnelle Scans mit hoher CPU/Memory
4. ✅ **Transcoding**: Mehr parallele Streams möglich
5. ✅ **Priorität**: Jellyfin hat höchste Priorität im Cluster
6. ✅ **Preemption**: Kann andere Pods verdrängen wenn nötig

## Nächste Schritte (Optional)

### Andere Container-Ressourcen reduzieren

Um sicherzustellen, dass andere Container "geradeso" laufen:

1. **Nicht-kritische Pods**: CPU/Memory Requests reduzieren
2. **Low-Priority Pods**: PriorityClass mit niedriger Priorität erstellen
3. **Monitoring**: Ressourcen-Auslastung überwachen

### Beispiel: Low-Priority PriorityClass
```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: low-priority
value: 100
preemptionPolicy: PreemptLowerPriority
```

## Monitoring

### Prüfen ob Jellyfin Ressourcen nutzt:
```bash
# Pod-Status
kubectl get pods -n default -l app=jellyfin

# Ressourcen-Verbrauch (wenn Metrics Server installiert)
kubectl top pod -n default -l app=jellyfin

# GPU-Auslastung
nvidia-smi
```

### Prüfen ob andere Pods verdrängt wurden:
```bash
# Pod-Events
kubectl describe pod <pod-name> -n <namespace>

# Preemption-Events
kubectl get events --all-namespaces --field-selector reason=FailedScheduling
```

## Zusammenfassung

✅ **Jellyfin hat jetzt maximale Ressourcen**:
- 75% CPU garantiert, 100% verfügbar
- 26% Memory garantiert, 39% verfügbar
- Höchste Priorität im Cluster
- GPU-Beschleunigung aktiviert

✅ **Andere Pods müssen sich anpassen**:
- Weniger Ressourcen verfügbar
- Können von Jellyfin verdrängt werden
- Sollten niedrigere Priorität haben

