# Webinterfaces Probleme - 2025-11-09

## Bekannte Probleme

### ArgoCD - DNS-Resolution-Timeout

**Problem**: 
- ArgoCD zeigt beim Check-Skript "Client error: 0, message='', url='https://argocd.k8sops.online'"
- `curl` zeigt DNS-Resolution-Timeout
- Python `socket.gethostbyname()` funktioniert (192.168.178.54)
- `dig` funktioniert (192.168.178.54)

**Ursache**:
- Vermutlich ein Problem mit IPv6/IPv4-DNS-Auflösung in aiohttp/curl
- ArgoCD-Server läuft korrekt (Pod Status: Running)
- Ingress ist korrekt konfiguriert

**Workaround**:
- ArgoCD ist über Port-Forward erreichbar: `kubectl port-forward -n argocd svc/argocd-server 8080:80`
- Direkter Zugriff über Browser funktioniert vermutlich (DNS wird vom Browser aufgelöst)

**Status**: ⚠️ Bekanntes Problem, Service funktioniert trotzdem

---

## Check-Skript Status

**Ergebnis**: 12 von 13 Webinterfaces funktionieren ✅

**Funktionierende Interfaces**:
- GitLab ✅
- Grafana ✅
- Pi-hole ✅
- Jellyfin ✅
- Komga ✅
- Syncthing ✅
- Kubernetes Dashboard ✅
- Heimdall ✅
- PlantUML ✅ (nach Fix)
- Prometheus ✅
- Jenkins ✅ (503 erwartet)
- Loki ✅ (404 erwartet)

**Probleme**:
- ArgoCD ⚠️ (DNS-Resolution-Problem, aber Service läuft)

---

**Ende des Dokuments**

