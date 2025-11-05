# Pi-hole Deployment Status

**Erstellt**: 2025-11-05 21:15  
**Status**: ⏳ Manifeste erstellt, Deployment ausstehend (Cluster nicht erreichbar)

## Aktueller Status

### ✅ Abgeschlossen

1. **Manifeste erstellt**:
   - `k8s/pihole/namespace.yaml` - Namespace
   - `k8s/pihole/metallb-pool.yaml` - MetallB IP-Pool (192.168.178.10)
   - `k8s/pihole/configmap.yaml` - ConfigMap mit Pi-hole Konfiguration
   - `k8s/pihole/secret.yaml` - Secret (für Web-Passwort)
   - `k8s/pihole/pvc.yaml` - PersistentVolumeClaim (2Gi)
   - `k8s/pihole/deployment.yaml` - Deployment
   - `k8s/pihole/service.yaml` - LoadBalancer Service
   - `k8s/pihole/kustomization.yaml` - Kustomize Config
   - `k8s/pihole/README.md` - Dokumentation

2. **Deployment-Script erstellt**:
   - `scripts/deploy-pihole.sh` - Automatisches Deployment-Script

3. **Dokumentation aktualisiert**:
   - `laptop-dns-problem-analysis.md` - Problem-Analyse
   - `laptop-dns-fix-fedora.md` - Workaround für Fedora
   - `pihole-analyse.md` - Status aktualisiert

### ⏳ Ausstehend

1. **Kubernetes-Cluster-Verfügbarkeit**:
   - Cluster ist aktuell nicht erreichbar (TLS handshake timeout)
   - SSH-Zugriff auf Debian-Server (192.168.178.54) schlägt fehl

2. **Pi-hole Deployment**:
   - Wird durchgeführt, sobald Cluster wieder erreichbar ist
   - Deployment-Script bereit: `scripts/deploy-pihole.sh`

3. **Verification**:
   - Pod-Status prüfen
   - Service-IP prüfen (sollte 192.168.178.10 sein)
   - DNS-Auflösung testen
   - Webinterface testen

## Deployment-Anleitung

### Voraussetzungen prüfen

```bash
# 1. Kubernetes-Cluster erreichbar?
kubectl cluster-info

# 2. MetallB installiert?
kubectl get namespace metallb-system

# 3. StorageClass vorhanden?
kubectl get storageclass
```

### Deployment durchführen

**Option 1: Mit Deployment-Script (Empfohlen)**

```bash
cd /home/bernd/infra-0511
./scripts/deploy-pihole.sh
```

**Option 2: Manuell mit kubectl**

```bash
cd /home/bernd/infra-0511

# Alle Manifeste auf einmal
kubectl apply -k k8s/pihole/

# Oder einzeln
kubectl apply -f k8s/pihole/namespace.yaml
kubectl apply -f k8s/pihole/metallb-pool.yaml
kubectl apply -f k8s/pihole/configmap.yaml
kubectl apply -f k8s/pihole/secret.yaml
kubectl apply -f k8s/pihole/pvc.yaml
kubectl apply -f k8s/pihole/deployment.yaml
kubectl apply -f k8s/pihole/service.yaml
```

**Option 3: Mit Helm (Alternative)**

```bash
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update

helm install pihole mojo2600/pihole \
  --namespace pihole \
  --create-namespace \
  --set service.loadBalancerIP=192.168.178.10 \
  --set service.type=LoadBalancer \
  --set persistence.enabled=true \
  --set timezone="Europe/Berlin" \
  --set dns.upstreamServers="1.1.1.1;1.0.0.1" \
  --set dns.dnssec="true" \
  --set dnsmasq.listen="all"
```

### Verification

```bash
# Pod-Status
kubectl get pods -n pihole

# Service-Status
kubectl get svc -n pihole

# Service-IP prüfen
kubectl get svc pihole -n pihole -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# DNS-Test
dig @192.168.178.10 google.de

# Webinterface testen
curl http://192.168.178.10/admin
```

## Konfiguration

### Pi-hole Konfiguration (ConfigMap)

- **Zeitzone**: Europe/Berlin
- **Upstream DNS**: 1.1.1.1;1.0.0.1 (Cloudflare)
- **DNSSEC**: Aktiviert
- **DNSMASQ_LISTENING**: all (alle Interfaces)
- **ServerIP**: 192.168.178.10

### Service-Konfiguration

- **Typ**: LoadBalancer
- **IP**: 192.168.178.10 (MetallB)
- **Ports**:
  - 53 TCP/UDP (DNS)
  - 80 TCP (Webinterface)

### PersistentVolumeClaim

- **Größe**: 2Gi
- **StorageClass**: local-path (kann angepasst werden)
- **Zweck**: Pi-hole Konfiguration und Daten persistent speichern

## Nächste Schritte (nach Deployment)

1. **Fritzbox DNS-Server ändern**:
   - Menü: Internet → Zugangsdaten → DNS-Server
   - DNS-Server: 192.168.178.10

2. **CoreDNS Upstream ändern**:
   ```bash
   kubectl edit configmap coredns -n kube-system
   # Ändere: forward . /etc/resolv.conf
   # Zu: forward . 192.168.178.10
   ```

3. **Custom DNS Records hinzufügen**:
   - Über Webinterface: http://192.168.178.10/admin
   - Oder über API (siehe `k8s/pihole/README.md`)

4. **Web-Passwort setzen** (optional):
   ```bash
   kubectl create secret generic pihole-secret \
     --from-literal=WEBPASSWORD='dein-passwort-hier' \
     --namespace pihole \
     --dry-run=client -o yaml | kubectl apply -f -
   
   kubectl rollout restart deployment pihole -n pihole
   ```

## Troubleshooting

### Pod startet nicht

```bash
# Logs prüfen
kubectl logs -n pihole -l app=pihole

# Pod-Status prüfen
kubectl describe pod -n pihole -l app=pihole
```

### Service erhält keine IP

```bash
# MetallB Status prüfen
kubectl get ipaddresspool -n metallb-system
kubectl get l2advertisement -n metallb-system

# Service-Status prüfen
kubectl describe svc pihole -n pihole
```

### Port 53 nicht erreichbar

```bash
# Port-Forward testen
kubectl port-forward -n pihole svc/pihole 5353:53

# Dann testen:
dig @127.0.0.1 -p 5353 google.de
```

## Wichtige Hinweise

- **Cluster-Verfügbarkeit**: Deployment kann erst durchgeführt werden, wenn Kubernetes-Cluster wieder erreichbar ist
- **StorageClass**: Falls `local-path` nicht vorhanden ist, bitte `k8s/pihole/pvc.yaml` anpassen
- **MetallB**: IP-Pool muss 192.168.178.10 enthalten (wird automatisch erstellt)
- **Web-Passwort**: Optional, kann später gesetzt werden

