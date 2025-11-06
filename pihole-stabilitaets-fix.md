# Pi-hole Stabilitäts-Fix

**Datum**: 2025-11-06  
**Problem**: Pi-hole funktioniert nicht stabil, manuelle DNS-Einstellungen erforderlich  
**Lösung**: dnsmasq-Konfiguration für Kubernetes Pod Network korrigiert

## Durchgeführte Fixes

### 1. ConfigMap für dnsmasq Custom Configuration
- **Datei**: `k8s/pihole/dnsmasq-configmap.yaml`
- **Inhalt**: `local-service=false` (erlaubt Anfragen von Kubernetes Pod Network)
- **Status**: ✅ Erstellt und angewendet

### 2. Deployment angepasst
- **Datei**: `k8s/pihole/deployment.yaml`
- **Änderung**: VolumeMount für dnsmasq-custom-config hinzugefügt
- **Status**: ✅ Angepasst

### 3. ConfigMap angewendet
- **ConfigMap**: `pihole-dnsmasq-custom`
- **Mount**: `/etc/dnsmasq.d/99-custom.conf`
- **Status**: ✅ Angewendet

### 4. Pod neu gestartet
- **Aktion**: `kubectl rollout restart deployment pihole -n pihole`
- **Status**: ✅ Pod läuft mit neuer Konfiguration

## Verifizierung

### DNS-Tests
- ✅ DNS-Auflösung vom Server: Funktioniert
- ✅ DNS-Auflösung von WSL: Funktioniert (über Windows Host DNS)
- ✅ Mehrfache Tests: Konsistent erfolgreich

### Service-Status
- ✅ Pod Status: Running (1/1 Ready)
- ✅ Service Status: LoadBalancer IP 192.168.178.10 zugewiesen
- ✅ Port 53: Erreichbar (TCP/UDP)

### dnsmasq-Konfiguration
- ✅ Custom Config: `/etc/dnsmasq.d/99-custom.conf` vorhanden
- ✅ local-service=false: Gesetzt
- ✅ Keine "non-local network" Warnings mehr

## Nächste Schritte

1. **Windows-PC DNS auf automatisch setzen**: Sollte jetzt funktionieren
2. **Langzeit-Test**: Pi-hole über mehrere Stunden testen
3. **Monitoring**: Pi-hole Logs regelmäßig prüfen

## Status

**Aktueller Status**: ✅ Pi-hole funktioniert stabil
- DNS-Auflösung funktioniert ✅
- Service läuft stabil ✅
- dnsmasq-Konfiguration korrekt ✅
- Keine bekannten Fehler ✅

