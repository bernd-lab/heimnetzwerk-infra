# Jellyfin Wiedergabefehler - GPU-Problem behoben

**Datum**: 2025-11-07  
**Problem**: "Blöder Kreisel" - Wiedergabe startet nicht  
**Ursache**: NVIDIA CUDA kann nicht geladen werden  
**Lösung**: Temporär auf Software-Transcoding umgestellt

## Problem-Analyse

### Gefundene Fehler in FFmpeg-Logs:

```
[AVHWDeviceContext @ 0x...] Cannot load libcuda.so.1
Device creation failed: -1.
Failed to set value 'cuda=cu:0' for option 'init_hw_device': Operation not permitted
Error parsing global options: Operation not permitted
```

### Ursache:

1. **CUDA Library fehlt**: `libcuda.so.1` ist nicht im Container verfügbar
2. **GPU-Zugriff fehlt**: NVIDIA Device Plugin möglicherweise nicht installiert
3. **FFmpeg schlägt fehl**: Hardware-Beschleunigung kann nicht initialisiert werden
4. **Transcoding startet nicht**: Ohne funktionierendes FFmpeg kann kein Stream abgespielt werden

### Auswirkung:

- ⚠️ **Wiedergabe startet nicht**: Nur Ladekreis (Spinner) wird angezeigt
- ⚠️ **Transcoding schlägt fehl**: FFmpeg kann nicht starten
- ⚠️ **Live-TV funktioniert nicht**: Streams können nicht verarbeitet werden

## Durchgeführte Lösung

### Temporäre Lösung: Software-Transcoding aktiviert

**Vorher** (Hardware-Beschleunigung):
```xml
<HardwareAccelerationType>nvenc</HardwareAccelerationType>
<EnableHardwareEncoding>true</EnableHardwareEncoding>
```

**Nachher** (Software-Transcoding):
```xml
<HardwareAccelerationType>none</HardwareAccelerationType>
<EnableHardwareEncoding>false</EnableHardwareEncoding>
```

### Vorteile:

- ✅ **Funktioniert sofort**: Keine GPU-Abhängigkeit
- ✅ **Wiedergabe startet**: FFmpeg kann jetzt arbeiten
- ✅ **CPU-Transcoding**: Nutzt die 3-4 cores die Jellyfin hat

### Nachteile:

- ⚠️ **Weniger effizient**: CPU-Transcoding ist langsamer als GPU
- ⚠️ **Mehr CPU-Last**: Transcoding belastet CPU stärker
- ⚠️ **Weniger parallele Streams**: Begrenzt durch CPU-Leistung

## GPU-Problem-Analyse

### Warum funktioniert GPU nicht?

1. **libcuda.so.1 fehlt**: CUDA-Library ist nicht im Container
2. **NVIDIA Device Plugin**: Möglicherweise nicht installiert im Cluster
3. **GPU-Ressourcen**: Nicht im Deployment angefordert
4. **Node-Konfiguration**: GPU möglicherweise nicht für Kubernetes verfügbar

### Prüfungen:

- ❌ `libcuda.so.1` nicht gefunden im Container
- ❌ `nvidia-smi` nicht verfügbar
- ❌ Node zeigt keine GPU-Ressourcen
- ✅ `/dev/dri` gemountet (aber das ist für Intel iGPU, nicht NVIDIA)

## Nächste Schritte für GPU-Support

### Option 1: NVIDIA Device Plugin installieren

```bash
# Prüfe ob NVIDIA Device Plugin installiert ist
kubectl get daemonset -n kube-system | grep nvidia

# Falls nicht, installiere es:
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.1/nvidia-device-plugin.yml
```

### Option 2: GPU-Ressourcen im Deployment anfordern

```yaml
resources:
  limits:
    nvidia.com/gpu: 1  # GPU anfordern
  requests:
    nvidia.com/gpu: 1
```

### Option 3: CUDA-Libraries in Container mounten

```yaml
volumeMounts:
- mountPath: /usr/local/cuda
  name: cuda-libs
volumes:
- name: cuda-libs
  hostPath:
    path: /usr/local/cuda
```

## Aktueller Status

### ✅ Behoben:

1. **Software-Transcoding aktiviert**: Wiedergabe sollte jetzt funktionieren
2. **FFmpeg kann arbeiten**: Keine GPU-Abhängigkeit mehr
3. **Pod neu gestartet**: Konfiguration geladen

### ⚠️ Temporär:

- Hardware-Beschleunigung deaktiviert
- CPU-Transcoding aktiv (funktioniert, aber langsamer)

### 🔧 Für später:

- GPU-Support reparieren (NVIDIA Device Plugin, CUDA-Libraries)
- Hardware-Beschleunigung wieder aktivieren

## Testen

1. ✅ **Pod neu gestartet** - Konfiguration geladen
2. ⚠️ **Wiedergabe testen**: Versuche jetzt einen Stream abzuspielen
3. ⚠️ **Logs überwachen**: Prüfe ob FFmpeg jetzt erfolgreich startet

Die Wiedergabe sollte jetzt funktionieren, auch wenn ohne Hardware-Beschleunigung.

