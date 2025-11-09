# Pi-hole DNS-Problem Zusammenfassung

**Datum**: 2025-11-07  
**Problem**: Windows kann keine KI nutzen, weil DNS nicht funktioniert  
**Status**: ⚠️ **Problem identifiziert, Lösung in Arbeit**

## Problem-Analyse

### Symptom:
- ⚠️ Windows: Keine KI nutzbar bei automatischer DNS-Konfiguration per DHCP
- ⚠️ DNS-Abfragen schlagen fehl: `dig @192.168.178.10 google.de` → Timeout

### Ursachen identifiziert:

1. **Pi-hole Pod lief nicht** (✅ **BEHOBEN**):
   - Status `Pending` wegen CPU-Mangel
   - **Lösung**: Jellyfin CPU reduziert (3 cores → 2 cores), Jenkins gestoppt
   - **Ergebnis**: Pi-hole läuft jetzt ✅

2. **DNSmasq ignoriert nicht-lokale Netzwerke** (⚠️ **IN BEARBEITUNG**):
   - Log-Warnung: `dnsmasq: ignoring query from non-local network 192.168.178.20`
   - **Problem**: DNSmasq blockiert Anfragen von Windows-Clients (192.168.178.x)
   - **Lösungsversuche**:
     - ConfigMap `pihole-dnsmasq-custom` angepasst: `local-service=false`, `listen-address=0.0.0.0`
     - ConfigMap `pihole-config` angepasst: `DNSMASQ_LISTENING=all`
     - Pod neu gestartet
   - **Status**: Problem besteht weiterhin ⚠️

## Aktueller Stand

### ✅ Was funktioniert:
- Pi-hole Pod läuft (`Running`)
- DNS lokal im Container funktioniert (`dig @127.0.0.1 google.de`)
- FTL läuft und lauscht auf Port 53
- Service konfiguriert (LoadBalancer mit IP 192.168.178.10)

### ❌ Was nicht funktioniert:
- DNS von außen: `dig @192.168.178.10 google.de` → Timeout
- DNSmasq ignoriert weiterhin nicht-lokale Netzwerke

## Nächste Schritte

### Option 1: Pi-hole FTL-Konfiguration prüfen
- Möglicherweise überschreibt FTL die DNSmasq-Konfiguration
- Prüfen ob FTL eigene Konfiguration hat

### Option 2: Alternative DNSmasq-Konfiguration
- `local-service=false` sollte funktionieren, tut es aber nicht
- Möglicherweise benötigt Pi-hole FTL eine andere Konfiguration

### Option 3: Pi-hole Version prüfen
- Möglicherweise Bug in der verwendeten Pi-hole-Version
- Update oder Downgrade prüfen

### Option 4: Workaround - NodePort verwenden
- Service auf NodePort umstellen
- Windows direkt auf Node-IP:Port konfigurieren
- Umgeht MetalLB-Probleme

## Empfehlung

**Sofort**: Weitere Recherche zu Pi-hole FTL und DNSmasq-Konfiguration für nicht-lokale Netzwerke.

**Alternativ**: NodePort-Test durchführen, um zu bestätigen, dass das Problem bei DNSmasq liegt und nicht bei MetalLB.

