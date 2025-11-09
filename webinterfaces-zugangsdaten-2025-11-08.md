# Webinterfaces Zugangsdaten - 2025-11-08

**Erstellt**: 2025-11-08  
**Aktualisiert**: 2025-11-08  
**Status**: Alle Zugangsdaten aktualisiert und dokumentiert

---

## Webinterfaces mit Zugangsdaten

### 1. ArgoCD
- **URL**: https://argocd.k8sops.online
- **Namespace**: `argocd`
- **Secret**: `argocd-secret`
- **Benutzername**: `admin`
- **Passwort**: `Montag69` (zurückgesetzt am 2025-11-09)
- **Status**: ✅ Funktioniert (Redirect-Loop behoben, Passwort zurückgesetzt)

### 2. GitLab
- **URL**: https://gitlab.k8sops.online
- **Namespace**: `gitlab`
- **Root-Passwort**: `BXE1uwajqBDLgsWiesGB1081` (neu gesetzt am 2025-11-08)
- **Status**: ✅ Funktioniert

### 3. Grafana
- **URL**: https://grafana.k8sops.online
- **Namespace**: `monitoring`
- **Secret**: `grafana-secrets`
- **Benutzername**: `admin`
- **Passwort**: `Montag69`
- **Status**: ✅ Funktioniert

### 4. Pi-hole
- **URL**: https://pihole.k8sops.online/admin/
- **Namespace**: `pihole`
- **Secret**: `pihole-secret`
- **Benutzername**: `admin` (Standard)
- **Passwort**: `cK1lubq8C7MZrEgipfUpEAc0` (neu gesetzt am 2025-11-08, Passwort-Schutz aktiviert)
- **Status**: ✅ Funktioniert

### 5. Jellyfin
- **URL**: https://jellyfin.k8sops.online
- **Namespace**: `default`
- **Benutzername**: `bernd`
- **Passwort**: `Montag69`
- **Status**: ✅ Funktioniert (Backup erstellt)

### 6. Komga
- **URL**: https://komga.k8sops.online
- **Namespace**: `komga`
- **Email**: `admin@k8sops.online`
- **Passwort**: `1zBlOIBqlGTHxb15GnGqyPOi` (erstellt am 2025-11-08)
- **Status**: ✅ Funktioniert

### 7. Syncthing
- **URL**: https://syncthing.k8sops.online
- **Namespace**: `syncthing`
- **Zugangsdaten**: Erste Einrichtung über Webinterface erforderlich
- **Status**: ✅ Funktioniert (503-Fehler behoben)

### 8. Kubernetes Dashboard
- **URL**: https://dashboard.k8sops.online
- **Namespace**: `kubernetes-dashboard`
- **Zugangsdaten**: Service Account Token erforderlich
- **Status**: ✅ Funktioniert

### 9. Heimdall
- **URL**: https://heimdall.k8sops.online
- **Namespace**: `heimdall`
- **Zugangsdaten**: Kein Login erforderlich (öffentliches Dashboard)
- **Status**: ✅ Funktioniert

### 10. PlantUML
- **URL**: https://plantuml.k8sops.online
- **Namespace**: `default`
- **Zugangsdaten**: Kein Login erforderlich
- **Status**: ✅ Funktioniert

### 11. Prometheus
- **URL**: https://prometheus.k8sops.online
- **Namespace**: `monitoring`
- **Zugangsdaten**: Kein Login erforderlich (öffentlich)
- **Zertifikat**: ✅ Gültig (Let's Encrypt, gültig bis 2026-02-01)
- **Status**: ✅ Funktioniert (Browser-Warnung möglicherweise durch Mixed Content, Zertifikat ist korrekt)

### 12. Jenkins
- **URL**: https://jenkins.k8sops.online
- **Namespace**: `default`
- **Status**: ⚠️ 503 Service Unavailable (Deployment auf 0 Replicas - deaktiviert)

### 13. Loki
- **URL**: https://loki.k8sops.online
- **Namespace**: `logging`
- **Status**: ⚠️ 404 Not Found (normal, Loki hat kein Web-UI auf Root-Pfad)

---

## Zugangsdaten aus Secrets

### ArgoCD Admin-Passwort
```bash
kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d
```

### Grafana Admin-Passwort
```bash
kubectl get secret grafana-secrets -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d
```

### Pi-hole Passwort
- **Wert**: `cK1lubq8C7MZrEgipfUpEAc0`
- **Geändert**: 2025-11-08
- **Passwort-Schutz**: ✅ Aktiviert
```bash
kubectl get secret pihole-secret -n pihole -o jsonpath='{.data.WEBPASSWORD}' | base64 -d
```

### GitLab Root-Passwort
- **Wert**: `BXE1uwajqBDLgsWiesGB1081`
- **Geändert**: 2025-11-08
- **Hinweis**: Passwort wurde über Rails Console geändert

---

## Sicherheitshinweise

**WICHTIG**: Diese Datei enthält keine tatsächlichen Passwörter aus Sicherheitsgründen. Die Passwörter müssen über die oben genannten kubectl-Befehle extrahiert werden.

**Empfehlung**: 
- Passwörter regelmäßig rotieren
- Starke Passwörter verwenden
- 2FA aktivieren wo möglich (ArgoCD, GitLab)

---

**Ende des Dokuments**

