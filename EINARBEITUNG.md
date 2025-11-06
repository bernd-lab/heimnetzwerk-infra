# Einarbeitungs-Guide: Infrastruktur und Passwörter

**Datum**: 2025-11-06  
**Zweck**: Vollständiger Guide für die Einarbeitung in die Infrastruktur

---

## GitLab Repository

### Repository-URL
- **GitLab**: `https://gitlab.k8sops.online/neue-zeit/heimnetzwerk-infra.git`
- **GitHub**: `https://github.com/bernd-lab/heimnetzwerk-infra.git` (Backup)

### Zugriff
```bash
# Repository klonen
git clone https://gitlab.k8sops.online/neue-zeit/heimnetzwerk-infra.git

# Oder falls bereits vorhanden, GitLab-Remote hinzufügen
git remote add gitlab https://gitlab.k8sops.online/neue-zeit/heimnetzwerk-infra.git
git push gitlab main
```

**Status**: ✅ Alle Änderungen sind in GitLab verfügbar (gerade gepusht)

---

## Passwörter und Secrets für Agents

### Wo finde ich die Passwörter?

**Wichtig**: Alle Passwörter sind verschlüsselt in `~/.cursor/secrets/` gespeichert.

### Secret-Verzeichnisstruktur

```
~/.cursor/secrets/
├── system-key/          # System-Key-verschlüsselte Secrets (automatisch verfügbar)
│   ├── GITHUB_TOKEN.age
│   ├── GITLAB_TOKEN.age
│   ├── CLOUDFLARE_API_TOKEN.age
│   ├── DEBIAN_SERVER_SSH_KEY.age
│   └── GITLAB_ROOT_PASSWORD.age
│
├── password/            # Passwort-verschlüsselte Secrets (manuell)
│   ├── FRITZBOX_ADMIN_PASSWORD.age
│   └── ROOT_PASSWORDS.age
│
└── system-key.txt       # System-Key für automatische Entschlüsselung
```

### Verfügbare Secrets

#### System-Key-verschlüsselt (automatisch verfügbar)

Diese Secrets werden automatisch geladen, wenn du `source scripts/load-secrets.sh` ausführst:

| Secret | Beschreibung | Verwendung |
|--------|--------------|------------|
| `GITHUB_TOKEN` | GitHub Personal Access Token | GitHub API-Zugriff |
| `GITLAB_TOKEN` | GitLab Personal Access Token | GitLab API-Zugriff |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API Token | DNS-Management, Cert-Manager |
| `DEBIAN_SERVER_SSH_KEY` | SSH Private Key | SSH-Zugriff zu 192.168.178.54 |
| `GITLAB_ROOT_PASSWORD` | GitLab Root-Passwort | GitLab Webinterface |

**Verwendung**:
```bash
# Secrets laden
source scripts/load-secrets.sh

# Secrets verwenden
echo $GITHUB_TOKEN
echo $GITLAB_TOKEN
ssh -i <(echo "$DEBIAN_SERVER_SSH_KEY") bernd@192.168.178.54
```

#### Passwort-verschlüsselt (manuell)

Diese Secrets benötigen eine Passphrase zur Entschlüsselung:

| Secret | Beschreibung | Verwendung |
|--------|--------------|------------|
| `FRITZBOX_ADMIN_PASSWORD` | FRITZ!Box Admin-Passwort | Fritzbox-Webinterface |
| `ROOT_PASSWORDS` | Root-Passwörter für Server | Server-Root-Zugriff |

**Verwendung**:
```bash
# Passwort-Secret entschlüsseln (interaktiv, Passphrase erforderlich)
FRITZBOX_PASSWORD=$(scripts/decrypt-secret.sh FRITZBOX_ADMIN_PASSWORD password)
ROOT_PASSWORD=$(scripts/decrypt-secret.sh ROOT_PASSWORDS password)
```

### Secrets auf dem Laptop einrichten

#### 1. Secrets-Verzeichnis erstellen

```bash
# Verzeichnisstruktur erstellen
mkdir -p ~/.cursor/secrets/system-key
mkdir -p ~/.cursor/secrets/password
chmod 700 ~/.cursor/secrets
```

#### 2. System-Key generieren (falls nicht vorhanden)

```bash
# System-Key generieren
age-keygen -o ~/.cursor/secrets/system-key.txt
chmod 600 ~/.cursor/secrets/system-key.txt
```

#### 3. Secrets erstellen

**System-Key-Secret erstellen**:
```bash
# Beispiel: GitHub Token
./scripts/encrypt-secret.sh GITHUB_TOKEN "ghp_your_token_here"

# Beispiel: GitLab Token
./scripts/encrypt-secret.sh GITLAB_TOKEN "glpat-your-token-here"

# Beispiel: SSH Key
./scripts/encrypt-secret.sh DEBIAN_SERVER_SSH_KEY "$(cat ~/.ssh/infra_ed25519)"
```

**Passwort-Secret erstellen**:
```bash
# Interaktiv (Secret-Wert wird ohne Echo eingegeben)
./scripts/encrypt-secret-password.sh FRITZBOX_ADMIN_PASSWORD
```

#### 4. Secrets testen

```bash
# System-Key-Secrets laden
source scripts/load-secrets.sh

# Prüfen ob Secrets verfügbar sind
echo "GitHub Token: ${GITHUB_TOKEN:0:10}..."  # Nur ersten 10 Zeichen zeigen
echo "GitLab Token: ${GITLAB_TOKEN:0:10}..."
```

### Dokumentation

- **User Guide**: `secrets-management-user-guide.md` - Vollständige Anleitung für Benutzer
- **Agent Guide**: `secrets-management-agent-guide.md` - Anleitung für Agenten
- **Secret Templates**: `secrets/secrets-template.yaml` - Vorlage für Secret-Struktur
- **Secret Metadata**: `secrets/secrets.metadata.yaml` - Metadaten (ohne Werte)

---

## Wichtige Zugangsdaten

### Kubernetes-Cluster

- **API Endpoint**: `https://192.168.178.54:6443`
- **Config**: `~/.kube/config` oder `~/.kube/config-new-cluster.yaml`
- **Context**: `kubernetes-admin@kubernetes`

### Services (Webinterfaces)

| Service | URL | Credentials |
|---------|-----|-------------|
| GitLab | https://gitlab.k8sops.online | Root: `GITLAB_ROOT_PASSWORD` (Secret) |
| ArgoCD | https://argocd.k8sops.online | Admin: (siehe ArgoCD-Dokumentation) |
| Grafana | https://grafana.k8sops.online | (siehe Monitoring-Dokumentation) |
| Pi-hole | http://192.168.178.10 | (siehe Pi-hole-Dokumentation) |
| Dashboard | https://dashboard.k8sops.online | (siehe Dashboard-Dokumentation) |

### Server-Zugriff

- **Debian-Server (zuhause)**: `ssh bernd@192.168.178.54`
- **SSH Key**: `DEBIAN_SERVER_SSH_KEY` (Secret) oder `~/.ssh/infra_ed25519`
- **Root-Zugriff**: `ROOT_PASSWORDS` (Secret, passwort-verschlüsselt)

### Fritzbox

- **URL**: `http://192.168.178.1` oder `http://fritz.box`
- **Passwort**: `FRITZBOX_ADMIN_PASSWORD` (Secret, passwort-verschlüsselt)

---

## Einarbeitungs-Checkliste

### 1. Repository klonen

```bash
git clone https://gitlab.k8sops.online/neue-zeit/heimnetzwerk-infra.git
cd heimnetzwerk-infra
```

### 2. Secrets einrichten

```bash
# Secrets-Verzeichnis erstellen
mkdir -p ~/.cursor/secrets/{system-key,password}

# System-Key generieren (falls nicht vorhanden)
age-keygen -o ~/.cursor/secrets/system-key.txt
chmod 600 ~/.cursor/secrets/system-key.txt

# Secrets erstellen (siehe oben)
```

### 3. Kubernetes-Zugriff konfigurieren

```bash
# Kubeconfig kopieren oder SSH-Tunnel einrichten
# Siehe: HANDOVER.md für Details
```

### 4. Wichtige Dokumentation lesen

- ✅ `HANDOVER.md` - Vollständiger Cluster-Handover
- ✅ `secrets-management-user-guide.md` - Secrets-Verwaltung
- ✅ `CLUSTER-ANALYSE.md` - Detaillierte Cluster-Analyse
- ✅ `PROBLEME.md` - Bekannte Probleme und Lösungen

### 5. Services testen

```bash
# Secrets laden
source scripts/load-secrets.sh

# Kubernetes-Zugriff testen
kubectl get nodes

# GitLab-Zugriff testen
curl -H "Authorization: Bearer $GITLAB_TOKEN" https://gitlab.k8sops.online/api/v4/user
```

---

## Troubleshooting

### Secrets nicht verfügbar

```bash
# Prüfe ob Secrets-Verzeichnis existiert
ls -la ~/.cursor/secrets/

# Prüfe ob System-Key existiert
ls -la ~/.cursor/secrets/system-key.txt

# Prüfe ob Secrets existieren
ls -la ~/.cursor/secrets/system-key/*.age
```

### Secret kann nicht entschlüsselt werden

```bash
# Prüfe System-Key-Berechtigungen
chmod 600 ~/.cursor/secrets/system-key.txt

# Prüfe Secret-Datei-Berechtigungen
chmod 600 ~/.cursor/secrets/system-key/*.age
```

### Kubernetes-Zugriff funktioniert nicht

```bash
# Prüfe Kubeconfig
kubectl config view

# Prüfe Cluster-Verbindung
kubectl cluster-info

# Prüfe Node-Status
kubectl get nodes
```

---

## Nächste Schritte

1. **Repository klonen** von GitLab
2. **Secrets einrichten** (siehe oben)
3. **HANDOVER.md lesen** für vollständigen Cluster-Überblick
4. **Services testen** (GitLab, Kubernetes, etc.)
5. **Kritische Probleme angehen** (siehe HANDOVER.md - WSL2-Node Problem)

---

**Viel Erfolg bei der Einarbeitung! 🚀**

