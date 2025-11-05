# Cursor Installation auf Fedora

**Erstellt**: 2025-11-05  
**Ziel**: Fedora 42 Laptop

## Optionen

Fedora verwendet RPM-Pakete, nicht .deb. Es gibt mehrere Installationsmethoden:

### Option 1: RPM-Paket (Empfohlen)

Falls Cursor ein RPM-Paket anbietet:

```bash
# RPM-Paket installieren
sudo dnf install cursor-*.rpm

# Oder mit rpm direkt
sudo rpm -i cursor-*.rpm
```

### Option 2: AppImage (Portabel)

1. AppImage von cursor.sh herunterladen
2. Ausführbar machen:
   ```bash
   chmod +x cursor-*.AppImage
   ./cursor-*.AppImage
   ```
3. Optional: In `/usr/local/bin` oder `~/bin` verlinken

### Option 3: Flatpak (Falls verfügbar)

```bash
# Flatpak installieren (falls noch nicht installiert)
sudo dnf install flatpak

# Cursor Flatpak hinzufügen (falls verfügbar)
flatpak install cursor
```

### Option 4: Snap (Falls verfügbar)

```bash
# Snap installieren (falls noch nicht installiert)
sudo dnf install snapd

# Snap aktivieren
sudo systemctl enable --now snapd.socket

# Cursor Snap installieren
sudo snap install cursor
```

### Option 5: Manuell aus .deb konvertieren (Nicht empfohlen)

```bash
# alien installieren
sudo dnf install alien

# .deb zu .rpm konvertieren
alien -r cursor.deb

# RPM installieren
sudo rpm -i cursor-*.rpm
```

**Hinweis**: Konvertierung kann Probleme verursachen, besser direkt RPM verwenden.

## Empfohlene Vorgehensweise

1. **Prüfe cursor.sh** ob ein RPM-Paket verfügbar ist
2. Falls ja: Option 1 verwenden
3. Falls nein: Option 2 (AppImage) ist am einfachsten und portabel

## Installation verifizieren

```bash
# Prüfe ob cursor im PATH ist
which cursor

# Version prüfen
cursor --version
```

## Troubleshooting

### GUI-Probleme (Wayland/X11)

Falls Cursor nicht startet:

```bash
# Wayland deaktivieren (temporär)
export GDK_BACKEND=x11
cursor

# Oder in .bashrc/.zshrc permanent setzen
echo 'export GDK_BACKEND=x11' >> ~/.bashrc
```

### Fehlende Abhängigkeiten

```bash
# Prüfe fehlende Bibliotheken
ldd $(which cursor) | grep "not found"

# Installiere fehlende Pakete
sudo dnf install <paket-name>
```

