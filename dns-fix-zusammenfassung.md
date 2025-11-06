# DNS-Fix Zusammenfassung: Automatische DNS-Konfiguration

**Erstellt**: 2025-11-06  
**Problem**: Windows-PC und Fedora-Laptop benötigen manuelle DNS-Konfiguration  
**⚠️ WICHTIG**: Pi-hole (192.168.178.10) läuft aktuell NICHT (Port 53 nicht erreichbar)  
**Lösung**: Automatische DNS-Konfiguration über Fritzbox DHCP aktivieren (NACH Pi-hole-Reparatur)

---

## Problem-Analyse

### Symptome
- **Windows-PC**: Verwendet manuelle DNS-Einstellungen (z.B. 8.8.8.8)
- **Fedora-Laptop**: Verwendet manuelle DNS-Einstellungen (8.8.8.8)
- **WSL**: DNS funktioniert nicht korrekt (weil Windows Host manuelle DNS hat)
- **KI-Kommunikation**: Funktioniert nicht wegen fehlendem DNS

### Root Cause
Beide Systeme haben manuelle DNS-Konfigurationen statt automatisch DNS von der Fritzbox zu beziehen.

---

## Lösung

### Fritzbox DNS-Konfiguration (bereits korrekt)

Die Fritzbox ist bereits korrekt konfiguriert:
- **DHCP-Server**: ✅ Aktiviert
- **Lokaler DNS-Server**: ✅ 192.168.178.10 (Pi-hole)
- **DNS-Verteilung**: ✅ Automatisch über DHCP

**Fritzbox prüfen**:
- Menü: Heimnetz → Netzwerk → Netzwerkeinstellungen
- "Lokaler DNS-Server" sollte `192.168.178.10` sein

### Windows DNS-Fix

**Option 1: GUI (Empfohlen)**
1. Windows-Taste + R → `ncpa.cpl`
2. Rechtsklick auf aktiven Adapter → Eigenschaften
3. IPv4 → Eigenschaften → **"DNS-Serveradressen automatisch beziehen"**
4. OK → Verbindung wird automatisch erneuert

**Option 2: PowerShell (Administrator)**
```powershell
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses
```

**Option 3: CMD (Administrator)**
```cmd
netsh interface ip set dns "Ethernet" dhcp
netsh interface ipv6 set dns "Ethernet" dhcp
```

**Verifizierung**:
```cmd
ipconfig /all | findstr "DNS"
```
Sollte zeigen: `192.168.178.10` (Pi-hole) oder `192.168.178.1` (Fritzbox)

**Detaillierte Anleitung**: Siehe `windows-dns-fix-anleitung.md`

### Fedora-Laptop DNS-Fix

**Option 1: Script (Empfohlen)**
```bash
# Script auf Laptop ausführen
./fix-dns-automatic.sh
```

**Option 2: Manuell (NetworkManager)**
```bash
# Aktive Verbindung finden
nmcli connection show --active

# Manuelle DNS entfernen
sudo nmcli connection modify "FRITZ!Box 7590 YU5" ipv4.dns ""
sudo nmcli connection down "FRITZ!Box 7590 YU5"
sudo nmcli connection up "FRITZ!Box 7590 YU5"
```

**Verifizierung**:
```bash
resolvectl status
dig google.de +short
```

**Detaillierte Anleitung**: Siehe `laptop-dns-fix-fedora.md`

### WSL DNS-Fix

WSL verwendet automatisch Windows Host DNS. Nach Windows DNS-Fix sollte WSL automatisch funktionieren.

**WSL DNS prüfen**:
```bash
cat /etc/resolv.conf
# Sollte zeigen: nameserver 10.255.255.254 (Windows Host)
```

**Falls WSL DNS nicht funktioniert**:
```bash
# WSL neu starten (in Windows PowerShell)
wsl --shutdown
# Dann WSL wieder öffnen
```

---

## Verifizierung

### DNS-Server prüfen

**Windows**:
```cmd
ipconfig /all | findstr "DNS"
```

**Linux**:
```bash
resolvectl status
# oder
cat /etc/resolv.conf
```

**Erwartetes Ergebnis**: DNS-Server sollte `192.168.178.10` (Pi-hole) oder `192.168.178.1` (Fritzbox) sein

### DNS-Auflösung testen

**Windows**:
```cmd
nslookup google.de
ping google.de
```

**Linux**:
```bash
dig google.de +short
ping google.de
```

**Erwartetes Ergebnis**: IP-Adresse wird zurückgegeben, Ping funktioniert

### KI-Kommunikation testen

Nach DNS-Fix sollte KI-Kommunikation wieder funktionieren:
- DNS-Auflösung funktioniert
- Internet-Verbindung funktioniert
- Lokale Domains (`*.k8sops.online`) funktionieren (wenn Pi-hole läuft)

---

## Troubleshooting

### DNS funktioniert nach Fix nicht

1. **DNS-Cache leeren**:
   - Windows: `ipconfig /flushdns`
   - Linux: `sudo systemd-resolve --flush-caches`

2. **Netzwerkverbindung erneuern**:
   - Windows: `ipconfig /release && ipconfig /renew`
   - Linux: Verbindung neu starten

3. **Fritzbox DHCP prüfen**:
   - Öffne http://192.168.178.1
   - Heimnetz → Netzwerk → Netzwerkeinstellungen
   - Prüfe: "Lokaler DNS-Server" = `192.168.178.10`

4. **Pi-hole erreichbar?**:
   ```bash
   ping 192.168.178.10
   dig @192.168.178.10 google.de
   ```

### Manuelle DNS-Einstellungen bleiben bestehen

- **Windows**: Prüfe ob Gruppenrichtlinien (GPO) DNS erzwingen
- **Linux**: Prüfe ob andere Tools DNS überschreiben (z.B. resolvconf)
- **VPN**: Prüfe ob VPN-Software DNS überschreibt

---

## Erstellte Dateien

1. **`fix-dns-automatic.sh`**: Automatisches DNS-Fix-Script für Linux
2. **`windows-dns-fix-anleitung.md`**: Detaillierte Windows DNS-Fix-Anleitung
3. **`.cursor/commands/network-expert.md`**: Netzwerk-Experte für Windows/Linux

---

## ⚠️ WICHTIG: Pi-hole läuft nicht!

**AKTUELLER STATUS**: 
- ❌ Pi-hole (192.168.178.10) Port 53 nicht erreichbar
- ✅ Manuelle DNS (8.8.8.8) funktioniert aktuell
- ⚠️ **NICHT auf automatisch umstellen**, solange Pi-hole nicht läuft!

**EMPFOHLENE VORGEWHENSWEISE**:
1. ⏳ **Pi-hole Service reparieren/deployen** (siehe `pihole-deployment-status.md`)
2. ✅ **Port 53 Erreichbarkeit testen**: `dig @192.168.178.10 google.de`
3. ✅ **Dann DNS auf automatisch umstellen** (siehe Anleitungen oben)

**ALTERNATIVE (wenn Pi-hole nicht repariert werden kann)**:
1. Fritzbox DNS auf Cloudflare ändern (Internet → Zugangsdaten → DNS-Server)
2. Dann DNS auf automatisch umstellen
3. Pi-hole später reparieren

**Siehe**: `dns-fix-sicherer-ansatz.md` für detaillierte Anleitung

## Nächste Schritte

1. ⏳ **Pi-hole reparieren**: Service in Kubernetes deployen
2. ✅ **Port 53 testen**: `dig @192.168.178.10 google.de`
3. ✅ **Windows DNS-Fix**: Manuelle DNS entfernen (siehe Anleitung)
4. ✅ **Fedora-Laptop DNS-Fix**: Script ausführen oder manuell konfigurieren
5. ✅ **Verifizierung**: DNS-Tests durchführen
6. ✅ **KI-Kommunikation testen**: Sollte jetzt funktionieren

---

## Wichtige Hinweise

- **Automatische DNS**: Alle Geräte sollten automatisch DNS von der Fritzbox beziehen
- **Konsistenz**: Alle Geräte verwenden den gleichen DNS-Server (Pi-hole: 192.168.178.10)
- **WSL**: Verwendet automatisch Windows Host DNS
- **Pi-hole**: Muss laufen für lokale Domains (`*.k8sops.online`)
- **Fritzbox**: Sollte 192.168.178.10 (Pi-hole) als DNS-Server über DHCP verteilen

---

**Status**: ✅ Lösungen erstellt, Scripts und Anleitungen bereitgestellt  
**Nächste Aktion**: Windows und Fedora-Laptop DNS-Fix durchführen

