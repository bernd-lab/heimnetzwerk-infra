# Pi-hole DNS-Problem - Interface-Konfiguration

**Datum**: 2025-11-07  
**Problem**: DNSmasq ignoriert Anfragen von nicht-lokalen Netzwerken  
**Lösung**: Interface explizit konfigurieren  
**Status**: ⚠️ **In Bearbeitung**

## Problem

DNSmasq ignoriert Anfragen von nicht-lokalen Netzwerken trotz:
- `local-service=false`
- `listen-address=0.0.0.0`
- `DNSMASQ_LISTENING=all`

## Lösung basierend auf Recherche

Laut Recherche muss das Interface explizit gesetzt werden:
```conf
interface=eth0
```

## Durchgeführte Schritte

1. ✅ **ConfigMap aktualisiert**: `interface=eth0` hinzugefügt
2. ✅ **Pod neu gestartet**: Um neue Konfiguration zu laden
3. ⚠️ **DNS-Test**: Wird durchgeführt

## Nächste Schritte

Falls das Problem weiterhin besteht:
1. Prüfen ob ConfigMap korrekt gemountet wird
2. Prüfen ob Pi-hole FTL die Konfiguration überschreibt
3. Alternative: Pi-hole direkt im Container konfigurieren

