# Token-Erstellung Anleitung für GitHub und GitLab

**Erstellt**: 2025-11-05
**Zweck**: Personal Access Tokens für GitHub/GitLab Sync erstellen

## Übersicht

Für den automatischen Sync zwischen GitHub und GitLab benötigen wir:
1. **GitHub Personal Access Token** - Für GitLab CI (GitLab → GitHub Sync)
2. **GitLab Personal Access Token** - Für GitHub Actions (GitHub → GitLab Sync)

## GitHub Personal Access Token erstellen

### Schritt 1: Zu GitHub navigieren
1. Gehe zu: https://github.com/settings/tokens
2. Falls nicht eingeloggt: Login mit deinem GitHub-Account

### Schritt 2: Neuen Token erstellen
1. Klicke auf **"Generate new token"** → **"Generate new token (classic)"**
2. **Token-Name**: z.B. `heimnetzwerk-infra-gitlab-sync`
3. **Ablauf**: Empfohlen: 90 Tage (oder 1 Jahr)
4. **Scopes auswählen**:
   - ✅ `repo` - Vollständiger Repository-Zugriff
   - ✅ `workflow` - GitHub Actions Workflows verwalten
   - ✅ `admin:org` (optional) - Falls Organisation-Token benötigt wird
5. Klicke auf **"Generate token"**

### Schritt 3: Token kopieren
⚠️ **WICHTIG**: Token wird nur einmal angezeigt!
- Kopiere den Token sofort
- Speichere ihn sicher (wird verschlüsselt gespeichert)

### Schritt 4: Token verschlüsselt speichern
Nach dem Kopieren:
```bash
./scripts/encrypt-secret.sh GITHUB_TOKEN "dein-token-hier"
```

## GitLab Personal Access Token erstellen

### Schritt 1: Zu GitLab navigieren
1. Gehe zu: https://gitlab.k8sops.online
2. Login mit: `root` / `TempPass123!`
   - Falls Login-Probleme: Siehe GitLab 502-Fix Dokumentation

### Schritt 2: Neuen Token erstellen
1. Gehe zu: **User Settings** → **Access Tokens**
   - Oder direkt: https://gitlab.k8sops.online/-/user_settings/personal_access_tokens
2. **Token-Name**: z.B. `heimnetzwerk-infra-github-sync`
3. **Ablauf**: Empfohlen: 90 Tage (oder 1 Jahr)
4. **Scopes auswählen**:
   - ✅ `api` - Vollständiger API-Zugriff
   - ✅ `read_repository` - Repository lesen
   - ✅ `write_repository` - Repository schreiben
5. Klicke auf **"Create personal access token"**

### Schritt 3: Token kopieren
⚠️ **WICHTIG**: Token wird nur einmal angezeigt!
- Kopiere den Token sofort
- Token beginnt mit `glpat-`
- Speichere ihn sicher (wird verschlüsselt gespeichert)

### Schritt 4: Token verschlüsselt speichern
Nach dem Kopieren:
```bash
./scripts/encrypt-secret.sh GITLAB_TOKEN "dein-token-hier"
```

## Bestehende Token prüfen

### GitLab Token bereits vorhanden?
In der Dokumentation wurde ein Token gefunden:
- `glpat-q9cRQjBeN--9eKsPzjZn5G86MQp1OjEH.01.0w11ag1un`

**Prüfung**:
```bash
# Token testen
GITLAB_TOKEN="glpat-q9cRQjBeN--9eKsPzjZn5G86MQp1OjEH.01.0w11ag1un"
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  https://gitlab.k8sops.online/api/v4/user
```

Falls Token funktioniert:
```bash
# Token verschlüsselt speichern
./scripts/encrypt-secret.sh GITLAB_TOKEN "glpat-q9cRQjBeN--9eKsPzjZn5G86MQp1OjEH.01.0w11ag1un"
```

## Token in GitHub Secrets speichern

### GitHub Actions Secret (für GitLab Token)
1. Gehe zu: https://github.com/bernd-lab/heimnetzwerk-infra/settings/secrets/actions
2. Klicke auf **"New repository secret"**
3. **Name**: `GITLAB_TOKEN`
4. **Value**: GitLab Token (aus verschlüsseltem Secret entschlüsseln)
5. Klicke auf **"Add secret"**

### Secret entschlüsseln:
```bash
scripts/decrypt-secret.sh GITLAB_TOKEN system-key
```

## Token in GitLab CI Variables speichern

### GitLab CI Variable (für GitHub Token)
1. Gehe zu: https://gitlab.k8sops.online/bernd-lab/heimnetzwerk-infra/-/settings/ci_cd
2. Scrolle zu **"Variables"**
3. Klicke auf **"Expand"** → **"Add variable"**
4. **Key**: `GITHUB_TOKEN`
5. **Value**: GitHub Token (aus verschlüsseltem Secret entschlüsseln)
6. ✅ **Masked** aktivieren (wichtig!)
7. Klicke auf **"Add variable"**

### Secret entschlüsseln:
```bash
scripts/decrypt-secret.sh GITHUB_TOKEN system-key
```

## Token-Status prüfen

### GitHub Token testen:
```bash
source scripts/load-secrets.sh
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user
```

### GitLab Token testen:
```bash
source scripts/load-secrets.sh
curl -H "PRIVATE-TOKEN: $GITLAB_TOKEN" \
  https://gitlab.k8sops.online/api/v4/user
```

## Automatische Token-Erstellung (Alternative)

Falls du möchtest, dass ich die Token-Erstellung per Browser-Automatisierung durchführe:

1. **GitHub**: Bitte dich bei GitHub einloggen (ich kann dann die Token-Erstellung durchführen)
2. **GitLab**: Versuche ich per Browser-Automatisierung (falls Login funktioniert)

**Oder**: Du führst die Schritte manuell durch und teilst mir die Tokens mit, dann speichere ich sie verschlüsselt.

## Nächste Schritte

Nach Token-Erstellung:
1. ✅ Tokens verschlüsselt speichern
2. ✅ Tokens in GitHub Secrets speichern
3. ✅ Tokens in GitLab CI Variables speichern
4. ✅ Sync testen (Push zu GitHub/GitLab)

## Troubleshooting

### Token funktioniert nicht
- Prüfe Ablaufdatum
- Prüfe Scopes (haben alle benötigten Berechtigungen)
- Prüfe Token-Format (GitHub: beginnt mit `ghp_`, GitLab: beginnt mit `glpat-`)

### Login-Probleme
- **GitHub**: Normale Login-Seite
- **GitLab**: Falls 502-Fehler → Siehe `gitlab-502-fix-analysis.md`

### Token nicht gefunden
- Token wurde nur einmal angezeigt
- Muss neu erstellt werden
- Alte Token können in Settings gelöscht werden

