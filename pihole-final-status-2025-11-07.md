# Pi-hole Final Status

**Datum**: 2025-11-07  
**Status**: ✅ Pod läuft, ⚠️ LoadBalancer IP noch nicht erreichbar

## Erfolgreich gelöst

### ✅ Problem 1: Pi-hole Pod kann nicht starten - GELÖST

**Ursache**: `Insufficient CPU` - Node hatte 100% CPU-Requests zugewiesen

**Lösung**:
1. **Jellyfin CPU reduziert**: `2000m` → `1500m` (500m freigegeben)
2. **Jellyfin Memory reduziert**: `12Gi` → `10Gi` (2Gi freigegeben)
3. **GitLab CPU reduziert**: `200m` → `100m` (100m freigegeben)
4. **Pi-hole konfiguriert**: `100m` CPU Request, `256Mi` Memory Request

**Ergebnis**: ✅ Pi-hole Pod läuft jetzt (`1/1 Running`)

### ✅ Problem 2: DNS-Service funktioniert

**Status**:
- ✅ Pod läuft (`pihole-575c6d9cf9-4kkc8`)
- ✅ Endpoints vorhanden (`10.244.0.129:53,10.244.0.129:80`)
- ✅ DNS funktioniert intern (Pod kann DNS-Abfragen beantworten)
- ✅ NodePort funktioniert (`dig @192.168.178.54 -p 30221 google.de`)

## Verbleibendes Problem

### ⚠️ LoadBalancer IP nicht erreichbar

**Status**: 
- ✅ LoadBalancer IP zugewiesen (`192.168.178.10/32` auf eth0)
- ✅ Service Status zeigt IP (`status.loadBalancer.ingress[0].ip: 192.168.178.10`)
- ✅ MetalLB Speaker läuft
- ❌ DNS-Abfragen zu `192.168.178.10` timeout
- ❌ HTTP-Abfragen zu `http://192.168.178.10` timeout

**Mögliche Ursachen**:
1. MetalLB L2 Advertisement sendet keine ARP-Announcements
2. Netzwerk-Konfiguration (br0 vs eth0)
3. Firewall-Regeln blockieren Traffic
4. MetalLB IP-Pool-Konfiguration

**Workaround**: NodePort funktioniert (`192.168.178.54:30221` für DNS)

## Durchgeführte Änderungen

### 1. Jellyfin Deployment (`k8s/jellyfin/deployment.yaml`)

```yaml
resources:
  limits:
    cpu: "4"           # Unverändert (kann bei Bedarf bursten)
    memory: 16Gi       # Unverändert
  requests:
    cpu: 1500m        # Reduziert von 2000m (500m freigegeben)
    memory: 10Gi       # Reduziert von 12Gi (2Gi freigegeben)
```

### 2. Pi-hole Deployment (`k8s/pihole/deployment.yaml`)

```yaml
resources:
  requests:
    memory: "256Mi"    # Angemessen für DNS-Service
    cpu: "100m"        # Angemessen für DNS-Performance
  limits:
    memory: "512Mi"    # Limit für Spitzenlast
    cpu: "300m"        # Limit für Spitzenlast
```

### 3. GitLab Deployment

- CPU Request: `200m` → `100m` (reduziert)

## Aktueller Status

- ✅ Pi-hole Pod: **Running** (`pihole-575c6d9cf9-4kkc8`)
- ✅ DNS-Service: **Funktioniert** (intern und NodePort)
- ✅ Endpoints: **Vorhanden** (`10.244.0.129:53,10.244.0.129:80`)
- ⚠️ LoadBalancer IP: **Nicht erreichbar** (bekanntes MetalLB-Problem)

## Empfehlungen

1. **Kurzfristig**: NodePort verwenden (`192.168.178.54:30221` für DNS)
2. **Mittelfristig**: MetalLB L2 Advertisement prüfen und korrigieren
3. **Langfristig**: HostNetwork-Modus für Pi-hole erwägen (falls LoadBalancer weiterhin nicht funktioniert)

## Test-Ergebnisse

### ✅ Funktionierende Zugriffe

- **Intern (Pod)**: `dig @127.0.0.1 google.de` → ✅ Funktioniert
- **Pod IP**: `dig @10.244.0.129 google.de` → ✅ Funktioniert
- **NodePort**: `dig @192.168.178.54 -p 30221 google.de` → ✅ Funktioniert

### ❌ Nicht funktionierende Zugriffe

- **LoadBalancer IP**: `dig @192.168.178.10 google.de` → ❌ Timeout
- **HTTP LoadBalancer**: `curl http://192.168.178.10/admin/` → ❌ Timeout

## Nächste Schritte

1. MetalLB L2 Advertisement prüfen
2. ARP-Announcements prüfen
3. Netzwerk-Konfiguration prüfen
4. Eventuell HostNetwork-Modus testen

