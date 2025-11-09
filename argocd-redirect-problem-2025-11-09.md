# ArgoCD Redirect-Loop Problem - 2025-11-09

## Problem
ArgoCD Web-Interface zeigt einen Redirect-Loop (307 → sich selbst).

## Durchgeführte Maßnahmen

1. ✅ **ConfigMap `url` Feld entfernt/geleert**: Das `url` Feld wurde zunächst auf `""` gesetzt, dann komplett entfernt
2. ✅ **ConfigMap `url` auf korrekte URL gesetzt**: `url: https://argocd.k8sops.online`
3. ✅ **ArgoCD Server neu gestartet**: Deployment wurde mehrfach neu gestartet
4. ✅ **Ingress-Konfiguration geprüft**: Ingress zeigt korrekt auf `argocd-server:80` mit `backend-protocol: HTTP`

## Aktueller Status

- **Pod Status**: ✅ Running (`argocd-server-54bc4d86c8-npfp5`)
- **HTTP Status**: ⚠️ 307 Redirect (redirectet von `/` auf `/` - Loop)
- **Ingress**: ✅ Konfiguriert (`backend-protocol: HTTP`)
- **ConfigMap `url`**: ✅ Gesetzt auf `https://argocd.k8sops.online`

## Mögliche Ursachen

1. **ArgoCD erkennt die URL nicht korrekt über den Ingress**
2. **Problem mit `server.rootpath` Konfiguration** (aktuell: `/`)
3. **Ingress-Controller behandelt Redirects nicht korrekt**

## Nächste Schritte

1. Prüfe Ingress-Annotations für ArgoCD-spezifische Einstellungen
2. Teste direkten Zugriff auf den Pod (Port-Forward)
3. Prüfe ArgoCD Server-Logs auf Redirect-Gründe
4. Möglicherweise `server.rootpath` anpassen oder entfernen

## Test-Ergebnisse

```bash
# Externer Zugriff (über Ingress)
curl -k -I https://argocd.k8sops.online
# Ergebnis: HTTP/2 307 → location: https://argocd.k8sops.online/

# Port-Forward (direkt zum Pod)
kubectl port-forward -n argocd svc/argocd-server 8080:80
curl http://localhost:8080
# Ergebnis: <a href="https://localhost:8080/">Temporary Redirect</a>
```

## Fazit

Das Problem besteht weiterhin. ArgoCD redirectet von `/` auf `/`, was einen Loop verursacht. Die Konfiguration scheint korrekt zu sein, aber ArgoCD erkennt die URL möglicherweise nicht korrekt über den Ingress.

---

**Ende des Reports**

