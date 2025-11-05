# Secret-Management Konzept

## Übersicht

Zentrales Secret-Management-System für automatisierte Verwaltung aller Sicherheitsdaten in der IT-Infrastruktur.

## Architektur

### Single Source of Truth

**Hauptdatei**: `secrets-inventory.yaml`
- Strukturierte Liste aller Secrets
- **OHNE** tatsächliche Werte (Sicherheit)
- Metadaten: Zweck, Owner, Rotation, Zugriff

### Zielsysteme

1. **GitHub**
   - Repository Secrets
   - Organization Secrets
   - Environment Secrets
   - Personal Access Tokens

2. **GitLab**
   - CI/CD Variables
   - Project Variables
   - Group Variables
   - Personal Access Tokens

3. **Kubernetes**
   - Secrets (verschlüsselt)
   - ConfigMaps (für nicht-sensitive Daten)
   - Service Accounts

4. **Externe Services**
   - Cloudflare API Tokens
   - United Domains API Keys
   - Let's Encrypt (via Cert-Manager)

## Automatisierung

### GitHub Secrets API

**Vorgehensweise**:
1. Public Key des Repositories abrufen
2. Secret mit Public Key verschlüsseln (LibSodium/PKCS1v15)
3. Verschüsseltes Secret via API speichern

**API-Endpunkte**:
- `GET /repos/{owner}/{repo}/actions/secrets/public-key`
- `PUT /repos/{owner}/{repo}/actions/secrets/{secret_name}`

**Python-Script**: `scripts/create-github-secret.py`

### GitHub Actions Workflow

**Workflow**: `.github/workflows/manage-secrets.yml`

**Funktionen**:
- Automatische Secret-Synchronisation
- Secret-Rotation
- Secret-Validierung
- Audit-Logging

### GitLab CI/CD Variables

**API-Endpunkte**:
- `POST /api/v4/projects/{id}/variables`
- `PUT /api/v4/projects/{id}/variables/{key}`

**Synchronisation**:
- Von GitHub Secrets zu GitLab Variables
- Bidirektionaler Sync (optional)

### Kubernetes Secrets

**Integration**:
- Via kubectl API
- Via Kubernetes Python Client
- Via Sealed Secrets (optional, für GitOps)

## Secret-Kategorien

### 1. GitHub Secrets

- `GITHUB_TOKEN` - Personal Access Token für API-Zugriff
- `GITLAB_TOKEN` - Token für GitLab-Sync
- `CLOUDFLARE_API_TOKEN` - Cloudflare DNS API
- `KUBERNETES_TOKEN` - Kubernetes Service Account Token

### 2. GitLab Secrets

- `GITLAB_TOKEN` - Personal Access Token
- `GITHUB_TOKEN` - Token für GitHub-Sync
- `KUBERNETES_TOKEN` - Kubernetes Service Account Token

### 3. Kubernetes Secrets

- `cloudflare-api-token` - Cert-Manager Cloudflare Integration
- `gitlab-registry-secret` - Container Registry Zugriff
- `cert-manager-credentials` - Let's Encrypt Credentials

### 4. Externe Services

- `CLOUDFLARE_API_TOKEN` - DNS-Management
- `UNITED_DOMAINS_API_KEY` - Domain-Management (falls vorhanden)
- `FRITZBOX_ADMIN_PASSWORD` - Router-Konfiguration (optional)

## Workflows

### Secret-Erstellung

1. **Manuell**: Secret in `secrets-inventory.yaml` eintragen
2. **Automatisch**: GitHub Actions Workflow erstellt Secret in allen Systemen
3. **Validierung**: Secret wird auf Gültigkeit geprüft
4. **Dokumentation**: Metadaten werden aktualisiert

### Secret-Aktualisierung

1. **Trigger**: Manuell oder automatisch (Rotation)
2. **Synchronisation**: Alle betroffenen Systeme werden aktualisiert
3. **Validierung**: Neue Secret-Werte werden getestet
4. **Rollback**: Bei Fehlern wird alter Wert wiederhergestellt

### Secret-Rotation

1. **Zeitplan**: Regelmäßige Rotation (z.B. alle 90 Tage)
2. **Automatisierung**: GitHub Actions Workflow
3. **Benachrichtigung**: Owner wird informiert
4. **Dokumentation**: Rotation wird in `secrets-inventory.yaml` dokumentiert

### Secret-Löschung

1. **Manuell**: Secret aus `secrets-inventory.yaml` entfernen
2. **Automatisch**: Aus allen Systemen gelöscht
3. **Audit**: Löschung wird geloggt

## Sicherheit

### Verschlüsselung

- **GitHub**: Secrets werden mit Public Key verschlüsselt
- **GitLab**: CI/CD Variables sind verschlüsselt gespeichert
- **Kubernetes**: Secrets sind base64-kodiert (nicht verschlüsselt)
- **Repository**: Keine Klartext-Secrets im Git-Repository

### Zugriffskontrolle

- **GitHub Secrets**: Nur für Actions verfügbar
- **GitLab Variables**: Nur für CI/CD Pipelines verfügbar
- **Kubernetes Secrets**: RBAC-basierte Zugriffskontrolle
- **Audit-Logging**: Alle Zugriffe werden geloggt

### Best Practices

1. **Minimal Privilege**: Nur notwendige Berechtigungen
2. **Rotation**: Regelmäßige Secret-Rotation
3. **Monitoring**: Überwachung auf unberechtigte Zugriffe
4. **Backup**: Secrets werden in sicheren Backup-Systemen gespeichert
5. **Dokumentation**: Alle Secrets sind dokumentiert (ohne Werte)

## Implementierung

### Dateien

- `secrets-inventory.yaml` - Zentrale Secret-Dokumentation
- `scripts/create-github-secret.py` - GitHub Secrets API Script
- `scripts/sync-secrets.sh` - Synchronisations-Script
- `.github/workflows/manage-secrets.yml` - Automatisierungs-Workflow

### Dependencies

- Python 3 mit `cryptography` Library
- GitHub Personal Access Token mit `repo` und `workflow` Berechtigungen
- GitLab Personal Access Token mit `api` Berechtigung
- kubectl für Kubernetes-Zugriff

## Nächste Schritte

1. `secrets-inventory.yaml` erstellen
2. GitHub Secrets API Script implementieren
3. GitHub Actions Workflow erstellen
4. GitLab API Integration
5. Kubernetes Secrets Integration
6. Synchronisations-Script erstellen
7. Testen und validieren

