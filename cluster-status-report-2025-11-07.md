# Cluster-Status-Report

**Datum**: 2025-11-07  
**Cluster**: Kubernetes v1.34.1  
**Control Plane**: 192.168.178.54:6443

## Cluster-Übersicht

### Nodes
- **zuhause** (192.168.178.54): Ready (control-plane)
- **wsl2-ubuntu** (172.31.16.162): NotReady (unreachable)

### Pod-Status Gesamt
- **Running**: 43 Pods
- **Pending**: 4 Pods
- **CrashLoopBackOff**: 1 Pod
- **Completed**: 2 Pods (Init-Jobs)

## Identifizierte Probleme

### P0 - Kritisch (Sofort beheben)

#### 1. Velero CrashLoopBackOff - CRDs fehlen
**Pod**: `velero-6b58d6d487-548s6` (velero Namespace)  
**Status**: CrashLoopBackOff (179 Restarts)  
**Fehler**: 
```
Velero custom resources not found - apply config/crd/v1/bases/*.yaml,config/crd/v2alpha1/bases*.yaml
```

**Betroffene CRDs**:
- DataUpload, DataDownload (velero.io/v2alpha1)
- PodVolumeBackup, BackupRepository, Restore, BackupStorageLocation, VolumeSnapshotLocation, ServerStatusRequest, Schedule, DownloadRequest, DeleteBackupRequest, PodVolumeRestore, Backup (velero.io/v1)

**Lösung**: Velero CRDs installieren

#### 2. wsl2-ubuntu Node NotReady
**Status**: NotReady  
**Taints**: 
- `node.kubernetes.io/unreachable:NoExecute`
- `node.kubernetes.io/unreachable:NoSchedule`
- `workload-type=development:NoSchedule`

**Probleme**:
- Kubelet startet immer wieder neu
- Viele "InvalidDiskCapacity" Warnungen
- Node kann keine Pods schedulen

**Auswirkung**: Pods, die auf wsl2-ubuntu laufen sollen, können nicht gestartet werden

### P1 - Wichtig (Bald beheben)

#### 3. Jenkins Pods Pending
**Pods**: 
- `jenkins-6c5c5687f4-z77hf`: Pending (Insufficient CPU auf zuhause)
- `jenkins-7fb5d89ddf-2rqxf`: Pending (wsl2-ubuntu unreachable)

**Problem**: 
- Jenkins Deployment hat 2 Replicas, aber beide können nicht schedulen
- Erster Pod: CPU-Mangel auf "zuhause" Node
- Zweiter Pod: Soll auf wsl2-ubuntu, aber Node ist unreachable

**Lösung**: 
- Jenkins Replicas auf 1 reduzieren ODER
- Jenkins CPU-Requests reduzieren ODER
- wsl2-ubuntu Node reparieren

#### 4. Velero Pod Pending
**Pod**: `velero-7c697f8956-ffphp` (velero Namespace)  
**Status**: Pending  
**Grund**: Soll auf wsl2-ubuntu laufen, aber Node ist unreachable

**Lösung**: Node-Selector entfernen oder wsl2-ubuntu reparieren

### P2 - Beobachten

#### 5. InvalidDiskCapacity Warnungen auf wsl2-ubuntu
**Warnung**: "invalid capacity 0 on image filesystem"  
**Häufigkeit**: Sehr häufig (alle paar Sekunden)  
**Auswirkung**: Vermutlich keine kritische Auswirkung, aber sollte untersucht werden

## Behobene Probleme (seit PROBLEME.md)

✅ **Jellyfin läuft**: Pod ist jetzt Running auf "zuhause" Node  
✅ **ServiceAccounts vorhanden**: Alle ServiceAccounts in argocd, velero, gitlab-runner existieren

## Extrahierte To-Dos aus Logs

### Aus Velero-Logs:
1. **TODO**: Velero CRDs installieren
   - Dateien: `config/crd/v1/bases/*.yaml` und `config/crd/v2alpha1/bases/*.yaml`
   - Quelle: Velero Error-Log

### Aus Cluster-Status:
2. **TODO**: wsl2-ubuntu Node reparieren
   - Kubelet-Problem beheben
   - Unreachable Taints entfernen
   - InvalidDiskCapacity Warnungen untersuchen

3. **TODO**: Jenkins Deployment anpassen
   - Replicas reduzieren ODER
   - CPU-Requests reduzieren ODER
   - Node-Selector/Tolerations anpassen

4. **TODO**: Velero Deployment anpassen
   - Node-Selector entfernen (wenn wsl2-ubuntu nicht benötigt wird)
   - ODER wsl2-ubuntu Node reparieren

## Behobene Probleme

### ✅ Velero CRDs installiert
- Alle 13 Velero CRDs wurden installiert
- Velero Pod läuft jetzt (1/1 Running)
- Alle Controller gestartet

### ✅ Jenkins läuft
- Replicas auf 1 reduziert
- CPU-Requests von 500m auf 400m reduziert
- Pod läuft jetzt (1/1 Running)

### ✅ Alte Pending Pods bereinigt
- Alte Jenkins Pods gelöscht
- Alte Velero Pods gelöscht

## Aktueller Status

**Alle kritischen Probleme behoben!**

- ✅ Velero: Running
- ✅ Jenkins: Running
- ✅ Jellyfin: Running
- ⚠️ wsl2-ubuntu Node: NotReady (nicht kritisch, da keine Pods darauf laufen müssen)

## Nächste Schritte (Optional)

1. **wsl2-ubuntu Node-Problem untersuchen** (nicht kritisch)
   - Kubelet-Problem beheben
   - Unreachable Taints entfernen
   - InvalidDiskCapacity Warnungen untersuchen

2. **Velero BackupStorageLocation konfigurieren** (falls Backups benötigt werden)

