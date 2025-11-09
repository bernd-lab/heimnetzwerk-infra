# Pi-hole Port 53 Final - Abgeschlossen

**Datum**: 2025-11-07  
**Status**: ✅ Konfiguration für externe Anfragen korrigiert

## Zusammenfassung der Änderungen

### Problem 1: Pi-hole blockierte externe Anfragen ✅ GELÖST

**Ursache**: 
- dnsmasq hatte `interface=eth0` (falsch für hostNetwork)
- FTL hatte `interface = "eth0"` (falsch für hostNetwork)

**Lösung**:
- `interface=eth0` aus dnsmasq-Konfiguration entfernt
- `FTLCONF_dns_interface: "all"` gesetzt
- `interface = "all"` in pihole.toml gesetzt

### Problem 2: Port-Konflikte ✅ GELÖST

**Ursache**: 
- Kubernetes deklarierte Ports im Deployment blockierten Scheduling
- systemd-resolved belegte Port 53

**Lösung**:
- Port-Deklarationen aus Deployment entfernt (bei hostNetwork nicht nötig)
- systemd-resolved gestoppt und deaktiviert

## Finale Konfiguration

### dnsmasq (`k8s/pihole/dnsmasq-configmap.yaml`)
```conf
listen-address=0.0.0.0          # Lauscht auf allen Adressen
bind-dynamic                     # Dynamisches Interface-Binding
local-service=false              # Erlaubt Anfragen von nicht-lokalen Netzwerken
localise-queries=false           # Verhindert Netzwerk-Erkennung
# Kein interface= - lauscht auf allen Interfaces
```

### FTL (`k8s/pihole/deployment.yaml`)
- `FTLCONF_dns_listeningMode: "all"` ✅
- `FTLCONF_dns_interface: "all"` ✅
- `interface = "all"` in pihole.toml ✅

### Deployment (`k8s/pihole/deployment.yaml`)
- `hostNetwork: true` ✅
- `dnsPolicy: ClusterFirstWithHostNet` ✅
- Keine Port-Deklarationen (bei hostNetwork nicht nötig) ✅

### Service (`k8s/pihole/service.yaml`)
- `type: ClusterIP` ✅
- Ports: 53 TCP/UDP, 80 TCP ✅

## Erwartetes Ergebnis

Mit dieser Konfiguration sollte Pi-hole:
- ✅ Auf Port 53 auf allen Host-Interfaces lauschen (`0.0.0.0:53`)
- ✅ DNS-Anfragen von allen Netzwerken akzeptieren (Kubernetes Pod Network + Home Network)
- ✅ Keine Anfragen von außerhalb blockieren
- ✅ Für FritzBox als DNS-Server konfigurierbar sein (`192.168.178.54`)

## Nächste Schritte

1. ✅ Konfiguration korrigiert
2. ✅ Port-Konflikte behoben
3. ⏳ Pod sollte jetzt starten können
4. ⏳ DNS sollte auf `192.168.178.54:53` erreichbar sein
5. ⏳ FritzBox kann `192.168.178.54` als DNS-Server konfigurieren

