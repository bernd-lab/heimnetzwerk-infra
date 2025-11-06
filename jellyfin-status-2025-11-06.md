# Jellyfin Status - 2025-11-06

**Datum**: 2025-11-06  
**Agent**: Jellyfin-Expert  
**Status**: ✅ Vollständig funktionsfähig

## Zusammenfassung

Jellyfin Media Server läuft erfolgreich in Kubernetes mit korrekt gemounteten Festplatten.

## Deployment-Status

- **Pod**: Running (1/1 Ready)
- **Service**: ClusterIP (10.111.39.176)
- **Ingress**: jellyfin.k8sops.online (192.168.178.54:80/443)
- **Image**: jellyfin/jellyfin:latest
- **Namespace**: default

## Volumes und Storage

### PersistentVolumes (NFS)
- ✅ `jellyfin-filme`: `/media/devmon/WD-Black_8TB` (500Gi, RWX) → Container: `/WD-Black`
- ✅ `jellyfin-vertical`: `/media/devmon/Elements` (100Gi, RWX) → Container: `/Elements`
- ✅ `jellyfin-media`: `/DATA/Media` (500Gi, RWX) → Container: `/Media`
- ✅ `jellyfin-config`: nfs-data StorageClass (10Gi, RWO) → Container: `/config`
- ✅ `jellyfin-data`: nfs-data StorageClass (20Gi, RWO) → Container: `/data`

### Externe Festplatten
- ✅ `/dev/sdc1` (WD-Black_8TB, 7.3TB, NTFS) → `/media/devmon/WD-Black_8TB` (gemountet)
- ✅ `/dev/sdd1` (Elements, 16.4TB, NTFS) → `/media/devmon/Elements` (gemountet)
- ✅ Automatisches Mount: `/etc/fstab` konfiguriert

## Mount-Pfade im Container

- `/WD-Black` → Gesamte WD-Black_8TB Festplatte
- `/Elements` → Gesamte Elements Festplatte
- `/Media` → /DATA/Media
- `/config` → Jellyfin-Konfiguration
- `/data` → Jellyfin-Daten

## Verfügbare Bibliotheken-Ordner

### Auf WD-Black_8TB (`/WD-Black`)
- ✅ `/WD-Black/Filme` - Filme-Ordner

### Auf Elements (`/Elements`)
- ✅ `/Elements/VerticalHeimatfilme` - Vertical/Heimatfilme
- ✅ `/Elements/Heimatfilme` - Heimatfilme
- ✅ `/Elements/JDownloader` - Anime/Downloads

## Konfiguration

### Umgebungsvariablen
- `PUID`: 1000
- `PGID`: 1000
- `TZ`: Europe/Berlin
- `JELLYFIN_FFmpeg_Path`: /usr/lib/jellyfin-ffmpeg/ffmpeg
- `NVIDIA_VISIBLE_DEVICES`: all
- `NVIDIA_DRIVER_CAPABILITIES`: compute,video,utility

### Ressourcen
- **Limits**: CPU 2000m, Memory 2Gi
- **Requests**: CPU 500m, Memory 512Mi

### Hardware-Beschleunigung
- `/dev/dri` gemountet (GPU-Zugriff)

## Erreichbarkeit

- **URL**: https://jellyfin.k8sops.online
- **Ingress**: nginx (80, 443)
- **Status**: ✅ Erreichbar

## Nächste Schritte

1. **Bibliotheken in Jellyfin konfigurieren**:
   - `/WD-Black/Filme` als Filme-Bibliothek
   - `/Elements/VerticalHeimatfilme` als weitere Bibliothek
   - `/Elements/Heimatfilme` als weitere Bibliothek
   - `/Elements/JDownloader` als Anime-Bibliothek

2. **Medien-Scans durchführen**
3. **Metadaten aktualisieren**

## Durchgeführte Fixes

1. ✅ Festplatten lokal gemountet (`/dev/sdc1` → WD-Black_8TB, `/dev/sdd1` → Elements)
2. ✅ Automatisches Mount in `/etc/fstab` eingerichtet
3. ✅ PVs auf Root-Pfade geändert (statt Unterverzeichnisse)
4. ✅ Mount-Pfade im Container angepasst (`/WD-Black`, `/Elements`)
5. ✅ Deployment bereinigt (unnötige Volumes entfernt)

