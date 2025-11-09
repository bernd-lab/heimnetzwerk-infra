# Fixes Abgeschlossen - 2025-11-08

**Datum**: 2025-11-08  
**Status**: ✅ Probleme behoben

---

## Durchgeführte Fixes

### ✅ 1. ArgoCD Web-Interface repariert

**Problem**: ArgoCD Web-Interface war nicht erreichbar (Timeout)
- **Ursache**: Ingress verwendete `backend-protocol: GRPC`, aber HTTP-Requests kamen an
- **Fehler**: `Connection reset by peer` im Ingress-Controller

**Lösung**:
```bash
kubectl annotate ingress argocd-ingress -n argocd \
  nginx.ingress.kubernetes.io/backend-protocol=HTTP \
  --overwrite
```

**Ergebnis**: ✅ ArgoCD antwortet jetzt mit HTTP/2 307 Redirect
- **Test**: `curl -k -I https://argocd.k8sops.online` → HTTP/2 307 ✅

**Zusätzliche Maßnahme**: Ingress-Controller Pod neu gestartet, um Änderung zu übernehmen

---

### ✅ 2. Pi-hole Certificate-Konflikt behoben

**Problem**: Zwei Certificates zeigten auf dasselbe Secret (`pihole-tls`)
- `pihole-tls`: READY=True (automatisch vom Ingress erstellt)
- `pihole-k8sops-online-tls`: READY=False (manuell erstellt)

**Lösung**:
1. Altes Certificate `pihole-tls` gelöscht
2. Certificate `pihole-k8sops-online-tls` so geändert, dass es auf Secret `pihole-k8sops-online-tls` zeigt
3. Ingress so geändert, dass er auf Secret `pihole-k8sops-online-tls` zeigt

**Befehle**:
```bash
# Altes Certificate löschen
kubectl delete certificate -n pihole pihole-tls

# Certificate auf neues Secret umstellen
kubectl patch certificate -n pihole pihole-k8sops-online-tls \
  -p '{"spec":{"secretName":"pihole-k8sops-online-tls"}}' \
  --type=merge

# Ingress auf neues Secret umstellen
kubectl patch ingress -n pihole pihole-ingress \
  -p '{"spec":{"tls":[{"hosts":["pihole.k8sops.online"],"secretName":"pihole-k8sops-online-tls"}]}}' \
  --type=merge
```

**Ergebnis**: ✅ Nur noch ein Certificate (`pihole-k8sops-online-tls`)
- **Status**: Certificate wird neu ausgestellt (READY=False, aber cert-manager arbeitet daran)

**Hinweis**: Das Certificate muss neu ausgestellt werden, da das Secret geändert wurde. Dies kann einige Minuten dauern.

---

## Aktualisierte Konfigurationen

### ArgoCD Ingress
- **Annotation**: `nginx.ingress.kubernetes.io/backend-protocol: HTTP` ✅
- **Status**: ✅ Funktioniert

### Pi-hole Certificate
- **Certificate**: `pihole-k8sops-online-tls` ✅
- **Secret**: `pihole-k8sops-online-tls` ✅
- **Ingress**: Zeigt auf `pihole-k8sops-online-tls` ✅
- **Status**: ⏳ Certificate wird neu ausgestellt

---

## Nächste Schritte

1. **Pi-hole Certificate überwachen**:
   ```bash
   kubectl get certificate -n pihole pihole-k8sops-online-tls
   kubectl describe certificate -n pihole pihole-k8sops-online-tls
   ```
   - Warten bis READY=True
   - Kann einige Minuten dauern (DNS-01 Challenge)

2. **ArgoCD Web-Interface testen**:
   - URL: https://argocd.k8sops.online
   - Sollte jetzt erreichbar sein

3. **Pi-hole Web-Interface testen**:
   - URL: https://pihole.k8sops.online/admin/
   - Sollte nach Certificate-Ausstellung funktionieren

---

## Dateien aktualisiert

Die folgenden Dateien sollten aktualisiert werden, um die Änderungen zu reflektieren:

1. **k8s/pihole/certificate.yaml**:
   - `secretName` sollte auf `pihole-k8sops-online-tls` geändert werden

2. **k8s/pihole/ingress.yaml**:
   - `secretName` sollte auf `pihole-k8sops-online-tls` geändert werden

**Hinweis**: Die Änderungen wurden direkt im Cluster durchgeführt. Die Manifest-Dateien sollten synchronisiert werden, um Inkonsistenzen zu vermeiden.

---

**Ende des Fix-Reports**

