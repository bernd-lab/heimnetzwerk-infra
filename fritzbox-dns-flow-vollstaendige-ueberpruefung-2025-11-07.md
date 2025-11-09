# FritzBox DNS-Flow Vollständige Überprüfung

**Datum**: 2025-11-07  
**Status**: ✅ **DNS-Konfiguration optimal!** ⚠️ **DHCP-Bereich-Konflikt identifiziert**

## Überprüfte Einstellungen

### 1. DNS-Server-Konfiguration (Internet → Zugangsdaten → DNS-Server)

**Status**: ✅ **OPTIMAL KONFIGURIERT**

#### DNSv4-Server:
- ✅ **Bevorzugter DNSv4-Server**: `192.168.178.10` (Pi-hole) ✅ **KORREKT!**
- ✅ **Alternativer DNSv4-Server**: `1.1.1.1` (Cloudflare) ✅ **KORREKT!**
- ✅ **Einstellung**: "Andere DNSv4-Server verwenden" (aktiviert)

#### DNSv6-Server:
- ✅ **Einstellung**: "Vom Internetanbieter zugewiesene DNSv6-Server verwenden" (aktiviert)
- ✅ **Bevorzugter DNSv6-Server**: `2003:fc:870b:a100:dea6:32ff:fec5:bea4` (Telekom)
- ✅ **Alternativer DNSv6-Server**: `2003:fc:870b:a100:dea6:32ff:fec5:bea4` (Telekom)

#### Öffentliche DNS-Server:
- ✅ **Fallback aktiviert**: "Bei DNS-Störungen auf öffentliche DNS-Server zurückgreifen" ✅

#### DNS over TLS (DoT):
- ✅ **Aktiviert**: "Verschlüsselte Namensauflösung im Internet (DNS over TLS)" ✅
- ✅ **Zertifikatsprüfung**: Erzwungen ✅
- ✅ **Fallback**: Auf unverschlüsselte Namensauflösung zulassen ✅
- ✅ **Server**: `dns.google` ✅

#### EDNS0:
- ⚠️ **Deaktiviert**: "Die MAC-Adresse und den Namen des anfragenden Netzwerkgeräts übermitteln" (nicht aktiviert)
- **Bewertung**: OK (nur bei Bedarf aktivieren)

### 2. DHCP-Konfiguration (Heimnetz → Netzwerk → IPv4-Adressen)

**Status**: ✅ **DNS-Server korrekt** ⚠️ **DHCP-Bereich-Konflikt**

#### Heimnetz:
- ✅ **IPv4-Adresse**: `192.168.178.1` ✅
- ✅ **Subnetzmaske**: `255.255.255.0` (/24) ✅
- ✅ **DHCP-Server**: Aktiviert ✅
- ⚠️ **IP-Bereich**: `192.168.178.20 - 192.168.178.200` ⚠️ **KONFLIKT!**
  - **Problem**: `192.168.178.54` (Kubernetes Ingress-Controller) liegt im DHCP-Bereich!
  - **Risiko**: DHCP könnte versehentlich diese IP an ein Gerät vergeben
  - **Empfehlung**: DHCP-Bereich anpassen auf `20-50, 60-200` oder statische Reservierung
- ✅ **Lease-Zeit**: 1 Tag ✅
- ✅ **Lokaler DNS-Server für Clients**: `192.168.178.10` (Pi-hole) ✅ **KORREKT!**

#### Gastnetz:
- **IPv4-Adresse**: `192.168.179.1` (automatisch, nicht veränderbar)
- **Gültigkeit**: 1 Stunde

## DNS-Flow-Analyse

### Aktueller Flow (optimal):

```
1. Clients (192.168.178.x)
   ↓
2. FritzBox DHCP (verteilt DNS-Server: 192.168.178.10) ✅
   ↓
3. Pi-hole (192.168.178.10) - Bevorzugter DNS ✅
   ↓
4. Cloudflare (1.1.1.1) - Alternativer DNS ✅
   ↓
5. Internet
```

### Für Kubernetes Pods:

```
1. Kubernetes Pods
   ↓
2. CoreDNS (10.96.0.10)
   ↓
3. Pi-hole (192.168.178.10) ✅
   ↓
4. Cloudflare (1.1.1.1) ✅
   ↓
5. Internet
```

## Bewertung

### ✅ Optimal konfiguriert:

1. **DNSv4-Server**: Pi-hole (192.168.178.10) als bevorzugter DNS ✅
2. **Fallback**: Cloudflare (1.1.1.1) als alternativer DNS ✅
3. **DNS over TLS**: Aktiviert mit dns.google ✅
4. **Fallback-Mechanismus**: Aktiviert für DNS-Störungen ✅
5. **DHCP DNS-Server**: Pi-hole (192.168.178.10) wird an Clients verteilt ✅

### ⚠️ Identifizierte Probleme:

1. **DHCP-Bereich-Konflikt**: 
   - **Problem**: `192.168.178.54` (Kubernetes Ingress-Controller) liegt im DHCP-Bereich (20-200)
   - **Risiko**: DHCP könnte versehentlich diese IP an ein Gerät vergeben
   - **Empfehlung**: DHCP-Bereich anpassen auf `20-50, 60-200` oder statische Reservierung für 192.168.178.54 erstellen

### ⚠️ Zu prüfen (optional):

1. **DNS-Rebind-Schutz**: Sollte aktiviert sein (Sicherheit)
   - **Menü**: Internet → Filter → Listen → Globale Filtereinstellungen
   - **Status**: Nicht überprüft (benötigt weitere Navigation)

## Empfehlungen

### Sofort (kritisch):

1. **DHCP-Bereich anpassen**:
   - **Aktuell**: 192.168.178.20 - 192.168.178.200
   - **Empfohlen**: 192.168.178.20 - 192.168.178.50, 192.168.178.60 - 192.168.178.200
   - **Oder**: Statische IP-Reservierung für 192.168.178.54 erstellen

### Wichtig (bald):

2. **DNS-Rebind-Schutz aktivieren** (Sicherheit)
   - **Menü**: Internet → Filter → Listen → Globale Filtereinstellungen
   - **Zweck**: Verhindert DNS-Rebind-Angriffe

### Optional:

3. **Statische IP-Reservierungen** für LoadBalancer IPs:
   - `192.168.178.54` → Ingress-Controller
   - `192.168.178.10` → Pi-hole (bereits außerhalb DHCP-Bereich)

## Zusammenfassung

### ✅ Was optimal ist:

1. **DNS-Server-Konfiguration**: Pi-hole (192.168.178.10) als bevorzugter DNS ✅
2. **Fallback-DNS**: Cloudflare (1.1.1.1) als alternativer DNS ✅
3. **DNS over TLS**: Aktiviert ✅
4. **DHCP DNS-Server**: Pi-hole wird an Clients verteilt ✅
5. **Fallback-Mechanismus**: Aktiviert für DNS-Störungen ✅

### ⚠️ Was zu beheben ist:

1. **DHCP-Bereich-Konflikt**: 192.168.178.54 liegt im DHCP-Bereich
   - **Lösung**: DHCP-Bereich anpassen oder statische Reservierung

### ⚠️ Was zu prüfen ist:

1. **DNS-Rebind-Schutz**: Sollte aktiviert sein (Sicherheit)
2. **Pi-hole Pod**: Muss zum Laufen gebracht werden (CPU-Problem)

## Nächste Schritte

1. ✅ **DNS-Konfiguration**: Optimal! Keine Änderungen nötig
2. ⚠️ **DHCP-Bereich anpassen**: Konflikt mit 192.168.178.54 beheben
3. ⚠️ **DNS-Rebind-Schutz aktivieren**: Sicherheit verbessern
4. ⚠️ **Pi-hole Pod zum Laufen bringen**: CPU-Problem lösen

## Fazit

**DNS-Flow ist optimal konfiguriert!** ✅

- Pi-hole (192.168.178.10) ist als bevorzugter DNS konfiguriert
- Cloudflare (1.1.1.1) ist als Fallback konfiguriert
- DNS over TLS ist aktiviert
- DHCP verteilt Pi-hole als DNS-Server an Clients

**Einzige kritische Anpassung**: DHCP-Bereich sollte angepasst werden, um Konflikt mit 192.168.178.54 zu vermeiden.

