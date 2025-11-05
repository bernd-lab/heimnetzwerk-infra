# Passwörter und Secrets - Bedarfsanalyse

**Erstellt**: 2025-11-05 18:40
**Status**: Wird während der Arbeit aktualisiert

## Identifizierte Passwörter/Secrets

### Sofort benötigt

1. **GitLab Root-Passwort** ✅ **Bekannt**
   - **Wert**: `TempPass123!`
   - **Zweck**: GitLab Login-Test
   - **Aktion**: In Secret speichern
   - **Status**: Bekannt, muss noch verschlüsselt werden

2. **Fritzbox Admin-Passwort** ⚠️ **Erforderlich**
   - **Zweck**: Fritzbox-Konfiguration (DNS-Rebind-Schutz, UPnP, TR-064)
   - **Aktion**: Wird während Browser-Automatisierung benötigt
   - **Status**: Benötigt, wird während der Arbeit abgefragt

### Für Secrets-Management

3. **GitHub Personal Access Token** ⚠️ **Erforderlich**
   - **Zweck**: GitHub Secrets API, CI/CD
   - **Scopes**: `repo`, `workflow`, `admin:org`
   - **Aktion**: Muss in GitHub erstellt werden
   - **Status**: Benötigt für GitHub Secrets

4. **GitLab Personal Access Token** ⚠️ **Erforderlich**
   - **Zweck**: GitLab API, CI/CD
   - **Scopes**: `api`, `read_repository`, `write_repository`
   - **Aktion**: Muss in GitLab erstellt werden
   - **Status**: Benötigt für GitLab CI Variables

5. **Cloudflare API Token** ⚠️ **Erforderlich**
   - **Zweck**: DNS-Management, Cert-Manager
   - **Status**: Bereits vorhanden (in Kubernetes), muss lokal gespeichert werden

### Optional

6. **SSH Private Key für Debian-Server** ⚠️ **Optional**
   - **Zweck**: SSH-Zugriff zu 192.168.178.54
   - **Status**: Wird wahrscheinlich aus ~/.ssh/ kopiert

7. **Root-Passwörter für Server** ⚠️ **Optional**
   - **Zweck**: Server-Zugriff
   - **Status**: Nur wenn benötigt

## Aktionsplan

### Sofort (mit bekannten Werten)

1. ✅ GitLab Root-Passwort verschlüsseln: `TempPass123!`
2. ⏳ GitLab Login testen
3. ⏳ Docker Images aufräumen

### Während der Arbeit (wird abgefragt)

4. ⏳ Fritzbox-Passwort (wenn Fritzbox-Konfiguration gestartet wird)
5. ⏳ Weitere Passwörter (falls sie auftauchen)

### Später (manuell erstellen)

6. ⏳ GitHub Token erstellen (in GitHub)
7. ⏳ GitLab Token erstellen (in GitLab)
8. ⏳ Cloudflare Token extrahieren (aus Kubernetes)

## Fortschritt

- ✅ **GitLab Root-Passwort**: Bekannt (`TempPass123!`)
- ⏳ **Fritzbox-Passwort**: Wird während Browser-Automatisierung benötigt
- ⏳ **GitHub Token**: Muss in GitHub erstellt werden
- ⏳ **GitLab Token**: Muss in GitLab erstellt werden

