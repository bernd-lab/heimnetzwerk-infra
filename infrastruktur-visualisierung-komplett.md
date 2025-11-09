# Infrastruktur-Visualisierung: Komplette Landschaft

**Erstellt**: 2025-11-09  
**Zweck**: Umfassende Visualisierung der Infrastruktur mit verschiedenen Techniken

---

## Übersicht

Diese Dokumentation visualisiert die komplette Infrastruktur-Landschaft mit:
- **PlantUML**: Strukturierte Diagramme (eigener Server)
- **Mermaid**: Native GitHub/GitLab Unterstützung
- **ASCII-Art**: Textbasierte Übersicht

---

## Infrastruktur-Komponenten

### Hardware
- **FritzBox 7590 AX**: Router/Gateway (192.168.178.1)
- **Kubernetes Node**: `zuhause` (192.168.178.54)
- **Windows-Maschine**: WSL2 Host
- **Laptop**: Client-Gerät (Fedora 42)

### Netzwerk
- **Heimnetzwerk**: 192.168.178.0/24
- **Kubernetes Pod Network**: 10.244.0.0/16
- **Kubernetes Service Network**: 10.96.0.0/12

### DNS
- **Pi-hole**: 192.168.178.54 (Host-Netzwerk, Port 53)
- **CoreDNS**: 10.96.0.10 (Kubernetes DNS)
- **Upstream DNS**: Cloudflare (1.1.1.1, 1.0.0.1)

### Services (Kubernetes)
- **ArgoCD**: GitOps Platform
- **GitLab**: Git Repository
- **Pi-hole**: DNS & Ad-Blocking
- **Jellyfin**: Media Server
- **Komga**: Comic Server
- **Syncthing**: File Sync
- **Heimdall**: Dashboard
- **Grafana**: Monitoring Dashboard
- **Prometheus**: Metrics Collection
- **Loki**: Log Aggregation
- **Kubernetes Dashboard**: Cluster Management
- **PlantUML**: Diagram Generator

---

## 1. PlantUML Visualisierung

### Komplettes Infrastruktur-Diagramm

**PlantUML-Code** (siehe `infrastruktur-plantuml.puml` für vollständigen Code):

```plantuml
@startuml Infrastruktur-Landschaft
!theme plain
skinparam backgroundColor #FFFFFF

title Komplette Infrastruktur-Landschaft: Heimnetzwerk k8sops.online

package "Hardware" {
  component "FritzBox 7590 AX" as fritzbox #FFA500
  component "Kubernetes Node" as k8snode #4169E1
  component "Windows-Maschine" as windows #00A8E8
  component "Laptop" as laptop #87CEEB
}

package "Kubernetes Cluster" {
  component "Pi-hole" as pihole #2E7D32
  component "CoreDNS" as coredns #1565C0
  component "nginx-ingress" as ingress #E91E63
  component "ArgoCD" as argocd #EF4444
  component "GitLab" as gitlab #FC6D26
  component "Jellyfin" as jellyfin #AA5CC3
  component "Grafana" as grafana #F46800
}

package "Internet" {
  component "Cloudflare DNS" as cloudflare #FF6F00
  component "Let's Encrypt" as letsencrypt #00BCD4
}

fritzbox --> pihole
pihole --> cloudflare
ingress --> argocd
ingress --> gitlab
ingress --> jellyfin

@enduml
```

**Gerendertes Diagramm** (als Bild eingebunden):

**Option 1: Direkte URL** (funktioniert in GitLab, wenn Server erreichbar):

⚠️ **Hinweis**: Die direkte URL kann manchmal die Welcome-Seite statt des Diagramms anzeigen. Verwende Option 2 (Asset) für zuverlässige Anzeige.

![Infrastruktur-Diagramm](https://plantuml.k8sops.online/png/eJx1U01z2jAQvetXbPGhJ3eAgIEeOjHCJGlopjM9tFdhr42KWHkkeUjS6X-vLJMEk6lOT2_efujt6to6YVxzUHBHpRHWmWbvGhNvBBU234nSsQ9uhweEWglJzO4l1cKIA2xFvq-MbqjgWmkD0Tocxpx0CuFeH2qFzuF_E3-GW5QHQvd8RLOH_dzq2n7SpCQhY7VPLyqEwa0wxVEYHMAfBpD7tJqQHAzWRrrnpX6E2XQxhPTXAISFsiW3nvTtpNPhsB9y32zR-Ipo4UEXGCJ8XfIYoskoWWSjfsBPSYU-2vib8D37vkLEsSMhGg7TeTbvR2xE7XQddCpAiOYznmVL9vfsUWeNcNVYh-bd877LeKdVV7GWLYRonM1WV-O-jmuDq4cfQZd7XJDvbDRNpvzi8VRJeowlVQatDfIThihbjLLkqi9PTaX5KuiEh3nhZeuJP33ZjXQbsQ2yyg9ebL3zPFmNk77sKyr1VEoKwt-nC0RpOuX8ovCNEaUg0aXssM85SeZ-muce3pELHr5zjivdFKXyOwOvxrxRfjGS9eVibNB9tJBRbp5q1w0PncXu3g56yVeTtvrrfsXxl9NY2Gk6LfNWh72Y29KdgT2qM6tHvdjC2DVS4f_kP_ZZL68=)

**Option 2: Als Asset** (funktioniert immer, auch in GitHub Public Repos):
![Infrastruktur-Diagramm](./docs/infrastruktur-diagramm.png)

**Hinweis**: 
- Option 1 nutzt deinen PlantUML-Server (`plantuml.k8sops.online`) - funktioniert in GitLab, wenn der Server erreichbar ist
- Option 2 ist ein gerendertes PNG-Asset, das immer funktioniert (auch in GitHub Public Repos)

**Vorteile**:
- ✅ Läuft auf eigenem Server
- ✅ Sehr mächtige Diagramm-Typen
- ✅ Textbasiert, versionierbar

**Nachteile**:
- ⚠️ GitHub kann nicht auf private Server zugreifen (für Public Repos)
- ⚠️ Encoding erforderlich

---

## 2. Mermaid Visualisierung (GitHub/GitLab Native)

### Infrastruktur-Übersicht

````markdown
```mermaid
graph TB
    subgraph "Hardware"
        FB[FritzBox 7590 AX<br/>192.168.178.1]
        K8S[Kubernetes Node<br/>zuhause<br/>192.168.178.54]
        WIN[Windows-Maschine<br/>WSL2 Host]
        LAP[Laptop<br/>Fedora 42]
    end
    
    subgraph "Netzwerk 192.168.178.0/24"
        DHCP[DHCP Server<br/>20-50, 60-200]
        DNSFW[DNS Forwarder]
    end
    
    subgraph "Kubernetes Cluster"
        subgraph "DNS-Stack"
            PH[Pi-hole<br/>192.168.178.54:53<br/>15 Blocklisten]
            CDNS[CoreDNS<br/>10.96.0.10]
        end
        
        subgraph "Ingress & TLS"
            ING[nginx-ingress<br/>192.168.178.54:80/443]
            CERT[Cert-Manager<br/>Let's Encrypt]
        end
        
        subgraph "GitOps & CI/CD"
            ARGO[ArgoCD<br/>8 Applications]
            GL[GitLab<br/>PostgreSQL + Redis]
            GLAG[GitLab Agent]
            GLRUN[GitLab Runner]
        end
        
        subgraph "Media Services"
            JELLY[Jellyfin<br/>10Gi Memory]
            KOMGA[Komga<br/>Port 25600]
        end
        
        subgraph "Monitoring"
            GRAF[Grafana<br/>Monitoring Dashboard]
            PROM[Prometheus<br/>Metrics]
            LOKI[Loki<br/>Log Aggregation]
        end
        
        subgraph "Dashboard & Tools"
            HEIM[Heimdall<br/>Service Dashboard]
            K8SD[Kubernetes Dashboard]
            PLANT[PlantUML Server<br/>Port 8080]
        end
        
        SYNC[Syncthing<br/>File Sync]
        VEL[Velero<br/>Backup System]
    end
    
    subgraph "Internet"
        CF[Cloudflare DNS<br/>1.1.1.1, 1.0.0.1]
        LE[Let's Encrypt<br/>ACME Server]
        UD[United Domains<br/>Domain Registrar]
    end
    
    FB --> DHCP
    DHCP --> DNSFW
    DNSFW --> PH
    WIN --> FB
    LAP --> FB
    
    PH --> CF
    PH --> ING
    CDNS --> PH
    K8S --> CDNS
    
    ING --> ARGO
    ING --> GL
    ING --> JELLY
    ING --> KOMGA
    ING --> SYNC
    ING --> GRAF
    ING --> PROM
    ING --> HEIM
    ING --> K8SD
    ING --> PLANT
    ING --> PH
    
    CERT --> LE
    CERT --> CF
    CERT --> ING
    
    ARGO --> GL
    GLAG --> GL
    GLRUN --> GL
    
    CF --> UD
    CF --> ING
    
    classDef hardware fill:#FFA500,stroke:#E65100,stroke-width:2px,color:#fff
    classDef network fill:#2196F3,stroke:#0D47A1,stroke-width:2px,color:#fff
    classDef dns fill:#2E7D32,stroke:#1B5E20,stroke-width:2px,color:#fff
    classDef ingress fill:#E91E63,stroke:#880E4F,stroke-width:2px,color:#fff
    classDef gitops fill:#EF4444,stroke:#B71C1C,stroke-width:2px,color:#fff
    classDef media fill:#AA5CC3,stroke:#4A148C,stroke-width:2px,color:#fff
    classDef monitoring fill:#F46800,stroke:#E65100,stroke-width:2px,color:#fff
    classDef tools fill:#3B82F6,stroke:#1E40AF,stroke-width:2px,color:#fff
    classDef internet fill:#FF6F00,stroke:#E65100,stroke-width:2px,color:#fff
    
    class FB,K8S,WIN,LAP hardware
    class DHCP,DNSFW network
    class PH,CDNS dns
    class ING,CERT ingress
    class ARGO,GL,GLAG,GLRUN gitops
    class JELLY,KOMGA media
    class GRAF,PROM,LOKI monitoring
    class HEIM,K8SD,PLANT,SYNC,VEL tools
    class CF,LE,UD internet
```
````

**Vorteile**:
- ✅ Native Unterstützung in GitHub/GitLab
- ✅ Rendert direkt im Markdown
- ✅ Keine externe Abhängigkeit

**Nachteile**:
- ⚠️ Begrenzte Diagramm-Typen
- ⚠️ Weniger mächtig als PlantUML

---

## 3. DNS-Flow Diagramm (Mermaid)

````markdown
```mermaid
sequenceDiagram
    participant C as Client
    participant FB as FritzBox
    participant PH as Pi-hole
    participant CF as Cloudflare
    participant ING as Ingress
    
    C->>FB: DHCP Request
    FB->>C: DNS Server: 192.168.178.54
    C->>PH: DNS Query: gitlab.k8sops.online
    PH->>PH: Check Local Records
    alt Local Record Found
        PH->>C: 192.168.178.54
    else External Domain
        PH->>CF: Upstream Query
        CF->>PH: IP Address
        PH->>C: IP Address
    end
    C->>ING: HTTPS Request
    ING->>C: Response
```
````

---

## 4. Kubernetes Services Übersicht (Mermaid)

````markdown
```mermaid
graph LR
    subgraph "Kubernetes Namespaces"
        ARGO[argocd<br/>7 Pods]
        GL[gitlab<br/>3 Pods]
        DEF[default<br/>6 Pods]
        MON[monitoring<br/>3 Pods]
        PIHOLE[pihole<br/>1 Pod]
        HEIM[heimdall<br/>1 Pod]
        KOMGA[komga<br/>1 Pod]
        SYNC[syncthing<br/>1 Pod]
        PLANT[plantuml<br/>1 Pod]
    end
    
    ING[nginx-ingress<br/>192.168.178.54]
    
    ING --> ARGO
    ING --> GL
    ING --> DEF
    ING --> MON
    ING --> PIHOLE
    ING --> HEIM
    ING --> KOMGA
    ING --> SYNC
    ING --> PLANT
```
````

---

## Vergleich: GitHub vs GitLab

### GitHub

**Vorteile**:
- ✅ Mermaid native Unterstützung
- ✅ PlantUML über plantuml.com möglich
- ✅ Große Community
- ✅ Gute Markdown-Rendering

**Nachteile**:
- ⚠️ Kann nicht auf private Server zugreifen
- ⚠️ PlantUML nur über externe Services

**Empfehlung für GitHub**:
1. **Mermaid** (primär) - Native Unterstützung
2. **PlantUML** (via plantuml.com) - Für komplexe Diagramme
3. **Rendered Images** - Für Graphviz/komplexe Visualisierungen

### GitLab

**Vorteile**:
- ✅ Mermaid native Unterstützung
- ✅ PlantUML über plantuml.com möglich
- ✅ Kann auf private Server zugreifen (wenn konfiguriert)
- ✅ PlantUML über eigenen Server möglich

**Nachteile**:
- ⚠️ Kleinere Community als GitHub

**Empfehlung für GitLab**:
1. **Mermaid** (primär) - Native Unterstützung
2. **PlantUML** (via plantuml.k8sops.online) - Eigener Server
3. **Rendered Images** - Für komplexe Visualisierungen

---

## Weitere Visualisierungstechniken

### 1. Graphviz/DOT

**Vorteile**:
- ✅ Sehr mächtig für komplexe Graphen
- ✅ Viele Layout-Algorithmen
- ✅ Export in viele Formate

**Nachteile**:
- ⚠️ Nicht nativ in GitHub/GitLab
- ⚠️ Rendering erforderlich

**Verwendung**:
- Lokal rendern und als Bild committen
- Oder: Online-Tools nutzen (z.B. graphviz.org)

### 2. ASCII-Art

**Vorteile**:
- ✅ Funktioniert überall
- ✅ Keine Rendering-Abhängigkeit
- ✅ Einfach zu editieren

**Nachteile**:
- ⚠️ Nicht so visuell ansprechend
- ⚠️ Manuelle Formatierung

**Beispiel**:
```
┌─────────────────┐
│   FritzBox      │
│ 192.168.178.1   │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
┌───▼───┐ ┌──▼───┐
│ Pi-hole│ │Ingress│
│  :53   │ │ :80/443│
└────────┘ └───────┘
```

### 3. C4 Model (PlantUML)

**Vorteile**:
- ✅ Strukturierte Architektur-Diagramme
- ✅ Mehrere Abstraktionsebenen
- ✅ Standardisiert

**Nachteile**:
- ⚠️ Komplexere Syntax
- ⚠️ Rendering erforderlich

---

## Webinterfaces & Zugangsdaten

### ArgoCD
- **URL**: https://argocd.k8sops.online
- **Benutzername**: `admin`
- **Passwort**: `Montag69`

### GitLab
- **URL**: https://gitlab.k8sops.online
- **Root-Passwort**: `BXE1uwajqBDLgsWiesGB1081`

### Grafana
- **URL**: https://grafana.k8sops.online
- **Benutzername**: `admin`
- **Passwort**: `Montag69`

### Pi-hole
- **URL**: https://pihole.k8sops.online/admin/
- **Benutzername**: `admin`
- **Passwort**: `cK1lubq8C7MZrEgipfUpEAc0`

### Jellyfin
- **URL**: https://jellyfin.k8sops.online
- **Benutzername**: `bernd`
- **Passwort**: `Montag69`

### Komga
- **URL**: https://komga.k8sops.online
- **Email**: `admin@k8sops.online`
- **Passwort**: `1zBlOIBqlGTHxb15GnGqyPOi`

### Syncthing
- **URL**: https://syncthing.k8sops.online
- **Zugangsdaten**: Erste Einrichtung über Webinterface erforderlich

### Kubernetes Dashboard
- **URL**: https://dashboard.k8sops.online
- **Zugangsdaten**: Service Account Token erforderlich

### Heimdall
- **URL**: https://heimdall.k8sops.online
- **Zugangsdaten**: Kein Login erforderlich

### PlantUML
- **URL**: https://plantuml.k8sops.online
- **Zugangsdaten**: Kein Login erforderlich

### Prometheus
- **URL**: https://prometheus.k8sops.online
- **Zugangsdaten**: Kein Login erforderlich

**Vollständige Liste**: Siehe [webinterfaces-zugangsdaten-2025-11-08.md](./webinterfaces-zugangsdaten-2025-11-08.md)

---

## Empfehlungen

### Für GitHub Public Repos
1. **Mermaid** (primär) - Native Unterstützung
2. **PlantUML** (via plantuml.com) - Für komplexe Diagramme
3. **Rendered Images** - Für Graphviz/komplexe Visualisierungen

### Für GitHub Private Repos / GitLab
1. **Mermaid** (primär) - Native Unterstützung
2. **PlantUML** (via plantuml.k8sops.online) - Eigener Server
3. **Rendered Images** - Für komplexe Visualisierungen

### Für lokale Dokumentation
1. **PlantUML** (via plantuml.k8sops.online) - Eigener Server
2. **Mermaid** - Via Viewer-Tools
3. **Graphviz** - Lokal rendern

---

**Ende der Dokumentation**
