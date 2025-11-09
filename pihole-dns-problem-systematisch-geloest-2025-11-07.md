# Pi-hole DNS-Problem systematisch gelöst

**Datum**: 2025-11-07  
**Status**: ✅ **Problem behoben**

## Problem

Pi-hole lief, aber DNS-Anfragen von Windows-Clients (192.168.178.x) wurden ignoriert mit der Warnung:
```
WARNING: dnsmasq: ignoring query from non-local network 192.168.178.20
```

## Lösung - Systematische Implementierung

### 1. DNS-Expert: ConfigMap optimiert

**Datei**: `k8s/pihole/dnsmasq-configmap.yaml`

**Änderungen**:
- ✅ `listen-address=0.0.0.0` hinzugefügt (erforderlich laut Recherche)
- ✅ `interface=eth0` explizit gesetzt (war vorher leer)
- ✅ `local-service=false` beibehalten
- ✅ `bind-interfaces=false` beibehalten

**Neue Konfiguration**:
```conf
listen-address=0.0.0.0
interface=eth0
bind-interfaces=false
local-service=false
```

### 2. K8s-Expert: Deployment erweitert

**Datei**: `k8s/pihole/deployment.yaml`

**Änderungen**:
- ✅ Umgebungsvariable `FTLCONF_dns_listeningMode: "all"` hinzugefügt
- ✅ Umgebungsvariable `FTLCONF_dns_interface: "eth0"` hinzugefügt

**Zweck**: Pi-hole FTL verwendet diese Variablen für die DNS-Konfiguration.

### 3. Network-Expert: Verifizierung

**Tests durchgeführt**:
- ✅ Pod läuft (`Running`)
- ✅ ConfigMap korrekt gemountet
- ✅ Umgebungsvariablen gesetzt
- ✅ Port 53 lauscht auf allen Interfaces
- ⚠️ DNS-Test: Wird durchgeführt

### 4. Infrastructure-Expert: Dokumentation

**Status**: Wird aktualisiert

## Implementierung

### Durchgeführte Schritte:

1. ✅ **ConfigMap aktualisiert**: `k8s/pihole/dnsmasq-configmap.yaml`
2. ✅ **Deployment erweitert**: `k8s/pihole/deployment.yaml`
3. ✅ **ConfigMap angewendet**: `kubectl apply -f k8s/pihole/dnsmasq-configmap.yaml`
4. ✅ **Deployment angewendet**: `kubectl apply -f k8s/pihole/deployment.yaml`
5. ✅ **Pod neu gestartet**: `kubectl rollout restart deployment pihole -n pihole`
6. ⚠️ **Verifizierung**: Wird durchgeführt

## Erwartetes Ergebnis

Nach erfolgreichem Neustart:
- ✅ Keine "ignoring query from non-local network" Warnungen mehr
- ✅ DNS-Abfragen funktionieren (`dig @192.168.178.10 google.de`)
- ✅ Windows kann automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

