# Pi-hole Externe Anfragen Fix - Abgeschlossen

**Datum**: 2025-11-07  
**Status**: ✅ Konfiguration korrigiert, systemd-resolved gestoppt

## Problem

Pi-hole blockierte Anfragen von außerhalb des Clusters wegen:
1. dnsmasq-Konfiguration hatte `interface=eth0` (falsch für hostNetwork)
2. FTL-Konfiguration hatte `interface = "eth0"` (falsch für hostNetwork)
3. Port 53 war durch systemd-resolved blockiert

## Durchgeführte Änderungen

### 1. dnsmasq-Konfiguration (`k8s/pihole/dnsmasq-configmap.yaml`)

**Entfernt**: `interface=eth0`  
**Begründung**: Mit `hostNetwork: true` sollte dnsmasq auf allen Interfaces lauschen, nicht nur auf eth0.

**Aktuelle Konfiguration**:
```conf
listen-address=0.0.0.0          # Lauscht auf allen Adressen
bind-dynamic                     # Dynamisches Interface-Binding
local-service=false              # Erlaubt Anfragen von nicht-lokalen Netzwerken
localise-queries=false           # Verhindert Netzwerk-Erkennung
# Kein interface= - lauscht auf allen Interfaces
```

### 2. FTL-Konfiguration (`k8s/pihole/deployment.yaml`)

**Geändert**:
- `FTLCONF_dns_interface: "eth0"` → `"all"`
- `interface = "eth0"` → `"all"` in pihole.toml

**Begründung**: Mit `hostNetwork: true` sollte FTL auf allen Interfaces lauschen.

### 3. Service-Konfiguration (`k8s/pihole/service.yaml`)

**Geändert**:
- `type: LoadBalancer` → `ClusterIP`
- Ungültige `nodePort: 53` entfernt

**Begründung**: Mit `hostNetwork: true` lauscht Pi-hole direkt auf Host-Ports. Service ist nur für interne Kubernetes-Kommunikation nötig.

### 4. systemd-resolved gestoppt

**Aktion**: `systemctl stop systemd-resolved` und `systemctl disable systemd-resolved`

**Begründung**: systemd-resolved blockierte Port 53 (127.0.0.53:53 und 10.255.255.254:53). Da Pi-hole der DNS-Server sein soll, wurde systemd-resolved gestoppt.

## Finale Konfiguration

### Pi-hole Einstellungen für externe Anfragen

1. **dnsmasq**:
   - ✅ `listen-address=0.0.0.0` (lauscht auf allen Adressen)
   - ✅ `local-service=false` (erlaubt Anfragen von nicht-lokalen Netzwerken)
   - ✅ `localise-queries=false` (verhindert Netzwerk-Erkennung)
   - ✅ Kein `interface=` (lauscht auf allen Interfaces)

2. **FTL**:
   - ✅ `dns_listeningMode = "all"` (akzeptiert Anfragen von allen Netzwerken)
   - ✅ `interface = "all"` (lauscht auf allen Interfaces)

3. **Pi-hole Environment**:
   - ✅ `DNSMASQ_LISTENING: "all"`
   - ✅ `FTLCONF_dns_listeningMode: "all"`
   - ✅ `FTLCONF_dns_interface: "all"`

## Ergebnis

✅ **Pi-hole sollte jetzt**:
- Auf Port 53 auf allen Host-Interfaces lauschen
- DNS-Anfragen von allen Netzwerken akzeptieren (Kubernetes Pod Network + Home Network)
- Keine Anfragen von außerhalb blockieren

## Nächste Schritte

1. ✅ Konfiguration korrigiert
2. ✅ systemd-resolved gestoppt
3. ⏳ Pod sollte jetzt starten können
4. ⏳ DNS sollte auf `192.168.178.54:53` erreichbar sein
5. ⏳ Externe Clients können Pi-hole als DNS-Server nutzen

