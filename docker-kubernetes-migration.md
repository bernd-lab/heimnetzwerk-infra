# Docker zu Kubernetes Migration Plan

## Aktuelle Situation

### Host-System: 192.168.178.54 ("zuhause")

**Gleichzeitig:**
- Docker-Host (Container laufen direkt auf dem Host)
- Kubernetes Node (kubeadm-basiert)
- MetallB LoadBalancer (192.168.178.54)

**Problematik:**
- Port-Konflikte zwischen Docker-Containern und Kubernetes Services
- Pi-hole läuft vermutlich in Docker auf Port 53
- Kubernetes ingress-nginx nutzt Port 80/443 (via NodePort 30827/30941)

## Wie funktioniert es aktuell?

### Port-Bindings

**Docker-Container:**
- Binden direkt an Host-IP (z.B. `-p 53:53/udp -p 53:53/tcp`)
- Nutzen iptables/netfilter für Port-Weiterleitung

**Kubernetes Services:**
- **NodePort**: Binden an Host-IP auf hohen Ports (30827, 30941)
- **LoadBalancer (MetallB L2)**: 
  - Nutzt ARP/NDP (Address Resolution Protocol)
  - Bindet nicht direkt an Port, sondern arbeitet auf Layer 2
  - Traffic wird über iptables zu Pods weitergeleitet

### Warum es funktioniert (aktuell)

**Port 53 (DNS):**
- Docker-Container: Binden direkt an 192.168.178.54:53
- Kubernetes: Nutzt CoreDNS in Pods (10.244.0.2/3), nicht direkt auf Host-IP:53

**Port 80/443 (HTTP/HTTPS):**
- Kubernetes ingress-nginx: NodePort 30827/30941
- MetallB LoadBalancer: ARP-Announcement für 192.168.178.54
- Traffic zu 192.168.178.54:80/443 wird über iptables zu NodePort weitergeleitet

**Konflikt:**
- Wenn Docker-Container auf 192.168.178.54:80/443 lauscht → Konflikt mit Kubernetes
- Wenn Docker-Container auf 192.168.178.54:53 lauscht → Läuft aktuell (Pi-hole vermutlich)

## Migration: Docker → Kubernetes

### Schritt 1: Docker-Container identifiziert ✅

**Gefundene Container:**
1. **Pi-hole** (Port 53 TCP/UDP) - KRITISCH
2. **nginx-reverse-proxy** (Port 80/443) - KRITISCH
3. **GitLab** (Port 8443, 8929, 2222) - Doppelt (läuft auch in Kubernetes)
4. **Jenkins** (Port 8080, 50000) - Doppelt (läuft auch in Kubernetes)
5. **Jellyfin** (Port 8097, 8921) - Doppelt (läuft auch in Kubernetes)
6. **libvirt-exporter** (Port 9177) - Monitoring
7. **cAdvisor** (Port 8081) - Monitoring

**nginx-reverse-proxy Funktion:**
- Reverse Proxy für Docker-Container auf `*.bernd.local` Domains
- Konfiguration: `/home/bernd/nginx-reverse-proxy/nginx.conf`
- Zertifikate: `/home/bernd/nginx-reverse-proxy/certs/`
- Leitet weiter zu:
  - `jenkins.bernd.local` → Docker Jenkins (172.20.0.30:8080)
  - `gitlab.bernd.local` → Docker GitLab
  - `pihole.bernd.local` → Docker Pi-hole

### Schritt 2: Port-Konflikte analysieren

**Aktuelle Port-Nutzung:**

| Port | Service | Typ |
|------|---------|-----|
| 53 | Docker (Pi-hole?) | Host-Binding |
| 80 | Kubernetes ingress-nginx | NodePort → LoadBalancer |
| 443 | Kubernetes ingress-nginx | NodePort → LoadBalancer |
| 30827 | Kubernetes ingress-nginx | NodePort |
| 30941 | Kubernetes ingress-nginx | NodePort |

**Konflikt-Szenarien:**
- Docker-Container auf Port 80/443 → Blockiert Kubernetes ingress-nginx
- Docker-Container auf Port 53 → Läuft parallel (anders als Kubernetes)

### Schritt 3: Pi-hole Migration

**Option A: Pi-hole in Kubernetes (Empfohlen)**

**Vorteile:**
- Konsistente Container-Orchestrierung
- Einfacheres Management (kubectl)
- Integration mit Kubernetes DNS
- Keine Port-Konflikte

**Konfiguration:**
```yaml
# Pi-hole als Kubernetes Service
apiVersion: v1
kind: Service
metadata:
  name: pihole
  namespace: default
spec:
  type: LoadBalancer
  loadBalancerIP: 192.168.178.10  # Neue IP außerhalb DHCP-Bereich
  ports:
  - port: 53
    protocol: UDP
    name: dns-udp
  - port: 53
    protocol: TCP
    name: dns-tcp
  - port: 80
    protocol: TCP
    name: web
```

**Option B: Pi-hole als HostNetwork Pod**

**Vorteile:**
- Kann direkt auf Port 53 lauschen
- Keine Port-Weiterleitung nötig

**Nachteile:**
- Port-Konflikt mit Docker-Container (während Migration)
- Weniger isoliert

### Schritt 4: DNS-Stack nach Migration

**Neuer Flow:**
```
Clients → Fritzbox DHCP (192.168.178.10) → Pi-hole (Kubernetes) → Cloudflare → Internet
```

**Fritzbox Konfiguration:**
- Lokaler DNS-Server: 192.168.178.10 (Pi-hole Kubernetes Service)

**CoreDNS Konfiguration:**
```yaml
forward . 192.168.178.10  # Pi-hole Kubernetes Service
```

**nginx-reverse-proxy:**
- **Entfernen**: Kubernetes ingress-nginx übernimmt diese Funktion
- **Domains**: `*.bernd.local` → `*.k8sops.online` (bereits vorhanden)
- **Zertifikate**: Cert-Manager übernimmt Let's Encrypt-Zertifikate

## Migration-Ablauf

### Phase 1: Vorbereitung

1. **Docker-Container inventarisieren:**
   ```bash
   docker ps -a > docker-containers-backup.txt
   docker images > docker-images-backup.txt
   ```

2. **Pi-hole Konfiguration exportieren:**
   ```bash
   docker exec pihole cat /etc/pihole/setupVars.conf > pihole-config-backup.conf
   docker exec pihole cat /etc/pihole/adlists.list > pihole-adlists-backup.list
   ```

3. **Kubernetes Namespace erstellen:**
   ```bash
   kubectl create namespace pihole
   ```

### Phase 2: Pi-hole in Kubernetes deployen

1. **Pi-hole Deployment erstellen:**
   - Helm Chart: `pihole/pihole`
   - Oder: Manifests manuell erstellen

2. **Service mit neuer IP:**
   - MetallB IP-Pool erweitern: 192.168.178.10
   - Service-Typ: LoadBalancer

3. **PersistentVolume für Konfiguration:**
   - Config-Dateien persistent speichern
   - Whitelist/Blacklist über ConfigMap/Volume

### Phase 3: DNS-Umstellung

1. **Pi-hole Kubernetes Service starten:**
   - Neue IP: 192.168.178.10
   - Test: `dig @192.168.178.10 google.com`

2. **Fritzbox DNS-Server ändern:**
   - Alt: 192.168.178.54
   - Neu: 192.168.178.10

3. **CoreDNS Upstream ändern:**
   - Alt: Forward zu Fritzbox
   - Neu: Forward zu Pi-hole (192.168.178.10)

### Phase 4: Docker-Container stoppen

1. **Pi-hole Docker-Container stoppen:**
   ```bash
   docker stop pihole
   docker rm pihole  # Optional: nach Verifizierung
   ```

2. **Weitere Docker-Container prüfen:**
   - Migrieren oder stoppen

3. **Port-Freigabe verifizieren:**
   ```bash
   ss -tlnp | grep 192.168.178.54
   ```

### Phase 5: Verifizierung

1. **DNS-Test:**
   ```bash
   dig @192.168.178.10 google.com
   dig @192.168.178.10 pihole.k8sops.online
   ```

2. **Pi-hole Webinterface:**
   - http://192.168.178.10/admin

3. **Kubernetes Services:**
   - Alle Services erreichbar
   - Cert-Manager funktioniert weiterhin

## Port-Konflikt-Lösung

### Warum Docker und Kubernetes parallel funktionieren können

**Layer 2 (MetallB L2 Mode):**
- MetallB bindet nicht direkt an Ports
- Nutzt ARP-Announcements
- Traffic wird über iptables zu Pods weitergeleitet

**Docker Port-Bindings:**
- Binden direkt an Host-IP:Port
- Nutzen iptables/netfilter

**Konflikt nur wenn:**
- Docker-Container und Kubernetes Service beide auf gleichem Port der Host-IP lauschen
- Beispiel: Docker auf :80, Kubernetes ingress-nginx auf :80

**Lösung:**
- Docker-Container auf andere Ports verschieben
- Oder: Kubernetes Services nutzen NodePort auf hohen Ports (aktuell)

## Empfehlungen

### Kurzfristig
1. ✅ Docker-Container inventarisieren
2. ✅ Pi-hole Konfiguration exportieren
3. ✅ Kubernetes Pi-hole Deployment vorbereiten

### Mittelfristig
1. ✅ Pi-hole in Kubernetes deployen (neue IP: 192.168.178.10)
2. ✅ DNS-Umstellung (Fritzbox + CoreDNS)
3. ✅ Docker-Container stoppen

### Langfristig
1. ✅ Alle Docker-Container nach Kubernetes migrieren
2. ✅ Docker auf Host deinstallieren (optional)
3. ✅ CMDB (NetBox) für Infrastruktur-Dokumentation

## Offene Fragen

1. **Welche Docker-Container laufen noch?**
   - Pi-hole sicher
   - Weitere Container?

2. **Pi-hole Konfiguration:**
   - Blocklisten
   - Custom DNS Records
   - Whitelist/Blacklist

3. **Weitere Docker-Container:**
   - Sollen diese auch migriert werden?
   - Oder nur Pi-hole?

