# Kubernetes Cluster Analyse

## Cluster-Informationen

- **Kubernetes Version**: kubeadm-basiert
- **Control Plane**: https://192.168.178.54:6443
- **CoreDNS**: https://192.168.178.54:6443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
- **Pod Network**: 10.244.0.0/16 (Flannel CNI)

## Namespaces

Aktive Namespaces:
- `argocd` - GitOps Deployment
- `cert-manager` - Zertifikatsmanagement
- `default` - Standard-Namespace
- `gitlab` - GitLab
- `gitlab-agent` - GitLab Agent
- `gitlab-runner` - GitLab Runner
- `heimdall` - Dashboard
- `ingress-nginx` - Ingress Controller
- `komga` - Medien-Verwaltung
- `kube-flannel` - Netzwerk-CNI
- `kube-system` - System-Komponenten
- `logging` - Logging (Loki)
- `metallb-system` - LoadBalancer
- `monitoring` - Prometheus/Grafana
- `syncthing` - Datei-Synchronisation
- `test-tls` - Test-Umgebung
- `velero` - Backup

## Ingress-Controller

### Konfiguration

- **Controller**: ingress-nginx
- **Service**: LoadBalancer (192.168.178.54)
- **Ports**: 80:30827/TCP, 443:30941/TCP
- **ConfigMap**: `ingress-nginx-controller`
  - `allow-snippet-annotations: false` (Sicherheit)

### Ingress-Ressourcen

Alle Ingresses verwenden die Klasse `nginx` und zeigen auf `192.168.178.54`:

| Namespace | Name | Host | Ports |
|-----------|------|------|-------|
| argocd | argocd-ingress | argocd.k8sops.online | 80, 443 |
| default | jellyfin-ingress | jellyfin.k8sops.online | 80, 443 |
| default | jenkins-ingress | jenkins.k8sops.online | 80, 443 |
| default | plantuml-ingress | plantuml.k8sops.online | 80, 443 |
| gitlab | gitlab | gitlab.k8sops.online | 80, 443 |
| heimdall | heimdall-ingress | heimdall.k8sops.online | 80, 443 |
| komga | komga-ingress | komga.k8sops.online | 80, 443 |
| logging | loki-ingress | loki.k8sops.online | 80, 443 |
| monitoring | grafana-ingress | grafana.k8sops.online | 80, 443 |
| monitoring | prometheus-ingress | prometheus.k8sops.online | 80, 443 |
| syncthing | syncthing-ingress | syncthing.k8sops.online | 80, 443 |
| test-tls | test-nginx-ingress | test.k8sops.online | 80, 443 |

## Zertifikatsmanagement (Cert-Manager)

### ClusterIssuer

**letsencrypt-prod-dns01:**
- **ACME Server**: https://acme-v02.api.letsencrypt.org/directory
- **Email**: bernd@k8sops.online
- **Challenge**: DNS01 mit Cloudflare
- **API Token**: Secret `cloudflare-api-token` (Key: `api-token`)
- **Status**: Ready (Account registriert)

**letsencrypt-staging-dns01:**
- Staging-Umgebung vorhanden

**letsencrypt-prod:**
- HTTP01 Challenge (vermutlich)

**letsencrypt-staging:**
- HTTP01 Challenge Staging

### Zertifikate

Alle Zertifikate sind `Ready`:

| Namespace | Name | Secret | Host |
|-----------|------|--------|------|
| argocd | argocd-k8sops-online-tls | argocd-k8sops-online-tls | argocd.k8sops.online |
| default | jellyfin-k8sops-online-tls | jellyfin-k8sops-online-tls | jellyfin.k8sops.online |
| default | jenkins-k8sops-online-tls | jenkins-k8sops-online-tls | jenkins.k8sops.online |
| default | plantuml-k8sops-online-tls | plantuml-k8sops-online-tls | plantuml.k8sops.online |
| gitlab | gitlab-tls | gitlab-tls | gitlab.k8sops.online |
| heimdall | heimdall-k8sops-online-tls | heimdall-k8sops-online-tls | heimdall.k8sops.online |
| komga | komga-k8sops-online-tls | komga-k8sops-online-tls | komga.k8sops.online |
| logging | loki-k8sops-online-tls | loki-k8sops-online-tls | loki.k8sops.online |
| monitoring | grafana-k8sops-online-tls | grafana-k8sops-online-tls | grafana.k8sops.online |
| monitoring | prometheus-k8sops-online-tls | prometheus-k8sops-online-tls | prometheus.k8sops.online |
| syncthing | syncthing-k8sops-online-tls | syncthing-k8sops-online-tls | syncthing.k8sops.online |
| test-tls | test-k8sops-online-tls | test-k8sops-online-tls | test.k8sops.online |

## LoadBalancer (MetalLB)

### Konfiguration

- **IP Address Pool**: `default-pool`
  - **Adressen**: `192.168.178.54/32`
  - **Auto Assign**: true
  
- **L2 Advertisement**: `default`
  - **IP Address Pools**: `default-pool`

Der LoadBalancer verwendet eine einzelne IP-Adresse (192.168.178.54), die von allen Services gemeinsam genutzt wird.

## DNS (CoreDNS)

### Konfiguration

```yaml
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf {
       max_concurrent 1000
    }
    cache 30 {
       disable success cluster.local
       disable denial cluster.local
    }
    loop
    reload
    loadbalance
}
```

**Analyse:**
- CoreDNS forwardet alle externen Anfragen an `/etc/resolv.conf` (Fritzbox)
- Kubernetes Service-Discovery für `cluster.local`
- Prometheus-Metriken auf Port 9153
- Caching aktiviert (30s, außer für cluster.local)
- Load Balancing aktiviert

## Netzwerk-Topologie

### IP-Bereiche

- **Kubernetes LoadBalancer**: 192.168.178.54/32
- **Pod Network**: 10.244.0.0/16 (Flannel)
- **Service Network**: 10.100.0.0/16 (vermutlich, aus Service-IPs abgeleitet)

### CNI

- **Flannel**: Layer 3 Overlay Network
- **Interface**: flannel.1
- **Bridge**: cni0

## Identifizierte Themen

### 1. DNS-Integration

**Aktuell:**
- CoreDNS forwardet an Fritzbox
- Externe DNS-Namen (k8sops.online) werden über Cloudflare verwaltet
- Cert-Manager nutzt Cloudflare DNS01-Challenge

**Potenzielle Verbesserungen:**
- Integration mit Pi-hole als Upstream-DNS
- Local DNS Records für interne Services
- External-DNS Integration für automatische DNS-Updates

### 2. IP-Management

**Aktuell:**
- MetalLB nutzt nur eine IP (192.168.178.54)
- Alle Services teilen sich diese IP

**Potenzielle Verbesserungen:**
- Erweiterung des IP-Pools falls nötig
- Separate IPs für kritische Services

### 3. Service-Discovery

**Aktuell:**
- Kubernetes Service-Discovery funktioniert
- Externe Zugriffe über Ingress

**Potenzielle Verbesserungen:**
- Integration mit NetBox für externe Service-Registry
- Automatische DNS-Updates bei Service-Änderungen

## Empfehlungen

1. **DNS-Stack optimieren:**
   - Pi-hole als Upstream für CoreDNS konfigurieren
   - Local DNS Records für interne Services
   - External-DNS für automatische DNS-Updates

2. **NetBox Integration:**
   - Kubernetes Services in NetBox dokumentieren
   - IP-Adressen und DNS-Namen zentral verwalten
   - API-Integration für Automatisierung

3. **Monitoring:**
   - Prometheus/Grafana bereits vorhanden
   - Integration mit NetBox für Service-Discovery

