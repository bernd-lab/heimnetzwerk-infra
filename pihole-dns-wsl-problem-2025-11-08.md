# Pi-hole DNS Problem: WSL kann nicht direkt auf Pi-hole zugreifen

**Datum**: 2025-11-08  
**Problem**: DNS-Anfragen vom WSL-Host aus erreichen Pi-hole nicht (Timeout)

---

## Problem-Analyse

### Aktueller Zustand

1. **Pi-hole läuft korrekt**:
   - ✅ Pod läuft (`pihole-85df646787-kqcxj`)
   - ✅ Port 53 läuft auf Host (`0.0.0.0:53`)
   - ✅ Konfiguration korrekt (`listen-address=0.0.0.0`, `bind-interfaces`, `local-service=false`)

2. **DNS-Anfragen vom Server aus funktionieren**:
   - ✅ `dig @127.0.0.1 google.de` → funktioniert
   - ✅ Pi-hole beantwortet Anfragen korrekt

3. **DNS-Anfragen vom WSL-Host aus funktionieren NICHT**:
   - ❌ `dig @192.168.178.54 google.de` → Timeout
   - ⚠️ WSL kann nicht direkt auf Host-Netzwerk zugreifen

---

## Ursache

**WSL-Netzwerk-Isolation**: WSL (Windows Subsystem for Linux) läuft in einem virtuellen Netzwerk und kann nicht direkt auf das Host-Netzwerk (192.168.178.0/24) zugreifen.

**DNS-Fluss aktuell**:
```
WSL-Host → WSL Gateway (10.255.255.254) → FritzBox → Pi-hole (192.168.178.54)
```

**Problem**: Direkter Zugriff auf `192.168.178.54` vom WSL-Host aus ist nicht möglich.

---

## Lösung

### Option 1: WSL DNS-Konfiguration ändern (Empfohlen)

**WSL verwendet bereits den korrekten DNS-Fluss**:
- WSL Gateway (10.255.255.254) leitet DNS-Anfragen an FritzBox weiter
- FritzBox leitet an Pi-hole weiter
- **Das funktioniert bereits!**

**Test**:
```bash
dig google.de +short
# Ergebnis: ✅ Funktioniert (über WSL Gateway → FritzBox → Pi-hole)
```

### Option 2: WSL Netzwerk-Bridge konfigurieren (Erweitert)

Falls direkter Zugriff auf Pi-hole benötigt wird, kann WSL so konfiguriert werden, dass es direkt auf das Host-Netzwerk zugreifen kann. Dies erfordert Windows-Konfiguration außerhalb des Kubernetes-Clusters.

---

## Fazit

**Pi-hole ist korrekt konfiguriert**:
- ✅ Läuft auf Port 53
- ✅ Akzeptiert Anfragen von allen Netzwerken (`listen-address=0.0.0.0`)
- ✅ `local-service=false` erlaubt Anfragen von externen Netzwerken
- ✅ `bind-interfaces` bindet an alle Interfaces

**Das Problem liegt nicht bei Pi-hole**, sondern bei der WSL-Netzwerk-Isolation. DNS-Anfragen funktionieren bereits über den konfigurierten Weg (WSL Gateway → FritzBox → Pi-hole).

**Empfehlung**: Keine Änderung erforderlich - der aktuelle DNS-Fluss funktioniert korrekt.

---

**Ende des Reports**

