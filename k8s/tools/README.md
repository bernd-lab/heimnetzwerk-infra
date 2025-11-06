# Kubernetes Tools

Dieses Verzeichnis enthält verschiedene Tools und Hilfsskripte für den Kubernetes-Cluster.

## NFS-Installation Tools

**Aktuell verwendete Dateien:**
- `nfs-reload-exports.yaml` - Job zum Neuladen der NFS-Exports auf dem Server

**Veraltete/Test-Dateien:**
Die folgenden Dateien sind veraltet oder waren Test-Versuche und sollten nicht mehr verwendet werden:
- `nfs-apt-install.yaml`
- `nfs-daemonset-installer.yaml`
- `nfs-daemonset.yaml`
- `nfs-direct-install.yaml`
- `nfs-final-install.yaml`
- `nfs-host-install-final.yaml`
- `nfs-host-install-simple.yaml`
- `nfs-host-installer.yaml`
- `nfs-install-job.yaml`
- `nfs-installer-job.yaml`
- `nfs-shell-access.yaml`
- `nfs-shell-install.yaml`
- `nfs-simple-install.yaml`

**Hinweis:** NFS-Client-Tools sollten direkt auf dem Host-System installiert werden, nicht über Kubernetes Pods/Jobs.

