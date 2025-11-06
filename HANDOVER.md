# Cluster-Handover Dokumentation

**Datum**: 2025-11-06  
**Erstellt von**: System-Handover  
**Zweck**: Vollständige Übergabe des Kubernetes-Clusters an den nächsten Agenten

---

## Schnellübersicht

### Cluster-Status

- **Nodes**: 2 (zuhause, wsl2-ubuntu)
- **Pods**: 46 total (38 Running, 1 Pending, 3 Terminating, 4 Completed)
- **Namespaces**: 23
- **Services**: 30+
- **Ingress**: 13

### Kritische Probleme

1. **Jellyfin kann nicht starten** - NFS-Mount-Fehler (P0)
2. **ServiceAccount-Fehler** - ArgoCD, Velero, GitLab-Runner (P1)
3. **Namespace-Inkonsistenz** - Jellyfin verteilt auf 2 Namespaces (P1)

### Funktionierende Services

✅ Pi-hole, Jenkins, GitLab, ArgoCD, Ingress, CoreDNS, Monitoring, Logging, Komga, Heimdall, Syncthing

---

## Detaillierte Dokumentation

### 📋 PROBLEME.md
Priorisierte Liste aller identifizierten Probleme mit Lösungsansätzen.

### 📊 CLUSTER-ANALYSE.md
Detaillierte technische Analyse des gesamten Clusters (Nodes, Pods, Services, Storage, Netzwerk).

---

## Aktionsplan für nächsten Agenten

### Phase 1: Kritische Probleme beheben (P0)

#### 1.1 Jellyfin NFS-Mount-Problem lösen

**Problem**: Jellyfin-Pod ist Pending, NFS-Volumes können nicht gemountet werden.

**Schritte**:
1. Prüfen, welche IP der NFS-Server bei Mount-Versuchen sieht:
   ```bash
   # Auf zuhause Node (192.168.178.54):
   journalctl -u nfs-kernel-server -f
   # Oder:
   tail -f /var/log/syslog | grep nfs
   ```

2. Windows-Host-IP identifizieren (nicht WSL2-interne IP 172.31.16.162)

3. `/etc/exports` auf zuhause Node anpassen:
   ```bash
   # Option A: WSL2-Subnetz hinzufügen
   /DATA 192.168.178.0/24,172.31.16.0/20(rw,sync,no_subtree_check,no_root_squash)
   
   # Option B: Windows-Host-IP hinzufügen (empfohlen)
   /DATA 192.168.178.0/24,<WINDOWS_HOST_IP>(rw,sync,no_subtree_check,no_root_squash)
   ```

4. NFS-Exports neu laden:
   ```bash
   exportfs -ra
   systemctl reload nfs-kernel-server
   ```

5. Jellyfin-Pod neu starten:
   ```bash
   kubectl delete pod -l app=jellyfin
   ```

**Alternative**: Jellyfin auf zuhause Node verschieben (weniger CPU, aber funktioniert sofort).

---

### Phase 2: Wichtige Probleme beheben (P1)

#### 2.1 ServiceAccounts erstellen

**Betroffene Namespaces**: argocd, velero, gitlab-runner

**Schritte**:
1. Prüfen, welche ServiceAccounts fehlen:
   ```bash
   kubectl get events -A | grep "serviceaccount.*not found"
   ```

2. ServiceAccounts erstellen oder Helm-Charts neu installieren:
   ```bash
   # Beispiel für ArgoCD:
   kubectl create serviceaccount argocd-application-controller -n argocd
   # ... weitere ServiceAccounts
   ```

#### 2.2 Namespace-Konsistenz für Jellyfin

**Entscheidung treffen**:
- Option A: Alles in `jellyfin` Namespace verschieben
- Option B: Alles zurück in `default` Namespace

**Hinweis**: PVCs können nicht einfach verschoben werden (an PVs gebunden).

---

### Phase 3: Warnungen beheben (P2)

#### 3.1 WSL2-Disk-Capacity-Warnungen untersuchen

**Problem**: Viele "InvalidDiskCapacity" Warnungen für wsl2-ubuntu.

**Schritte**:
1. WSL2-Disk-Konfiguration prüfen
2. Möglicherweise WSL2-spezifisches Problem (kann ignoriert werden)

---

## Wichtige Konfigurationen

### NFS-Server

- **Server**: 192.168.178.54 (zuhause Node)
- **Exports**: `/etc/exports`
- **Pfade**:
  - `/DATA` → Dynamische PVCs
  - `/media/devmon/WD-Black_8TB` → WD-Black Festplatte
  - `/media/devmon/Elements` → Elements Festplatte

### DNS

- **CoreDNS**: Forward an Pi-hole (192.168.178.10) und 8.8.8.8
- **Pi-hole**: LoadBalancer IP 192.168.178.10

### Ingress

- **Controller**: nginx (hostNetwork: true)
- **LoadBalancer IP**: 192.168.178.54
- **Alle Domains**: `*.k8sops.online`

### Nodes

- **zuhause**: Debian 12, 4 CPU, 32GB RAM (control-plane)
- **wsl2-ubuntu**: Ubuntu 24.04 WSL2, 16 CPU, 58GB RAM

---

## Wichtige Dateien

### Kubernetes-Manifeste

- `k8s/jellyfin/deployment.yaml` - Jellyfin Deployment
- `k8s/jellyfin/service.yaml` - Jellyfin Service
- `k8s/jellyfin/ingress.yaml` - Jellyfin Ingress
- `k8s/jellyfin/namespace.yaml` - Jellyfin Namespace
- `k8s/jellyfin/priorityclass.yaml` - PriorityClass

### Tools

- `k8s/tools/nfs-reload-exports.yaml` - Job zum Neuladen der NFS-Exports
- `k8s/tools/README.md` - Dokumentation der Tools

---

## Bekannte Funktionsfähige Services

### ✅ Laufen stabil

- **Pi-hole** (192.168.178.10) - DNS/Ad-Blocking
- **Jenkins** - CI/CD
- **GitLab** - Code-Repository
- **ArgoCD** - GitOps (teilweise - ServiceAccount-Probleme)
- **Ingress-Controller** (192.168.178.54) - Routing
- **CoreDNS** - Cluster-DNS
- **Prometheus/Grafana** - Monitoring
- **Loki** - Logging
- **Komga** - Manga-Server
- **Heimdall** - Dashboard
- **Syncthing** - File-Sync

### ⚠️ Probleme

- **Jellyfin** - Kann nicht starten (NFS-Mount-Fehler)

---

## Nächste Schritte

1. **Sofort**: Jellyfin NFS-Problem lösen (siehe Phase 1.1)
2. **Bald**: ServiceAccounts erstellen (siehe Phase 2.1)
3. **Später**: Namespace-Konsistenz, Disk-Warnungen

---

## Kontaktinformationen / Zugriff

- **Kubernetes API**: `https://192.168.178.54:6443`
- **Dashboard**: `https://dashboard.k8sops.online`
- **GitLab**: `https://gitlab.k8sops.online`
- **ArgoCD**: `https://argocd.k8sops.online`

---

## Zusätzliche Ressourcen

- **PROBLEME.md** - Detaillierte Problem-Liste
- **CLUSTER-ANALYSE.md** - Technische Cluster-Analyse
- **k8s/tools/README.md** - Tools-Dokumentation

---

## Wichtige Hinweise

1. **NFS-Problem ist komplex**: WSL2-Netzwerk vs. NFS-Export-Berechtigungen
2. **PVCs können nicht verschoben werden**: An PVs gebunden, ReclaimPolicy beachten
3. **ServiceAccounts**: Möglicherweise durch Helm-Charts verwaltet
4. **WSL2-Disk-Warnungen**: Vermutlich harmlos, aber sollte untersucht werden

---

**Viel Erfolg beim Weiterarbeiten! 🚀**

