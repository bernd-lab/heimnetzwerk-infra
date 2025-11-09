# Hersteller-Empfehlungen für Ressourcen-Konfiguration

**Datum**: 2025-11-07  
**Status**: Recherche abgeschlossen

## Jellyfin

**Offizielle Empfehlungen**:
- **Basis-Nutzung** (1-2 Streams): 2-4 cores, 4-8GB RAM
- **Mittel-Nutzung** (3-5 Streams): 4-6 cores, 8-12GB RAM
- **Hohe Nutzung** (6+ Streams): 6-8+ cores, 12-16GB+ RAM
- **Hardware-Beschleunigung**: GPU empfohlen (NVIDIA GTX16/RTX20+ oder Intel UHD 710+)

**Empfohlene Konfiguration für Performance**:
- CPU Request: 2500-3000m (2.5-3 cores garantiert)
- CPU Limit: 4 cores (alle verfügbaren CPUs)
- Memory Request: 12Gi (großzügig für Bibliotheks-Scans)
- Memory Limit: 16Gi

## GitLab CE

**Offizielle Empfehlungen**:
- **Minimum**: 4 cores, 4GB RAM
- **Empfohlen**: 8+ cores, 8GB+ RAM
- **Für kleine Installationen**: 2-4 cores, 4-8GB RAM

**Empfohlene Konfiguration**:
- CPU Request: 800-1000m (1 core garantiert)
- CPU Limit: 2 cores
- Memory Request: 4Gi
- Memory Limit: 6Gi

## GitLab PostgreSQL

**Offizielle Empfehlungen**:
- **Kleine Installationen**: 1-2 cores, 2-4GB RAM
- **Mittlere Installationen**: 2-4 cores, 4-8GB RAM

**Empfohlene Konfiguration**:
- CPU Request: 400-500m (0.4-0.5 cores garantiert)
- CPU Limit: 1 core
- Memory Request: 1Gi
- Memory Limit: 2Gi

## GitLab Redis

**Offizielle Empfehlungen**:
- **Kleine Installationen**: 1 core, 1-2GB RAM
- **Mittlere Installationen**: 1-2 cores, 2-4GB RAM

**Empfohlene Konfiguration**:
- CPU Request: 200m
- CPU Limit: 500m (0.5 cores max)
- Memory Request: 512Mi
- Memory Limit: 1Gi

## Pi-hole

**Offizielle Empfehlungen**:
- **Minimum**: 1 core, 512MB RAM
- **Empfohlen**: 1-2 cores, 1GB RAM für größere Blocklisten

**Empfohlene Konfiguration**:
- CPU Request: 100m
- CPU Limit: 500m
- Memory Request: 512Mi
- Memory Limit: 1Gi

## GitLab Runner

**Offizielle Empfehlungen**:
- Variabel je nach Workload
- Typisch: 100-500m CPU, 256-512Mi RAM pro Runner

**Empfohlene Konfiguration**:
- CPU Request: 200m
- CPU Limit: 500m
- Memory Request: 256Mi
- Memory Limit: 512Mi

## Ingress-NGINX Controller

**Offizielle Empfehlungen**:
- **Kleiner Traffic**: 1 core, 512Mi RAM
- **Mittlerer Traffic**: 1-2 cores, 512Mi-1Gi RAM
- **Hoher Traffic**: 2+ cores, 1Gi+ RAM

**Empfohlene Konfiguration**:
- CPU Request: 200m
- CPU Limit: 1 core
- Memory Request: 256Mi
- Memory Limit: 512Mi

## ArgoCD

**Offizielle Empfehlungen**:
- **application-controller**: 200-500m CPU, 512Mi-1Gi RAM
- **repo-server**: 200-500m CPU, 512Mi-1Gi RAM
- **server**: 100-200m CPU, 256-512Mi RAM
- **dex-server**: 100-200m CPU, 256-512Mi RAM
- **notifications-controller**: 100-200m CPU, 256-512Mi RAM
- **redis**: 100-200m CPU, 256-512Mi RAM

**Empfohlene Konfiguration**:
- **application-controller**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **repo-server**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **server**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **dex-server**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **notifications-controller**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **redis**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi

## Cert-Manager

**Offizielle Empfehlungen**:
- **controller**: 100-200m CPU, 128-256Mi RAM
- **cainjector**: 50-100m CPU, 128-256Mi RAM
- **webhook**: 50-100m CPU, 128-256Mi RAM

**Empfohlene Konfiguration**:
- **controller**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **cainjector**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi
- **webhook**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi

## CoreDNS

**Offizielle Empfehlungen**:
- 100-200m CPU, 128-256Mi RAM pro Pod

**Empfohlene Konfiguration**:
- CPU Request: 100m, Limit: 500m
- Memory Request: 128Mi, Limit: 256Mi

## MetalLB

**Offizielle Empfehlungen**:
- **controller**: Minimal, typisch 50-100m CPU, 64-128Mi RAM
- **speaker**: Minimal, typisch 50-100m CPU, 64-128Mi RAM

**Empfohlene Konfiguration**:
- **controller**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi
- **speaker**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi

## Velero

**Offizielle Empfehlungen**:
- Variabel je nach Backup-Größe
- Typisch: 500m-1 CPU, 512Mi-1Gi RAM

**Empfohlene Konfiguration**:
- CPU Request: 200m, Limit: 1
- Memory Request: 512Mi, Limit: 1Gi

## NFS Provisioner

**Offizielle Empfehlungen**:
- Minimal, typisch 50-100m CPU, 128-256Mi RAM pro Instanz

**Empfohlene Konfiguration**:
- CPU Request: 50m, Limit: 200m
- Memory Request: 128Mi, Limit: 256Mi

## Weitere Services

### Prometheus
- CPU Request: 500m, Limit: 2
- Memory Request: 2Gi, Limit: 4Gi

### Grafana
- CPU Request: 200m, Limit: 1
- Memory Request: 512Mi, Limit: 1Gi

### Loki
- CPU Request: 200m, Limit: 1
- Memory Request: 512Mi, Limit: 1Gi

### Komga
- CPU Request: 200m, Limit: 1
- Memory Request: 512Mi, Limit: 1Gi

### Syncthing
- CPU Request: 200m, Limit: 1
- Memory Request: 512Mi, Limit: 1Gi

### PlantUML
- CPU Request: 100m, Limit: 500m
- Memory Request: 256Mi, Limit: 512Mi

### Heimdall
- CPU Request: 100m, Limit: 500m
- Memory Request: 256Mi, Limit: 512Mi

### Kubernetes Dashboard
- CPU Request: 100m, Limit: 500m
- Memory Request: 256Mi, Limit: 512Mi

### GitLab Agent
- CPU Request: 100m, Limit: 500m
- Memory Request: 256Mi, Limit: 512Mi

