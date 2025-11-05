# Pi-hole Analyse

## Status (Aktualisiert: 2025-11-05)

**⚠️ Pi-hole läuft nicht oder ist nicht erreichbar.**

### Aktuelle Situation

- **Erwartete IP**: 192.168.178.10 (Kubernetes LoadBalancer)
- **Netzwerk-Erreichbarkeit**: ✅ Ping funktioniert
- **Port 53**: ❌ Nicht erreichbar (Timeout)
- **DNS-Abfragen**: ❌ Schlagen fehl
- **Docker Pi-hole**: Gestoppt (Exited 4 hours ago laut `debian-server-analysis-report.md`)

### Suchresultate

- **192.168.178.54**: Kubernetes LoadBalancer (Ingress-Controller, nicht Pi-hole)
- **192.168.178.10**: IP ist pingbar, aber Port 53 nicht erreichbar
- **Pi-hole API**: Nicht erreichbar
- **Pi-hole Webinterface**: Nicht erreichbar
- **Kubernetes-Cluster**: Aktuell nicht erreichbar (kann nicht direkt geprüft werden)

## Mögliche Szenarien

### 1. Pi-hole läuft nicht oder ist deaktiviert
- Pi-hole wurde möglicherweise deinstalliert oder ist nicht mehr aktiv
- System könnte überarbeitet werden

### 2. Pi-hole läuft in Kubernetes
- Möglicherweise als Kubernetes-Service
- Prüfung ergab: Keine Pi-hole Pods im Cluster

### 3. Pi-hole läuft auf nicht erreichbarer IP
- Möglicherweise in anderem Netzwerk-Segment
- Oder nur über VPN erreichbar

## Fritzbox-DNS-Konfiguration

Die Fritzbox ist konfiguriert mit:
- **Lokaler DNS-Server**: 192.168.178.54 (Kubernetes LoadBalancer)
- **DHCP**: Gibt 192.168.178.54 als DNS-Server an alle Clients weiter

## Empfehlungen

### Option 1: Pi-hole installieren/aktivieren
- Pi-hole auf separatem Gerät oder in Kubernetes installieren
- IP-Adresse außerhalb des DHCP-Bereichs wählen (z.B. 192.168.178.10)
- Fritzbox DNS-Server-Einstellung auf Pi-hole IP ändern

### Option 2: Kubernetes DNS nutzen
- CoreDNS ist bereits im Cluster aktiv
- Aktuell forwardet CoreDNS an Fritzbox (192.168.178.1)
- Konfiguration prüfen ob Pi-hole als Upstream verwendet werden kann

### Option 3: DNS-Stack ohne Pi-hole
- Direkt Cloudflare/United Domains DNS verwenden
- Für Let's Encrypt DNS-Challenge: Cloudflare API bereits konfiguriert

## Nächste Schritte

1. **Sofort**: Cloudflare DNS als Workaround für betroffene Clients (siehe `laptop-dns-fix-fedora.md`)
2. **Kubernetes-Cluster-Verfügbarkeit prüfen**: Warten bis Cluster wieder erreichbar ist
3. **Pi-hole Status prüfen**: Sobald Cluster erreichbar ist
   - `kubectl get pods -A | grep pihole`
   - `kubectl get svc -A | grep pihole`
4. **Falls Pi-hole nicht existiert**: In Kubernetes deployen
   - IP: 192.168.178.10 (MetallB LoadBalancer)
   - Helm Chart: `mojo2600/pihole`
5. **Falls Pi-hole existiert aber nicht funktioniert**: Service-Konfiguration prüfen
6. **DNS-Stack optimieren**: Fritzbox → Pi-hole → Cloudflare/United Domains
7. **Zurück zu Pi-hole wechseln**: Nach erfolgreicher Reparatur

## Bekannte Probleme (2025-11-05)

- **Port 53 nicht erreichbar**: Pi-hole läuft nicht oder Service ist nicht korrekt konfiguriert
- **Kubernetes-Cluster nicht erreichbar**: Kann aktuell nicht direkt geprüft werden
- **Workaround verfügbar**: Cloudflare DNS (1.1.1.1) funktioniert temporär

Siehe: `laptop-dns-problem-analysis.md` für vollständige Analyse.

