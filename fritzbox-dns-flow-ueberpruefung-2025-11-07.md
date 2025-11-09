# FritzBox DNS-Flow Überprüfung

**Datum**: 2025-11-07  
**Zweck**: Überprüfung der DNS-Konfiguration für optimalen DNS-Flow  
**Status**: ⚠️ **Manuelle Überprüfung erforderlich (Passwort benötigt)**

## Aktuelle Situation

### Pi-hole Status:
- ⚠️ **Pod Status**: `Pending` (Insufficient CPU)
- ✅ **Service IP**: `192.168.178.10` (LoadBalancer)
- ❌ **DNS nicht erreichbar**: Timeout bei DNS-Abfragen
- ⚠️ **Problem**: Pi-hole Pod kann nicht gestartet werden (CPU-Mangel)

### CoreDNS Konfiguration:
- ✅ **Forward-Konfiguration**: `forward . 192.168.178.10 8.8.8.8`
- ✅ **Fallback**: 8.8.8.8 (Google DNS)
- ⚠️ **Problem**: Pi-hole ist nicht erreichbar, daher wird direkt an 8.8.8.8 geforwardet

## Optimaler DNS-Flow (Ziel-Konfiguration)

### Erwarteter Flow:
```
1. Clients (192.168.178.x)
   ↓
2. FritzBox DHCP (verteilt DNS-Server)
   ↓
3. Pi-hole (192.168.178.10) - Ad-Blocking, lokale DNS-Records
   ↓
4. Upstream DNS (Cloudflare 1.1.1.1 oder Google 8.8.8.8)
   ↓
5. Internet
```

### Kubernetes Pods:
```
1. Kubernetes Pods
   ↓
2. CoreDNS (10.96.0.10)
   ↓
3. Pi-hole (192.168.178.10)
   ↓
4. Upstream DNS
   ↓
5. Internet
```

## Zu überprüfende FritzBox-Einstellungen

### 1. DNS-Server-Konfiguration (KRITISCH)

**Menü-Pfad**: `Internet → Zugangsdaten → DNS-Server`

**Zu prüfen**:
- ✅ **Lokaler DNS-Server**: Sollte `192.168.178.10` sein (Pi-hole)
- ⚠️ **Aktuell**: Möglicherweise noch nicht konfiguriert oder falsch
- ✅ **Upstream DNS**: Sollte Cloudflare (1.1.1.1, 1.0.0.1) oder Google (8.8.8.8) sein

**Erwartete Konfiguration**:
```
Lokaler DNS-Server: 192.168.178.10
Upstream DNS: 1.1.1.1, 1.0.0.1 (Cloudflare)
```

### 2. DHCP-Konfiguration (KRITISCH)

**Menü-Pfad**: `Heimnetz → Netzwerk → IPv4-Adressen`

**Zu prüfen**:
- ✅ **DHCP-Server**: Sollte aktiviert sein
- ⚠️ **IP-Bereich**: Sollte `192.168.178.20 - 192.168.178.200` sein
- ⚠️ **Problem**: `192.168.178.54` (Ingress-Controller) liegt im DHCP-Bereich
- ✅ **DNS-Server für Clients**: Sollte `192.168.178.10` sein (Pi-hole)

**Erwartete Konfiguration**:
```
DHCP-Bereich: 192.168.178.20 - 192.168.178.50, 192.168.178.60 - 192.168.178.200
DNS-Server für Clients: 192.168.178.10
```

**Statische Reservierungen** (empfohlen):
- `192.168.178.54` → Ingress-Controller (statisch)
- `192.168.178.10` → Pi-hole (statisch)

### 3. DNS-Rebind-Schutz (WICHTIG)

**Menü-Pfad**: `Erweiterte Netzwerkeinstellungen → DNS-Rebind-Schutz`

**Zu prüfen**:
- ⚠️ **Status**: Sollte aktiviert sein
- ✅ **Zweck**: Verhindert DNS-Rebind-Angriffe
- ⚠️ **Aktuell**: Möglicherweise noch nicht aktiviert

**Erwartete Konfiguration**:
```
DNS-Rebind-Schutz: Aktiviert
```

### 4. DNS over TLS (OPTIONAL)

**Menü-Pfad**: `Internet → Zugangsdaten → DNS over TLS`

**Zu prüfen**:
- ✅ **Status**: Kann aktiviert sein (dns.google)
- ⚠️ **Hinweis**: Optional, aber empfohlen für Sicherheit

**Erwartete Konfiguration**:
```
DNS over TLS: Aktiviert (optional)
Provider: dns.google oder Cloudflare
```

## Aktuelle Probleme

### 1. Pi-hole nicht erreichbar
- **Problem**: Pod ist `Pending` (Insufficient CPU)
- **Auswirkung**: DNS-Flow funktioniert nicht optimal
- **Lösung**: CPU-Ressourcen freigeben oder Pi-hole CPU-Requests reduzieren

### 2. DNS-Flow unterbrochen
- **Problem**: CoreDNS forwardet an Pi-hole, aber Pi-hole antwortet nicht
- **Auswirkung**: Fallback zu 8.8.8.8, aber keine Ad-Blocking, keine lokalen DNS-Records
- **Lösung**: Pi-hole Pod zum Laufen bringen

### 3. DHCP-Bereich-Konflikt
- **Problem**: `192.168.178.54` liegt im DHCP-Bereich
- **Auswirkung**: Potenzielle IP-Konflikte
- **Lösung**: DHCP-Bereich anpassen oder statische Reservierung

## Empfohlene Überprüfungsreihenfolge

### Schritt 1: Pi-hole zum Laufen bringen
```bash
# CPU-Requests reduzieren oder andere Pods reduzieren
kubectl get pods -A --sort-by=.spec.containers[0].resources.requests.cpu
```

### Schritt 2: FritzBox DNS-Server konfigurieren
1. Anmelden: `http://192.168.178.1`
2. Navigieren: `Internet → Zugangsdaten → DNS-Server`
3. Prüfen: Lokaler DNS-Server = `192.168.178.10`
4. Falls nicht: Auf `192.168.178.10` setzen

### Schritt 3: DHCP-Konfiguration prüfen
1. Navigieren: `Heimnetz → Netzwerk → IPv4-Adressen`
2. Prüfen: DNS-Server für Clients = `192.168.178.10`
3. Prüfen: DHCP-Bereich (sollte 192.168.178.54 ausschließen)
4. Falls nötig: Statische Reservierung für 192.168.178.54 erstellen

### Schritt 4: DNS-Rebind-Schutz aktivieren
1. Navigieren: `Erweiterte Netzwerkeinstellungen → DNS-Rebind-Schutz`
2. Prüfen: Status = Aktiviert
3. Falls nicht: Aktivieren

### Schritt 5: DNS-Flow testen
```bash
# Von einem Client im Netzwerk
dig @192.168.178.10 google.de
dig @192.168.178.10 gitlab.k8sops.online

# Von einem Kubernetes Pod
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup google.com
```

## Erwartete Ergebnisse nach Konfiguration

### Von Clients:
- ✅ DNS-Abfragen gehen an `192.168.178.10` (Pi-hole)
- ✅ Ad-Blocking funktioniert
- ✅ Lokale DNS-Records (`*.k8sops.online`) funktionieren
- ✅ Upstream-DNS (Cloudflare/Google) wird verwendet

### Von Kubernetes Pods:
- ✅ CoreDNS forwardet an `192.168.178.10` (Pi-hole)
- ✅ Service Discovery (`*.svc.cluster.local`) funktioniert
- ✅ Externe DNS-Abfragen gehen über Pi-hole

## Nächste Schritte

1. ⚠️ **Pi-hole Pod zum Laufen bringen** (CPU-Problem lösen)
2. ⚠️ **FritzBox-Passwort entschlüsseln** (für Browser-Automation)
3. ⚠️ **FritzBox DNS-Einstellungen überprüfen** (per Browser-Automation)
4. ⚠️ **DHCP-Konfiguration prüfen** (DNS-Server für Clients)
5. ⚠️ **DNS-Rebind-Schutz aktivieren** (Sicherheit)

## Hinweis

**Für vollständige Browser-Automation benötigt**:
- FritzBox-Passwort (verschlüsselt in `FRITZBOX_ADMIN_PASSWORD.age`)
- Passphrase zur Entschlüsselung (vom Benutzer)

**Alternative**: Manuelle Überprüfung der oben genannten Einstellungen im FritzBox-Webinterface.

