# NFS-Tools Installation auf WSL2-Node

**Problem**: Jellyfin kann nicht starten, weil der WSL2-Node keine NFS-Client-Tools hat.

## Lösung

Die NFS-Tools müssen direkt auf dem WSL2-Host-System installiert werden. Da wir keinen direkten SSH-Zugriff haben, gibt es zwei Optionen:

### Option 1: Manuelle Installation (Empfohlen)

**Auf dem WSL2-System ausführen** (nicht im Container):

```bash
# Auf WSL2-Node (wsl2-ubuntu) direkt:
sudo apt-get update
sudo apt-get install -y nfs-common

# Verifizierung:
which mount.nfs
ls -la /sbin/mount.nfs
```

### Option 2: DaemonSet (Automatisch)

Ich habe einen DaemonSet erstellt (`k8s/tools/nfs-daemonset-installer.yaml`), der die Tools installiert. Allerdings muss dieser auf dem Host-System installieren, was schwierig ist.

**Besser**: Direkt auf dem WSL2-System installieren.

## Verifizierung

Nach der Installation sollte Jellyfin automatisch starten können:

```bash
kubectl get pods -l app=jellyfin
kubectl describe pod -l app=jellyfin | grep -i mount
```

Die Fehlermeldung "bad option; for several filesystems (e.g. nfs, cifs) you might need a /sbin/mount.<type> helper program" sollte verschwinden.

## Nächste Schritte

1. NFS-Tools auf WSL2-Node installieren (Option 1)
2. Jellyfin Pod neu starten (wird automatisch neu erstellt)
3. Verifizieren, dass alle Volumes gemountet sind

