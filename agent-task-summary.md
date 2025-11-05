# Agent Task Summary - Was zu tun ist

## ✅ Sofort ausführbar (ohne Input)

### `/gitlab-github-expert`
1. **GitLab Login testen** (Browser: https://gitlab.k8sops.online, root/TempPass123!)
2. **Git-Commits vorbereiten** (alle neuen Dateien, außer Secrets)

### `/secrets-expert`
1. **GitLab Root-Passwort verschlüsseln**: `./scripts/encrypt-secret.sh GITLAB_ROOT_PASSWORD "TempPass123!"`
2. **Cloudflare Token extrahieren** aus Kubernetes und verschlüsseln

### `/debian-server-expert`
1. **Docker Images aufräumen** (5.66GB freigeben)
2. **Monitoring-Container prüfen** (libvirt-exporter, cadvisor)

### `/k8s-expert`
1. **GitLab Pod-Status analysieren** (warum Restart vor 6m58s?)
2. **Logs prüfen** auf weitere Fehler

---

## ⚠️ Benötigt Input

### `/fritzbox-expert`
1. **DNS-Rebind-Schutz aktivieren** (Passwort benötigt)
2. **UPnP prüfen/deaktivieren** (Passwort benötigt)
3. **TR-064 prüfen** (Passwort benötigt)

### `/gitlab-github-expert` + `/secrets-expert`
1. **GitHub Token erstellen** (manuell in GitHub)
2. **GitLab Token erstellen** (manuell in GitLab)
3. **Tokens verschlüsselt speichern**
4. **GitHub Secrets via API erstellen**
5. **GitLab CI Variables erstellen**

---

## ⏳ Monitoring (läuft)

### `/monitoring-expert` + `/k8s-expert`
1. **GitLab Stabilität beobachten** (24h, aktuell 19m, 1 Restart)

---

## 📋 Dokumentation

### `/infrastructure-expert`
1. **README.md aktualisieren**
2. **Status-Reports konsolidieren**

---

## Nächste Schritte

**Priorität 1** (jetzt):
1. GitLab Login testen
2. GitLab Root-Passwort verschlüsseln
3. Docker Images aufräumen

**Priorität 2** (wenn Input vorhanden):
4. Fritzbox-Konfiguration
5. GitHub/GitLab Tokens erstellen

**Priorität 3** (laufend):
6. GitLab Stabilität überwachen
7. Dokumentation aktualisieren

