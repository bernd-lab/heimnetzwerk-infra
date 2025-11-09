# DNS-Problem WSL2 - Detaillierte Analyse

**Datum**: 2025-11-07  
**Status**: ⚠️ **Problem identifiziert - Netzwerk-Routing-Problem, nicht Pi-hole-Konfiguration**

## Problem

DNS-Abfragen von WSL2-Umgebung zu `192.168.178.54` schlagen fehl mit:
```
;; communications error to 192.168.178.54#53: timed out
;; communications error to 192.168.178.54#53: network unreachable
```

## Analyse

### 1. Pi-hole-Konfiguration ✅ Korrekt

**DNS-Server läuft korrekt**:
- Lauscht auf `0.0.0.0:53` (UDP und TCP) ✅
- `listeningMode = "ALL"` ✅
- `local-service=false` ✅
- `localise-queries=false` ✅
- `listen-address=0.0.0.0` ✅

**DNS funktioniert für andere Geräte**:
- `192.168.178.20` ✅ (Harmony Hub)
- `192.168.178.34` ✅ (Hue Bridge)
- `192.168.178.49` ✅ (Android-Gerät)
- `10.244.0.x` ✅ (Kubernetes Pods)

### 2. Netzwerk-Verbindung ✅ Funktioniert

**ICMP (Ping) funktioniert**:
```
PING 192.168.178.54 (192.168.178.54) 56(84) bytes of data.
64 bytes from 192.168.178.54: icmp_seq=1 ttl=63 time=0.580 ms
64 bytes from 192.168.178.54: icmp_seq=2 ttl=63 time=4.50 ms
--- 192.168.178.54 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss
```

**Routing funktioniert**:
- WSL2 IP: `172.31.16.162/20`
- Route zu Host: `192.168.178.54 via 172.31.16.1 dev eth0`

### 3. DNS-Port-Erreichbarkeit ❌ Funktioniert NICHT

**UDP Port 53**: Timeout
```
timeout 3 nc -zv -u 192.168.178.54 53
# Timeout - keine Verbindung
```

**TCP Port 53**: Timeout
```
timeout 3 nc -zv 192.168.178.54 53
# Timeout - keine Verbindung
```

**DNS-Abfragen erreichen Pi-hole NICHT**:
- Keine Log-Einträge von `172.31.x.x` im Pi-hole Log
- Pakete kommen nicht beim Host an

### 4. Root Cause

**Das Problem ist NICHT die Pi-hole-Konfiguration**, sondern:

1. **WSL2 NAT-Netzwerk**: WSL2 verwendet ein NAT-Netzwerk (`172.31.x.x`), das UDP-Pakete möglicherweise nicht korrekt weiterleitet
2. **Windows Firewall**: Windows Firewall könnte UDP-Port 53 blockieren
3. **WSL2 Port-Forwarding**: WSL2 leitet möglicherweise UDP-Port 53 nicht an den Host weiter

## Lösungsansätze

### Option 1: WSL2 Port-Forwarding konfigurieren

Windows PowerShell (als Administrator):
```powershell
# UDP Port 53 von WSL2 an Host weiterleiten
netsh interface portproxy add v4tov4 listenport=53 listenaddress=0.0.0.0 connectport=53 connectaddress=192.168.178.54 protocol=udp
netsh interface portproxy add v4tov4 listenport=53 listenaddress=0.0.0.0 connectport=53 connectaddress=192.168.178.54 protocol=tcp
```

**Problem**: Port 53 ist ein privilegierter Port und benötigt Administrator-Rechte.

### Option 2: Windows Firewall-Regel hinzufügen

Windows PowerShell (als Administrator):
```powershell
# Erlaube UDP Port 53 von WSL2
New-NetFirewallRule -DisplayName "WSL2 DNS to Pi-hole" -Direction Inbound -LocalPort 53 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "WSL2 DNS to Pi-hole" -Direction Inbound -LocalPort 53 -Protocol TCP -Action Allow
```

### Option 3: WSL2 DNS-Konfiguration ändern

In WSL2 `/etc/resolv.conf`:
```bash
# Temporär Pi-hole als DNS setzen
echo "nameserver 192.168.178.54" | sudo tee /etc/resolv.conf
```

**Problem**: WSL2 überschreibt `/etc/resolv.conf` automatisch.

### Option 4: WSL2 `/etc/wsl.conf` konfigurieren

Erstelle `/etc/wsl.conf`:
```ini
[network]
generateResolvConf = false
```

Dann manuell `/etc/resolv.conf` setzen:
```bash
echo "nameserver 192.168.178.54" | sudo tee /etc/resolv.conf
```

## Empfohlene Lösung

**Kombination aus Option 2 und 4**:
1. Windows Firewall-Regel hinzufügen (Option 2)
2. WSL2 DNS-Konfiguration manuell setzen (Option 4)

## Fazit

**Das Problem liegt NICHT an Pi-hole**, sondern an der WSL2-Netzwerk-Konfiguration. Pi-hole funktioniert korrekt für alle anderen Geräte im Netzwerk. Die DNS-Pakete von WSL2 erreichen den Host nicht, weil WSL2 UDP-Port 53 nicht korrekt weiterleitet oder Windows Firewall die Pakete blockiert.

