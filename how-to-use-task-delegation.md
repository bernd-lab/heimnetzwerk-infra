# Wie nutze ich die Task-Delegation?

## Konzept

Die `task-delegation-current.md` listet alle offenen Tasks auf, die an spezialisierte Agenten delegiert wurden. Du kannst diese Tasks abarbeiten, indem du die entsprechenden Agenten aufrufst.

## Vorgehen

### Option 1: Direkt mit Agenten arbeiten (Empfohlen)

Nutze die spezialisierten Agenten, um die Tasks abzuarbeiten:

#### Beispiel 1: GitLab Login testen
```
/gitlab-github-expert

Teste den GitLab Login im Browser: https://gitlab.k8sops.online
Login: root / TempPass123!
Prüfe ob das CSRF-Problem behoben ist.
```

#### Beispiel 2: Docker Images aufräumen
```
/debian-server-expert

Räume die Docker Images auf dem Debian-Server auf:
- Prüfe welche Images vorhanden sind
- Entferne ungenutzte Images (gitlab, jenkins, jellyfin, pihole, nginx)
- Prüfe ob libvirt-exporter und cadvisor noch benötigt werden
```

#### Beispiel 3: Secrets verschlüsseln
```
/secrets-expert

Verschlüssele das GitLab Root-Passwort:
- Wert: TempPass123!
- Verwende: ./scripts/encrypt-secret.sh GITLAB_ROOT_PASSWORD "TempPass123!"
```

### Option 2: Router verwenden (Automatisch)

Nutze den Router, der automatisch die richtigen Agenten auswählt:

```
/router

Ich möchte GitLab testen und Docker aufräumen.
```

Der Router delegiert dann automatisch an:
- `/gitlab-github-expert` für GitLab
- `/debian-server-expert` für Docker

### Option 3: Ask-All für komplexe Tasks

Wenn mehrere Bereiche betroffen sind:

```
/ask-all

Was sollte ich als nächstes angehen? Ich habe GitLab CSRF-Fix gemacht und möchte jetzt weiterarbeiten.
```

## Priorisierung

### Sofort (kann jetzt gemacht werden)

1. **GitLab Login testen** → `/gitlab-github-expert`
2. **GitLab Root-Passwort verschlüsseln** → `/secrets-expert`
3. **Docker Images aufräumen** → `/debian-server-expert`

### Benötigt Input (wenn du bereit bist)

4. **Fritzbox-Konfiguration** → `/fritzbox-expert` (braucht Passwort)
5. **GitHub/GitLab Tokens** → `/gitlab-github-expert` + `/secrets-expert` (manuelle Erstellung)

### Monitoring (läuft automatisch)

6. **GitLab Stabilität** → `/k8s-expert` + `/monitoring-expert`

## Praktisches Beispiel

### Schritt 1: GitLab Login testen
```
/gitlab-github-expert

Teste den GitLab Login:
- URL: https://gitlab.k8sops.online
- Login: root / TempPass123!
- Prüfe ob CSRF-Problem behoben ist
- Wenn erfolgreich: Speichere das Passwort verschlüsselt
```

### Schritt 2: Wenn Login funktioniert, Secrets verschlüsseln
```
/secrets-expert

Verschlüssele das GitLab Root-Passwort "TempPass123!" als GITLAB_ROOT_PASSWORD
```

### Schritt 3: Docker aufräumen
```
/debian-server-expert

Räume Docker Images auf dem Server 192.168.178.54 auf:
- Prüfe welche Images vorhanden sind
- Entferne ungenutzte Images
- Prüfe Speicherplatz-Gewinn
```

### Schritt 4: Git-Commits vorbereiten
```
/gitlab-github-expert

Bereite Git-Commits vor:
- Prüfe welche Dateien geändert/neu sind
- Committe wichtige Dateien (Agenten, Scripts, Dokumentation)
- WICHTIG: Keine Secrets committen!
```

## Wichtige Hinweise

1. **Secrets niemals committen**: Die `.gitignore` ist konfiguriert, aber prüfe vor Commits
2. **Agenten haben Kontext**: Jeder Agent kennt seine spezialisierten Aufgaben
3. **Router nutzen**: Bei Unsicherheit, welcher Agent zuständig ist
4. **Ask-All nutzen**: Für komplexe Fragen, die mehrere Bereiche betreffen

## Task-Status aktualisieren

Wenn du Tasks abarbeitest, kannst du die `task-delegation-current.md` als Referenz nutzen:
- ✅ Aufgaben als erledigt markieren
- 📋 Neue Tasks hinzufügen
- ⚠️ Tasks die Input benötigen vermerken

## Nächste Schritte

**Empfehlung**: Starte mit den "Sofort ausführbaren" Tasks:

1. `/gitlab-github-expert` → GitLab Login testen
2. `/secrets-expert` → GitLab Root-Passwort verschlüsseln
3. `/debian-server-expert` → Docker Images aufräumen

Diese können sofort gemacht werden, ohne auf Input zu warten!

