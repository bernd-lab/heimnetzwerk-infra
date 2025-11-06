# Pi-hole Status nach Server-Neustart

**Datum**: 2025-11-06 09:40  
**Status**: ⚠️ Pi-hole läuft, aber Port 53 nicht von außen erreichbar

## ✅ Was funktioniert

1. **Server-Neustart**: ✅ Erfolgreich
2. **Swap deaktiviert**: ✅ (kubelet läuft jetzt)
3. **Kubernetes Cluster**: ✅ Läuft (2 Nodes Ready)
4. **Pi-hole Pod**: ✅ Running (pihole-787479f5f9-nnrgn)
5. **Pi-hole Container**: ✅ DNS funktioniert im Container
6. **Pi-hole Service**: ✅ LoadBalancer erstellt (IP: 192.168.178.10)
7. **MetalLB**: ✅ IP auf br0 Interface (192.168.178.10/32)

## ❌ Problem

**Port 53 nicht von außen erreichbar**:
- `dig @192.168.178.10 google.de` → Connection refused
- `nc -zv 192.168.178.10 53` → Connection refused
- HTTP Port 80: Timeout

## Analyse

### Service-Konfiguration
- **Service-Typ**: LoadBalancer
- **IP**: 192.168.178.10 ✅
- **Ports**: 53 TCP/UDP, 80 TCP ✅
- **Endpoints**: 10.244.0.144:53 ✅

### MetalLB
- **IP-Pool**: default-pool enthält 192.168.178.10 ✅
- **L2Advertisement**: Aktiv ✅
- **IP auf Interface**: br0 hat 192.168.178.10/32 ✅

### Mögliche Ursachen

1. **Service External Traffic Policy**: Auf "Cluster" statt "Local"
2. **iptables/nftables**: Blockiert möglicherweise Traffic
3. **CNI/Netzwerk**: Routing-Problem zwischen LoadBalancer und Pod
4. **Pi-hole Container**: Hört möglicherweise nicht auf alle Interfaces

## Nächste Schritte

1. **Service External Traffic Policy prüfen/ändern**:
   ```bash
   kubectl patch svc pihole -n pihole -p '{"spec":{"externalTrafficPolicy":"Local"}}'
   ```

2. **iptables-Regeln prüfen**:
   ```bash
   sudo iptables -t nat -L -n -v | grep 192.168.178.10
   ```

3. **CNI/Netzwerk prüfen**:
   ```bash
   kubectl get pods -n kube-system | grep -i "cni\|flannel\|calico"
   ```

4. **Pi-hole Container-Logs prüfen**:
   ```bash
   kubectl logs -n pihole -l app=pihole --tail=50
   ```

## Temporäre Lösung

Falls Port 53 weiterhin nicht erreichbar ist:
- **NodePort verwenden**: Port 32228 (UDP) und 32228 (TCP) für DNS
- **Port-Forward**: `kubectl port-forward -n pihole svc/pihole 53:53`

