# Detaillierte Cluster-Analyse

**Datum**: 2025-11-06  
**Analysiert von**: System-Handover  
**Cluster-Version**: v1.34.1

## Cluster-Übersicht

### Nodes

| Node | IP | CPU | Memory | OS | Status |
|------|----|----|--------|----|--------|
| zuhause | 192.168.178.54 | 4 cores | ~32GB | Debian 12 | Ready (control-plane) |
| wsl2-ubuntu | 172.31.16.162 | 16 cores | ~58GB | Ubuntu 24.04 (WSL2) | Ready |

**Ressourcen-Verteilung**:
- **zuhause**: 2900m CPU (72%), 5372Mi Memory (16%) belegt
- **wsl2-ubuntu**: 2100m CPU (13%), 8242Mi Memory (14%) belegt

### Pod-Status Übersicht

- **Running**: 38 Pods
- **Completed**: 4 Pods (Init-Jobs)
- **Terminating**: 3 Pods (wird aufgeräumt)
- **Pending**: 1 Pod (Jellyfin)

**Gesamt**: 46 Pods

---

## Namespaces

### Aktive Namespaces (23)

- `argocd` - ArgoCD GitOps
- `cert-manager` - TLS-Zertifikate
- `default` - Standard-Namespace (Jellyfin, Jenkins, etc.)
- `gitlab` - GitLab CI/CD
- `gitlab-agent` - GitLab Agent
- `gitlab-runner` - GitLab Runner
- `heimdall` - Dashboard
- `ingress-nginx` - Ingress Controller
- `jellyfin` - Jellyfin Media Server (teilweise)
- `komga` - Komga Manga Server
- `kube-flannel` - CNI Plugin
- `kube-node-lease` - Node Leases
- `kube-public` - Public Config
- `kube-system` - System Components
- `kubernetes-dashboard` - Dashboard
- `logging` - Loki Logging
- `metallb-system` - LoadBalancer
- `monitoring` - Prometheus/Grafana
- `nfs` - NFS Namespace (leer)
- `pihole` - DNS/Ad-Blocker
- `syncthing` - File Sync
- `test-tls` - TLS Testing
- `velero` - Backup

---

## Services

### LoadBalancer Services

| Service | Namespace | External IP | Ports |
|---------|-----------|-------------|-------|
| ingress-nginx-controller | ingress-nginx | 192.168.178.54 | 80, 443 |
| pihole | pihole | 192.168.178.10 | 53, 80 |

### ClusterIP Services

- **ArgoCD**: 5 Services (application-controller, dex-server, redis, repo-server, server)
- **Cert-Manager**: 2 Services (cert-manager, webhook)
- **GitLab**: 5 Services (gitlab, postgresql, redis)
- **Monitoring**: 2 Services (grafana, prometheus)
- **Weitere**: Jenkins, Komga, Heimdall, Loki, Syncthing, etc.

**Gesamt**: 30+ Services

---

## Ingress

### Aktive Ingress-Ressourcen (13)

Alle Ingress-Ressourcen zeigen auf `192.168.178.54` (Ingress-Controller):

- `argocd.k8sops.online`
- `jenkins.k8sops.online`
- `gitlab.k8sops.online`
- `jellyfin.k8sops.online`
- `grafana.k8sops.online`
- `prometheus.k8sops.online`
- `komga.k8sops.online`
- `heimdall.k8sops.online`
- `syncthing.k8sops.online`
- `loki.k8sops.online`
- `dashboard.k8sops.online`
- `plantuml.k8sops.online`
- `test.k8sops.online`

**Ingress-Controller**: nginx (hostNetwork: true auf zuhause Node)

---

## Storage

### PersistentVolumes (25)

**NFS-basierte PVs**:
- 3 Jellyfin-PVs (jellyfin-filme, jellyfin-vertical, jellyfin-media-existing)
- 2 Komga-PVs (komga-media-elements, komga-media-wdblack)
- 2 Syncthing-PVs (syncthing-data, syncthing-wolke)
- 20+ dynamisch erstellte PVs via StorageClass `nfs-data`

**StorageClasses**:
- `nfs-data` (default) - Dynamische Provisionierung via NFS
- `nfs-elements` - Für Elements-Festplatte
- `nfs-wd-black` - Für WD-Black-Festplatte
- `manual` - Manuelle Provisionierung

### NFS-Server-Konfiguration

**Server**: 192.168.178.54 (zuhause Node)

**Exports** (`/etc/exports`):
```
/DATA 192.168.178.0/24(rw,sync,no_subtree_check,no_root_squash)
/media/devmon/Elements 192.168.178.0/24(rw,sync,no_subtree_check,no_root_squash)
/media/devmon/WD-Black_8TB 192.168.178.0/24(rw,sync,no_subtree_check,no_root_squash)
```

**Problem**: WSL2-Node (172.31.16.162) ist nicht im erlaubten Subnetz!

---

## Netzwerk

### DNS-Konfiguration

**CoreDNS**:
- 2 Pods (Running auf zuhause)
- Forward-Konfiguration: `192.168.178.10 8.8.8.8` (Pi-hole als primärer DNS)
- Cache: 30 Sekunden

**Pi-hole**:
- 1 Pod (Running auf zuhause)
- LoadBalancer IP: `192.168.178.10`
- Ports: 53 (TCP/UDP), 80

### Ingress-Controller

- **Namespace**: ingress-nginx
- **Pod**: `ingress-nginx-controller-68c56f854d-gqw6f`
- **Node**: zuhause
- **Host Network**: true (bindet direkt an 192.168.178.54)
- **LoadBalancer IP**: 192.168.178.54

### Network Policies

- `gitlab-postgresql` (gitlab Namespace)
- `gitlab-redis` (gitlab Namespace)

---

## Ressourcen-Verteilung

### Node zuhause (Debian-Server)

**Allokiert**:
- CPU: 2900m (72% von 4000m)
- Memory: 5372Mi (16% von ~32GB)
- Limits: 5 CPU (125%), 8532Mi Memory (26%)

**Services**:
- Pi-hole, Jenkins, Ingress, GitLab, CoreDNS, etc.

### Node wsl2-ubuntu (WSL2)

**Allokiert**:
- CPU: 2100m (13% von 16000m)
- Memory: 8242Mi (14% von ~58GB)
- Limits: 8 CPU (50%), 16Gi Memory (28%)

**Services**:
- Jellyfin (Pending - kann nicht starten)

### PriorityClasses

- `jellyfin-high-priority`: 1000000 (für Jellyfin)
- `system-cluster-critical`: 2000000000
- `system-node-critical`: 2000001000

---

## Bekannte Probleme

### 1. Jellyfin NFS-Mount-Fehler

**Pod**: `jellyfin-6ccf8fbcb7-gmpk9` (Pending)

**Details**:
- Deployment im `default` Namespace
- Node: wsl2-ubuntu
- Volumes können nicht gemountet werden
- WSL2-IP (172.31.16.162) nicht in NFS-Exports erlaubt

### 2. ServiceAccount-Fehler

**Betroffene Namespaces**:
- argocd: 5 fehlende ServiceAccounts
- velero: 1 fehlender ServiceAccount
- gitlab-runner: 1 fehlender ServiceAccount

**Auswirkung**: Pods können nicht erstellt werden

### 3. Namespace-Inkonsistenz

- Jellyfin-Service/Ingress im `jellyfin` Namespace
- Jellyfin-Deployment im `default` Namespace
- PVCs im `default` Namespace

---

## Funktionierende Services

### ✅ Laufen stabil

- **Pi-hole**: DNS/Ad-Blocking (192.168.178.10)
- **Jenkins**: CI/CD
- **GitLab**: Code-Repository (inkl. PostgreSQL, Redis)
- **ArgoCD**: GitOps (teilweise - ServiceAccount-Probleme)
- **Ingress-Controller**: Routing (192.168.178.54)
- **CoreDNS**: Cluster-DNS
- **Monitoring**: Prometheus, Grafana
- **Logging**: Loki
- **Komga**: Manga-Server
- **Heimdall**: Dashboard
- **Syncthing**: File-Sync

---

## Konfigurationen

### Wichtige Dateien

- `k8s/jellyfin/deployment.yaml` - Jellyfin Deployment
- `k8s/jellyfin/service.yaml` - Jellyfin Service (jellyfin Namespace)
- `k8s/jellyfin/ingress.yaml` - Jellyfin Ingress (jellyfin Namespace)
- `k8s/jellyfin/namespace.yaml` - Jellyfin Namespace
- `k8s/jellyfin/priorityclass.yaml` - PriorityClass für Jellyfin

### NFS-Konfiguration

- Server: `/etc/exports` auf zuhause Node (192.168.178.54)
- Client: `nfs-common` installiert auf WSL2-Host

---

## Empfehlungen

1. **NFS-Exports erweitern** für WSL2-Zugriff
2. **ServiceAccounts erstellen** für ArgoCD, Velero, GitLab-Runner
3. **Namespace-Konsistenz** für Jellyfin herstellen
4. **WSL2-Disk-Warnungen** untersuchen

---

## Nächste Schritte

Siehe `PROBLEME.md` für priorisierte Problem-Liste und `HANDOVER.md` für Aktionsplan.

