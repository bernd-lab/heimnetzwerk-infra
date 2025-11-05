# Cursor Setup auf Fedora - Nach der Installation

**Erstellt**: 2025-11-05  
**Fedora 42 Laptop**

## ✅ Installation abgeschlossen

Cursor wurde per Snap installiert. Jetzt können wir es einrichten!

## Nächste Schritte

### 1. Cursor starten

```bash
# Cursor starten
cursor

# Oder über die Anwendungsliste/GUI
```

### 2. Repository öffnen

**Option A: Von GitHub klonen (falls noch nicht vorhanden)**

```bash
# Repository klonen
cd ~
git clone https://github.com/bernd-lab/heimnetzwerk-infra.git
cd heimnetzwerk-infra

# Cursor im Repository starten
cursor .
```

**Option B: Bestehendes Repository öffnen**

```bash
# Falls Repository bereits lokal vorhanden
cd /path/to/heimnetzwerk-infra
cursor .
```

**Option C: In Cursor öffnen**

1. Cursor starten
2. **File** → **Open Folder...**
3. Repository-Verzeichnis auswählen

### 3. Git-Konfiguration prüfen

```bash
# Git-Konfiguration prüfen
git config --global user.name
git config --global user.email

# Falls nicht gesetzt:
git config --global user.name "bernd-lab"
git config --global user.email "deine-email@example.com"
```

### 4. SSH Key für GitHub (falls nötig)

Falls du SSH für Git verwenden möchtest:

```bash
# SSH Key generieren (falls noch nicht vorhanden)
ssh-keygen -t ed25519 -C "deine-email@example.com"

# Public Key anzeigen
cat ~/.ssh/id_ed25519.pub

# In GitHub einfügen: Settings → SSH and GPG keys → New SSH key
```

### 5. Remote-Repository prüfen

```bash
# Im Repository-Verzeichnis
cd ~/heimnetzwerk-infra  # oder dein Pfad

# Remote-Repository prüfen
git remote -v

# Falls GitHub nicht konfiguriert:
git remote add origin https://github.com/bernd-lab/heimnetzwerk-infra.git
# Oder mit SSH:
git remote set-url origin git@github.com:bernd-lab/heimnetzwerk-infra.git
```

## Cursor Features nutzen

### AI-Agenten verfügbar

Alle spezialisierten Agenten sind verfügbar:
- `/dns-expert` - DNS-Konfiguration
- `/k8s-expert` - Kubernetes Cluster
- `/gitlab-github-expert` - Repository-Management
- `/fritzbox-expert` - Fritzbox-Konfiguration
- `/debian-server-expert` - Server-Analyse
- Und viele mehr...

### Task-Orchestrierung

- `/auto-task` - Automatische Task-Ausführung
- `/task-status` - Task-Status anzeigen
- `/router` - Intelligente Task-Delegation

### Secrets-Management

Secrets können geladen werden (falls System-Key vorhanden):

```bash
# In Cursor Terminal
source scripts/load-secrets.sh

# Secrets sind dann verfügbar als Environment-Variablen
echo $GITHUB_TOKEN  # Beispiel
```

## Probleme beheben

### Cursor startet nicht

```bash
# Snap-Version prüfen
snap list cursor

# Logs prüfen
snap logs cursor

# Snap neu installieren (falls nötig)
sudo snap remove cursor
sudo snap install cursor
```

### Git-Zugriff funktioniert nicht

```bash
# HTTPS-Authentifizierung prüfen
git config --global credential.helper store

# Oder SSH verwenden
git remote set-url origin git@github.com:bernd-lab/heimnetzwerk-infra.git
```

### Repository nicht gefunden

```bash
# Repository klonen
git clone https://github.com/bernd-lab/heimnetzwerk-infra.git
cd heimnetzwerk-infra
cursor .
```

## Nützliche Cursor-Einstellungen

### Extensions installieren

Cursor unterstützt VS Code Extensions. Empfohlene Extensions:
- GitLens (Git-Integration)
- YAML (für Kubernetes Manifeste)
- Docker (Container-Management)
- Kubernetes (K8s-Support)

### Cursor AI-Konfiguration

Cursor AI ist bereits aktiv. Du kannst:
- `Ctrl+K` für AI-Completions
- Chat-Fenster für Fragen öffnen
- Commands mit `/` nutzen

## Projekt-spezifische Features

### Worktrees

Cursor Worktrees sind konfiguriert in `.cursor/worktrees.json`:
- Ermöglicht parallele Agent-Ausführung
- Isolierte Branches

### Custom Commands

Alle Agenten sind als Custom Commands verfügbar:
- Aufruf mit `/` im Chat
- Automatische Kontext-Ladung
- Spezialisierte Expertise

## Nächste Schritte

1. **Repository öffnen** in Cursor
2. **Git-Konfiguration prüfen**
3. **Erste Agenten testen**: `/task-status` oder `/router`
4. **Projekt erkunden**: README.md lesen

