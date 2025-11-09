# ArgoCD Redirect-Loop Problem behoben - 2025-11-09

## Problem
ArgoCD Web-Interface zeigte einen Redirect-Loop (307 → sich selbst).

## Ursache
ArgoCD dachte, dass es direkt TLS verwendet (`tls: true`), obwohl es hinter einem nginx Ingress-Controller mit TLS-Terminierung läuft. Dies führte dazu, dass ArgoCD versuchte, auf HTTPS zu redirecten, was einen Loop verursachte.

## Lösung

### 1. ConfigMap `server.insecure` auf `true` gesetzt
```bash
kubectl patch configmap argocd-cm -n argocd --type merge -p='{"data":{"server.insecure":"true"}}'
```

### 2. Umgebungsvariable `ARGOCD_SERVER_INSECURE=true` hinzugefügt
```bash
kubectl patch deployment argocd-server -n argocd --type json \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name": "ARGOCD_SERVER_INSECURE", "value": "true"}}]'
```

### 3. ArgoCD Server neu gestartet
```bash
kubectl rollout restart deployment argocd-server -n argocd
```

## Ergebnis

✅ **ArgoCD Web-Interface funktioniert jetzt korrekt!**
- URL: https://argocd.k8sops.online
- Status: ✅ Erreichbar (kein Redirect-Loop mehr)
- Browser-Test: ✅ Erfolgreich

## Konfiguration

**ConfigMap `argocd-cm`:**
- `server.insecure: "true"` ✅
- `url: https://argocd.k8sops.online` ✅
- `server.rootpath: /` ✅

**Deployment `argocd-server`:**
- Umgebungsvariable: `ARGOCD_SERVER_INSECURE=true` ✅

**Ingress `argocd-ingress`:**
- `backend-protocol: HTTP` ✅
- `ssl-redirect: "true"` ✅
- `force-ssl-redirect: "false"` ✅

## Warum funktioniert es jetzt?

ArgoCD läuft hinter einem nginx Ingress-Controller, der TLS terminiert. Wenn ArgoCD denkt, dass es direkt TLS verwendet, versucht es, auf HTTPS zu redirecten, was einen Loop verursacht. Durch das Setzen von `server.insecure=true` und `ARGOCD_SERVER_INSECURE=true` weiß ArgoCD, dass es hinter einem Proxy läuft und keine eigenen TLS-Redirects durchführen muss.

---

**Ende des Reports**

