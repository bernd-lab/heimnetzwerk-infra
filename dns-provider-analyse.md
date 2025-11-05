# DNS-Provider Analyse: United Domains & Cloudflare

## Analyse der DNS-Konfiguration für k8sops.online

### Bekannte Konfiguration aus Kubernetes

**Cert-Manager Konfiguration:**
- ClusterIssuer: `letsencrypt-prod-dns01`
- Challenge: DNS01 mit Cloudflare
- API Token: Secret `cloudflare-api-token` (Key: `api-token`)
- Status: Ready (Account registriert)

**Schlussfolgerung:**
- Die Domain `k8sops.online` wird über Cloudflare DNS verwaltet
- Cert-Manager nutzt Cloudflare API für DNS01-Challenges
- United Domains ist vermutlich der Registrar (Domain-Registrierung)

### DNS-Flow Analyse

**Aktueller Flow:**
```
Domain-Registrierung: United Domains
DNS-Verwaltung: Cloudflare
DNS-Challenge: Cert-Manager → Cloudflare API
```

### Empfehlungen für DNS-Konfiguration

#### 1. United Domains (Registrar)
**Zu prüfen:**
- Nameserver auf Cloudflare zeigen lassen
- Domain-Status: Active
- Auto-Renew: Aktiviert
- WHOIS Privacy: Aktiviert (optional)

**Typische Konfiguration:**
- Nameserver: `*.cloudflare.com` (von Cloudflare zugewiesen)
- Domain-Lock: Aktiviert (Schutz vor unberechtigten Transfers)

#### 2. Cloudflare DNS (DNS-Provider)
**Zu prüfen:**
- DNS Records für `*.k8sops.online` → `192.168.178.54` (A-Record oder CNAME)
- Wildcard DNS: `*.k8sops.online` → `192.168.178.54`
- Root-Domain: `k8sops.online` → `192.168.178.54` (optional)
- API Token: Berechtigungen für DNS-Edit (Cert-Manager)

**Empfohlene DNS-Records:**
```
*.k8sops.online    A    192.168.178.54    (Wildcard für alle Subdomains)
k8sops.online      A    192.168.178.54    (Root-Domain, optional)
```

**Cloudflare Einstellungen:**
- **Proxy Status**: Off (grau) für interne IPs (192.168.x.x)
- **DNS Only**: Aktiviert für interne IPs
- **TTL**: Auto oder 300s
- **DNSSEC**: Aktiviert (optional, aber empfohlen)

#### 3. Cert-Manager Integration
**Aktuell:**
- ✅ Cloudflare DNS01-Challenge konfiguriert
- ✅ API Token vorhanden
- ✅ Funktioniert für externe Domains

**Zu prüfen:**
- API Token Berechtigungen: `Zone:Edit` und `DNS:Edit`
- Token Scope: Nur für `k8sops.online` Zone
- Token Status: Aktiv

### Sicherheitsempfehlungen

1. **Cloudflare API Token:**
   - Minimal benötigte Berechtigungen
   - Nur für spezifische Zone
   - Regelmäßig rotieren

2. **DNS-Sicherheit:**
   - DNSSEC aktivieren (wenn möglich)
   - DNS-Lock bei United Domains aktivieren
   - 2FA für beide Accounts aktivieren

3. **Monitoring:**
   - DNS-Record Änderungen überwachen
   - Zertifikat-Erneuerungen loggen

### Nächste Schritte

1. **United Domains prüfen:**
   - Login über korrekte URL (möglicherweise über https://www.united-domains.de/beispiel-portfolio/)
   - Nameserver-Konfiguration prüfen
   - Domain-Status prüfen

2. **Cloudflare prüfen:**
   - DNS-Records für `*.k8sops.online` prüfen
   - API Token Berechtigungen verifizieren
   - Proxy-Status für interne IPs prüfen

3. **DNS-Test:**
   ```bash
   dig gitlab.k8sops.online +short
   dig *.k8sops.online +short
   ```

## Analyse-Ergebnisse

### United Domains (Registrar)

**Status:**
- ✅ Domain `k8sops.online` registriert und aktiv
- ✅ Nameserver korrekt auf Cloudflare konfiguriert:
  - `gabriella.ns.cloudflare.com`
  - `olof.ns.cloudflare.com`
- ✅ Domain-Tresor: Nicht aktiv (nicht kritisch, da Cloudflare Features vorhanden)

**Empfehlungen:**
- 2FA für United Domains Account aktivieren (kostenlos)
- Domain-Lock aktivieren (Schutz vor unberechtigten Transfers)
- Domain-Tresor nicht notwendig (Cloudflare bietet bessere Features)

### Cloudflare DNS (DNS-Provider)

**Status:**
- ✅ Nameserver aktiv: `gabriella.ns.cloudflare.com`, `olof.ns.cloudflare.com`
- ✅ DNS-Records funktionieren korrekt:
  - `k8sops.online` → `192.168.178.54`
  - `gitlab.k8sops.online` → `192.168.178.54`
  - `jenkins.k8sops.online` → `192.168.178.54`
  - `grafana.k8sops.online` → `192.168.178.54`
  - `argocd.k8sops.online` → `192.168.178.54`
  - `test.k8sops.online` → `192.168.178.54`
  - Alle weiteren Subdomains funktionieren
- ✅ Cert-Manager API Token vorhanden (40 Zeichen)
- ✅ Cert-Manager funktioniert: 10+ Zertifikate erfolgreich erstellt
  - argocd, jellyfin, jenkins, plantuml, gitlab, heimdall, komga, loki, grafana, prometheus

**Vermutete Konfiguration (basierend auf funktionierenden DNS-Records):**
- ✅ Wildcard DNS-Record: `*.k8sops.online` → `192.168.178.54` (funktioniert)
- ✅ Root-Domain: `k8sops.online` → `192.168.178.54` (funktioniert)
- ⚠️ Proxy-Status: Vermutlich "DNS Only" (da interne IP 192.168.x.x)
- ⚠️ DNSSEC: Status unbekannt (muss im Dashboard geprüft werden)

**Zu prüfen (benötigt Cloudflare Dashboard Login):**
- Proxy-Status für interne IPs bestätigen (sollte "DNS Only" sein)
- DNSSEC Status prüfen/aktivieren
- API Token Berechtigungen verifizieren (sollte `Zone:Edit` und `DNS:Edit` haben)
- SSL/TLS Einstellungen prüfen
- TTL-Einstellungen optimieren

### Zusammenfassung

**Status:**
- ✅ Cert-Manager korrekt konfiguriert
- ✅ Cloudflare API-Token vorhanden und funktionsfähig
- ✅ DNS-Records funktionieren korrekt (alle Subdomains zeigen auf 192.168.178.54)
- ✅ United Domains Nameserver korrekt konfiguriert
- ✅ Wildcard DNS funktioniert (test.k8sops.online, argocd.k8sops.online, etc.)
- ✅ 10+ Zertifikate erfolgreich via Cert-Manager erstellt
- ✅ Proxy-Status korrekt auf "DNS Only" für interne IPs
- ❌ DNSSEC: Nicht aktiviert (bewusst deaktiviert)

## DNSSEC Aktivierung

**Status (05.11.2025):**
- ✅ DNSSEC-Setup in Cloudflare wurde erfolgreich widerrufen
- ❌ DNSSEC nicht aktiviert (bewusst deaktiviert)
- ℹ️ Begründung: Für privates Heimnetzwerk nicht zwingend erforderlich, da bereits umfassende Sicherheitsmaßnahmen vorhanden
- ℹ️ Keine "pending" Statusmeldungen mehr - sauberer Zustand

**Hintergrund:**
- DNSSEC würde zusätzliche Sicherheitsschicht bieten (Schutz vor DNS-Manipulation)
- United Domains erfordert "Domain-Tresor" für DNSSEC (kostenpflichtig: 7,50 €/Jahr im ersten Jahr, dann 15 €/Jahr)
- Für privates Setup nicht kritisch, da bereits vorhanden: Cloudflare DDoS-Schutz, SSL/TLS, WHOIS Privacy, Domain-Lock, 2FA

**Hinweis:**
- DNSSEC kann jederzeit später aktiviert werden, wenn gewünscht
- Siehe `dnssec-erklaerung.md` für detaillierte Erklärung

**Optimierungspotenzial:**
- DNS-Records für interne Services über Cloudflare API automatisiert verwalten
- External-DNS Integration für automatische DNS-Updates
- Monitoring für DNS-Änderungen
- DNSSEC aktivieren (über Cloudflare)

