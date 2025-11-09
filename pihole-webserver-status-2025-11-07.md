# Pi-hole Webserver Status

**Datum**: 2025-11-07  
**Status**: ❌ **Webserver läuft NICHT**

## Problem

Der Pi-hole Webserver kann nicht auf Port 80 binden, weil Port 80 bereits von **nginx-ingress-controller** belegt ist.

**Fehlermeldung im Log**:
```
[2025-11-07 22:35:46.937 CET 67] Initializing HTTP server on ports "80o,443os,[::]:80o,[::]:443os"
[2025-11-07 22:35:46.940 CET 67] cannot bind to 80o: 98 (Address in use)
[2025-11-07 22:35:46.940 CET 67] cannot bind to 443os: 98 (Address in use)
[2025-11-07 22:35:46.940 CET 67] cannot bind to IPv6 [::]:80o: 98 (Address in use)
[2025-11-07 22:35:46.940 CET 67] cannot bind to IPv6 [::]:443os: 98 (Address in use)
```

## Aktuelle Situation

1. **Port 80**: Belegt von nginx-ingress-controller (läuft mit `hostNetwork: true`)
2. **Pi-hole Webserver**: Kann nicht starten, weil Port 80 nicht verfügbar ist
3. **Ingress erstellt**: `pihole-ingress` existiert, zeigt aber auf einen Service, der keinen laufenden Webserver hat
4. **Service**: `pihole` Service zeigt auf Port 80, aber Pi-hole Webserver läuft nicht

## Lösungsansätze

### Option 1: Pi-hole Webserver auf Port 8080 konfigurieren (Empfohlen)

**Schritte**:
1. Pi-hole Webserver-Konfiguration ändern: `webserver.port = "8080"`
2. Service anpassen: `targetPort: 8080`
3. Ingress bleibt unverändert (zeigt auf Service Port 80, der intern auf Pod Port 8080 weiterleitet)

### Option 2: Webserver deaktivieren und nur über Ingress zugreifen

**Problem**: Pi-hole Webserver ist notwendig für die Web-UI. Ohne Webserver keine Admin-Oberfläche.

### Option 3: nginx-ingress Port 80 freigeben

**Problem**: nginx-ingress wird von vielen anderen Services verwendet. Nicht praktikabel.

## Empfohlene Lösung

**Option 1**: Pi-hole Webserver auf Port 8080 konfigurieren und Service entsprechend anpassen.

**Konfiguration**:
- `pihole.toml`: `webserver.port = "8080"`
- `service.yaml`: `targetPort: 8080` (Service Port bleibt 80 für Ingress)
- Ingress bleibt unverändert

## Status

- ❌ Webserver läuft nicht
- ✅ Ingress erstellt
- ⚠️ Service zeigt auf nicht existierenden Webserver
- ✅ DNS funktioniert korrekt

