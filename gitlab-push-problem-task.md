# Task: GitLab Push-Problem beheben

**Erstellt**: 2025-11-06 15:25  
**Status**: 🔴 **KRITISCH - BLOCKIERT**  
**Priorität**: Hoch

## Problem

Git-Push zu GitLab schlägt fehl oder hängt:
- `git push gitlab main` hängt oder wird abgebrochen
- GitHub-Push funktioniert: ✅ `53da221..89aecf0  main -> main`
- GitLab-Remote konfiguriert: `https://gitlab.k8sops.online/bernd-lab/heimnetzwerk-infra.git`

**KRITISCH**: GitLab ist nicht erreichbar über Standard-Ports!
- `curl https://gitlab.k8sops.online` → Timeout nach 2+ Minuten
- `curl http://gitlab.k8sops.online` → Timeout
- **ABER**: NodePort funktioniert! ✅ `curl http://192.168.178.54:30827` → 308 Redirect

## Diagnose-Ergebnisse

### ✅ Funktioniert
- GitLab-Pods: Running (1/1 Ready)
- GitLab-Service: ClusterIP 10.105.61.1, Endpoints 10.244.0.141:80
- GitLab-Pod Health: ✅ "GitLab OK"
- Zertifikat: ✅ `gitlab-tls` (Ready, True)
- DNS: ✅ `gitlab.k8sops.online` → 192.168.178.54
- Ingress: ✅ Konfiguriert mit nginx, Backend: gitlab:80
- MetalLB: ✅ IP zugewiesen (192.168.178.54 VIP)
- IP auf Interface: ✅ `br0` (192.168.178.54/24)
- **NodePort funktioniert**: ✅ Port 30827 (HTTP) und 30941 (HTTPS) erreichbar
- **Ingress-Controller**: ✅ Health-Check OK, Pod läuft

### ❌ Problem
- **Ports 80/443 nicht direkt erreichbar**: Traffic zu 192.168.178.54:80/443 wird nicht zu NodePort weitergeleitet
- **MetalLB L2-Mode**: Bindet nicht direkt Ports, nutzt ARP/NDP
- **iptables-Routing**: Vermutlich fehlt NAT-Regel für Port 80/443 → NodePort

## Root Cause

**MetalLB L2-Mode + iptables-Routing-Problem**:
- MetalLB hat IP 192.168.178.54 zugewiesen (VIP)
- Ingress-Controller läuft auf NodePort 30827/30941
- **Aber**: iptables leitet Traffic von Port 80/443 nicht zu NodePort weiter
- **Lösung**: iptables-NAT-Regel hinzufügen ODER Ingress-Controller auf hostNetwork umstellen

## Aufgaben

### 1. K8s-Expert: iptables-Routing prüfen und beheben (KRITISCH)
- [x] NodePort funktioniert: ✅ Port 30827/30941
- [x] iptables-NAT-Regeln hinzugefügt: ✅ Port 80→30827, 443→30941
- [ ] **Problem**: iptables-Regeln greifen nicht (Traffic kommt nicht an)
- [ ] **Lösung 1**: Ingress-Controller auf `hostNetwork: true` umstellen (empfohlen)
- [ ] **Lösung 2**: iptables-Regeln-Reihenfolge prüfen, OUTPUT-Chain prüfen
- [ ] **Lösung 3**: MetalLB auf BGP-Mode umstellen (komplexer)
- [ ] GitLab-Erreichbarkeit testen: `curl http://gitlab.k8sops.online`

### 2. Network-Expert: MetalLB-Konfiguration prüfen
- [x] MetalLB läuft: ✅ Controller und Speaker
- [x] IPAddressPool konfiguriert: ✅ 192.168.178.54/32
- [x] L2Advertisement konfiguriert: ✅
- [ ] ARP-Announcement prüfen: `ip neigh show | grep 192.168.178.54`
- [ ] MetalLB-Logs prüfen: Externe Requests sichtbar?

### 3. GitLab-Expert: Repository-Status prüfen
- [ ] Prüfen, ob Repository `bernd-lab/heimnetzwerk-infra` existiert
- [ ] Prüfen, ob Repository `neue-zeit/heimnetzwerk-infra` existiert
- [ ] Repository über API erstellen, falls nicht vorhanden
- [ ] Korrekten Repository-Pfad identifizieren

### 4. GitLab-Expert: Authentifizierung konfigurieren
- [ ] GitLab Personal Access Token für Git-Operations prüfen/erstellen
- [ ] Token-Scopes prüfen: `write_repository`, `api`
- [ ] Remote-URL mit Token konfigurieren: `https://oauth2:TOKEN@gitlab.k8sops.online/...`
- [ ] Oder SSH-Key für GitLab konfigurieren

### 5. Secrets-Expert: Token-Management
- [ ] GitLab Token verschlüsselt speichern (falls neu erstellt)
- [ ] Token in Secrets-Management dokumentieren
- [ ] Token-Berechtigungen dokumentieren

### 6. GitLab-Expert: Push testen
- [ ] Remote-URL mit Token testen
- [ ] Push durchführen: `git push gitlab main`
- [ ] Erfolg verifizieren
- [ ] Automatischen Sync konfigurieren (falls gewünscht)

## Erwartetes Ergebnis

✅ GitLab erreichbar:
```bash
curl https://gitlab.k8sops.online
# <HTML> GitLab Login Page
```

✅ Git-Push zu GitLab funktioniert:
```bash
git push gitlab main
# To https://gitlab.k8sops.online/...
#   53da221..89aecf0  main -> main
```

## Relevante Agenten

1. **k8s-expert** - iptables-Routing, Ingress-Controller-Konfiguration, hostNetwork
2. **network-expert** - MetalLB, ARP/NDP, Netzwerk-Routing
3. **gitlab-github-expert** - Repository-Management, Authentifizierung
4. **secrets-expert** - Token-Management, Verschlüsselung

## Dokumentation

- `gitlab-erreichbarkeit-analyse.md` - Detaillierte Analyse
- `docker-kubernetes-migration.md` - Port-Konflikte und MetalLB
- `gitlab-setup-summary.md` - GitLab Setup-Status
- `gitlab-analyse.md` - GitLab-Konfiguration
- `.cursor/commands/gitlab-github-expert.md` - Agent-Definition

## Nächste Schritte

1. ✅ Task erstellt
2. ✅ Diagnose durchgeführt (NodePort funktioniert, Port 80/443 nicht)
3. ⏳ K8s-Expert aktivieren: iptables-Routing beheben
4. ⏳ Network-Expert aktivieren: MetalLB-Konfiguration prüfen
5. ⏳ GitLab-Expert: Repository-Status und Authentifizierung
6. ⏳ GitLab-Expert: Push-Problem beheben
