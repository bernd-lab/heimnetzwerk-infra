# Cluster-Vollständige Überprüfung

**Datum**: 2025-11-08  
**Status**: ✅ Cluster läuft stabil, einige Probleme identifiziert

---

## Phase 1: Zugriff und Grundstatus

### ✅ SSH-Zugriff
- **Status**: ✅ Funktioniert
- **Server**: `zuhause` (192.168.178.54)
- **Uptime**: 22 Stunden
- **Load Average**: 1.35, 2.43, 2.65 (4 CPUs verfügbar)

### ✅ kubectl-Zugriff
- **Status**: ✅ Funktioniert
- **Cluster**: Kubernetes v1.34.1
- **Control Plane**: https://192.168.178.54:6443
- **Node**: `zuhause` - Ready

---

## Phase 2: Pod-Status und Stabilität

### Gesamt-Übersicht
- **Running**: 47 Pods ✅
- **Pending**: 0 Pods ✅
- **CrashLoopBackOff**: 0 Pods ✅
- **Completed**: 2 Pods (Init-Jobs) ✅

### Node-Ressourcen
- **CPU Requests**: 3950m (98% von 4000m) ⚠️ **Hoch, aber OK**
- **CPU Limits**: 15400m (385% - Overcommitment)
- **Memory Requests**: 19796Mi (62% von ~32GB) ✅
- **Memory Limits**: 32000Mi (100%)

### Tatsächliche Auslastung
- **CPU**: 1255m (31%) ✅ **Gut**
- **Memory**: 11268Mi (35%) ✅ **Gut**

**Hinweis**: Die CPU-Requests sind hoch (98%), aber die tatsächliche Auslastung ist nur 31%. Das bedeutet, dass die Pods genug Ressourcen haben, aber die Requests könnten optimiert werden.

### Kritische Services

#### ✅ Pi-hole
- **Namespace**: `pihole`
- **Pod**: `pihole-7fc8889b54-mdl2f` - Running (1/1)
- **Service**: ClusterIP (10.100.79.138)
- **Ports**: 53/TCP, 53/UDP, 80/TCP
- **Status**: ✅ Stabil, keine Restarts

#### ✅ Ingress-Controller
- **Namespace**: `ingress-nginx`
- **Pod**: `ingress-nginx-controller-68c56f854d-bzqbf` - Running (1/1)
- **Status**: ✅ Stabil

#### ✅ Cert-Manager
- **Namespace**: `cert-manager`
- **Pods**: 3 Running (cainjector, cert-manager, webhook)
- **Status**: ✅ Stabil

#### ✅ ArgoCD
- **Namespace**: `argocd`
- **Pods**: 7 Running
  - `argocd-application-controller-0` - Running
  - `argocd-server-76686697fb-jn8cc` - Running
  - `argocd-repo-server-694bc78b6f-ttbxb` - Running
  - `argocd-dex-server-6d457f6565-6lc5p` - Running
  - `argocd-redis-7b6cdf646d-jfvmz` - Running
  - `argocd-notifications-controller-5d5994c6d5-dgjxj` - Running
  - `argocd-applicationset-controller-6fbcc76cf4-g8z44` - Running
- **Status**: ⚠️ **Pod läuft, aber Web-Interface nicht erreichbar** (siehe Phase 4)

#### ✅ GitLab
- **Namespace**: `gitlab`
- **Pods**: 3 Running
  - `gitlab-7b86fcf65b-mz6jt` - Running (0 Restarts)
  - `gitlab-postgresql-0` - Running (1 Restart vor 22h)
  - `gitlab-redis-master-0` - Running (1 Restart vor 22h)
- **Status**: ✅ Stabil, Health-Checks funktionieren

---

## Phase 3: Logs-Analyse

### Pi-hole Logs
- **Status**: ✅ Normal
- **Warnungen**: Load Average Warnungen (normal bei hoher Last)
- **Hinweis**: Einige "Cannot get exclusive lock" Warnungen, aber nicht kritisch

### Ingress-Controller Logs
- **Status**: ✅ Normal
- **Hinweis**: GitLab-KAS API-Anfragen (404 ist normal, wenn nicht konfiguriert)

### Cert-Manager Logs
- **Status**: ✅ Normal
- **Hinweis**: Pi-hole Certificate wurde erfolgreich ausgestellt (`pihole-tls`)

### ArgoCD Logs
- **Status**: ⚠️ **Keine Logs verfügbar** (Container-Logs konnten nicht abgerufen werden)
- **Hinweis**: Pod läuft, aber möglicherweise Problem mit Log-Zugriff

### GitLab Logs
- **Status**: ✅ Normal
- **Health-Checks**: ✅ Funktionieren (200 OK)
- **Readiness**: ✅ Funktionieren

---

## Phase 4: Webinterfaces

### ✅ Funktionierende Interfaces

| Service | URL | Status | HTTP Code | TLS |
|---------|-----|--------|-----------|-----|
| **GitLab** | https://gitlab.k8sops.online | ✅ | 302 Redirect | ✅ |
| **Jellyfin** | https://jellyfin.k8sops.online | ✅ | 302 Redirect | ✅ |
| **Heimdall** | https://heimdall.k8sops.online | ✅ | 200 OK | ✅ |
| **Grafana** | https://grafana.k8sops.online | ✅ | 302 Redirect | ✅ |
| **Prometheus** | https://prometheus.k8sops.online | ✅ | 405 (Method Not Allowed - normal) | ✅ |
| **Pi-hole** | https://pihole.k8sops.online/admin/ | ✅ | 302 Redirect | ✅ |

### ⚠️ Probleme

#### ArgoCD - Web-Interface nicht erreichbar
- **URL**: https://argocd.k8sops.online
- **Problem**: Timeout bei HTTP-Anfragen
- **Ursache**: Ingress verwendet `backend-protocol: GRPC`, aber HTTP-Requests werden als GRPC behandelt
- **Fehler**: `recv() failed (104: Connection reset by peer) while reading response header from upstream`
- **Status**: ⚠️ **Pod läuft, aber Web-Interface nicht erreichbar**

**Lösung**: Ingress-Konfiguration ändern:
- `nginx.ingress.kubernetes.io/backend-protocol: GRPC` entfernen oder auf `HTTP` ändern
- ArgoCD unterstützt sowohl HTTP als auch GRPC, aber für das Web-Interface sollte HTTP verwendet werden

---

## Phase 5: DNS-Tests

### ✅ DNS-Auflösung
- **Von WSL2 aus**: ✅ `argocd.k8sops.online` → `192.168.178.54`
- **Von WSL2 aus**: ✅ `gitlab.k8sops.online` → `192.168.178.54`
- **Pi-hole DNS**: ✅ `dig @192.168.178.54 google.de` funktioniert

### ⚠️ DNS-Problem bei curl
- **Problem**: `curl` von WSL2 aus kann Domains nicht auflösen (Timeout)
- **Ursache**: WSL2-Netzwerk-Isolation (bekanntes Problem)
- **Workaround**: DNS-Auflösung funktioniert mit `dig`, aber nicht mit `curl`
- **Lösung**: Tests vom Server selbst durchführen (funktioniert)

### DNS-Konfiguration
- **Pi-hole**: ✅ Läuft auf Port 53 (Host-Netzwerk)
- **CoreDNS**: ✅ Forward an Pi-hole konfiguriert
- **FritzBox**: ⚠️ **Nicht getestet** (sollte auf `192.168.178.54` zeigen)

---

## Phase 6: Ingress und Netzwerk-Konfiguration

### Ingress-Controller
- **Status**: ✅ Running
- **LoadBalancer IP**: `192.168.178.54`
- **Host Network**: `true` (bindet direkt an Host-IP)
- **Ports**: 80 (HTTP), 443 (HTTPS)

### Ingress-Ressourcen (13)
Alle Ingress-Ressourcen sind konfiguriert:
- ✅ ArgoCD (aber mit GRPC-Problem)
- ✅ GitLab
- ✅ Jellyfin
- ✅ Heimdall
- ✅ Grafana
- ✅ Prometheus
- ✅ Pi-hole
- ✅ Jenkins
- ✅ Komga
- ✅ Loki
- ✅ Syncthing
- ✅ Kubernetes Dashboard
- ✅ PlantUML
- ✅ Test

### TLS-Zertifikate
- **Status**: ✅ Alle Zertifikate sind gültig (außer Pi-hole)
- **Pi-hole**: ⚠️ **Zwei Certificates**:
  - `pihole-k8sops-online-tls`: READY=False (zeigt auf `pihole-tls` Secret)
  - `pihole-tls`: READY=True
- **Problem**: Beide Certificates zeigen auf dasselbe Secret (`pihole-tls`)
- **Lösung**: Altes Certificate (`pihole-tls`) löschen, nur `pihole-k8sops-online-tls` behalten

---

## Phase 7: FritzBox-Konfiguration

### ⚠️ Nicht getestet
- **DNS-Server**: Sollte auf `192.168.178.54` zeigen
- **Status**: ⚠️ **Muss manuell geprüft werden**

---

## Identifizierte Probleme

### P1 - Wichtig (Bald beheben)

1. **ArgoCD Web-Interface nicht erreichbar**
   - **Problem**: Ingress verwendet GRPC, aber HTTP-Requests kommen an
   - **Lösung**: Ingress-Konfiguration ändern (`backend-protocol: HTTP` statt `GRPC`)
   - **Datei**: Ingress-Ressource `argocd-ingress` im Namespace `argocd`

2. **Pi-hole Certificate-Konflikt**
   - **Problem**: Zwei Certificates zeigen auf dasselbe Secret
   - **Lösung**: Altes Certificate (`pihole-tls`) löschen
   - **Befehl**: `kubectl delete certificate -n pihole pihole-tls`

### P2 - Beobachten

3. **CPU-Requests hoch (98%)**
   - **Problem**: CPU-Requests sind bei 98%, aber tatsächliche Auslastung nur 31%
   - **Auswirkung**: Keine kritische Auswirkung, aber könnte optimiert werden
   - **Lösung**: CPU-Requests für weniger kritische Services reduzieren

4. **WSL2-Netzwerk-Isolation**
   - **Problem**: DNS-Auflösung funktioniert mit `dig`, aber nicht mit `curl`
   - **Auswirkung**: Tests müssen vom Server selbst durchgeführt werden
   - **Status**: Bekanntes Problem, kein kritischer Fehler

---

## Zusammenfassung

### ✅ Funktioniert
- SSH-Zugriff
- kubectl-Zugriff
- Alle Pods laufen stabil
- GitLab Web-Interface
- Jellyfin Web-Interface
- Heimdall Web-Interface
- Grafana Web-Interface
- Prometheus Web-Interface
- Pi-hole DNS-Server
- DNS-Auflösung (mit dig)
- TLS-Zertifikate (außer Pi-hole-Konflikt)

### ⚠️ Probleme
- ArgoCD Web-Interface nicht erreichbar (GRPC-Konfiguration)
- Pi-hole Certificate-Konflikt (zwei Certificates)
- FritzBox-Konfiguration nicht getestet

### 📋 Nächste Schritte

1. **ArgoCD Ingress reparieren**:
   ```bash
   kubectl annotate ingress argocd-ingress -n argocd \
     nginx.ingress.kubernetes.io/backend-protocol=HTTP \
     --overwrite
   ```

2. **Pi-hole Certificate bereinigen**:
   ```bash
   kubectl delete certificate -n pihole pihole-tls
   ```

3. **FritzBox DNS-Konfiguration prüfen**:
   - DNS-Server sollte auf `192.168.178.54` zeigen
   - Von verschiedenen Geräten im Heimnetzwerk testen

4. **CPU-Requests optimieren** (optional):
   - Weniger kritische Services analysieren
   - CPU-Requests reduzieren wo möglich

---

**Ende des Reports**

