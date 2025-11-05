# Laptop DNS-Problem: Analyse-Zusammenfassung

**Erstellt**: 2025-11-05 21:05  
**Problem**: Fedora 42 Laptop - DNS funktioniert komplett nicht

## Problem-Identifikation

✅ **Root Cause gefunden**: Pi-hole läuft nicht oder Port 53 ist nicht erreichbar.

### Beweise

1. **Port 53 nicht erreichbar**:
   - `dig @192.168.178.10 google.de` → Timeout
   - `nc -zv 192.168.178.10 53` → Timeout

2. **Netzwerk funktioniert**:
   - `ping 192.168.178.10` → ✅ Erfolg (2 packets received)
   - `ping 192.168.178.54` → ✅ Erfolg

3. **DNS-Client funktioniert**:
   - `dig @1.1.1.1 google.de` → ✅ Erfolg (216.58.206.67)

4. **Pi-hole Status**:
   - Docker Pi-hole: Gestoppt (Exited 4 hours ago)
   - Kubernetes Pi-hole: Status unbekannt (Cluster nicht erreichbar)

## Sofort-Lösung (Workaround)

### Für Fedora 42 Laptop

**NetworkManager DNS auf Cloudflare ändern**:

```bash
# Verbindung identifizieren
nmcli connection show --active

# DNS-Server ändern
nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1"

# Verbindung neu starten
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"

# Test
dig google.de
```

**Detaillierte Anleitung**: Siehe `laptop-dns-fix-fedora.md`

## Langfristige Lösung

### Pi-hole reparieren/deployen

**Voraussetzungen**:
- Kubernetes-Cluster muss erreichbar sein
- SSH-Zugriff auf Debian-Server (192.168.178.54)

**Schritte**:
1. Kubernetes-Cluster-Verfügbarkeit prüfen
2. Pi-hole Pod/Service-Status prüfen
3. Falls nicht vorhanden: Pi-hole in Kubernetes deployen
4. MetallB IP-Pool prüfen (192.168.178.10 muss enthalten sein)
5. Port 53 Erreichbarkeit testen
6. Zurück zu Pi-hole wechseln

**Detaillierte Anleitung**: Siehe `laptop-dns-problem-analysis.md`

## Dokumentation erstellt

1. ✅ `laptop-dns-problem-analysis.md` - Vollständige Problem-Analyse
2. ✅ `laptop-dns-fix-fedora.md` - Fedora-spezifische Lösungsanleitung
3. ✅ `pihole-analyse.md` - Pi-hole Status aktualisiert

## Nächste Schritte

1. **Sofort**: Cloudflare DNS als Workaround auf Fedora Laptop setzen
2. **Cluster-Verfügbarkeit**: Warten bis Kubernetes wieder erreichbar ist
3. **Pi-hole reparieren**: Sobald Cluster erreichbar ist
4. **Zurück zu Pi-hole**: Nach erfolgreicher Reparatur

