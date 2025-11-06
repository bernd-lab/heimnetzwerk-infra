# Windows DNS-Konfiguration: Automatisch von Fritzbox

## Problem
Windows verwendet manuelle DNS-Einstellungen statt automatisch DNS von der Fritzbox zu erhalten.

## Lösung: DNS auf automatisch setzen

### Methode 1: Über Netzwerk-Einstellungen (GUI)

1. **Netzwerk-Adapter öffnen**:
   - Windows-Taste + R
   - `ncpa.cpl` eingeben und Enter drücken
   - Oder: Systemsteuerung → Netzwerk und Freigabecenter → Adaptereinstellungen ändern

2. **Aktiven Adapter finden**:
   - Suche nach "Ethernet" oder "WLAN" (je nach Verbindung)
   - Rechtsklick → **Eigenschaften**

3. **IPv4-Eigenschaften öffnen**:
   - Wähle **"Internetprotokoll Version 4 (TCP/IPv4)"**
   - Klicke auf **"Eigenschaften"**

4. **DNS auf automatisch setzen**:
   - Wähle **"Folgende DNS-Serveradressen verwenden"** → **"DNS-Serveradressen automatisch beziehen"**
   - Klicke auf **"OK"**

5. **IPv6-Eigenschaften (falls aktiviert)**:
   - Wähle **"Internetprotokoll Version 6 (TCP/IPv6)"**
   - Klicke auf **"Eigenschaften"**
   - Wähle **"DNS-Serveradressen automatisch beziehen"**
   - Klicke auf **"OK"**

6. **Übernehmen**:
   - Klicke auf **"OK"** im Adapter-Eigenschaften-Fenster
   - Windows erneuert die Netzwerkverbindung automatisch

### Methode 2: Über PowerShell (Administrator)

```powershell
# Als Administrator ausführen!

# Alle Netzwerkadapter auflisten
Get-NetAdapter

# Aktiven Adapter finden (z.B. "Ethernet" oder "Wi-Fi")
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

# DNS auf automatisch setzen (DHCP)
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses

# Prüfen
Get-DnsClientServerAddress -InterfaceAlias $adapter.Name
```

### Methode 3: Über CMD (Administrator)

```cmd
REM Als Administrator ausführen!

REM Alle Adapter auflisten
netsh interface show interface

REM DNS auf automatisch setzen (z.B. für "Ethernet")
netsh interface ip set dns "Ethernet" dhcp
netsh interface ipv6 set dns "Ethernet" dhcp

REM Oder für WLAN:
netsh interface ip set dns "Wi-Fi" dhcp
netsh interface ipv6 set dns "Wi-Fi" dhcp
```

## Verifizierung

### DNS-Server prüfen

**PowerShell**:
```powershell
Get-DnsClientServerAddress | Format-Table InterfaceAlias, ServerAddresses
```

**CMD**:
```cmd
ipconfig /all | findstr "DNS"
```

**Erwartetes Ergebnis**:
- DNS-Server sollte `192.168.178.10` (Pi-hole) oder `192.168.178.1` (Fritzbox) sein
- NICHT `8.8.8.8`, `1.1.1.1` oder andere manuelle DNS-Server

### DNS-Test

```cmd
nslookup google.de
```

**Erwartetes Ergebnis**: IP-Adresse wird zurückgegeben

## WSL DNS-Konfiguration

WSL verwendet automatisch die DNS-Einstellungen des Windows-Hosts. Wenn Windows DNS automatisch von der Fritzbox bezieht, sollte auch WSL funktionieren.

**WSL DNS prüfen**:
```bash
cat /etc/resolv.conf
```

**Erwartetes Ergebnis**: `nameserver 10.255.255.254` (Windows-Host-IP) oder Fritzbox-DNS

## Troubleshooting

### DNS funktioniert immer noch nicht

1. **Netzwerkverbindung erneuern**:
   ```cmd
   ipconfig /release
   ipconfig /renew
   ```

2. **DNS-Cache leeren**:
   ```cmd
   ipconfig /flushdns
   ```

3. **Fritzbox DHCP prüfen**:
   - Öffne http://192.168.178.1
   - Heimnetz → Netzwerk → Netzwerkeinstellungen
   - Prüfe: "Lokaler DNS-Server" sollte `192.168.178.10` (Pi-hole) sein

4. **Firewall prüfen**:
   - Windows-Firewall sollte DNS-Traffic (Port 53) erlauben

### Manuelle DNS-Einstellungen bleiben bestehen

- Prüfe ob Gruppenrichtlinien (GPO) DNS-Einstellungen erzwingen
- Prüfe ob VPN-Software DNS überschreibt
- Prüfe ob Antivirus-Software DNS blockiert

## Fritzbox DNS-Konfiguration

Die Fritzbox sollte folgende DNS-Konfiguration haben:

- **DHCP-Server**: Aktiviert
- **Lokaler DNS-Server**: `192.168.178.10` (Pi-hole)
- **DNS-Rebind-Schutz**: Aktiviert (empfohlen)

**Fritzbox prüfen**:
1. Öffne http://192.168.178.1
2. Internet → Zugangsdaten → DNS-Server
3. Prüfe: "Lokaler DNS-Server" = `192.168.178.10`

## Nach der Änderung

Nachdem DNS auf automatisch gesetzt wurde:
- Windows bezieht DNS automatisch von der Fritzbox
- Alle Geräte im Netzwerk verwenden den gleichen DNS-Server (Pi-hole)
- Lokale Domains (`*.k8sops.online`) funktionieren automatisch
- Keine manuelle DNS-Konfiguration mehr nötig

