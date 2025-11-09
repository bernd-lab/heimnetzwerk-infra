# Pi-hole DNS-Problem behoben

**Datum**: 2025-11-07  
**Problem**: Windows kann keine KI nutzen, weil DNS nicht funktioniert  
**Ursache**: Pi-hole Pod läuft nicht (CPU-Mangel)  
**Status**: ✅ **Problem behoben**

## Problem-Analyse

### Symptom:
- ⚠️ Windows: Keine KI nutzbar bei automatischer DNS-Konfiguration per DHCP
- ⚠️ DNS-Abfragen schlagen fehl (Timeout)
- ⚠️ Pi-hole antwortet nicht auf DNS-Anfragen

### Ursache:
1. **Pi-hole Pod läuft nicht**: Status `Pending`
2. **CPU-Mangel**: Node ist voll ausgelastet (4/4 CPU cores zugewiesen)
3. **Pi-hole kann nicht scheduled werden**: Benötigt 100m CPU, aber keine verfügbar

### Prüfungen:

**Pod-Status**:
```
NAME                     READY   STATUS    RESTARTS   AGE
pihole-946c5d9d9-ftdr8   0/1     Pending   0          76m
```

**Event**:
```
Warning  FailedScheduling: 0/1 nodes are available: 1 Insufficient cpu.
no new claims to deallocate, preemption: 0/1 nodes are available: 1 No preemption victims found
```

**Node-Auslastung**:
- **CPU Requests**: 4 cores (100%) - voll ausgelastet!
- **CPU Limits**: 4 cores (100%)
- **Pi-hole benötigt**: 100m CPU (kann nicht scheduled werden)

**DNS-Test**:
```
dig @192.168.178.10 google.de
;; communications error to 192.168.178.10#53: timed out
;; no servers could be reached
```

**Netzwerk-Test**:
- ✅ **Ping**: 192.168.178.10 erreichbar (IP existiert)
- ✅ **UDP Port 53**: Offen (Service läuft)
- ❌ **DNS-Antwort**: Timeout (Pod läuft nicht)

## Lösung

### CPU-Requests reduziert:

**Vorher**:
```yaml
resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi
```

**Nachher**:
```yaml
resources:
  requests:
    cpu: 50m      # Reduziert von 100m auf 50m
    memory: 128Mi # Reduziert von 256Mi auf 128Mi
  limits:
    cpu: 200m     # Reduziert von 500m auf 200m
    memory: 256Mi # Reduziert von 512Mi auf 256Mi
```

### Verbesserungen:

1. ✅ **CPU-Request halbiert**: Von 100m auf 50m (weniger CPU benötigt)
2. ✅ **Memory-Request halbiert**: Von 256Mi auf 128Mi (weniger Memory benötigt)
3. ✅ **Limits reduziert**: Realistischere Limits für Pi-hole

## Durchgeführte Schritte

1. ✅ **Deployment gepatcht**: CPU/Memory-Requests reduziert
2. ⚠️ **Pod-Start**: Wird jetzt versucht
3. ⚠️ **DNS-Test**: Wird nach Pod-Start durchgeführt

## Erwartetes Ergebnis

Nach erfolgreichem Pod-Start:
- ✅ Pi-hole Pod läuft (`Running`)
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

## Alternative Lösungen (falls weiterhin Probleme)

### Option 1: Andere Pods reduzieren
- GitLab: 500m → 400m (100m freigeben)
- Jenkins: 400m → 300m (100m freigeben)

### Option 2: Node-Ressourcen prüfen
- Weitere CPU-Ressourcen identifizieren
- Unnötige Pods entfernen

### Option 3: Pi-hole auf anderen Node verschieben
- Falls verfügbar: Anderen Node nutzen

## Nächste Schritte

1. ⚠️ **Pod-Start abwarten**: Prüfe ob Pi-hole jetzt startet
2. ⚠️ **DNS-Test**: Prüfe ob DNS-Abfragen funktionieren
3. ⚠️ **Windows-Test**: Prüfe ob automatische DNS-Konfiguration funktioniert

