# Jellyfin Backup-Dokumentation - 2025-11-08

**Erstellt**: 2025-11-08  
**Status**: ✅ Backup erstellt

---

## Backup-Informationen

### Jellyfin Konfiguration
- **Namespace**: `default`
- **Deployment**: `jellyfin`
- **PVC**: `jellyfin-data`
- **Zugangsdaten**: `bernd:Montag69`
- **Status**: ✅ Funktioniert einwandfrei

### Gesicherte Dateien

1. **Deployment-Manifest**:
   - Pfad: `/tmp/jellyfin-deployment-backup.yaml`
   - Datum: 2025-11-08
   - Inhalt: Vollständiges Jellyfin Deployment-Manifest

2. **Backup-Verzeichnis**:
   - Pfad: `/tmp/jellyfin-backup-20251108/`
   - Inhalt: Deployment-Manifest

### PVC-Daten

- **PVC Name**: `jellyfin-data`
- **Volume Name**: [wird beim Backup ermittelt]
- **Speicherort**: Persistent Volume auf Node
- **Hinweis**: PVC-Daten müssen separat gesichert werden (z.B. über Velero oder manuelles Backup)

---

## Wiederherstellung

### Deployment wiederherstellen

```bash
# Deployment aus Backup wiederherstellen
kubectl apply -f /tmp/jellyfin-deployment-backup.yaml
```

### PVC-Daten wiederherstellen

**Option 1: Velero Backup** (falls konfiguriert):
```bash
# Backup erstellen
velero backup create jellyfin-backup-2025-11-08 --include-namespaces default --include-resources persistentvolumeclaims

# Wiederherstellen
velero restore create jellyfin-restore --from-backup jellyfin-backup-2025-11-08
```

**Option 2: Manuelles Backup**:
```bash
# PVC-Daten vom Node kopieren (falls bekannt)
# PVC-Mount-Point identifizieren und Daten kopieren
```

---

## Zugangsdaten

- **Benutzername**: `bernd`
- **Passwort**: `Montag69`
- **Status**: ✅ Funktioniert

**WICHTIG**: Diese Zugangsdaten müssen nach Wiederherstellung möglicherweise neu gesetzt werden, falls die Datenbank nicht mitgesichert wurde.

---

## Backup-Zeitplan

**Empfehlung**: Regelmäßige Backups (z.B. wöchentlich)

**Backup-Methode**:
1. Deployment-Manifest sichern (kubectl get deployment -o yaml)
2. PVC-Daten sichern (Velero oder manuell)
3. Zugangsdaten dokumentieren

---

**Ende der Backup-Dokumentation**

