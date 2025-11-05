# Fritzbox Analyse

## Gerät-Informationen

- **Modell**: FRITZ!Box 7590 AX
- **FRITZ!OS Version**: 8.20
- **IP-Adresse**: 192.168.178.1
- **Subnetzmaske**: 255.255.255.0 (/24)
- **Netzwerk**: 192.168.178.0/24

## DHCP-Konfiguration

### Heimnetz
- **DHCP-Server**: Aktiviert ✓
- **IP-Bereich**: 192.168.178.20 - 192.168.178.200
- **Lease-Zeit**: 1 Tag
- **Lokaler DNS-Server**: **192.168.178.54** ← Wichtig!

**Analyse:**
- Der lokale DNS-Server ist auf 192.168.178.54 konfiguriert (Kubernetes LoadBalancer IP)
- Dies bedeutet, dass die Fritzbox allen DHCP-Clients diese IP als DNS-Server mitteilt
- Falls Pi-hole auf dieser IP läuft, wird es von allen Geräten verwendet

### Gastnetz
- **IP-Adresse**: 192.168.179.1
- **Subnetzmaske**: 255.255.255.0 (/24)
- **Lease-Zeit**: 1 Stunde

## Netzwerk-Übersicht

### Aktive Geräte (11 Geräte)

**LAN-Verbindungen:**
- `zuhause` (192.168.178.54) - Kubernetes Node, Echtzeitpriorisiert
- `DESKTOP-6QKGRU3` (192.168.178.25) - Echtzeitpriorisiert
- `ecb5fa1f8b45` (192.168.178.34) - Hue Bridge (Philips Hue)

**WLAN-Verbindungen:**
- `amazon-b8525b8c3` (192.168.178.21) - Smartphone
- `Android` (192.168.178.47) - Smartphone
- `Galaxy-Tab-S7` (192.168.178.49) - Tablet, Echtzeitpriorisiert
- `HarmonyHub` (192.168.178.20) - Logitech Harmony Hub
- `leah-laptop` (192.168.178.86) - Laptop
- `Pixel-8-Pro` (192.168.178.48) - Smartphone

**VPN-Verbindungen:**
- `Pixel` (192.168.178.202) - WireGuard VPN
- `bernd` (192.168.178.201) - IPSec VPN (inaktiv)
- `S7plus` (192.168.178.203) - WireGuard VPN (inaktiv)
- `z13` (192.168.178.204) - WireGuard VPN (inaktiv)

### Ungenutzte Verbindungen
- Mehrere alte Geräte-Einträge vorhanden (könnten aufgeräumt werden)

## Netzwerk-Einstellungen

### LAN-Ports
- **LAN 1-4**: Alle mit 1 Gbit/s
- **WAN**: Als LAN genutzt (aktiviert)
- **Energy Efficient Ethernet (EEE)**: Automatisch

### Gastzugang
- Gastzugang über LAN 4: Nicht aktiviert

### Funktion im Netzwerk
- **Betriebsart**: Internet-Router (Standard)
- Stellt Internetverbindung für Heimnetz bereit

## Sicherheitseinstellungen

### Heimnetzfreigaben
- **Zugriff für Apps erlauben**: Aktiviert (TR-064-Protokoll)
- **UPnP Statusinformationen**: Aktiviert

### DNS-Rebind-Schutz
- Zu prüfen (Menüpunkt vorhanden)

## Internet-Verbindung

- **Anbieter**: Telekom
- **Verbindung**: DSL
- **Bandbreite**: ↓267,7 Mbit/s, ↑44,3 Mbit/s
- **Status**: Verbunden seit 04.11.2025, 06:05 Uhr

## Identifizierte Themen

### 1. DNS-Konfiguration

**Aktuell:**
- Lokaler DNS-Server: 192.168.178.54 (Kubernetes LoadBalancer IP)
- Alle DHCP-Clients erhalten diese IP als DNS-Server

**Fragen:**
- Läuft Pi-hole auf 192.168.178.54?
- Oder läuft Pi-hole woanders und sollte als DNS-Server konfiguriert werden?
- Wie ist die DNS-Weiterleitung konfiguriert?

**Empfehlung:**
- Pi-hole IP identifizieren
- Falls Pi-hole auf anderer IP läuft, DNS-Server-Einstellung anpassen
- Upstream-DNS-Server prüfen (Internet-Einstellungen)

### 2. DHCP-IP-Bereich

**Aktuell:**
- IP-Bereich: 192.168.178.20 - 192.168.178.200
- Kubernetes LoadBalancer nutzt: 192.168.178.54

**Potenzielle Konflikte:**
- 192.168.178.54 liegt im DHCP-Bereich
- MetallB könnte Konflikte mit DHCP-Leases haben

**Empfehlung:**
- DHCP-Bereich auf 192.168.178.20 - 192.168.178.50 und 192.168.178.60 - 192.168.178.200 anpassen
- Oder statische Reservierung für 192.168.178.54 erstellen

### 3. Sicherheit

**Aktuell:**
- App-Zugriff aktiviert (TR-064)
- UPnP aktiviert

**Empfehlung:**
- DNS-Rebind-Schutz prüfen
- Unnötige Dienste deaktivieren falls nicht benötigt

## Nächste Schritte

1. Internet-DNS-Einstellungen prüfen (Upstream-DNS-Server)
2. Pi-hole IP-Adresse identifizieren
3. DNS-Rebind-Schutz prüfen
4. DHCP-Bereich optimieren (Konflikt mit Kubernetes LoadBalancer vermeiden)

