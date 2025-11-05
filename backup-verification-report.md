# Backup und Verifikations-Report

## GitLab

### Docker-Container Status
- **Status**: Running (Up 2 weeks, health: starting)
- **Ports**: 8443, 8929, 2222
- **Volumes**:
  - `bernd_gitlab_config` → `/etc/gitlab`
  - `bernd_gitlab_logs` → `/var/log/gitlab`
  - `bernd_gitlab_data` → `/var/opt/gitlab` (vermutlich)

### Kubernetes Status
- **Pods**: Running (gitlab-6bd6446c6f-fbltz, 434 Restarts - möglicherweise instabil)
- **Services**: ClusterIP (gitlab, postgresql, redis)
- **Ingress**: `gitlab.k8sops.online` auf 192.168.178.54:80/443
- **PVCs**: 
  - gitlab-config (5Gi)
  - gitlab-data (50Gi)
  - data-gitlab-postgresql-0 (10Gi)
  - redis-data-gitlab-redis-master-0 (5Gi)
- **HTTPS-Test**: ❌ Timeout (Port 443 möglicherweise blockiert durch nginx-reverse-proxy)

### Backup-Notwendigkeit
- **Kritisch**: GitLab enthält wichtige Daten (Repositories, Issues, etc.)
- **Backup**: Docker Volumes sichern bevor Container gestoppt wird
- **Verifikation**: Kubernetes-Version prüfen ob Daten vorhanden

### GitLab Backup Status
- ✅ **Config Backup**: 384K (`/tmp/docker-backups/gitlab-config`)
- ✅ **Data Backup**: 3.7G (`/tmp/docker-backups/gitlab-data`)
- ⚠️ **Kubernetes Status**: Läuft, aber 434 Restarts (instabil)
- ⚠️ **HTTPS**: Nicht erreichbar (Port 443 blockiert durch nginx-reverse-proxy)

## Jenkins

### Docker-Container Status
- **Status**: Running (Up 3 weeks)
- **Ports**: 192.168.178.54:8080, 192.168.178.54:50000
- **Volume**: `jenkins_home_new` → `/var/jenkins_home`

### Kubernetes Status
- **Pod**: Running (jenkins-577d48d8d7-fvkq6, 0 Restarts - stabil)
- **Ingress**: `jenkins.k8sops.online` auf 192.168.178.54:80/443
- **HTTP-Test**: Zu prüfen

### Backup-Notwendigkeit
- **Kritisch**: Jenkins Jobs und Konfiguration
- **Backup**: `/var/jenkins_home` sichern

### Jenkins Backup Status
- ✅ **Home Backup**: 330M (`/tmp/docker-backups/jenkins-home`)
- ✅ **Kubernetes Status**: Läuft stabil (0 Restarts)
- ✅ **PVC**: jenkins-data (50Gi) vorhanden
- ❌ **HTTP-Test**: Nicht erreichbar (Port 80 blockiert durch nginx-reverse-proxy)

## Jellyfin

### Docker-Container Status
- **Status**: Running (Up 3 weeks, health: starting)
- **Ports**: 8097, 8921, 7359
- **Volumes**:
  - Bind Mount: `/DATA/AppData/jellyfin/config` → `/config`
  - Bind Mount: Media-Ordner (Filme, Vertical, etc.)

### Kubernetes Status
- **Pod**: Running (jellyfin-76b547597b-527cm, 0 Restarts - stabil)
- **Ingress**: `jellyfin.k8sops.online` auf 192.168.178.54:80/443
- **PVCs**:
  - jellyfin-config (10Gi)
  - jellyfin-data (20Gi)
  - jellyfin-media (500Gi)
  - jellyfin-filme (500Gi)
  - jellyfin-vertical (100Gi)
  - jellyfin-heimatfilme (100Gi)
  - jellyfin-anime (100Gi)
- ❌ **HTTP-Test**: Nicht erreichbar (Port 80 blockiert durch nginx-reverse-proxy)

### Backup-Notwendigkeit
- **Kritisch**: Jellyfin Konfiguration und Medien-Metadaten
- **Backup**: `/DATA/AppData/jellyfin/config` sichern
- **Hinweis**: Media-Dateien sind bereits auf NFS/Storage (nicht in Docker Volume)

### Jellyfin Backup Status
- ⚠️ **Config Backup**: In Progress (Bind Mount, nicht Docker Volume)
- ✅ **Kubernetes Status**: Läuft stabil (0 Restarts)
- ✅ **PVCs**: Alle vorhanden und größer als Docker-Version

