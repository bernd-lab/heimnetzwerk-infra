# Pi-hole Reparatur Zusammenfassung

**Datum**: 2025-11-06  
**Status**: ✅ Pi-hole funktioniert vom Server aus

## Durchgeführte Reparaturen

### ✅ Phase 1: Manuelle DNS-Konfigurationen entfernen

**Fedora-Laptop**:
- Manuelle DNS-Konfiguration (8.8.8.8) entfernt
- Automatische DNS von Fritzbox aktiviert
- **Hinweis**: Laptop ist aktuell nicht erreichbar (Netzwerk-Problem)

**Windows-PC/WSL**:
- WSL verwendet automatisch Windows Host DNS (10.255.255.254)
- Windows Host sollte automatisch DNS von Fritzbox beziehen

### ✅ Phase 2: Service-Konfiguration korrigiert

**Änderungen**:
- `k8s/pihole/service.yaml`: `loadBalancerIP` Feld entfernt
- Nur Annotation `metallb.universe.tf/loadBalancerIPs` verwendet
- Service neu erstellt

**Ergebnis**:
- ✅ MetalLB hat IP zugewiesen: `192.168.178.10`
- ✅ Keine "AllocationFailed" Events mehr
- ✅ Service Status: LoadBalancer mit IP 192.168.178.10

### ✅ Phase 3: MetalLB ARP-Announcements

**Status**:
- ✅ IP auf br0 Interface: `192.168.178.10/32`
- ✅ L2Advertisement aktiv für default-pool
- ✅ MetalLB Speaker läuft

### ✅ Phase 4: Verifizierung

**Vom Server (192.168.178.54)**:
- ✅ DNS funktioniert: `dig @192.168.178.10 google.de` → IP zurückgegeben
- ✅ Port 53 TCP erreichbar: `nc -zv 192.168.178.10 53` → succeeded
- ✅ Port 53 UDP funktioniert (DNS-Abfragen erfolgreich)

**Vom WSL-System**:
- ⚠️ DNS-Test: Timeout (WSL-Netzwerk-Isolation)
- ⚠️ Port 53: Timeout (WSL kann nicht direkt auf 192.168.178.0/24 zugreifen)

**Vom Laptop (192.168.178.63)**:
- ⚠️ Nicht erreichbar (Netzwerk-Problem, separate Ursache)

## Aktueller Status

### ✅ Was funktioniert

1. **Pi-hole Pod**: ✅ Running (pihole-787479f5f9-nnrgn)
2. **Pi-hole Service**: ✅ LoadBalancer mit IP 192.168.178.10
3. **MetalLB**: ✅ IP zugewiesen und auf br0 Interface
4. **DNS vom Server**: ✅ Funktioniert vollständig
5. **Service-Konfiguration**: ✅ Korrigiert (keine Konflikte mehr)

### ⚠️ Bekannte Probleme

1. **WSL-Netzwerk-Isolation**:
   - WSL (172.31.16.0/24) kann nicht direkt auf 192.168.178.0/24 zugreifen
   - Pi-hole ist vom Server aus erreichbar, aber nicht von WSL
   - **Lösung**: Windows Host DNS sollte Pi-hole verwenden (wenn Windows DNS korrekt konfiguriert ist)

2. **Laptop nicht erreichbar**:
   - Laptop (192.168.178.63) ist aktuell nicht erreichbar
   - Separate Netzwerk-Problem (nicht Pi-hole-bezogen)

## Nächste Schritte

### Für Windows-PC

1. **Windows DNS auf automatisch setzen** (falls noch nicht geschehen):
   - Netzwerkadapter → Eigenschaften → IPv4 → DNS automatisch beziehen
   - Windows Host sollte dann Pi-hole (192.168.178.10) von Fritzbox erhalten
   - WSL verwendet dann automatisch Windows Host DNS

2. **Verifizierung**:
   ```cmd
   ipconfig /all | findstr "DNS"
   nslookup google.de
   ```

### Für Fedora-Laptop

1. **Laptop-Netzwerk-Problem beheben** (separates Problem)
2. **DNS-Verifizierung** (sobald Laptop erreichbar):
   ```bash
   resolvectl status
   dig @192.168.178.10 google.de
   dig google.de  # Sollte automatisch Pi-hole verwenden
   ```

### Fritzbox DNS-Konfiguration

**Prüfen**:
- Fritzbox Web-Interface: http://192.168.178.1
- Heimnetz → Netzwerk → Netzwerkeinstellungen
- "Lokaler DNS-Server" sollte `192.168.178.10` (Pi-hole) sein

**Falls nicht korrekt**:
- DNS-Server auf `192.168.178.10` ändern
- Alle DHCP-Clients erhalten dann automatisch Pi-hole als DNS

## Zusammenfassung

**Pi-hole ist funktionsfähig**:
- ✅ Pod läuft
- ✅ Service konfiguriert
- ✅ DNS funktioniert vom Server aus
- ✅ MetalLB IP zugewiesen

**Verbleibende Aufgaben**:
- ⏳ Windows DNS auf automatisch umstellen (falls noch nicht geschehen)
- ⏳ Laptop-Netzwerk-Problem beheben (separates Problem)
- ⏳ Fritzbox DNS-Server auf Pi-hole (192.168.178.10) prüfen/setzen

**Nach diesen Schritten**:
- Alle Geräte sollten automatisch Pi-hole als DNS verwenden
- Keine manuellen DNS-Konfigurationen mehr nötig
- DNS funktioniert vollständig automatisch

