# Offene Tasks und weitere Empfehlungen

## Zusammenfassung der aktuellen Situation

### ✅ Was bereits erledigt wurde:

1. **DNS-Stack:**
   - ✅ Pi-hole in Kubernetes deployiert (192.168.178.10)
   - ✅ Fritzbox DNS-Server auf 192.168.178.10 geändert
   - ✅ CoreDNS Upstream auf 192.168.178.10 geändert
   - ✅ Pi-hole Custom DNS Records für *.k8sops.online hinzugefügt
   - ✅ Docker Pi-hole gestoppt

2. **DHCP:**
   - ✅ DHCP-Bereich angepasst (20-50, 60-200)
   - ✅ Kubernetes LoadBalancer IP (192.168.178.54) außerhalb DHCP-Bereich

3. **Sicherheit:**
   - ✅ WHOIS Privacy aktiv
   - ✅ Domain-Lock aktiv
   - ✅ 2FA auf Cloudflare und United Domains
   - ✅ DNSSEC bewusst nicht aktiviert (nicht kritisch für privates Setup)

4. **Port-Konflikte:**
   - ✅ nginx-reverse-proxy Docker gestoppt (Port 80/443 freigegeben)
   - ✅ Docker Pi-hole gestoppt (Port 53 freigegeben)

## 🔴 Kritische offene Tasks

### 1. Doppelte Docker-Container stoppen

**Status:**
- ⚠️ GitLab: Läuft sowohl in Docker als auch Kubernetes
- ⚠️ Jenkins: Läuft sowohl in Docker als auch Kubernetes
- ⚠️ Jellyfin: Läuft sowohl in Docker als auch Kubernetes

**Problem:**
- Ressourcenverschwendung (doppelte CPU/RAM-Nutzung)
- Verwirrung bei Service-Zugriff
- Potenzielle Dateninkonsistenzen

**Aktion:**
```bash
# Nach Verifizierung, dass Kubernetes-Versionen funktionieren:
docker stop gitlab jenkins jellyfin
# Optional nach erfolgreicher Migration:
docker rm gitlab jenkins jellyfin
```

**Vorher prüfen:**
- ✅ Kubernetes Services funktionieren (bereits verifiziert)
- ⚠️ Daten-Migration: Kubernetes-Versionen haben bereits PVCs mit Daten
- ⚠️ GitLab: 463 Restarts (instabil) - sollte überprüft werden

### 2. GitLab Stabilität prüfen

**Status:**
- ⚠️ Kubernetes GitLab: 463 Restarts in 40h (sehr instabil)
- ⚠️ Docker GitLab: Läuft noch (könnte stabiler sein)

**Aktion:**
```bash
# GitLab Logs prüfen
kubectl logs -n gitlab gitlab-6bd6446c6f-fbltz --tail=100

# Pod-Status detailliert prüfen
kubectl describe pod -n gitlab gitlab-6bd6446c6f-fbltz

# Ressourcen prüfen
kubectl top pod -n gitlab
```

**Mögliche Ursachen:**
- Ressourcenknappheit (CPU/RAM)
- PVC-Probleme
- Konfigurationsfehler
- Health-Check-Probleme

**Empfehlung:**
- Ursache identifizieren und beheben
- Erst danach Docker-Container stoppen

### 3. Kubernetes Ingress-Verfügbarkeit prüfen

**Status:**
- ✅ nginx-reverse-proxy Docker gestoppt (Port 80/443 frei)
- ⚠️ Kubernetes ingress-nginx sollte jetzt auf 192.168.178.54:80/443 funktionieren

**Aktion:**
```bash
# Ingress-Controller Status prüfen
kubectl get pods -n ingress-nginx

# Service-Status prüfen
kubectl get svc -n ingress-nginx

# HTTP/HTTPS-Test
curl -I http://192.168.178.54
curl -I https://192.168.178.54

# Domain-Tests
curl -I http://gitlab.k8sops.online
curl -I http://jenkins.k8sops.online
curl -I http://jellyfin.k8sops.online
```

**Erwartung:**
- Kubernetes Services sollten jetzt über ingress-nginx erreichbar sein
- Alle *.k8sops.online Domains sollten funktionieren

## 🟡 Wichtige offene Tasks

### 4. Monitoring-Container Migration (Optional)

**Status:**
- ⚠️ libvirt-exporter: Läuft noch in Docker (Port 9177)
- ⚠️ cAdvisor: Läuft noch in Docker (Port 8081)

**Optionen:**
- **Option A**: In Kubernetes migrieren (DaemonSet)
- **Option B**: Behalten (keine Port-Konflikte)
- **Option C**: Entfernen (falls nicht benötigt)

**Empfehlung:**
- Prüfen, ob diese Container noch benötigt werden
- Falls ja: In Kubernetes migrieren für Konsistenz
- Falls nein: Entfernen

### 5. CMDB (NetBox) Deployment

**Status:**
- ⚠️ NetBox wurde noch nicht installiert/deployed
- ✅ CMDB-Evaluierung durchgeführt (NetBox empfohlen)

**Zweck:**
- Strukturierte Infrastruktur-Dokumentation
- IP/DNS-Verwaltung
- API für Automatisierung
- Daten für KI-Agenten

**Aktion:**
```bash
# NetBox in Kubernetes deployen
# Helm Chart oder Manifests verwenden
# Initiale Daten importieren (IPs, Devices, Services)
```

**Priorität:**
- Nicht kritisch, aber hilfreich für zukünftige Analysen
- Kann später implementiert werden

### 6. DNS-Rebind-Schutz in Fritzbox

**Status:**
- ⚠️ Noch nicht geprüft/aktiviert

**Zweck:**
- Schutz vor DNS-Rebinding-Angriffen
- Verhindert, dass interne IPs über externe Domains aufgerufen werden

**Aktion:**
- Fritzbox Webinterface: Internet → Filter → DNS-Rebind-Schutz
- Prüfen und aktivieren

### 7. Unnötige Fritzbox-Dienste prüfen

**Status:**
- ⚠️ UPnP: Aktiviert (sollte geprüft werden)
- ⚠️ App-Zugriff (TR-064): Aktiviert (sollte geprüft werden)

**Empfehlung:**
- **UPnP**: Nur aktivieren wenn benötigt (z.B. für Gaming)
- **TR-064**: Nur für vertrauenswürdige Geräte aktivieren
- **Prüfen**: Welche Dienste werden wirklich benötigt?

## 🟢 Nice-to-have (Optional)

### 8. External-DNS Integration

**Zweck:**
- Automatische DNS-Updates bei IP-Änderungen
- Integration mit Cloudflare API

**Status:**
- Optional, nicht kritisch
- Cert-Manager funktioniert bereits für DNS-Challenges

### 9. Monitoring-Integration

**Status:**
- Prometheus/Grafana bereits vorhanden
- Integration mit NetBox (falls deployed)

**Zweck:**
- Automatische IP-Discovery
- Monitoring-Alerts
- Infrastruktur-Dokumentation

### 10. Automatisierung für DNS-Updates

**Zweck:**
- Automatische DNS-Record-Updates bei IP-Änderungen
- Integration mit Cloudflare API

**Status:**
- Optional, nicht kritisch
- Manuelle Updates funktionieren aktuell

## 📋 Prioritätenliste

### Priorität 1 (Kritisch - sofort)

1. **GitLab Stabilität prüfen und beheben**
   - 463 Restarts in 40h ist kritisch
   - Ursache identifizieren (Logs, Ressourcen, PVCs)
   - Beheben bevor Docker-Container gestoppt wird

2. **Kubernetes Ingress-Verfügbarkeit verifizieren**
   - Prüfen ob Services jetzt über ingress-nginx erreichbar sind
   - HTTP/HTTPS-Tests durchführen
   - Bei Problemen: Logs prüfen

3. **Doppelte Docker-Container stoppen**
   - GitLab, Jenkins, Jellyfin
   - Nur nach Verifizierung, dass Kubernetes-Versionen funktionieren

### Priorität 2 (Wichtig - bald)

4. **Monitoring-Container Migration**
   - libvirt-exporter, cAdvisor
   - Prüfen ob noch benötigt

5. **DNS-Rebind-Schutz in Fritzbox aktivieren**
   - Sicherheitsverbesserung

6. **Fritzbox-Dienste optimieren**
   - UPnP, TR-064 prüfen

### Priorität 3 (Nice-to-have - später)

7. **NetBox CMDB Deployment**
   - Für strukturierte Dokumentation
   - API für Automatisierung

8. **External-DNS Integration**
   - Automatische DNS-Updates

9. **Monitoring-Integration**
   - NetBox + Prometheus/Grafana

## 🔍 Was mir unterwegs begegnet ist

### 1. GitLab Instabilität

**Beobachtung:**
- Kubernetes GitLab: 463 Restarts in 40h
- Docker GitLab: Läuft stabil (Up 2 weeks)

**Vermutung:**
- Ressourcenknappheit (CPU/RAM-Limits zu niedrig)
- PVC-Probleme (Mount-Probleme?)
- Health-Check konfiguriert zu aggressiv

**Empfehlung:**
- Logs analysieren
- Ressourcen-Limits prüfen
- PVC-Status prüfen

### 2. Port-Konflikt-Lösung

**Beobachtung:**
- Docker nginx-reverse-proxy blockierte Port 80/443
- Kubernetes ingress-nginx konnte nicht auf LoadBalancer IP funktionieren
- Lösung: Docker-Container gestoppt

**Status:**
- ✅ Behoben (nginx-reverse-proxy gestoppt)
- ⚠️ Sollte verifiziert werden, dass ingress-nginx jetzt funktioniert

### 3. DNS-Stack Optimierung

**Beobachtung:**
- Komplexer DNS-Flow mit mehreren Hops
- Pi-hole Docker → Fritzbox → Clients war nicht optimal

**Status:**
- ✅ Optimiert: Clients → Fritzbox → Pi-hole Kubernetes → Cloudflare
- ✅ CoreDNS → Pi-hole Kubernetes
- ✅ Sauberer, einfacher Flow

### 4. DHCP-Bereich Konflikt

**Beobachtung:**
- DHCP-Bereich (20-200) umfasste Kubernetes LoadBalancer IP (54)
- Potenzieller Konflikt mit MetallB

**Status:**
- ✅ Behoben (DHCP-Bereich angepasst: 20-50, 60-200)

### 5. DNSSEC Überlegungen

**Beobachtung:**
- DNSSEC würde zusätzliche Sicherheit bieten
- Aber: United Domains erfordert kostenpflichtigen Domain-Tresor (7,50-15€/Jahr)
- Für privates Setup nicht kritisch

**Status:**
- ✅ Bewusst nicht aktiviert (nicht kritisch)
- ✅ Setup in Cloudflare widerrufen (sauberer Zustand)

## 📝 Nächste konkrete Schritte

### Sofort (heute):

1. **GitLab Stabilität analysieren:**
   ```bash
   kubectl logs -n gitlab gitlab-6bd6446c6f-fbltz --tail=200
   kubectl describe pod -n gitlab gitlab-6bd6446c6f-fbltz
   kubectl top pod -n gitlab
   ```

2. **Kubernetes Ingress testen:**
   ```bash
   curl -I http://192.168.178.54
   curl -I http://gitlab.k8sops.online
   curl -I http://jenkins.k8sops.online
   ```

3. **Docker-Container Status prüfen:**
   ```bash
   sudo systemctl start docker  # Falls gestoppt
   docker ps -a
   ```

### Diese Woche:

4. **Doppelte Docker-Container stoppen** (nach GitLab-Fix)
5. **DNS-Rebind-Schutz aktivieren**
6. **Fritzbox-Dienste optimieren**

### Diese Woche/Monat:

7. **Monitoring-Container Migration** (optional)
8. **NetBox CMDB Deployment** (optional)

## ⚠️ Wichtige Hinweise

### Vor dem Stoppen der Docker-Container:

1. **GitLab Kubernetes stabilisieren**
   - 463 Restarts ist kritisch
   - Ursache muss behoben werden

2. **Alle Kubernetes Services testen**
   - Verifizieren, dass alle Services funktionieren
   - HTTP/HTTPS-Tests durchführen

3. **Backups vorhanden**
   - ✅ GitLab: 3.7G Daten-Backup
   - ✅ Jenkins: 330M Home-Backup
   - ✅ Jellyfin: Config-Backup

### Rollback-Plan:

- Docker-Container können jederzeit wieder gestartet werden
- Backups vorhanden
- Kubernetes-Versionen laufen parallel

## 🎯 Zusammenfassung

**Kritisch:**
- GitLab Stabilität (463 Restarts)
- Kubernetes Ingress-Verfügbarkeit verifizieren
- Doppelte Docker-Container stoppen

**Wichtig:**
- Monitoring-Container Migration
- DNS-Rebind-Schutz
- Fritzbox-Dienste optimieren

**Optional:**
- NetBox CMDB
- External-DNS
- Automatisierung

**Status:**
- ✅ DNS-Stack optimiert
- ✅ Port-Konflikte behoben
- ✅ Sicherheit verbessert (WHOIS Privacy, Domain-Lock, 2FA)
- ⚠️ GitLab Stabilität muss noch behoben werden

