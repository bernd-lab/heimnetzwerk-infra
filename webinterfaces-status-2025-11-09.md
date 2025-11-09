# Webinterfaces Status & Zugangsdaten - 2025-11-09

**Erstellt**: 2025-11-09  
**Aktualisiert**: 2025-11-09  
**Status**: Alle Webinterfaces dokumentiert, Check-Skript erstellt

---

## 📋 Übersicht aller Webinterfaces

**Gesamt**: 13 Ingress-Routen

### ✅ Mit Zugangsdaten dokumentiert (6)

1. **ArgoCD** - https://argocd.k8sops.online
   - Credentials: `admin:Admin123!`
   - Status: ✅ Funktioniert

2. **GitLab** - https://gitlab.k8sops.online
   - Credentials: `root:BXE1uwajqBDLgsWiesGB1081`
   - Status: ✅ Funktioniert

3. **Grafana** - https://grafana.k8sops.online
   - Credentials: `admin:Montag69`
   - Status: ✅ Funktioniert

4. **Pi-hole** - https://pihole.k8sops.online/admin/
   - Credentials: `admin:cK1lubq8C7MZrEgipfUpEAc0`
   - Status: ✅ Funktioniert

5. **Jellyfin** - https://jellyfin.k8sops.online
   - Credentials: `bernd:Montag69`
   - Status: ✅ Funktioniert

6. **Komga** - https://komga.k8sops.online
   - Credentials: `admin@k8sops.online:1zBlOIBqlGTHxb15GnGqyPOi`
   - Status: ✅ Funktioniert

### ✅ Ohne Login erforderlich (4)

7. **Heimdall** - https://heimdall.k8sops.online
   - Status: ✅ Funktioniert (öffentliches Dashboard)

8. **PlantUML** - https://plantuml.k8sops.online
   - Status: ✅ Funktioniert

9. **Prometheus** - https://prometheus.k8sops.online
   - Status: ✅ Funktioniert (öffentlich)

10. **Kubernetes Dashboard** - https://dashboard.k8sops.online
    - Status: ✅ Funktioniert (Service Account Token erforderlich)

### ⚠️ Spezialfälle (3)

11. **Syncthing** - https://syncthing.k8sops.online
    - Status: ✅ Funktioniert (erste Einrichtung über Webinterface erforderlich)
    - Zugangsdaten: Noch nicht eingerichtet

12. **Jenkins** - https://jenkins.k8sops.online
    - Status: ⚠️ 503 Service Unavailable (Deployment auf 0 Replicas - deaktiviert)
    - Hinweis: Bewusst deaktiviert, da nicht kritisch

13. **Loki** - https://loki.k8sops.online
    - Status: ⚠️ 404 Not Found (normal, Loki hat kein Web-UI auf Root-Pfad)
    - Hinweis: Loki ist ein Log-Aggregator, kein Web-Interface

---

## 🔧 Check-Skript

**Skript**: `scripts/check-webinterfaces.sh`

**Funktionen**:
- ✅ Prüft alle 13 Webinterfaces auf Erreichbarkeit
- ✅ Prüft Pod-Status für jeden Service
- ✅ Prüft HTTP-Status-Codes
- ✅ Prüft SSL-Zertifikate (für HTTPS)
- ✅ Optional: Auth-Tests für geschützte Services
- ✅ Erstellt Log-Datei mit Timestamps
- ✅ Farbige Ausgabe (grün/gelb/rot)
- ✅ Exit-Codes: 0=OK, 1=Fehler, 2=Warnungen

**Verwendung**:
```bash
# Einfacher Check
./scripts/check-webinterfaces.sh

# Mit Log-Datei
LOG_FILE=/tmp/webinterfaces-check.log ./scripts/check-webinterfaces.sh

# In Cron-Job einbinden (täglich um 2 Uhr)
0 2 * * * /home/bernd/infra-0511/scripts/check-webinterfaces.sh >> /var/log/webinterfaces-check.log 2>&1
```

---

## 📊 Zugangsdaten-Verwaltung

**Dokumentation**: `webinterfaces-zugangsdaten-2025-11-08.md`

**Aktuelle Zugangsdaten**:
- ✅ ArgoCD: `admin:Admin123!`
- ✅ GitLab: `root:BXE1uwajqBDLgsWiesGB1081`
- ✅ Grafana: `admin:Montag69`
- ✅ Pi-hole: `admin:cK1lubq8C7MZrEgipfUpEAc0`
- ✅ Jellyfin: `bernd:Montag69`
- ✅ Komga: `admin@k8sops.online:1zBlOIBqlGTHxb15GnGqyPOi`

**Aus Kubernetes Secrets extrahieren**:
```bash
# ArgoCD
kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d

# Grafana
kubectl get secret grafana-secrets -n monitoring -o jsonpath='{.data.admin-password}' | base64 -d

# Pi-hole
kubectl get secret pihole-secret -n pihole -o jsonpath='{.data.WEBPASSWORD}' | base64 -d
```

---

## ✅ Status-Zusammenfassung

**Alle Webinterfaces**:
- ✅ **10 funktionieren** (inkl. Spezialfälle)
- ⚠️ **2 erwartete Warnungen** (Jenkins deaktiviert, Loki kein Web-UI)
- ⚠️ **1 benötigt Einrichtung** (Syncthing)

**Zugangsdaten**:
- ✅ **6 Services** haben dokumentierte Zugangsdaten
- ✅ **4 Services** benötigen kein Login
- ⚠️ **1 Service** (Syncthing) benötigt erste Einrichtung

**Check-Skript**:
- ✅ Erstellt und getestet
- ✅ Kann regelmäßig ausgeführt werden
- ✅ Erstellt Log-Dateien mit Timestamps

---

## 🔄 Regelmäßige Checks

**Empfohlene Häufigkeit**:
- **Täglich**: Automatischer Check per Cron-Job
- **Wöchentlich**: Manuelle Überprüfung der Log-Dateien
- **Bei Problemen**: Sofortiger Check mit `./scripts/check-webinterfaces.sh`

**Cron-Job Beispiel**:
```bash
# Täglich um 2 Uhr morgens
0 2 * * * /home/bernd/infra-0511/scripts/check-webinterfaces.sh >> /var/log/webinterfaces-check.log 2>&1
```

---

**Ende des Dokuments**

