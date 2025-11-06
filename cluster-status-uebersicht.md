# Cluster-Status Übersicht

**Datum**: 2025-11-06  
**Gesamt-Pods**: 43  
**Laufende Pods**: 40 (93%)

## ✅ Alle kritischen Services laufen

### DNS & Networking
- ✅ **Pi-hole**: Running auf `zuhause` Node (192.168.178.10)
- ✅ **CoreDNS**: Running (2 Pods)
- ✅ **Ingress-Controller**: Running (hostNetwork: true)

### Haupt-Services
- ✅ **Jellyfin**: Running (CPU: 2000m requests, 4 cores limits)
- ✅ **GitLab**: Running (PostgreSQL & Redis laufen)
- ✅ **ArgoCD**: Running
- ✅ **Heimdall**: Running

## ⚠️ Pods mit Problemen

### 1. Jenkins - Pending (Insufficient CPU)
- **Status**: 0/1 Pending
- **Problem**: Benötigt 1 CPU, aber Node "zuhause" ist voll (97% belegt)
- **Lösungsoptionen**:
  1. Jenkins auf WSL2-Node verschieben (mit Toleration)
  2. Jenkins CPU-Requests reduzieren
  3. Jenkins Deployment skalieren auf 0 (wenn nicht benötigt)

### 2. test-argocd - Unknown (gelöscht)
- **Status**: 0/1 Unknown (seit 23h)
- **Aktion**: ✅ Gelöscht (war Test-Pod)

## Ressourcen-Verteilung

### Node "zuhause" (4 CPUs, 31GB RAM)
- **CPU Requests**: 3900m (97%) von 4000m
- **CPU Limits**: 7 cores (175% - overcommitted)
- **Memory Requests**: 12540Mi (39%) von 31GB
- **Memory Limits**: 18772Mi (58%)

**Verteilung**:
- Jellyfin: 2000m CPU requests (2 cores)
- Pi-hole: 100m CPU requests
- Ingress-Controller: 100m CPU requests
- GitLab: ~500m CPU requests
- Andere Services: ~1200m CPU requests

### Node "wsl2-ubuntu"
- **Taint**: `workload-type=development:NoSchedule`
- **CPU**: Fast leer (nur 100m belegt)
- **Verwendung**: Für Development-Workloads oder temporäre High-Performance-Tasks

## Empfehlungen

### Für Jenkins
1. **Auf WSL2 verschieben** (wenn Jenkins benötigt wird):
   ```yaml
   nodeSelector:
     kubernetes.io/hostname: wsl2-ubuntu
   tolerations:
   - key: workload-type
     operator: Equal
     value: development
     effect: NoSchedule
   ```

2. **CPU-Requests reduzieren** (wenn auf "zuhause" bleiben soll):
   ```yaml
   resources:
     requests:
       cpu: 500m  # Statt 1 CPU
   ```

3. **Deployment skalieren auf 0** (wenn nicht benötigt):
   ```bash
   kubectl scale deployment jenkins --replicas=0
   ```

### Für maximale Jellyfin-Performance
Wenn Jellyfin maximale Performance benötigt (Bibliotheken laden, Bilder generieren):
- Jellyfin temporär auf WSL2 verschieben
- Oder Jellyfin CPU-Requests temporär auf 3000m erhöhen

## Nächste Schritte

1. ✅ DNS funktioniert wieder
2. ✅ Alle kritischen Services laufen
3. ⏳ Jenkins-Problem lösen (auf WSL2 verschieben oder skalieren)
4. ⏳ Cluster-Ressourcen langfristig optimieren

