# Alertmanager Discord Webhook Secret Setup

## Sicherheitshinweis

⚠️ **WICHTIG**: Die Discord Webhook URL ist ein sensibles Credential und darf **NICHT** im Git-Repository gespeichert werden!

Die Webhook URL ermöglicht es, Nachrichten an den Discord-Kanal zu senden. Jeder mit Zugriff auf die URL kann Nachrichten im Namen des Alertmanagers senden.

## ⚠️ KRITISCH: secret.yaml.template darf NICHT angewendet werden!

Die Datei `secret.yaml.template` ist **NUR** als Dokumentation gedacht und enthält einen Platzhalter-Wert.
**Wenn Sie diese Datei mit `kubectl apply` ausführen, wird der Platzhalter als echter Secret-Wert gesetzt,**
**was zu fehlgeschlagenen Webhooks führt!**

Die `secret.yaml.template` ist **AUSDRÜCKLICH** aus der Kustomization ausgeschlossen.
Das Secret **MUSS** manuell erstellt werden (siehe unten).

## Secret erstellen

Das Secret muss **manuell** erstellt werden, bevor Alertmanager deployed wird:

```bash
# Option 1: Direkt mit kubectl create
kubectl create secret generic alertmanager-discord-webhook \
  --from-literal=webhook_url='https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN' \
  -n monitoring

# Option 2: Mit temporärer Datei (für bessere Sicherheit)
echo -n 'https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN' > /tmp/webhook-url.txt
kubectl create secret generic alertmanager-discord-webhook \
  --from-file=webhook_url=/tmp/webhook-url.txt \
  -n monitoring
rm /tmp/webhook-url.txt

# Option 3: Mit base64-encoded Secret (für CI/CD)
WEBHOOK_URL='https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN'
kubectl create secret generic alertmanager-discord-webhook \
  --from-literal=webhook_url="${WEBHOOK_URL}" \
  -n monitoring \
  --dry-run=client -o yaml | kubectl apply -f -
```

## Secret prüfen

```bash
# Secret existiert?
kubectl get secret alertmanager-discord-webhook -n monitoring

# Secret-Inhalt prüfen (base64-encoded)
kubectl get secret alertmanager-discord-webhook -n monitoring -o jsonpath='{.data.webhook_url}' | base64 -d
```

## Secret aktualisieren

```bash
# Secret löschen und neu erstellen
kubectl delete secret alertmanager-discord-webhook -n monitoring
kubectl create secret generic alertmanager-discord-webhook \
  --from-literal=webhook_url='https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN' \
  -n monitoring

# Alertmanager Pod neu starten, damit die neue Config geladen wird
kubectl rollout restart deployment/alertmanager -n monitoring
```

## Wie es funktioniert

1. Das Secret `alertmanager-discord-webhook` wird als Volume in den Init-Container gemountet
2. Der Init-Container liest die Webhook-URL aus dem Secret
3. Der Init-Container ersetzt den Platzhalter `REPLACE_WITH_WEBHOOK_URL_FROM_SECRET` in der ConfigMap-Template-Datei durch die echte Webhook-URL
4. Die generierte Config-Datei wird in ein `emptyDir` Volume geschrieben
5. Alertmanager liest die Config-Datei aus dem `emptyDir` Volume

## Troubleshooting

### Secret fehlt
```bash
# Prüfen, ob Secret existiert
kubectl get secret alertmanager-discord-webhook -n monitoring

# Falls nicht vorhanden, erstellen (siehe oben)
```

### Alertmanager startet nicht
```bash
# Init-Container Logs prüfen
kubectl logs -n monitoring deployment/alertmanager -c config-generator

# Alertmanager Logs prüfen
kubectl logs -n monitoring deployment/alertmanager -c alertmanager
```

### Webhook funktioniert nicht
```bash
# Config-Datei im Pod prüfen
kubectl exec -n monitoring deployment/alertmanager -c alertmanager -- cat /etc/alertmanager/alertmanager.yml

# Prüfen, ob Platzhalter ersetzt wurde
kubectl exec -n monitoring deployment/alertmanager -c alertmanager -- grep -i discord /etc/alertmanager/alertmanager.yml
```

## Alternative: Sealed Secrets oder External Secrets Operator

Für produktive Umgebungen sollte ein Secret-Management-System verwendet werden:

- **Sealed Secrets**: Verschlüsselte Secrets im Git-Repository
- **External Secrets Operator**: Secrets aus externen Secret-Stores (Vault, AWS Secrets Manager, etc.)
- **CI/CD Secrets**: Secrets als CI/CD Environment Variables

Siehe auch: `secrets-management-konzept.md`

