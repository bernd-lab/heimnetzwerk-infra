# GitLab Push-Problem - Zusammenfassung

**Datum**: 2025-11-06 15:35  
**Status**: 🔴 **KRITISCH - GitLab nicht erreichbar über Standard-Ports**

## Problem

GitLab ist nicht über Standard-Ports (80/443) erreichbar:
- `curl https://gitlab.k8sops.online` → Timeout
- `git push gitlab main` → Hängt/fehlgeschlagen

## Diagnose-Ergebnisse

### ✅ Funktioniert
- GitLab-Pods: Running (1/1 Ready)
- GitLab-Pod Health: ✅ "GitLab OK" (direkter Pod-Zugriff)
- Zertifikat: ✅ `gitlab-tls` (Ready)
- DNS: ✅ `gitlab.k8sops.online` → 192.168.178.54
- Ingress: ✅ Konfiguriert
- **NodePort funktioniert**: ✅ `curl http://192.168.178.54:30827` → 308 Redirect

### ❌ Problem
- **Port 80/443 nicht erreichbar**: Traffic zu 192.168.178.54:80/443 wird nicht weitergeleitet
- **MetalLB L2-Mode**: Bindet nicht direkt Ports, nutzt ARP/NDP
- **iptables-Regeln**: Hinzugefügt, aber greifen nicht

## Root Cause

**MetalLB L2-Mode + iptables-Routing-Problem**:
- MetalLB hat IP 192.168.178.54 zugewiesen (VIP)
- Ingress-Controller läuft auf NodePort 30827/30941
- **Problem**: iptables leitet Traffic von Port 80/443 nicht zu NodePort weiter
- **Versuchte Lösung**: iptables-NAT-Regeln hinzugefügt, aber greifen nicht

## Empfohlene Lösung

### Option 1: Ingress-Controller auf hostNetwork umstellen (EMPFOHLEN)
- Ingress-Controller hört direkt auf Port 80/443
- Keine iptables-Routing-Probleme
- Einfachste Lösung

### Option 2: iptables-Routing korrigieren
- OUTPUT-Chain prüfen
- Regeln-Reihenfolge korrigieren
- Dauerhaft machen (iptables-save)

### Option 3: MetalLB auf BGP-Mode umstellen
- Komplexer, aber professioneller
- Benötigt BGP-Router

## Relevante Agenten

1. **k8s-expert** - Ingress-Controller-Konfiguration, hostNetwork
2. **network-expert** - iptables-Routing, MetalLB
3. **gitlab-github-expert** - Repository-Management, Authentifizierung

## Nächste Schritte

1. ⏳ K8s-Expert: Ingress-Controller auf hostNetwork umstellen
2. ⏳ GitLab-Expert: Repository-Status prüfen
3. ⏳ GitLab-Expert: Authentifizierung konfigurieren
4. ⏳ GitLab-Expert: Push testen

