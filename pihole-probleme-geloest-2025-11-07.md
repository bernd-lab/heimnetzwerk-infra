# Pi-hole Probleme gelöst

**Datum**: 2025-11-07  
**Status**: ✅ Pod läuft, ⚠️ LoadBalancer IP noch nicht erreichbar

## Probleme identifiziert und gelöst

### ✅ Problem 1: Pi-hole Pod kann nicht starten - GELÖST

**Ursache**: `Insufficient CPU` - Node hatte 100% CPU-Requests zugewiesen

**Lösung**:
- Pi-hole CPU-Request auf `0` gesetzt (DNS benötigt sehr wenig CPU)
- Pi-hole Memory-Request auf `128Mi` reduziert
- GitLab CPU-Request reduziert (300m → 200m)
- Velero CPU-Request reduziert (100m → 50m)

**Ergebnis**: ✅ Pi-hole Pod läuft jetzt (`1/1 Running`)

### ⚠️ Problem 2: LoadBalancer IP nicht erreichbar - IN BEARBEITUNG

**Status**: 
- ✅ Pod läuft (`10.244.0.118`)
- ✅ Endpoints vorhanden (`10.244.0.118:53,10.244.0.118:80`)
- ✅ DNS funktioniert intern (Pod kann DNS-Abfragen beantworten)
- ✅ NodePort funktioniert (`dig @192.168.178.54 -p 30221 google.de`)
- ✅ LoadBalancer IP zugewiesen (`192.168.178.10/32` auf eth0)
- ❌ LoadBalancer IP nicht erreichbar (`dig @192.168.178.10` timeout)

**Konfiguration**:
- Service: `externalTrafficPolicy: Cluster` (geändert zu `Local` für Test)
- MetalLB: IP-Pool vorhanden (`192.168.178.10/32`)
- L2 Advertisement: Konfiguriert

**Nächste Schritte**:
1. MetalLB L2 Advertisement prüfen
2. ARP-Announcements prüfen
3. Netzwerk-Konfiguration prüfen (br0 vs eth0)
4. Eventuell HostNetwork-Modus testen

## Durchgeführte Änderungen

### 1. Pi-hole Deployment (`k8s/pihole/deployment.yaml`)

```yaml
resources:
  requests:
    memory: "128Mi"       # Minimal für DNS-Service
    cpu: "0"              # Kein CPU-Request - DNS benötigt sehr wenig CPU
  limits:
    memory: "512Mi"       # Limit bleibt für Spitzenlast
    cpu: "200m"           # Limit bleibt für Spitzenlast
```

### 2. Service-Konfiguration

- `externalTrafficPolicy: Cluster` → `Local` (getestet, keine Verbesserung)

## Test-Ergebnisse

### ✅ Funktionierende Zugriffe

- **Intern (Pod)**: `dig @127.0.0.1 google.de` → ✅ Funktioniert
- **NodePort**: `dig @192.168.178.54 -p 30221 google.de` → ✅ Funktioniert
- **HTTP NodePort**: `curl http://192.168.178.54:31874/admin/` → ✅ Funktioniert

### ❌ Nicht funktionierende Zugriffe

- **LoadBalancer IP**: `dig @192.168.178.10 google.de` → ❌ Timeout
- **HTTP LoadBalancer**: `curl http://192.168.178.10/admin/` → ❌ Timeout

## Empfehlungen

1. **Kurzfristig**: NodePort verwenden (`192.168.178.54:30221` für DNS)
2. **Mittelfristig**: MetalLB L2 Advertisement prüfen und korrigieren
3. **Langfristig**: HostNetwork-Modus für Pi-hole erwägen (falls LoadBalancer weiterhin nicht funktioniert)

## Aktueller Status

- ✅ Pi-hole Pod: **Running** (`pihole-86965f5486-99ms7`)
- ✅ DNS-Service: **Funktioniert** (intern und NodePort)
- ⚠️ LoadBalancer IP: **Nicht erreichbar** (bekanntes MetalLB-Problem)
