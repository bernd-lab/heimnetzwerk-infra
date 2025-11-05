# Fedora 42 DNS-Konfiguration: Sofort-Lösung

**Erstellt**: 2025-11-05  
**Betroffenes Gerät**: Fedora 42 Laptop  
**Problem**: DNS funktioniert nicht (Pi-hole auf 192.168.178.10 nicht erreichbar)

## Sofort-Lösung: Cloudflare DNS setzen

### Methode 1: NetworkManager (Empfohlen)

```bash
# 1. Aktive Verbindung identifizieren
nmcli connection show --active

# 2. DNS-Server auf Cloudflare ändern
nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1"

# Falls WLAN:
nmcli connection modify "Wi-Fi" ipv4.dns "1.1.1.1 1.0.0.1"

# 3. Verbindung neu starten
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

### Methode 2: Manuell (temporär)

```bash
# /etc/resolv.conf temporär überschreiben
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf

# Test
dig google.de
```

**Hinweis**: Diese Änderung wird beim Neustart überschrieben. Für permanente Lösung siehe Methode 1.

### Methode 3: GUI (NetworkManager)

1. **System Settings** → **Network** → **Wired** (oder **Wi-Fi**)
2. **Settings** (Zahnrad-Symbol) öffnen
3. **IPv4** Tab → **DNS** Section
4. **DNS-Server**: `1.1.1.1, 1.0.0.1` (Cloudflare)
5. **Apply** → Verbindung neu starten

## DNS-Test nach Änderung

```bash
# DNS-Auflösung testen
dig google.de
nslookup google.de
host google.de

# Erwartung: IP-Adresse wird zurückgegeben
```

## Zurück zu Pi-hole wechseln (später)

Nachdem Pi-hole repariert ist:

```bash
# DNS-Server zurück zu Pi-hole
nmcli connection modify "Wired connection 1" ipv4.dns "192.168.178.10"

# Verbindung neu starten
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"

# Test
dig @192.168.178.10 google.de
```

## Troubleshooting

### DNS funktioniert immer noch nicht

1. **Firewall prüfen**:
   ```bash
   sudo firewall-cmd --list-all
   sudo firewall-cmd --list-services  # DNS sollte erlaubt sein
   ```

2. **systemd-resolved prüfen** (falls aktiv):
   ```bash
   systemctl status systemd-resolved
   resolvectl status
   ```

3. **NetworkManager neu starten**:
   ```bash
   sudo systemctl restart NetworkManager
   ```

4. **DNS-Cache leeren**:
   ```bash
   sudo systemd-resolve --flush-caches  # Falls systemd-resolved aktiv
   ```

### Verbindung-Name finden

```bash
# Alle Verbindungen auflisten
nmcli connection show

# Name der aktiven Verbindung
nmcli connection show --active
```

## Wichtige Hinweise

- **Temporär**: Diese Lösung ist ein Workaround bis Pi-hole repariert ist
- **Pi-hole-Features**: Ad-Blocking und lokale DNS-Records gehen verloren
- **Permanent**: Nach Pi-hole-Reparatur zurück zu Pi-hole wechseln

