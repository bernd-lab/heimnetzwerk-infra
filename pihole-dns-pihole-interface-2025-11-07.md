# Pi-hole DNS-Problem - PIHOLE_INTERFACE gesetzt

**Datum**: 2025-11-07  
**Problem**: DNS funktioniert nicht von außen  
**Ursache**: Pi-hole FTL `interface = ""` (leer) in pihole.toml  
**Lösung**: Umgebungsvariable `PIHOLE_INTERFACE=eth0` gesetzt  
**Status**: ⚠️ **Wird getestet**

## Problem identifiziert

In `/etc/pihole/pihole.toml` steht:
```
interface = ""
```

**Bedeutung**: Pi-hole FTL verwendet die pihole.toml Konfiguration, nicht die DNSmasq-Config. Wenn das Interface leer ist, weiß FTL nicht, auf welchem Interface es lauschen soll.

## Lösung

Umgebungsvariable `PIHOLE_INTERFACE=eth0` im Deployment gesetzt.

## Durchgeführte Schritte

1. ✅ **Deployment gepatcht**: `PIHOLE_INTERFACE=eth0` als Umgebungsvariable hinzugefügt
2. ✅ **Pod neu gestartet**: Um neue Konfiguration zu laden
3. ⚠️ **DNS-Test**: Wird durchgeführt

## Erwartetes Ergebnis

Nach erfolgreichem Neustart:
- ✅ `interface = "eth0"` in pihole.toml
- ✅ Keine "ignoring query from non-local network" Warnungen mehr
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

