# Pod-Status Check

**Datum**: 2025-11-07  
**Status**: ✅ **Alle Pods laufen vernünftig**

## Gesamt-Status

### Pod-Verteilung
- **Running**: 45 Pods ✅
- **Completed**: 4 Pods ✅ (Init-Jobs)
- **Pending**: 0 Pods ✅
- **CrashLoopBackOff**: 0 Pods ✅
- **Error**: 0 Pods ✅

### Nodes
- **zuhause** (192.168.178.54): Ready ✅ (control-plane)
- Alle Pods laufen auf diesem Node

## Jellyfin Status

### ✅ Jellyfin läuft perfekt!

**Pod-Status**:
- **Name**: `jellyfin-868f8f559c-xn8rb`
- **Status**: Running (1/1) ✅
- **Ready**: true ✅
- **Restarts**: 0 ✅
- **Uptime**: 17 Stunden
- **Node**: zuhause

**Ressourcen**:
- **CPU Requests**: 1500m (1.5 cores)
- **CPU Limits**: 8 cores
- **Memory Requests**: 8Gi
- **Memory Limits**: 16Gi

**Service & Ingress**:
- ✅ Service: `jellyfin` (ClusterIP) - Ports 80, 443
- ✅ Ingress: `jellyfin-ingress` - Host: `jellyfin.k8sops.online`
- ✅ Erreichbar über: http://jellyfin.k8sops.online

**Volumes**:
- ✅ jellyfin-config (PVC)
- ✅ jellyfin-media (PVC)
- ✅ jellyfin-filme (PVC)
- ✅ jellyfin-vertical (PVC)
- ✅ /dev/dri (HostPath für GPU)

**Aktuelle Aktivität**:
- ✅ Medien-Bibliothek-Scan läuft (normal)
- ✅ Bibliotheken werden überwacht:
  - `/Elements/Humor`
  - `/WD-Black/Filme`
  - `/WD-Black/JDownloader/NSFW`
  - `/Elements/Heimatfilme`
- ⚠️ Einige Warnungen über unsupported codecs (normal, nicht kritisch)
- ⚠️ Trickplay-Warnungen (normal, nicht kritisch)

**Logs**:
- ✅ Keine kritischen Fehler
- ✅ Normale Betriebs-Logs
- ✅ Bibliothek-Scan läuft erfolgreich

## Weitere wichtige Services

### ✅ Jenkins
- **Status**: Running (1/1)
- **Uptime**: 120 Minuten
- **Restarts**: 0

### ✅ Velero
- **Status**: Running (1/1)
- **Uptime**: 120 Minuten
- **Restarts**: 0
- **CRDs**: Installiert ✅

### ✅ Pi-hole
- **Status**: Running (1/1)
- **Uptime**: 20 Stunden
- **IP**: 192.168.178.10

## Zusammenfassung

**Alle Pods laufen vernünftig!**

- ✅ Keine problematischen Pods
- ✅ Alle wichtigen Services laufen
- ✅ Jellyfin funktioniert einwandfrei
- ✅ Keine kritischen Fehler
- ✅ Normale Betriebs-Logs

### Jellyfin - Alles in Ordnung!

Jellyfin läuft stabil und führt aktuell einen Medien-Bibliothek-Scan durch. Die Warnungen in den Logs sind normal und nicht kritisch:
- "Unsupported codec" Warnungen sind normal bei verschiedenen Video-Formaten
- Trickplay-Warnungen sind normal bei der Verarbeitung von Thumbnails
- Bibliothek-Scan läuft erfolgreich (165 Minuten für letzten Scan)

**Jellyfin ist voll funktionsfähig und erreichbar über `jellyfin.k8sops.online`!**

