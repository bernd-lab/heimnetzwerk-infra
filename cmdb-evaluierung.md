# CMDB/Überwachungssystem Evaluierung

## Anforderungen

Ziel ist es, ein System zur strukturierten Datenspeicherung der IT-Infrastruktur einzurichten, das:
- Daten strukturiert hält für wiederholte Analysen
- KI-Agenten gut damit arbeiten können
- Automatisierung und Integration ermöglicht
- Die aktuelle IT-Landschaft dokumentiert

## Lösungsoptionen

### Option 1: NetBox (Empfohlen)

**Vorteile:**
- Open Source, selbst gehostet
- Fokus auf IPAM (IP Address Management) und DCIM (Data Center Infrastructure Management)
- REST API und GraphQL API für KI-Agenten-Integration
- Strukturierte Datenmodelle für:
  - IP-Adressen und Prefixes
  - DNS-Namen und Records
  - Geräte (Devices) und Interfaces
  - Services und Anwendungen
  - VLANs und Netzwerk-Topologie
- Webhook-Support für Automatisierung
- Docker-Container verfügbar, einfach zu deployen
- Gute Integration mit Kubernetes (via API)
- Template-System für wiederholbare Konfigurationen

**Nachteile:**
- Primär für Netzwerk-Infrastruktur, weniger für Applikations-Monitoring
- Keine integrierte Überwachung/Metriken (nur Dokumentation)
- Benötigt separate Monitoring-Lösung (z.B. Prometheus/Grafana)

**Einsatz:**
- Zentrale Quelle für IP-Adressen, DNS-Namen, Netzwerk-Topologie
- Geräte-Inventar (Fritzbox, Pi-hole, Kubernetes Nodes)
- Service-Registry (welche Services laufen wo)
- Dokumentation der Netzwerk-Architektur

**Ziel:**
- Strukturierte Datenspeicherung für automatisierte DNS/IP-Konfiguration
- Basis für automatisierte Updates (z.B. External-DNS Integration)
- Dokumentierte Netzwerk-Architektur für KI-gestützte Analysen

**Deployment:**
- Kubernetes-Deployment möglich (PostgreSQL + Redis + NetBox)
- Oder Docker Compose für einfacheres Setup

### Option 2: iTop

**Vorteile:**
- Vollständiges IT Service Management (ITSM)
- CMDB mit Relationship-Mapping
- Change Management, Incident Management
- REST API verfügbar
- Service-Katalog und SLA-Management

**Nachteile:**
- Komplexer für reine Infrastruktur-Dokumentation
- Overhead für Heimnetzwerk-Szenario
- Weniger fokussiert auf IP/DNS-Management
- Mehr auf Business-Prozesse ausgerichtet

**Einsatz:**
- Falls Service-Management und Incident-Tracking benötigt werden
- Für größere IT-Umgebungen mit vielen Stakeholdern

### Option 3: Custom-Lösung (YAML/JSON + Kubernetes)

**Vorteile:**
- Vollständige Kontrolle über Datenstruktur
- Kubernetes-native (CRDs, Operatoren)
- Git-basierte Versionierung
- Integration mit Prometheus/Grafana für Monitoring
- Keine zusätzliche Infrastruktur nötig

**Nachteile:**
- Mehr Entwicklungsaufwand
- Fehlende vorgefertigte UI/Workflows
- Manueller API-Aufbau für KI-Agenten
- Weniger Features out-of-the-box

**Einsatz:**
- Falls maximale Flexibilität und Kubernetes-Integration Priorität haben
- Für einfache, schlanke Lösungen

## Empfehlung: NetBox + Prometheus/Grafana

**Kombination:**
- **NetBox**: Strukturierte Infrastruktur-Daten (IPs, DNS, Geräte, Services)
- **Prometheus/Grafana**: Monitoring und Metriken (bereits im Cluster vorhanden)

**Vorteile dieser Kombination:**
1. NetBox als Single Source of Truth für Infrastruktur-Daten
2. Prometheus/Grafana für Monitoring (bereits vorhanden im Cluster)
3. API-Integration zwischen beiden Systemen möglich
4. KI-Agenten können strukturiert über NetBox API abfragen
5. Automatisierung möglich (z.B. External-DNS liest aus NetBox)

**Datenstruktur in NetBox:**

```
Site: Heimnetzwerk
├── Prefix: 192.168.178.0/24
│   ├── IP Address: 192.168.178.1 (Fritzbox)
│   ├── IP Address: 192.168.178.54 (Kubernetes LoadBalancer)
│   └── IP Address: 192.168.178.XX (Pi-hole)
├── Prefix: 10.244.0.0/16 (Kubernetes Pod Network)
│   └── IP Addresses für Services
├── Devices:
│   ├── Fritzbox (Router/Gateway)
│   ├── Pi-hole (DNS-Filter)
│   └── Kubernetes Nodes
├── Services:
│   ├── DNS (Pi-hole, Fritzbox)
│   ├── DHCP (Fritzbox)
│   └── Kubernetes Services
└── DNS Records:
    ├── *.k8sops.online → 192.168.178.54
    └── Local DNS Records
```

**Integration mit Kubernetes:**
- NetBox API für External-DNS Integration
- Webhook bei DNS-Änderungen
- Automatische Updates bei Service-Änderungen

## Nächste Schritte

1. NetBox Deployment planen (Kubernetes oder Docker Compose)
2. Datenmodell für aktuelle Infrastruktur erstellen
3. Initiale Daten importieren
4. API-Zugang für KI-Agenten konfigurieren
5. Integration mit Prometheus/Grafana vorbereiten

