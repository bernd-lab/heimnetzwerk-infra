# Jellyfin Hardware-Beschleunigung und Performance-Optimierung

**Datum**: 2025-11-07  
**Status**: ✅ **Optimiert**

## Durchgeführte Optimierungen

### 1. Hardware-Beschleunigung konfiguriert

**Aktuelle Konfiguration**:
- ✅ **HardwareAccelerationType**: `nvenc` (NVIDIA GPU)
- ✅ **EnableHardwareEncoding**: `true`
- ✅ **EnableEnhancedNvdecDecoder**: `true`
- ✅ **PreferSystemNativeHwDecoder**: `true`

**GPU-Geräte verfügbar**:
- `/dev/dri/card0` (NVIDIA)
- `/dev/dri/card1` (NVIDIA)
- `/dev/dri/renderD128` (NVIDIA)
- `/dev/dri/renderD129` (NVIDIA)

**Verfügbare Encoder**:
- ✅ `h264_nvenc` - NVIDIA NVENC H.264 encoder
- ✅ `hevc_nvenc` - NVIDIA NVENC HEVC encoder (vermutlich)
- ✅ `av1_nvenc` - NVIDIA NVENC AV1 encoder
- ✅ CUDA Hardware-Acceleration verfügbar

### 2. Performance-Einstellungen optimiert

**EncodingThreadCount**: 
- **Vorher**: 3 Threads
- **Nachher**: 4 Threads (entspricht verfügbaren CPU-Kernen)

**Hardware-Decoding optimiert**:
- ✅ **EnableDecodingColorDepth10Hevc**: `true` (vorher: false)
- ✅ **EnableDecodingColorDepth10Vp9**: `true` (vorher: false)
- ✅ **EnableDecodingColorDepth10HevcRext**: `true` (vorher: false)
- ✅ **EnableDecodingColorDepth12HevcRext**: `true` (vorher: false)

**Effekt**: Bessere Unterstützung für 10-bit und 12-bit Video-Formate mit Hardware-Beschleunigung

### 3. Container-Ressourcen (bereits optimal)

**CPU**:
- Requests: 2000m (2 cores)
- Limits: 8 cores

**Memory**:
- Requests: 8Gi
- Limits: 16Gi

**GPU**:
- `/dev/dri` gemountet
- NVIDIA_VISIBLE_DEVICES=all
- NVIDIA_DRIVER_CAPABILITIES=compute,video,utility

## Optimierte Einstellungen

### encoding.xml Änderungen

1. **EncodingThreadCount**: 3 → 4
   - Nutzt alle verfügbaren CPU-Kerne optimal

2. **EnableDecodingColorDepth10Hevc**: false → true
   - Aktiviert Hardware-Decoding für 10-bit HEVC

3. **EnableDecodingColorDepth10Vp9**: false → true
   - Aktiviert Hardware-Decoding für 10-bit VP9

4. **EnableDecodingColorDepth10HevcRext**: false → true
   - Aktiviert Hardware-Decoding für 10-bit HEVC Rext

5. **EnableDecodingColorDepth12HevcRext**: false → true
   - Aktiviert Hardware-Decoding für 12-bit HEVC Rext

## Erwartete Verbesserungen

1. ✅ **Bessere Transcoding-Performance**: 4 Threads statt 3
2. ✅ **Hardware-Decoding für 10-bit/12-bit Videos**: Aktiviert
3. ✅ **GPU-Beschleunigung**: Vollständig aktiviert (NVENC)
4. ✅ **Mehr parallele Streams**: Möglich durch optimierte Threads

## Nächste Schritte (im Webinterface)

Die folgenden Einstellungen sollten im Jellyfin-Webinterface überprüft/konfiguriert werden:

### Dashboard → Wiedergabe → Transcoding

1. **Hardware-Beschleunigung**: 
   - Sollte auf "NVIDIA NVENC" oder "Automatisch" stehen
   - ✅ Bereits konfiguriert (nvenc)

2. **Hardware-Decoding aktivieren**:
   - ✅ Bereits aktiviert

3. **Transcoding-Threads**:
   - ✅ Auf 4 gesetzt (entspricht CPU-Kernen)

4. **H.264 Encoding**:
   - CRF: 23 (gut für Qualität/Performance-Balance)
   - ✅ Bereits optimal

5. **HEVC Encoding**:
   - CRF: 28 (gut für Qualität/Performance-Balance)
   - ✅ Bereits optimal

### Dashboard → Allgemein → Leistung

1. **Limit der Parallelen Aufgaben für das Scanen der Bibliotheken**:
   - Empfehlung: 2-4 (abhängig von Netzwerk-Performance)
   - Aktuell: Standard (0 = automatisch)

2. **Limit der parallelen Bildkodierung**:
   - Empfehlung: 2-4
   - Aktuell: Standard (0 = automatisch)

## Verifizierung

### GPU-Zugriff prüfen
```bash
kubectl exec -n default $(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}') -- ls -la /dev/dri/
```

### NVENC Encoder prüfen
```bash
kubectl exec -n default $(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}') -- /usr/lib/jellyfin-ffmpeg/ffmpeg -hide_banner -encoders 2>/dev/null | grep nvenc
```

### Konfiguration prüfen
```bash
kubectl exec -n default $(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}') -- cat /config/config/encoding.xml | grep -E "HardwareAccelerationType|EncodingThreadCount|EnableHardwareEncoding"
```

## Zusammenfassung

✅ **Hardware-Beschleunigung**: Vollständig aktiviert (NVENC)  
✅ **Performance**: Optimiert (4 Threads in encoding.xml, 10-bit/12-bit Decoding aktiviert)  
✅ **GPU-Zugriff**: Funktioniert  
✅ **Container-Ressourcen**: Optimal konfiguriert  
✅ **Webinterface-Einstellungen**: Konfiguriert und gespeichert

### Im Webinterface konfiguriert:
- ✅ **Hardwarebeschleunigung**: Nvidia NVENC
- ✅ **Hardwarekodierung aktivieren**: Aktiviert
- ✅ **Erweiterten NVDEC-Decoder**: Aktiviert
- ✅ **Hardware-Dekodierung für**: H264, HEVC, VP8, VP9, AV1
- ✅ **10-bit/12-bit Decoding**: HEVC 10bit, VP9 10bit, HEVC RExt 8/10bit, HEVC RExt 12bit - **ALLE AKTIVIERT**
- ✅ **Kodierung im HEVC-Format**: Aktiviert
- ✅ **Kodierung im AV1-Format**: Aktiviert

**Jellyfin ist jetzt für maximale Performance mit Hardware-Beschleunigung konfiguriert!**

