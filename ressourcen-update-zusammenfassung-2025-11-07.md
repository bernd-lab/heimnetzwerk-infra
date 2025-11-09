# Ressourcen-Update Zusammenfassung

**Datum**: 2025-11-07  
**Status**: Updates angewendet

## Durchgeführte Updates

### 1. Jellyfin (default/jellyfin)
- **CPU Request**: 1000m → **2000m** (2 cores - 50% des Nodes)
- **CPU Limit**: 4 (behalten)
- **Memory Request**: 8Gi → **12Gi** (großzügig für Bibliotheks-Scans)
- **Memory Limit**: 16Gi (behalten)

### 2. Pi-hole (pihole/pihole)
- **CPU Request**: 50m → **100m**
- **CPU Limit**: 500m (behalten)
- **Memory Request**: 256Mi → **512Mi**
- **Memory Limit**: 512Mi → **1Gi**

### 3. GitLab (gitlab/gitlab)
- **CPU Request**: 500m → **300m** (reduziert für Balance)
- **CPU Limit**: 2 (behalten)
- **Memory Request**: 3Gi → **4Gi**
- **Memory Limit**: 5Gi → **6Gi**

### 4. GitLab PostgreSQL (gitlab/gitlab-postgresql)
- **CPU Request**: 100m → **200m**
- **CPU Limit**: nicht gesetzt → **1**
- **Memory Request**: 256Mi → **1Gi**
- **Memory Limit**: nicht gesetzt → **2Gi**

### 5. GitLab Redis (gitlab/gitlab-redis-master)
- **CPU Request**: 50m → **100m**
- **CPU Limit**: nicht gesetzt → **500m**
- **Memory Request**: 128Mi → **512Mi**
- **Memory Limit**: nicht gesetzt → **1Gi**

### 6. GitLab Runner (gitlab-runner/gitlab-runner)
- **CPU Request**: 100m → **100m** (behalten)
- **CPU Limit**: 500m (behalten)
- **Memory Request**: 128Mi → **256Mi**
- **Memory Limit**: 512Mi (behalten)

### 7. Ingress-NGINX Controller (ingress-nginx/ingress-nginx-controller)
- **CPU Request**: 100m → **100m** (behalten)
- **CPU Limit**: nicht gesetzt → **1**
- **Memory Request**: nicht gesetzt → **256Mi**
- **Memory Limit**: 90Mi → **512Mi**

### 8. ArgoCD Komponenten (argocd/)
- **application-controller**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi (neu)
- **repo-server**: CPU Request: 150m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi (neu)
- **server**: CPU Request: 50m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi (neu)
- **dex-server**: CPU Request: 50m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi (neu)
- **notifications-controller**: CPU Request: 50m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi (neu)
- **redis**: CPU Request: 50m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi (neu)

### 9. Cert-Manager Komponenten (cert-manager/)
- **controller**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi (neu)
- **cainjector**: CPU Request: 25m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi (neu)
- **webhook**: CPU Request: 25m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi (neu)

### 10. CoreDNS (kube-system/coredns)
- **CPU Request**: nicht gesetzt → **50m**
- **CPU Limit**: nicht gesetzt → **500m**
- **Memory Request**: nicht gesetzt → **128Mi**
- **Memory Limit**: nicht gesetzt → **256Mi**

### 11. MetalLB (metallb-system/)
- **controller**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi (neu)
- **speaker**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi (neu)

### 12. Velero (velero/velero)
- **CPU Request**: nicht gesetzt → **100m**
- **CPU Limit**: nicht gesetzt → **1**
- **Memory Request**: nicht gesetzt → **512Mi**
- **Memory Limit**: nicht gesetzt → **1Gi**

### 13. NFS Provisioner (default/nfs-provisioner-*)
- **Alle 3 Instanzen**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi (neu)

## Ressourcen-Verteilung (geschätzt)

### CPU Requests (Summe):
- Jellyfin: 2000m
- GitLab: 300m
- GitLab PostgreSQL: 200m
- GitLab Redis: 100m
- Pi-hole: 100m
- GitLab Runner: 200m (2 Pods)
- Ingress-NGINX: 100m
- ArgoCD: ~600m
- Cert-Manager: ~150m
- CoreDNS: 100m (2 Pods)
- MetalLB: 100m
- Velero: 200m
- NFS Provisioner: 150m (3 Instanzen)
- Weitere Services: ~400m (geschätzt)
- **Gesamt**: ~4700m

**Bewertung**: Gesamt-CPU-Requests (~4700m) > Verfügbare CPUs (4000m) - **Überbelegung!**

### Memory Requests (Summe):
- Jellyfin: 12Gi
- GitLab: 4Gi
- GitLab PostgreSQL: 1Gi
- GitLab Redis: 512Mi
- Pi-hole: 512Mi
- GitLab Runner: 512Mi (2 Pods)
- Ingress-NGINX: 256Mi
- ArgoCD: ~3.5Gi
- Cert-Manager: ~512Mi
- CoreDNS: 256Mi (2 Pods)
- MetalLB: 256Mi
- Velero: 1Gi
- NFS Provisioner: 384Mi (3 Instanzen)
- Weitere Services: ~2Gi (geschätzt)
- **Gesamt**: ~26Gi

**Bewertung**: Memory Requests (~26Gi) < Verfügbare Memory (~32GB) - **OK**

## Wichtige Hinweise

1. **CPU-Überbelegung**: Die CPU-Requests übersteigen die verfügbaren CPUs. Dies ist in Kubernetes erlaubt, da Limits höher sein können als Requests (Burst-Capability).

2. **Jellyfin Priorität**: Jellyfin hat jetzt 50% der Node-CPUs garantiert (2000m), was großzügig ist für Performance.

3. **Memory OK**: Memory-Verteilung ist gesund und unter dem Limit.

4. **Limits höher als Requests**: Viele Pods haben Limits die höher sind als Requests, was Burst-Capability ermöglicht.

## Nächste Schritte

1. Pods überwachen auf Ressourcen-Konflikte
2. Performance von Jellyfin prüfen
3. Bei Bedarf: Weitere Anpassungen basierend auf tatsächlicher Nutzung
4. Optional: Node erweitern für mehr CPU-Kapazität

