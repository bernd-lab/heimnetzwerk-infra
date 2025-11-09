# Metrics API Installation abgeschlossen

**Datum**: 2025-11-07  
**Status**: ✅ **Metrics API erfolgreich installiert**

## Installation

### 1. Metrics Server installiert
```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 2. Anpassungen für K3s

**Problem**: Metrics Server konnte nicht starten wegen:
- **Insufficient CPU**: Node hatte nicht genug freie CPU-Ressourcen
- **TLS-Zertifikatsfehler**: K3s verwendet selbstsignierte Zertifikate

**Lösung**:
1. CPU-Requests reduziert: `100m` → `50m`
2. Memory-Requests reduziert: `200Mi` → `100Mi`
3. `--kubelet-insecure-tls` Flag hinzugefügt für K3s-Kompatibilität

```bash
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/cpu", "value": "50m"}]'
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/resources/requests/memory", "value": "100Mi"}]'
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
```

## Verifizierung

### Node-Metriken
```bash
$ kubectl top nodes
NAME      CPU(cores)   CPU(%)   MEMORY(bytes)   MEMORY(%)   
zuhause   1570m        39%      9675Mi          30%
```

### Pod-Metriken (Top CPU)
```
kube-apiserver-zuhause             141m
kube-controller-manager-zuhause    93m
gitlab-7b86fcf65b-mz6jt            82m
metrics-server-694c6646d7-clq6x    74m
etcd-zuhause                       60m
```

### Pod-Metriken (Top Memory)
```
gitlab-7b86fcf65b-mz6jt            2803Mi
kube-apiserver-zuhause             598Mi
komga-6d8bb46bd5-j4lh9             461Mi
gitlab-postgresql-0                272Mi
plantuml-5fb7f4bc99-896jn          262Mi
jellyfin-84c6d8f9b5-ggxkv          233Mi
```

## CPU-Analyse

**Aktuelle Auslastung**: 39% (1570m von 4000m = 4 Cores)
- **Status**: ✅ Normal, keine Überlastung
- **Hinweis**: Die Warnung über hohe Last (5.2 > 4) stammt vermutlich von einem früheren Zeitpunkt oder einem kurzen Peak

**Top CPU-Verbraucher**:
1. kube-apiserver: 141m (3.5%)
2. kube-controller-manager: 93m (2.3%)
3. GitLab: 82m (2.1%)
4. Metrics Server: 74m (1.9%)
5. etcd: 60m (1.5%)

**Fazit**: Die CPU-Auslastung ist im normalen Bereich. Die Warnung im Pi-hole Log über hohe Last könnte von einem temporären Peak stammen oder von der Gesamtlast des Systems (nicht nur Kubernetes).

## Nächste Schritte

1. ✅ Metrics API funktioniert
2. ⚠️ DNS-Problem von WSL2-Umgebung analysieren
3. ⚠️ Pi-hole Webserver-Problem beheben

