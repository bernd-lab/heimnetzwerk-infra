# GitLab Erreichbarkeit-Analyse

**Datum**: 2025-11-06 15:30  
**Status**: 🔴 **KRITISCH - GitLab nicht erreichbar**

## Problem

GitLab ist von außen nicht erreichbar:
- `curl https://gitlab.k8sops.online` → Timeout nach 2+ Minuten
- Git-Push zu GitLab schlägt fehl

## Aktuelle Konfiguration

### GitLab-Pods
- ✅ `gitlab-5b58f85bb9-ps8sb`: Running (1/1 Ready)
- ✅ `gitlab-postgresql-0`: Running (1/1 Ready)
- ✅ `gitlab-redis-master-0`: Running (1/1 Ready)

### GitLab-Service
- **Name**: `gitlab`
- **Type**: ClusterIP
- **Cluster-IP**: 10.105.61.1
- **Ports**: 80/TCP, 22/TCP
- **Endpoints**: 10.244.0.141:80, 10.244.0.141:22 ✅

### Ingress
- **Name**: `gitlab`
- **Class**: nginx
- **Host**: gitlab.k8sops.online
- **Address**: 192.168.178.54
- **Ports**: 80, 443

### DNS
- ✅ `gitlab.k8sops.online` → 192.168.178.54 (korrekt aufgelöst)

### Ingress-Controller
- ✅ `ingress-nginx-controller-6fb6bc46cb-qhh2l`: Running (1/1 Ready)
- **Service**: LoadBalancer (192.168.178.54)
- **NodePort**: 80→30827, 443→30941
- **MetalLB**: ✅ IP zugewiesen (192.168.178.54 VIP)

### Zertifikat
- ✅ `gitlab-tls`: Ready (True)

## Diagnose-Ergebnisse

### ✅ Funktioniert
- GitLab-Pods: Running (1/1 Ready)
- GitLab-Service: ClusterIP 10.105.61.1, Endpoints 10.244.0.141:80
- GitLab-Pod Health: ✅ "GitLab OK" (direkter Pod-Zugriff)
- Zertifikat: ✅ `gitlab-tls` (Ready, True)
- DNS: ✅ `gitlab.k8sops.online` → 192.168.178.54
- Ingress: ✅ Konfiguriert mit nginx, Backend: gitlab:80
- MetalLB: ✅ IP zugewiesen (192.168.178.54 VIP)
- IP auf Interface: ✅ `br0` (192.168.178.54/24)

### ❌ Problem
- **Ports 80/443 nicht gebunden**: `ss -tlnp` zeigt keine Ports 80/443 auf 192.168.178.54
- **Externe Requests**: Timeout (HTTP und HTTPS)
- **Ingress-Logs**: Nur interne Requests (GitLab-KAS), keine externen Requests
- **Vermutung**: Port 80/443 wird von Docker-Container blockiert (nginx-reverse-proxy)

## Root Cause Analysis

### Port-Konflikt vermutet

Laut `docker-kubernetes-migration.md`:
- **Docker nginx-reverse-proxy**: Bindet an `0.0.0.0:80/443`
- **Kubernetes ingress-nginx**: NodePort 30827/30941, LoadBalancer 192.168.178.54
- **Problem**: Docker-Container blockiert Port 80/443, daher kann Ingress-Controller nicht darauf zugreifen

### MetalLB L2-Mode

MetalLB arbeitet im L2-Mode (VIP):
- Bindet nicht direkt Ports auf dem Host
- Nutzt ARP/NDP für IP-Announcement
- Traffic wird über iptables zu NodePort weitergeleitet
- **Aber**: Wenn Port 80/443 von Docker belegt ist, funktioniert das nicht!

## Nächste Schritte

1. ⏳ **Docker-Container prüfen**: `docker ps | grep nginx`
2. ⏳ **Port-Besetzung prüfen**: `lsof -i :80 -i :443`
3. ⏳ **Docker-Container stoppen** (falls nginx-reverse-proxy noch läuft)
4. ⏳ **Ports freigeben** für Kubernetes Ingress-Controller
5. ⏳ **GitLab-Erreichbarkeit testen**

## Relevante Agenten

- **k8s-expert**: Kubernetes-Service/Ingress-Konfiguration, MetalLB
- **network-expert**: Port-Konflikte, Docker-Container, Netzwerk-Routing
- **gitlab-github-expert**: GitLab-Konfiguration, Repository-Management

## Dokumentation

- `docker-kubernetes-migration.md` - Port-Konflikte zwischen Docker und Kubernetes
- `docker-container-analyse.md` - Docker-Container-Analyse
- `kubernetes-analyse.md` - Kubernetes-Cluster-Analyse
