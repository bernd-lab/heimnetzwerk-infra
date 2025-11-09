# Handover-Dokument: Monitoring-Setup & Offene To-Dos

**Erstellt:** 2025-11-09  
**Status:** In Arbeit  
**Zweck:** Vollständiges Monitoring-Setup mit Prometheus, Grafana, Alertmanager und Discord-Integration

---

## 📋 Executive Summary

Dieses Handover dokumentiert den aktuellen Stand des Monitoring-Setups und alle offenen To-Dos, die für die vollständige Implementierung noch ausstehen.

### Was wurde bereits umgesetzt:

✅ **ArgoCD Sync**: Alle OutOfSync Applications wurden synchronisiert  
✅ **ServiceMonitors**: CRDs installiert und ServiceMonitors für CoreDNS, Cert-Manager, nginx-ingress, ArgoCD, Velero, Kubelet erstellt  
✅ **Node Exporter**: DaemonSet für Node-Metriken deployed  
✅ **Kube-State-Metrics**: Deployment für Kubernetes Resource-Metriken deployed  
✅ **Prometheus Config**: Erweitert mit Service Discovery für alle neuen Targets  
✅ **Alertmanager**: Deployment, Service, PVC, ConfigMap und Ingress erstellt  
✅ **Discord Integration**: Webhook-URL konfiguriert (muss noch getestet werden)  
✅ **PrometheusRules**: 3 Regel-Sets erstellt (Kubernetes, Services, Infrastructure)  
✅ **Grafana Dashboards**: Standard-Dashboards heruntergeladen und ConfigMaps erstellt  

### Was noch offen ist:

⚠️ **Grafana Dashboard Provisioning**: Dashboards müssen noch korrekt in Grafana eingebunden werden  
⚠️ **Discord Webhook Test**: Alertmanager muss getestet werden, ob Discord-Benachrichtigungen funktionieren  
⚠️ **Custom Dashboards**: Weitere Custom-Dashboards für spezifische Services müssen erstellt werden  
⚠️ **Dashboard-Verifikation**: Alle Dashboards müssen im Browser geprüft werden, ob sie echte Daten anzeigen  
⚠️ **ArgoCD Application**: Monitoring-Stack muss als ArgoCD Application registriert werden  

---

## 🔧 Aktueller Status der Komponenten

### Prometheus
- **Namespace:** `monitoring`
- **Status:** ✅ Running
- **ConfigMap:** `prometheus-config` (erweitert mit Service Discovery)
- **Targets:** 
  - Kubernetes API Server
  - Kubernetes Nodes
  - Kubernetes Pods (via annotations)
  - Node Exporter
  - Kube-State-Metrics
  - CoreDNS
  - Cert-Manager
  - nginx-ingress
  - ArgoCD
  - Velero
  - Kubelet

### Grafana
- **Namespace:** `monitoring`
- **Status:** ✅ Running (neues Deployment mit Dashboard-Volumes)
- **URL:** https://grafana.k8sops.online
- **Credentials:** `admin` / `Montag69`
- **Dashboards:** 
  - Standard-Dashboards als ConfigMaps erstellt
  - Dashboard Provisioning ConfigMap erstellt
  - **Problem:** Dashboards müssen noch korrekt eingebunden werden

### Alertmanager
- **Namespace:** `monitoring`
- **Status:** ⚠️ Pending (PVC wird erstellt)
- **URL:** https://alertmanager.k8sops.online (wird erstellt)
- **Discord Webhook:** Konfiguriert
- **Problem:** Discord-Integration muss getestet werden (Alertmanager unterstützt Discord nicht nativ, benötigt Webhook-Adapter)

### Node Exporter
- **Namespace:** `monitoring`
- **Status:** ✅ Running (DaemonSet)
- **Port:** 9100 (hostNetwork)

### Kube-State-Metrics
- **Namespace:** `monitoring`
- **Status:** ✅ Running
- **Port:** 8080

### ServiceMonitors
- **Status:** ✅ Installiert
- **CRDs:** ✅ Installiert
- **ServiceMonitors:**
  - coredns
  - cert-manager
  - nginx-ingress
  - argocd
  - velero
  - kubelet

### PrometheusRules
- **Status:** ✅ Installiert
- **Regel-Sets:**
  - `kubernetes-alerts` - Pod/Node/Deployment Alerts
  - `services-alerts` - Service Down, DNS, Ingress, Certificate Alerts
  - `infrastructure-alerts` - Network, Disk I/O, Container Resource Alerts

---

## 🚨 Kritische Offene To-Dos

### TODO 1: Grafana Dashboard Provisioning korrigieren

**Status:** ⚠️ In Arbeit  
**Priorität:** Hoch  
**Agent:** `/monitoring-expert`

**Problem:**
- Dashboard ConfigMaps wurden erstellt, aber Grafana lädt sie nicht automatisch
- Dashboard Provisioning ConfigMap existiert, aber Volumes sind nicht korrekt konfiguriert
- Dashboards müssen manuell importiert oder Provisioning korrigiert werden

**Lösungsschritte:**

1. **Grafana Deployment prüfen:**
   ```bash
   kubectl get deployment grafana -n monitoring -o yaml | grep -A 20 "volumes:"
   kubectl get deployment grafana -n monitoring -o yaml | grep -A 20 "volumeMounts:"
   ```

2. **Dashboard Provisioning korrigieren:**
   - Grafana erwartet Dashboards in `/var/lib/grafana/dashboards/`
   - Provisioning ConfigMap muss in `/etc/grafana/provisioning/dashboards/` gemountet werden
   - Dashboard ConfigMaps müssen als Volumes gemountet werden

3. **Korrekte Konfiguration:**
   ```yaml
   # Grafana Deployment muss haben:
   volumeMounts:
   - name: dashboard-provisioning
     mountPath: /etc/grafana/provisioning/dashboards
   - name: dashboards
     mountPath: /var/lib/grafana/dashboards
   
   volumes:
   - name: dashboard-provisioning
     configMap:
       name: grafana-dashboard-provisioning
   - name: dashboards
     emptyDir: {}
   # Oder: Alle Dashboard ConfigMaps als einzelne Volumes
   ```

4. **Alternative: Manueller Import**
   - Falls Provisioning nicht funktioniert, Dashboards manuell über Grafana UI importieren
   - Dashboard JSONs sind in ConfigMaps verfügbar

5. **Verifikation:**
   - In Grafana UI: Dashboards → Browse
   - Alle Dashboards sollten sichtbar sein
   - Dashboards öffnen und prüfen, ob Metriken geladen werden

**Dateien:**
- `k8s/monitoring/grafana/dashboard-provisioning.yaml`
- `k8s/monitoring/grafana/dashboards/standard/*.yaml`
- `k8s/monitoring/grafana/dashboards/custom/*.yaml`

**Befehle:**
```bash
# Grafana Deployment prüfen
kubectl get deployment grafana -n monitoring -o yaml > /tmp/grafana-deployment.yaml

# Dashboard ConfigMaps prüfen
kubectl get configmap -n monitoring | grep grafana-dashboard

# Grafana Logs prüfen
kubectl logs -n monitoring -l app=grafana --tail=100 | grep -i dashboard
```

---

### TODO 2: Discord Webhook-Integration für Alertmanager

**Status:** ⚠️ Konfiguriert, aber nicht getestet  
**Priorität:** Hoch  
**Agent:** `/monitoring-expert`

**Problem:**
- Alertmanager unterstützt Discord nicht nativ
- Aktuelle Konfiguration verwendet `webhook_configs`, was nicht direkt mit Discord funktioniert
- Benötigt Discord-Webhook-Adapter oder korrekte Webhook-Payload-Formatierung

**Lösungsschritte:**

1. **Option A: Discord-Webhook-Adapter deployen**
   - Deployment eines Discord-Webhook-Adapters zwischen Alertmanager und Discord
   - Oder: Verwendung eines bestehenden Adapters wie `prometheus-discord-webhook`

2. **Option B: Alertmanager Webhook-Template erstellen**
   - Discord-Webhook erwartet spezifisches JSON-Format
   - Alertmanager Webhook-Template erstellen, das Discord-Format generiert

3. **Discord Webhook Format:**
   ```json
   {
     "content": "Alert: {{ .GroupLabels.alertname }}",
     "embeds": [{
       "title": "{{ .GroupLabels.alertname }}",
       "description": "{{ range .Alerts }}{{ .Annotations.description }}{{ end }}",
       "color": 15158332
     }]
   }
   ```

4. **Test-Alert auslösen:**
   ```bash
   # Test-Alert in Prometheus manuell auslösen
   curl -X POST http://prometheus.monitoring.svc:9090/api/v1/alerts \
     -H "Content-Type: application/json" \
     -d '[{
       "labels": {"alertname": "TestAlert", "severity": "warning"},
       "annotations": {"description": "Test alert for Discord"},
       "startsAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
     }]'
   ```

5. **Alertmanager Logs prüfen:**
   ```bash
   kubectl logs -n monitoring -l app=alertmanager --tail=100 | grep -i discord
   ```

**Dateien:**
- `k8s/monitoring/alertmanager/configmap.yaml`
- `k8s/monitoring/alertmanager/secret.yaml`

**Discord Webhook URL:**
```
https://discord.com/api/webhooks/1434373123225948180/fI_jDJabe9f9DRy1WKAzL4E5CevlToCrprF7kb-_icM2DMa7sUFu6vVMJ4iZGxH47OUs
```

**Referenzen:**
- [Prometheus Discord Webhook](https://promlabs.com/blog/2022/12/23/sending-prometheus-alerts-to-discord-with-alertmanager-v0-25-0/)
- Discord Webhook API Dokumentation

---

### TODO 3: Custom Dashboards für spezifische Services erstellen

**Status:** ⚠️ Teilweise erstellt  
**Priorität:** Mittel  
**Agent:** `/monitoring-expert`

**Fehlende Dashboards:**

1. **Pi-hole Dashboard**
   - DNS Queries (Total, Blocked, Allowed)
   - Top Blocked Domains
   - Upstream DNS Response Times
   - Query Types Distribution
   - **Problem:** Pi-hole Metriken-Endpunkt muss erst geprüft werden

2. **ArgoCD Dashboard**
   - Applications Status (Synced/OutOfSync)
   - Health Status
   - Sync Durations
   - Git Repository Status
   - **Metriken:** ArgoCD Server Metriken-Endpunkt prüfen

3. **GitLab Dashboard**
   - CI/CD Pipeline Status
   - Runner Status
   - Repository Statistics
   - **Problem:** GitLab Metriken-Endpunkt muss geprüft werden

4. **Media Services Dashboard**
   - Jellyfin: Active Streams, Users, Storage Usage
   - Komga: Library Statistics, Reading Activity
   - **Problem:** Metriken-Endpunkte müssen geprüft werden

5. **Syncthing Dashboard**
   - Sync Status per Device
   - Transfer Rates
   - File Counts
   - **Problem:** Syncthing Metriken-Endpunkt muss geprüft werden

6. **Velero Dashboard**
   - Backup Status
   - Backup Durations
   - Restore Operations
   - Storage Usage

**Lösungsschritte:**

1. **Metriken-Endpunkte prüfen:**
   ```bash
   # Pi-hole
   kubectl port-forward -n pihole svc/pihole 8080:80
   curl http://localhost:8080/admin/api.php?summaryRaw
   
   # ArgoCD
   kubectl port-forward -n argocd svc/argocd-server 8080:80
   curl http://localhost:8080/metrics
   
   # GitLab
   kubectl port-forward -n gitlab svc/gitlab 8080:80
   curl http://localhost:8080/-/metrics
   ```

2. **ServiceMonitors für Services ohne Metriken erstellen:**
   - Falls Services keine Metriken-Endpunkte haben, müssen diese erst aktiviert werden
   - Oder: Exporter für diese Services deployen

3. **Dashboard JSONs erstellen:**
   - Basierend auf verfügbaren Metriken
   - Grafana Dashboard Editor verwenden oder JSON manuell erstellen

4. **Dashboard ConfigMaps erstellen:**
   - Wie bei Standard-Dashboards
   - In `k8s/monitoring/grafana/dashboards/custom/`

**Dateien:**
- `k8s/monitoring/grafana/dashboards/custom/pihole-dashboard.yaml` (zu erstellen)
- `k8s/monitoring/grafana/dashboards/custom/argocd-dashboard.yaml` (zu erstellen)
- `k8s/monitoring/grafana/dashboards/custom/gitlab-dashboard.yaml` (zu erstellen)
- `k8s/monitoring/grafana/dashboards/custom/media-services-dashboard.yaml` (zu erstellen)
- `k8s/monitoring/grafana/dashboards/custom/syncthing-dashboard.yaml` (zu erstellen)
- `k8s/monitoring/grafana/dashboards/custom/velero-dashboard.yaml` (zu erstellen)

---

### TODO 4: Dashboard-Verifikation im Browser

**Status:** ⚠️ Nicht durchgeführt  
**Priorität:** Hoch  
**Agent:** `/monitoring-expert`

**Aufgabe:**
- Alle Dashboards in Grafana öffnen
- Prüfen, ob Metriken geladen werden (keine "No Data" Meldungen)
- Prüfen, ob Queries funktionieren
- Dummy-Daten identifizieren und entfernen/ersetzen

**Checkliste:**

1. **Standard-Dashboards prüfen:**
   - [ ] Kubernetes Cluster Monitoring (7249)
   - [ ] Node Exporter Full (1860)
   - [ ] Kubernetes Pods (6417)
   - [ ] Kubernetes Deployment (8588)
   - [ ] Kubernetes Kubelet (6671)
   - [ ] Prometheus Stats (2)
   - [ ] Prometheus 2.0 Stats (3662)
   - [ ] Alertmanager (9578)
   - [ ] Nginx Ingress Controller (9614)

2. **Custom-Dashboards prüfen:**
   - [ ] Infrastructure Overview
   - [ ] Pi-hole Dashboard (wenn erstellt)
   - [ ] ArgoCD Dashboard (wenn erstellt)
   - [ ] GitLab Dashboard (wenn erstellt)
   - [ ] Media Services Dashboard (wenn erstellt)
   - [ ] Syncthing Dashboard (wenn erstellt)
   - [ ] Velero Dashboard (wenn erstellt)

3. **Für jedes Dashboard prüfen:**
   - Metriken werden geladen (keine "No Data")
   - Queries funktionieren (keine Fehler in Browser Console)
   - Zeitbereich funktioniert (Last 5 minutes, Last 1 hour, etc.)
   - Refresh funktioniert
   - Keine Dummy-Daten

**Befehle:**
```bash
# Grafana URL öffnen
# https://grafana.k8sops.online
# Login: admin / Montag69

# Prometheus Targets prüfen
curl -k https://prometheus.k8sops.online/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'
```

**Dateien:**
- `k8s/monitoring/grafana/dashboards/verification.md` (zu erstellen)

---

### TODO 5: ArgoCD Application für Monitoring-Stack

**Status:** ⚠️ Nicht erstellt  
**Priorität:** Mittel  
**Agent:** `/gitops-expert`

**Aufgabe:**
- ArgoCD Application für den gesamten Monitoring-Stack erstellen
- Auto-Sync aktivieren
- Alle Monitoring-Komponenten unter GitOps-Management bringen

**Lösungsschritte:**

1. **ArgoCD Application erstellen:**
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: monitoring
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/bernd-lab/heimnetzwerk-infra.git
       targetRevision: main
       path: k8s/monitoring
     destination:
       server: https://kubernetes.default.svc
       namespace: monitoring
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
       - CreateNamespace=true
   ```

2. **Kustomization für Monitoring-Stack:**
   - `k8s/monitoring/kustomization.yaml` erstellen
   - Alle Komponenten einbinden:
     - prometheus/
     - grafana/
     - alertmanager/
     - node-exporter/
     - kube-state-metrics/
     - prometheus/servicemonitors/
     - prometheus/prometheusrules/

3. **Application registrieren:**
   ```bash
   kubectl apply -f k8s/monitoring/argocd-application.yaml
   ```

**Dateien:**
- `k8s/monitoring/argocd-application.yaml` (zu erstellen)
- `k8s/monitoring/kustomization.yaml` (zu erstellen)

---

### TODO 6: Alertmanager Discord-Webhook-Adapter

**Status:** ⚠️ Nicht implementiert  
**Priorität:** Hoch  
**Agent:** `/monitoring-expert`

**Problem:**
- Alertmanager sendet Webhooks im Prometheus-Format
- Discord erwartet spezifisches JSON-Format
- Benötigt Adapter oder Template

**Lösungsoptionen:**

**Option A: Discord-Webhook-Adapter Deployment**
- Deployment eines Adapters zwischen Alertmanager und Discord
- Beispiel: `prometheus-discord-webhook` oder ähnlicher Adapter

**Option B: Alertmanager Webhook-Template**
- Alertmanager unterstützt Templates für Webhooks
- Template erstellen, das Discord-Format generiert

**Option C: Externer Webhook-Service**
- Kleiner Service, der Prometheus-Alerts empfängt und an Discord weiterleitet

**Empfohlene Lösung:**
- Option B: Alertmanager Webhook-Template verwenden
- Template in ConfigMap speichern
- Alertmanager ConfigMap erweitern mit Template-Pfad

**Dateien:**
- `k8s/monitoring/alertmanager/webhook-template.yaml` (zu erstellen)
- `k8s/monitoring/alertmanager/configmap.yaml` (zu aktualisieren)

**Referenzen:**
- [Alertmanager Webhook Templates](https://prometheus.io/docs/alerting/latest/configuration/#webhook_config)
- [Discord Webhook Format](https://discord.com/developers/docs/resources/webhook)

---

## 📁 Dateistruktur

### Erstellte Dateien:

```
k8s/monitoring/
├── prometheus/
│   ├── configmap.yaml (erweitert)
│   └── servicemonitors/
│       ├── coredns.yaml
│       ├── cert-manager.yaml
│       ├── nginx-ingress.yaml
│       ├── argocd.yaml
│       ├── velero.yaml
│       ├── kubelet.yaml
│       └── kustomization.yaml
│   └── prometheusrules/
│       ├── kubernetes.yaml
│       ├── services.yaml
│       ├── infrastructure.yaml
│       └── kustomization.yaml
├── grafana/
│   ├── dashboard-provisioning.yaml
│   └── dashboards/
│       ├── standard/
│       │   ├── k8s-cluster-monitoring.yaml
│       │   ├── node-exporter-full.yaml
│       │   ├── k8s-pods.yaml
│       │   ├── k8s-deployment.yaml
│       │   ├── k8s-kubelet.yaml
│       │   ├── prometheus-stats.yaml
│       │   ├── prometheus-2-stats.yaml
│       │   ├── alertmanager.yaml
│       │   └── nginx-ingress.yaml
│       └── custom/
│           └── infrastructure-overview.yaml
├── alertmanager/
│   ├── namespace.yaml
│   ├── secret.yaml
│   ├── configmap.yaml
│   ├── pvc.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── certificate.yaml
│   ├── ingress.yaml
│   └── kustomization.yaml
├── node-exporter/
│   ├── namespace.yaml
│   ├── daemonset.yaml
│   ├── service.yaml
│   └── kustomization.yaml
└── kube-state-metrics/
    ├── namespace.yaml
    ├── serviceaccount.yaml
    ├── clusterrole.yaml
    ├── clusterrolebinding.yaml
    ├── deployment.yaml
    ├── service.yaml
    └── kustomization.yaml
```

### Fehlende Dateien:

- `k8s/monitoring/argocd-application.yaml`
- `k8s/monitoring/kustomization.yaml`
- `k8s/monitoring/alertmanager/webhook-template.yaml`
- `k8s/monitoring/grafana/dashboards/custom/pihole-dashboard.yaml`
- `k8s/monitoring/grafana/dashboards/custom/argocd-dashboard.yaml`
- `k8s/monitoring/grafana/dashboards/custom/gitlab-dashboard.yaml`
- `k8s/monitoring/grafana/dashboards/custom/media-services-dashboard.yaml`
- `k8s/monitoring/grafana/dashboards/custom/syncthing-dashboard.yaml`
- `k8s/monitoring/grafana/dashboards/custom/velero-dashboard.yaml`
- `k8s/monitoring/grafana/dashboards/verification.md`

---

## 🔍 Debugging & Troubleshooting

### Prometheus Targets prüfen:

```bash
# Alle Targets anzeigen
curl -k https://prometheus.k8sops.online/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health, lastError: .lastError}'

# Fehlerhafte Targets
curl -k https://prometheus.k8sops.online/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'
```

### Grafana Logs prüfen:

```bash
# Grafana Pod Logs
kubectl logs -n monitoring -l app=grafana --tail=100

# Dashboard Provisioning Fehler
kubectl logs -n monitoring -l app=grafana --tail=100 | grep -i dashboard
```

### Alertmanager Logs prüfen:

```bash
# Alertmanager Pod Logs
kubectl logs -n monitoring -l app=alertmanager --tail=100

# Webhook-Fehler
kubectl logs -n monitoring -l app=alertmanager --tail=100 | grep -i webhook
```

### ServiceMonitors prüfen:

```bash
# Alle ServiceMonitors
kubectl get servicemonitors -n monitoring

# ServiceMonitor Details
kubectl describe servicemonitor <name> -n monitoring
```

### PrometheusRules prüfen:

```bash
# Alle PrometheusRules
kubectl get prometheusrules -n monitoring

# PrometheusRules Details
kubectl describe prometheusrule <name> -n monitoring

# Alerts in Prometheus prüfen
curl -k https://prometheus.k8sops.online/api/v1/alerts | jq '.data.alerts[]'
```

---

## 📝 Wichtige Befehle

### Monitoring-Stack Status:

```bash
# Alle Pods
kubectl get pods -n monitoring

# Alle Services
kubectl get svc -n monitoring

# Alle ConfigMaps
kubectl get configmap -n monitoring

# Alle PVCs
kubectl get pvc -n monitoring
```

### Prometheus:

```bash
# Prometheus Config prüfen
kubectl get configmap prometheus-config -n monitoring -o yaml

# Prometheus Targets
curl -k https://prometheus.k8sops.online/api/v1/targets

# Prometheus Alerts
curl -k https://prometheus.k8sops.online/api/v1/alerts

# Prometheus Query
curl -k "https://prometheus.k8sops.online/api/v1/query?query=up"
```

### Grafana:

```bash
# Grafana Deployment prüfen
kubectl get deployment grafana -n monitoring -o yaml

# Grafana Logs
kubectl logs -n monitoring -l app=grafana --tail=100

# Dashboard ConfigMaps
kubectl get configmap -n monitoring | grep grafana-dashboard
```

### Alertmanager:

```bash
# Alertmanager Status
kubectl get pods -n monitoring -l app=alertmanager

# Alertmanager Config
kubectl get configmap alertmanager-config -n monitoring -o yaml

# Alertmanager Logs
kubectl logs -n monitoring -l app=alertmanager --tail=100
```

---

## 🎯 Nächste Schritte für Agents

### Für `/monitoring-expert`:

1. **Grafana Dashboard Provisioning korrigieren** (TODO 1)
2. **Discord Webhook-Integration testen und korrigieren** (TODO 2)
3. **Custom Dashboards erstellen** (TODO 3)
4. **Dashboard-Verifikation im Browser** (TODO 4)

### Für `/gitops-expert`:

1. **ArgoCD Application für Monitoring-Stack erstellen** (TODO 5)
2. **Kustomization für Monitoring-Stack erstellen**

### Für `/k8s-expert`:

1. **ArgoCD OutOfSync Applications analysieren** (falls weiterhin OutOfSync)
2. **Alertmanager PVC-Problem beheben** (falls Pod weiterhin Pending)

---

## 🔗 Wichtige URLs

- **Grafana:** https://grafana.k8sops.online (admin / Montag69)
- **Prometheus:** https://prometheus.k8sops.online
- **Alertmanager:** https://alertmanager.k8sops.online (wird erstellt)
- **ArgoCD:** https://argocd.k8sops.online (admin / Montag69)

---

## 📚 Referenzen

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Dashboard Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)
- [Alertmanager Webhook Configuration](https://prometheus.io/docs/alerting/latest/configuration/#webhook_config)
- [Discord Webhook API](https://discord.com/developers/docs/resources/webhook)
- [Prometheus Discord Webhook Blog](https://promlabs.com/blog/2022/12/23/sending-prometheus-alerts-to-discord-with-alertmanager-v0-25-0/)

---

**Ende des Handover-Dokuments**

*Letzte Aktualisierung: 2025-11-09*

