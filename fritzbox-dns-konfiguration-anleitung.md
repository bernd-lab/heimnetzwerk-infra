# FritzBox DNS-Konfiguration für Pi-hole

**Datum**: 2025-11-07  
**Ziel**: Pi-hole (`192.168.178.54`) als DNS-Server in der FritzBox konfigurieren

## Voraussetzungen

- Zugriff auf die FritzBox-Weboberfläche (http://192.168.178.1)
- FRITZ!Box-Kennwort oder Benutzername + Passwort
- Pi-hole läuft auf `192.168.178.54:53` ✅ (bereits konfiguriert)

## Methode 1: Über Internet > Zugangsdaten > DNS-Server (Empfohlen)

### Schritte:

1. **Anmeldung**
   - Öffnen Sie http://192.168.178.1 im Browser
   - Melden Sie sich mit Ihrem FRITZ!Box-Kennwort an
   - Falls nötig: Klicken Sie auf "Ansicht: Standard" und wählen Sie "Erweitert"

2. **DNS-Server-Einstellungen**
   - Navigieren Sie zu: **Internet** → **Zugangsdaten**
   - Wählen Sie den Reiter **"DNS-Server"**
   - Aktivieren Sie: **"Andere DNSv4-Server verwenden"**
   - **Bevorzugter DNSv4-Server**: `192.168.178.54`
   - **Alternativer DNSv4-Server**: Leer lassen oder `1.1.1.1` (Cloudflare) als Fallback

3. **Speichern**
   - Klicken Sie auf **"Übernehmen"**
   - Warten Sie, bis die Einstellungen übernommen wurden

## Methode 2: Über Heimnetz > Netzwerk > Netzwerkeinstellungen

### Schritte:

1. **Anmeldung**
   - Öffnen Sie http://192.168.178.1 im Browser
   - Melden Sie sich mit Ihrem FRITZ!Box-Kennwort an

2. **Netzwerkeinstellungen**
   - Navigieren Sie zu: **Heimnetz** → **Netzwerk**
   - Wählen Sie die Registerkarte **"Netzwerkeinstellungen"**
   - Scrollen Sie zum Abschnitt **"IP-Adressen"**
   - Klicken Sie auf **"IPv4-Adressen"**

3. **Lokaler DNS-Server**
   - Tragen Sie unter **"Lokaler DNS-Server"** ein: `192.168.178.54`
   - Klicken Sie auf **"OK"**

4. **Speichern**
   - Klicken Sie auf **"Übernehmen"**

## Nach der Konfiguration

### Überprüfung:

1. **DNS-Test von einem Client**
   ```bash
   dig @192.168.178.54 google.de +short
   ```

2. **Prüfen Sie die Pi-hole-Logs**
   - Die Logs sollten DNS-Anfragen von Geräten im Netzwerk zeigen
   - Zugriff auf Pi-hole-Weboberfläche: http://192.168.178.54/admin/

3. **DHCP-Clients**
   - Geräte, die per DHCP eine IP-Adresse erhalten, bekommen automatisch `192.168.178.54` als DNS-Server
   - Bestehende Verbindungen müssen möglicherweise neu verbunden werden, um die neuen DNS-Einstellungen zu erhalten

## Wichtige Hinweise

- ⚠️ **Pi-hole muss verfügbar sein**: Wenn Pi-hole nicht läuft, funktioniert DNS nicht mehr
- ✅ **Fallback-DNS**: Optional können Sie einen zweiten DNS-Server (z.B. `1.1.1.1`) als Alternative konfigurieren
- 🔄 **DHCP-Neustart**: Nach der Änderung sollten DHCP-Clients die neuen DNS-Einstellungen automatisch erhalten
- 📱 **Manuelle Konfiguration**: Geräte mit manueller DNS-Konfiguration müssen manuell aktualisiert werden

## Troubleshooting

### DNS funktioniert nicht:
1. Prüfen Sie, ob Pi-hole läuft: `kubectl get pods -n pihole`
2. Prüfen Sie die Pi-hole-Logs: `kubectl logs -n pihole <pod-name>`
3. Testen Sie DNS direkt: `dig @192.168.178.54 google.de`

### Clients erhalten alte DNS-Einstellungen:
- Trennen Sie die Netzwerkverbindung und verbinden Sie sich erneut
- Oder starten Sie den DHCP-Client neu

## Status

- ✅ Pi-hole läuft auf `192.168.178.54:53`
- ✅ Pi-hole akzeptiert externe DNS-Anfragen
- ⏳ FritzBox-DNS-Konfiguration: **Benötigt Zugangsdaten**

