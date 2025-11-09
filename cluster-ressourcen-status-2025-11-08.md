# Cluster Ressourcen-Status und Übersicht - 2025-11-08

## 📊 Node-Status

**Node**: `zuhause`
- **Status**: ✅ Ready
- **OS**: Debian GNU/Linux 12 (bookworm)
- **Kernel**: 6.1.0-40-amd64
- **Kubernetes Version**: v1.34.1
- **Container Runtime**: containerd://1.6.20
- **IP**: 192.168.178.54
- **Uptime**: 6 Tage, 3 Stunden

---

## 💻 Ressourcen-Verteilung

### Hardware-Kapazität
- **CPU**: 4 Cores (4000m)
- **Memory**: ~32 GB (32768 Mi)

### Aktuelle Auslastung
- **CPU**: 1315m (32% von 4000m) ✅ **Normal**
- **Memory**: 11571 Mi (36% von 32768 Mi) ✅ **Normal**

### Ressourcen-Requests (garantierte Ressourcen)
- **CPU Requests**: 3950m (98% von 4000m) ⚠️ **KRITISCH - Fast voll**
- **Memory Requests**: 19796 Mi (62% von 32768 Mi) ✅ **OK**

### Ressourcen-Limits (maximale Ressourcen)
- **CPU Limits**: 15400m (385% - Overcommitment) ⚠️ **Hohes Overcommitment**
- **Memory Limits**: 32000 Mi (100%) ✅ **Ausgelastet**

**Warnung**: CPU Requests sind bei 98% - es können keine neuen Pods mit CPU-Requests gestartet werden!

---

## 🚀 Laufende Pods: 45 Pods in 19 Namespaces

### Namespace-Verteilung

| Namespace | Pods | Status |
|-----------|------|--------|
| **kube-system** | 8 | ✅ System-Komponenten |
| **argocd** | 7 | ✅ GitOps |
| **default** | 6 | ✅ Anwendungen |
| **gitlab** | 3 | ✅ GitLab Stack |
| **monitoring** | 3 | ✅ Monitoring |
| **cert-manager** | 3 | ✅ TLS-Zertifikate |
| **metallb-system** | 2 | ✅ LoadBalancer |
| **velero** | 2 | ✅ Backup |
| **gitlab-agent** | 1 | ✅ GitLab Agent |
| **gitlab-runner** | 1 | ✅ CI/CD Runner |
| **heimdall** | 1 | ✅ Dashboard |
| **ingress-nginx** | 1 | ✅ Ingress Controller |
| **komga** | 1 | ✅ Medien-Server |
| **kube-flannel** | 1 | ✅ Netzwerk CNI |
| **kubernetes-dashboard** | 1 | ✅ K8s Dashboard |
| **logging** | 1 | ✅ Logging |
| **pihole** | 1 | ✅ DNS/Ad-Blocker |
| **syncthing** | 1 | ✅ File-Sync |
| **test-tls** | 1 | ✅ Test |

---

## 🔧 Wichtige Services im Detail

### 1. Pi-hole (DNS/Ad-Blocker)
- **Namespace**: `pihole`
- **Status**: ✅ Running (1/1)
- **Pod**: `pihole-85df646787-kqcxj`
- **IP**: 192.168.178.54 (hostNetwork)
- **Ressourcen**: 200m CPU / 256Mi Memory (Requests), 500m CPU / 512Mi Memory (Limits)
- **Blocklisten**: 15 aktive Listen, 1.645.204 blockierte Domains
- **URL**: https://pihole.k8sops.online/admin/

### 2. Jellyfin (Media Server)
- **Namespace**: `default`
- **Status**: ✅ Running (1/1)
- **Pod**: `jellyfin-d646478b9-4nvnm`
- **Ressourcen**: 1300m CPU / 10Gi Memory (Requests), 4 CPU / 16Gi Memory (Limits)
- **⚠️ WICHTIG**: Größter CPU/Memory-Verbraucher (32% CPU Requests, 31% Memory Requests)
- **URL**: https://jellyfin.k8sops.online

### 3. GitLab
- **Namespace**: `gitlab`
- **Status**: ✅ Running (3/3 Pods)
- **Pods**: 
  - `gitlab-7b86fcf65b-mz6jt` (GitLab CE)
  - `gitlab-postgresql-0` (PostgreSQL)
  - `gitlab-redis-master-0` (Redis)
- **Ressourcen**: 100m CPU / 4Gi Memory (GitLab), 100m CPU / 256Mi Memory (PostgreSQL), 50m CPU / 128Mi Memory (Redis)
- **URL**: https://gitlab.k8sops.online

### 4. ArgoCD (GitOps)
- **Namespace**: `argocd`
- **Status**: ✅ Running (7/7 Pods)
- **Ressourcen**: 
  - Application Controller: 200m CPU / 512Mi Memory
  - Repo Server: 150m CPU / 512Mi Memory
  - Server: 50m CPU / 256Mi Memory
  - Redis: 50m CPU / 256Mi Memory
  - Dex Server: 50m CPU / 256Mi Memory
  - Notifications Controller: 50m CPU / 256Mi Memory
  - ApplicationSet Controller: keine Limits
- **URL**: https://argocd.k8sops.online

### 5. Monitoring Stack
- **Namespace**: `monitoring`
- **Status**: ✅ Running (3/3 Pods)
- **Pods**: 
  - `prometheus-585d56d988-kgjb5` (Prometheus)
  - `grafana-775b45c697-sh6vk` (Grafana)
  - `grafana-test-85cdf6f69f-hwsrr` (Grafana Test)
- **Ressourcen**: Keine Limits definiert
- **URL**: https://grafana.k8sops.online

### 6. Ingress Controller
- **Namespace**: `ingress-nginx`
- **Status**: ✅ Running (1/1)
- **Pod**: `ingress-nginx-controller-68c56f854d-4prxr`
- **IP**: 192.168.178.54 (LoadBalancer)
- **Ressourcen**: 100m CPU / 90Mi Memory (Requests)
- **Ports**: 80:30827/TCP, 443:30941/TCP

### 7. Cert-Manager (TLS-Zertifikate)
- **Namespace**: `cert-manager`
- **Status**: ✅ Running (3/3 Pods)
- **Ressourcen**: 
  - Controller: 100m CPU / 256Mi Memory
  - Webhook: 25m CPU / 128Mi Memory
  - CA Injector: 25m CPU / 128Mi Memory

### 8. Heimdall (Dashboard)
- **Namespace**: `heimdall`
- **Status**: ✅ Running (1/1)
- **Pod**: `heimdall-5b7457b589-2bmc6`
- **Ressourcen**: Keine Limits definiert
- **URL**: https://heimdall.k8sops.online

### 9. Komga (Comic-Server)
- **Namespace**: `komga`
- **Status**: ✅ Running (1/1)
- **Pod**: `komga-6d8bb46bd5-j4lh9`
- **Ressourcen**: Keine Limits definiert
- **URL**: https://komga.k8sops.online

### 10. Velero (Backup)
- **Namespace**: `velero`
- **Status**: ✅ Running (2/2 Pods)
- **Pods**: 
  - `velero-86b79bd68f-g5tcf` (Velero Controller)
  - `minio-6ff996b598-m2d5h` (MinIO S3 Storage)
- **Ressourcen**: 
  - Velero: 50m CPU / 512Mi Memory (Requests), 1 CPU / 1Gi Memory (Limits)
  - MinIO: 100m CPU / 256Mi Memory (Requests), 500m CPU / 512Mi Memory (Limits)

### 11. Syncthing (File-Sync)
- **Namespace**: `syncthing`
- **Status**: ✅ Running (1/1)
- **Pod**: `syncthing-0` (StatefulSet)
- **Ressourcen**: Keine Limits definiert

### 12. Kubernetes System-Komponenten
- **Namespace**: `kube-system`
- **Status**: ✅ Running (8/8 Pods)
- **Pods**:
  - `etcd-zuhause` (100m CPU / 100Mi Memory)
  - `kube-apiserver-zuhause` (250m CPU)
  - `kube-controller-manager-zuhause` (200m CPU)
  - `kube-scheduler-zuhause` (100m CPU)
  - `kube-proxy-bl2f8` (keine Limits)
  - `coredns-64f644b686-wlcj2` (50m CPU / 128Mi Memory, 500m CPU / 256Mi Memory Limits)
  - `coredns-64f644b686-zbrwn` (50m CPU / 128Mi Memory, 500m CPU / 256Mi Memory Limits)
  - `metrics-server-694c6646d7-clq6x` (50m CPU / 100Mi Memory)

---

## ⚠️ Ressourcen-Probleme

### Kritische Probleme

1. **CPU Requests bei 98%** ⚠️ **KRITISCH**
   - **Aktuell**: 3950m von 4000m belegt
   - **Problem**: Keine neuen Pods mit CPU-Requests können gestartet werden
   - **Lösung**: 
     - CPU-Requests für Pods ohne Limits reduzieren
     - Oder: CPU-Requests für weniger kritische Pods entfernen
     - Oder: Node erweitern (mehr CPU)

2. **Hohes CPU-Overcommitment (385%)**
   - **Aktuell**: 15400m Limits bei 4000m verfügbar
   - **Problem**: Bei hoher Last können Pods nicht alle Limits gleichzeitig nutzen
   - **Hinweis**: Normal für Development/Home-Umgebungen, aber sollte überwacht werden

### Potenzielle Probleme

1. **Memory Limits bei 100%**
   - **Aktuell**: 32000 Mi Limits bei ~32768 Mi verfügbar
   - **Problem**: Sehr wenig Puffer für Memory-Spikes
   - **Lösung**: Memory-Limits für weniger kritische Pods reduzieren

2. **Viele Pods ohne Ressourcen-Limits**
   - **Pods ohne Limits**: plantuml, gitlab-agent, heimdall, komga, syncthing, loki, grafana, prometheus, kubernetes-dashboard, test-nginx
   - **Problem**: Können unbegrenzt Ressourcen verbrauchen
   - **Empfehlung**: Limits für alle Pods definieren

---

## 📈 Top Ressourcen-Verbraucher

### CPU Requests (garantierte CPU)
1. **Jellyfin**: 1300m (32% des Nodes)
2. **ArgoCD Application Controller**: 200m (5%)
3. **Pi-hole**: 200m (5%)
4. **Kube API Server**: 250m (6%)
5. **Kube Controller Manager**: 200m (5%)
6. **GitLab**: 100m (2,5%)
7. **Ingress Controller**: 100m (2,5%)
8. **Cert-Manager**: 100m (2,5%)
9. **ArgoCD Repo Server**: 150m (3,75%)
10. **Weitere**: ~1450m (36%)

### Memory Requests (garantierter Memory)
1. **Jellyfin**: 10Gi (31% des Nodes)
2. **GitLab**: 4Gi (12,5%)
3. **ArgoCD Application Controller**: 512Mi (1,6%)
4. **ArgoCD Repo Server**: 512Mi (1,6%)
5. **Velero**: 512Mi (1,6%)
6. **Weitere**: ~4,5Gi (14%)

---

## ✅ Services-Status

### Alle wichtigen Services laufen:
- ✅ **Pi-hole**: DNS/Ad-Blocking funktioniert
- ✅ **Jellyfin**: Media Server läuft
- ✅ **GitLab**: Git-Repository läuft
- ✅ **ArgoCD**: GitOps funktioniert
- ✅ **Heimdall**: Dashboard verfügbar
- ✅ **Komga**: Comic-Server läuft
- ✅ **Grafana**: Monitoring verfügbar
- ✅ **Prometheus**: Metriken werden gesammelt
- ✅ **Ingress Controller**: Routing funktioniert
- ✅ **Cert-Manager**: TLS-Zertifikate werden verwaltet
- ✅ **Velero**: Backup-System läuft
- ✅ **Syncthing**: File-Sync läuft

### Nicht gestartet:
- ⚠️ **Jenkins**: Deployment vorhanden, aber 0/0 Pods (bewusst deaktiviert)

---

## 🔍 Empfehlungen

### Sofortige Maßnahmen

1. **CPU-Requests reduzieren**:
   - Pods ohne Limits sollten Limits erhalten
   - Weniger kritische Pods sollten CPU-Requests reduzieren
   - Jellyfin könnte CPU-Requests reduzieren (aktuell 1300m)

2. **Memory-Limits optimieren**:
   - Memory-Limits für Pods ohne Limits definieren
   - Memory-Limits für weniger kritische Pods reduzieren

3. **Ressourcen-Limits für alle Pods definieren**:
   - Besonders wichtig für: plantuml, gitlab-agent, heimdall, komga, syncthing, loki, grafana, prometheus

### Langfristige Maßnahmen

1. **Node erweitern**: Mehr CPU/Memory für zukünftige Services
2. **Resource Quotas**: Namespace-basierte Ressourcen-Limits einführen
3. **Horizontal Pod Autoscaling**: Für Services mit variabler Last
4. **Resource Monitoring**: Grafana-Dashboards für Ressourcen-Überwachung

---

## 📊 Zusammenfassung

**Status**: ✅ **Cluster läuft stabil**

**Ressourcen**:
- ✅ **Aktuelle Auslastung**: Normal (32% CPU, 36% Memory)
- ⚠️ **CPU Requests**: Kritisch (98% belegt)
- ⚠️ **Memory Limits**: Vollständig ausgelastet (100%)

**Services**: 
- ✅ **45 Pods laufen** in 19 Namespaces
- ✅ **Alle wichtigen Services** sind verfügbar
- ⚠️ **Jenkins** ist deaktiviert (bewusst)

**Nächste Schritte**:
1. CPU-Requests optimieren (besonders für Pods ohne Limits)
2. Memory-Limits für alle Pods definieren
3. Ressourcen-Überwachung einrichten

---

**Erstellt**: 2025-11-08 19:00 CET  
**Letzte Aktualisierung**: 2025-11-08 19:00 CET

