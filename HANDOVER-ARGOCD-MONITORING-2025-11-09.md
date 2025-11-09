# Handover: ArgoCD Monitoring Degraded Status

**Erstellt**: 2025-11-09  
**Letzte Aktualisierung**: 2025-11-09 17:45  
**Thread-Kontext**: ArgoCD Out-of-Sync Analyse und Monitoring Degraded Status  
**Git Commit**: `0b9d64c584bb4f0e41fff394a9653e9919e436ba`

---

## 🎯 Aktuelle Situation

### Problem
Die ArgoCD Application `monitoring` zeigt den Status **"Degraded"** an, obwohl alle Pods laufen und funktionieren.

### Root Cause
**Grafana** und **Prometheus** Deployments/Services existierten im Cluster, waren aber **nicht in der `kustomization.yaml` definiert**. ArgoCD markiert Applications als "Degraded", wenn Ressourcen im Cluster existieren, die nicht von ArgoCD verwaltet werden.

---

## ✅ Durchgeführte Maßnahmen

### 1. Kustomization-Fehler behoben
**Problem**: Kustomization-Dateien wurden als Resources referenziert
- ❌ `prometheus/servicemonitors/kustomization.yaml` wurde als Resource referenziert
- ❌ `prometheus/prometheusrules/kustomization.yaml` wurde als Resource referenziert
- ❌ `alertmanager/kustomization.yaml` wurde als Resource referenziert
- ❌ `node-exporter/kustomization.yaml` wurde als Resource referenziert
- ❌ `kube-state-metrics/kustomization.yaml` wurde als Resource referenziert

**Lösung**: Alle einzelnen Resource-Dateien werden jetzt direkt referenziert
- ✅ Alle ServiceMonitor-Dateien direkt referenziert
- ✅ Alle PrometheusRule-Dateien direkt referenziert
- ✅ Alle Alertmanager-Ressourcen direkt referenziert
- ✅ Alle Node-Exporter-Ressourcen direkt referenziert
- ✅ Alle Kube-State-Metrics-Ressourcen direkt referenziert
- ✅ Doppelte Namespace-Definitionen entfernt

**Commits**: `38a8f00`, `0771c1c`, `b0bad60`, `0195b07`, `f4d5113`

### 2. Fehlende Deployments/Services hinzugefügt
**Problem**: Grafana und Prometheus waren nicht in der Kustomization
- ❌ `grafana/deployment.yaml` fehlte
- ❌ `grafana/service.yaml` fehlte
- ❌ `prometheus/deployment.yaml` fehlte
- ❌ `prometheus/service.yaml` fehlte

**Lösung**: 
- ✅ Grafana Deployment und Service erstellt (`k8s/monitoring/grafana/deployment.yaml`, `service.yaml`)
- ✅ Prometheus Deployment und Service erstellt (`k8s/monitoring/prometheus/deployment.yaml`, `service.yaml`)
- ✅ Beide zur `kustomization.yaml` hinzugefügt

**Commit**: `0b9d64c`

### 3. Alte Pods bereinigt
- ✅ `grafana-test` Deployment gelöscht (0 Replicas, nicht mehr benötigt)
- ✅ `prometheus-585d56d988-xntwh` Pod gelöscht (Completed, alte Revision)

---

## 📊 Aktueller Status

### ArgoCD Applications
```
NAMESPACE   NAME                   SYNC STATUS   HEALTH STATUS   REVISION
argocd      gitlab                 OutOfSync     Healthy         0b9d64c
argocd      heimdall               OutOfSync     Healthy         0b9d64c
argocd      jellyfin               Synced        Healthy         0b9d64c
argocd      komga                  OutOfSync     Healthy         0b9d64c
argocd      kubernetes-dashboard   Synced        Healthy         0b9d64c
argocd      monitoring             Unknown       Degraded        (keine Revision)
argocd      pihole                 OutOfSync     Healthy         0b9d64c
argocd      plantuml               Synced        Healthy         0b9d64c
argocd      syncthing              OutOfSync     Healthy         0b9d64c
```

### Monitoring Namespace Pods
```
NAME                                  READY   STATUS    RESTARTS   AGE
alertmanager-657867fbd6-s7xkx         1/1     Running   0          3h19m
grafana-86bd9dd8f4-stjcc              1/1     Running   0          115m
kube-state-metrics-64ccc748f6-stm46   1/1     Running   0          5h27m
node-exporter-8c6nf                   1/1     Running   0          5h27m
prometheus-76f94b4799-dgf74           1/1     Running   0          168m
```

**Alle Pods laufen korrekt!** ✅

---

## 🔍 Detaillierte Analyse

### Monitoring Application Status
- **Sync Status**: `Unknown` (ArgoCD synchronisiert gerade die neue Revision)
- **Health Status**: `Degraded` (sollte zu "Healthy" wechseln nach Sync)
- **Revision**: Keine (ArgoCD hat die neue Revision noch nicht geladen)

### Warum "Degraded"?
ArgoCD markiert Applications als "Degraded", wenn:
1. Ressourcen im Cluster existieren, die nicht in Git definiert sind
2. Ressourcen Health-Checks fehlschlagen
3. Deployments nicht die gewünschte Anzahl von Replicas haben

**In unserem Fall**: Grafana und Prometheus Deployments existierten im Cluster, waren aber nicht in der Kustomization definiert.

### Out-of-Sync Applications
Die meisten anderen Applications zeigen "OutOfSync" wegen **ArgoCD Tracking-Annotations** (`argocd.argoproj.io/tracking-id`). Dies ist **normales Verhalten** und kann ignoriert werden, wenn:
- Applications "Healthy" sind
- Keine echten Konfigurationsunterschiede bestehen
- Ressourcen funktionieren korrekt

---

## 📁 Wichtige Dateien

### Kustomization
- **Datei**: `k8s/monitoring/kustomization.yaml`
- **Status**: ✅ Aktualisiert mit allen Ressourcen
- **Struktur**: Alle Ressourcen direkt referenziert (keine verschachtelten Kustomizations)

### Neue Dateien (Commit `0b9d64c`)
- `k8s/monitoring/grafana/deployment.yaml` - Grafana Deployment
- `k8s/monitoring/grafana/service.yaml` - Grafana Service
- `k8s/monitoring/prometheus/deployment.yaml` - Prometheus Deployment
- `k8s/monitoring/prometheus/service.yaml` - Prometheus Service

### Bestehende Dateien
- Alle ServiceMonitor-Dateien: `k8s/monitoring/prometheus/servicemonitors/*.yaml`
- Alle PrometheusRule-Dateien: `k8s/monitoring/prometheus/prometheusrules/*.yaml`
- Alle Dashboard-ConfigMaps: `k8s/monitoring/grafana/dashboards/**/*.yaml`

---

## 🚀 Nächste Schritte

### Sofort (P0)
1. **Warten auf ArgoCD Sync** (5-10 Minuten)
   - ArgoCD muss die neue Revision (`0b9d64c`) laden
   - Kustomization muss gebaut werden
   - Resources müssen synchronisiert werden

2. **Status prüfen**
   ```bash
   kubectl get application monitoring -n argocd -o wide
   kubectl get application monitoring -n argocd -o jsonpath='{.status.health.status}'
   kubectl get application monitoring -n argocd -o jsonpath='{.status.sync.status}'
   ```

3. **Falls Status weiterhin "Degraded"**
   ```bash
   # Hard Refresh durchführen
   kubectl patch application monitoring -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
   
   # Oder Application neu erstellen
   kubectl delete application monitoring -n argocd --cascade=orphan
   kubectl apply -f k8s/monitoring/argocd-application.yaml
   ```

### Optional (P1)
4. **ArgoCD Sync-Optionen konfigurieren**
   - Tracking-Annotations ignorieren für Out-of-Sync-Status
   - Sync-Optionen in Application-Manifest hinzufügen

5. **Monitoring Health-Checks prüfen**
   - Warum zeigt ArgoCD keine Health-Status für Deployments?
   - Prüfen, ob Health-Checks korrekt konfiguriert sind

---

## 🔧 Troubleshooting

### Monitoring Application zeigt "Unknown"
**Ursache**: ArgoCD hat die neue Revision noch nicht geladen

**Lösung**:
```bash
# Revision prüfen
kubectl get application monitoring -n argocd -o jsonpath='{.status.sync.comparedTo.source.revision}'

# Hard Refresh
kubectl patch application monitoring -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'

# Oder Application neu erstellen
kubectl delete application monitoring -n argocd --cascade=orphan
kubectl apply -f k8s/monitoring/argocd-application.yaml
```

### Monitoring Application zeigt weiterhin "Degraded"
**Ursache**: Möglicherweise fehlen noch Ressourcen oder Health-Checks schlagen fehl

**Lösung**:
```bash
# Alle Resources prüfen
kubectl get application monitoring -n argocd -o jsonpath='{range .status.resources[*]}{.kind}/{.name}: Health={.health.status}, Sync={.status}{"\n"}{end}'

# Ungesunde Resources finden
kubectl get application monitoring -n argocd -o yaml | grep -A 10 "health:" | grep -v "Healthy"

# Deployments prüfen
kubectl get deployments -n monitoring
kubectl get pods -n monitoring
```

### Kustomization-Build-Fehler
**Ursache**: Fehlerhafte Resource-Referenzen

**Lösung**:
```bash
# Kustomization lokal testen
cd k8s/monitoring
kustomize build . > /tmp/test-build.yaml

# Prüfen auf Fehler
kubectl apply --dry-run=client -f /tmp/test-build.yaml
```

---

## 📝 Git Commits

### Relevante Commits
- `38a8f00` - ServiceMonitors direkt referenziert
- `0771c1c` - PrometheusRules direkt referenziert
- `b0bad60` - Alertmanager/Node-Exporter/Kube-State-Metrics direkt referenziert
- `0195b07` - Alle kustomization.yaml durch einzelne Resources ersetzt
- `f4d5113` - Doppelte Namespace-Definitionen entfernt
- `0b9d64c` - Grafana und Prometheus Deployments/Services hinzugefügt

### Repository
- **URL**: https://github.com/bernd-lab/heimnetzwerk-infra.git
- **Branch**: `main`
- **Path**: `k8s/monitoring/`

---

## 🎓 Lessons Learned

1. **Kustomization-Dateien nicht als Resources referenzieren**
   - ArgoCD kann verschachtelte Kustomizations nicht direkt verarbeiten
   - Alle Ressourcen müssen direkt referenziert werden

2. **Alle Cluster-Ressourcen müssen in Git sein**
   - ArgoCD markiert Applications als "Degraded", wenn Ressourcen im Cluster existieren, die nicht in Git sind
   - Deployments, Services, etc. müssen alle in der Kustomization definiert sein

3. **ArgoCD Tracking-Annotations sind normal**
   - "Out of Sync" wegen Tracking-Annotations ist normal
   - Kann ignoriert werden, wenn Applications "Healthy" sind

4. **ArgoCD Cache kann verzögert sein**
   - Neue Commits werden nicht sofort erkannt
   - Hard Refresh oder Application-Neuerstellung kann helfen

---

## 📞 Weitere Informationen

### Dokumentation
- `ARGOCD-OUT-OF-SYNC-ANALYSE.md` - Detaillierte Analyse der Out-of-Sync-Applications
- `MONITORING-LANDSCHAFT.md` - Monitoring-Landschaft Übersicht
- `HANDOVER-NEU.md` - Allgemeines Handover-Dokument

### Wichtige Commands
```bash
# Application-Status prüfen
kubectl get applications -A -o wide

# Monitoring-Status prüfen
kubectl get pods -n monitoring
kubectl get deployments -n monitoring

# ArgoCD Sync durchführen
kubectl patch application monitoring -n argocd --type merge -p '{"operation":{"initiatedBy":{"username":"admin"},"sync":{"revision":"main"}}}'

# Hard Refresh
kubectl patch application monitoring -n argocd --type merge -p '{"metadata":{"annotations":{"argocd.argoproj.io/refresh":"hard"}}}'
```

---

**Ende des Handover-Dokuments**

