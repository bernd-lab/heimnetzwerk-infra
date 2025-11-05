# Pi-hole Kubernetes Deployment

**Erstellt**: 2025-11-05  
**Zweck**: Pi-hole als Kubernetes Service deployen (IP: 192.168.178.10)

## Voraussetzungen

1. **Kubernetes-Cluster** muss erreichbar sein
2. **MetallB** muss installiert sein (`metallb-system` Namespace)
3. **StorageClass** muss vorhanden sein (z.B. `local-path`)

## Deployment

### Option 1: Mit kubectl (Manifeste)

```bash
# 1. Namespace erstellen
kubectl apply -f k8s/pihole/namespace.yaml

# 2. MetallB IP-Pool erweitern (falls 192.168.178.10 noch nicht im Pool)
kubectl apply -f k8s/pihole/metallb-pool.yaml

# 3. ConfigMap erstellen
kubectl apply -f k8s/pihole/configmap.yaml

# 4. Secret erstellen (optional, für Web-Passwort)
kubectl apply -f k8s/pihole/secret.yaml

# 5. PersistentVolumeClaim erstellen
kubectl apply -f k8s/pihole/pvc.yaml

# 6. Deployment erstellen
kubectl apply -f k8s/pihole/deployment.yaml

# 7. Service erstellen
kubectl apply -f k8s/pihole/service.yaml

# Oder alles auf einmal:
kubectl apply -k k8s/pihole/
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
# DNS-Abfrage testen
dig @192.168.178.10 google.de
dig @192.168.178.10 pihole.k8sops.online

# Webinterface testen
curl http://192.168.178.10/admin
```

### MetallB IP-Pool prüfen

```bash
kubectl get ipaddresspool -n metallb-system
kubectl describe ipaddresspool pihole-pool -n metallb-system
```

## Konfiguration

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

# Pod neu starten
kubectl rollout restart deployment pihole -n pihole
```

### Custom DNS Records

Nach dem Deployment können Custom DNS Records über das Pi-hole Webinterface hinzugefügt werden:
- URL: http://192.168.178.10/admin
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

## Nächste Schritte

1. **Fritzbox DNS-Server ändern** auf 192.168.178.10
2. **CoreDNS Upstream ändern** auf 192.168.178.10
3. **Custom DNS Records** für `*.k8sops.online` hinzufügen

## StorageClass

Falls `local-path` nicht vorhanden ist, kann eine andere StorageClass verwendet werden:

```bash
# Verfügbare StorageClasses prüfen
kubectl get storageclass

# PVC mit anderer StorageClass erstellen
kubectl patch pvc pihole-data -n pihole -p '{"spec":{"storageClassName":"<storageclass-name>"}}'
```

