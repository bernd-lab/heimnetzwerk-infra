# FritzBox DNS-Automatisierung Status

**Datum**: 2025-11-07  
**Ziel**: Pi-hole (`192.168.178.54`) als DNS-Server in der FritzBox konfigurieren

## Status

⚠️ **Benötigt Zugangsdaten**: Die automatische Konfiguration erfordert das FRITZ!Box-Admin-Passwort.

## Verfügbare Methoden

### Methode 1: Browser-Automatisierung (Empfohlen)

**Voraussetzung**: FRITZ!Box-Admin-Passwort

**Schritte**:
1. Login bei http://192.168.178.1
2. Navigation: **Internet** → **Zugangsdaten** → **DNS-Server** Tab
3. "Andere DNSv4-Server verwenden" aktivieren
4. Bevorzugter DNSv4-Server: `192.168.178.54`
5. Übernehmen

**Browser-Automatisierung-Code** (aus `.cursor/commands/fritzbox-expert.md`):
```javascript
// Login
await browser.type({ 
  element: "FRITZ!Box-Kennwort textbox", 
  ref: "textbox[aria-label*='FRITZ!Box-Kennwort']", 
  text: "<password>" 
});
await browser.click({ element: "Anmelden button", ref: "button:has-text('Anmelden')" });

// Navigation zu DNS-Server
await browser.click({ element: "Internet menuitem", ref: "menuitem:has-text('Internet')" });
await browser.click({ element: "Zugangsdaten menuitem", ref: "menuitem:has-text('Zugangsdaten')" });
await browser.click({ element: "DNS-Server link", ref: "a:has-text('DNS-Server')" });

// DNS-Server konfigurieren
// "Andere DNSv4-Server verwenden" aktivieren
// Bevorzugter DNSv4-Server: 192.168.178.54
// Übernehmen
```

### Methode 2: TR-064 API

**Voraussetzung**: TR-064 aktiviert (✅ bereits aktiviert laut Dokumentation)

**Service**: `WANIPConnection` oder `LANHostConfigManagement`

**Python-Beispiel** (mit `fritzconnection`):
```python
from fritzconnection import FritzConnection

fc = FritzConnection(address='192.168.178.1', password='<password>')
# DNS-Server setzen
fc.call_action('WANIPConnection', 'SetDNSServers', NewDNSServers='192.168.178.54')
```

### Methode 3: Manuelle Konfiguration

Siehe: `fritzbox-dns-konfiguration-anleitung.md`

## Aktuelle Situation

- ✅ Pi-hole läuft auf `192.168.178.54:53`
- ✅ Pi-hole akzeptiert externe DNS-Anfragen
- ⏳ FritzBox-DNS-Konfiguration: **Benötigt Zugangsdaten**

## Nächste Schritte

**Option A**: Passwort bereitstellen → Automatische Konfiguration
**Option B**: Manuelle Konfiguration gemäß Anleitung

