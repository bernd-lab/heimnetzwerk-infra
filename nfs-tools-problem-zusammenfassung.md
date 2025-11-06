# NFS-Tools Problem - Zusammenfassung

**Datum**: 2025-11-06  
**Problem**: Jellyfin kann nicht starten, weil WSL2-Node keine NFS-Client-Tools hat  
**Status**: ⚠️ **Benötigt manuelle Installation auf WSL2-Host**

## Problem

Jellyfin Pod auf WSL2-Node kann NFS-Volumes nicht mounten:

```
mount: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
```

**Root Cause**: Der WSL2-Node hat `nfs-common` nicht installiert.

## Lösungsoptionen

### Option 1: NFS-Tools auf WSL2 installieren (Empfohlen)

**Auf dem WSL2-System direkt ausführen** (nicht über Kubernetes):

```bash
# Auf WSL2-Node (wsl2-ubuntu) direkt:
sudo apt-get update
sudo apt-get install -y nfs-common

# Verifizierung:
which mount.nfs
ls -la /sbin/mount.nfs
```

**Nach Installation**: Jellyfin Pod wird automatisch neu erstellt und sollte starten können.

### Option 2: Jellyfin zurück auf "zuhause" verschieben

Da der "zuhause" Node bereits NFS-Tools hat, kann Jellyfin dorthin verschoben werden:

**In `k8s/jellyfin/deployment.yaml`**:
- `nodeSelector` und `tolerations` entfernen
- CPU-Requests eventuell reduzieren (z.B. auf 2000m)

**Vorteil**: Funktioniert sofort  
**Nachteil**: Weniger CPU-Ressourcen verfügbar

## Versuchte Lösungen

1. ✅ **Job erstellt**: `nfs-installer` - lief im Container, installierte Tools nicht auf Host
2. ✅ **Pod mit hostNetwork**: `nfs-host-installer` - konnte Logs nicht abrufen, Installation unklar
3. ✅ **DaemonSet vorbereitet**: `nfs-daemonset-installer.yaml` - benötigt aber auch Host-Zugriff

## Empfehlung

**Sofort-Lösung**: Option 1 - NFS-Tools direkt auf WSL2 installieren

**Langfristig**: 
- DaemonSet erstellen, der Tools auf allen Nodes installiert
- Oder: Jellyfin auf "zuhause" Node lassen (stabiler, aber weniger Performance)

## Nächste Schritte

1. ⏳ NFS-Tools auf WSL2-Node installieren (manuell)
2. ⏳ Jellyfin Pod Status prüfen (sollte automatisch starten)
3. ⏳ Verifizieren, dass alle Volumes gemountet sind

