# Pi-hole DNS-Problem - Finale Lösung

**Datum**: 2025-11-07  
**Problem**: DNS funktioniert nicht von außen  
**Ursache**: DNSmasq ignoriert Anfragen von nicht-lokalen Netzwerken  
**Status**: ⚠️ **In Bearbeitung - ConfigMap mit interface=eth0 aktualisiert**

## Zusammenfassung

### Problem identifiziert:
1. ✅ **Pi-hole Pod lief nicht** → **BEHOBEN** (CPU reduziert)
2. ⚠️ **DNSmasq ignoriert nicht-lokale Netzwerke** → **IN BEARBEITUNG**

### Lösungsschritte:

1. **ConfigMap `pihole-dnsmasq-custom` aktualisiert**:
   ```conf
   local-service=false
   interface=eth0          ← WICHTIG: Explizit gesetzt (war leer)
   bind-interfaces=false
   listen-address=0.0.0.0
   localise-queries=false
   ```

2. **Pod neu gestartet**: Um neue Konfiguration zu laden

3. **DNS-Test**: Wird durchgeführt

## Aktueller Stand

- ✅ ConfigMap aktualisiert mit `interface=eth0`
- ⚠️ Pod wird neu gestartet
- ⚠️ DNS-Test ausstehend

## Erwartetes Ergebnis

Nach erfolgreichem Neustart:
- ✅ Keine "ignoring query from non-local network" Warnungen mehr
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

## Falls Problem weiterhin besteht

Alternative Lösungen:
1. Pi-hole FTL-Konfiguration direkt anpassen
2. Service auf NodePort umstellen (Workaround)
3. Pi-hole-Version prüfen/aktualisieren

