# Heimnetzwerk IT-Infrastruktur Dokumentation

Dieses Repository dokumentiert die komplette IT-Infrastruktur des Heimnetzwerks, einschließlich DNS-Flow, Kubernetes-Konfiguration, Docker-Migration und Sicherheitsanalysen.

## 📋 Inhaltsverzeichnis

### Infrastruktur-Dokumentation
- [DNS-Flow Diagramm](dns-flow-diagram.md) - Komplette DNS-Architektur mit Mermaid-Diagramm
- [Kubernetes Analyse](kubernetes-analyse.md) - Detaillierte Analyse des Kubernetes-Clusters
- [Fritzbox Analyse](fritzbox-analyse.md) - Fritzbox-Konfiguration und Einstellungen
- [Pi-hole Analyse](pihole-analyse.md) - Pi-hole Konfiguration und Status
- [DNS-Provider Analyse](dns-provider-analyse.md) - United Domains und Cloudflare Konfiguration
- [Domain Sicherheitsanalyse](domain-sicherheitsanalyse.md) - WHOIS-Daten und Domain-Sicherheit
- [DNSSEC Erklärung](dnssec-erklaerung.md) - DNSSEC Vor- und Nachteile

### Task-Management
- [Task-Delegation](task-delegation-current.md) - Aktuelle Task-Delegation an Spezialisten
- [Task-Orchestrierung](task-orchestration-summary.md) - Task-Orchestrierung System
- [How-to: Task-Delegation](how-to-use-task-delegation.md) - Anleitung zur Task-Delegation

### Secret-Management
- [Secret-Management User Guide](secrets-management-user-guide.md) - Benutzer-Anleitung
- [Secret-Management Agent Guide](secrets-management-agent-guide.md) - Agenten-Anleitung
- [Secrets Inventory](secrets-inventory.yaml) - Inventar aller Secrets (Metadaten)

### Migration & Planung
- [Docker zu Kubernetes Migration](docker-kubernetes-migration.md) - Migrationsplan
- [Offene Tasks](offene-tasks-zusammenfassung.md) - Übersicht über offene Aufgaben
- [Optimierungsempfehlungen](optimierungsempfehlungen.md) - Kritische Optimierungen
- [CMDB Evaluierung](cmdb-evaluierung.md) - CMDB-Lösungsvergleich

### GitLab & GitHub
- [GitLab Analyse](gitlab-analyse.md) - GitLab Installation und Konfiguration
- [GitLab 502-Fix](gitlab-502-fix-analysis.md) - Analyse und Fix des 502-Fehler-Problems
- [GitLab Sync Setup](gitlab-sync-setup.md) - GitHub/GitLab Synchronisation

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

## 🤖 Spezialisierte AI-Agenten

Dieses Repository nutzt spezialisierte AI-Agenten für verschiedene Aufgabenbereiche. Jeder Agent hat tiefes Wissen in seinem Fachgebiet und kann automatisch Tasks ausführen.

### Verfügbare Agenten

- `/dns-expert` - DNS-Konfiguration, Pi-hole, Cloudflare, Domain-Management
- `/k8s-expert` - Kubernetes Cluster, Pods, Services, Ingress, Health-Probes
- `/gitops-expert` - ArgoCD, CI/CD, Deployment-Strategien
- `/security-expert` - SSL/TLS, Domain-Sicherheit, 2FA
- `/gitlab-github-expert` - GitLab/GitHub Sync, Repository-Management, API-Integration
- `/monitoring-expert` - Grafana, Prometheus, Logging, Metriken
- `/secrets-expert` - Kubernetes Secrets, API-Tokens, Rotation, Verschlüsselung
- `/infrastructure-expert` - Gesamtübersicht, Netzwerk-Topologie, Architektur
- `/debian-server-expert` - Debian-Server-Analyse, Docker, KVM, Kubernetes-Host
- `/fritzbox-expert` - FRITZ!Box 7590 AX Konfiguration, Browser-Automatisierung
- `/ask-all` - Multi-Expert-Konsultation für komplexe Fragen
- `/router` - Intelligente Prompt-Delegation an Spezialisten

### Task-Orchestrierung

- `/auto-task` - Führt automatisch alle "Sofort ausführbaren" Tasks aus
- `/execute-tasks` - Führt bestimmte Tasks aus (manuelle Auswahl)
- `/task-queue` - Zeigt Task-Liste mit manueller Auswahl
- `/task-status` - Zeigt aktuellen Status aller Tasks (gruppiert nach Status)

### Automatischer Git-Commit

Alle Agenten checken automatisch ihre Änderungen in Git ein. Falls das nicht möglich ist, wird das Problem klar identifiziert und gemeldet.

Siehe: `.cursor/context/git-auto-commit-context.md` für Details.

### Kontext-Selbstaktualisierung

Alle Agenten aktualisieren automatisch ihren eigenen Kontext nach jeder Aufgabe, um ihr Wissen aktuell zu halten und von erfolgreichen Lösungen zu profitieren.

Siehe: `.cursor/context/context-self-update.md` für Details.

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

### Secret-Management

Alle Secrets werden verschlüsselt gespeichert:
- **Verschlüsselung**: `age` (Age Encryption)
- **System-Key-Secrets**: Automatisch entschlüsselbar mit System-Key
- **Passwort-Secrets**: Passwort-verschlüsselt (interaktiv)
- **Speicherort**: `~/.cursor/secrets/` (nicht in Git)
- **Metadaten**: `secrets/secrets.metadata.yaml` (in Git, OHNE Werte)

Siehe: `secrets-management-user-guide.md` und `secrets-management-agent-guide.md` für Details.

## 📝 Versionierung

- **Dokumentation**: 2025-11-05
- **Fritzbox**: FRITZ!OS 8.20
- **Kubernetes**: v1.28.x (kubeadm)
- **Pi-hole**: Latest (Kubernetes)
- **CoreDNS**: v1.10.1
- **Cert-Manager**: v1.13.x
- **GitLab**: CE (Kubernetes) - Liveness-Probe-Fix aktiv

## 📊 Status-Reports

- **Auto-Task Ausführung**: [auto-task-execution-summary-2025-11-05.md](auto-task-execution-summary-2025-11-05.md)
- **Task-Status**: Siehe [task-delegation-current.md](task-delegation-current.md) für aktuellen Status

## 🤝 Beitrag

Dieses Repository dient als Dokumentation und Referenz für die Heimnetzwerk-Infrastruktur. Updates werden kontinuierlich vorgenommen, um den aktuellen Stand zu reflektieren.

## 📄 Lizenz

Private Dokumentation - Keine Lizenz erforderlich.

