# Qualitätskontrolle-Checkliste für Agenten

**Zweck**: Jeder Task soll nach Abschluss auf Wirksamkeit und Erfolg geprüft werden.

## Standard-Qualitätskontrolle nach jedem Task

### 1. Funktionalitätstest
- [ ] **Funktionalität verifiziert**: Die implementierte Funktion wurde getestet
- [ ] **Erwartetes Verhalten bestätigt**: Das System verhält sich wie erwartet
- [ ] **Fehlerbehandlung geprüft**: Fehlerfälle wurden getestet (falls relevant)
- [ ] **Edge Cases berücksichtigt**: Grenzfälle wurden geprüft (falls relevant)

### 2. Konfigurationstest
- [ ] **Konfiguration korrekt**: Alle Konfigurationsdateien sind korrekt
- [ ] **Dependencies geprüft**: Alle Abhängigkeiten sind erfüllt
- [ ] **Secrets/Passwords**: Keine Secrets versehentlich committet
- [ ] **Umgebungsvariablen**: Alle benötigten Umgebungsvariablen gesetzt

### 3. Integrationstest
- [ ] **Integration funktioniert**: Integration mit anderen Komponenten funktioniert
- [ ] **APIs erreichbar**: Externe/Interne APIs sind erreichbar
- [ ] **Datenfluss geprüft**: Daten fließen korrekt durch das System
- [ ] **Kompatibilität**: Kompatibilität mit bestehenden Systemen geprüft

### 4. Dokumentation
- [ ] **Dokumentation aktualisiert**: Relevante Dokumentation wurde aktualisiert
- [ ] **Agent-Kontext aktualisiert**: Agent-Kontext wurde mit neuen Erkenntnissen aktualisiert
- [ ] **Änderungen dokumentiert**: Alle Änderungen sind dokumentiert
- [ ] **Troubleshooting ergänzt**: Bekannte Probleme und Lösungen dokumentiert

### 5. Git-Commit (NUR NACH ERFOLGREICHER QUALITÄTSKONTROLLE!)
- [ ] **Qualitätskontrolle erfolgreich**: Alle Tests (1-4) erfolgreich durchgeführt
- [ ] **Git-Commit durchgeführt**: Änderungen wurden committed (NUR bei erfolgreichen Tests!)
- [ ] **Commit-Message aussagekräftig**: Commit-Message beschreibt die Änderung klar
- [ ] **Keine Secrets im Commit**: Keine Secrets versehentlich committet
- [ ] **Push erfolgreich**: Push zu Remote-Repository erfolgreich

**⚠️ WICHTIG**: Git-Commit NUR durchführen, wenn alle Qualitätskontrolle-Tests erfolgreich waren!

### 6. Rollback-Plan
- [ ] **Rollback-Plan vorhanden**: Es gibt einen Plan zum Zurückrollen (falls nötig)
- [ ] **Backup erstellt**: Wichtige Daten wurden gesichert (falls relevant)
- [ ] **Wiederherstellung getestet**: Rollback wurde getestet (falls kritisch)

## Spezifische Qualitätskontrollen

### DNS-Änderungen
- [ ] **DNS-Auflösung getestet**: DNS-Auflösung funktioniert korrekt
- [ ] **Lokale Domains getestet**: Lokale Domains (z.B. *.k8sops.online) funktionieren
- [ ] **Externe Domains getestet**: Externe Domains funktionieren
- [ ] **Pi-hole Logs geprüft**: Pi-hole Logs zeigen keine Fehler
- [ ] **CoreDNS Integration**: CoreDNS funktioniert mit Pi-hole

### Kubernetes-Änderungen
- [ ] **Pods laufen**: Alle Pods sind im Running-Status
- [ ] **Services erreichbar**: Services sind erreichbar
- [ ] **LoadBalancer IP zugewiesen**: LoadBalancer hat IP zugewiesen (falls relevant)
- [ ] **ConfigMaps/Secrets**: ConfigMaps und Secrets sind korrekt
- [ ] **PersistentVolumes**: PersistentVolumes sind gemountet (falls relevant)
- [ ] **Resource Limits**: Resource Limits sind angemessen

### Netzwerk-Änderungen
- [ ] **Konnektivität getestet**: Netzwerk-Konnektivität funktioniert
- [ ] **Routing geprüft**: Routing funktioniert korrekt
- [ ] **Firewall-Regeln**: Firewall-Regeln sind korrekt (falls relevant)
- [ ] **DNS-Konfiguration**: DNS-Konfiguration ist korrekt

### Fritzbox-Änderungen
- [ ] **DHCP-Konfiguration**: DHCP-Konfiguration ist korrekt
- [ ] **DNS-Weiterleitung**: DNS-Weiterleitung funktioniert
- [ ] **Port-Forwarding**: Port-Forwarding funktioniert (falls relevant)
- [ ] **UPnP/TR-064**: UPnP/TR-064 funktioniert (falls relevant)

## Nacharbeit bei Fehlern

### Wenn Tests fehlschlagen:
1. **Fehler analysieren**: Fehlerursache identifizieren
2. **Logs prüfen**: Relevante Logs analysieren
3. **Konfiguration prüfen**: Konfiguration auf Fehler prüfen
4. **Korrektur durchführen**: Fehler beheben
5. **Erneut testen**: Tests erneut durchführen
6. **Dokumentation aktualisieren**: Fehler und Lösung dokumentieren

### Wenn Integration fehlschlägt:
1. **Abhängigkeiten prüfen**: Alle Abhängigkeiten sind erfüllt
2. **Kompatibilität prüfen**: Kompatibilität mit anderen Komponenten prüfen
3. **API-Versionen prüfen**: API-Versionen sind kompatibel
4. **Netzwerk-Konnektivität**: Netzwerk-Konnektivität prüfen
5. **Korrektur durchführen**: Integration korrigieren
6. **Erneut testen**: Integration erneut testen

## Automatisierung

### Scripts für Qualitätskontrolle
- `scripts/test-dns.sh` - DNS-Funktionalitätstest
- `scripts/test-kubernetes.sh` - Kubernetes-Funktionalitätstest
- `scripts/test-network.sh` - Netzwerk-Funktionalitätstest
- `scripts/verify-config.sh` - Konfigurationsverifikation

### CI/CD Integration
- Qualitätskontrollen sollten in CI/CD-Pipeline integriert werden
- Automatische Tests nach jedem Commit
- Automatische Verifikation von Konfigurationen

## Best Practices

1. **Immer testen**: Jede Änderung sollte getestet werden
2. **Dokumentation**: Änderungen sollten dokumentiert werden
3. **Rollback-Plan**: Für kritische Änderungen sollte ein Rollback-Plan vorhanden sein
4. **Inkrementell**: Änderungen sollten inkrementell durchgeführt werden
5. **Verifikation**: Verifikation sollte nach jeder Änderung durchgeführt werden

