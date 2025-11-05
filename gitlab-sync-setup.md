# GitLab Sync Setup

## Übersicht

Dieses Repository ist jetzt für automatischen Sync zwischen GitHub und GitLab konfiguriert.

## Setup

### 1. GitLab Repository erstellen

1. Gehe zu `https://gitlab.k8sops.online`
2. Erstelle ein neues Projekt: `heimnetzwerk-infra`
3. Wähle den Namespace/Group: `bernd-lab`
4. **Wichtig**: Lasse das Repository leer (kein README, keine .gitignore)

### 2. GitHub Actions Token (für GitLab)

1. Gehe zu GitLab: Settings → Access Tokens
2. Erstelle einen Token mit `write_repository` Berechtigung
3. Kopiere den Token
4. Gehe zu GitHub: Settings → Secrets and variables → Actions
5. Füge einen neuen Secret hinzu: `GITLAB_TOKEN` mit dem GitLab-Token

### 3. GitLab CI Token (für GitHub)

1. Gehe zu GitHub: Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Erstelle einen Token mit `repo` Berechtigung
3. Kopiere den Token
4. Gehe zu GitLab: Settings → CI/CD → Variables
5. Füge eine Variable hinzu: `GITHUB_TOKEN` (masked) mit dem GitHub-Token

### 4. Lokaler Sync (Optional)

Falls du lokal zu beiden pushen willst:

```bash
# GitLab Remote hinzufügen
git remote add gitlab https://gitlab.k8sops.online/bernd-lab/heimnetzwerk-infra.git

# Zu beiden pushen
git push origin main
git push gitlab main
```

Oder mit einem Push-Command, der beide pusht:

```bash
# Git Config für beide Remotes
git remote set-url --add --push origin https://github.com/bernd-lab/heimnetzwerk-infra.git
git remote set-url --add --push origin https://gitlab.k8sops.online/bernd-lab/heimnetzwerk-infra.git

# Dann einfach:
git push origin main  # Pusht zu beiden
```

## Automatischer Sync

### GitHub → GitLab
- Wird automatisch ausgelöst bei jedem Push zu `main` auf GitHub
- GitHub Actions Workflow: `.github/workflows/sync-to-gitlab.yml`

### GitLab → GitHub
- Wird automatisch ausgelöst bei jedem Push zu `main` auf GitLab
- GitLab CI Pipeline: `.gitlab-ci.yml`

## Manuelle Sync

Falls der automatische Sync nicht funktioniert:

```bash
# Von GitHub zu GitLab
git fetch origin
git push gitlab main

# Von GitLab zu GitHub
git fetch gitlab
git push origin main
```

## Troubleshooting

### GitHub Actions schlägt fehl
- Prüfe, ob `GITLAB_TOKEN` Secret korrekt gesetzt ist
- Prüfe, ob das GitLab-Repository existiert
- Prüfe GitLab-Logs für Details

### GitLab CI schlägt fehl
- Prüfe, ob `GITHUB_TOKEN` Variable korrekt gesetzt ist
- Prüfe GitLab CI/CD Pipeline Logs
- Stelle sicher, dass das GitHub-Repository existiert

### Merge-Konflikte
- Bei Konflikten zwischen beiden Repositories:
  - Entscheide, welche Version die "Master"-Version ist
  - Merge die Änderungen manuell
  - Push zu beiden Repositories

## Best Practices

1. **Primary Repository**: GitHub ist das primäre Repository
2. **Commits**: Mache alle Änderungen in GitHub, GitLab wird automatisch synchronisiert
3. **Backup**: GitLab dient als Backup und Alternative
4. **Konflikte vermeiden**: Ändere nicht direkt in beiden Repositories gleichzeitig

## Alternative: GitLab Mirror

Falls du GitLab als Mirror verwenden willst:

1. GitLab: Settings → Repository → Mirroring repositories
2. Source repository: `https://github.com/bernd-lab/heimnetzwerk-infra.git`
3. Mirror direction: Pull
4. Authentication method: Password (GitHub Personal Access Token)

Dies ist einfacher, aber weniger flexibel als der CI/CD-basierte Sync.

