# Pi-hole Kubernetes Deployment

**Erstellt**: 2025-11-05  
**Aktualisiert**: 2025-11-08  
**Zweck**: Pi-hole als Kubernetes Service deployen (IP: 192.168.178.54, Host-Netzwerk)

## Voraussetzungen

1. **Kubernetes-Cluster** muss erreichbar sein
2. **MetallB** muss installiert sein (`metallb-system` Namespace)
3. **StorageClass** muss vorhanden sein (z.B. `local-path`)

## Deployment

### Option 1: Mit kubectl (Manifeste) - **EMPFOHLEN**

```bash
# Alle Manifeste auf einmal anwenden:
kubectl apply -k k8s/pihole/

# Oder einzeln:
# 1. Namespace erstellen
kubectl apply -f k8s/pihole/namespace.yaml

# 2. ConfigMaps erstellen
kubectl apply -f k8s/pihole/configmap.yaml
kubectl apply -f k8s/pihole/pihole-toml-configmap.yaml
kubectl apply -f k8s/pihole/adlists-configmap.yaml
kubectl apply -f k8s/pihole/dnsmasq-configmap.yaml

# 3. Secret erstellen (optional, für Web-Passwort)
kubectl apply -f k8s/pihole/secret.yaml

# 4. PersistentVolumeClaim erstellen
kubectl apply -f k8s/pihole/pvc.yaml

# 5. Deployment erstellen
kubectl apply -f k8s/pihole/deployment.yaml

# 6. Service erstellen
kubectl apply -f k8s/pihole/service.yaml

# 7. Ingress erstellen (optional)
kubectl apply -f k8s/pihole/ingress.yaml
```

### Option 2: Mit Helm (Empfohlen)

```bash
# 1. Helm Repo hinzufügen
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update

# 2. Pi-hole installieren
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

## Prüfung

### Pod-Status

```bash
kubectl get pods -n pihole
kubectl logs -n pihole -l app=pihole
```

### Service-Status

```bash
kubectl get svc -n pihole
kubectl describe svc pihole -n pihole
```

### DNS-Test

```bash
# DNS-Abfrage testen (vom Server aus)
dig @127.0.0.1 google.de
dig @192.168.178.54 google.de
dig @192.168.178.54 argocd.k8sops.online

# Ad-Blocking testen
dig @192.168.178.54 doubleclick.net
# Erwartung: 0.0.0.0 (blockiert)

# Webinterface testen
curl -k https://pihole.k8sops.online/admin/
```

### MetallB IP-Pool prüfen

```bash
kubectl get ipaddresspool -n metallb-system
kubectl describe ipaddresspool pihole-pool -n metallb-system
```

## Konfiguration

### Wichtige ConfigMaps

1. **pihole-config**: Umgebungsvariablen (ServerIP, DNS, etc.)
2. **pihole-toml-config**: Pi-hole Hauptkonfiguration (pihole.toml)
3. **pihole-adlists-config**: Ad-Blocker-Listen (adlists.list)
4. **pihole-dnsmasq-custom**: Custom dnsmasq-Konfiguration

### Web-Passwort setzen

```bash
# Secret aktualisieren
kubectl create secret generic pihole-secret \
  --from-literal=WEBPASSWORD='dein-passwort-hier' \
  --namespace pihole \
  --dry-run=client -o yaml | kubectl apply -f -

# Pod neu starten
kubectl rollout restart deployment pihole -n pihole
```

### Upstream DNS ändern

```bash
# ConfigMap bearbeiten
kubectl edit configmap pihole-config -n pihole

# PIHOLE_DNS_ Wert ändern, z.B.:
# PIHOLE_DNS_: "1.1.1.1;1.0.0.1"

# Oder pihole.toml ConfigMap bearbeiten:
kubectl edit configmap pihole-toml-config -n pihole

# Pod neu starten
kubectl rollout restart deployment pihole -n pihole
```

### Ad-Blocker-Listen hinzufügen/ändern

**Methode 1: ConfigMap aktualisieren** (empfohlen)
```bash
# ConfigMap bearbeiten
kubectl edit configmap pihole-adlists-config -n pihole

# Listen hinzufügen (eine URL pro Zeile)
# Pod neu starten
kubectl rollout restart deployment pihole -n pihole
```

**Methode 2: Über API** (für einzelne Listen)
```bash
# Script verwenden
./scripts/pihole-add-adlists.sh

# Oder manuell:
kubectl exec -n pihole $(kubectl get pod -n pihole -l app=pihole -o jsonpath='{.items[0].metadata.name}') -- \
  curl -s "http://127.0.0.1:8080/admin/api.php?list=adlist&action=add&address=URL&auth=TOKEN"
```

### Custom DNS Records

Nach dem Deployment können Custom DNS Records über das Pi-hole Webinterface hinzugefügt werden:
- URL: https://pihole.k8sops.online/admin/
- Menü: Local DNS → DNS Records

Oder über API:
```bash
curl -X POST "http://192.168.178.10/admin/api.php" \
  -d "token=YOUR_API_TOKEN" \
  -d "action=addCustomDNS" \
  -d "domain=gitlab.k8sops.online" \
  -d "ip=192.168.178.54"
```

## Troubleshooting

### Pod startet nicht

```bash
# Pod-Logs prüfen
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

## Wichtige Konfigurationen

### Host-Netzwerk Modus
- **hostNetwork: true**: Pi-hole läuft direkt auf Host-Interfaces
- **IP**: 192.168.178.54 (Host-IP)
- **Port 53**: Direkt auf Host gebunden (TCP/UDP)
- **Vorteil**: Akzeptiert DNS-Anfragen aus Heimnetzwerk (192.168.178.0/24)

### FTL-Konfiguration (pihole.toml)
- **interface = "all"**: Lauscht auf allen Interfaces
- **dns_listeningMode = "all"**: Akzeptiert Anfragen von allen Netzwerken
- **webserver.port = "8080"**: Webserver auf Port 8080 (nginx-ingress nutzt 80)

### Ad-Blocker-Listen
- **10 Listen** vorkonfiguriert in `pihole-adlists-config` ConfigMap
- Listen werden beim Pod-Start automatisch geladen
- Gravity-Datenbank wird beim ersten Start erstellt

### CoreDNS Integration
- **Forward**: `forward . 192.168.178.54 8.8.8.8`
- Kubernetes Pods → CoreDNS → Pi-hole → Cloudflare

## Nächste Schritte

1. ✅ **Fritzbox DNS-Server ändern** auf 192.168.178.54 (bereits konfiguriert)
2. ✅ **CoreDNS Upstream** auf 192.168.178.54 (bereits aktualisiert)
3. ✅ **Ad-Blocker-Listen** eingerichtet (10 Listen)
4. ⏳ **Custom DNS Records** für `*.k8sops.online` über Pi-hole Web-Interface hinzufügen (optional)

## StorageClass

Falls `local-path` nicht vorhanden ist, kann eine andere StorageClass verwendet werden:

```bash
# Verfügbare StorageClasses prüfen
kubectl get storageclass

# PVC mit anderer StorageClass erstellen
kubectl patch pvc pihole-data -n pihole -p '{"spec":{"storageClassName":"<storageclass-name>"}}'
```

