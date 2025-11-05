# Secrets Management - Agent Guide

## Übersicht

Dieses Dokument beschreibt, wie Agenten auf verschlüsselte Secrets zugreifen können, die sicher in `~/.cursor/secrets/` gespeichert sind.

## Secret-Kategorien

### System-Key-verschlüsselte Secrets
- **Verschlüsselung**: Automatisch mit System-Key
- **Zugriff**: Automatisch beim Laden von `load-secrets.sh`
- **Typ**: API-Tokens, SSH-Keys, Webinterface-Credentials
- **Location**: `~/.cursor/secrets/system-key/*.age`

### Passwort-verschlüsselte Secrets
- **Verschlüsselung**: Mit Passphrase (interaktiv)
- **Zugriff**: Manuell mit `decrypt-secret.sh`
- **Typ**: Kritische Passwörter (Fritzbox, Root)
- **Location**: `~/.cursor/secrets/password/*.age`

## Secret-Zugriff für Agenten

### Automatisches Laden (System-Key-Secrets)

```bash
# Alle System-Key-verschlüsselten Secrets laden
source scripts/load-secrets.sh

# Secrets sind jetzt als Environment-Variablen verfügbar
echo $GITHUB_TOKEN
echo $GITLAB_TOKEN
echo $CLOUDFLARE_API_TOKEN
```

### Manuelles Laden (Passwort-Secrets)

```bash
# Einzelnes Passwort-Secret entschlüsseln
FRITZBOX_PASSWORD=$(scripts/decrypt-secret.sh FRITZBOX_ADMIN_PASSWORD password)
```

### In Agent-Commands verwenden

```bash
#!/bin/bash
# In einem Agent-Command
source scripts/load-secrets.sh

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN nicht verfügbar"
    exit 1
fi

# Secret verwenden
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/bernd-lab/heimnetzwerk-infra
```

## Verfügbare Secrets

### System-Key-verschlüsselt (automatisch verfügbar)
- `GITHUB_TOKEN` - GitHub Personal Access Token
- `GITLAB_TOKEN` - GitLab Personal Access Token
- `CLOUDFLARE_API_TOKEN` - Cloudflare API Token
- `DEBIAN_SERVER_SSH_KEY` - SSH Private Key für Debian-Server
- `GITLAB_ROOT_PASSWORD` - GitLab Root-Passwort

### Passwort-verschlüsselt (manuell)
- `FRITZBOX_ADMIN_PASSWORD` - FRITZ!Box Admin-Passwort
- `ROOT_PASSWORDS` - Root-Passwörter für Server

## Best Practices für Agenten

### 1. Secrets niemals loggen
```bash
# ❌ FALSCH: Secret im Klartext loggen
echo "Token: $GITHUB_TOKEN"

# ✅ RICHTIG: Nur Metadaten loggen
echo "GitHub API-Aufruf erfolgreich"
```

### 2. Secrets nur bei Bedarf laden
```bash
# Lade Secrets nur, wenn sie benötigt werden
source scripts/load-secrets.sh

# Verwende Secret
do_something_with_token "$GITHUB_TOKEN"

# Optional: Secret entladen (umgebungsvariable löschen)
unset GITHUB_TOKEN
```

### 3. Fehlerbehandlung
```bash
source scripts/load-secrets.sh

if [ -z "$GITHUB_TOKEN" ]; then
    echo "Error: GITHUB_TOKEN nicht verfügbar"
    echo "Hinweis: Secret muss mit 'encrypt-secret.sh' erstellt werden"
    exit 1
fi
```

### 4. Passwort-Secrets
Passwort-verschlüsselte Secrets benötigen interaktive Passphrase-Eingabe und können nicht automatisch geladen werden.

```bash
# Nur für manuelle Tasks, nicht für Automatisierung
FRITZBOX_PASSWORD=$(scripts/decrypt-secret.sh FRITZBOX_ADMIN_PASSWORD password)
```

## Agent-spezifische Secrets

### DNS-Expert
- `CLOUDFLARE_API_TOKEN`
- `DEBIAN_SERVER_SSH_KEY`

### GitLab/GitHub-Expert
- `GITHUB_TOKEN`
- `GITLAB_TOKEN`
- `GITLAB_ROOT_PASSWORD`
- `DEBIAN_SERVER_SSH_KEY`

### Fritzbox-Expert
- `FRITZBOX_ADMIN_PASSWORD` (Passwort-verschlüsselt)

### Debian-Server-Expert
- `DEBIAN_SERVER_SSH_KEY`
- `ROOT_PASSWORDS` (Passwort-verschlüsselt)

### K8s-Expert
- `DEBIAN_SERVER_SSH_KEY`
- `CLOUDFLARE_API_TOKEN`

### Secrets-Expert
- Alle Secrets (verwaltet alle)

### Security-Expert
- `GITHUB_TOKEN`
- `GITLAB_TOKEN`
- `FRITZBOX_ADMIN_PASSWORD`
- `ROOT_PASSWORDS`

### Infrastructure-Expert
- `FRITZBOX_ADMIN_PASSWORD`
- `DEBIAN_SERVER_SSH_KEY`
- `CLOUDFLARE_API_TOKEN`

## Troubleshooting

### Secret nicht verfügbar
```bash
# Prüfe ob Secret existiert
ls -la ~/.cursor/secrets/system-key/GITHUB_TOKEN.age

# Prüfe System-Key
ls -la ~/.cursor/secrets/system-key.txt
```

### Secret kann nicht entschlüsselt werden
```bash
# Prüfe System-Key-Berechtigungen
chmod 600 ~/.cursor/secrets/system-key.txt

# Prüfe Secret-Datei-Berechtigungen
chmod 600 ~/.cursor/secrets/system-key/GITHUB_TOKEN.age
```

### Passwort-Secret benötigt Passphrase
Passwort-verschlüsselte Secrets benötigen immer die Passphrase. Diese kann nicht automatisiert werden.

## Weitere Informationen

- **Shared Context**: `.cursor/context/secrets-context.md`
- **User Guide**: `secrets-management-user-guide.md`
- **Secret Templates**: `secrets/secrets-template.yaml`
- **Secret Metadata**: `secrets/secrets.metadata.yaml`

