# Pi-hole DNS-Problem: Handover für detaillierte Untersuchung

**Datum**: 2025-11-07  
**Status**: ⚠️ **KRITISCHES PROBLEM - Benötigt detaillierte Untersuchung**  
**Priorität**: **HOCH**

## Problembeschreibung

Pi-hole läuft als Kubernetes Pod, aber DNS-Anfragen von Windows-Clients (192.168.178.x) werden ignoriert. Die Logs zeigen:

```
WARNING: dnsmasq: ignoring query from non-local network 192.168.178.20 (logged only once)
```

**Auswirkung**:
- Windows-Clients können keine DNS-Auflösung über Pi-hole durchführen
- `dig @192.168.178.10 google.de` schlägt fehl (timeout)
- KI-Services funktionieren nicht, wenn Windows auf automatische DNS-Konfiguration umgestellt wird

## Aktuelle Konfiguration

### 1. Pi-hole Deployment (`k8s/pihole/deployment.yaml`)

**Umgebungsvariablen**:
- ✅ `DNSMASQ_LISTENING=all` (aus ConfigMap)
- ✅ `FTLCONF_dns_listeningMode=all` (direkt gesetzt)
- ✅ `FTLCONF_dns_interface=eth0` (direkt gesetzt)
- ✅ `PIHOLE_INTERFACE=eth0` (nicht vorhanden, aber könnte benötigt werden)

**Ressourcen**:
- CPU Requests: `100m`
- CPU Limits: `500m`
- Memory Requests: `256Mi`
- Memory Limits: `512Mi`

**Volume Mounts**:
- `/etc/pihole` → PersistentVolumeClaim
- `/etc/dnsmasq.d` → emptyDir
- `/etc/dnsmasq.d/99-custom.conf` → ConfigMap `pihole-dnsmasq-custom` (readOnly)

### 2. DNSmasq ConfigMap (`k8s/pihole/dnsmasq-configmap.yaml`)

**Aktuelle Konfiguration**:
```conf
listen-address=0.0.0.0
interface=eth0
bind-interfaces=false
local-service=false
```

**Mount-Pfad**: `/etc/dnsmasq.d/99-custom.conf` (readOnly: true)

### 3. Pi-hole ConfigMap (`k8s/pihole/configmap.yaml`)

**Relevante Einstellungen**:
- `DNSMASQ_LISTENING: "all"`
- `ServerIP: "192.168.178.10"`

### 4. Service (`k8s/pihole/service.yaml`)

**Typ**: LoadBalancer  
**IP**: `192.168.178.10` (MetalLB)  
**Ports**: 53 (TCP/UDP), 80 (HTTP)  
**externalTrafficPolicy**: `Cluster`

## Bisherige Lösungsversuche (ALLE FEHLGESCHLAGEN)

### Versuch 1: ConfigMap mit `local-service=false`
- **Datum**: 2025-11-07
- **Änderung**: `local-service=false` in `99-custom.conf`
- **Ergebnis**: ❌ Problem besteht weiterhin

### Versuch 2: ConfigMap mit `interface=` (leer)
- **Datum**: 2025-11-07
- **Änderung**: `interface=` (leer) in `99-custom.conf`
- **Ergebnis**: ❌ Problem besteht weiterhin

### Versuch 3: ConfigMap mit `interface=eth0`
- **Datum**: 2025-11-07
- **Änderung**: `interface=eth0` in `99-custom.conf`
- **Ergebnis**: ❌ Problem besteht weiterhin

### Versuch 4: ConfigMap mit `listen-address=0.0.0.0`
- **Datum**: 2025-11-07
- **Änderung**: `listen-address=0.0.0.0` hinzugefügt
- **Ergebnis**: ❌ Problem besteht weiterhin

### Versuch 5: ConfigMap mit `localise-queries=false`
- **Datum**: 2025-11-07
- **Änderung**: `localise-queries=false` hinzugefügt
- **Ergebnis**: ❌ Problem besteht weiterhin

### Versuch 6: Deployment mit `PIHOLE_INTERFACE=eth0`
- **Datum**: 2025-11-07
- **Änderung**: Umgebungsvariable `PIHOLE_INTERFACE=eth0` hinzugefügt
- **Ergebnis**: ❌ Problem besteht weiterhin

### Versuch 7: Deployment mit `FTLCONF_dns_listeningMode=all` und `FTLCONF_dns_interface=eth0`
- **Datum**: 2025-11-07
- **Änderung**: Beide Umgebungsvariablen hinzugefügt
- **Ergebnis**: ❌ Problem besteht weiterhin

**Alle Versuche haben das Problem NICHT gelöst!**

## Aktueller Status

### Pod-Status:
- ✅ Pod läuft (`Running`)
- ✅ ConfigMap ist korrekt gemountet
- ✅ `/etc/dnsmasq.d/99-custom.conf` enthält die erwartete Konfiguration
- ✅ Umgebungsvariablen sind gesetzt

### DNS-Tests:
- ❌ `dig @192.168.178.10 google.de` → `timed out`
- ❌ `nc -zv -u 192.168.178.10 53` → Port ist erreichbar, aber DNS-Abfragen schlagen fehl
- ✅ `kubectl exec ... dig @127.0.0.1 google.de` → Funktioniert intern im Container

### Logs:
- ⚠️ `WARNING: dnsmasq: ignoring query from non-local network 192.168.178.20 (logged only once)`
- ⚠️ Keine weiteren Fehler in den Logs

## Bekannte Probleme / Offene Fragen

1. **Pi-hole FTL vs. dnsmasq**: Pi-hole verwendet FTL (Faster Than Light), das dnsmasq umhüllt. Möglicherweise überschreibt FTL die dnsmasq-Konfiguration.

2. **`pihole.toml`**: Die FTL-Konfigurationsdatei `/etc/pihole/pihole.toml` hat `interface = ""` (leer). Dies könnte die dnsmasq-Einstellungen überschreiben.

3. **MetalLB LoadBalancer**: Der Service verwendet `externalTrafficPolicy: Cluster`. Möglicherweise gibt es ein Problem mit der Weiterleitung von externen Anfragen.

4. **Kubernetes Pod Network vs. Heimnetz**: 
   - Pod Network: `10.244.0.0/16`
   - Heimnetz: `192.168.178.0/24`
   - Pi-hole läuft im Pod Network, aber Anfragen kommen vom Heimnetz

5. **dnsmasq "local network" Definition**: dnsmasq betrachtet möglicherweise nur das Kubernetes Pod Network als "lokal", nicht das Heimnetz.

## Was muss untersucht werden

### 1. Pi-hole FTL Konfiguration
- [ ] `/etc/pihole/pihole.toml` vollständig analysieren
- [ ] FTL-spezifische Umgebungsvariablen recherchieren
- [ ] Prüfen, ob FTL die dnsmasq-Konfiguration überschreibt
- [ ] Offizielle Pi-hole Docker-Dokumentation für Kubernetes/Container-Netzwerke konsultieren

### 2. dnsmasq Konfigurationsreihenfolge
- [ ] Alle dnsmasq-Konfigurationsdateien im Container auflisten (`/etc/dnsmasq.d/*`)
- [ ] Prüfen, welche Konfiguration zuletzt geladen wird
- [ ] Testen, ob andere Konfigurationsdateien unsere Einstellungen überschreiben
- [ ] dnsmasq-Konfigurationsreihenfolge dokumentieren

### 3. Netzwerk-Architektur
- [ ] MetalLB LoadBalancer-Konfiguration prüfen
- [ ] Service-Endpoints verifizieren
- [ ] Prüfen, ob Anfragen tatsächlich beim Pod ankommen (tcpdump im Container)
- [ ] IP-Tables/Netzwerk-Policies prüfen

### 4. Pi-hole Container-Image
- [ ] Pi-hole Image-Version prüfen (`pihole/pihole:latest`)
- [ ] Bekannte Probleme mit dieser Version recherchieren
- [ ] Prüfen, ob es spezielle Kubernetes-spezifische Konfigurationen gibt

### 5. Alternative Lösungsansätze
- [ ] Prüfen, ob `network_mode: host` in Kubernetes möglich ist (wahrscheinlich nicht)
- [ ] Prüfen, ob ein NodePort-Service statt LoadBalancer funktioniert
- [ ] Prüfen, ob ein HostNetwork-Pod notwendig ist
- [ ] Prüfen, ob ein Init-Container die Konfiguration setzen kann

## Empfohlene Vorgehensweise

### Phase 1: Tiefgreifende Analyse
1. **Pi-hole FTL Dokumentation studieren**: 
   - Offizielle Pi-hole Docker-Dokumentation
   - FTL-spezifische Konfigurationsoptionen
   - Kubernetes/Container-Netzwerk-Beispiele

2. **Container-Interna analysieren**:
   - Alle Konfigurationsdateien auflisten
   - dnsmasq-Prozess und Argumente prüfen
   - FTL-Prozess und Argumente prüfen
   - Netzwerk-Interfaces im Container prüfen

3. **Netzwerk-Flow nachvollziehen**:
   - tcpdump im Container während DNS-Abfrage
   - Prüfen, ob Pakete ankommen
   - Prüfen, welche IP-Adresse dnsmasq sieht

### Phase 2: Systematische Tests
1. **Minimale Konfiguration testen**:
   - Nur eine dnsmasq-Einstellung nach der anderen testen
   - Jede Änderung einzeln verifizieren

2. **Alternative Konfigurationsmethoden testen**:
   - Init-Container für Konfiguration
   - Direkte Modifikation von `pihole.toml`
   - FTL-Umgebungsvariablen statt dnsmasq

3. **Alternative Deployment-Methoden testen**:
   - NodePort statt LoadBalancer
   - HostNetwork (falls möglich)
   - DaemonSet statt Deployment

### Phase 3: Lösung implementieren
1. **Bewährte Lösung identifizieren**
2. **Vollständigen Plan erstellen** (jeder Schritt dokumentiert)
3. **Lösung implementieren**
4. **Umfassend testen**

## Wichtige Dateien

- `k8s/pihole/deployment.yaml` - Pi-hole Deployment
- `k8s/pihole/dnsmasq-configmap.yaml` - DNSmasq Custom ConfigMap
- `k8s/pihole/configmap.yaml` - Pi-hole Haupt-ConfigMap
- `k8s/pihole/service.yaml` - LoadBalancer Service
- `k8s/pihole/README.md` - Deployment-Dokumentation

## Relevante Dokumentation

- Pi-hole Docker: https://github.com/pi-hole/docker-pi-hole
- Pi-hole FTL: https://docs.pi-hole.net/ftldns/
- DNSmasq: http://www.thekelleys.org.uk/dnsmasq/doc.html
- Kubernetes LoadBalancer: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer

## Erwartetes Ergebnis

Nach erfolgreicher Lösung:
- ✅ Keine "ignoring query from non-local network" Warnungen mehr
- ✅ `dig @192.168.178.10 google.de` funktioniert
- ✅ Windows-Clients können automatische DNS-Konfiguration nutzen
- ✅ KI-Services funktionieren wieder

## Handover-Notiz

**An den nächsten Agenten**: 

Dieses Problem erfordert eine **systematische, tiefgreifende Untersuchung**. Alle oberflächlichen Lösungsversuche sind fehlgeschlagen. Bitte:

1. **NICHT** einfach weitere dnsmasq-Einstellungen ausprobieren
2. **SICHERSTELLEN**, dass die Pi-hole FTL-Dokumentation vollständig verstanden wird
3. **ANALYSIEREN**, wie FTL und dnsmasq interagieren
4. **TESTEN**, ob Anfragen tatsächlich beim Pod ankommen
5. **PLANEN**, bevor implementiert wird

**Dies ist ein komplexes Problem, das Zeit und sorgfältige Analyse erfordert.**

