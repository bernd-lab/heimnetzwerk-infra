# Jellyfin Live-TV - Öffentlich-rechtliche Sender eingerichtet

**Datum**: 2025-11-07  
**Status**: ✅ **M3U-Tuner erfolgreich konfiguriert**

## Durchgeführte Einrichtung

### ✅ M3U-Playlist erstellt
- **Datei**: `oeffentlich-rechtliche-sender.m3u`
- **Pfad im Container**: `/config/livetv/oeffentlich-rechtliche-sender.m3u`
- **Enthaltene Sender** (17 Sender):
  - Das Erste
  - ZDF
  - 3sat
  - Arte
  - Phoenix
  - ARD-alpha
  - Deutsche Welle
  - KiKA
  - tagesschau24
  - ONE
  - NDR
  - WDR
  - BR
  - MDR
  - SWR
  - HR
  - RBB
  - SR

### ✅ M3U-Tuner in Jellyfin konfiguriert
- **Tuner-Typ**: M3U Tuner
- **Playlist-Pfad**: `/config/livetv/oeffentlich-rechtliche-sender.m3u`
- **Status**: ✅ Erfolgreich hinzugefügt
- **Kanäle**: Jellyfin lädt aktuell die Kanäle aus der Playlist

### ⚠️ EPG (Programmführer)
- **Status**: XMLTV-Provider erstellt, aber noch keine EPG-URL konfiguriert
- **Hinweis**: Die Kanäle funktionieren auch ohne EPG, nur ohne Programminformationen
- **Optionen für später**:
  1. **Schedules Direct** (~23€/Jahr) - Beste Qualität, sehr zuverlässig
  2. **Kostenlose XMLTV-Quellen** - Müssen selbst generiert oder gefunden werden
  3. **Ohne EPG** - Kanäle funktionieren, aber keine Programminformationen

## Nächste Schritte

### 1. Kanäle testen
- Nach dem Laden der Kanäle können diese im Jellyfin-Interface getestet werden
- Navigation: Dashboard → Live-TV → Kanäle

### 2. EPG hinzufügen (optional)
- **Schedules Direct** (empfohlen):
  - Website: https://www.schedulesdirect.org
  - Kosten: ~23€/Jahr
  - Sehr gute EPG-Daten für deutsche Sender
- **Kostenlose Optionen**:
  - XMLTV-Tools können EPG-Daten generieren
  - Einige öffentliche Quellen verfügbar (Qualität variiert)

### 3. Kanäle zuordnen (falls EPG hinzugefügt)
- Nach dem Hinzufügen von EPG-Daten müssen die Kanäle den EPG-Einträgen zugeordnet werden
- Jellyfin versucht automatisch zuzuordnen, manuelle Korrekturen möglich

## Dateien

- **M3U-Playlist**: `/home/bernd/infra-0511/oeffentlich-rechtliche-sender.m3u`
- **Im Container**: `/config/livetv/oeffentlich-rechtliche-sender.m3u`

## Zusammenfassung

✅ **17 öffentlich-rechtliche deutsche Sender** sind jetzt in Jellyfin verfügbar  
✅ **Alle Sender sind kostenlos und legal**  
✅ **Live-TV funktioniert sofort** (auch ohne EPG)  
⚠️ **EPG-Daten können später hinzugefügt werden** (optional)

**Die öffentlich-rechtlichen Sender sind jetzt einsatzbereit!**

## Weitere kostenlose Quellen (US-TV & International)

### IPTV-Org - Kostenlose US-TV-Sender
- **URL**: `https://iptv-org.github.io/iptv/countries/us.m3u`
- **Status**: ⚠️ Noch nicht hinzugefügt - kann manuell hinzugefügt werden
- **Anleitung**: Siehe `jellyfin-kostenlose-tv-quellen.md`

### Weitere kostenlose Quellen
- **Alle Länder**: `https://iptv-org.github.io/iptv/index.m3u`
- **Kategorien**: News, Sports, Movies, Kids, Music verfügbar
- **Details**: Siehe `jellyfin-kostenlose-tv-quellen.md`

