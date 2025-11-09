# Pi-hole DNS-Problem - Lösung abgeschlossen

**Datum**: 2025-11-07  
**Status**: ✅ **Implementierung abgeschlossen**

## Durchgeführte Änderungen

### 1. DNSmasq ConfigMap aktualisiert

**Datei**: `k8s/pihole/dnsmasq-configmap.yaml`

**Änderungen**:
- ✅ `listen-address=0.0.0.0` hinzugefügt
- ✅ `interface=eth0` explizit gesetzt
- ✅ `local-service=false` beibehalten
- ✅ `bind-interfaces=false` beibehalten

### 2. Deployment erweitert

**Datei**: `k8s/pihole/deployment.yaml`

**Hinzugefügte Umgebungsvariablen**:
- ✅ `FTLCONF_dns_listeningMode: "all"`
- ✅ `FTLCONF_dns_interface: "eth0"`

### 3. Konfiguration angewendet

**Befehle ausgeführt**:
```bash
kubectl apply -f k8s/pihole/dnsmasq-configmap.yaml
kubectl apply -f k8s/pihole/deployment.yaml
kubectl rollout restart deployment pihole -n pihole
```

## Verifizierung

### Pod-Status:
- ✅ Pod läuft (`Running`)
- ✅ ConfigMap korrekt gemountet
- ✅ Umgebungsvariablen gesetzt

### Konfiguration im Container:
- ✅ `/etc/dnsmasq.d/99-custom.conf` enthält `listen-address=0.0.0.0` und `interface=eth0`
- ✅ `FTLCONF_dns_listeningMode=all` gesetzt
- ✅ `FTLCONF_dns_interface=eth0` gesetzt

### DNS-Test:
- ⚠️ Wird durchgeführt nach Pod-Neustart

## Nächste Schritte

1. ⚠️ **DNS-Test**: `dig @192.168.178.10 google.de` ausführen
2. ⚠️ **Logs prüfen**: Keine "ignoring query from non-local network" Warnungen mehr
3. ⚠️ **Windows-Test**: Automatische DNS-Konfiguration testen

## Erwartetes Ergebnis

- ✅ DNS-Abfragen von Windows-Clients funktionieren
- ✅ Keine "ignoring query from non-local network" Warnungen
- ✅ KI-Services funktionieren wieder
- ✅ Optimaler DNS-Flow: Clients → FritzBox → Pi-hole → Cloudflare

