# Aktuelle Ressourcen-Analyse aller Pods

**Datum**: 2025-11-07  
**Status**: Analyse abgeschlossen

## Node-Ressourcen

- **CPU**: 4 cores (4000m)
- **Memory**: ~32GB (32730572Ki = 31963Mi)
- **Pods**: Maximal 110 Pods möglich

## Aktuelle Ressourcen-Verteilung

### CPU Requests (Summe)
- Aktuell belegt: ~2151m (53.8% von 4000m)
- Verfügbar: ~1849m (46.2%)

### Memory Requests (Summe)
- Aktuell belegt: ~2055Mi (6.3% von ~32GB)
- Verfügbar: ~29908Mi (93.7%)

## Detaillierte Pod-Ressourcen

### Jellyfin (default/jellyfin)
- CPU Request: 1000m (1 core)
- CPU Limit: 4 cores
- Memory Request: 8Gi
- Memory Limit: 16Gi
- **Status**: Läuft, aber CPU Request könnte höher sein für Performance

### GitLab (gitlab/gitlab)
- CPU Request: 500m
- CPU Limit: 2 cores
- Memory Request: 3Gi
- Memory Limit: 5Gi
- **Status**: Läuft

### GitLab PostgreSQL (gitlab/gitlab-postgresql)
- CPU Request: 100m
- CPU Limit: nicht gesetzt
- Memory Request: 256Mi
- Memory Limit: nicht gesetzt
- **Status**: Läuft, aber könnte mehr Ressourcen nutzen

### GitLab Redis (gitlab/gitlab-redis-master)
- CPU Request: 50m
- CPU Limit: nicht gesetzt
- Memory Request: 128Mi
- Memory Limit: nicht gesetzt
- **Status**: Läuft, aber könnte mehr Ressourcen nutzen

### Pi-hole (pihole/pihole)
- CPU Request: 50m
- CPU Limit: 500m
- Memory Request: 256Mi
- Memory Limit: 512Mi
- **Status**: Läuft

### GitLab Runner (gitlab-runner/gitlab-runner)
- CPU Request: 100m (pro Pod, 2 Pods = 200m)
- CPU Limit: 500m
- Memory Request: 128Mi (pro Pod, 2 Pods = 256Mi)
- Memory Limit: 512Mi
- **Status**: Läuft

### Ingress-NGINX (ingress-nginx/ingress-nginx-controller)
- CPU Request: 100m
- CPU Limit: nicht gesetzt
- Memory Request: nicht gesetzt
- Memory Limit: 90Mi
- **Status**: Läuft, aber Memory Limit sehr niedrig

### ArgoCD Komponenten (argocd/)
- **application-controller**: Keine Ressourcen gesetzt
- **repo-server**: Keine Ressourcen gesetzt
- **server**: Keine Ressourcen gesetzt
- **dex-server**: Keine Ressourcen gesetzt
- **notifications-controller**: Keine Ressourcen gesetzt
- **redis**: Keine Ressourcen gesetzt
- **Status**: Alle laufen, aber keine Ressourcen-Limits gesetzt

### Cert-Manager Komponenten (cert-manager/)
- **controller**: Keine Ressourcen gesetzt
- **cainjector**: Keine Ressourcen gesetzt
- **webhook**: Keine Ressourcen gesetzt
- **Status**: Alle laufen, aber keine Ressourcen-Limits gesetzt

### CoreDNS (kube-system/coredns)
- CPU Request: nicht gesetzt
- CPU Limit: nicht gesetzt
- Memory Request: nicht gesetzt
- Memory Limit: nicht gesetzt
- **Status**: Läuft, aber keine Ressourcen-Limits gesetzt

### MetalLB (metallb-system/)
- **controller**: Keine Ressourcen gesetzt
- **speaker**: Keine Ressourcen gesetzt
- **Status**: Läuft, aber keine Ressourcen-Limits gesetzt

### Velero (velero/velero)
- CPU Request: nicht gesetzt
- CPU Limit: nicht gesetzt
- Memory Request: nicht gesetzt
- Memory Limit: nicht gesetzt
- **Status**: Läuft, aber keine Ressourcen-Limits gesetzt

### NFS Provisioner (default/nfs-provisioner-*)
- 3 Instanzen, keine Ressourcen gesetzt
- **Status**: Läuft, aber keine Ressourcen-Limits gesetzt

### Weitere Services
- **PlantUML**: Keine Ressourcen gesetzt
- **Heimdall**: Keine Ressourcen gesetzt
- **Komga**: Keine Ressourcen gesetzt
- **Syncthing**: Keine Ressourcen gesetzt
- **Loki**: Keine Ressourcen gesetzt
- **Prometheus**: Keine Ressourcen gesetzt
- **Grafana**: Keine Ressourcen gesetzt
- **Kubernetes Dashboard**: Keine Ressourcen gesetzt
- **GitLab Agent**: Keine Ressourcen gesetzt

## Zusammenfassung

### Probleme identifiziert:
1. **Viele Pods haben keine Ressourcen-Limits** - Kann zu Ressourcen-Konflikten führen
2. **Jellyfin CPU Request zu niedrig** - Sollte höher sein für Performance
3. **GitLab PostgreSQL/Redis zu niedrig** - Könnten mehr Ressourcen nutzen
4. **Ingress-NGINX Memory Limit sehr niedrig** - Nur 90Mi
5. **Keine Ressourcen für System-Pods** - ArgoCD, Cert-Manager, CoreDNS, etc.

### Nächste Schritte:
1. Hersteller-Empfehlungen recherchieren
2. Optimale Ressourcen-Verteilung berechnen
3. Alle Deployments aktualisieren

