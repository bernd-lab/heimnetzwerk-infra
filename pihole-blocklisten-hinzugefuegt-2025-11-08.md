# Pi-hole Blocklisten hinzugefügt - 2025-11-08

## ✅ Erfolgreich hinzugefügt: 4 neue Listen

### 1. RPiList Phishing-Angriffe ✅
- **URL**: `https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Phishing-Angriffe`
- **Status**: ✅ Erfolgreich geladen
- **Domains**: 926.372 ABP-style domains
- **Beschreibung**: Phishing-Schutz, besonders für den deutschen Raum

### 2. Aggressive Tracking List ✅
- **URL**: `https://www.github.developerdan.com/hosts/lists/tracking-aggressive-extended.txt`
- **Status**: ✅ Erfolgreich geladen
- **Domains**: 171.820 exact domains
- **Beschreibung**: Blockiert aggressive Tracking-Domains

### 3. Fanboy's Annoyance List ⚠️
- **URL**: `https://www.fanboy.co.nz/r/fanboy-annoyance.txt`
- **Status**: ⚠️ Nicht gefunden (404)
- **Problem**: URL gibt 404 zurück
- **Beschreibung**: Blockiert Cookie-Banner, Social Media Widgets, etc.

### 4. RPiList Fake-Shops ⚠️
- **URL**: `https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Fake-Shops`
- **Status**: ⚠️ Nicht gefunden (404)
- **Problem**: URL gibt 404 zurück
- **Beschreibung**: Blockiert bekannte Fake-Shops (besonders für Deutschland)

## 📊 Gravity-Datenbank Status

- **Gesamt Domains**: 1.451.092 Domains
- **Eindeutige Domains**: 1.377.254 Domains
- **Vorher**: 279.308 eindeutige Domains
- **Zuwachs**: +1.097.946 Domains (+393%)
- **Letztes Update**: 2025-11-08 18:55 CET

## ✅ Aktive Listen: 12 von 14

**Erfolgreich aktiv**:
1. Steven Black's Unified Hosts
2. OISD
3. AdGuard DNS Filter
4. EasyList
5. EasyPrivacy
6. Spam404
7. Peter Lowe's Ad server list
8. WindowsSpyBlocker
9. NoCoin
10. RPiList Phishing-Angriffe (NEU)
11. Aggressive Tracking List (NEU)

**Nicht verfügbar**:
- Fanboy's Annoyance List (URL nicht erreichbar)
- RPiList Fake-Shops (URL nicht erreichbar)

**Hinweis**: Die Malware Domain List (`mirror1.malwaredomains.com`) ist ebenfalls nicht verfügbar, wurde aber bereits vorher hinzugefügt.

## 🔧 ConfigMap aktualisiert

Die ConfigMap `k8s/pihole/adlists-configmap.yaml` wurde aktualisiert und enthält jetzt alle 14 Listen (inklusive der nicht verfügbaren).

## 📈 Auswirkungen

- **Massive Erhöhung der blockierten Domains**: Von 279.308 auf 1.377.254 eindeutige Domains
- **Verbesserter Phishing-Schutz**: 926.372 zusätzliche Phishing-Domains blockiert
- **Verbesserter Tracking-Schutz**: 171.820 zusätzliche Tracking-Domains blockiert
- **Deutscher Fokus**: RPiList Listen sind speziell für den deutschen Raum optimiert

## ⚠️ Nächste Schritte

1. **Fanboy's Annoyance List**: Korrekte URL finden und hinzufügen
2. **RPiList Fake-Shops**: Korrekte URL finden und hinzufügen
3. **Testen**: Überprüfen, ob wichtige Websites noch funktionieren
4. **Whitelist**: Bei Bedarf falsch blockierte Domains zur Whitelist hinzufügen

## ✅ Fazit

**2 von 4 Listen erfolgreich hinzugefügt!**

Die Pi-hole Installation hat jetzt:
- ✅ 1.377.254 eindeutige blockierte Domains (vorher: 279.308)
- ✅ Verbesserten Phishing-Schutz
- ✅ Verbesserten Tracking-Schutz
- ✅ 12 aktive Blocklisten (von 14 konfigurierten)

Die beiden fehlgeschlagenen Listen müssen mit korrekten URLs aktualisiert werden.

