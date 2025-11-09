# ArgoCD Passwort zurückgesetzt - 2025-11-09

## Durchgeführte Änderungen

### Passwort geändert
- **Benutzername**: `admin`
- **Altes Passwort**: `Admin123!`
- **Neues Passwort**: `Montag69`
- **Datum**: 2025-11-09

### Durchgeführte Schritte

1. **Secret aktualisiert**:
   ```bash
   kubectl patch secret argocd-secret -n argocd --type='json' \
     -p="[{\"op\": \"replace\", \"path\": \"/data/admin.password\", \"value\": \"$(echo -n 'Montag69' | base64)\"}]"
   ```

2. **ArgoCD Server neu gestartet**:
   ```bash
   kubectl rollout restart deployment argocd-server -n argocd
   ```

3. **Passwort verifiziert**:
   ```bash
   kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d
   # Ergebnis: Montag69
   ```

## Dokumentation aktualisiert

Die Datei `webinterfaces-zugangsdaten-2025-11-08.md` wurde aktualisiert mit:
- **Passwort**: `Montag69` (zurückgesetzt am 2025-11-09)
- **Status**: ✅ Funktioniert (Redirect-Loop behoben, Passwort zurückgesetzt)

## Zugriff

- **URL**: https://argocd.k8sops.online
- **Benutzername**: `admin`
- **Passwort**: `Montag69`

## Passwort aus Secret extrahieren

```bash
kubectl get secret argocd-secret -n argocd -o jsonpath='{.data.admin\.password}' | base64 -d
```

---

**Ende des Reports**

