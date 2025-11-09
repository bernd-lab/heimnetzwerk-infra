# Pi-hole DNS-Problem Analyse und Reparatur-Plan

**Datum**: 2025-11-07  
**Status**: ⚠️ DNS-Abfragen schlagen fehl trotz korrekter Konfiguration

## Problem

DNS-Abfragen an `192.168.178.10` schlagen fehl:
```
;; communications error to 192.168.178.10#53: timed out
```

## Aktuelle Konfiguration (✅ Korrekt)

### Pi-hole Pod
- **Status**: Running (1/1)
- **IP**: 10.244.0.93
- **pihole.toml**: `listeningMode = "ALL"` ✅
- **pihole.toml**: `interface = "eth0"` ✅
- **DNSmasq ConfigMap**: Korrekt konfiguriert ✅

### Service
- **Typ**: LoadBalancer
- **IP**: 192.168.178.10 (MetalLB)
- **Endpoints**: 10.244.0.93:53 ✅
- **externalTrafficPolicy**: Local ⚠️ (könnte Problem sein)

### MetalLB
- **IP-Pool**: 192.168.178.10/32 ✅
- **Status**: IP zugewiesen ✅

## Mögliche Ursachen

1. **externalTrafficPolicy: Local** - Könnte Probleme mit Source-IP verursachen
2. **MetalLB ARP-Announcements** - Könnten nicht richtig funktionieren
3. **Netzwerk-Routing** - Traffic kommt möglicherweise nicht beim Pod an
4. **Firewall-Regeln** - Könnten DNS-Traffic blockieren

## Systemauslastung

- **CPU Requests**: 2151m / 4000m (53%) - OK
- **Memory Requests**: 2055Mi / ~32GB (6%) - OK
- **Load Average**: 1.80, 2.60, 1.49 (4 CPUs) - OK
- **Disk**: 62% verwendet - OK

## Reparatur-Plan

1. **externalTrafficPolicy prüfen/anpassen**
2. **MetalLB ARP-Announcements verifizieren**
3. **Netzwerk-Routing testen**
4. **Firewall-Regeln prüfen**
5. **DNS-Tests durchführen**
