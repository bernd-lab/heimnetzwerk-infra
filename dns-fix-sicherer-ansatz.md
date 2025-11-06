# DNS-Fix: SICHERER Ansatz (Pi-hole läuft nicht!)

**⚠️ WICHTIG**: Pi-hole (192.168.178.10) ist aktuell NICHT erreichbar (Port 53 timeout)

## Problem-Analyse

### Aktuelle Situation
- ✅ **Pi-hole IP pingbar**: 192.168.178.10 antwortet auf Ping
- ❌ **Pi-hole DNS nicht erreichbar**: Port 53 timeout
- ✅ **Fritzbox DNS funktioniert**: 192.168.178.1 kann DNS auflösen
- ✅ **Manuelle DNS funktioniert**: 8.8.8.8 (Google) funktioniert aktuell

### Risiko bei sofortiger Umstellung
Wenn wir jetzt manuelle DNS entfernen und auf automatisch (DHCP) umstellen:
- ❌ Geräte würden versuchen, Pi-hole (192.168.178.10) zu verwenden
- ❌ DNS würde komplett ausfallen
- ❌ KI-Kommunikation würde unterbrochen werden

## SICHERER Ansatz: Zwei-Phasen-Plan

### Phase 1: Fritzbox als Fallback-DNS konfigurieren (SICHER)

**Option A: Fritzbox DNS direkt verwenden (Empfohlen für sofortige Lösung)**

Die Fritzbox kann auch direkt als DNS-Server fungieren. Wir konfigurieren die Geräte so, dass sie:
1. Primär: Fritzbox (192.168.178.1) als DNS verwenden
2. Sekundär: Cloudflare (1.1.1.1) als Fallback

**Vorteil**: 
- ✅ Funktioniert sofort
- ✅ Keine Unterbrechung der KI-Kommunikation
- ✅ Automatisch über DHCP (nach Fritzbox-Konfiguration)

**Nachteil**:
- ⚠️ Pi-hole-Features (Ad-Blocking, lokale DNS-Records) gehen verloren
- ⚠️ Lokale Domains (`*.k8sops.online`) funktionieren nicht

**Option B: Pi-hole erst reparieren (Längerfristig)**

1. Pi-hole Service in Kubernetes reparieren/deployen
2. Port 53 Erreichbarkeit testen
3. Dann DNS auf automatisch umstellen

**Vorteil**:
- ✅ Pi-hole-Features verfügbar
- ✅ Lokale Domains funktionieren

**Nachteil**:
- ⚠️ Dauert länger (Kubernetes-Cluster muss erreichbar sein)
- ⚠️ KI-Kommunikation könnte während Reparatur unterbrochen werden

### Phase 2: Automatische DNS-Umstellung (Nach Phase 1)

Nachdem Phase 1 erfolgreich ist:
1. Manuelle DNS-Einstellungen entfernen
2. Automatisch über DHCP beziehen
3. Verifizieren dass DNS funktioniert

## Empfohlene Lösung: Option A (Fritzbox DNS)

### Schritt 1: Fritzbox DNS-Konfiguration prüfen/anpassen

**Fritzbox sollte konfiguriert sein**:
- Heimnetz → Netzwerk → Netzwerkeinstellungen
- "Lokaler DNS-Server": Entweder `192.168.178.1` (Fritzbox selbst) oder `1.1.1.1` (Cloudflare)

**Falls Pi-hole nicht läuft**, sollte Fritzbox entweder:
- **Option 1**: Fritzbox selbst als DNS verwenden (192.168.178.1)
- **Option 2**: Cloudflare direkt (1.1.1.1) als DNS verteilen

### Schritt 2: Windows DNS-Fix (mit Fallback)

**PowerShell (Administrator)**:
```powershell
# DNS auf automatisch setzen (bezieht von Fritzbox)
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ResetServerAddresses

# Falls Fritzbox Pi-hole verteilt (was nicht funktioniert), manuell Fallback setzen
# Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "192.168.178.1","1.1.1.1"
```

**WICHTIG**: Erst testen ob Fritzbox DNS funktioniert, dann umstellen!

### Schritt 3: Fedora-Laptop DNS-Fix (mit Fallback)

```bash
# Erst prüfen: Was würde DHCP geben?
# Wenn Fritzbox Pi-hole (192.168.178.10) verteilt → NICHT umstellen!
# Wenn Fritzbox Cloudflare (1.1.1.1) oder sich selbst (192.168.178.1) verteilt → OK

# Manuelle DNS entfernen (nur wenn Fritzbox DNS funktioniert!)
sudo nmcli connection modify "FRITZ!Box 7590 YU5" ipv4.dns ""
sudo nmcli connection down "FRITZ!Box 7590 YU5"
sudo nmcli connection up "FRITZ!Box 7590 YU5"
```

## SICHERER Test-Plan

### Vor DNS-Umstellung testen:

1. **Fritzbox DNS testen**:
   ```bash
   dig @192.168.178.1 google.de +short
   ```
   ✅ Muss funktionieren!

2. **Was verteilt Fritzbox über DHCP?**
   - Fritzbox Web-Interface öffnen
   - Heimnetz → Netzwerk → Netzwerkeinstellungen
   - "Lokaler DNS-Server" prüfen
   - Falls `192.168.178.10` (Pi-hole) → **NICHT umstellen!**
   - Falls `192.168.178.1` (Fritzbox) oder `1.1.1.1` (Cloudflare) → OK

3. **Test-Umstellung auf einem Gerät**:
   - Erst auf einem Gerät testen (z.B. Laptop)
   - DNS-Tests durchführen
   - KI-Kommunikation testen
   - Erst dann auf anderen Geräten umstellen

### Rollback-Plan

Falls DNS nach Umstellung nicht funktioniert:

**Windows**:
```powershell
# Zurück zu manuellem DNS (8.8.8.8)
$adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
Set-DnsClientServerAddress -InterfaceAlias $adapter.Name -ServerAddresses "8.8.8.8","1.1.1.1"
```

**Linux**:
```bash
# Zurück zu manuellem DNS (8.8.8.8)
sudo nmcli connection modify "FRITZ!Box 7590 YU5" ipv4.dns "8.8.8.8 1.1.1.1"
sudo nmcli connection down "FRITZ!Box 7590 YU5"
sudo nmcli connection up "FRITZ!Box 7590 YU5"
```

## Empfehlung: WARTEN bis Pi-hole repariert ist

**Sicherste Option**: 
1. Pi-hole Service in Kubernetes reparieren/deployen
2. Port 53 Erreichbarkeit verifizieren
3. Dann DNS auf automatisch umstellen

**Warum?**
- ✅ Keine Unterbrechung der KI-Kommunikation
- ✅ Pi-hole-Features verfügbar
- ✅ Lokale Domains funktionieren
- ✅ Konsistente Konfiguration

## Alternative: Fritzbox DNS temporär ändern

Falls Pi-hole nicht schnell repariert werden kann:

1. **Fritzbox DNS auf Cloudflare ändern**:
   - Fritzbox Web-Interface
   - Internet → Zugangsdaten → DNS-Server
   - "Lokaler DNS-Server": `1.1.1.1` (Cloudflare)
   - Oder: Fritzbox selbst als DNS verwenden

2. **Dann DNS auf automatisch umstellen** (wie oben beschrieben)

**Nachteil**: Pi-hole-Features gehen verloren, lokale Domains funktionieren nicht

## Zusammenfassung

**⚠️ AKTUELLER STATUS**: 
- Pi-hole DNS nicht erreichbar → **NICHT auf automatisch umstellen!**
- Manuelle DNS (8.8.8.8) funktioniert → **Beibehalten bis Pi-hole repariert**

**EMPFOHLENE VORGEWHENSWEISE**:
1. ✅ Pi-hole Service reparieren/deployen
2. ✅ Port 53 Erreichbarkeit testen
3. ✅ Dann DNS auf automatisch umstellen

**ALTERNATIVE (wenn Pi-hole nicht repariert werden kann)**:
1. Fritzbox DNS auf Cloudflare ändern
2. Dann DNS auf automatisch umstellen
3. Pi-hole später reparieren

