# Agent Handover: DNS-Dokumentation und Infrastruktur-Übersicht

## 📋 Übersicht

Dieses Dokument dient als Handover für einen anderen Agenten und erklärt die DNS-Infrastruktur des Heimnetzwerks in einfacher, visueller Form.

## 🎯 Zielgruppe

- **Für Agenten**: Vollständige technische Dokumentation
- **Für Menschen**: Einfache Erklärungen "wie für ein Kleinkind"

---

## 🌐 DNS-Infrastruktur - Einfach erklärt

### Was ist DNS?

DNS (Domain Name System) ist wie ein **Telefonbuch für das Internet**. 
Wenn du `gitlab.k8sops.online` in den Browser eingibst, findet DNS die richtige IP-Adresse (z.B. `192.168.178.54`), damit dein Computer weiß, wohin er gehen soll.

### Unser DNS-System - Schritt für Schritt

Stell dir vor, du fragst nach dem Weg zu einem Freund:

1. **Du (Client)** fragst: "Wo ist gitlab.k8sops.online?"
2. **Fritzbox (Router)** kennt den DNS-Server: "Frag mal den Pi-hole!"
3. **Pi-hole (DNS-Server)** prüft: "Ist das lokal? Nein? Dann frag Cloudflare!"
4. **Cloudflare (Internet-DNS)** antwortet: "Das ist 192.168.178.54"
5. **Pi-hole** merkt sich das und gibt es weiter
6. **Du** bekommst die Antwort und kannst jetzt dorthin gehen

---

## 🔄 DNS-Flow Diagramm

### Mermaid-Visualisierung

```mermaid
graph TB
    subgraph "Client (Laptop/Handy)"
        C[Client<br/>Möchte: gitlab.k8sops.online]
    end
    
    subgraph "Fritzbox (Router)"
        FB[Fritzbox<br/>DNS-Server: 192.168.178.10]
    end
    
    subgraph "Pi-hole Kubernetes"
        PH[Pi-hole<br/>192.168.178.10<br/>Filtert Werbung]
        PH_LOCAL[Lokale DNS-Einträge<br/>*.k8sops.online → 192.168.178.54]
    end
    
    subgraph "Kubernetes Cluster"
        COREDNS[CoreDNS<br/>Upstream: Pi-hole]
        K8S_SVC[Kubernetes Services<br/>gitlab.k8sops.online]
    end
    
    subgraph "Internet"
        CF[Cloudflare DNS<br/>1.1.1.1, 1.0.0.1<br/>Public DNS]
    end
    
    subgraph "Registrar & DNS Provider"
        UD[United Domains<br/>Registrar<br/>k8sops.online]
        CF_DNS[Cloudflare DNS<br/>DNS Provider<br/>k8sops.online]
    end
    
    C -->|1. DNS-Anfrage| FB
    FB -->|2. Weiterleitung| PH
    PH -->|3a. Lokale Domain?| PH_LOCAL
    PH_LOCAL -->|Ja: *.k8sops.online| K8S_SVC
    PH -->|3b. Externe Domain?| CF
    CF -->|4. Öffentliche IP| C
    COREDNS -->|Upstream| PH
    
    UD -->|Domain-Registrierung| CF_DNS
    CF_DNS -->|DNS-Records| CF
    
    classDef client fill:#0277bd,stroke:#01579b,stroke-width:3px,color:#ffffff
    classDef fritzbox fill:#f57c00,stroke:#e65100,stroke-width:3px,color:#ffffff
    classDef pihole fill:#2e7d32,stroke:#1b5e20,stroke-width:3px,color:#ffffff
    classDef kubernetes fill:#1565c0,stroke:#0d47a1,stroke-width:3px,color:#ffffff
    classDef cloudflare fill:#ff6f00,stroke:#e65100,stroke-width:3px,color:#ffffff
    classDef internet fill:#6a1b9a,stroke:#4a148c,stroke-width:3px,color:#ffffff
    classDef registrar fill:#5d4037,stroke:#3e2723,stroke-width:3px,color:#ffffff
    
    class C client
    class FB fritzbox
    class PH,PH_LOCAL pihole
    class COREDNS,K8S_SVC kubernetes
    class CF,CF_DNS cloudflare
    class UD registrar
```

### PlantUML-Visualisierung (für PlantUML-Server)

```plantuml
@startuml DNS-Flow
!theme plain
skinparam backgroundColor #FFFFFF
skinparam defaultFontSize 12

package "Client (Laptop/Handy)" {
  [Client] as Client
  note right of Client
    Möchte: gitlab.k8sops.online
  end note
}

package "Fritzbox (Router)" {
  [Fritzbox] as FB
  note right of FB
    DNS-Server: 192.168.178.10
    Weiterleitung an Pi-hole
  end note
}

package "Pi-hole Kubernetes" {
  [Pi-hole] as PH
  [Lokale DNS-Einträge] as PH_LOCAL
  note right of PH
    192.168.178.10
    Filtert Werbung
  end note
  note right of PH_LOCAL
    *.k8sops.online → 192.168.178.54
  end note
}

package "Kubernetes Cluster" {
  [CoreDNS] as COREDNS
  [Kubernetes Services] as K8S_SVC
  note right of COREDNS
    Upstream: Pi-hole
  end note
}

package "Internet" {
  [Cloudflare DNS] as CF
  note right of CF
    1.1.1.1, 1.0.0.1
    Public DNS
  end note
}

package "Registrar & DNS Provider" {
  [United Domains] as UD
  [Cloudflare DNS Provider] as CF_DNS
  note right of UD
    Registrar
    k8sops.online
  end note
  note right of CF_DNS
    DNS Provider
    k8sops.online
  end note
}

Client --> FB : 1. DNS-Anfrage
FB --> PH : 2. Weiterleitung
PH --> PH_LOCAL : 3a. Lokale Domain?
PH_LOCAL --> K8S_SVC : Ja: *.k8sops.online
PH --> CF : 3b. Externe Domain?
CF --> Client : 4. Öffentliche IP
COREDNS --> PH : Upstream
UD --> CF_DNS : Domain-Registrierung
CF_DNS --> CF : DNS-Records

@enduml
```

---

## 📍 Wichtige IP-Adressen und Domains

### Lokales Netzwerk (192.168.178.0/24)

| Gerät/Service | IP-Adresse | Zweck |
|---------------|------------|-------|
| **Fritzbox** | 192.168.178.1 | Router/Gateway |
| **Pi-hole** | 192.168.178.10 | DNS-Server, Werbeblocker |
| **Kubernetes LoadBalancer** | 192.168.178.54 | Alle Kubernetes-Services |
| **Pi-hole (Kubernetes)** | 10.244.0.XX | Pod-IP (intern) |

### Domains

| Domain | Ziel | Zweck |
|--------|------|-------|
| `*.k8sops.online` | 192.168.178.54 | Alle Kubernetes-Services |
| `gitlab.k8sops.online` | 192.168.178.54 | GitLab |
| `dashboard.k8sops.online` | 192.168.178.54 | Kubernetes Dashboard |
| `argocd.k8sops.online` | 192.168.178.54 | ArgoCD |
| `grafana.k8sops.online` | 192.168.178.54 | Grafana |

---

## 🔧 DNS-Konfiguration Details

### 1. Fritzbox Konfiguration

**DNS-Server:**
- Primär: `192.168.178.10` (Pi-hole)
- Sekundär: `8.8.8.8` (Google DNS - Fallback)

**DHCP:**
- Gibt Pi-hole DNS weiter an alle Clients
- Bereich: 192.168.178.20-200

### 2. Pi-hole Konfiguration

**Lokale DNS-Einträge:**
- `*.k8sops.online` → `192.168.178.54`
- Wildcard-Eintrag für alle Subdomains

**Upstream-DNS:**
- Primär: `1.1.1.1` (Cloudflare)
- Sekundär: `1.0.0.1` (Cloudflare)

**Features:**
- Werbeblockierung (Adlists)
- DNS-Logging
- Query-Logging

### 3. CoreDNS (Kubernetes)

**Konfiguration:**
- Upstream: Pi-hole (192.168.178.10)
- Fallback: 1.1.1.1 (Cloudflare)
- Service-Discovery für Kubernetes Services

### 4. Cloudflare (DNS Provider)

**DNS-Records für k8sops.online:**
- A-Record: `@` → Public IP (Dynamic DNS)
- A-Record: `*` → Public IP (Wildcard)
- NS-Records: Cloudflare Nameserver

**Features:**
- DDoS-Schutz
- SSL/TLS (Full)
- DNS-Management via API

---

## 🔐 Sicherheit

### Domain-Sicherheit

**WHOIS Privacy:**
- ✅ Aktiviert (United Domains)
- ✅ Persönliche Daten geschützt

**Domain-Lock:**
- ✅ Aktiviert
- ✅ Verhindert Domain-Transfer ohne Autorisierung

**2FA:**
- ⚠️ Sollte aktiviert werden für zusätzliche Sicherheit

**DNSSEC:**
- ❌ Nicht aktiviert
- **Grund**: Kostenpflichtig bei United Domains (Domain-Tresor)
- **Empfehlung**: Für privates Heimnetzwerk nicht notwendig

### SSL/TLS-Zertifikate

**Cert-Manager:**
- ✅ Verwendet Let's Encrypt
- ✅ DNS01-Challenge mit Cloudflare API
- ✅ Automatische Erneuerung

**Zertifikate:**
- Alle Services haben gültige Zertifikate
- Automatische Erneuerung aktiv

---

## 🚀 Aktuelle Services im Cluster

### Über DNS erreichbar:

1. **GitLab** - https://gitlab.k8sops.online
   - Status: ✅ Läuft stabil (Pod `gitlab-fff89c66b-lxgh5` seit 2025-11-05 17:10 CET ohne Restarts)
   - HTTPS: ✅ Funktioniert (Ingress-Check → 308 Redirect zu HTTPS)
   - Web-Interface: 🟡 Login-Test ausstehend (IP-Spoofing-Fix aktiv, bitte im Browser prüfen)

2. **Kubernetes Dashboard** - https://dashboard.k8sops.online
   - Status: ✅ Läuft
   - Login: Token-basiert

3. **ArgoCD** - https://argocd.k8sops.online
   - Status: ✅ Läuft
   - GitOps-Deployment

4. **Grafana** - https://grafana.k8sops.online
   - Status: ✅ Läuft
   - Monitoring

5. **Prometheus** - https://prometheus.k8sops.online
   - Status: ✅ Läuft
   - Metriken-Sammlung

---

## 📊 DNS-Auflösung - Detaillierter Flow

### Beispiel: Anfrage für gitlab.k8sops.online

```mermaid
sequenceDiagram
    participant C as Client
    participant FB as Fritzbox
    participant PH as Pi-hole
    participant PH_LOCAL as Pi-hole<br/>Lokale Einträge
    participant K8S as Kubernetes<br/>Ingress
    participant GL as GitLab Pod
    
    C->>FB: DNS-Anfrage: gitlab.k8sops.online?
    FB->>PH: Weiterleitung an 192.168.178.10
    PH->>PH_LOCAL: Prüfe lokale Einträge
    PH_LOCAL->>PH: *.k8sops.online → 192.168.178.54
    PH->>FB: Antwort: 192.168.178.54
    FB->>C: Antwort: 192.168.178.54
    C->>K8S: HTTPS Request: gitlab.k8sops.online
    K8S->>GL: Weiterleitung an GitLab Service
    GL->>C: GitLab Web-Interface
```

### Beispiel: Externe Domain (z.B. google.com)

```mermaid
sequenceDiagram
    participant C as Client
    participant FB as Fritzbox
    participant PH as Pi-hole
    participant CF as Cloudflare DNS
    participant EXT as Externe Website
    
    C->>FB: DNS-Anfrage: google.com?
    FB->>PH: Weiterleitung an 192.168.178.10
    PH->>PH_LOCAL: Prüfe lokale Einträge
    PH_LOCAL->>PH: Nicht gefunden
    PH->>CF: Upstream: 1.1.1.1
    CF->>PH: Antwort: 142.250.185.14
    PH->>FB: Antwort: 142.250.185.14
    FB->>C: Antwort: 142.250.185.14
    C->>EXT: HTTP Request: google.com
```

---

## 🔍 Troubleshooting

### Häufige Probleme

#### Problem: DNS-Auflösung funktioniert nicht

**Prüfungen:**
1. Pi-hole erreichbar? `ping 192.168.178.10`
2. Fritzbox DNS korrekt? `nslookup gitlab.k8sops.online 192.168.178.10`
3. Pi-hole läuft? `kubectl get pods -n default -l app=pihole`

**Lösung:**
- Pi-hole Pod-Status prüfen
- DNS-Einträge in Pi-hole prüfen
- Fritzbox DNS-Server-Einstellungen prüfen

#### Problem: Domain auflösbar, aber Service nicht erreichbar

**Prüfungen:**
1. Ingress vorhanden? `kubectl get ingress -A`
2. Service läuft? `kubectl get pods -n <namespace>`
3. Zertifikat gültig? `kubectl get certificate -n <namespace>`

**Lösung:**
- Ingress-Logs prüfen
- Service-Endpunkte prüfen
- Pod-Status prüfen

---

## 📝 Wichtige Dateien

### DNS-Konfiguration
- `dns-flow-diagram.md` - DNS-Flow Mermaid-Diagramm
- `dns-provider-analyse.md` - Cloudflare/United Domains Analyse
- `domain-sicherheitsanalyse.md` - Sicherheitsanalyse
- `dnssec-erklaerung.md` - DNSSEC Erklärung

### Kubernetes-Konfiguration
- `kubernetes-analyse.md` - Cluster-Übersicht
- `k8s/monitoring/` - Monitoring-Tools Manifeste

### GitOps
- `.github/workflows/` - GitHub Actions
- `.gitlab-ci.yml` - GitLab CI
- `k8s/` - Kubernetes Manifeste

---

## 🎓 Für Agenten: Wichtige Befehle

### DNS-Tests

```bash
# DNS-Auflösung testen
nslookup gitlab.k8sops.online 192.168.178.10

# Pi-hole API abfragen
curl http://192.168.178.10/admin/api.php?summaryRaw

# Kubernetes DNS testen
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup gitlab.k8sops.online
```

### Kubernetes-Services prüfen

```bash
# Alle Pods
kubectl get pods -A

# Ingress prüfen
kubectl get ingress -A

# DNS-Service (CoreDNS)
kubectl get svc -n kube-system kube-dns

# Pi-hole Status
kubectl get pods -n default -l app=pihole
```

### GitLab-Zugriff

```bash
# Pod-Status
kubectl get pods -n gitlab

# Logs
kubectl logs -n gitlab -l app=gitlab --tail=50

# API-Test
curl -k -H "PRIVATE-TOKEN: <token>" https://gitlab.k8sops.online/api/v4/user
```

---

## 🔄 Aktuelle Aufgaben und Status

### ✅ Erledigt
- [x] GitLab Deployment repariert (Liveness/Readiness Probes)
- [x] HTTPS-Konfiguration für GitLab
- [x] DNS-Auflösung funktioniert
- [x] Kubernetes Dashboard deployed
- [x] K9s installiert
- [x] ArgoCD Application erstellt
- [x] Group "neue-zeit" in GitLab erstellt
- [x] Personal Access Token für GitLab API erstellt

### ⚠️ In Arbeit
- [ ] Repository "heimnetzwerk-infra" in GitLab erstellen
- [ ] GitHub/GitLab Sync finalisieren
- [ ] GitLab Login im Browser testen (HandleIpSpoof-Fix aktiv, Pod seit 17:10 CET stabil)

### 📋 Offen
- [ ] ArgoCD-Zugriff testen
- [ ] Alle Services im Dashboard verifizieren

---

## 🚨 Bekannte Probleme

### GitLab
- **Problem**: Web-Interface-Login gab 500-Fehler (HandleIpSpoofAttackError)
- **Fix**: `trusted_proxies` in ConfigMap + Liveness-Probe auf `initialDelaySeconds=600`, `failureThreshold=12` via `kubectl patch` (2025-11-05)
- **Status**: Pod `gitlab-fff89c66b-lxgh5` läuft seit 2025-11-05 17:10 CET ohne Restarts; `curl` auf `/users/sign_in` liefert 200, manueller Browser-Login noch offen

### Kubernetes Dashboard
- **Problem**: Secret "kubernetes-dashboard-csrf" fehlte
- **Fix**: Secret erstellt
- **Status**: ✅ Funktioniert jetzt

---

## 📞 Wichtige Zugangsdaten (für Agenten)

### GitLab
- **URL**: https://gitlab.k8sops.online
- **Root-User**: root
- **Passwort**: TempPass123! (temporär gesetzt)
- **API-Token**: `glpat-q9cRQjBeN--9eKsPzjZn5G86MQp1OjEH.01.0w11ag1un`
- **Group**: neue-zeit (ID: 3)

### Kubernetes Dashboard
- **URL**: https://dashboard.k8sops.online
- **Login**: Token-basiert
- **Token**: Via `kubectl -n kubernetes-dashboard create token kubernetes-dashboard`

### ArgoCD
- **URL**: https://argocd.k8sops.online
- **Admin-Passwort**: In Secret `argocd-initial-admin-secret`

---

## 🎯 Nächste Schritte für neuen Agenten

1. **GitLab Login testen**
   - HTTPS-URL öffnen
   - Mit root / TempPass123! einloggen
   - Falls 500-Fehler: Logs prüfen, trusted_proxies verifizieren

2. **Alle Services verifizieren**
   - Dashboard, ArgoCD, Grafana, Prometheus
   - HTTPS-Zugriff testen
   - Funktionalität prüfen

3. **Repository-Sync**
   - GitHub → GitLab Sync testen
   - GitLab → GitHub Sync testen
   - Tokens verifizieren

4. **Dokumentation aktualisieren**
   - Zugangsdaten dokumentieren
   - Funktionsstatus aktualisieren
   - Bekannte Probleme dokumentieren

---

## 📚 Weitere Ressourcen

- [DNS-Flow Diagramm](dns-flow-diagram.md)
- [DNS Provider Analyse](dns-provider-analyse.md)
- [Domain Sicherheitsanalyse](domain-sicherheitsanalyse.md)
- [Kubernetes Analyse](kubernetes-analyse.md)
- [GitLab Analyse](gitlab-analyse.md)

---

**Erstellt**: 2025-11-05
**Letzte Aktualisierung**: 2025-11-05
**Status**: In Arbeit - GitLab Login muss noch behoben werden

