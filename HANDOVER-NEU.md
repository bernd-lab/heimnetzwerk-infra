# Handover-Dokument - Kubernetes Home Infrastructure

**Erstellt**: 2025-11-07  
**Letzte Aktualisierung**: 2025-11-09  
**Cluster**: K3s v1.34.1  
**Node**: zuhause (Debian 12, 192.168.178.54)

---

## 🎯 Schnellstart für neue Agents

### Wichtige Kommandos

```bash
# Cluster-Status prüfen
kubectl get nodes
kubectl get pods --all-namespaces
kubectl top nodes

# Pi-hole Status
kubectl get pods -n pihole
kubectl logs -n pihole -l app=pihole --tail=50

# DNS testen
dig @192.168.178.54 google.de
dig @192.168.178.10 google.de

# Zertifikate prüfen
kubectl get certificate --all-namespaces
kubectl describe certificate -n pihole pihole-k8sops-online-tls

# Ressourcen prüfen
kubectl describe node zuhause | grep -A 5 "Allocated resources"
```

### Wichtige URLs

- **Pi-hole Web**: https://pihole.k8sops.online/admin/
- **ArgoCD**: https://argocd.k8sops.online
- **GitLab**: https://gitlab.k8sops.online
- **Jellyfin**: https://jellyfin.k8sops.online
- **Heimdall**: https://heimdall.k8sops.online
- **Grafana**: https://grafana.k8sops.online

---

## 📋 Infrastruktur-Übersicht

### Node: zuhause

**Hardware**:
- **OS**: Debian GNU/Linux 12 (bookworm)
- **Kernel**: 6.1.0-40-amd64
- **Container Runtime**: containerd://1.6.20
- **IP**: 192.168.178.54
- **CPU**: 4 Cores
- **Memory**: ~32GB
- **Status**: Ready

**Ressourcen-Verteilung** (Stand: 2025-11-07):
- **CPU Requests**: 3950m (98% von 4000m) ⚠️ **KRITISCH - Fast voll**
- **CPU Limits**: 15400m (385% - Overcommitment)
- **Memory Requests**: 19796Mi (62% von ~32GB)
- **Memory Limits**: 32000Mi (100%)

**Aktuelle Auslastung**:
- **CPU**: 1215m (30%)
- **Memory**: 10063Mi (31%)

### Netzwerk

**Heimnetzwerk**: 192.168.178.0/24
- **Router**: FritzBox (DHCP-Server)
- **DNS-Server**: Pi-hole (192.168.178.54 auf Port 53)
- **LoadBalancer IP**: 192.168.178.54 (nginx-ingress)
- **Pi-hole LoadBalancer IP**: 192.168.178.10 (nicht mehr verwendet, da hostNetwork)

**Kubernetes Pod Network**: 10.244.0.0/16 (Flannel CNI)

---

## 🔧 Wichtige Services

### 1. Pi-hole (DNS/Ad-Blocker)

**Namespace**: `pihole`  
**Status**: ✅ Running (1/1 Pods)  
**Pod**: `pihole-7fc8889b54-mdl2f`

**Konfiguration**:
- **DNS-Port**: 53 (TCP/UDP) auf Host-Netzwerk
- **Webserver-Port**: 8080 (intern), über Ingress auf Port 80/443
- **Web-URL**: https://pihole.k8sops.online/admin/
- **Host Network**: `true` (bindet direkt an Host-IP)
- **DNS Policy**: `ClusterFirstWithHostNet`

**Wichtige Dateien**:
- `k8s/pihole/deployment.yaml` - Haupt-Deployment
- `k8s/pihole/service.yaml` - Kubernetes Service
- `k8s/pihole/ingress.yaml` - Ingress für Web-Interface
- `k8s/pihole/certificate.yaml` - TLS-Zertifikat (DNS-01 Challenge)
- `k8s/pihole/configmap.yaml` - Pi-hole Konfiguration
- `k8s/pihole/dnsmasq-configmap.yaml` - DNSmasq Custom Config

**Besonderheiten**:
- **Init Container**: Konfiguriert `pihole.toml` automatisch:
  - `interface = "all"` - Akzeptiert Anfragen von allen Netzwerken
  - `dns_listeningMode = "all"` - Lauscht auf allen Interfaces
  - `webserver.port = "8080"` - Webserver auf Port 8080 (nginx-ingress nutzt 80)
- **DNSmasq Config**: `local-service=false` - Erlaubt Anfragen von Pod-Netzwerk
- **PVC**: `pihole-data` - Persistente Daten (Blocklisten, Konfiguration)

**Ressourcen**:
- **CPU Request**: 200m
- **CPU Limit**: 500m
- **Memory Request**: 256Mi
- **Memory Limit**: 512Mi

**TLS-Zertifikat**:
- **ClusterIssuer**: `letsencrypt-prod-dns01` (DNS-01 Challenge mit Cloudflare)
- **Status**: ⚠️ **In Bearbeitung** - DNS-01 Challenge läuft
- **Certificate**: `pihole-k8sops-online-tls` (READY: False, wartet auf DNS-Propagierung)
- **Secret**: `pihole-tls` (bereits vorhanden, aber möglicherweise von altem Certificate)

**Bekannte Probleme**:
- ⚠️ **TLS-Zertifikat**: Zwei Certificates zeigen auf dasselbe Secret (`pihole-tls` und `pihole-k8sops-online-tls`)
  - Lösung: Alte Certificates löschen, nur `pihole-k8sops-online-tls` behalten
- ✅ **DNS funktioniert**: Port 53 läuft korrekt auf Host-Netzwerk
- ✅ **Webserver funktioniert**: Port 8080 läuft, Ingress routet korrekt

### 2. Ingress Controller (nginx-ingress)

**Namespace**: `ingress-nginx`  
**Status**: ✅ Running  
**Pod**: `ingress-nginx-controller-68c56f854d-bzqbf`

**Konfiguration**:
- **Host Network**: `true` (bindet direkt an 192.168.178.54)
- **Ports**: 80 (HTTP), 443 (HTTPS)
- **LoadBalancer IP**: 192.168.178.54

**Wichtige Annotations**:
- `allow-snippet-annotations: false` (Sicherheit)

### 3. Cert-Manager

**Namespace**: `cert-manager`  
**Status**: ✅ Running (3 Pods)

**ClusterIssuer**:
- **letsencrypt-prod-dns01**: DNS-01 Challenge mit Cloudflare API
  - **API Token Secret**: `cloudflare-api-token` (Namespace: cert-manager)
  - **Status**: Ready
- **letsencrypt-prod**: HTTP-01 Challenge (für öffentlich erreichbare Domains)

**Zertifikate**:
- Alle anderen `*.k8sops.online` Domains haben gültige Zertifikate ✅
- Pi-hole: ⚠️ In Bearbeitung (DNS-01 Challenge läuft)

### 4. ArgoCD (GitOps)

**Namespace**: `argocd`  
**Status**: ✅ Running (7 Pods)  
**URL**: https://argocd.k8sops.online

### 5. GitLab

**Namespace**: `gitlab`  
**Status**: ✅ Running  
**URL**: https://gitlab.k8sops.online

**Komponenten**:
- GitLab Pod
- PostgreSQL StatefulSet
- Redis StatefulSet

### 6. Jellyfin (Media Server)

**Namespace**: `default`  
**Status**: ✅ Running  
**URL**: https://jellyfin.k8sops.online

**Ressourcen**:
- **CPU Request**: 1300m (reduziert für Pi-hole Platz)
- **CPU Limit**: 4
- **Memory Request**: 10Gi
- **Memory Limit**: 16Gi

### 7. Heimdall (Dashboard)

**Namespace**: `heimdall`  
**Status**: ✅ Running  
**URL**: https://heimdall.k8sops.online

---

## 🔐 Sicherheit & Secrets

### Cloudflare API Token

**Secret**: `cloudflare-api-token`  
**Namespace**: `cert-manager`  
**Key**: `api-token`  
**Verwendung**: DNS-01 Challenge für Let's Encrypt Zertifikate

### Pi-hole Web Password

**Secret**: `pihole-secret`  
**Namespace**: `pihole`  
**Key**: `WEBPASSWORD`

---

## 📁 Wichtige Dateien und Verzeichnisse

### Kubernetes-Manifeste

```
k8s/
├── pihole/
│   ├── deployment.yaml          # Pi-hole Deployment (hostNetwork: true)
│   ├── service.yaml              # Kubernetes Service (ClusterIP)
│   ├── ingress.yaml             # Ingress für Web-Interface
│   ├── certificate.yaml         # TLS-Zertifikat (DNS-01)
│   ├── configmap.yaml           # Pi-hole Konfiguration
│   ├── dnsmasq-configmap.yaml   # DNSmasq Custom Config
│   ├── secret.yaml              # Secrets Template
│   ├── pvc.yaml                 # Persistent Volume Claim
│   └── README.md                # Dokumentation
├── jellyfin/
│   └── deployment.yaml          # Jellyfin Deployment
└── ...
```

### Dokumentation

- `HANDOVER-NEU.md` - **Dieses Dokument** (aktuelles Handover)
- `HANDOVER.md` - Altes Handover (veraltet)
- `kubernetes-analyse.md` - Detaillierte Cluster-Analyse
- `dns-flow-diagram.md` - DNS-Flow Dokumentation
- `dns-provider-analyse.md` - DNS-Provider Analyse

---

## ⚠️ Bekannte Probleme & Offene Tasks

### 1. TLS-Zertifikat für Pi-hole (P1)

**Problem**:
- Zwei Certificates zeigen auf dasselbe Secret (`pihole-tls`)
- `pihole-k8sops-online-tls`: READY=False (wartet auf DNS-Propagierung)
- `pihole-tls`: READY=True (altes Certificate?)

**Status**: DNS-01 Challenge läuft, wartet auf DNS-Propagierung

**Lösung**:
```bash
# Alte Certificates löschen
kubectl delete certificate -n pihole pihole-tls

# Nur das neue Certificate behalten
kubectl get certificate -n pihole pihole-k8sops-online-tls

# Status prüfen
kubectl describe certificate -n pihole pihole-k8sops-online-tls
```

### 2. CPU-Ressourcen knapp (P1)

**Problem**:
- CPU Requests: 3950m von 4000m (98%) ⚠️
- Fast keine CPU mehr verfügbar für neue Pods

**Aktuelle Verteilung**:
- Jellyfin: 1300m (reduziert von 1500m)
- Pi-hole: 200m (erhöht von 50m)
- GitLab: 100m
- ArgoCD: 200m
- System: ~2150m

**Lösungsansätze**:
1. Weitere CPU-Requests optimieren (weniger kritische Services)
2. CPU-Limits erhöhen (Overcommitment akzeptieren)
3. Node erweitern (nicht möglich - Single-Node)

### 3. Memory-Ressourcen (P2)

**Status**: ✅ OK (62% verwendet)

---

## 🚀 Nächste Schritte

### Sofort (P0)

1. **TLS-Zertifikat für Pi-hole abschließen**:
   - DNS-01 Challenge Status prüfen
   - Alte Certificates bereinigen
   - Zertifikat-Status überwachen

### Bald (P1)

2. **CPU-Ressourcen optimieren**:
   - Weitere Services analysieren
   - CPU-Requests reduzieren wo möglich
   - Monitoring einrichten

3. **Pi-hole Monitoring**:
   - DNS-Query-Logs prüfen
   - Performance-Metriken sammeln
   - Blocklist-Status überwachen

### Später (P2)

4. **Dokumentation aktualisieren**:
   - Alle Services dokumentieren
   - Troubleshooting-Guides erstellen
   - Runbooks für häufige Probleme

---

## 🔍 Troubleshooting

### Pi-hole DNS funktioniert nicht

```bash
# Pod-Status prüfen
kubectl get pods -n pihole

# Logs prüfen
kubectl logs -n pihole -l app=pihole --tail=100

# DNS-Test
dig @192.168.178.54 google.de
dig @192.168.178.10 google.de

# Port-Status prüfen
kubectl exec -n pihole -l app=pihole -- netstat -tuln | grep ":53"

# FTL-Status prüfen
kubectl exec -n pihole -l app=pihole -- pihole status
```

### TLS-Zertifikat funktioniert nicht

```bash
# Certificate-Status
kubectl get certificate -n pihole
kubectl describe certificate -n pihole pihole-k8sops-online-tls

# Challenge-Status
kubectl get challenge -n pihole
kubectl describe challenge -n pihole

# Order-Status
kubectl get order -n pihole
kubectl describe order -n pihole

# Cert-Manager Logs
kubectl logs -n cert-manager -l app.kubernetes.io/name=cert-manager --tail=50 | grep -i pihole
```

### Pod kann nicht starten (CPU-Ressourcen)

```bash
# Node-Ressourcen prüfen
kubectl describe node zuhause | grep -A 5 "Allocated resources"

# Pod-Events prüfen
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Events:"

# CPU-Verteilung prüfen
kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.spec.nodeName=="zuhause") | "\(.spec.containers[0].resources.requests.cpu // "none") \(.metadata.namespace)/\(.metadata.name)"' | sort -rn | head -20
```

---

## 📞 Kontakt & Support

**Domain**: k8sops.online  
**DNS-Provider**: Cloudflare  
**Registrar**: United Domains

**Wichtige Accounts**:
- Cloudflare: DNS-Management, API-Token für Cert-Manager
- United Domains: Domain-Registrierung

---

## 📝 Changelog

### 2025-11-09
- ✅ ArgoCD Monitoring Kustomization-Fehler behoben
- ✅ Grafana und Prometheus Deployments/Services zur Kustomization hinzugefügt
- ✅ Alle Ressourcen direkt referenziert (keine verschachtelten Kustomizations)
- ✅ Monitoring-Application neu strukturiert für ArgoCD
- ✅ Handover-Dokument für ArgoCD Monitoring erstellt (`HANDOVER-ARGOCD-MONITORING-2025-11-09.md`)

### 2025-11-07
- ✅ Pi-hole auf DNS-01 Challenge umgestellt
- ✅ Pi-hole Webserver auf Port 8080 konfiguriert
- ✅ Pi-hole CPU-Ressourcen erhöht (200m request, 500m limit)
- ✅ Jellyfin CPU reduziert (1300m) für Pi-hole Platz
- ✅ Handover-Dokument erstellt

---

**Ende des Handover-Dokuments**


