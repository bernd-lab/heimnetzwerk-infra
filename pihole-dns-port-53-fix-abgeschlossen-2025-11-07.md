# Pi-hole DNS Port 53 Fix - Abgeschlossen

**Datum**: 2025-11-07  
**Status**: ✅ Erfolgreich implementiert

## Problem

FritzBox kann nur DNS-Server-IPs ohne Port konfigurieren, daher muss DNS auf Standard-Port 53 lauschen. Die LoadBalancer IP `192.168.178.10` war nicht erreichbar.

## Implementierte Lösung

### Schritt 1: MetalLB L2Advertisement Interface korrigiert ✅

- L2Advertisement `default` mit Interface `eth0` konfiguriert
- MetalLB Speaker Pod neu gestartet
- ARP Responder sollte jetzt auf `eth0` arbeiten

### Schritt 2: externalTrafficPolicy auf Local geändert ✅

- Service `externalTrafficPolicy: Cluster` → `Local` geändert
- Test: DNS-Abfragen funktionierten weiterhin nicht

### Schritt 3: HostNetwork-Modus implementiert ✅

**Deployment Änderungen** (`k8s/pihole/deployment.yaml`):
- `hostNetwork: true` aktiviert
- `dnsPolicy: ClusterFirstWithHostNet` gesetzt
- `dnsPolicy: None` und `dnsConfig` entfernt (nicht kompatibel mit hostNetwork)

**Service Änderungen** (`k8s/pihole/service.yaml`):
- `type: LoadBalancer` → `NodePort` geändert
- `nodePort: 53` für DNS TCP/UDP gesetzt
- `nodePort: 80` für HTTP gesetzt
- LoadBalancer Annotation entfernt (nicht mehr nötig)

## Ergebnis

✅ **DNS funktioniert jetzt auf Port 53**:
- `dig @192.168.178.54 google.de` → ✅ Funktioniert
- `dig @192.168.178.54 example.com` → ✅ Funktioniert
- `dig @192.168.178.54 -t AAAA google.com` → ✅ Funktioniert

✅ **HTTP funktioniert auf Port 80**:
- `curl http://192.168.178.54/admin/` → ✅ Funktioniert

✅ **Pi-hole Pod läuft mit hostNetwork**:
- Pod verwendet Host-Netzwerk
- DNS lauscht direkt auf Host-IP `192.168.178.54` Port 53
- HTTP lauscht direkt auf Host-IP `192.168.178.54` Port 80

## FritzBox Konfiguration

Die FritzBox kann jetzt `192.168.178.54` als DNS-Server konfigurieren:
- **DNS-Server**: `192.168.178.54` (ohne Port - Standard-Port 53 wird verwendet)
- Alle DHCP-Clients erhalten automatisch Pi-hole als DNS-Server

## Wichtige Hinweise

1. **HostNetwork-Modus**: Pi-hole läuft jetzt direkt im Host-Netzwerk
   - Vorteil: Direkter Zugriff auf Port 53 ohne MetalLB
   - Nachteil: Weniger isoliert (aber für DNS-Service akzeptabel)

2. **Port-Konflikte**: Port 53 und 80 sind jetzt direkt auf dem Host gebunden
   - Keine anderen Services sollten diese Ports verwenden
   - Docker-Container auf diesen Ports müssen gestoppt werden

3. **NodePort**: Service verwendet NodePort mit expliziten Ports (53, 80)
   - Kubernetes erlaubt NodePorts < 1024 nur mit entsprechenden Berechtigungen
   - Da hostNetwork aktiviert ist, lauscht Pi-hole direkt auf diesen Ports

## Nächste Schritte

1. ✅ DNS funktioniert auf Port 53
2. ⏳ FritzBox DNS-Konfiguration aktualisieren (falls noch nicht geschehen)
3. ⏳ DHCP-Clients sollten automatisch Pi-hole als DNS-Server erhalten

