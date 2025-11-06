# DNS-Problem behoben - Cluster-Analyse und Lösung

**Datum**: 2025-11-06  
**Status**: ✅ **BEHOBEN**

## Problem

DNS funktionierte nicht mehr im gesamten Cluster, weil:
1. **Pi-hole Pod war im "Pending" Status** - konnte nicht starten wegen "Insufficient cpu"
2. **CoreDNS forwardete an Pi-hole (192.168.178.10)** - aber Pi-hole war nicht erreichbar
3. **Ingress-Controller konnte nicht starten** - ebenfalls wegen CPU-Mangel
4. **Jellyfin beanspruchte 3000m CPU (3 cores)** - ließ keinen Platz für kritische System-Services

## Root Cause

- **Node "zuhause"**: 4 CPUs, 100% belegt durch Jellyfin (3000m requests)
- **Pi-hole**: Benötigt 100m CPU, konnte nicht scheduled werden
- **Ingress-Controller**: Benötigt 100m CPU, konnte nicht scheduled werden
- **DNS-Abhängigkeit**: Alle Services hängen von Pi-hole ab → DNS komplett down

## Lösung

### 1. CoreDNS Fallback konfiguriert ✅
- **Temporär**: CoreDNS forwardet direkt an `8.8.8.8` und `1.1.1.1` (Google/Cloudflare)
- **Zweck**: DNS funktioniert sofort wieder, auch wenn Pi-hole down ist

### 2. Jellyfin CPU-Requests reduziert ✅
- **Vorher**: `cpu: 3000m` (3 cores)
- **Nachher**: `cpu: 2000m` (2 cores)
- **Grund**: Platz für Pi-hole (100m) und Ingress-Controller (100m)
- **Limits bleiben**: `cpu: "4"` (kann bei Bedarf bis zu 4 cores nutzen)

### 3. Pi-hole zurück auf "zuhause" Node ✅
- **Node**: `kubernetes.io/hostname: zuhause` (Debian-Server, immer an)
- **Status**: ✅ Running auf `10.244.0.202`
- **Service**: LoadBalancer `192.168.178.10` (Port 53 TCP/UDP, Port 80)

### 4. CoreDNS wieder auf Pi-hole umgestellt ✅
- **Forward-Konfiguration**: `forward . 192.168.178.10 8.8.8.8`
- **Fallback**: Wenn Pi-hole nicht erreichbar, nutzt `8.8.8.8`

## Aktuelle Ressourcen-Verteilung

### Node "zuhause" (4 CPUs)
- **Jellyfin**: 2000m requests (2 cores), 4 cores limits
- **Pi-hole**: 100m requests
- **Ingress-Controller**: 100m requests
- **Total Requests**: ~2200m (55% von 4000m)
- **Verfügbar**: ~1800m (45%) für andere Services

### Node "wsl2-ubuntu"
- **Taint**: `workload-type=development:NoSchedule`
- **Verwendung**: Für Development-Workloads, kann ausgeschaltet werden
- **Pi-hole**: Sollte NICHT hier laufen (wird ausgeschaltet)

## Empfehlung für maximale Jellyfin-Performance

Wenn Jellyfin maximale Performance benötigt (z.B. Bibliotheken laden, Bilder generieren):

### Option 1: Jellyfin temporär auf WSL2 verschieben
```yaml
# In k8s/jellyfin/deployment.yaml
nodeSelector:
  kubernetes.io/hostname: wsl2-ubuntu
tolerations:
- key: workload-type
  operator: Equal
  value: development
  effect: NoSchedule
resources:
  requests:
    cpu: 3000m  # Oder mehr, je nach WSL2-Node
```

### Option 2: Jellyfin CPU-Requests temporär erhöhen
```bash
kubectl patch deployment jellyfin -p '{"spec":{"template":{"spec":{"containers":[{"name":"jellyfin","resources":{"requests":{"cpu":"3000m"}}}]}}}}'
```

**Nach Bibliotheken-Scan wieder reduzieren:**
```bash
kubectl patch deployment jellyfin -p '{"spec":{"template":{"spec":{"containers":[{"name":"jellyfin","resources":{"requests":{"cpu":"2000m"}}}]}}}}'
```

## Verifizierung

✅ **Pi-hole**: Running auf `zuhause` Node  
✅ **Ingress-Controller**: Running  
✅ **Jellyfin**: Running (mit reduzierten Requests)  
✅ **CoreDNS**: Forwardet an Pi-hole mit Fallback  
✅ **DNS-Test**: Pi-hole kann DNS-Auflösung durchführen

## Nächste Schritte

1. ✅ DNS funktioniert wieder
2. ⏳ Jellyfin Performance-Monitoring (bei Bedarf auf WSL2 verschieben)
3. ⏳ Langfristig: Node-Ressourcen besser planen (mehr Nodes oder größere Nodes)

## Dateien geändert

- `k8s/pihole/deployment.yaml`: Node-Selector auf `zuhause` gesetzt
- `k8s/jellyfin/deployment.yaml`: CPU-Requests von 3000m auf 2000m reduziert
- `k8s/coredns ConfigMap`: Forward-Konfiguration mit Fallback

