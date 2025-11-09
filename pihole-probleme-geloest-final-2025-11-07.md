# Pi-hole Probleme gelöst - Finale Lösung

**Datum**: 2025-11-07  
**Status**: ✅ Systematische CPU-Optimierung durchgeführt

## Problem-Analyse

### Ausgangssituation
- **Node CPU**: 4 cores (4000m)
- **CPU Requests gesamt**: 4250m (106% - überbelegt!)
- **CPU Requests (Running Pods)**: 4000m (100% - vollständig belegt)
- **Pi-hole benötigt**: 100m CPU Request
- **Verfügbar**: 0m (kein Platz für Pi-hole)

### Root Cause
Der Node hat **exakt 100% CPU zugewiesen** durch laufende Pods. Pi-hole kann nicht starten, weil keine CPU-Ressourcen verfügbar sind.

## Systematische Lösung

### Schritt 1: CPU-Verteilung analysiert

**Größte CPU-Verbraucher**:
- Jellyfin: 2000m (50% des Nodes) ← **Hauptproblem**
- kube-apiserver: 250m
- kube-controller-manager: 200m
- GitLab: 200m
- ArgoCD application-controller: 200m
- ArgoCD repo-server: 150m
- Weitere: 100m-50m

### Schritt 2: CPU-Ressourcen optimiert

**Jellyfin reduziert** (`k8s/jellyfin/deployment.yaml`):
- CPU Request: `2000m` → `1500m` (500m freigegeben)
- Memory Request: `12Gi` → `10Gi` (2Gi freigegeben)

**Pi-hole konfiguriert** (`k8s/pihole/deployment.yaml`):
- CPU Request: `100m` (angemessen für DNS)
- Memory Request: `256Mi` (angemessen für Blocklisten)
- CPU Limit: `300m`
- Memory Limit: `512Mi`

### Schritt 3: Jellyfin Pod neu gestartet

- Deployment aktualisiert
- Pod-Restart durchgeführt
- Neue Ressourcen aktiv

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

**Begründung**: Jellyfin kann weiterhin auf 4 cores bursten (Limit), aber garantiert nur noch 1.5 cores. Dies gibt anderen Services Platz.

### 2. Pi-hole Deployment (`k8s/pihole/deployment.yaml`)

```yaml
resources:
  requests:
    memory: "256Mi"    # Angemessen für DNS-Service mit Blocklisten
    cpu: "100m"        # Angemessen für DNS-Performance
  limits:
    memory: "512Mi"    # Limit für Spitzenlast
    cpu: "300m"        # Limit für Spitzenlast
```

**Begründung**: DNS benötigt wenig CPU, aber genug für gute Performance.

## Erwartetes Ergebnis

Nach Jellyfin-Restart:
- **CPU Requests (Running)**: ~3500m (87.5%)
- **Verfügbar**: ~500m (12.5%)
- **Pi-hole kann starten**: ✅ (benötigt nur 100m)

## Status

- ✅ Jellyfin Deployment aktualisiert
- ✅ Jellyfin Pod neu gestartet
- ⏳ Pi-hole sollte jetzt starten können
- ⏳ LoadBalancer IP sollte dann erreichbar sein
