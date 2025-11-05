# Optimierungsempfehlungen für IT-Infrastruktur

## Zusammenfassung der Analyse

### Aktuelle Situation

**Fritzbox:**
- DHCP aktiv, IP-Bereich: 192.168.178.20-200
- DNS-Server: 192.168.178.54 (Kubernetes LoadBalancer)
- Problem: DHCP-Bereich umfasst Kubernetes LoadBalancer IP

**Kubernetes:**
- LoadBalancer: 192.168.178.54 (MetallB)
- Cert-Manager: Cloudflare DNS01-Challenge konfiguriert
- CoreDNS: Forwardet an Fritzbox (192.168.178.1)
- Ingress: 12 Services mit *.k8sops.online Domains

**Pi-hole:**
- Nicht gefunden/aktiv

## Kritische Optimierungen

### 1. DHCP-IP-Bereich anpassen

**Problem:**
- DHCP-Bereich: 192.168.178.20-200
- Kubernetes LoadBalancer: 192.168.178.54
- Konflikt: 192.168.178.54 liegt im DHCP-Bereich

**Lösung:**
```
Neuer DHCP-Bereich:
- von: 192.168.178.20
- bis: 192.168.178.50
- und: 192.168.178.60
- bis: 192.168.178.200
```

**Alternative:**
- Statische DHCP-Reservierung für 192.168.178.54 erstellen

### 2. DNS-Stack optimieren

**Aktueller Flow:**
```
Clients → Fritzbox (192.168.178.54) → ? → Internet
```

**Empfohlener Flow (mit Pi-hole):**
```
Clients → Fritzbox DHCP (192.168.178.XX) → Pi-hole → Cloudflare/United Domains → Internet
```

**Empfohlener Flow (ohne Pi-hole):**
```
Clients → Fritzbox (192.168.178.1) → Cloudflare/United Domains → Internet
```

**Für Kubernetes:**
```
CoreDNS → Pi-hole (falls vorhanden) → Cloudflare/United Domains
```

### 3. Pi-hole Integration

**Falls Pi-hole gewünscht:**
1. Pi-hole installieren (IP: 192.168.178.10 empfohlen)
2. Fritzbox DNS-Server auf 192.168.178.10 ändern
3. Pi-hole Upstream-DNS: Cloudflare (1.1.1.1, 1.0.0.1) oder United Domains
4. Local DNS Records für *.k8sops.online → 192.168.178.54
5. CoreDNS Upstream auf Pi-hole ändern

**Falls Pi-hole nicht gewünscht:**
1. Fritzbox DNS-Server auf Cloudflare/United Domains ändern
2. Für Let's Encrypt: Cloudflare API bereits konfiguriert (funktioniert)

### 4. Let's Encrypt DNS-Challenge

**Aktuell:**
- Cert-Manager nutzt Cloudflare DNS01-Challenge ✓
- Funktioniert für externe Domains (k8sops.online)

**Für interne DNS:**
- Falls Pi-hole: Local DNS Records für Certbot-TXT-Records
- Falls ohne Pi-hole: Externe DNS-Challenge funktioniert bereits

### 5. Sicherheit

**Zu prüfen:**
- DNS-Rebind-Schutz in Fritzbox aktivieren
- Unnötige Dienste deaktivieren:
  - UPnP (falls nicht benötigt)
  - App-Zugriff (TR-064) (falls nicht benötigt)

**Empfehlung:**
- DNS-Rebind-Schutz aktivieren
- UPnP nur aktivieren wenn benötigt
- App-Zugriff nur für vertrauenswürdige Geräte

## CMDB-Empfehlung

### NetBox Deployment

**Vorteile:**
- Zentrale IP/DNS-Verwaltung
- Strukturierte Daten für KI-Agenten
- API-Integration für Automatisierung

**Datenstruktur:**
```
Site: Heimnetzwerk
├── Prefix: 192.168.178.0/24
│   ├── IP: 192.168.178.1 (Fritzbox)
│   ├── IP: 192.168.178.54 (Kubernetes LoadBalancer)
│   └── IP: 192.168.178.XX (Pi-hole, falls vorhanden)
├── Devices:
│   ├── FRITZ!Box 7590 AX
│   ├── Kubernetes Node (zuhause)
│   └── Pi-hole (falls vorhanden)
└── Services:
    ├── DNS
    ├── DHCP
    └── Kubernetes Services
```

## Konkrete Aktionsschritte

### Priorität 1 (Kritisch)
1. ✅ DHCP-Bereich anpassen (Konflikt mit Kubernetes LoadBalancer)
2. ✅ DNS-Stack dokumentieren und optimieren
3. ✅ Pi-hole Status klären (aktivieren oder entfernen)

### Priorität 2 (Wichtig)
4. ✅ NetBox installieren und initiale Daten importieren
5. ✅ DNS-Rebind-Schutz aktivieren
6. ✅ Unnötige Fritzbox-Dienste prüfen

### Priorität 3 (Nice-to-have)
7. ✅ External-DNS für automatische DNS-Updates
8. ✅ Monitoring-Integration (Prometheus/Grafana + NetBox)
9. ✅ Automatisierung für DNS-IP-Updates

## Technische Details

### DHCP-Konfiguration (Fritzbox)

**Aktuell:**
```
IP-Bereich: 192.168.178.20 - 192.168.178.200
DNS-Server: 192.168.178.54
Lease-Zeit: 1 Tag
```

**Empfohlen:**
```
IP-Bereich: 192.168.178.20 - 192.168.178.50, 192.168.178.60 - 192.168.178.200
DNS-Server: 192.168.178.10 (Pi-hole) oder 1.1.1.1 (Cloudflare)
Statische Reservierung: 192.168.178.54 (Kubernetes LoadBalancer)
```

### CoreDNS-Konfiguration (Kubernetes)

**Aktuell:**
```
forward . /etc/resolv.conf
```

**Empfohlen (mit Pi-hole):**
```
forward . 192.168.178.10
```

**Empfohlen (ohne Pi-hole):**
```
forward . 1.1.1.1 1.0.0.1
```

### Cert-Manager (bereits optimal)

**Konfiguration:**
- Cloudflare DNS01-Challenge aktiv
- API Token konfiguriert
- Funktioniert für externe Domains

## Fazit

Die Infrastruktur ist grundsätzlich gut konfiguriert. Hauptoptimierungsbedarf:

1. **DHCP-IP-Bereich**: Konflikt mit Kubernetes LoadBalancer beheben
2. **DNS-Stack**: Klären ob Pi-hole gewünscht, dann optimieren
3. **CMDB**: NetBox für strukturierte Datenverwaltung
4. **Sicherheit**: DNS-Rebind-Schutz und unnötige Dienste prüfen

Die Let's Encrypt DNS-Challenge funktioniert bereits optimal über Cloudflare API.

