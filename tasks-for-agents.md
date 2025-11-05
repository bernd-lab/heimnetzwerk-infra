# Tasks für Spezialisierte Agenten

## `/gitlab-github-expert`: GitLab Login-Test + Git-Commits

### Task 1: GitLab Login testen
```bash
# Browser-Test: https://gitlab.k8sops.online
# Login: root / TempPass123!
# Prüfen ob CSRF-Problem behoben
```

### Task 2: Git-Commits vorbereiten
- Alle neuen Dateien prüfen
- `.cursor/` committen (Agenten-System)
- `scripts/` committen (Secret-Management)
- `secrets/` committen (nur Templates/Metadaten, keine .age Dateien!)
- `.gitignore` committen
- Dokumentation committen

**Wichtig**: Keine Secrets committen! Nur Templates und Metadaten.

---

## `/k8s-expert`: GitLab Stabilität + Monitoring

### Task 1: GitLab Pod-Status prüfen
```bash
kubectl get pods -n gitlab
kubectl logs -n gitlab gitlab-7f86dc7f4f-v429r --tail=100
kubectl describe pod -n gitlab gitlab-7f86dc7f4f-v429r
```

### Task 2: Restarts analysieren
- Warum Restart vor 6m58s?
- Prüfen ob weitere Probleme auftreten
- Logs auf Fehler prüfen

---

## `/debian-server-expert`: Docker Images aufräumen

### Task 1: Docker Images prüfen
```bash
ssh bernd@192.168.178.54 "docker images"
ssh bernd@192.168.178.54 "docker system df"
```

### Task 2: Ungenutzte Images entfernen
```bash
# Images die entfernt werden können:
# - gitlab/gitlab-ce (3.8GB)
# - jenkins/jenkins (472MB)
# - jellyfin/jellyfin (1.25GB)
# - pihole/pihole (90.1MB)
# - nginx (52.8MB)
```

### Task 3: Monitoring-Container prüfen
- libvirt-exporter: Wird noch benötigt?
- cadvisor: Wird noch benötigt?

---

## `/fritzbox-expert`: Fritzbox-Konfiguration

### Task 1: DNS-Rebind-Schutz aktivieren
- Browser: http://192.168.178.1
- Menü: Internet → Filter → DNS-Rebind-Schutz
- Aktivieren

### Task 2: UPnP prüfen
- Menü: Heimnetz → Netzwerk → Netzwerkeinstellungen
- UPnP prüfen
- Deaktivieren falls nicht benötigt

### Task 3: TR-064 prüfen
- TR-064 (App-Zugriff) prüfen
- Beschränken falls möglich

**Hinweis**: Passwort wird während der Arbeit benötigt.

---

## `/secrets-expert`: Secrets erstellen und verschlüsseln

### Task 1: GitLab Root-Passwort verschlüsseln
```bash
./scripts/encrypt-secret.sh GITLAB_ROOT_PASSWORD "TempPass123!"
```

### Task 2: Cloudflare API Token extrahieren
```bash
# Aus Kubernetes Secret extrahieren
kubectl get secret -n cert-manager cloudflare-api-token -o jsonpath='{.data.api-token}' | base64 -d

# Dann verschlüsseln
./scripts/encrypt-secret.sh CLOUDFLARE_API_TOKEN "<token-value>"
```

### Task 3: SSH Key prüfen
- Prüfen ob SSH Key in ~/.ssh/ vorhanden
- Falls vorhanden, verschlüsselt speichern

### Task 4: Dokumentation aktualisieren
- `secrets-inventory.yaml` aktualisieren
- Status auf "active" setzen für erstellte Secrets

---

## `/gitlab-github-expert` + `/secrets-expert`: GitHub/GitLab Tokens

### Task 1: GitHub Token erstellen
- GitHub → Settings → Developer settings → Personal access tokens
- Scopes: `repo`, `workflow`, `admin:org`
- Token verschlüsselt speichern

### Task 2: GitLab Token erstellen
- GitLab → Preferences → Access Tokens
- Scopes: `api`, `read_repository`, `write_repository`
- Token verschlüsselt speichern

### Task 3: GitHub Secrets via API erstellen
```bash
# Mit Python Script
python3 scripts/create-github-secret.py <token> <owner> <repo> <secret-name> <secret-value>
```

### Task 4: GitLab CI Variables erstellen
- Via GitLab API oder Web-Interface
- GITHUB_TOKEN und GITLAB_TOKEN als CI Variables

---

## `/monitoring-expert`: GitLab Monitoring

### Task 1: GitLab Metriken prüfen
- Prometheus Targets prüfen
- GitLab Metriken sammeln
- Pod-Restarts überwachen

### Task 2: Logs analysieren
- GitLab Logs auf Fehler prüfen
- Sidekiq Jobs überwachen
- Performance-Metriken

---

## `/infrastructure-expert`: Dokumentation

### Task 1: README.md aktualisieren
- Neue Agenten dokumentieren
- Secret-Management-System dokumentieren
- Links zu wichtigen Dokumenten

### Task 2: Status-Reports konsolidieren
- Temporäre Reports identifizieren
- Wichtige Informationen in permanente Dokumentation übernehmen
- Alte Reports aufräumen

---

## `/dns-expert`: DNS-Prüfung (optional)

### Task 1: DNS-Auflösung prüfen
- GitLab-Domain testen
- Pi-hole Custom Records prüfen
- Cloudflare DNS prüfen

---

## Zusammenfassung

**Sofort ausführbar**:
1. GitLab Login-Test
2. GitLab Root-Passwort verschlüsseln
3. Docker Images aufräumen
4. Git-Commits vorbereiten

**Benötigt Input**:
5. Fritzbox-Passwort (für Konfiguration)
6. GitHub/GitLab Tokens (manuelle Erstellung)

**Monitoring**:
7. GitLab Stabilität beobachten

