# Pi-hole Externe Anfragen Fix

**Datum**: 2025-11-07  
**Status**: ✅ Konfiguration korrigiert für hostNetwork-Modus

## Problem

Pi-hole blockierte Anfragen von außerhalb des Clusters, weil:
1. dnsmasq-Konfiguration hatte `interface=eth0` (falsch für hostNetwork)
2. FTL-Konfiguration hatte `interface = "eth0"` (falsch für hostNetwork)
3. Port-Konflikte verhinderten Pod-Start

## Durchgeführte Änderungen

### 1. dnsmasq-Konfiguration (`k8s/pihole/dnsmasq-configmap.yaml`)

**Vorher**:
```conf
interface=eth0  # Falsch für hostNetwork
```

**Nachher**:
```conf
# Do NOT set interface=eth0 with hostNetwork - let dnsmasq listen on all interfaces
# This allows queries from all networks (Kubernetes Pod Network + Home Network)
```

**Begründung**: Mit `hostNetwork: true` läuft Pi-hole direkt auf Host-Interfaces. `interface=eth0` würde nur auf einem Interface lauschen. Ohne `interface=` lauscht dnsmasq auf allen Interfaces.

### 2. FTL-Konfiguration (`k8s/pihole/deployment.yaml`)

**Vorher**:
- `FTLCONF_dns_interface: "eth0"`
- `interface = "eth0"` in pihole.toml

**Nachher**:
- `FTLCONF_dns_interface: "all"`
- `interface = "all"` in pihole.toml

**Begründung**: Mit `hostNetwork: true` sollte FTL auf allen Interfaces lauschen, nicht nur auf eth0.

### 3. Service-Konfiguration (`k8s/pihole/service.yaml`)

**Vorher**:
- `type: LoadBalancer`
- `nodePort: 53` (ungültig - nur 30000-32767 erlaubt)

**Nachher**:
- `type: ClusterIP`
- Kein nodePort (nicht nötig mit hostNetwork)

**Begründung**: Mit `hostNetwork: true` lauscht Pi-hole direkt auf Host-Ports. Ein Service ist nur für interne Kubernetes-Kommunikation nötig.

## Konfiguration für externe Anfragen

### Aktuelle Einstellungen

1. **dnsmasq**:
   - `listen-address=0.0.0.0` ✅ (lauscht auf allen Adressen)
   - `local-service=false` ✅ (erlaubt Anfragen von nicht-lokalen Netzwerken)
   - `localise-queries=false` ✅ (verhindert Netzwerk-Erkennung)
   - Kein `interface=` ✅ (lauscht auf allen Interfaces)

2. **FTL**:
   - `dns_listeningMode = "all"` ✅ (akzeptiert Anfragen von allen Netzwerken)
   - `interface = "all"` ✅ (lauscht auf allen Interfaces)

3. **Pi-hole Environment**:
   - `DNSMASQ_LISTENING: "all"` ✅
   - `FTLCONF_dns_listeningMode: "all"` ✅
   - `FTLCONF_dns_interface: "all"` ✅

## Erwartetes Ergebnis

Mit diesen Änderungen sollte Pi-hole:
- ✅ Auf Port 53 auf allen Host-Interfaces lauschen
- ✅ DNS-Anfragen von allen Netzwerken akzeptieren (Kubernetes Pod Network + Home Network)
- ✅ Keine Anfragen von außerhalb blockieren

## Nächste Schritte

1. Pod sollte jetzt starten können (Port-Konflikte behoben)
2. DNS sollte auf `192.168.178.54:53` erreichbar sein
3. Externe Clients (Windows, etc.) sollten Pi-hole als DNS-Server nutzen können

