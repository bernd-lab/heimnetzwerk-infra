# Pi-hole DNS-Problem Finale Analyse

**Datum**: 2025-11-07  
**Problem**: DNS funktioniert im Container, aber nicht von außen  
**Status**: ⚠️ **Problem identifiziert - MetalLB UDP-Weiterleitung**

## Aktueller Status

### ✅ Was funktioniert:

1. **Pi-hole Pod läuft**: Status `Running`
2. **DNS lokal funktioniert**: `dig @127.0.0.1 google.de` → funktioniert ✅
3. **FTL läuft**: `pihole status` zeigt "FTL is listening on port 53" ✅
4. **Port 53 offen**: Lauscht auf `0.0.0.0:53` (UDP und TCP) ✅
5. **Service konfiguriert**: LoadBalancer mit IP `192.168.178.10` ✅
6. **MetalLB IP zugewiesen**: `192.168.178.10 (VIP)` ✅

### ❌ Was nicht funktioniert:

1. **DNS von außen**: `dig @192.168.178.10 google.de` → Timeout ❌
2. **DNS auf Pod-IP**: `dig @10.244.0.253 google.de` → Timeout ❌
3. **Windows DNS**: Kann keine DNS-Abfragen durchführen ❌

## Problem-Analyse

### Mögliche Ursachen:

1. **MetalLB L2-Modus UDP-Problem**:
   - MetalLB verwendet L2-Modus (ARP-Responder)
   - UDP-Traffic wird möglicherweise nicht richtig weitergeleitet
   - ARP-Responder antwortet nur auf ARP-Anfragen, nicht auf UDP-Pakete

2. **Service externalTrafficPolicy**:
   - Aktuell: `Cluster` (Standard)
   - Getestet: `Local` (keine Verbesserung)

3. **Network-Policy oder Firewall**:
   - Keine Network Policies gefunden
   - iptables-Regeln zeigen NodePort-Weiterleitung

4. **Pi-hole FTL-Konfiguration**:
   - `DNSMASQ_LISTENING=all` sollte auf allen Interfaces lauschen
   - FTL läuft, aber möglicherweise Problem mit Interface-Binding

## Durchgeführte Tests

### ✅ Erfolgreich:
- DNS lokal im Container: `dig @127.0.0.1 google.de` → funktioniert
- Pi-hole Status: FTL läuft, Port 53 offen
- Service-Endpoints: Korrekt konfiguriert

### ❌ Fehlgeschlagen:
- DNS von außen: `dig @192.168.178.10 google.de` → Timeout
- DNS auf Pod-IP: `dig @10.244.0.253 google.de` → Timeout
- NodePort-Test: Nicht getestet (könnte funktionieren)

## Nächste Schritte

### Option 1: NodePort testen
```bash
dig @192.168.178.54 -p 31047 google.de
```
Falls das funktioniert, ist das Problem bei MetalLB L2-Modus für UDP.

### Option 2: MetalLB auf BGP-Modus umstellen
- BGP-Modus könnte UDP-Traffic besser handhaben
- Erfordert BGP-Router-Konfiguration

### Option 3: Service auf NodePort umstellen
- Direkter Zugriff über Node-IP:Port
- Umgeht MetalLB-Probleme

### Option 4: Pi-hole direkt auf Node deployen
- Nicht ideal, aber würde das Problem umgehen

## Empfehlung

**Sofort**: NodePort testen, um zu bestätigen, dass das Problem bei MetalLB liegt.

**Langfristig**: MetalLB-Konfiguration prüfen oder auf NodePort umstellen, falls MetalLB L2-Modus UDP-Probleme hat.

