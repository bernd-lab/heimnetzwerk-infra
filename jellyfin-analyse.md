# Jellyfin Container Analyse

**Datum**: 2025-11-06  
**Status**: ⚠️ **KRITISCHE PROBLEME IDENTIFIZIERT - ROOT CAUSE GEFUNDEN**

## Zusammenfassung

### ❌ Kritische Probleme
1. **Pod-Status**: 0/1 Unknown - Pod ist nicht ready
2. **Container-Status**: Terminated (Exit Code 255) - Container ist abgestürzt
3. **Volume-Mount-Fehler**: 4 Volumes können nicht gemountet werden - **NFS-Pfade existieren nicht**
4. **Database-Fehler**: DbUpdateConcurrencyException - Datenbank-Konflikte
5. **Service-Erreichbarkeit**: HTTP Timeout - Service nicht erreichbar

## Root Cause: NFS-Pfade existieren nicht mehr

### Fehlermeldungen zeigen klar das Problem:

```
mount.nfs: mounting 192.168.178.54:/media/devmon/WD-Black_8TB/Filme failed, 
reason given by server: No such file or directory

mount.nfs: mounting 192.168.178.54:/media/devmon/Elements/VerticalHeimatfilme failed, 
reason given by server: No such file or directory

mount.nfs: mounting 192.168.178.54:/media/devmon/Elements/Heimatfilme failed, 
reason given by server: No such file or directory

mount.nfs: mounting 192.168.178.54:/media/devmon/Elements/JDownloader failed, 
reason given by server: No such file or directory
```

**Problem**: Die NFS-Export-Pfade auf dem Server (192.168.178.54) existieren nicht mehr!

### Betroffene Volumes

| Volume | NFS-Pfad | Status | Problem |
|--------|----------|--------|---------|
| `jellyfin-filme` | `/media/devmon/WD-Black_8TB/Filme` | ❌ | Pfad existiert nicht |
| `jellyfin-vertical` | `/media/devmon/Elements/VerticalHeimatfilme` | ❌ | Pfad existiert nicht |
| `jellyfin-heimatfilme` | `/media/devmon/Elements/Heimatfilme` | ❌ | Pfad existiert nicht |
| `jellyfin-anime` | `/media/devmon/Elements/JDownloader` | ❌ | Pfad existiert nicht |
| `jellyfin-media` | (unbekannt) | ✅ | Funktioniert |
| `jellyfin-config` | (nfs-data StorageClass) | ✅ | Funktioniert |
| `jellyfin-data` | (nfs-data StorageClass) | ✅ | Funktioniert |

## Detaillierte Analyse

### 1. Pod-Status
```
NAME                              READY   STATUS    RESTARTS   AGE
jellyfin-76b547597b-527cm         0/1     Unknown   0          2d21h
```

**Problem**: 
- Pod-Status: `Unknown` (nicht `Running`)
- Ready: 0/1 (Container nicht ready)
- Restart-Count: 0 (Container wurde nicht neu gestartet)

### 2. Container-Status
```json
{
  "terminated": {
    "containerID": "containerd://c58bd9b5ba77ff474df60b924e909d762eda363489b9e6fdafc26e209521991d",
    "exitCode": 255,
    "finishedAt": "2025-11-06T08:37:27Z",
    "reason": "Unknown",
    "startedAt": "2025-11-03T13:05:41Z"
  }
}
```

**Problem**:
- Container ist **terminated** (abgestürzt)
- Exit Code: **255** (kritischer Fehler)
- Container lief von 2025-11-03 bis 2025-11-06 (ca. 3 Tage)
- Grund: `Unknown` (wahrscheinlich wegen fehlender Volumes)

### 3. Volume-Mount-Fehler (KRITISCH)

**Events zeigen wiederholte Mount-Fehler**:
```
LAST SEEN   TYPE      REASON        OBJECT                          MESSAGE
56m         Warning   FailedMount   pod/jellyfin-76b547597b-527cm   MountVolume.SetUp failed for volume "jellyfin-filme" : mount failed: exit status 32
15m         Warning   FailedMount   pod/jellyfin-76b547597b-527cm   MountVolume.SetUp failed for volume "jellyfin-vertical" : mount failed: exit status 32
5m21s       Warning   FailedMount   pod/jellyfin-76b547597b-527cm   MountVolume.SetUp failed for volume "jellyfin-heimatfilme" : mount failed: exit status 32
76s         Warning   FailedMount   pod/jellyfin-76b547597b-527cm   MountVolume.SetUp failed for volume "jellyfin-anime" : mount failed: exit status 32
```

**Detaillierte Fehlermeldungen**:
- `jellyfin-filme`: `/media/devmon/WD-Black_8TB/Filme` - **No such file or directory**
- `jellyfin-vertical`: `/media/devmon/Elements/VerticalHeimatfilme` - **No such file or directory**
- `jellyfin-heimatfilme`: `/media/devmon/Elements/Heimatfilme` - **No such file or directory**
- `jellyfin-anime`: `/media/devmon/Elements/JDownloader` - **No such file or directory**

**Problem**: 
- Exit Status 32 = NFS-Mount-Fehler
- **NFS-Pfade existieren nicht mehr auf dem Server**
- RWX (ReadWriteMany) Volumes haben Probleme
- RWO (ReadWriteOnce) Volumes funktionieren (verwenden StorageClass)

### 4. PersistentVolume-Konfiguration

**Manual Volumes (ohne StorageClass)**:
```
jellyfin-anime         100Gi   RWX   Retain   Bound   default/jellyfin-anime
jellyfin-filme         500Gi   RWX   Retain   Bound   default/jellyfin-filme
jellyfin-heimatfilme   100Gi   RWX   Retain   Bound   default/jellyfin-heimatfilme
jellyfin-vertical      100Gi   RWX   Retain   Bound   default/jellyfin-vertical
jellyfin-media         500Gi   RWX   Retain   Bound   default/jellyfin-media
```

**StorageClass-basierte Volumes**:
```
jellyfin-config   10Gi   RWO   Delete   Bound   default/jellyfin-config   (nfs-data)
jellyfin-data     20Gi   RWO   Delete   Bound   default/jellyfin-data     (nfs-data)
```

**Problem**: 
- Manual Volumes zeigen auf NFS-Pfade, die nicht mehr existieren
- StorageClass-basierte Volumes funktionieren

### 5. Database-Fehler

**Logs zeigen wiederholte Datenbank-Fehler**:
```
[ERR] Jellyfin.Database.Implementations.JellyfinDbContext: Error trying to save changes.
Microsoft.EntityFrameworkCore.DbUpdateConcurrencyException: 
The database operation was expected to affect 1 row(s), but actually affected 0 row(s); 
data may have been modified or deleted since entities were loaded.
```

**Problem**:
- **Optimistic Concurrency Exception** in Entity Framework
- Datenbank-Einträge wurden zwischenzeitlich geändert oder gelöscht
- Kann durch parallele Zugriffe oder Datenbank-Korruption verursacht werden
- **Sekundäres Problem** (Container läuft nicht, daher nicht kritisch)

### 6. Service-Erreichbarkeit

**Service-Konfiguration**:
```
NAME      TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE
jellyfin  ClusterIP   10.111.39.176 <none>        80/TCP,443/TCP    2d22h
```

**Ingress-Konfiguration**:
```
NAME              CLASS   HOSTS                      ADDRESS          PORTS     AGE
jellyfin-ingress  nginx   jellyfin.k8sops.online     192.168.178.54   80, 443   2d22h
```

**DNS-Auflösung**:
```
jellyfin.k8sops.online → 192.168.178.54 ✅
```

**HTTP-Test**:
```
curl: (28) Failed to connect to jellyfin.k8sops.online port 80 after 5055 ms: Timeout was reached
```

**Problem**:
- Service ist konfiguriert, aber nicht erreichbar
- Pod läuft nicht (Container terminated)
- Ingress kann keinen Traffic weiterleiten, da kein Backend-Pod verfügbar ist

### 7. Ressourcen-Konfiguration

**Resource Limits** (aktuell im Deployment):
```json
{
  "limits": {
    "cpu": "2000m",
    "memory": "2Gi"
  },
  "requests": {
    "cpu": "500m",
    "memory": "512Mi"
  }
}
```

**Resource Limits** (im Pod):
```json
{
  "limits": {
    "cpu": "3",
    "memory": "4Gi"
  },
  "requests": {
    "cpu": "1",
    "memory": "1Gi"
  }
}
```

**Status**: ⚠️ Unterschiedliche Limits zwischen Deployment und Pod (möglicherweise manuell geändert)

## Root Cause Analysis

### Hauptproblem: NFS-Pfade existieren nicht mehr

1. **NFS-Export-Pfade wurden geändert oder gelöscht**
   - `/media/devmon/WD-Black_8TB/Filme` - existiert nicht
   - `/media/devmon/Elements/VerticalHeimatfilme` - existiert nicht
   - `/media/devmon/Elements/Heimatfilme` - existiert nicht
   - `/media/devmon/Elements/JDownloader` - existiert nicht

2. **Mögliche Ursachen**:
   - Externe Festplatten wurden abgemeldet/umbenannt
   - Mount-Punkte wurden geändert
   - Festplatten wurden neu formatiert
   - NFS-Exports wurden geändert

3. **Container stürzt ab** (Exit Code 255)
   - Wahrscheinlich weil kritische Volumes nicht gemountet werden können
   - Container kann nicht starten ohne Media-Volumes

4. **Database-Fehler**
   - Sekundäres Problem (Container läuft nicht)
   - Könnte auf Datenbank-Korruption hindeuten

## Empfohlene Lösungen

### Priorität 1: NFS-Pfade prüfen und korrigieren

1. **Aktuelle NFS-Exports prüfen**:
   ```bash
   # Auf Server (192.168.178.54)
   showmount -e localhost
   # oder
   cat /etc/exports
   ```

2. **Aktuelle Mount-Punkte prüfen**:
   ```bash
   # Auf Server
   mount | grep /media
   ls -la /media/devmon/
   ```

3. **Korrekte Pfade identifizieren**:
   - Wo sind die Filme jetzt?
   - Wo sind die Anime jetzt?
   - Wo sind die Heimatfilme jetzt?
   - Wo ist Vertical jetzt?

4. **PersistentVolumes aktualisieren**:
   ```bash
   # PVs beschreiben und NFS-Pfade korrigieren
   kubectl get pv jellyfin-filme -o yaml
   # NFS-Pfad im PV korrigieren
   kubectl edit pv jellyfin-filme
   # Gleiches für andere PVs
   ```

### Priorität 2: Alternative Lösung - StorageClass verwenden

1. **StorageClasses prüfen**:
   - `nfs-data` (funktioniert)
   - `nfs-elements` (verfügbar)
   - `nfs-wd-black` (verfügbar)

2. **PVCs auf StorageClass umstellen**:
   - Neue PVCs mit StorageClass erstellen
   - Alte Manual-PVs löschen
   - Deployment aktualisieren

### Priorität 3: Container neu starten

1. **Pod löschen** (wird automatisch neu erstellt):
   ```bash
   kubectl delete pod -n default jellyfin-76b547597b-527cm
   ```

2. **Deployment prüfen**:
   ```bash
   kubectl describe deployment -n default jellyfin
   ```

### Priorität 4: Database prüfen

1. **Datenbank-Backup erstellen** (falls möglich)
2. **Datenbank-Integrität prüfen**
3. **Bei Bedarf Datenbank zurücksetzen**

## Nächste Schritte

1. ✅ **NFS-Pfade auf Server prüfen** (wo sind die Daten jetzt?)
2. ⏳ **PersistentVolumes aktualisieren** (NFS-Pfade korrigieren)
3. ⏳ **Container neu starten** (nach Behebung der Volume-Probleme)
4. ⏳ **Service-Erreichbarkeit testen** (nach erfolgreichem Start)
5. ⏳ **Database-Fehler beheben** (falls weiterhin vorhanden)

## Status-Update

**Aktueller Status**: ⚠️ **KRITISCH - Container läuft nicht**

**Blockierende Probleme**:
- ❌ **NFS-Pfade existieren nicht mehr** (4 Volumes)
- ❌ Container terminated (Exit Code 255)
- ❌ Service nicht erreichbar

**Nicht-blockierende Probleme**:
- ⚠️ Database-Fehler (sekundär, da Container nicht läuft)
- ⚠️ Unterschiedliche Resource Limits (Deployment vs. Pod)

## Sofortige Aktion erforderlich

**Auf Server (192.168.178.54) geprüft**:
1. ✅ NFS-Exports sind aktiv: `/media/devmon/Elements` und `/media/devmon/WD-Black_8TB`
2. ❌ **Unterpfade existieren NICHT**:
   - ❌ `/media/devmon/WD-Black_8TB/Filme` - **NICHT vorhanden**
   - ❌ `/media/devmon/Elements/VerticalHeimatfilme` - **NICHT vorhanden**
   - ❌ `/media/devmon/Elements/Heimatfilme` - **NICHT vorhanden**
   - ❌ `/media/devmon/Elements/JDownloader` - **NICHT vorhanden**

**Problem bestätigt**: Die Festplatten sind leer oder die Verzeichnisse wurden gelöscht/umbenannt!

**Lösungsoptionen**:
1. **Verzeichnisse neu erstellen** (falls Daten noch vorhanden, aber nur Verzeichnisse fehlen):
   ```bash
   mkdir -p /media/devmon/WD-Black_8TB/Filme
   mkdir -p /media/devmon/Elements/VerticalHeimatfilme
   mkdir -p /media/devmon/Elements/Heimatfilme
   mkdir -p /media/devmon/Elements/JDownloader
   ```

2. **Neue Pfade identifizieren** (falls Daten verschoben wurden):
   - Wo sind die Filme jetzt?
   - Wo sind die Anime jetzt?
   - Wo sind die Heimatfilme jetzt?
   - Wo ist Vertical jetzt?

3. **PVs auf Root-Pfade ändern** (falls Daten direkt im Root liegen):
   - PVs auf `/media/devmon/WD-Black_8TB` ändern
   - PVs auf `/media/devmon/Elements` ändern
   - Deployment anpassen (Mount-Pfade im Container)

4. **StorageClass-basierte Lösung** (empfohlen):
   - Neue PVCs mit StorageClass erstellen
   - Alte Manual-PVs löschen
   - Deployment aktualisieren
