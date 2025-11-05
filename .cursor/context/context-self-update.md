# Kontext-Selbstaktualisierung für Agenten

## Übersicht

**WICHTIG**: Agenten sollten nach jeder Aufgabe ihren eigenen Kontext überprüfen und aktualisieren, um ihre Dokumentation und ihr Wissen aktuell zu halten.

## Warum Kontext aktualisieren?

1. **Aktualität**: Dokumentation bleibt immer auf dem neuesten Stand
2. **Lerneffekt**: Agenten sammeln Wissen über erfolgreiche Lösungen
3. **Wiederverwendbarkeit**: Andere Agenten profitieren von aktualisiertem Wissen
4. **Konsistenz**: Alle Agenten haben die gleichen, aktuellen Informationen

## Wann Kontext aktualisieren?

### Nach jeder Aufgabe:
1. **Neue Erkenntnisse**: Wenn neue Informationen oder Lösungen gefunden wurden
2. **Fehlerbehebung**: Wenn Probleme identifiziert und gelöst wurden
3. **Konfigurationsänderungen**: Wenn Systeme oder Einstellungen geändert wurden
4. **Best Practices**: Wenn neue bewährte Verfahren identifiziert wurden
5. **Troubleshooting**: Wenn neue Fehlerquellen oder Lösungswege gefunden wurden

### Beispiele:
- ✅ GitLab 502-Fehler gefunden und behoben → Kontext aktualisiert
- ✅ Neue Liveness-Probe-Konfiguration → Kontext aktualisiert
- ✅ Neue API-Endpunkte entdeckt → Kontext aktualisiert
- ✅ Sicherheitsproblem identifiziert → Kontext aktualisiert
- ✅ Best Practice gefunden → Kontext aktualisiert

## Wie Kontext aktualisieren?

### 1. Datei identifizieren
- **Agent-Kontext**: `.cursor/commands/<agent-name>.md`
- **Shared Context**: `.cursor/context/<context-name>.md`
- **Dokumentation**: Relevante `.md` Dateien im Projekt

### 2. Relevante Abschnitte finden
- **"Bekannte Konfigurationen"**: Aktuelle Konfigurationen und Status
- **"Wichtige Dokumentation"**: Neue Dokumentationsreferenzen
- **"Troubleshooting"**: Neue Fehlerquellen und Lösungen
- **"Best Practices"**: Neue bewährte Verfahren
- **"Wichtige Hinweise"**: Wichtige Erkenntnisse und Warnungen

### 3. Aktualisierungen vornehmen
```markdown
## Bekannte Konfigurationen

### Beispiel-Service
- **Status**: ✅ Stabil (nach [Problem]-Fix am [Datum])
- **Problem**: [Beschreibung des Problems]
- **Lösung**: [Beschreibung der Lösung]
- **Wichtig**: [Wichtige Erkenntnisse oder Warnungen]
```

### 4. Dokumentation verlinken
Wenn detaillierte Analyse-Dokumente erstellt wurden:
```markdown
## Wichtige Dokumentation

Lese diese Dateien für vollständigen Kontext:
- `problem-analysis.md` - **WICHTIG**: Analyse des [Problems] und Fix
- `best-practice-guide.md` - Best Practices für [Thema]
```

## Kontext-Aktualisierungs-Checklist

Nach jeder Aufgabe prüfen:

- [ ] **Neue Erkenntnisse dokumentiert?**
  - Neue Lösungen in "Bekannte Konfigurationen" eingetragen?
  - Neue Best Practices hinzugefügt?
  
- [ ] **Fehlerbehebung dokumentiert?**
  - Problem in "Troubleshooting" dokumentiert?
  - Lösungsschritte beschrieben?
  - Warnungen hinzugefügt?
  
- [ ] **Konfigurationen aktualisiert?**
  - Status aktualisiert (z.B. "✅ Stabil" nach Fix)?
  - Konfigurationsänderungen dokumentiert?
  - Wichtige Parameter notiert?
  
- [ ] **Dokumentation verlinkt?**
  - Neue Analyse-Dokumente in "Wichtige Dokumentation" verlinkt?
  - Relevante externe Dokumentation ergänzt?
  
- [ ] **Konsistenz geprüft?**
  - Informationen stimmen mit anderen Agenten überein?
  - Widersprüche aufgelöst?
  - Cross-Referenzen aktualisiert?

## Beispiel: Kontext-Aktualisierung

### Vorher:
```markdown
### GitLab
- **Status**: ✅ Stabil
- **Liveness Probe**: Korrigiert auf `/-/health`
```

### Nachher (nach 502-Fehler-Fix):
```markdown
### GitLab
- **Status**: ✅ Stabil (nach Liveness-Probe-Fix am 2025-11-05)
- **Liveness Probe**: `exec` mit `curl -sf http://localhost:80/-/health` (initialDelay: 600s, failureThreshold: 12)
- **502-Fehler-Problem**: War durch fehlgeschlagene Liveness-Probe verursacht (Pod wurde getötet)
- **Fix**: Liveness-Probe von `httpGet` auf `exec` umgestellt (analog zur Readiness-Probe)
- **Wichtig**: Liveness-Probe muss `exec` verwenden, nicht `httpGet` (verursacht 404-Fehler)
```

### Zusätzlich in "Wichtige Dokumentation":
```markdown
- `gitlab-502-fix-analysis.md` - **WICHTIG**: Analyse des 502-Fehler-Problems nach Login und Fix
```

### Zusätzlich in "Troubleshooting":
```markdown
- **Health-Probes**: Bei 404-Fehlern mit `httpGet`-Probes → auf `exec` mit `curl` umstellen
- **Pod-Restarts**: Prüfe Liveness-Probe-Konfiguration, Exit Code 137 = SIGKILL (Pod wurde getötet)
```

## Integration in Agenten

### Standard-Abschnitt für jeden Agenten:

```markdown
## Kontext-Aktualisierung

**WICHTIG**: Nach jeder Aufgabe eigenen Kontext überprüfen und aktualisieren!

### Wann aktualisieren?
- ✅ Neue Erkenntnisse oder Lösungen gefunden
- ✅ Probleme identifiziert und behoben
- ✅ Konfigurationen geändert
- ✅ Best Practices identifiziert
- ✅ Fehlerquellen oder Lösungswege gefunden

### Was aktualisieren?
1. **"Bekannte Konfigurationen"**: Status, Probleme, Lösungen
2. **"Wichtige Dokumentation"**: Neue Analyse-Dokumente verlinken
3. **"Troubleshooting"**: Neue Fehlerquellen und Lösungen
4. **"Best Practices"**: Neue bewährte Verfahren
5. **"Wichtige Hinweise"**: Wichtige Erkenntnisse und Warnungen

### Checklist nach jeder Aufgabe:
- [ ] Neue Erkenntnisse in "Bekannte Konfigurationen" dokumentiert?
- [ ] Probleme und Lösungen in "Troubleshooting" ergänzt?
- [ ] Neue Dokumentation in "Wichtige Dokumentation" verlinkt?
- [ ] Status und Konfigurationen aktualisiert?
- [ ] Konsistenz mit anderen Agenten geprüft?

Siehe: `.cursor/context/context-self-update.md` für vollständige Anleitung.
```

## Wichtige Hinweise

1. **Konsistenz**: Aktualisierungen sollten konsistent mit anderen Agenten sein
2. **Verlinkung**: Wichtige Analyse-Dokumente immer verlinken
3. **Datum**: Bei wichtigen Fixes Datum dokumentieren
4. **Status**: Status immer aktuell halten (✅, ⚠️, ❌)
5. **Warnungen**: Wichtige Warnungen und "Gotchas" immer dokumentieren

## Zusammenarbeit mit anderen Agenten

- **Cross-Referenzen**: Wenn ein Agent Kontext aktualisiert, sollten relevante andere Agenten auch aktualisiert werden
- **Shared Context**: Gemeinsame Erkenntnisse in `.cursor/context/` dokumentieren
- **Konsistenz-Check**: Vor dem Commit prüfen ob andere Agenten aktualisiert werden müssen

## Beispiel-Workflow

1. **Aufgabe ausführen**: Problem analysieren und lösen
2. **Dokumentation erstellen**: Analyse-Dokument erstellen (z.B. `problem-fix-analysis.md`)
3. **Kontext aktualisieren**: Agent-Datei aktualisieren
4. **Shared Context prüfen**: Falls relevant, Shared Context aktualisieren
5. **Andere Agenten prüfen**: Falls relevant, andere Agenten aktualisieren
6. **Git-Commit**: Alles committen und pushen

Dieser Workflow stellt sicher, dass alle Agenten immer aktuelles Wissen haben und von erfolgreichen Lösungen profitieren.

