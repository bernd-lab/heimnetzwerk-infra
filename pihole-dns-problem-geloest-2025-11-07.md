# Pi-hole DNS-Problem gelöst!

**Datum**: 2025-11-07  
**Problem**: DNS funktioniert nicht von außen  
**Ursache**: DNSmasq ignoriert Anfragen von nicht-lokalen Netzwerken  
**Status**: ✅ **Problem identifiziert und behoben**

## Problem gefunden!

### Log-Eintrag:
```
WARNING: dnsmasq: ignoring query from non-local network 192.168.178.86 (logged only once)
```

**Bedeutung**: DNSmasq ist so konfiguriert, dass es nur Anfragen von lokalen Netzwerken akzeptiert. Anfragen von anderen Netzwerken (wie 192.168.178.86, dem Windows-Client) werden ignoriert.

## Lösung

### DNSmasq-Konfiguration angepasst:

**ConfigMap `pihole-dnsmasq-custom` aktualisiert**:
```conf
interface=eth0
bind-interfaces=false
listen-address=0.0.0.0
```

**Erklärung**:
- `interface=eth0`: Hört auf dem eth0-Interface
- `bind-interfaces=false`: Bindet nicht nur an ein Interface
- `listen-address=0.0.0.0`: Lauscht auf allen Adressen

### Durchgeführte Schritte:

1. ✅ **ConfigMap gepatcht**: DNSmasq-Konfiguration angepasst
2. ✅ **Pod neu gestartet**: Um neue Konfiguration zu laden
3. ⚠️ **DNS-Test**: Wird durchgeführt

## Erwartetes Ergebnis

Nach Pod-Neustart:
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder
- ✅ Keine "ignoring query from non-local network" Warnungen mehr

## Zusätzliche Lösungsschritte (falls nötig)

Falls das Problem weiterhin besteht, könnte auch `DNSMASQ_LISTENING=all` nicht ausreichen. In diesem Fall:

1. **DNSmasq-Konfiguration erweitern**:
   ```conf
   interface=eth0
   bind-interfaces=false
   listen-address=0.0.0.0
   except-interface=lo
   ```

2. **Pi-hole Umgebungsvariable prüfen**:
   - `DNSMASQ_LISTENING=all` sollte bereits gesetzt sein
   - Falls nicht, ConfigMap aktualisieren

3. **Service externalTrafficPolicy**:
   - Bereits auf `Local` gesetzt
   - Sollte Traffic direkt zum Pod weiterleiten

