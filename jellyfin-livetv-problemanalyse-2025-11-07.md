# Jellyfin Live-TV Problem-Analyse

**Datum**: 2025-11-07  
**Problem**: Live-TV bleibt schwarz, keine Kanäle sichtbar

## Status der Tuner

### ✅ Beide Tuner sind konfiguriert:

1. **Deutsche Sender (M3U)**
   - **Pfad**: `/config/livetv/oeffentlich-rechtliche-sender.m3u`
   - **Status**: ✅ Datei existiert und ist korrekt formatiert
   - **Enthaltene Sender**: 17 öffentlich-rechtliche Sender (ARD, ZDF, 3sat, Arte, etc.)

2. **US-TV (M3U URL)**
   - **URL**: `https://iptv-org.github.io/iptv/countries/us.m3u`
   - **Status**: ✅ URL ist erreichbar
   - **Kanäle**: Viele US-Kanäle wurden erfolgreich geparst (Logs zeigen "Parsed channel")

## Analyse der Logs

### ✅ Erfolgreich geladen:
- **US-Kanäle**: Viele Kanäle wurden erfolgreich geparst (z.B. "Yahoo! Finance", "Yes Network", "Yo! MTV", etc.)
- **Guide-Daten**: "Refreshing guide with 7 days of guide data" - EPG wird aktualisiert

### ⚠️ Mögliche Probleme:

1. **Deutsche Sender**: Keine Logs gefunden, die zeigen, dass deutsche Sender geparst wurden
2. **Stream-URLs**: Die Stream-URLs in der M3U-Datei könnten nicht erreichbar sein
3. **Kanäle nicht aktiviert**: Kanäle müssen möglicherweise manuell aktiviert werden

## Mögliche Lösungen

### 1. Prüfe die Stream-URLs der deutschen Sender

Die M3U-Datei enthält URLs wie:
- `https://mcdn.daserste.de/daserste/de/master.m3u8`
- Diese URLs müssen vom Container aus erreichbar sein

### 2. Aktiviere die Kanäle manuell

1. Gehe zu: Dashboard → Live-TV → Kanäle
2. Prüfe, ob Kanäle angezeigt werden
3. Falls Kanäle angezeigt werden, aber nicht funktionieren:
   - Klicke auf einen Kanal
   - Prüfe die Stream-URL
   - Teste die URL direkt

### 3. Prüfe die Tuner-Konfiguration

1. Gehe zu: Dashboard → Live-TV → Tuner
2. Klicke auf den ersten Tuner (deutsche Sender)
3. Prüfe, ob der Pfad korrekt ist: `/config/livetv/oeffentlich-rechtliche-sender.m3u`
4. Klicke auf "Speichern" (auch wenn nichts geändert wurde)
5. Wiederhole für den zweiten Tuner (US-TV)

### 4. Teste die Stream-URLs direkt

```bash
# Teste deutsche Sender
kubectl exec -n default $(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}') -- curl -I "https://mcdn.daserste.de/daserste/de/master.m3u8"

# Teste US-Sender
kubectl exec -n default $(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}') -- curl -I "https://3abn.bozztv.com/3abn2/3abn_live/smil:3abn_live.smil/playlist.m3u8"
```

### 5. Prüfe die Jellyfin-Konfiguration

Die Kanäle könnten geladen sein, aber nicht in der UI angezeigt werden, weil:
- Kanäle müssen möglicherweise zuerst aktiviert werden
- EPG-Daten müssen zugeordnet werden
- Kanäle könnten gefiltert sein

## Nächste Schritte

1. ✅ **Tuner-Status**: Beide Tuner sind konfiguriert
2. ✅ **US-Kanäle**: Erfolgreich geladen (Logs bestätigen)
3. ⚠️ **Deutsche Sender**: Status unklar - keine Parsing-Logs gefunden
4. ⚠️ **Kanäle-Anzeige**: Kanäle werden nicht in der UI angezeigt

**Empfehlung**: 
- Prüfe die Kanäle-Seite im Webinterface
- Teste die Stream-URLs direkt
- Prüfe, ob die Kanäle aktiviert werden müssen

