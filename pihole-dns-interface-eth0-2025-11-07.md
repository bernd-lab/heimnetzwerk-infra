# Pi-hole DNS-Problem - Interface eth0 gesetzt

**Datum**: 2025-11-07  
**Problem**: DNSmasq ignoriert Anfragen von nicht-lokalen Netzwerken  
**Lösung**: `interface=eth0` in ConfigMap gesetzt  
**Status**: ⚠️ **Wird getestet**

## Problem

ConfigMap hatte `interface=` (leer), was dazu führt, dass DNSmasq nicht weiß, auf welchem Interface es lauschen soll.

## Lösung

ConfigMap `pihole-dnsmasq-custom` aktualisiert:
```conf
local-service=false
interface=eth0          ← EXPLIZIT GESETZT
bind-interfaces=false
listen-address=0.0.0.0
localise-queries=false
```

## Durchgeführte Schritte

1. ✅ **ConfigMap gepatcht**: `interface=eth0` gesetzt (war vorher leer)
2. ✅ **Pod neu gestartet**: Um neue Konfiguration zu laden
3. ⚠️ **DNS-Test**: Wird durchgeführt

## Erwartetes Ergebnis

Nach erfolgreicher Konfiguration:
- ✅ Keine "ignoring query from non-local network" Warnungen mehr
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

