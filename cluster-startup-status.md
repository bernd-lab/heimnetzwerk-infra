# Cluster Startup Status

**Datum**: 2025-11-06  
**Gesamt-Status**: ⚠️ **Fast alle Services laufen, Jellyfin hat NFS-Problem**

## ✅ Erfolgreich gestartete Services

### Kritische Infrastruktur
- ✅ **Pi-hole**: Running auf `zuhause` (192.168.178.10)
- ✅ **CoreDNS**: Running (2 Pods)
- ✅ **Ingress-Controller**: Running auf `zuhause` (hostNetwork: true)

### Haupt-Services
- ✅ **Jenkins**: Running auf `zuhause`
- ✅ **GitLab**: Running auf `zuhause` (inkl. PostgreSQL & Redis)
- ✅ **ArgoCD**: Running
- ✅ **Heimdall**: Running

**Status**: 40 von 42 Pods laufen erfolgreich (95%)

## ⚠️ Jellyfin - NFS-Mount-Problem

### Problem
Jellyfin kann nicht starten, weil der WSL2-Node keine NFS-Client-Tools installiert hat.

**Fehler**:
```
MountVolume.SetUp failed for volume "jellyfin-filme" : mount failed: exit status 32
mount: bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program.
```

**Betroffene Volumes**:
- `jellyfin-config` (PVC)
- `jellyfin-filme` (NFS: /media/devmon/WD-Black_8TB)
- `jellyfin-vertical` (NFS: /media/devmon/Elements)
- `jellyfin-media` (NFS: /DATA/Media)

### Lösungsoptionen

#### Option 1: NFS-Client auf WSL2 installieren (empfohlen)
```bash
# Auf WSL2-Node ausführen
sudo apt-get update
sudo apt-get install -y nfs-common
```

#### Option 2: Jellyfin zurück auf "zuhause" verschieben
- Entferne `nodeSelector` und `tolerations` aus `k8s/jellyfin/deployment.yaml`
- Jellyfin läuft dann auf dem Debian-Server, der NFS-Tools hat
- **Nachteil**: Weniger CPU-Ressourcen verfügbar

#### Option 3: NFS-Volumes durch andere Storage-Lösung ersetzen
- Nicht empfohlen, da NFS bereits konfiguriert ist

## Aktuelle Ressourcen-Verteilung

### Node "zuhause" (Debian-Server)
- **CPU**: 72% belegt (2900m von 4000m)
- **Services**: Pi-hole, Jenkins, Ingress, GitLab, etc.
- **Status**: ✅ Alle Services laufen

### Node "wsl2-ubuntu"
- **CPU**: 38% belegt (6100m von 16000m)
- **Services**: Jellyfin (kann nicht starten wegen NFS)
- **Status**: ⚠️ Jellyfin wartet auf NFS-Client-Tools

## Empfehlung

**Sofort-Lösung**: NFS-Client auf WSL2 installieren
```bash
# Auf WSL2-Node (wsl2-ubuntu) ausführen:
sudo apt-get update && sudo apt-get install -y nfs-common
```

**Alternative**: Jellyfin zurück auf "zuhause" verschieben (dann mit reduzierten CPU-Requests)

## Nächste Schritte

1. ⏳ NFS-Client auf WSL2 installieren
2. ⏳ Jellyfin sollte dann automatisch starten
3. ⏳ Verifizieren, dass alle Volumes gemountet sind

