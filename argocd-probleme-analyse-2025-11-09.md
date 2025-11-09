# ArgoCD Probleme Analyse - 2025-11-09

## Aktueller Status

**Gesamt Applications**: 8
- ✅ `jellyfin` - Synced, Healthy
- ✅ `kubernetes-dashboard` - Synced, Healthy
- ⚠️ `gitlab` - OutOfSync, Healthy
- ⚠️ `heimdall` - OutOfSync, Healthy
- ⚠️ `komga` - OutOfSync, Healthy
- ⚠️ `pihole` - OutOfSync, Healthy
- ❌ `plantuml` - OutOfSync, Missing
- ⚠️ `syncthing` - OutOfSync, Healthy

## Identifizierte Probleme

### 1. PlantUML - Missing Status

**Problem**: 
- ArgoCD Application zeigt auf `default` Namespace
- Manifeste zeigen auf `plantuml` Namespace
- PlantUML läuft noch im `default` Namespace
- ArgoCD versucht Ressourcen im `plantuml` Namespace zu erstellen, findet sie aber nicht

**Ursache**: 
- Namespace-Konflikt zwischen Application-Konfiguration und Manifesten
- PlantUML wurde manuell im `default` Namespace erstellt

**Lösung**: 
- ✅ ArgoCD Application auf `plantuml` Namespace geändert
- ⏳ PlantUML muss vom `default` Namespace in den `plantuml` Namespace migriert werden
- ⏳ Oder: Manifeste zurück auf `default` Namespace ändern (wenn PlantUML dort bleiben soll)

### 2. Pi-hole - OutOfSync (PVC)

**Problem**: 
- PersistentVolumeClaim `pihole-data` ist OutOfSync
- Deployment ist Synced (RollingUpdate Strategy wurde bereits angewendet)

**Ursache**: 
- PVC wurde manuell erstellt oder geändert
- Manifest im Repository entspricht nicht der laufenden PVC-Konfiguration

**Lösung**: 
- PVC-Manifest im Repository mit laufender PVC synchronisieren
- Oder: PVC im Cluster mit Repository-Manifest synchronisieren

### 3. GitLab - OutOfSync (Services)

**Problem**: 
- Mehrere Services sind OutOfSync:
  - `gitlab`
  - `gitlab-postgresql`
  - `gitlab-postgresql-hl`
  - `gitlab-redis-headless`

**Ursache**: 
- Services wurden manuell erstellt oder geändert
- Exportierte Manifeste entsprechen nicht den laufenden Services
- Möglicherweise fehlen Service-Manifeste im Repository

**Lösung**: 
- Fehlende Service-Manifeste exportieren und ins Repository hinzufügen
- Oder: Services mit Repository-Manifesten synchronisieren

### 4. Heimdall, Komga, Syncthing - OutOfSync

**Problem**: 
- Alle drei Applications sind OutOfSync

**Ursache**: 
- Manifeste wurden exportiert und bereinigt
- Laufende Ressourcen entsprechen nicht den bereinigten Manifesten
- Möglicherweise fehlen Ressourcen im Repository (z.B. PVCs, Secrets)

**Lösung**: 
- Fehlende Ressourcen identifizieren und hinzufügen
- Oder: Ressourcen synchronisieren

## Empfohlene Lösungsschritte

1. **PlantUML Namespace-Problem beheben**:
   - Entscheiden: Soll PlantUML im `plantuml` oder `default` Namespace bleiben?
   - Application und Manifeste entsprechend anpassen
   - Ressourcen migrieren oder neu erstellen

2. **Fehlende Manifeste hinzufügen**:
   - PVCs für alle Services exportieren
   - Secrets prüfen und dokumentieren
   - Services für GitLab vollständig exportieren

3. **ArgoCD synchronisieren**:
   - Entweder: Manuell synchronisieren (kubectl apply)
   - Oder: ArgoCD automatisches Sync nutzen (empfohlen)

4. **Repository aktualisieren**:
   - Alle fehlenden Manifeste committen
   - ArgoCD wird dann automatisch synchronisieren

---

**Ende der Analyse**

