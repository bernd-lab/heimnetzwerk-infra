# Migrationsplan: Docker → Kubernetes

## Aktuelle Situation

### Host: 192.168.178.54 ("zuhause")

**Gleichzeitig:**
- Docker-Host mit 7 Containern
- Kubernetes Node (kubeadm)
- MetallB LoadBalancer (192.168.178.54)

**Port-Konflikte:**
- Port 53: Pi-hole Docker vs. Kubernetes (DNS)
- Port 80/443: nginx-reverse-proxy Docker vs. Kubernetes ingress-nginx

**Doppelte Services:**
- GitLab: Docker + Kubernetes
- Jenkins: Docker + Kubernetes  
- Jellyfin: Docker + Kubernetes

## Warum funktioniert es aktuell?

### Port 53 (DNS)
- Docker Pi-hole bindet an `0.0.0.0:53` (Host-IP)
- Kubernetes CoreDNS läuft in Pods (10.244.0.2/3), nicht direkt auf Host-IP
- **Fritzbox DNS**: 192.168.178.54 → Pi-hole Docker antwortet
- **Funktioniert**: Weil Kubernetes CoreDNS nicht auf Host-IP:53 lauscht

### Port 80/443 (HTTP/HTTPS)
- Docker nginx-reverse-proxy bindet an `0.0.0.0:80/443`
- Kubernetes ingress-nginx: NodePort 30827/30941, LoadBalancer 192.168.178.54
- **Problem**: Traffic zu 192.168.178.54:80/443 geht an Docker-Container
- **Wie funktioniert es trotzdem?**
  - Docker nginx-reverse-proxy leitet zu Docker-Containern weiter
  - Kubernetes Services werden über NodePort direkt aufgerufen
  - Oder: Kubernetes ingress-nginx wird von Docker blockiert (nicht optimal)

## Migrationsstrategie

### Phase 1: Vorbereitung (Keine Downtime)

#### 1.1 Pi-hole Konfiguration exportieren
```bash
# Auf 192.168.178.54
docker exec pihole cat /etc/pihole/setupVars.conf > /tmp/pihole-config-backup.conf
docker exec pihole cat /etc/pihole/adlists.list > /tmp/pihole-adlists-backup.list
docker exec pihole sqlite3 /etc/pihole/gravity.db ".dump" > /tmp/pihole-gravity-backup.sql
```

#### 1.2 MetallB IP-Pool erweitern
```bash
kubectl get ipaddresspool -n metallb-system default-pool -o yaml
# Neue IP hinzufügen: 192.168.178.10
```

**Neue IP-Pool-Konfiguration:**
```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.178.54/32  # Kubernetes ingress-nginx
  - 192.168.178.10/32  # Pi-hole (neu)
```

#### 1.3 Pi-hole Kubernetes Deployment vorbereiten
- Helm Chart: `pihole/pihole` oder Manifests
- PersistentVolume für Konfiguration
- Service: LoadBalancer mit IP 192.168.178.10

### Phase 2: Pi-hole Migration (Kritisch)

#### 2.1 Pi-hole in Kubernetes deployen
```bash
# Helm installieren
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update

# Pi-hole installieren
helm install pihole mojo2600/pihole \
  --namespace pihole \
  --create-namespace \
  --set service.loadBalancerIP=192.168.178.10 \
  --set persistence.enabled=true
```

**Alternative: Manifests**
- Deployment, Service, PersistentVolumeClaim
- ConfigMap für Konfiguration

#### 2.2 Pi-hole Konfiguration importieren
- setupVars.conf → ConfigMap
- adlists.list → ConfigMap
- gravity.db → PersistentVolume (falls möglich)

#### 2.3 DNS-Test
```bash
# Pi-hole Kubernetes testen
dig @192.168.178.10 google.com
dig @192.168.178.10 pihole.k8sops.online

# Webinterface testen
curl http://192.168.178.10/admin
```

### Phase 3: DNS-Umstellung

#### 3.1 Fritzbox DNS-Server ändern
- Alt: 192.168.178.54 (Docker Pi-hole)
- Neu: 192.168.178.10 (Kubernetes Pi-hole)
- Fritzbox Webinterface: Heimnetz → Netzwerk → IPv4 → Lokaler DNS-Server

#### 3.2 CoreDNS Upstream ändern
```bash
kubectl edit configmap coredns -n kube-system
```

**Neue CoreDNS-Konfiguration:**
```yaml
forward . 192.168.178.10 {
  max_concurrent 1000
}
```

#### 3.3 Pi-hole Docker-Container stoppen
```bash
docker stop pihole
# Nach Verifizierung: docker rm pihole
```

### Phase 4: nginx-reverse-proxy entfernen

#### 4.1 Kubernetes ingress-nginx prüfen
- Alle Services sollten bereits über ingress-nginx erreichbar sein
- Domains: `*.k8sops.online` (bereits vorhanden)

#### 4.2 nginx-reverse-proxy stoppen
```bash
docker stop nginx-reverse-proxy
# Port 80/443 wird freigegeben
```

#### 4.3 Kubernetes ingress-nginx testen
```bash
# Sollte jetzt auf 192.168.178.54:80/443 funktionieren
curl -I http://192.168.178.54
curl -I https://192.168.178.54
```

### Phase 5: Doppelte Docker-Container stoppen

#### 5.1 GitLab Docker stoppen
```bash
docker stop gitlab
# GitLab läuft bereits in Kubernetes: gitlab.k8sops.online
```

#### 5.2 Jenkins Docker stoppen
```bash
docker stop jenkins
# Jenkins läuft bereits in Kubernetes: jenkins.k8sops.online
```

#### 5.3 Jellyfin Docker stoppen
```bash
docker stop jellyfin
# Jellyfin läuft bereits in Kubernetes: jellyfin.k8sops.online
```

### Phase 6: Monitoring-Container (Optional)

#### 6.1 libvirt-exporter
- Option A: In Kubernetes migrieren (DaemonSet)
- Option B: Behalten (Port 9177, kein Konflikt)

#### 6.2 cAdvisor
- Option A: Kubernetes DaemonSet (kubectl top)
- Option B: Behalten (Port 8081, kein Konflikt)

### Phase 7: Aufräumen

#### 7.1 Docker-Container entfernen
```bash
# Nach erfolgreicher Migration
docker rm pihole nginx-reverse-proxy gitlab jenkins jellyfin
```

#### 7.2 Docker-Images aufräumen
```bash
docker image prune -a
```

#### 7.3 Port-Freigabe verifizieren
```bash
ss -tlnp | grep -E '192.168.178.54|:53|:80|:443'
# Sollte nur Kubernetes zeigen
```

## Rollback-Plan

### Falls Probleme auftreten

#### Pi-hole Rollback
```bash
# Docker Pi-hole wieder starten
docker start pihole

# Fritzbox DNS zurück ändern: 192.168.178.54
```

#### nginx-reverse-proxy Rollback
```bash
docker start nginx-reverse-proxy
```

## Erfolgskriterien

### Nach Migration

- ✅ Pi-hole Kubernetes läuft auf 192.168.178.10
- ✅ DNS funktioniert (Clients → Pi-hole → Internet)
- ✅ Port 80/443 freigegeben für Kubernetes ingress-nginx
- ✅ Kubernetes ingress-nginx funktioniert auf 192.168.178.54:80/443
- ✅ Alle Kubernetes Services erreichbar über *.k8sops.online
- ✅ Docker-Container gestoppt (keine Konflikte)
- ✅ Cert-Manager funktioniert weiterhin

## Zeitplan

### Geschätzte Dauer

- **Phase 1 (Vorbereitung)**: 30 Minuten
- **Phase 2 (Pi-hole Migration)**: 1-2 Stunden
- **Phase 3 (DNS-Umstellung)**: 15 Minuten
- **Phase 4 (nginx-reverse-proxy)**: 15 Minuten
- **Phase 5 (Doppelte Container)**: 15 Minuten
- **Phase 6 (Monitoring)**: Optional, 30 Minuten
- **Phase 7 (Aufräumen)**: 15 Minuten

**Gesamt**: ~3-4 Stunden (mit Testing)

## Risiken

### Niedrig
- Monitoring-Container (libvirt-exporter, cAdvisor)
- Doppelte Services (GitLab, Jenkins, Jellyfin)

### Mittel
- nginx-reverse-proxy (aber Kubernetes ingress-nginx übernimmt)

### Hoch
- Pi-hole Migration (DNS-Kritisch)
- Port-Konflikte (80/443)

## Nächste Schritte

1. ✅ Pi-hole Konfiguration exportieren
2. ✅ MetallB IP-Pool erweitern (192.168.178.10)
3. ✅ Pi-hole Kubernetes Deployment erstellen
4. ✅ Schrittweise Migration durchführen
5. ✅ Verifizierung nach jedem Schritt

