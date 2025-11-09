# Pi-hole DNS-Problem - Lösung implementiert

**Datum**: 2025-11-07  
**Status**: ✅ **Lösung implementiert - Bereit zur Anwendung**

## Problem

DNSmasq ignoriert DNS-Anfragen von Windows-Clients (192.168.178.x) mit der Warnung:
```
WARNING: dnsmasq: ignoring query from non-local network 192.168.178.20
```

**Root Cause**: 
- Pi-hole FTL verwendet dnsmasq, das standardmäßig nur Anfragen von "lokalen" Netzwerken akzeptiert
- In Kubernetes läuft der Pod im Pod-Netzwerk (10.244.0.0/16)
- Anfragen kommen vom Heimnetz (192.168.178.0/24) über MetalLB
- dnsmasq sieht diese als "nicht-lokal" an und ignoriert sie

## Implementierte Lösung

### 1. Pi-hole FTL-Konfiguration (`pihole.toml`)

**Datei**: `k8s/pihole/deployment.yaml` (Init-Container)

**Änderungen**:
- ✅ `dns_listeningMode = "all"` wird jetzt in `pihole.toml` gesetzt
- ✅ `interface = "eth0"` wird weiterhin gesetzt
- ✅ Init-Container aktualisiert, um beide Einstellungen korrekt zu konfigurieren

**Warum wichtig**:
- `dns_listeningMode = "all"` ist die **kritische** Einstellung, die FTL anweist, DNS-Anfragen von allen Netzwerken zu akzeptieren
- Diese Einstellung wurde bisher nur als Umgebungsvariable (`FTLCONF_dns_listeningMode`) gesetzt, aber nicht in `pihole.toml`
- FTL liest `pihole.toml` und kann Umgebungsvariablen überschreiben

### 2. DNSmasq-ConfigMap optimiert

**Datei**: `k8s/pihole/dnsmasq-configmap.yaml`

**Änderungen**:
- ✅ `bind-dynamic` statt `bind-interfaces=false` verwendet
- ✅ `localise-queries=false` hinzugefügt
- ✅ `local-service=false` beibehalten
- ✅ `listen-address=0.0.0.0` beibehalten
- ✅ `interface=eth0` beibehalten

**Warum wichtig**:
- `bind-dynamic` ist besser für Kubernetes, da es Interfaces dynamisch bindet
- `localise-queries=false` verhindert, dass dnsmasq versucht, "lokale" Netzwerke zu bestimmen
- Zusammen mit `local-service=false` erlaubt dies Anfragen von allen Netzwerken

### 3. Service-Konfiguration optimiert

**Datei**: `k8s/pihole/service.yaml`

**Änderungen**:
- ✅ `externalTrafficPolicy: Local` hinzugefügt

**Warum wichtig**:
- `externalTrafficPolicy: Local` stellt sicher, dass die Source-IP der Clients erhalten bleibt
- Dies ist wichtig, damit dnsmasq die richtige Source-IP sieht und nicht die Kubernetes-Proxy-IP

## Anwendung der Lösung

### Schritt 1: Konfiguration anwenden

```bash
cd /home/bernd/infra-0511

# ConfigMap aktualisieren
kubectl apply -f k8s/pihole/dnsmasq-configmap.yaml

# Service aktualisieren
kubectl apply -f k8s/pihole/service.yaml

# Deployment aktualisieren (wird Pod neu starten)
kubectl apply -f k8s/pihole/deployment.yaml

# Pod-Neustart erzwingen (falls nötig)
kubectl rollout restart deployment pihole -n pihole
```

### Schritt 2: Pod-Status prüfen

```bash
# Pod-Status
kubectl get pods -n pihole

# Init-Container-Logs prüfen (sollte "SUCCESS: pihole.toml configured correctly" zeigen)
kubectl logs -n pihole -l app=pihole -c fix-pihole-config

# Pi-hole-Logs prüfen (sollte keine "ignoring query from non-local network" Warnungen mehr zeigen)
kubectl logs -n pihole -l app=pihole --tail=50
```

### Schritt 3: Konfiguration im Container verifizieren

```bash
# Pi-hole Pod-Name ermitteln
POD=$(kubectl get pods -n pihole -l app=pihole -o jsonpath='{.items[0].metadata.name}')

# pihole.toml prüfen
kubectl exec -n pihole $POD -- cat /etc/pihole/pihole.toml

# Erwartete Ausgabe:
# [FTL]
# interface = "eth0"
# dns_listeningMode = "all"

# DNSmasq-Config prüfen
kubectl exec -n pihole $POD -- cat /etc/dnsmasq.d/99-custom.conf
```

### Schritt 4: DNS-Tests durchführen

```bash
# DNS-Abfrage vom Server testen
dig @192.168.178.10 google.de

# Erwartete Ausgabe: IP-Adresse von google.de

# DNS-Abfrage von Windows-Client testen
# Auf Windows-PC ausführen:
# nslookup google.de 192.168.178.10

# Logs auf Warnungen prüfen
kubectl logs -n pihole -l app=pihole --tail=100 | grep -i "ignoring\|warning"
# Erwartete Ausgabe: Keine "ignoring query from non-local network" Warnungen
```

## Erwartetes Ergebnis

Nach erfolgreicher Anwendung:

- ✅ Keine "ignoring query from non-local network" Warnungen mehr in den Logs
- ✅ `dig @192.168.178.10 google.de` funktioniert von allen Clients
- ✅ Windows-Clients können automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder
- ✅ `pihole.toml` enthält `dns_listeningMode = "all"`

## Technische Details

### Warum die Lösung funktioniert

1. **FTL-Konfiguration (`pihole.toml`)**:
   - `dns_listeningMode = "all"` weist FTL an, DNS-Anfragen von allen Netzwerken zu akzeptieren
   - Dies ist die primäre Konfiguration, die FTL verwendet

2. **DNSmasq-ConfigMap**:
   - `bind-dynamic` ermöglicht dynamisches Binden von Interfaces
   - `localise-queries=false` verhindert lokale Netzwerk-Erkennung
   - `local-service=false` erlaubt Anfragen von nicht-lokalen Netzwerken

3. **Service-Konfiguration**:
   - `externalTrafficPolicy: Local` erhält die Source-IP der Clients
   - Dies ist wichtig für die korrekte Netzwerk-Erkennung

### Unterschied zu vorherigen Versuchen

**Vorher**:
- Nur Umgebungsvariablen (`FTLCONF_dns_listeningMode=all`)
- `pihole.toml` hatte nur `interface = "eth0"`
- `dns_listeningMode` wurde nicht in `pihole.toml` gesetzt

**Jetzt**:
- `dns_listeningMode = "all"` wird explizit in `pihole.toml` gesetzt
- Init-Container stellt sicher, dass die Konfiguration korrekt ist
- DNSmasq-ConfigMap verwendet `bind-dynamic` statt `bind-interfaces`
- Service verwendet `externalTrafficPolicy: Local`

## Fallback-Plan

Falls die Lösung nicht funktioniert:

1. **HostNetwork-Modus testen** (falls möglich):
   - Pod mit `hostNetwork: true` deployen
   - Würde Netzwerk-Isolation umgehen

2. **NodePort-Service testen**:
   - LoadBalancer durch NodePort ersetzen
   - Könnte Netzwerk-Flow ändern

3. **Pi-hole-Version prüfen**:
   - Eventuell auf neueste Version aktualisieren
   - Bekannte Probleme in älteren Versionen

## Zusammenfassung

Die Lösung kombiniert drei wichtige Änderungen:

1. ✅ **FTL-Konfiguration**: `dns_listeningMode = "all"` in `pihole.toml`
2. ✅ **DNSmasq-ConfigMap**: `bind-dynamic` und `localise-queries=false`
3. ✅ **Service-Konfiguration**: `externalTrafficPolicy: Local`

Diese Kombination sollte das Problem beheben, da sie auf allen Ebenen (FTL, dnsmasq, Kubernetes Service) die Annahme von Anfragen von nicht-lokalen Netzwerken ermöglicht.

