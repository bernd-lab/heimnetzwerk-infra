# Secrets Management - User Guide

## Übersicht

Dieses Dokument beschreibt, wie Benutzer Secrets erstellen, verwalten und verwenden können.

## Voraussetzungen

- `age` (Age Encryption) installiert: `age --version`
- System-Key generiert: `~/.cursor/secrets/system-key.txt`
- Verzeichnisstruktur vorhanden: `~/.cursor/secrets/`

## Secret-Erstellung

### System-Key-Secret erstellen

```bash
# Secret mit System-Key verschlüsseln
./scripts/encrypt-secret.sh GITHUB_TOKEN "your-token-here"

# Beispiel: GitHub Token
./scripts/encrypt-secret.sh GITHUB_TOKEN "ghp_xxxxxxxxxxxxxxxxxxxx"
```

**Wichtig**: Das Secret wird automatisch mit dem System-Key verschlüsselt und in `~/.cursor/secrets/system-key/GITHUB_TOKEN.age` gespeichert.

### Passwort-Secret erstellen

```bash
# Secret mit Passphrase verschlüsseln (interaktiv)
./scripts/encrypt-secret-password.sh FRITZBOX_ADMIN_PASSWORD

# Secret-Wert wird interaktiv abgefragt (ohne Echo)
# Passphrase muss eingegeben werden
```

**Wichtig**: 
- Secret-Wert wird ohne Echo eingegeben
- Passphrase muss sicher aufbewahrt werden
- Secret wird in `~/.cursor/secrets/password/FRITZBOX_ADMIN_PASSWORD.age` gespeichert

## Secret-Verwendung

### Alle System-Key-Secrets laden

```bash
# In einem Script oder Terminal
source scripts/load-secrets.sh

# Secrets sind jetzt als Environment-Variablen verfügbar
echo $GITHUB_TOKEN
echo $GITLAB_TOKEN
```

### Einzelnes Secret entschlüsseln

```bash
# System-Key-Secret
scripts/decrypt-secret.sh GITHUB_TOKEN system-key

# Passwort-Secret (interaktiv)
scripts/decrypt-secret.sh FRITZBOX_ADMIN_PASSWORD password
```

### Secret in Script verwenden

```bash
#!/bin/bash
source scripts/load-secrets.sh

# Secret verwenden
curl -H "Authorization: token $GITHUB_TOKEN" \
     https://api.github.com/repos/bernd-lab/heimnetzwerk-infra
```

## Secret-Verwaltung

### Secret-Liste anzeigen

```bash
# System-Key-Secrets
ls -la ~/.cursor/secrets/system-key/*.age

# Passwort-Secrets
ls -la ~/.cursor/secrets/password/*.age
```

### Secret aktualisieren

```bash
# Einfach neu erstellen (überschreibt altes Secret)
./scripts/encrypt-secret.sh GITHUB_TOKEN "new-token-value"
```

### Secret löschen

```bash
# Secret-Datei löschen
rm ~/.cursor/secrets/system-key/GITHUB_TOKEN.age

# Oder Passwort-Secret
rm ~/.cursor/secrets/password/FRITZBOX_ADMIN_PASSWORD.age
```

## Secret-Kategorien

### System-Key-verschlüsselt (empfohlen für API-Tokens)

**Vorteile**:
- Automatisches Laden möglich
- Keine interaktive Eingabe nötig
- Perfekt für Automatisierung

**Verwendung für**:
- API-Tokens (GitHub, GitLab, Cloudflare)
- SSH-Keys
- Webinterface-Credentials (nicht kritisch)

### Passwort-verschlüsselt (empfohlen für kritische Secrets)

**Vorteile**:
- Zusätzliche Sicherheit durch Passphrase
- Perfekt für kritische Passwörter

**Verwendung für**:
- Fritzbox Admin-Passwort
- Root-Passwörter
- Sehr sensible Daten

## Sicherheit

### Best Practices

1. **Niemals Secrets im Git committen**
   - Secrets sind in `.gitignore`
   - Nur Metadaten in Git

2. **System-Key sicher aufbewahren**
   - System-Key in `~/.cursor/secrets/system-key.txt`
   - Backup empfohlen
   - Sichere Berechtigungen (600)

3. **Passphrase sicher aufbewahren**
   - Passphrase für Passwort-Secrets
   - Passwort-Manager empfohlen

4. **Sichere Berechtigungen**
   ```bash
   chmod 700 ~/.cursor/secrets
   chmod 600 ~/.cursor/secrets/system-key.txt
   chmod 600 ~/.cursor/secrets/system-key/*.age
   chmod 600 ~/.cursor/secrets/password/*.age
   ```

### Backup

```bash
# System-Key sichern (wichtig!)
cp ~/.cursor/secrets/system-key.txt ~/backup/system-key.txt.backup

# Secrets-Verzeichnis sichern
tar -czf secrets-backup.tar.gz ~/.cursor/secrets/
```

## Troubleshooting

### System-Key nicht gefunden

```bash
# System-Key generieren
age-keygen -o ~/.cursor/secrets/system-key.txt
```

### Secret kann nicht entschlüsselt werden

```bash
# Prüfe System-Key
ls -la ~/.cursor/secrets/system-key.txt

# Prüfe Secret-Datei
ls -la ~/.cursor/secrets/system-key/GITHUB_TOKEN.age

# Prüfe Berechtigungen
chmod 600 ~/.cursor/secrets/system-key.txt
chmod 600 ~/.cursor/secrets/system-key/*.age
```

### Passwort-Secret erfordert Passphrase

Passwort-verschlüsselte Secrets benötigen immer die Passphrase. Diese kann nicht automatisiert werden.

## Integration mit Agenten

Agenten können automatisch auf System-Key-verschlüsselte Secrets zugreifen:

```bash
# In Agent-Command
source scripts/load-secrets.sh

# Secret verwenden
echo "Using token: ${GITHUB_TOKEN:0:10}..."  # Nur ersten 10 Zeichen zeigen
```

## Weitere Informationen

- **Agent Guide**: `secrets-management-agent-guide.md`
- **Shared Context**: `.cursor/context/secrets-context.md`
- **Secret Templates**: `secrets/secrets-template.yaml`
- **Secret Metadata**: `secrets/secrets.metadata.yaml`
- **Secrets Inventory**: `secrets-inventory.yaml`

