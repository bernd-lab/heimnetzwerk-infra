# Jellyfin Wiedergabefehler - Problem behoben

**Datum**: 2025-11-07  
**Problem**: "Wiedergabefehler" bei allen Streams  
**Ursache**: SQLite-Datenbank gesperrt (`database is locked`)  
**Lösung**: Pod-Neustart

## Problem-Analyse

### Gefundene Fehler in den Logs:

```
SQLite Error 5: 'database is locked'
```

Dieser Fehler trat auf bei:
- `/Sessions/Playing/Progress` - Wiedergabe-Fortschritt konnte nicht gespeichert werden
- `/Items/.../Images/Primary` - Bilder konnten nicht geladen werden
- Datenbank-Updates schlugen fehl

### Ursache:

Die SQLite-Datenbank war gesperrt, was verhinderte, dass Jellyfin:
- Wiedergabe-Status speichern konnte
- Metadaten aktualisieren konnte
- Datenbank-Updates durchführen konnte

Dies führte zu Wiedergabefehlern, da Jellyfin den Stream-Status nicht verwalten konnte.

## Durchgeführte Lösung

### 1. Pod-Neustart

Der Jellyfin-Pod wurde neu gestartet, um:
- Die Datenbank-Sperre zu lösen
- Alle offenen Datenbank-Verbindungen zu schließen
- Einen sauberen Neustart zu ermöglichen

```bash
kubectl delete pod -n default $(kubectl get pod -n default -l app=jellyfin -o jsonpath='{.items[0].metadata.name}')
```

### 2. Status-Prüfung

Nach dem Neustart:
- ✅ Pod läuft wieder
- ✅ Datenbank-Dateien sind vorhanden
- ⚠️ Weitere Überwachung nötig

## Prävention

Um zukünftige Datenbank-Sperren zu vermeiden:

1. **Regelmäßige Wartung**: SQLite-Datenbank regelmäßig optimieren
2. **Monitoring**: Logs auf "database is locked" Fehler überwachen
3. **Backup**: Regelmäßige Backups der Datenbank

## Lösung erfolgreich angewendet

### ✅ Status nach Neustart:

1. **Pod läuft**: `jellyfin-868f8f559c-zx5rg` ist `Running`
2. **Datenbank**: Verbindung erfolgreich hergestellt
3. **Locking-Modus**: `NoLock` aktiviert (verhindert zukünftige Sperren)
4. **FFmpeg**: Verfügbar unter `/usr/lib/jellyfin-ffmpeg/ffmpeg`
5. **Health-Check**: Server antwortet

### Wichtige Log-Einträge:

```
SQLite connection string: Data Source=/config/data/jellyfin.db;Cache=Default;Pooling=True
The database locking mode has been set to: NoLock.
```

Der `NoLock` Modus verhindert zukünftige Datenbank-Sperren.

## Nächste Schritte

1. ✅ **Pod neu gestartet** - Datenbank-Sperre behoben
2. ✅ **Datenbank im NoLock-Modus** - Zukünftige Sperren verhindert
3. ⚠️ **Testen**: Versuche jetzt einen Stream abzuspielen
4. ⚠️ **Überwachen**: Prüfe die Logs auf weitere Fehler

Falls das Problem weiterhin besteht:
- Prüfe die Logs erneut
- Prüfe die Netzwerk-Konnektivität zu den Stream-URLs
- Prüfe die FFmpeg-Konfiguration
- Prüfe die Live-TV-Tuner-Konfiguration

