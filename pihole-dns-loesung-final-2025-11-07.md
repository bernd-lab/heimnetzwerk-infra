# Pi-hole DNS-Problem - Finale Lösung

**Datum**: 2025-11-07  
**Problem**: DNS funktioniert nicht von außen  
**Ursache**: DNSmasq ignoriert Anfragen von nicht-lokalen Netzwerken  
**Status**: ⚠️ **In Bearbeitung - ConfigMap wird angepasst**

## Problem

### Log-Warnung:
```
WARNING: dnsmasq: ignoring query from non-local network 192.168.178.20
```

**Bedeutung**: DNSmasq blockiert Anfragen von Netzwerken, die nicht als "lokal" erkannt werden.

## Lösung

### DNSmasq-ConfigMap angepasst:

**Aktuelle Konfiguration** (`pihole-dnsmasq-custom`):
```conf
local-service=false
interface=
bind-interfaces=false
listen-address=0.0.0.0
```

**Erklärung**:
- `local-service=false`: Erlaubt Anfragen von nicht-lokalen Netzwerken
- `interface=`: Leer = lauscht auf allen Interfaces
- `bind-interfaces=false`: Bindet nicht nur an ein Interface
- `listen-address=0.0.0.0`: Lauscht auf allen Adressen

### Durchgeführte Schritte:

1. ✅ **ConfigMap gepatcht**: `listen-address=0.0.0.0` hinzugefügt
2. ✅ **Pod neu gestartet**: Um neue Konfiguration zu laden
3. ⚠️ **DNS-Test**: Wird durchgeführt

## Nächste Schritte

Falls das Problem weiterhin besteht:

1. **Pi-hole DNS neu starten**: `pihole restartdns`
2. **ConfigMap prüfen**: Ob wirklich geladen wird
3. **Alternative**: Pi-hole Umgebungsvariable `DNSMASQ_LISTENING=all` prüfen

## Erwartetes Ergebnis

Nach erfolgreicher Konfiguration:
- ✅ Keine "ignoring query from non-local network" Warnungen mehr
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

