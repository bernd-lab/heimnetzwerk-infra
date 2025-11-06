# Pi-hole dnsmasq Kubernetes Pod Network Fix

**Datum**: 2025-11-06  
**Problem**: dnsmasq blockiert DNS-Anfragen vom Kubernetes Pod Network (10.244.0.0/16)  
**Lösung**: Custom dnsmasq-Konfiguration mit `local-service=false`

## Problem

Pi-hole verwendet `dnsmasq` als DNS-Resolver. Standardmäßig blockiert dnsmasq Anfragen von "non-local" Netzwerken aus Sicherheitsgründen. Das Kubernetes Pod Network (10.244.0.0/16) wird als "non-local" betrachtet, daher werden DNS-Anfragen von Kubernetes Pods abgelehnt.

**Symptom**:
```
WARNING: dnsmasq: ignoring query from non-local network 10.244.1.0 (logged only once)
```

## Lösung

### 1. ConfigMap für dnsmasq Custom Configuration

**Datei**: `k8s/pihole/dnsmasq-configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: pihole-dnsmasq-custom
  namespace: pihole
data:
  99-custom.conf: |
    # Custom dnsmasq configuration for Kubernetes Pod Network
    # Allows DNS queries from Kubernetes Pod Network (10.244.0.0/16)
    
    # Disable local-service restriction to allow queries from Pod Network
    # This allows Kubernetes pods to query Pi-hole DNS
    # The default dnsmasq behavior blocks queries from non-local networks
    # Setting local-service=false allows queries from any network
    local-service=false
```

### 2. Deployment anpassen

**Datei**: `k8s/pihole/deployment.yaml`

**Volume hinzufügen**:
```yaml
volumes:
- name: dnsmasq-custom-config
  configMap:
    name: pihole-dnsmasq-custom
```

**VolumeMount hinzufügen**:
```yaml
volumeMounts:
- name: dnsmasq-custom-config
  mountPath: /etc/dnsmasq.d/99-custom.conf
  subPath: 99-custom.conf
  readOnly: true
```

### 3. Deployment anwenden

```bash
kubectl apply -f k8s/pihole/dnsmasq-configmap.yaml
kubectl apply -f k8s/pihole/deployment.yaml
kubectl rollout restart deployment pihole -n pihole
```

### 4. Verifizierung

```bash
# ConfigMap prüfen
kubectl get configmap pihole-dnsmasq-custom -n pihole

# Konfiguration im Pod prüfen
kubectl exec -n pihole $(kubectl get pod -n pihole -l app=pihole -o jsonpath="{.items[0].metadata.name}") -- cat /etc/dnsmasq.d/99-custom.conf

# Logs prüfen (keine "non-local network" Warnings mehr)
kubectl logs -n pihole -l app=pihole | grep -i "non-local"
```

## Erwartetes Ergebnis

- ✅ Keine "ignoring query from non-local network" Warnings mehr
- ✅ Kubernetes Pods können Pi-hole DNS abfragen
- ✅ DNS-Anfragen von 10.244.0.0/16 werden akzeptiert

## Sicherheitshinweise

**⚠️ WICHTIG**: `local-service=false` erlaubt DNS-Anfragen von **allen** Netzwerken, nicht nur dem Kubernetes Pod Network. Dies ist in einem privaten Heimnetzwerk akzeptabel, sollte aber in produktiven Umgebungen mit Firewall-Regeln abgesichert werden.

**Alternative (restriktiver)**:
Falls nur das Kubernetes Pod Network erlaubt werden soll, kann eine Firewall-Regel verwendet werden, die nur 10.244.0.0/16 erlaubt. Dies erfordert jedoch zusätzliche iptables/nftables-Konfiguration.

## Weitere Informationen

- **dnsmasq Dokumentation**: https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html
- **Pi-hole dnsmasq Konfiguration**: `/etc/dnsmasq.d/` im Container
- **Kubernetes Pod Network**: 10.244.0.0/16 (Flannel CNI)

