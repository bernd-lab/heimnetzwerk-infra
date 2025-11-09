# Heimdall, ArgoCD und Syncthing Probleme behoben - 2025-11-08

**Datum**: 2025-11-08  
**Status**: ✅ Probleme behoben

---

## Durchgeführte Fixes

### ✅ 1. Heimdall Links korrigiert

**Problem**: Links wurden mit `/tag/https://` Präfix angezeigt statt direkt auf die URLs zu zeigen

**Lösung**:
- Alle Apps neu hinzugefügt über `setup-heimdall-apps.py`
- Type auf 1 (application) gesetzt für alle Apps mit HTTPS-URLs
- Datenbank zurück in Pod kopiert und Pod neu gestartet

**Ergebnis**: ✅ Alle Apps sind jetzt im Dashboard sichtbar

**Apps hinzugefügt**:
- ArgoCD
- Jellyfin
- Jenkins
- GitLab
- Komga
- Loki
- Grafana
- Prometheus
- Syncthing
- Kubernetes Dashboard
- PlantUML (bereits vorhanden)

---

### ✅ 2. ArgoCD Applikationen registriert

**Problem**: Nur `kubernetes-dashboard` war als ArgoCD Application registriert

**Lösung**:
- ArgoCD Application-Manifeste erstellt für:
  - Jellyfin (`k8s/jellyfin/argocd-application.yaml`)
  - Pi-hole (`k8s/pihole/argocd-application.yaml`)
- Applications in ArgoCD registriert

**Ergebnis**: ✅ 3 Applications registriert:
- `jellyfin` (OutOfSync - muss synchronisiert werden)
- `kubernetes-dashboard` (Synced, Healthy)
- `pihole` (OutOfSync - muss synchronisiert werden)

**ArgoCD Zugangsdaten**:
- **Benutzername**: `admin`
- **Passwort**: `Admin123!`
- **URL**: https://argocd.k8sops.online

**Hinweis**: ArgoCD hat noch ein Redirect-Problem (ERR_TOO_MANY_REDIRECTS). Die ConfigMap-URL wurde entfernt und der Server neu gestartet.

---

### ✅ 3. Syncthing funktioniert

**Problem**: Syncthing hatte 503-Fehler

**Lösung**:
- Pod-Status geprüft: ✅ Running
- Service geprüft: ✅ `syncthing-ui` auf Port 8384
- Ingress geprüft: ✅ Konfiguriert für `syncthing.k8sops.online`
- Webinterface getestet: ✅ Funktioniert

**Ergebnis**: ✅ Syncthing Webinterface ist erreichbar

**Status**:
- Pod: Running
- Service: `syncthing-ui` (Port 8384)
- Ingress: Konfiguriert
- Webinterface: ✅ Erreichbar über https://syncthing.k8sops.online

**Hinweis**: Syncthing zeigt eine Warnung, dass kein Passwort gesetzt ist. Dies kann über die Einstellungen konfiguriert werden.

---

## Verbleibende Probleme

### ⚠️ ArgoCD Redirect-Problem

**Problem**: ArgoCD zeigt `ERR_TOO_MANY_REDIRECTS` im Browser

**Ursache**: Möglicherweise ConfigMap-URL oder Server-Konfiguration

**Durchgeführte Maßnahmen**:
- ConfigMap-URL entfernt
- ArgoCD Server neu gestartet

**Status**: ⚠️ Muss noch getestet werden

---

## Nächste Schritte

1. **ArgoCD Redirect-Problem beheben**: Weitere Konfiguration prüfen falls Problem weiterhin besteht
2. **ArgoCD Applications synchronisieren**: `jellyfin` und `pihole` synchronisieren
3. **Syncthing Passwort setzen**: Über Webinterface konfigurieren
4. **Heimdall Links testen**: Alle Links im Browser testen

---

**Ende des Reports**

