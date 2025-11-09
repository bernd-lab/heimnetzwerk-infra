# FritzBox DNS-Flow Überprüfung - Zusammenfassung

**Datum**: 2025-11-07  
**Status**: ⚠️ **Pi-hole Problem identifiziert, FritzBox-Überprüfung benötigt Passwort**

## Zusammenfassung

### ✅ Was funktioniert:

1. **CoreDNS Konfiguration**: ✅ Korrekt konfiguriert
   - Forwardet an `192.168.178.10` (Pi-hole)
   - Fallback zu `8.8.8.8` (Google DNS)

2. **Service-Konfiguration**: ✅ Pi-hole Service korrekt
   - LoadBalancer IP: `192.168.178.10`
   - Ports: 53 (TCP/UDP), 80 (HTTP)

3. **Dokumentation**: ✅ Vollständig vorhanden
   - Erwartete Konfiguration dokumentiert
   - Menü-Pfade bekannt

### ⚠️ Probleme identifiziert:

1. **Pi-hole Pod nicht laufend**: ❌ `Pending` (Insufficient CPU)
   - **CPU-Request**: 100m (sehr niedrig)
   - **Problem**: Node ist voll ausgelastet
   - **Auswirkung**: DNS-Flow funktioniert nicht (Fallback zu 8.8.8.8)

2. **FritzBox-Überprüfung blockiert**: ⚠️ Passwort benötigt
   - **Grund**: Passwort ist verschlüsselt (`FRITZBOX_ADMIN_PASSWORD.age`)
   - **Benötigt**: Passphrase zur Entschlüsselung

3. **DNS nicht erreichbar**: ❌ Pi-hole antwortet nicht
   - **Grund**: Pod läuft nicht
   - **Test**: `dig @192.168.178.10 google.de` → Timeout

## CPU-Auslastung Analyse

### Top CPU-Requests:
- GitLab: 500m
- Jenkins: 400m
- kube-apiserver: 250m
- kube-controller-manager: 200m
- Pi-hole: 100m (kann nicht scheduled werden)

### Problem:
- Node hat 4 CPU cores (4000m)
- Gesamt-Requests: ~1850m (ohne Pi-hole)
- Pi-hole benötigt nur 100m, aber Node ist voll

## Zu überprüfende FritzBox-Einstellungen

### 1. DNS-Server (Internet → Zugangsdaten → DNS-Server)
- **Sollte sein**: Lokaler DNS-Server = `192.168.178.10`
- **Zu prüfen**: Aktuelle Einstellung

### 2. DHCP DNS-Server (Heimnetz → Netzwerk → IPv4-Adressen)
- **Sollte sein**: DNS-Server für Clients = `192.168.178.10`
- **Zu prüfen**: Ob Clients Pi-hole als DNS erhalten

### 3. DHCP-Bereich
- **Problem**: `192.168.178.54` liegt im DHCP-Bereich (20-200)
- **Empfehlung**: Bereich anpassen oder statische Reservierung

### 4. DNS-Rebind-Schutz (Erweiterte Netzwerkeinstellungen)
- **Sollte sein**: Aktiviert
- **Zu prüfen**: Aktueller Status

## Nächste Schritte

### Sofort (kritisch):

1. **Pi-hole zum Laufen bringen**:
   ```bash
   # Option 1: Andere Pods reduzieren (z.B. Jenkins)
   # Option 2: Pi-hole CPU-Request noch weiter reduzieren
   # Option 3: Node-Ressourcen prüfen
   ```

2. **FritzBox-Passwort entschlüsseln** (für Browser-Automation):
   ```bash
   FRITZBOX_PASSWORD=$(scripts/decrypt-secret.sh FRITZBOX_ADMIN_PASSWORD password)
   ```

3. **FritzBox DNS-Einstellungen überprüfen** (per Browser):
   - Internet → Zugangsdaten → DNS-Server
   - Heimnetz → Netzwerk → IPv4-Adressen

### Später (wichtig):

1. **DHCP-Bereich optimieren** (Konflikt mit 192.168.178.54 vermeiden)
2. **DNS-Rebind-Schutz aktivieren** (Sicherheit)
3. **Statische IP-Reservierungen** für LoadBalancer IPs

## Browser-Automation Status

### ✅ Vorbereitet:
- FritzBox-URL: `http://192.168.178.1`
- Passwort-Feld identifiziert: `uiPass` (id: `uiPassInput`)
- Menü-Pfade dokumentiert

### ⚠️ Blockiert:
- Passwort benötigt (verschlüsselt)
- Pi-hole läuft nicht (DNS-Flow kann nicht getestet werden)

## Empfehlung

**Für vollständige Überprüfung**:
1. Pi-hole Pod zum Laufen bringen (CPU-Problem lösen)
2. FritzBox-Passwort entschlüsseln (vom Benutzer)
3. Browser-Automation durchführen (DNS-Einstellungen prüfen)
4. DNS-Flow testen (von Client und Kubernetes Pod)

**Alternative (ohne Passwort)**:
- Manuelle Überprüfung der dokumentierten Einstellungen
- Prüfung der DHCP-Konfiguration über andere Methoden

