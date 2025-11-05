# Heimnetzwerk IT-Infrastruktur Dokumentation

Dieses Repository dokumentiert die komplette IT-Infrastruktur des Heimnetzwerks, einschließlich DNS-Flow, Kubernetes-Konfiguration, Docker-Migration und Sicherheitsanalysen.

## 📋 Inhaltsverzeichnis

- [DNS-Flow Diagramm](dns-flow-diagram.md) - Komplette DNS-Architektur mit Mermaid-Diagramm
- [Offene Tasks](offene-tasks-zusammenfassung.md) - Übersicht über offene Aufgaben und Empfehlungen
- [Optimierungsempfehlungen](optimierungsempfehlungen.md) - Kritische Optimierungen für die Infrastruktur
- [Kubernetes Analyse](kubernetes-analyse.md) - Detaillierte Analyse des Kubernetes-Clusters
- [Fritzbox Analyse](fritzbox-analyse.md) - Fritzbox-Konfiguration und Einstellungen
- [Pi-hole Analyse](pihole-analyse.md) - Pi-hole Konfiguration und Status
- [DNS-Provider Analyse](dns-provider-analyse.md) - United Domains und Cloudflare Konfiguration
- [Domain Sicherheitsanalyse](domain-sicherheitsanalyse.md) - WHOIS-Daten und Domain-Sicherheit
- [DNSSEC Erklärung](dnssec-erklaerung.md) - DNSSEC Vor- und Nachteile
- [Docker zu Kubernetes Migration](docker-kubernetes-migration.md) - Migrationsplan
- [CMDB Evaluierung](cmdb-evaluierung.md) - CMDB-Lösungsvergleich

## 🏗️ Infrastruktur-Übersicht

### Netzwerk
- **Netzwerk**: 192.168.178.0/24
- **Router**: FRITZ!Box 7590 AX (192.168.178.1)
- **Kubernetes Node**: 192.168.178.54
- **Pi-hole**: 192.168.178.10 (Kubernetes LoadBalancer)

### DNS-Stack
```
Clients → Fritzbox DHCP → Pi-hole (192.168.178.10) → Cloudflare (1.1.1.1) → Internet
Kubernetes Pods → CoreDNS → Pi-hole (192.168.178.10) → Cloudflare → Internet
```

### Kubernetes Services
- **Ingress**: nginx-ingress (192.168.178.54:80/443)
- **DNS**: CoreDNS (forward an Pi-hole)
- **Cert-Manager**: Let's Encrypt mit Cloudflare DNS01-Challenge
- **LoadBalancer**: MetalLB (192.168.178.54, 192.168.178.10)

### Domain
- **Domain**: k8sops.online
- **Registrar**: United Domains
- **DNS-Provider**: Cloudflare
- **Nameserver**: gabriella.ns.cloudflare.com, olof.ns.cloudflare.com

## 🚀 Quick Start

### DNS-Flow visualisieren

Das DNS-Flow-Diagramm ist in `dns-flow-diagram.md` enthalten und kann direkt auf GitHub gerendert werden (Mermaid-Support).

### Offene Tasks prüfen

Siehe [offene-tasks-zusammenfassung.md](offene-tasks-zusammenfassung.md) für aktuelle Aufgaben und Prioritäten.

## 📊 Dokumentationsstruktur

### Analyse-Dokumente
- Detaillierte Analysen der einzelnen Komponenten
- Konfigurations- und Status-Informationen
- Identifizierte Probleme und Empfehlungen

### Migrations-Dokumente
- Docker zu Kubernetes Migration Plan
- Schritt-für-Schritt Anleitungen
- Rollback-Strategien

### Sicherheits-Dokumente
- Domain-Sicherheitsanalyse
- WHOIS-Daten und Privacy-Einstellungen
- DNSSEC Erklärung und Empfehlungen

## 🔒 Sicherheit

- **WHOIS Privacy**: Aktiviert (United Domains)
- **Domain-Lock**: Aktiviert (United Domains)
- **2FA**: Aktiviert (Cloudflare, United Domains)
- **DNSSEC**: Nicht aktiviert (bewusst, nicht kritisch für privates Setup)
- **SSL/TLS**: Let's Encrypt Zertifikate via Cert-Manager

## 📝 Versionierung

- **Dokumentation**: 2025-11-05
- **Fritzbox**: FRITZ!OS 8.20
- **Kubernetes**: v1.28.x (kubeadm)
- **Pi-hole**: Latest (Kubernetes)
- **CoreDNS**: v1.10.1
- **Cert-Manager**: v1.13.x

## 🤝 Beitrag

Dieses Repository dient als Dokumentation und Referenz für die Heimnetzwerk-Infrastruktur. Updates werden kontinuierlich vorgenommen, um den aktuellen Stand zu reflektieren.

## 📄 Lizenz

Private Dokumentation - Keine Lizenz erforderlich.

