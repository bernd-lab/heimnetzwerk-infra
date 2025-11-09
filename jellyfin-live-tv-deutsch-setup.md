# Jellyfin Live-TV Setup - Deutsche Sender

**Datum**: 2025-11-07  
**Status**: 📺 **Anleitung für deutsches Live-TV**

## Übersicht

Jellyfin unterstützt Live-TV über verschiedene Quellen:
1. **IPTV (M3U-Playlist)** - Am einfachsten, keine Hardware nötig
2. **HDHomeRun** - Hardware-Tuner für DVB-T/T2/C/S
3. **Andere Hardware-Tuner** - DVB-T/T2/C/S Karten

## Option 1: IPTV mit M3U-Playlist (Empfohlen)

### Vorteile
- ✅ Keine Hardware nötig
- ✅ Einfache Einrichtung
- ✅ Viele deutsche Sender verfügbar
- ✅ Funktioniert überall mit Internet

### Nachteile
- ⚠️ Abhängig von IPTV-Anbieter
- ⚠️ Qualität variiert
- ⚠️ Rechtliche Aspekte beachten (nur legale Quellen nutzen!)
- ⚠️ Monatliche Kosten (außer kostenlose Optionen)

## 📺 US-TV: Daily Show, Last Week Tonight & Co.

### Spezifische Shows

**The Daily Show (Comedy Central, USA):**
- **Sender**: Comedy Central (USA)
- **Verfügbarkeit**: Über IPTV-Anbieter mit US-Sendern
- **Kostenlose Optionen**: YouTube (Clips), Comedy Central Website (geoblockiert)

**Last Week Tonight (HBO, USA):**
- **Sender**: HBO (USA)
- **Verfügbarkeit**: Über IPTV-Anbieter mit US-Sendern
- **Kostenlose Optionen**: ✅ **YouTube** (vollständige Episoden kostenlos!)
- **HBO Max**: Abo nötig (geoblockiert in Deutschland)

### US-TV-Anbieter

**Option 1: Waipu.tv (Empfohlen für US-Sender)**
- **Preis**: 7,49-14,99 €/Monat
- **Angebot**: 20.000+ internationale Sender, inkl. viele US-Kanäle
- **US-Sender**: Comedy Central, HBO, CNN, Fox, ABC, NBC, CBS, etc.
- **Legal**: ✅ Seriös, lizenziert
- **Geoblocking**: ⚠️ Möglicherweise geoblockiert, VPN könnte nötig sein

**Option 2: US-Streaming-Dienste (mit VPN)**
- **Sling TV**: ~$40/Monat (~37€/Monat)
- **YouTube TV**: ~$73/Monat (~67€/Monat)
- **Hulu + Live TV**: ~$77/Monat (~71€/Monat)
- **Geoblocking**: ⚠️ Meist nur in USA verfügbar, VPN nötig
- **M3U-Playlist**: ⚠️ Oft nicht direkt verfügbar, App-basiert

**Option 3: Pluto TV (Kostenlos, US-Kanäle)**
- **Preis**: 0€ (werbefinanziert)
- **Angebot**: Viele US-Kanäle, auch in Deutschland verfügbar
- **Legal**: ✅ Seriös, legal
- **M3U-Playlist**: Prüfe ob verfügbar

### ⚠️ WICHTIG: Geoblocking bei US-Sendern

**Problem:**
- Viele US-Sender sind geografisch beschränkt (nur USA)
- Außerhalb der USA nicht verfügbar
- VPN kann helfen, aber:
  - ⚠️ Verstößt oft gegen Nutzungsbedingungen
  - ⚠️ Rechtlich in Grauzone
  - ⚠️ Streams können blockiert werden

**Lösungen:**
1. **Waipu.tv**: Bietet US-Sender, die bereits für Deutschland lizenziert sind
2. **Pluto TV**: Kostenlos, oft auch in Deutschland verfügbar
3. **YouTube**: Viele Shows haben offizielle Kanäle (kostenlos, legal)
4. **VPN + US-Streaming-Dienst**: Technisch möglich, aber rechtlich fragwürdig

## 💰 Kosten und seriöse Anbieter

### Seriöse IPTV-Anbieter für Deutschland

#### 1. Waipu.tv (Empfohlen)
- **Preis**: 7,49 € - 14,99 €/Monat
  - Comfort-Paket: 7,49 €/Monat
  - Perfect Plus: 14,99 €/Monat (290+ Sender, viele HD)
- **Angebot**: Über 290 Sender, viele in HD-Qualität
- **Besonderheit**: ✅ Kostenloser Probemonat verfügbar
- **Legal**: ✅ Seriös, lizenziert
- **Jellyfin-Kompatibilität**: ⚠️ M3U-Playlist muss verfügbar sein (App-API prüfen)

#### 2. Zattoo
- **Preis**: 9,99 € - 13,99 €/Monat
  - Premium: 9,99 €/Monat
  - Ultimate: 13,99 €/Monat (223+ Sender, 4 Geräte gleichzeitig)
- **Angebot**: Über 223 Sender (öffentlich-rechtlich + privat)
- **Besonderheit**: ✅ Kostenloser Testmonat, Streaming auf 4 Geräten
- **Legal**: ✅ Seriös, lizenziert
- **Jellyfin-Kompatibilität**: ⚠️ M3U-Playlist muss verfügbar sein (App-API prüfen)

#### 3. MagentaTV (Deutsche Telekom)
- **Preis**: Ab 9,75 €/Monat
- **Angebot**: Viele deutsche Sender + Streaming-Dienste (Disney+, Netflix)
- **Besonderheit**: ✅ Telekom-Kunden oft günstiger
- **Legal**: ✅ Seriös, lizenziert
- **Jellyfin-Kompatibilität**: ⚠️ M3U-Playlist muss verfügbar sein

#### 4. Waipu.tv (Auch US-Sender!)
- **Preis**: 7,49 € - 14,99 €/Monat
- **Angebot**: 290+ deutsche Sender + **20.000+ internationale Sender** (inkl. US-Sender!)
- **US-Sender**: Comedy Central, HBO, und viele weitere US-Kanäle verfügbar
- **Besonderheit**: ✅ Sehr großes internationales Angebot
- **Legal**: ✅ Seriös, lizenziert
- **Jellyfin-Kompatibilität**: ⚠️ M3U-Playlist muss verfügbar sein

### ⚠️ WICHTIG: Rechtliche Warnung

**Vermeide diese Anbieter:**
- ❌ Angebote mit 1000+ Sendern für 5-10€/Monat (meist illegal)
- ❌ Anbieter ohne Impressum oder deutsche Adresse
- ❌ Angebote auf dubiosen Websites oder Telegram-Kanälen
- ❌ "Lifetime"-Angebote zu sehr niedrigen Preisen

**Warum?**
- Diese Anbieter haben meist keine Lizenzen
- Urheberrechtsverletzungen
- Risiko von Abmahnungen
- Streams können jederzeit wegbrechen

### 💸 Kostenübersicht

| Option | Kosten/Monat | Kosten/Jahr | Sender | Legal |
|--------|--------------|-------------|--------|-------|
| **Waipu.tv Comfort** | 7,49 € | ~90 € | 290+ | ✅ |
| **Waipu.tv Perfect Plus** | 14,99 € | ~180 € | 290+ (HD) | ✅ |
| **Zattoo Premium** | 9,99 € | ~120 € | 223+ | ✅ |
| **Zattoo Ultimate** | 13,99 € | ~168 € | 223+ (4 Geräte) | ✅ |
| **MagentaTV** | 9,75 €+ | ~117 €+ | Viele + Streaming | ✅ |
| **Kostenlose Optionen** | 0 € | 0 € | Öffentlich-rechtlich | ✅ |
| **Waipu.tv (mit US-Sendern)** | 7,49-14,99 € | ~90-180 € | 20.000+ (inkl. US) | ✅ |
| **Pluto TV (US, kostenlos)** | 0 € | 0 € | Viele US-Kanäle | ✅ |

### 🆓 Kostenlose Optionen

**Öffentlich-rechtliche Sender (kostenlos, legal):**
- **ARD (Das Erste)**: Kostenlose Streams verfügbar
- **ZDF**: Kostenlose Streams verfügbar
- **ARD-Mediathek/ZDF-Streams**: Oft als Live-Streams verfügbar
- **3sat, Arte, Phoenix**: Öffentlich-rechtlich, oft kostenlos

**US-TV kostenlos:**
- **Pluto TV**: Kostenloser, werbefinanzierter Streaming-Dienst
  - Viele US-Kanäle verfügbar
  - Oft auch in Deutschland verfügbar
  - M3U-Playlist: Prüfe ob verfügbar
- **YouTube**: Viele Shows haben offizielle YouTube-Kanäle
  - "Last Week Tonight": Vollständige Episoden auf YouTube
  - "Daily Show": Clips und Highlights auf YouTube
  - **Achtung**: Nicht als Live-TV, sondern als On-Demand

**Wie bekommt man kostenlose M3U-Playlists?**
- Einige Tools können öffentlich-rechtliche Streams in M3U-Format konvertieren
- Oft direkt über die Mediathek-APIs verfügbar
- **Achtung**: Diese ändern sich häufig, müssen regelmäßig aktualisiert werden

### 📺 EPG (Programmführer) Kosten

#### Schedules Direct (Empfohlen für beste Qualität)
- **Kosten**: ~$25/Jahr (~23€/Jahr)
- **Angebot**: Sehr gute EPG-Daten für deutsche Sender
- **Qualität**: ⭐⭐⭐⭐⭐ Professionell, zuverlässig
- **Website**: https://www.schedulesdirect.org

#### Kostenlose EPG-Optionen
- **XMLTV mit deutschen Sendern**: Kostenlos, Qualität variiert
- **Einige Tools**: Generieren EPG-Daten aus öffentlichen Quellen
- **Qualität**: ⭐⭐⭐ Variiert, manchmal unvollständig

### Einrichtung

#### 1. M3U-Playlist beschaffen

**Option A: Seriöser IPTV-Anbieter (Empfohlen)**
- **Waipu.tv, Zattoo, MagentaTV**: Prüfe, ob M3U-Playlist verfügbar ist
- Viele Anbieter bieten M3U-URLs für ihre Apps/APIs
- Format: `http://anbieter.com/playlist.m3u?username=xxx&password=yyy`
- **Kosten**: 7-15€/Monat (siehe Kostenübersicht oben)

**Option B: Öffentliche deutsche Sender (kostenlos, legal)**
- **ARD/ZDF**: Offizielle Streams verfügbar
- **Öffentlich-rechtliche Sender**: Oft kostenlos verfügbar
- **Tools**: Einige Tools können diese in M3U-Format konvertieren
- **Achtung**: URLs ändern sich häufig, regelmäßige Updates nötig

**Beispiel-M3U-Format:**
```
#EXTM3U
#EXTINF:-1 tvg-id="ard.de" tvg-name="ARD" tvg-logo="https://example.com/ard.png" group-title="Deutschland",ARD
http://example.com/ard/stream.m3u8
#EXTINF:-1 tvg-id="zdf.de" tvg-name="ZDF" tvg-logo="https://example.com/zdf.png" group-title="Deutschland",ZDF
http://example.com/zdf/stream.m3u8
```

#### 2. M3U-Tuner in Jellyfin hinzufügen

1. **Jellyfin Webinterface öffnen**: https://jellyfin.k8sops.online
2. **Als Admin einloggen**: `bernd:Montag69`
3. **Navigation**: Dashboard → Live-TV
4. **Tuner hinzufügen**: Klicke auf "Add Tuner Device"
5. **Tuner-Typ wählen**: "M3U Tuner"
6. **Konfiguration**:
   - **Name**: z.B. "Deutsche Sender IPTV"
   - **M3U Playlist URL**: URL deiner M3U-Playlist
     - Oder: Lokale Datei (muss im Container erreichbar sein)
   - **M3U Playlist Path**: Falls lokale Datei, z.B. `/config/livetv/playlist.m3u`
7. **Speichern**

#### 3. EPG (Programmführer) hinzufügen

Für deutsche Sender gibt es verschiedene EPG-Quellen:

**Option A: Schedules Direct (Empfohlen - beste Qualität)**
- **Kosten**: ~$25/Jahr (~23€/Jahr)
- **Qualität**: ⭐⭐⭐⭐⭐ Professionell, sehr zuverlässig
- **Abdeckung**: Sehr gute EPG-Daten für deutsche Sender
- **Website**: https://www.schedulesdirect.org
- **Einrichtung**: 
  1. Account erstellen auf schedulesdirect.org
  2. Lineup für Deutschland wählen
  3. In Jellyfin: Dashboard → Live-TV → "Add Provider" → "Schedules Direct"
  4. Login-Daten eingeben

**Option B: XMLTV-EPG (Kostenlos, Qualität variiert)**
1. **EPG-Provider hinzufügen**: Dashboard → Live-TV → "Add Provider"
2. **Provider-Typ**: "XMLTV"
3. **Konfiguration**:
   - **Name**: z.B. "Deutsche Sender EPG"
   - **XMLTV URL**: URL zu XMLTV-Datei
     - Beispiel: `https://example.com/epg.xml`
   - Oder: Lokale Datei, z.B. `/config/livetv/epg.xml`
4. **Speichern**

**Option C: Kostenlose EPG-Quellen**
- Einige deutsche Sender bieten EPG-Daten an
- Oft als XMLTV verfügbar
- Qualität variiert, manchmal unvollständig
- **Tools**: Einige Tools können EPG-Daten für deutsche Sender generieren

#### 4. Kanäle zuordnen

Nach dem Hinzufügen von Tuner und EPG:
1. **Kanäle zuordnen**: Dashboard → Live-TV → Kanäle
2. Jeder Kanal aus der M3U-Playlist muss dem EPG zugeordnet werden
3. **Automatische Zuordnung**: Jellyfin versucht automatisch zuzuordnen
4. **Manuelle Zuordnung**: Falls nötig, manuell korrigieren

## Option 2: HDHomeRun (Hardware-Tuner)

### Vorteile
- ✅ Sehr gute Qualität (Over-the-Air)
- ✅ Keine Abhängigkeit von Internet-Streams
- ✅ Lokale Aufnahmen möglich
- ✅ EPG über HDHomeRun verfügbar

### Nachteile
- ⚠️ Hardware-Kosten (~100-200€)
- ⚠️ Antenne nötig (DVB-T/T2)
- ⚠️ Abhängig von Empfang

### Einrichtung

1. **HDHomeRun kaufen und einrichten**
   - HDHomeRun Connect oder Flex
   - Mit Antenne verbinden
   - Im lokalen Netzwerk verfügbar machen

2. **HDHomeRun in Jellyfin hinzufügen**
   - Dashboard → Live-TV → "Add Tuner Device"
   - Tuner-Typ: "HDHomeRun"
   - Jellyfin findet HDHomeRun automatisch im Netzwerk
   - EPG wird automatisch von HDHomeRun bezogen

## Option 3: DVB-T/T2/C/S Tuner (Linux)

### Vorteile
- ✅ Direkte Hardware-Integration
- ✅ Sehr gute Qualität
- ✅ Lokale Aufnahmen

### Nachteile
- ⚠️ Komplexe Einrichtung
- ⚠️ Hardware-Treiber nötig
- ⚠️ Im Container schwierig (Device-Zugriff)

### Einrichtung

Für Kubernetes/Container:
1. **DVB-Tuner-Karte** im Host-System installieren
2. **Device-Mapping** im Kubernetes Deployment:
   ```yaml
   volumeMounts:
   - mountPath: /dev/dvb
     name: dvb-devices
   volumes:
   - hostPath:
       path: /dev/dvb
       type: Directory
     name: dvb-devices
   ```
3. **Tuner in Jellyfin konfigurieren**

## Empfohlene Konfiguration für deutsche Sender

### 💰 Kosten-Nutzen-Vergleich

#### Option 1: Günstig (kostenlos)
- **M3U-Playlist**: Öffentlich-rechtliche Sender (kostenlos)
- **EPG**: Kostenlose XMLTV-Quelle
- **Kosten**: 0€/Monat
- **Sender**: ~10-20 (nur öffentlich-rechtlich)
- **Qualität**: ⭐⭐⭐ Gut für Grundversorgung

#### Option 2: Mittel (empfohlen)
- **M3U-Playlist**: Waipu.tv Comfort (7,49€/Monat)
- **EPG**: Schedules Direct (~23€/Jahr = ~2€/Monat)
- **Kosten**: ~9,50€/Monat
- **Sender**: 290+ deutsche + 20.000+ internationale (inkl. US-Sender!)
- **Qualität**: ⭐⭐⭐⭐ Sehr gut
- **US-Sender**: ✅ Comedy Central, HBO, CNN, Fox, etc. verfügbar

#### Option 3: Premium
- **M3U-Playlist**: Waipu.tv Perfect Plus (14,99€/Monat)
- **EPG**: Schedules Direct (~23€/Jahr = ~2€/Monat)
- **Kosten**: ~17€/Monat
- **Sender**: 290+ deutsche + 20.000+ internationale (viele HD, Pay-TV)
- **Qualität**: ⭐⭐⭐⭐⭐ Beste Qualität
- **US-Sender**: ✅ Alle wichtigen US-Kanäle in HD verfügbar

### M3U-Playlist mit deutschen Sendern

**Öffentlich-rechtliche Sender (kostenlos, legal):**
- ARD (Das Erste)
- ZDF
- 3sat, Arte, Phoenix
- ARD-Mediathek Streams
- ZDF-Streams

**Private Sender (über IPTV-Anbieter):**
- RTL, ProSieben, Sat.1, VOX, etc.
- Über Waipu.tv, Zattoo, MagentaTV verfügbar

### EPG-Quellen für Deutschland

1. **Schedules Direct** (~23€/Jahr) - ⭐⭐⭐⭐⭐ Beste Qualität
2. **XMLTV mit deutschen Sendern** (kostenlos) - ⭐⭐⭐ Qualität variiert
3. **HDHomeRun EPG** (wenn HDHomeRun verwendet wird) - ⭐⭐⭐⭐ Gut

## Praktische Schritte

### Schritt 1: M3U-Playlist erstellen/beschaffen

**Falls du eine IPTV-URL hast:**
```
http://dein-iptv-anbieter.com/playlist.m3u?username=xxx&password=yyy
```

**Falls lokale Datei:**
1. M3U-Datei erstellen oder herunterladen
2. In Jellyfin-Container zugänglich machen:
   ```bash
   kubectl cp playlist.m3u default/$(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}'):/config/livetv/playlist.m3u
   ```
3. In Jellyfin: Pfad `/config/livetv/playlist.m3u` verwenden

### Schritt 2: EPG-Datei beschaffen

**XMLTV-EPG für Deutschland:**
- Einige Tools können EPG-Daten für deutsche Sender generieren
- Oder: Schedules Direct nutzen (kostenpflichtig, aber sehr gut)

**Lokale EPG-Datei:**
```bash
kubectl cp epg.xml default/$(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}'):/config/livetv/epg.xml
```

### Schritt 3: In Jellyfin konfigurieren

1. **Tuner hinzufügen**:
   - Dashboard → Live-TV → "Add Tuner Device"
   - M3U Tuner wählen
   - URL oder Pfad eingeben

2. **EPG hinzufügen**:
   - Dashboard → Live-TV → "Add Provider"
   - XMLTV wählen
   - URL oder Pfad eingeben

3. **Kanäle zuordnen**:
   - Automatisch oder manuell

## Wichtige Hinweise

### Rechtliche Aspekte
- ⚠️ **Nur legale Quellen nutzen!**
- ⚠️ Urheberrechte beachten
- ⚠️ Öffentlich-rechtliche Sender sind oft kostenlos verfügbar
- ⚠️ Private IPTV-Anbieter prüfen (oft illegal)

### Performance
- Live-TV-Streams können CPU/GPU belasten
- Hardware-Beschleunigung (NVENC) hilft bei Transkodierung
- Mehrere gleichzeitige Streams = mehr Ressourcen

### Container-Konfiguration

Falls lokale Dateien genutzt werden, müssen diese im Container verfügbar sein:
- M3U-Playlist: `/config/livetv/playlist.m3u`
- EPG-Datei: `/config/livetv/epg.xml`

Diese Dateien werden im PersistentVolume `/config` gespeichert.

## 🛒 Wo bekommt man das her?

### IPTV-Anbieter (Seriös)

1. **Waipu.tv** (Empfohlen für US-Sender!)
   - Website: https://www.waipu.tv
   - Direkt auf der Website registrieren
   - Kostenloser Probemonat
   - **Besonderheit**: 20.000+ internationale Sender (inkl. US-Sender wie Comedy Central, HBO)
   - M3U-Playlist: Prüfe in den Einstellungen oder Support kontaktieren

2. **Zattoo**
   - Website: https://zattoo.com
   - Direkt auf der Website registrieren
   - Kostenloser Testmonat
   - M3U-Playlist: Prüfe in den Einstellungen oder Support kontaktieren

3. **MagentaTV (Telekom)**
   - Website: https://www.telekom.de/fernsehen
   - Für Telekom-Kunden oft günstiger
   - M3U-Playlist: Prüfe in den Einstellungen

### US-TV spezifisch

1. **Pluto TV** (Kostenlos!)
   - Website: https://pluto.tv
   - Viele US-Kanäle, auch in Deutschland verfügbar
   - Werbefinanziert, aber kostenlos
   - M3U-Playlist: Prüfe ob verfügbar

2. **YouTube** (Kostenlos für viele Shows!)
   - **Last Week Tonight**: Vollständige Episoden auf YouTube
   - **Daily Show**: Clips und Highlights
   - **Achtung**: Nicht als Live-TV, sondern On-Demand
   - **Jellyfin-Integration**: Über YouTube-Plugin möglich

### EPG-Anbieter

1. **Schedules Direct**
   - Website: https://www.schedulesdirect.org
   - Account erstellen, Lineup für Deutschland wählen
   - Direkt in Jellyfin integrierbar

2. **Kostenlose XMLTV-Quellen**
   - Verschiedene Tools und Websites
   - Qualität variiert, regelmäßige Updates nötig

### ⚠️ WICHTIG: Was man NICHT tun sollte

**Vermeide:**
- ❌ IPTV-Anbieter auf Telegram, Discord, etc.
- ❌ Angebote mit "1000+ Sender für 5€"
- ❌ Anbieter ohne Impressum
- ❌ "Lifetime"-Angebote
- ❌ Anbieter, die nur Krypto-Zahlungen akzeptieren

**Warum?**
- Meist illegal (keine Lizenzen)
- Risiko von Abmahnungen
- Streams können jederzeit wegbrechen
- Keine Garantie auf Service

## 🎯 Empfehlungen für spezifische Shows

### Daily Show (Comedy Central, USA)
- **Option 1**: Waipu.tv (7,49-14,99€/Monat) - Comedy Central verfügbar
- **Option 2**: YouTube (kostenlos) - Clips und Highlights
- **Option 3**: Comedy Central Website (geoblockiert, VPN nötig)

### Last Week Tonight (HBO, USA)
- **Option 1**: ✅ **YouTube (KOSTENLOS!)** - Vollständige Episoden!
- **Option 2**: Waipu.tv (7,49-14,99€/Monat) - HBO verfügbar
- **Option 3**: HBO Max (geoblockiert in Deutschland, VPN nötig)

### Allgemeine US-Sender
- **Waipu.tv**: Beste Option für viele US-Sender (20.000+ internationale Sender)
- **Pluto TV**: Kostenlos, viele US-Kanäle
- **Schedules Direct EPG**: Sehr gute EPG-Daten auch für US-Sender

## Nächste Schritte

1. **Entscheidung treffen**: 
   - Nur deutsche Sender? → Kostenlos (öffentlich-rechtlich) oder Waipu.tv/Zattoo
   - US-Sender gewünscht? → Waipu.tv (beste Option) oder Pluto TV (kostenlos)
2. **Anbieter wählen**: 
   - Deutsche Sender: Waipu.tv, Zattoo oder MagentaTV
   - US-Sender: Waipu.tv (empfohlen) oder Pluto TV (kostenlos)
3. **M3U-Playlist beschaffen**: Vom Anbieter oder kostenlos
4. **EPG wählen**: Schedules Direct (bezahlt, ~23€/Jahr) oder kostenlose XMLTV-Quelle
5. **In Jellyfin konfigurieren** (siehe Schritte oben)
6. **Kanäle testen** und zuordnen
7. **Aufnahmen konfigurieren** (falls gewünscht)

## Hilfe und Ressourcen

- **Jellyfin Live-TV Dokumentation**: https://jellyfin.org/docs/general/server/live-tv/
- **M3U-Format**: Standard-Format für IPTV-Playlists
- **XMLTV-Format**: Standard für EPG-Daten
- **Schedules Direct**: Professioneller EPG-Service

**Viel Erfolg beim Einrichten! 📺**

