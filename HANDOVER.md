# Kubernetes-Cluster Handover Dokumentation

**Datum**: 2025-11-06  
**Erstellt von**: System-Handover  
**Status**: Vollständiger Handover für nächsten Agenten

---

## Executive Summary

### Cluster-Status
- **Nodes**: 2 (1 Ready, 1 NotReady)
- **Kubernetes Version**: v1.34.1 (beide Nodes)
- **Pods**: 51 total (48 Running, 3 Pending)
- **Namespaces**: 23 aktiv
- **Services**: 30+ (2 LoadBalancer)
- **Ingress**: 13 aktive Ingress-Ressourcen
- **Storage**: 24 PVCs, 24 PVs (NFS-basiert)

### Kritische Probleme
1. **WSL2-Node NotReady** - Kubelet-Fehler: "system validation failed" (P0)
2. **3 Pods Pending** - Jenkins (2x), Velero (1x) - CPU-Ressourcen-Mangel (P1)

### Funktionierende Services
✅ Pi-hole, ArgoCD, GitLab, Ingress-nginx, CoreDNS, Monitoring, Logging, Komga, Heimdall, Syncthing, Cert-Manager

---

## Cluster-Architektur

### Nodes

| Node | IP | Status | Role | OS | Kubernetes | Container Runtime |
|------|----|----|-----|----|----|----|
| zuhause | 192.168.178.54 | Ready | control-plane | Debian 12 | v1.34.1 | containerd 1.6.20 |
| wsl2-ubuntu | 172.31.16.162 | NotReady | worker | Ubuntu 24.04 WSL2 | v1.34.1 | containerd 1.7.28 |

**Wichtig**: WSL2-Node ist aktuell nicht funktionsfähig. Alle Pods laufen auf `zuhause` Node.

### Netzwerk

- **Pod Network**: 10.244.0.0/16 (Flannel CNI)
- **Service Network**: 10.100.0.0/16
- **Control Plane**: https://192.168.178.54:6443
- **CNI**: Flannel (2 DaemonSet Pods)

### Storage

**StorageClasses**:
- `nfs-data` (default) - Dynamische Provisionierung auf `/DATA`
- `nfs-elements` - Für `/media/devmon/Elements`
- `nfs-wd-black` - Für `/media/devmon/WD-Black_8TB`
- `manual` - Manuelle Provisionierung

**NFS-Server** (auf zuhause Node):
- Server: 192.168.178.54
- Exports: `/DATA`, `/media/devmon/Elements`, `/media/devmon/WD-Black_8TB`
- Erlaubte Subnetze: `192.168.178.0/24`, `172.31.16.0/20` (WSL2-Subnetz hinzugefügt)

**PVCs/PVs**: 24 PVCs mit 24 zugehörigen PVs (alle NFS-basiert)

---

## Services und Namespaces

### LoadBalancer Services

| Service | Namespace | External IP | Ports | Status |
|---------|-----------|-------------|-------|--------|
| ingress-nginx-controller | ingress-nginx | 192.168.178.54 | 80, 443 | ✅ Running |
| pihole | pihole | 192.168.178.10 | 53, 80 | ✅ Running |

### Ingress-Ressourcen (13)

Alle Services sind über `*.k8sops.online` erreichbar:

| Namespace | Service | Host | TLS |
|-----------|--------|------|-----|
| argocd | ArgoCD | argocd.k8sops.online | ✅ |
| default | Jellyfin | jellyfin.k8sops.online | ✅ |
| default | Jenkins | jenkins.k8sops.online | ✅ |
| default | PlantUML | plantuml.k8sops.online | ✅ |
| gitlab | GitLab | gitlab.k8sops.online | ✅ |
| heimdall | Heimdall | heimdall.k8sops.online | ✅ |
| komga | Komga | komga.k8sops.online | ✅ |
| logging | Loki | loki.k8sops.online | ✅ |
| monitoring | Grafana | grafana.k8sops.online | ✅ |
| monitoring | Prometheus | prometheus.k8sops.online | ✅ |
| syncthing | Syncthing | syncthing.k8sops.online | ✅ |
| kubernetes-dashboard | Dashboard | dashboard.k8sops.online | ✅ |
| test-tls | Test | test.k8sops.online | ✅ |

### Namespaces (23)

| Namespace | Pods | Zweck | Status |
|-----------|------|-------|--------|
| argocd | 7 | GitOps Deployment | ✅ Running |
| cert-manager | 3 | TLS-Zertifikate | ✅ Running |
| default | 8 | Standard-Services | ⚠️ 2 Pending |
| gitlab | 3 | GitLab CI/CD | ✅ Running |
| gitlab-agent | 1 | GitLab Agent | ✅ Running |
| gitlab-runner | 1 | GitLab Runner | ✅ Running |
| heimdall | 1 | Dashboard | ✅ Running |
| ingress-nginx | 3 | Ingress Controller | ✅ Running |
| komga | 1 | Manga-Server | ✅ Running |
| kube-flannel | 2 | CNI Plugin | ✅ Running |
| kube-system | 8 | System Components | ✅ Running |
| kubernetes-dashboard | 1 | Dashboard | ✅ Running |
| logging | 1 | Loki Logging | ✅ Running |
| metallb-system | 2 | LoadBalancer | ✅ Running |
| monitoring | 3 | Prometheus/Grafana | ✅ Running |
| pihole | 1 | DNS/Ad-Blocker | ✅ Running |
| syncthing | 1 | File-Sync | ✅ Running |
| test-tls | 1 | TLS Testing | ✅ Running |
| velero | 3 | Backup | ⚠️ 1 Pending |

---

## Kritische Probleme

### 1. WSL2-Node NotReady (P0 - Kritisch)

**Problem**:
- Node `wsl2-ubuntu` ist im Status `NotReady`
- Kubelet-Fehler: "system validation failed - wrong number of fields (expected 6, got 7)"
- Ursache: Kubernetes v1.34.1 Inkompatibilität mit WSL2/cgroup2

**Auswirkung**:
- WSL2-Node kann keine Pods schedulen
- Alle Pods laufen auf `zuhause` Node
- CPU-Ressourcen-Mangel auf `zuhause` Node

**Lösungsansätze**:
1. **Kubernetes Downgrade** (empfohlen): Auf v1.31.5 downgraden
   - Siehe: `kubernetes-downgrade-feinkonzept.md` (wird erstellt)
2. **WSL2 cgroup v1**: WSL2 auf cgroup v1 umstellen (komplex)
3. **Warten auf Kubernetes-Fix**: Für WSL2/cgroup2 Kompatibilität

**Status**: Wartet auf Implementierung

### 2. Pods Pending - CPU-Ressourcen-Mangel (P1)

**Betroffene Pods**:
- `default/jenkins-6c5c5687f4-z77hf`: Pending
- `default/jenkins-7fb5d89ddf-2rqxf`: Pending
- `velero/velero-7c697f8956-ffphp`: Pending

**Ursache**:
- Alle Pods laufen auf `zuhause` Node (4 CPU)
- CPU-Requests übersteigen verfügbare Ressourcen
- WSL2-Node ist nicht verfügbar

**Lösung**:
- WSL2-Node reparieren (siehe Problem 1)
- Oder: CPU-Requests reduzieren für weniger kritische Services
- Oder: Services auf WSL2-Node verschieben (sobald Ready)

---

## Wichtige Konfigurationen

### DNS

**CoreDNS**:
- Forward an Pi-hole (192.168.178.10) und 8.8.8.8
- Cache: 30 Sekunden
- Service Discovery: cluster.local

**Pi-hole**:
- LoadBalancer IP: 192.168.178.10
- Ports: 53 (TCP/UDP), 80
- Status: ✅ Running

### Ingress-Controller

- **Controller**: nginx-ingress
- **Namespace**: ingress-nginx
- **LoadBalancer IP**: 192.168.178.54
- **Host Network**: true (bindet direkt an Host-IP)
- **ConfigMap**: `allow-snippet-annotations: false` (Sicherheit)

### MetalLB

- **IP-Pool**: `default-pool`
- **Adressen**: `192.168.178.54/32`, `192.168.178.10/32`
- **L2 Advertisement**: aktiviert

### Cert-Manager

- **ClusterIssuer**: `letsencrypt-prod-dns01`
- **Challenge**: DNS01 mit Cloudflare
- **API Token**: Secret `cloudflare-api-token` in `cert-manager` Namespace
- **Status**: ✅ Ready

---

## Bekannte Konfigurationen

### Jellyfin

- **Namespace**: `default` (Deployment), `jellyfin` (Service/Ingress) - **Inkonsistent**
- **PVCs**: Im `default` Namespace
- **Status**: Deployment läuft, aber Service/Ingress im anderen Namespace
- **PriorityClass**: `jellyfin-high-priority` (1000000)

### GitLab

- **Namespace**: `gitlab`
- **Ingress**: `gitlab.k8sops.online`
- **TLS**: Cert-Manager Zertifikat
- **Liveness-Probe**: Verwendet `exec` mit `curl` (nicht `httpGet`)
- **Status**: ✅ Running stabil

### ArgoCD

- **Namespace**: `argocd`
- **Ingress**: `argocd.k8sops.online`
- **TLS**: Cert-Manager Zertifikat
- **Status**: ✅ Running (7 Pods)

---

## Wichtige Dateien

### Kubernetes-Manifeste

- `k8s/` - Alle Kubernetes-Manifeste
- `k8s/jellyfin/` - Jellyfin-Konfiguration
- `k8s/pihole/` - Pi-hole-Konfiguration
- `k8s/tools/` - Utility-Jobs und Tools

### Dokumentation

- `CLUSTER-ANALYSE.md` - Detaillierte Cluster-Analyse
- `PROBLEME.md` - Priorisierte Problem-Liste
- `kubernetes-analyse.md` - Kubernetes-Konfiguration
- `docker-kubernetes-migration.md` - Migrationsplan

### Scripts

- `scripts/deploy-pihole.sh` - Pi-hole Deployment
- `scripts/load-secrets.sh` - Secrets laden

---

## Nächste Schritte

### Sofort (P0)

1. **WSL2-Node reparieren**:
   - Kubernetes Downgrade auf v1.31.5 durchführen
   - Oder: Alternative Lösung für cgroup2-Problem finden

### Bald (P1)

2. **Pending Pods beheben**:
   - CPU-Ressourcen optimieren
   - Oder: WSL2-Node reparieren und Pods dorthin verschieben

3. **Namespace-Konsistenz**:
   - Jellyfin komplett in `jellyfin` Namespace verschieben
   - Oder: Alles zurück in `default` Namespace

### Später (P2)

4. **Monitoring verbessern**:
   - Metrics-Server installieren (fehlt aktuell)
   - Ressourcen-Monitoring erweitern

5. **Backup-Strategie**:
   - Velero-Backups verifizieren
   - Automatische Backups einrichten

---

## Zugriff und Kontakte

### Kubernetes API

- **Endpoint**: `https://192.168.178.54:6443`
- **Config**: `~/.kube/config` oder `~/.kube/config-new-cluster.yaml`
- **Context**: `kubernetes-admin@kubernetes`

### Services

- **Dashboard**: https://dashboard.k8sops.online
- **GitLab**: https://gitlab.k8sops.online
- **ArgoCD**: https://argocd.k8sops.online
- **Grafana**: https://grafana.k8sops.online
- **Pi-hole**: http://192.168.178.10

### SSH-Zugriff

- **zuhause Node**: `ssh bernd@192.168.178.54`
- **SSH Key**: `~/.ssh/infra_ed25519` (verfügbar)

---

## Wichtige Hinweise

1. **WSL2-Node ist aktuell nicht nutzbar** - Alle Pods laufen auf `zuhause` Node
2. **CPU-Ressourcen sind knapp** - 4 CPU auf `zuhause` Node für alle Services
3. **NFS-Exports wurden erweitert** - WSL2-Subnetz (172.31.16.0/20) ist erlaubt
4. **Metrics-Server fehlt** - `kubectl top` funktioniert nicht
5. **PVCs können nicht verschoben werden** - An PVs gebunden, ReclaimPolicy beachten

---

## Zusammenarbeit mit Agenten

- **k8s-expert**: Kubernetes-Cluster-Management, Services, Ingress
- **debian-server-expert**: Server-Analyse, Docker, KVM, Node-Management
- **dns-expert**: DNS-Konfiguration, Pi-hole, CoreDNS
- **gitops-expert**: ArgoCD, GitOps-Workflows
- **monitoring-expert**: Prometheus, Grafana, Logging

---

**Viel Erfolg beim Weiterarbeiten! 🚀**
