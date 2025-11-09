# Jellyfin GPU-Problem - Zusammenfassung und Lösung

**Datum**: 2025-11-07  
**Problem**: Wiedergabe startet nicht - nur Ladekreis  
**Status**: ✅ **Temporär behoben (Software-Transcoding)**

## Problem

### Symptom:
- ⚠️ Beim Abspielen von Streams erscheint nur ein Ladekreis
- ⚠️ Wiedergabe startet nicht
- ⚠️ Kein Video/Audio

### Ursache:
FFmpeg kann NVIDIA CUDA nicht nutzen:
```
Cannot load libcuda.so.1
Device creation failed: -1
Failed to set value 'cuda=cu:0' for option 'init_hw_device': Operation not permitted
```

### Warum funktioniert GPU nicht?

1. **CUDA Library fehlt**: `libcuda.so.1` ist nicht im Container verfügbar
2. **NVIDIA Device Plugin**: Möglicherweise nicht installiert
3. **GPU-Ressourcen**: Nicht im Deployment angefordert
4. **Container-Image**: Jellyfin-Image enthält keine CUDA-Libraries

## Durchgeführte Lösung

### 1. Software-Transcoding aktiviert

**encoding.xml geändert**:
```xml
<!-- Vorher -->
<HardwareAccelerationType>nvenc</HardwareAccelerationType>
<EnableHardwareEncoding>true</EnableHardwareEncoding>

<!-- Nachher -->
<HardwareAccelerationType>none</HardwareAccelerationType>
<EnableHardwareEncoding>false</EnableHardwareEncoding>
```

### 2. Pod neu gestartet

- Konfiguration geladen
- FFmpeg kann jetzt ohne GPU arbeiten

## Aktueller Status

### ✅ Funktioniert jetzt:

- ✅ **Software-Transcoding**: FFmpeg nutzt CPU statt GPU
- ✅ **Wiedergabe sollte starten**: Keine GPU-Abhängigkeit mehr
- ✅ **FFmpeg läuft**: Version 7.1.2 gefunden und funktionsfähig

### ⚠️ Temporär:

- ⚠️ **Keine Hardware-Beschleunigung**: Langsamer als GPU-Transcoding
- ⚠️ **Mehr CPU-Last**: Transcoding belastet CPU stärker
- ⚠️ **Weniger parallele Streams**: Begrenzt durch CPU-Leistung (3-4 cores)

## Für später: GPU-Support reparieren

### Option 1: NVIDIA Device Plugin installieren

```bash
# Prüfe ob installiert
kubectl get daemonset -n kube-system | grep nvidia

# Installiere falls nicht vorhanden
kubectl apply -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.14.1/nvidia-device-plugin.yml
```

### Option 2: GPU-Ressourcen im Deployment anfordern

```yaml
resources:
  limits:
    nvidia.com/gpu: 1
  requests:
    nvidia.com/gpu: 1
```

### Option 3: CUDA-Libraries mounten

```yaml
volumeMounts:
- mountPath: /usr/local/cuda
  name: cuda-libs
volumes:
- name: cuda-libs
  hostPath:
    path: /usr/local/cuda
```

### Option 4: NVIDIA Container Runtime nutzen

Der Node muss mit `nvidia-container-runtime` konfiguriert sein.

## Testen

1. ✅ **Konfiguration geändert** - Software-Transcoding aktiviert
2. ✅ **Pod neu gestartet** - Änderungen geladen
3. ⚠️ **Wiedergabe testen**: Versuche jetzt einen Stream abzuspielen
4. ⚠️ **Logs prüfen**: Sollte keine CUDA-Fehler mehr zeigen

## Zusammenfassung

**Problem**: GPU-Hardware-Beschleunigung funktioniert nicht (CUDA fehlt)  
**Lösung**: Temporär auf Software-Transcoding umgestellt  
**Status**: ✅ Wiedergabe sollte jetzt funktionieren (langsamer, aber funktional)

**Nächste Schritte**:
1. Teste die Wiedergabe - sollte jetzt funktionieren
2. Für später: GPU-Support reparieren (NVIDIA Device Plugin, CUDA-Libraries)

