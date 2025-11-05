# Docker-Container Analyse auf 192.168.178.54

## Gefundene Docker-Container

### 1. Pi-hole (KRITISCH - Port 53)
- **Container**: `pihole`
- **Image**: `feb8c881adba` (Pi-hole)
- **Ports**:
  - `0.0.0.0:53->53/tcp` ← **KRITISCH: Konflikt mit Kubernetes**
  - `0.0.0.0:53->53/udp` ← **KRITISCH: Konflikt mit Kubernetes**
  - `0.0.0.0:8053->80/tcp` (Webinterface)
  - `67/udp`, `123/udp`, `443/tcp`
- **Status**: Up 2 weeks (health: starting)
- **Problem**: Bindet direkt an Host-IP:53 (TCP/UDP)

### 2. nginx-reverse-proxy (KRITISCH - Port 80/443)
- **Container**: `nginx-reverse-proxy`
- **Image**: `nginx:alpine`
- **Ports**:
  - `0.0.0.0:80->80/tcp` ← **KRITISCH: Konflikt mit Kubernetes ingress-nginx**
  - `0.0.0.0:443->443/tcp` ← **KRITISCH: Konflikt mit Kubernetes ingress-nginx**
- **Status**: Up 3 weeks
- **Problem**: Bindet direkt an Host-IP:80/443

### 3. GitLab
- **Container**: `gitlab`
- **Image**: `gitlab/gitlab-ce:latest`
- **Ports**:
  - `0.0.0.0:8443->8443/tcp`
  - `0.0.0.0:8929->8929/tcp`
  - `0.0.0.0:2222->22/tcp`
  - `80/tcp`, `443/tcp` (intern)
- **Status**: Up 2 weeks (health: starting)
- **Hinweis**: GitLab läuft bereits in Kubernetes! → Doppelt vorhanden

### 4. Jenkins
- **Container**: `jenkins`
- **Image**: `jenkins/jenkins:lts`
- **Ports**:
  - `192.168.178.54:8080->8080/tcp`
  - `192.168.178.54:50000->50000/tcp`
- **Status**: Up 3 weeks
- **Hinweis**: Jenkins läuft bereits in Kubernetes! → Doppelt vorhanden

### 5. Jellyfin
- **Container**: `jellyfin`
- **Image**: `jellyfin/jellyfin:latest`
- **Ports**:
  - `0.0.0.0:8097->8096/tcp`
  - `0.0.0.0:8921->8920/tcp`
  - `0.0.0.0:7359->7359/udp`
- **Status**: Up 3 weeks (health: starting)
- **Hinweis**: Jellyfin läuft bereits in Kubernetes! → Doppelt vorhanden

### 6. libvirt-exporter
- **Container**: `libvirt-exporter`
- **Image**: `alekseizakharov/libvirt-exporter:latest`
- **Ports**: `192.168.178.54:9177->9177/tcp`
- **Status**: Up 3 weeks
- **Zweck**: Prometheus-Exporter für libvirt

### 7. cAdvisor
- **Container**: `cadvisor`
- **Image**: `gcr.io/cadvisor/cadvisor:latest`
- **Ports**: `192.168.178.54:8081->8080/tcp`
- **Status**: Up 3 weeks (health: starting)
- **Zweck**: Container-Metriken für Prometheus

## Port-Konflikte

### Aktuelle Port-Nutzung auf 192.168.178.54

| Port | Docker-Container | Kubernetes Service | Konflikt |
|------|------------------|-------------------|----------|
| **53/tcp** | Pi-hole | - | **JA** (für DNS) |
| **53/udp** | Pi-hole | - | **JA** (für DNS) |
| **80/tcp** | nginx-reverse-proxy | ingress-nginx LoadBalancer | **JA** |
| **443/tcp** | nginx-reverse-proxy | ingress-nginx LoadBalancer | **JA** |
| 8080 | Jenkins | - | Nein (spezifische IP) |
| 8081 | cAdvisor | - | Nein (spezifische IP) |
| 8097 | Jellyfin | - | Nein |
| 8443 | GitLab | - | Nein |
| 8929 | GitLab | - | Nein |
| 9177 | libvirt-exporter | - | Nein (spezifische IP) |

## Warum es aktuell funktioniert

### Port 53 (DNS)
- **Docker Pi-hole**: Bindet direkt an `0.0.0.0:53` (Host-IP)
- **Kubernetes CoreDNS**: Läuft in Pods (10.244.0.2/3), nicht direkt auf Host-IP
- **Fritzbox DNS**: Zeigt auf 192.168.178.54 → Pi-hole Docker-Container antwortet
- **Funktioniert**: Weil Kubernetes CoreDNS nicht direkt auf Host-IP:53 lauscht

### Port 80/443 (HTTP/HTTPS)
- **Docker nginx-reverse-proxy**: Bindet direkt an `0.0.0.0:80/443` (Host-IP)
- **Kubernetes ingress-nginx**: 
  - NodePort: 30827 (80), 30941 (443)
  - LoadBalancer: 192.168.178.54 (MetallB L2)
  - **Problem**: MetallB arbeitet auf Layer 2, aber Traffic zu :80/443 geht an Docker-Container!
- **Funktioniert NICHT korrekt**: Kubernetes ingress-nginx wird von Docker-Container blockiert

## Analyse: Kubernetes ingress-nginx

**Aktuell:**
- Kubernetes ingress-nginx läuft auf NodePort 30827/30941
- MetallB LoadBalancer zeigt auf 192.168.178.54
- Aber: Port 80/443 ist von Docker nginx-reverse-proxy belegt

**Wie funktioniert es trotzdem?**
- Vermutlich: Docker nginx-reverse-proxy leitet Traffic zu Kubernetes weiter (Reverse Proxy)
- Oder: Kubernetes Services werden über NodePort direkt aufgerufen (30827/30941)
- **Nicht optimal**: MetallB LoadBalancer IP funktioniert nicht für Port 80/443

## Doppelte Services

### GitLab
- **Docker**: Port 8443, 8929, 2222
- **Kubernetes**: gitlab.k8sops.online (via ingress-nginx)
- **Empfehlung**: Docker-Container stoppen, nur Kubernetes verwenden

### Jenkins
- **Docker**: Port 8080, 50000 (auf 192.168.178.54)
- **Kubernetes**: jenkins.k8sops.online (via ingress-nginx)
- **Empfehlung**: Docker-Container stoppen, nur Kubernetes verwenden

### Jellyfin
- **Docker**: Port 8097, 8921
- **Kubernetes**: jellyfin.k8sops.online (via ingress-nginx)
- **Empfehlung**: Docker-Container stoppen, nur Kubernetes verwenden

## Migrationsprioritäten

### Priorität 1 (Kritisch - Port-Konflikte)
1. **Pi-hole**: Docker → Kubernetes (Port 53 freigeben)
2. **nginx-reverse-proxy**: Entfernen oder migrieren (Port 80/443 freigeben)

### Priorität 2 (Doppelte Services)
3. **GitLab**: Docker-Container stoppen (läuft bereits in Kubernetes)
4. **Jenkins**: Docker-Container stoppen (läuft bereits in Kubernetes)
5. **Jellyfin**: Docker-Container stoppen (läuft bereits in Kubernetes)

### Priorität 3 (Monitoring)
6. **libvirt-exporter**: In Kubernetes migrieren (optional)
7. **cAdvisor**: In Kubernetes migrieren (optional, läuft oft als DaemonSet)

## Nächste Schritte

1. **Pi-hole Konfiguration exportieren** (vor Migration)
2. **Pi-hole in Kubernetes deployen** (neue IP: 192.168.178.10)
3. **nginx-reverse-proxy analysieren** (was macht er genau?)
4. **Doppelte Docker-Container stoppen**
5. **Port-Konflikte beheben**

