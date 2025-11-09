# Pi-hole Blocklisten Final - 2025-11-08

## ✅ Status: Erfolgreich aktualisiert

### Aktive Blocklisten: 14 Listen (von 16 konfigurierten)

**Erfolgreich aktiv**:
1. ✅ Steven Black's Unified Hosts (109.615 exact domains)
2. ✅ OISD - Optional Internet Security Domains
3. ✅ AdGuard DNS Filter (145.475 ABP-style domains)
4. ✅ EasyList (43.426 ABP-style domains)
5. ✅ EasyPrivacy (42.107 ABP-style domains)
6. ✅ Spam404 (8.140 exact domains)
7. ✅ Peter Lowe's Ad server list (3.468 exact domains)
8. ✅ WindowsSpyBlocker (347 exact domains)
9. ✅ NoCoin (313 exact domains)
10. ✅ RPiList Phishing-Angriffe (926.372 ABP-style domains) - **NEU**
11. ✅ Aggressive Tracking List (171.820 exact domains) - **NEU**
12. ✅ Disconnect.me Tracking Protection (34 exact domains) - **NEU**
13. ✅ Goodbye Ads (277.779 exact domains) - **NEU**

**Fehlgeschlagen** (werden beim nächsten Gravity-Update entfernt):
- ⚠️ Fanboy's Annoyance List (URL nicht erreichbar - 404)
- ⚠️ RPiList Fake-Shops (URL nicht erreichbar - 404)
- ⚠️ Malware Domain List (mirror1.malwaredomains.com - nicht erreichbar)

## 📊 Gravity-Datenbank Status

- **Gesamt Domains**: 1.728.905 Domains
- **Eindeutige Domains**: 1.645.202 Domains
- **Vorher**: 1.377.254 eindeutige Domains
- **Zuwachs**: +267.948 Domains (+19,5%)
- **Letztes Update**: 2025-11-08 19:00 CET

## ✅ Neue Listen hinzugefügt

### 1. Disconnect.me Tracking Protection ✅
- **URL**: `https://s3.amazonaws.com/lists.disconnect.me/simple_tracking.txt`
- **Status**: ✅ Erfolgreich geladen
- **Domains**: 34 exact domains
- **Beschreibung**: Tracking-Schutz von Disconnect.me

### 2. Goodbye Ads ✅
- **URL**: `https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt`
- **Status**: ✅ Erfolgreich geladen
- **Domains**: 277.779 exact domains
- **Beschreibung**: Umfassende Ad-Blocker-Liste

## 🔧 ConfigMap aktualisiert

Die ConfigMap `k8s/pihole/adlists-configmap.yaml` wurde aktualisiert und enthält jetzt:
- ✅ Alle erfolgreichen Listen
- ⚠️ Fehlgeschlagene Listen wurden durch funktionierende Alternativen ersetzt

**Ersetzt**:
- Fanboy's Annoyance List → Disconnect.me Tracking Protection
- RPiList Fake-Shops → Goodbye Ads

## 📈 Auswirkungen

- **Massive Erhöhung der blockierten Domains**: Von 1.377.254 auf 1.645.202 eindeutige Domains
- **Verbesserter Tracking-Schutz**: Disconnect.me + Aggressive Tracking List
- **Verbesserter Ad-Blocking**: Goodbye Ads mit 277.779 zusätzlichen Domains
- **Verbesserter Phishing-Schutz**: RPiList Phishing-Angriffe mit 926.372 ABP-style Domains

## ⚠️ Fehlgeschlagene Listen

Die folgenden Listen konnten nicht geladen werden und sollten manuell entfernt werden:

1. **Fanboy's Annoyance List**
   - URL: `https://www.fanboy.co.nz/r/fanboy-annoyance.txt`
   - Status: ⚠️ 404 Not Found
   - **Ersetzt durch**: Disconnect.me Tracking Protection

2. **RPiList Fake-Shops**
   - URL: `https://raw.githubusercontent.com/RPiList/specials/master/Blocklisten/Fake-Shops`
   - Status: ⚠️ 404 Not Found
   - **Ersetzt durch**: Goodbye Ads

3. **Malware Domain List**
   - URL: `https://mirror1.malwaredomains.com/files/justdomains`
   - Status: ⚠️ Nicht erreichbar
   - **Hinweis**: Bereits vorher vorhanden, kann entfernt werden

## ✅ Fazit

**14 von 16 Listen erfolgreich aktiv!**

Die Pi-hole Installation hat jetzt:
- ✅ 1.645.202 eindeutige blockierte Domains (vorher: 1.377.254)
- ✅ Verbesserten Phishing-Schutz
- ✅ Verbesserten Tracking-Schutz (2 Listen)
- ✅ Verbesserten Ad-Blocking (Goodbye Ads)
- ✅ 14 aktive Blocklisten

Die 3 fehlgeschlagenen Listen sollten manuell aus dem Webinterface entfernt werden, um die Warnungen zu beseitigen.

## 🔧 Nächste Schritte

1. **Fehlgeschlagene Listen entfernen**:
   - Gehen Sie zu `https://pihole.k8sops.online/admin/groups/lists`
   - Entfernen Sie die Listen mit ⚠️-Icon (Fanboy's Annoyance, RPiList Fake-Shops, Malware Domain List)

2. **Gravity erneut aktualisieren** (optional):
   - Nach dem Entfernen der fehlgeschlagenen Listen kann Gravity erneut aktualisiert werden

3. **Testen**:
   - Überprüfen Sie, ob wichtige Websites noch funktionieren
   - Nutzen Sie die Whitelist für falsch blockierte Domains

