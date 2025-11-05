# GitLab Analyse

## Installation-Status

### Kubernetes Deployment

**Namespace**: `gitlab`

**Pods**:
- `gitlab-75b764b497-bglmk`: Running (1/1 Ready - STABIL nach Probe-Korrektur)
- `gitlab-postgresql-0`: Running (PostgreSQL Database)
- `gitlab-redis-master-0`: Running (Redis Cache)

**Services**:
- `gitlab`: ClusterIP (10.105.61.1) - Ports: 80/TCP, 22/TCP
- `gitlab-postgresql`: ClusterIP (10.109.229.6) - Port: 5432/TCP
- `gitlab-redis-master`: ClusterIP (10.105.85.108) - Port: 6379/TCP

**Ingress**:
- Host: `gitlab.k8sops.online`
- Ports: 80, 443

### Konfiguration

**External URL**: `http://gitlab.k8sops.online` (aus ConfigMap)

**GitLab-Konfiguration** (aus ConfigMap):
- External URL: `http://gitlab.k8sops.online`
- Let's Encrypt: Deaktiviert (Cert-Manager übernimmt)
- Nginx: Port 80, HTTP only (HTTPS via Ingress)
- PostgreSQL: Extern (gitlab-postgresql.gitlab.svc.cluster.local)
- Redis: Extern (gitlab-redis-master.gitlab.svc.cluster.local)
- Gitaly: Aktiviert
- Puma: 2 Worker Processes
- Sidekiq: Max 5 Concurrency
- Monitoring: Deaktiviert
- Pages: Deaktiviert
- Container Registry: Deaktiviert
- Mattermost: Deaktiviert

### Zugriff

**Webinterface**: https://gitlab.k8sops.online
- Status: Erreichbar
- Login-Seite: Anzeige funktioniert
- GitLab Community Edition

**API-Endpunkt**: https://gitlab.k8sops.online/api/v4

### Bestehende Struktur

**Bisherige Analyse**:
- Keine Gruppen/Projekte sichtbar ohne Login
- Explore-Seite zeigt öffentliche Projekte (falls vorhanden)
- Registrierung möglich

## API-Zugriff

### Personal Access Token erforderlich

**Benötigte Berechtigungen**:
- `api` - Vollständiger API-Zugriff
- `read_repository` - Repository lesen
- `write_repository` - Repository schreiben
- `write_registry` - Container Registry (optional)

**Token-Erstellung**:
1. GitLab Webinterface: Preferences → Access Tokens
2. Oder: Settings → Access Tokens (falls verfügbar)

## Nächste Schritte

1. ~~**GitLab-Zugangsdaten beschaffen**~~ → ✅ Root-User existiert
2. ~~**API-Token erstellen**~~ → ✅ Token erstellt: `glpat-q9cRQjBeN--9eKsPzjZn5G86MQp1OjEH.01.0w11ag1un`
3. ~~**Group "neue-zeit" erstellen**~~ → ✅ Erstellt (ID: 3, Path: `neue-zeit`)
4. **Repository erstellen** → In Arbeit
5. **Sync konfigurieren** zwischen GitHub und GitLab

## Bekannte Probleme

- ~~**GitLab Pod**: 468 Restarts - sehr instabil~~ → **BEHOBEN**: Liveness Probe korrigiert
- **Fix**: Liveness Probe auf `/-/health` mit 300s initialDelay, Readiness Probe mit 120s initialDelay
- **Status**: Pod läuft jetzt stabil (1/1 Ready, 0 Restarts)

## Empfehlungen

1. GitLab-Pod-Stabilität prüfen (Logs, Ressourcen)
2. Zugangsdaten für Webinterface beschaffen
3. API-Token für Automatisierung erstellen
4. Group und Repository setup durchführen

