# Pi-hole DNS-Problem - Aktueller Status

**Datum**: 2025-11-07  
**Problem**: DNS funktioniert nicht von außen  
**Status**: ⚠️ **Problem besteht weiterhin - Weitere Untersuchung erforderlich**

## Aktueller Stand

### ✅ Was funktioniert:
- Pi-hole Pod läuft (`Running`)
- DNS lokal im Container funktioniert
- ConfigMap ist korrekt gemountet (`interface=eth0` gesetzt)
- FTL läuft und lauscht auf Port 53

### ❌ Was nicht funktioniert:
- DNS von außen: `dig @192.168.178.10 google.de` → Timeout
- DNSmasq ignoriert weiterhin nicht-lokale Netzwerke
- Log zeigt: `dnsmasq: ignoring query from non-local network 192.168.178.20`

## Durchgeführte Maßnahmen

1. ✅ ConfigMap `pihole-dnsmasq-custom` angepasst:
   - `local-service=false`
   - `interface=eth0` (explizit gesetzt)
   - `bind-interfaces=false`
   - `listen-address=0.0.0.0`
   - `localise-queries=false`

2. ✅ ConfigMap `pihole-config` geprüft:
   - `DNSMASQ_LISTENING=all` ist gesetzt

3. ✅ Pod mehrfach neu gestartet

4. ❌ Problem besteht weiterhin

## Mögliche Ursachen

1. **Pi-hole FTL überschreibt DNSmasq-Konfiguration**:
   - FTL könnte eigene Konfiguration haben, die die DNSmasq-Config überschreibt
   - Möglicherweise muss FTL direkt konfiguriert werden

2. **Pi-hole-Version hat Bug**:
   - Möglicherweise Bug in der verwendeten Pi-hole-Version
   - Update oder Downgrade könnte helfen

3. **Kubernetes Network-Policy**:
   - Obwohl keine Network Policies gefunden wurden, könnte es ein Problem geben

4. **MetalLB UDP-Problem**:
   - NodePort funktioniert auch nicht, was darauf hindeutet, dass das Problem nicht bei MetalLB liegt

## Nächste Schritte

1. **Pi-hole FTL-Konfiguration prüfen**: Ob FTL die DNSmasq-Config überschreibt
2. **Pi-hole-Version prüfen**: Ob Update verfügbar ist
3. **Alternative Lösung**: Service auf NodePort umstellen (Workaround)
4. **Pi-hole Web-UI**: Manuelle Konfiguration über Web-Interface prüfen

## Empfehlung

**Sofort**: Pi-hole FTL-Konfiguration genauer untersuchen und prüfen, ob FTL die DNSmasq-Config überschreibt.

**Alternativ**: Workaround mit NodePort oder direkter Konfiguration über Pi-hole Web-UI.

