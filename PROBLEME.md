# Identifizierte Probleme im Kubernetes-Cluster

**Datum**: 2025-11-06  
**Status**: Priorisierte Liste aller bekannten Probleme

## Kritische Probleme (P0 - Sofort beheben)

### 1. Jellyfin kann nicht starten - NFS-Mount-Fehler

**Priorität**: P0 - Kritisch  
**Status**: Pending  
**Namespace**: default  
**Pod**: `jellyfin-6ccf8fbcb7-gmpk9`

**Problem**:
- Pod ist im Status "Pending" und kann nicht starten
- NFS-Volumes können nicht gemountet werden
- Frühere Fehlermeldungen: "access denied by server while mounting"

**Betroffene Volumes**:
- `jellyfin-config`: `/DATA/default-jellyfin-config-pvc-...` (NFS)
- `jellyfin-data`: `/DATA/default-jellyfin-data-pvc-...` (NFS)
- `jellyfin-filme`: `/media/devmon/WD-Black_8TB` (NFS)
- `jellyfin-vertical`: `/media/devmon/Elements` (NFS)
- `jellyfin-media`: `/DATA/Media` (NFS)

**Root Cause Analyse**:
- WSL2-Node hat IP `172.31.16.162` (nicht im 192.168.178.0/24 Netzwerk)
- NFS-Exports erlauben nur `192.168.178.0/24`
- NFS-Server sieht möglicherweise die WSL2-interne IP statt der Windows-Host-IP
- NFS-Tools wurden auf WSL2 installiert, aber Mounts schlagen weiterhin fehl

**Lösungsansätze**:
1. **NFS-Exports erweitern** (empfohlen):
   - `/etc/exports` auf zuhause Node (192.168.178.54) anpassen
   - WSL2-Subnetz oder Windows-Host-IP hinzufügen
   - `exportfs -ra` ausführen

2. **Jellyfin auf zuhause Node verschieben**:
   - `nodeSelector` und `tolerations` aus Deployment entfernen
   - Funktioniert sofort, aber weniger CPU-Ressourcen

3. **NFS-Server-Logs prüfen**:
   - `/var/log/syslog` oder `journalctl -u nfs-kernel-server` auf zuhause Node
   - Prüfen, welche IP der Server bei Mount-Versuchen sieht

**Nächste Schritte**:
1. Prüfen, welche IP der NFS-Server tatsächlich sieht (Windows-Host-IP vs. WSL2-IP)
2. `/etc/exports` entsprechend anpassen
3. NFS-Exports neu laden
4. Jellyfin-Pod neu starten

---

## Wichtige Probleme (P1 - Bald beheben)

### 2. ServiceAccount-Fehler für ArgoCD, Velero, GitLab-Runner

**Priorität**: P1 - Wichtig  
**Status**: Fehlerhafte Pod-Erstellung  
**Namespaces**: argocd, velero, gitlab-runner

**Problem**:
- Mehrere Deployments können Pods nicht erstellen
- Fehler: "serviceaccount not found"

**Betroffene ServiceAccounts**:
- `argocd/argocd-application-controller`
- `argocd/argocd-repo-server`
- `argocd/argocd-dex-server`
- `argocd/argocd-notifications-controller`
- `argocd/argocd-applicationset-controller`
- `velero/velero`
- `gitlab-runner/gitlab-runner`

**Lösungsansatz**:
- ServiceAccounts in den jeweiligen Namespaces erstellen
- Oder: Helm-Charts/Manifests neu anwenden, die diese ServiceAccounts enthalten sollten

---

### 3. Namespace-Inkonsistenz bei Jellyfin

**Priorität**: P1 - Wichtig  
**Status**: Inkonsistent

**Problem**:
- `jellyfin` Namespace existiert
- Service und Ingress sind im `jellyfin` Namespace
- Deployment läuft noch im `default` Namespace
- PVCs sind im `default` Namespace

**Lösungsansatz**:
- Entscheidung treffen: Jellyfin komplett in `jellyfin` Namespace verschieben
- Oder: Alles zurück in `default` Namespace
- PVCs können nicht einfach verschoben werden (an PVs gebunden)

---

## Warnungen (P2 - Beobachten)

### 4. InvalidDiskCapacity Warnungen auf WSL2-Node

**Priorität**: P2 - Warnung  
**Status**: Wiederkehrende Warnungen

**Problem**:
- Viele "InvalidDiskCapacity" Warnungen für `node/wsl2-ubuntu`
- "invalid capacity 0 on image filesystem"

**Auswirkung**: Vermutlich keine kritische Auswirkung, aber sollte untersucht werden

**Lösungsansatz**:
- WSL2-Disk-Konfiguration prüfen
- Möglicherweise WSL2-spezifisches Problem

---

### 5. Viele veraltete NFS-Install-Dateien

**Priorität**: P2 - Aufräumen  
**Status**: Bereinigt (README erstellt)

**Problem**:
- 13+ verschiedene NFS-Install-Versuche in `k8s/tools/`
- Verwirrung über welche Dateien aktuell sind

**Lösung**: README.md erstellt, das veraltete Dateien dokumentiert

---

## Behobene Probleme

### ✅ NFS-Tools auf WSL2 installiert
- `nfs-common` wurde auf WSL2-Host installiert
- Früherer Fehler "bad option; for several filesystems" ist behoben

### ✅ Test-Pods aufgeräumt
- Terminating/Pending Test-Pods wurden gelöscht
- Completed Jobs wurden bereinigt

---

## Zusammenfassung

**Kritische Probleme**: 1 (Jellyfin NFS-Mount)  
**Wichtige Probleme**: 2 (ServiceAccounts, Namespace-Inkonsistenz)  
**Warnungen**: 2 (Disk-Capacity, veraltete Dateien)

**Gesamt-Status**: Cluster läuft größtenteils, aber Jellyfin ist nicht funktionsfähig.

