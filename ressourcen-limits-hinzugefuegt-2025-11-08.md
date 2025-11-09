# Ressourcen-Limits hinzugefügt - 2025-11-08

## ✅ Durchgeführte Änderungen

Ressourcen-Limits wurden für alle Pods ohne Limits hinzugefügt, um unbegrenzten Ressourcen-Verbrauch zu verhindern.

---

## 📊 Aktualisierte Deployments/StatefulSets

### 1. PlantUML
- **Namespace**: `default`
- **Requests**: 10m CPU / 128Mi Memory (reduziert von 50m CPU)
- **Limits**: 500m CPU / 512Mi Memory
- **Aktuelle Nutzung**: 2m CPU / 262Mi Memory

### 2. GitLab Agent
- **Namespace**: `gitlab-agent`
- **Requests**: 10m CPU / 64Mi Memory (reduziert von 50m CPU)
- **Limits**: 200m CPU / 128Mi Memory
- **Aktuelle Nutzung**: 1m CPU / 25Mi Memory

### 3. Heimdall
- **Namespace**: `heimdall`
- **Requests**: 10m CPU / 128Mi Memory (reduziert von 50m CPU)
- **Limits**: 500m CPU / 512Mi Memory
- **Aktuelle Nutzung**: 1m CPU / 158Mi Memory

### 4. Komga
- **Namespace**: `komga`
- **Requests**: 50m CPU / 256Mi Memory (reduziert von 100m CPU)
- **Limits**: 1000m CPU / 1Gi Memory
- **Aktuelle Nutzung**: 3m CPU / 487Mi Memory

### 5. Kubernetes Dashboard
- **Namespace**: `kubernetes-dashboard`
- **Requests**: 10m CPU / 64Mi Memory (reduziert von 50m CPU)
- **Limits**: 200m CPU / 256Mi Memory
- **Aktuelle Nutzung**: 1m CPU / 38Mi Memory

### 6. Loki
- **Namespace**: `logging`
- **Requests**: 50m CPU / 128Mi Memory (reduziert von 100m CPU)
- **Limits**: 1000m CPU / 512Mi Memory
- **Aktuelle Nutzung**: 5m CPU / 47Mi Memory

### 7. Grafana
- **Namespace**: `monitoring`
- **Requests**: 50m CPU / 128Mi Memory (reduziert von 100m CPU)
- **Limits**: 1000m CPU / 512Mi Memory
- **Aktuelle Nutzung**: 5m CPU / 111Mi Memory

### 8. Grafana Test
- **Namespace**: `monitoring`
- **Requests**: 10m CPU / 32Mi Memory
- **Limits**: 100m CPU / 128Mi Memory
- **Aktuelle Nutzung**: 0m CPU / 10Mi Memory

### 9. Prometheus
- **Namespace**: `monitoring`
- **Requests**: 100m CPU / 256Mi Memory (reduziert von 200m CPU)
- **Limits**: 2000m CPU / 2Gi Memory
- **Aktuelle Nutzung**: 7m CPU / 63Mi Memory

### 10. Syncthing
- **Namespace**: `syncthing`
- **Requests**: 10m CPU / 64Mi Memory (reduziert von 50m CPU)
- **Limits**: 500m CPU / 256Mi Memory
- **Aktuelle Nutzung**: 2m CPU / 33Mi Memory

### 11. ArgoCD ApplicationSet Controller
- **Namespace**: `argocd`
- **Requests**: 10m CPU / 256Mi Memory (reduziert von 50m CPU)
- **Limits**: 500m CPU / 512Mi Memory

### 12. Velero
- **Namespace**: `default`
- **Requests**: 10m CPU / 512Mi Memory (reduziert von 50m CPU)
- **Limits**: 1000m CPU / 1Gi Memory

### 13. Test Nginx
- **Namespace**: `test-tls`
- **Requests**: 10m CPU / 32Mi Memory
- **Limits**: 100m CPU / 128Mi Memory

---

## 📈 Ressourcen-Verteilung nach Update

### Vorher
- **CPU Requests**: 3950m (98% von 4000m) ⚠️
- **CPU Limits**: 15400m (385%)
- **Memory Requests**: 19796 Mi (62%)
- **Memory Limits**: 32000 Mi (100%)

### Nachher
- **CPU Requests**: 4 (100% von 4000m) ⚠️ **Vollständig belegt**
- **CPU Limits**: 15900m (397%)
- **Memory Requests**: 19924 Mi (62%)
- **Memory Limits**: 32512 Mi (102%)

---

## ⚠️ Wichtige Hinweise

### CPU Requests bei 100%
- **Status**: Alle CPU-Requests sind belegt
- **Problem**: Keine neuen Pods mit CPU-Requests können gestartet werden
- **Lösung**: 
  - CPU-Requests für weniger kritische Pods weiter reduzieren
  - Oder: Node erweitern (mehr CPU)
  - Oder: Bestehende Pods ohne CPU-Requests behalten (nur Limits)

### Memory Limits bei 102%
- **Status**: Memory-Limits überschreiten verfügbaren Memory
- **Problem**: Overcommitment - nicht alle Limits können gleichzeitig genutzt werden
- **Hinweis**: Normal für Development/Home-Umgebungen, aber sollte überwacht werden

---

## 🔍 Verbleibende Pods ohne Limits

Die folgenden Pods haben noch keine Limits (System-Pods oder StatefulSets mit mehreren Containern):

1. **GitLab PostgreSQL** (`gitlab-postgresql-0`) - StatefulSet
2. **GitLab Redis Master** (`gitlab-redis-master-0`) - StatefulSet
3. **Ingress Controller** (`ingress-nginx-controller`) - Hat bereits Requests, aber keine Limits
4. **Kube Flannel** (`kube-flannel-ds-snnjb`) - System-Pod
5. **etcd** (`etcd-zuhause`) - System-Pod
6. **Kube Proxy** (`kube-proxy-bl2f8`) - System-Pod
7. **Metrics Server** (`metrics-server-694c6646d7-clq6x`) - Hat bereits Requests, aber keine Limits

**Empfehlung**: Diese Pods können Limits erhalten, aber System-Pods sollten vorsichtig behandelt werden.

---

## ✅ Erfolgreich aktualisiert

**13 Deployments/StatefulSets** wurden mit Ressourcen-Limits aktualisiert:

- ✅ Alle Limits basieren auf aktueller Nutzung + Puffer
- ✅ Requests wurden reduziert, um CPU-Platz zu schaffen
- ✅ Memory-Limits sind angemessen für die aktuelle Nutzung

---

## 📊 Zusammenfassung

**Status**: ✅ **Limits erfolgreich hinzugefügt**

**Ergebnis**:
- ✅ **13 Pods** haben jetzt Limits
- ⚠️ **CPU Requests**: 100% belegt (kein Platz für neue Pods)
- ✅ **Memory Limits**: 102% (Overcommitment, aber akzeptabel)

**Nächste Schritte**:
1. CPU-Requests für weniger kritische Pods weiter reduzieren
2. Verbleibende Pods ohne Limits prüfen (GitLab PostgreSQL, Redis, etc.)
3. Ressourcen-Überwachung einrichten

---

**Erstellt**: 2025-11-08 19:15 CET

