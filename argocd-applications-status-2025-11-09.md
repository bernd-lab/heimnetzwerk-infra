# ArgoCD Applications Status - 2025-11-09

## Aktuelle Situation

**Registrierte ArgoCD Applications**: 3
1. `jellyfin` - Synced, Healthy
2. `kubernetes-dashboard` - Synced, Healthy  
3. `pihole` - OutOfSync, Healthy

## Fehlende ArgoCD Applications

Die folgenden Services laufen im Cluster, haben aber **keine** ArgoCD Applications:

### Services ohne ArgoCD Applications:
- **GitLab** (`gitlab` namespace)
- **Heimdall** (`heimdall` namespace)
- **Komga** (`komga` namespace)
- **Syncthing** (`syncthing` namespace)
- **PlantUML** (`default` namespace)
- **Jenkins** (`default` namespace, deaktiviert)

## Problem

ArgoCD kann nur Services verwalten, die als Kubernetes-Manifeste im Git-Repository vorhanden sind. Wenn die Manifeste für diese Services nicht im Repository sind, können keine ArgoCD Applications erstellt werden.

## Lösung

### Option 1: Manifeste ins Repository hinzufügen
1. Kubernetes-Manifeste für alle Services ins Repository committen
2. ArgoCD Applications für jeden Service erstellen
3. ArgoCD wird dann automatisch die Services aus dem Repository deployen

### Option 2: Bestehende Deployments importieren
1. Bestehende Deployments mit `kubectl get` exportieren
2. Manifeste ins Repository committen
3. ArgoCD Applications erstellen

## Nächste Schritte

1. Prüfen, welche Services bereits Manifeste im Repository haben
2. Fehlende Manifeste erstellen oder exportieren
3. ArgoCD Applications für alle Services erstellen
4. ArgoCD synchronisieren lassen

---

**Ende des Reports**

