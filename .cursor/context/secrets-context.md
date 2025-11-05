# Secrets Context für Agenten

## Übersicht

Agenten können auf verschlüsselte Secrets zugreifen, die sicher in `~/.cursor/secrets/` gespeichert sind. Secrets werden mit `age` (Age Encryption) verschlüsselt und niemals im Klartext im Repository gespeichert.

## Secret-Kategorien

### 1. System-Key-verschlüsselte Secrets (weniger kritisch)
- **Location**: `~/.cursor/secrets/system-key/`
- **Verschlüsselung**: Automatisch mit System-Key
- **Zugriff**: Automatisch beim Laden von `load-secrets.sh`
- **Beispiele**: API-Tokens, SSH-Keys, Webinterface-Credentials

### 2. Passwort-verschlüsselte Secrets (kritisch)
- **Location**: `~/.cursor/secrets/password/`
- **Verschlüsselung**: Mit Passphrase (interaktiv)
- **Zugriff**: Manuell mit `decrypt-secret.sh`
- **Beispiele**: Fritzbox-Passwort, Root-Passwörter

## Secret-Zugriff für Agenten

### Automatisches Laden (System-Key-Secrets)

```bash
# Alle System-Key-verschlüsselten Secrets laden
source scripts/load-secrets.sh

# Secrets sind jetzt als Environment-Variablen verfügbar
echo $GITHUB_TOKEN
echo $GITLAB_TOKEN
```

### Manuelles Laden (Passwort-Secrets)

```bash
# Einzelnes Passwort-Secret entschlüsseln
FRITZBOX_PASSWORD=$(scripts/decrypt-secret.sh FRITZBOX_ADMIN_PASSWORD password)
```

### In Scripts verwenden

```bash
#!/bin/bash
source scripts/load-secrets.sh

# Secret verwenden
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
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

## Secret-Erstellung (für Benutzer)

### System-Key-Secret erstellen
```bash
./scripts/encrypt-secret.sh GITHUB_TOKEN "your-token-here"
```

### Passwort-Secret erstellen
```bash
./scripts/encrypt-secret-password.sh FRITZBOX_ADMIN_PASSWORD
# Secret-Wert wird interaktiv abgefragt
# Passphrase muss eingegeben werden
```

## Best Practices für Agenten

1. **Niemals Secrets im Klartext loggen**
   - Verwende Secrets nur für API-Calls oder Authentifizierung
   - Logge nur Metadaten, nie die Secret-Werte

2. **Secrets nur bei Bedarf laden**
   - Lade Secrets nur, wenn sie benötigt werden
   - Entlade Secrets nach Verwendung (optional)

3. **Fehlerbehandlung**
   - Prüfe, ob Secrets verfügbar sind, bevor sie verwendet werden
   - Gib hilfreiche Fehlermeldungen, wenn Secrets fehlen

4. **Passwort-Secrets**
   - Passwort-verschlüsselte Secrets benötigen interaktive Eingabe
   - Verwende sie nur für manuelle Tasks, nicht für Automatisierung

## Beispiel: Secret in Agent verwenden

```bash
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

## Sicherheit

- ✅ Secrets werden niemals im Git-Repository gespeichert
- ✅ Verschlüsselung mit age (moderne Verschlüsselung)
- ✅ System-Key wird sicher in `~/.cursor/secrets/system-key.txt` gespeichert
- ✅ Passwort-Secrets benötigen zusätzliche Passphrase
- ✅ Sichere Dateiberechtigungen (600) für alle Secret-Dateien

## Wichtige Hinweise

- **Niemals** Secrets im Klartext im Code oder in Logs ausgeben
- **Niemals** Secrets in Git committen (auch nicht versehentlich)
- System-Key sicher aufbewahren (Backup empfohlen)
- Passphrase für Passwort-Secrets sicher aufbewahren

