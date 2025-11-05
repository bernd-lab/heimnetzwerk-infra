# Laptop DNS-Problem Analyse (Fedora 42)

**Erstellt**: 2025-11-05 20:30  
**Analysiert von**: DNS-Expert + Infrastructure-Expert  
**Betroffenes Gerät**: Fedora 42 Laptop

## Problem-Beschreibung

### Symptome
- **DNS-Server konfiguriert**: 192.168.178.10 (Pi-hole) ✅
- **Netzwerk-Erreichbarkeit**: Pi-hole kann gepingt werden ✅
- **DNS-Abfragen**: Schlagen komplett fehl ❌
  - `dig @192.168.178.10 google.de` → Timeout
  - `nc -zv 192.168.178.10 53` → Timeout
- **Direkte DNS-Abfrage funktioniert**: `dig @1.1.1.1 google.de` → ✅ Erfolg

### Root Cause Analyse

**Problem identifiziert**: Pi-hole läuft nicht oder Port 53 ist nicht erreichbar.

**Beweise**:
1. Port 53 TCP/UDP ist nicht erreichbar (Timeout bei `nc` und `dig`)
2. Ping funktioniert → Netzwerk-Erreichbarkeit OK
3. Direkte DNS-Abfrage an Cloudflare funktioniert → DNS-Client funktioniert
4. Kubernetes und SSH zum Debian-Server sind nicht erreichbar (Cluster-Problem)

## Analyse-Ergebnisse

### 1. Pi-hole Service-Status

**Vermutung**: Pi-hole läuft nicht in Kubernetes.

**Beweise**:
- `pihole-analyse.md`: "Pi-hole wurde nicht im Netzwerk gefunden"
- `debian-server-analysis-report.md`: "pihole: ✅ Exited (0) 4 hours ago" (Docker-Container gestoppt)
- Port 53 ist nicht erreichbar
- Kubernetes-Cluster ist aktuell nicht erreichbar (kann nicht direkt geprüft werden)

**Dokumentation sagt**:
- Pi-hole sollte in Kubernetes auf IP 192.168.178.10 laufen
- Docker Pi-hole wurde gestoppt (Migration zu Kubernetes)
- Aber: Pi-hole wurde möglicherweise nie erfolgreich in Kubernetes deployed

### 2. Port 53 Erreichbarkeit

**Test-Ergebnisse**:
```bash
# DNS-Abfrage
dig @192.168.178.10 google.de
# Ergebnis: communications error to 192.168.178.10#53: timed out

# Port 53 TCP
nc -zv 192.168.178.10 53
# Ergebnis: Connection timed out

# Ping (Netzwerk OK)
ping 192.168.178.10
# Ergebnis: ✅ 2 packets transmitted, 2 received, 0% packet loss
```

**Fazit**: Port 53 ist nicht erreichbar, aber Netzwerk-Erreichbarkeit ist OK.

### 3. Pi-hole Service-Konfiguration

**Laut Dokumentation**:
- Pi-hole sollte als Kubernetes LoadBalancer Service laufen
- IP: 192.168.178.10 (MetallB)
- Ports: 53 TCP/UDP (DNS), 80 (Webinterface)

**Aktueller Status**: Unbekannt (Kubernetes nicht erreichbar)

### 4. Firewall-Regeln

**Mögliche Probleme**:
- Kubernetes NetworkPolicies blockieren Port 53
- Fritzbox Firewall blockiert Port 53 (unwahrscheinlich, da Ping funktioniert)
- Fedora Firewall (firewalld) blockiert ausgehende DNS-Abfragen (unwahrscheinlich, da 1.1.1.1 funktioniert)

**Wahrscheinlichste Ursache**: Pi-hole Service läuft nicht

### 5. Alternative DNS-Server

**Test-Ergebnis**:
```bash
dig @1.1.1.1 google.de
# Ergebnis: ✅ 216.58.206.67 (erfolgreich)
```

**Fazit**: DNS-Client funktioniert, Problem liegt bei Pi-hole.

## Lösung-Implementierung

### Option A: Pi-hole Service reparieren (Empfohlen)

**Voraussetzungen**:
- Kubernetes-Cluster muss erreichbar sein
- SSH-Zugriff auf Debian-Server (192.168.178.54)

**Schritte**:
1. **Kubernetes-Cluster-Verfügbarkeit prüfen**
   ```bash
   kubectl get nodes
   kubectl cluster-info
   ```

2. **Pi-hole Pod/Service prüfen**
   ```bash
   kubectl get pods -A | grep pihole
   kubectl get svc -A | grep pihole
   kubectl describe svc pihole -n <namespace>
   ```

3. **Falls Pi-hole nicht existiert: Deployen**
   ```bash
   # Helm Chart installieren
   helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
   helm install pihole mojo2600/pihole \
     --namespace pihole \
     --create-namespace \
     --set service.loadBalancerIP=192.168.178.10 \
     --set service.type=LoadBalancer
   ```

4. **MetallB IP-Pool prüfen/erweitern**
   ```bash
   kubectl get ipaddresspool -n metallb-system
   # Prüfen ob 192.168.178.10 im Pool ist
   ```

5. **Port 53 Erreichbarkeit testen**
   ```bash
   dig @192.168.178.10 google.de
   curl http://192.168.178.10/admin
   ```

### Option B: Temporärer Workaround (Sofort-Lösung)

**Für Fedora 42 Laptop**:

1. **Cloudflare DNS temporär setzen**
   ```bash
   # NetworkManager (Fedora Standard)
   nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1"
   nmcli connection down "Wired connection 1"
   nmcli connection up "Wired connection 1"
   
   # Oder manuell in /etc/resolv.conf (temporär)
   echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
   ```

2. **DNS-Test**
   ```bash
   dig google.de
   nslookup google.de
   ```

3. **Später zurück zu Pi-hole wechseln** (nachdem Pi-hole repariert ist)

### Option C: Fritzbox DNS-Server ändern (System-weit)

**Falls Pi-hole nicht repariert werden kann**:

1. **Fritzbox DNS-Server auf Cloudflare ändern**
   - Menü: Internet → Zugangsdaten → DNS-Server
   - DNS-Server: 1.1.1.1, 1.0.0.1 (Cloudflare)
   - Alle DHCP-Clients erhalten dann Cloudflare DNS

2. **Vorteil**: Funktioniert sofort für alle Geräte
3. **Nachteil**: Pi-hole-Features (Ad-Blocking, lokale DNS-Records) gehen verloren

## Empfohlene Lösung

### Sofort (Workaround)
1. **Fedora Laptop**: Cloudflare DNS temporär setzen (Option B)
2. **DNS-Test**: Verifizieren dass DNS wieder funktioniert

### Mittelfristig (Pi-hole reparieren)
1. **Kubernetes-Cluster-Verfügbarkeit prüfen**
2. **Pi-hole Status prüfen**
3. **Falls nicht vorhanden**: Pi-hole in Kubernetes deployen
4. **Falls vorhanden aber nicht erreichbar**: Service-Konfiguration prüfen
5. **Zurück zu Pi-hole wechseln** (nach erfolgreicher Reparatur)

## Fedora 42 Spezifische Hinweise

### NetworkManager DNS-Konfiguration

**Prüfen aktuelle DNS-Konfiguration**:
```bash
# Aktive Verbindung
nmcli connection show --active

# DNS-Server prüfen
nmcli connection show "Wired connection 1" | grep ipv4.dns

# DNS-Konfiguration ändern
nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1"
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

### systemd-resolved (falls aktiv)

**Prüfen**:
```bash
systemctl status systemd-resolved
resolvectl status
```

**Falls aktiv**: DNS-Konfiguration kann über systemd-resolved verwaltet werden.

### firewalld (Firewall)

**Prüfen ob DNS blockiert wird**:
```bash
sudo firewall-cmd --list-all
sudo firewall-cmd --list-services
```

**DNS sollte erlaubt sein** (Standard: `dns` Service ist erlaubt).

## Nächste Schritte

1. **Sofort**: Cloudflare DNS als Workaround setzen (Option B)
2. **Cluster-Verfügbarkeit prüfen**: Warten bis Kubernetes wieder erreichbar ist
3. **Pi-hole Status prüfen**: Sobald Cluster erreichbar ist
4. **Pi-hole reparieren/deployen**: Falls nicht vorhanden oder nicht funktionsfähig
5. **Zurück zu Pi-hole wechseln**: Nach erfolgreicher Reparatur

## Dokumentation aktualisieren

- `pihole-analyse.md` - Pi-hole Status aktualisieren
- `fritzbox-kubernetes-integration.md` - DNS-Problem dokumentieren
- `kubernetes-analyse.md` - Pi-hole Service-Status aktualisieren

## Wichtige Erkenntnisse

1. **Pi-hole läuft nicht**: Port 53 ist nicht erreichbar, aber IP ist pingbar
2. **Kubernetes-Cluster nicht erreichbar**: Kann aktuell nicht direkt geprüft werden
3. **Workaround verfügbar**: Cloudflare DNS (1.1.1.1) funktioniert
4. **Root Cause**: Pi-hole Service fehlt oder ist nicht korrekt konfiguriert

