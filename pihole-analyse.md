# Pi-hole Analyse

## Status

**Pi-hole wurde nicht im Netzwerk gefunden.**

### Suchresultate

- **192.168.178.54**: Kubernetes LoadBalancer (nicht Pi-hole)
- **Scan durchgeführt**: IPs 192.168.178.20-202 getestet
- **Pi-hole API**: Nicht erreichbar
- **Pi-hole Webinterface**: Nicht gefunden

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

1. Klären ob Pi-hole gewünscht/benötigt wird
2. Falls ja: Pi-hole installieren und konfigurieren
3. DNS-Stack optimieren: Fritzbox → Pi-hole → Cloudflare/United Domains
4. Certbot DNS-Challenge Integration prüfen

