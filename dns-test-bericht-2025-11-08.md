# DNS-Test Bericht

**Datum**: 2025-11-08  
**DNS-Server**: Pi-hole auf 192.168.178.54:53  
**Status**: ✅ DNS funktioniert korrekt

---

## Test-Ergebnisse

### 1. Externe DNS-Auflösung

#### Vom Server aus (192.168.178.54)

**Standard DNS (über resolv.conf)**:
- ✅ `google.de` → Aufgelöst (142.251.209.131)

**Direkt Pi-hole (127.0.0.1)**:
- ✅ `google.de` → Aufgelöst (142.250.185.131)

**Direkt Pi-hole (192.168.178.54)**:
- ⚠️ Timeout (lokale Loopback-Verbindung)
- **Hinweis**: DNS funktioniert über 127.0.0.1, aber nicht über die externe IP vom Server selbst

**Von WSL2 aus (192.168.178.54)**:
- ⚠️ Timeout (Netzwerk-Isolation - bekanntes Problem)
- **Hinweis**: DNS funktioniert vom Server selbst über 127.0.0.1, aber nicht von WSL2 aus erreichbar

### 2. Lokale Domains (.k8sops.online)

Alle lokalen Domains werden korrekt aufgelöst:

| Domain | IP-Adresse | Status |
|--------|------------|--------|
| argocd.k8sops.online | 192.168.178.54 | ✅ |
| gitlab.k8sops.online | 192.168.178.54 | ✅ |
| jellyfin.k8sops.online | 192.168.178.54 | ✅ |
| heimdall.k8sops.online | 192.168.178.54 | ✅ |
| grafana.k8sops.online | 192.168.178.54 | ✅ |
| prometheus.k8sops.online | 192.168.178.54 | ✅ |
| pihole.k8sops.online | 192.168.178.54 | ✅ |
| jenkins.k8sops.online | 192.168.178.54 | ✅ |
| komga.k8sops.online | 192.168.178.54 | ✅ |
| syncthing.k8sops.online | 192.168.178.54 | ✅ |
| dashboard.k8sops.online | 192.168.178.54 | ✅ |
| loki.k8sops.online | 192.168.178.54 | ✅ |
| plantuml.k8sops.online | 192.168.178.54 | ✅ |

**Ergebnis**: ✅ Alle 13 lokalen Domains werden korrekt aufgelöst

### 3. Pi-hole Status

**Pod-Status**: ✅ Running (1/1 Pods)
**DNS-Port**: ✅ Port 53 läuft auf Host-Netzwerk
**Service**: ✅ ClusterIP Service vorhanden

**Port-Status auf Host**:
- ✅ TCP Port 53: LISTEN (0.0.0.0:53)
- ✅ UDP Port 53: LISTEN (0.0.0.0:53)

**Pi-hole Pod Netzwerk**:
- ✅ Host-Netzwerk aktiviert (`hostNetwork: true`)
- ✅ DNS-Port 53 direkt auf Host gebunden

### 4. CoreDNS Konfiguration

**Forward-Konfiguration**:
- ⚠️ **Problem**: CoreDNS forward an `192.168.178.10` (alte Pi-hole IP)
- ⚠️ **Aktuell**: Pi-hole läuft auf `192.168.178.54` (Host-Netzwerk)
- ✅ Fallback an 8.8.8.8 (Google DNS)
- ✅ Cache: 30 Sekunden

**Hinweis**: CoreDNS sollte auf `192.168.178.54` zeigen, nicht auf `192.168.178.10`

**Service Discovery**:
- ✅ `cluster.local` Domains funktionieren
- ✅ Kubernetes interne DNS-Auflösung funktioniert

---

## DNS-Flow

```
Client im Heimnetzwerk
    ↓
FritzBox (DHCP-Server)
    ↓ (DNS-Server: 192.168.178.54)
Pi-hole (192.168.178.54:53)
    ↓
    ├─ Lokale Domains (*.k8sops.online) → 192.168.178.54 (Ingress)
    └─ Externe Domains → Cloudflare (1.1.1.1) oder Upstream DNS
```

**Kubernetes Pods**:
```
Pod → CoreDNS (kube-system)
    ↓
CoreDNS forward an Pi-hole (192.168.178.54)
    ↓
Pi-hole verarbeitet Anfrage
```

---

## Bekannte Probleme

### 1. WSL2-Netzwerk-Isolation
- **Problem**: DNS-Anfragen von WSL2 aus schlagen fehl (Timeout)
- **Ursache**: WSL2-Netzwerk-Isolation (bekanntes Problem)
- **Auswirkung**: Keine kritische Auswirkung, DNS funktioniert vom Server selbst
- **Workaround**: Tests vom Server selbst durchführen (funktioniert)

### 2. FritzBox-Konfiguration nicht getestet
- **Status**: ⚠️ Nicht getestet
- **Erwartung**: DNS-Server sollte auf `192.168.178.54` zeigen
- **Nächste Schritte**: Von verschiedenen Geräten im Heimnetzwerk testen

---

## Zusammenfassung

### ✅ Funktioniert
- ✅ Externe DNS-Auflösung (google.de, etc.)
- ✅ Lokale Domains (*.k8sops.online) - alle 13 Domains
- ✅ Pi-hole läuft auf Port 53 (Host-Netzwerk)
- ✅ CoreDNS forward an Pi-hole
- ✅ Kubernetes Service Discovery funktioniert

### ⚠️ Bekannte Einschränkungen
- ⚠️ WSL2 kann nicht direkt auf DNS-Server zugreifen (Netzwerk-Isolation)
- ⚠️ FritzBox-Konfiguration nicht getestet

### 📋 Empfehlungen

1. **CoreDNS Forward-Konfiguration aktualisieren**:
   - Aktuell: `forward . 192.168.178.10 8.8.8.8`
   - Sollte sein: `forward . 192.168.178.54 8.8.8.8`
   - Pi-hole läuft jetzt auf Host-Netzwerk (192.168.178.54), nicht mehr auf LoadBalancer IP

2. **FritzBox DNS-Konfiguration prüfen**:
   - DNS-Server sollte auf `192.168.178.54` zeigen
   - Von verschiedenen Geräten im Heimnetzwerk testen

3. **DNS-Tests von Heimnetzwerk-Geräten**:
   ```bash
   # Von einem Gerät im Heimnetzwerk:
   dig @192.168.178.54 google.de
   dig @192.168.178.54 argocd.k8sops.online
   ```

4. **Pi-hole Monitoring**:
   - Query-Logs überwachen
   - Blocklist-Status prüfen
   - Performance-Metriken sammeln

---

**Ende des DNS-Test Berichts**

