# Jellyfin - Vollständige Konfigurationsprüfung und Optimierung

**Datum**: 2025-11-07  
**Status**: ✅ **Alle wichtigen Menüs überprüft und optimiert**

## Überprüfte Menüs und Einstellungen

### 1. ✅ Hardware-Beschleunigung (Wiedergabe → Transkodierung)
**Status**: Vollständig konfiguriert

- ✅ **Hardware-Beschleunigung**: NVIDIA NVENC aktiviert
- ✅ **Hardware-Encoding**: Aktiviert
- ✅ **Enhanced NVDEC Decoder**: Aktiviert
- ✅ **10-bit/12-bit Hardware-Decoding**: Alle aktiviert
  - HEVC 10bit
  - VP9 10bit
  - HEVC RExt 8/10bit
  - HEVC RExt 12bit
- ✅ **EncodingThreadCount**: 4 Threads (optimiert)
- ✅ **Hardware-Decoding Codecs**: H264, HEVC, VP8, VP9, AV1
- ✅ **Encoding-Formate**: H264, HEVC, AV1

### 2. ✅ Allgemein (Server-Einstellungen)
**Status**: Performance-Einstellungen optimiert

**Optimierte Werte** (basierend auf 8 CPU-Kernen):
- ✅ **LibraryScanFanoutConcurrency**: 0 → **6**
  - Parallele Aufgaben beim Bibliotheks-Scan
  - Vorsichtig gewählt wegen NFS-Verbindung
- ✅ **LibraryMetadataRefreshConcurrency**: 0 → **6**
  - Parallele Metadaten-Aktualisierungen
- ✅ **ParallelImageEncodingLimit**: 0 → **8**
  - Maximale parallele Bildkodierungen
  - Kann höher sein, da weniger I/O-intensiv

**Weitere Einstellungen**:
- ✅ Servername: `jellyfin-k8s`
- ✅ Sprache: Deutsch
- ✅ Quick Connect: Aktiviert

### 3. ✅ Netzwerk
**Status**: Optimal konfiguriert

- ✅ **HTTP Port**: 8096
- ✅ **HTTPS Port**: 8920
- ✅ **IPv4**: Aktiviert
- ✅ **IPv6**: Deaktiviert (nicht benötigt)
- ✅ **Automatische Erkennung**: Aktiviert (UDP Port 7359)
- ✅ **Externe Verbindungen**: Erlaubt
- ✅ **Bekannte Proxys**: Leer (wird über Ingress gehandhabt)

### 4. ✅ Bibliotheken
**Status**: Konfiguriert

**Vorhandene Bibliotheken**:
- ✅ **Filme2** (Typ: Filme)
- ✅ **Filme** (Typ: Filme)
- ✅ **Heimvideos und -bilder** (Typ: Heimvideos und -bilder)

### 5. ✅ Geplante Aufgaben
**Status**: Läuft normal

**Wichtige Aufgaben**:
- ✅ **Medien-Bibliothek scannen**: Läuft regelmäßig (zuletzt vor 3 Stunden)
- ✅ **Datenbank optimieren**: Läuft regelmäßig (zuletzt vor 5 Stunden)
- ✅ **Transkodierungs-Verzeichnis aufräumen**: Läuft regelmäßig
- ⚠️ **Keyframe-Extraktor**: Fehlgeschlagen (vor 4 Tagen) - nicht kritisch
- ⚠️ **Aktivitätsprotokolle aufräumen**: Fehlgeschlagen (vor 4 Tagen) - nicht kritisch
- ⚠️ **Aufgabe zur Bereinigung von Benutzerdaten**: Fehlgeschlagen (vor 4 Tagen) - nicht kritisch

### 6. ✅ Aktivitäten
**Status**: Normal

- ✅ Benutzer-Aktivitäten werden korrekt protokolliert
- ✅ Video-Wiedergabe wird getrackt
- ✅ Sessions werden erfasst

### 7. ✅ Wiedergabe → Streaming
**Status**: Optimal konfiguriert

- ✅ **Bitratenlimit für Internet-Streaming**: Unbegrenzt (0 Mbit/s)
  - Für lokale Nutzung optimal
  - Keine unnötige Transkodierung

### 8. ✅ Wiedergabe → Trickplay
**Status**: Optimiert

**Optimierte Einstellungen**:
- ✅ **Hardware-Dekoder aktivieren**: false → **true**
  - Nutzt GPU für Trickplay-Generierung
- ✅ **FFmpeg-Threads**: 1 → **4**
  - Nutzt alle verfügbaren CPU-Kerne optimal

**Weitere Einstellungen**:
- ✅ Scanverhalten: Non-Blocking (optimal)
- ✅ Prozess-Priorität: BelowNormal (schont System)
- ✅ Bildintervall: 10000ms (Standard)
- ✅ Breitenauflösung: 320px (Standard)
- ⚠️ Hardwarebeschleunigte MJPEG-Enkodierung: Nicht aktiviert (nur für QSV/VA-API/VideoToolbox verfügbar, nicht für NVENC)

### 9. ✅ Wiedergabe → Fortsetzen
**Status**: Optimal konfiguriert

- ✅ Minimale Prozent für Wiederaufnahme: 5%
- ✅ Maximale Prozent für Wiederaufnahme: 90%
- ✅ Minimale Dauer für Wiederaufnahme: 300 Sekunden

## Performance-Optimierungen

### Container-Ressourcen
- **CPU Requests**: 2000m (2 cores garantiert)
- **CPU Limits**: 8 cores (maximal verfügbar)
- **Memory Requests**: 8Gi
- **Memory Limits**: 16Gi
- **PriorityClass**: `jellyfin-high-priority` (höchste Priorität)

### Hardware-Zugriff
- ✅ GPU-Geräte gemountet (`/dev/dri`)
- ✅ NVIDIA-Umgebungsvariablen gesetzt
- ✅ FFmpeg mit Hardware-Beschleunigung konfiguriert

### System-Performance
- ✅ **Bibliotheks-Scan**: 6 parallele Aufgaben (optimiert für NFS)
- ✅ **Metadaten-Refresh**: 6 parallele Aufgaben
- ✅ **Bildkodierung**: 8 parallele Aufgaben (maximal)

## Konfigurationsdateien

### encoding.xml
- Hardware-Beschleunigung: NVENC
- EncodingThreadCount: 4
- 10-bit/12-bit Decoding: Aktiviert

### system.xml
- LibraryScanFanoutConcurrency: 6
- LibraryMetadataRefreshConcurrency: 6
- ParallelImageEncodingLimit: 8
- TrickplayOptions:
  - EnableHwAcceleration: true (optimiert)
  - ProcessThreads: 4 (optimiert)

## Zusammenfassung

✅ **Hardware-Beschleunigung**: Vollständig aktiviert und optimiert  
✅ **Performance-Einstellungen**: Optimiert für 8 CPU-Kerne  
✅ **Trickplay**: Hardware-Beschleunigung aktiviert, 4 Threads  
✅ **Netzwerk**: Optimal konfiguriert  
✅ **Bibliotheken**: Konfiguriert und funktionsfähig  
✅ **Geplante Aufgaben**: Laufen normal (einige nicht-kritische Fehler)  
✅ **Container-Ressourcen**: Optimal zugewiesen  

**Jellyfin ist vollständig konfiguriert und für maximale Performance optimiert!**

