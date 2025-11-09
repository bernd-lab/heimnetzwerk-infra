# System-Analyse Zusammenfassung

**Datum**: 2025-11-07  
**Status**: ✅ Metrics API installiert, ⚠️ DNS und Webserver-Probleme identifiziert

## 1. Metrics API Installation ✅

**Status**: Erfolgreich installiert und funktioniert

- Metrics Server installiert mit K3s-Anpassungen (`--kubelet-insecure-tls`)
- CPU-Requests reduziert auf `50m` für erfolgreichen Start
- `kubectl top nodes` und `kubectl top pods` funktionieren jetzt

**Aktuelle Node-Auslastung**:
- CPU: 34% (1398m von 4000m = 4 Cores) ✅ Normal
- Memory: 30% (9678Mi) ✅ Normal

## 2. CPU-Analyse ✅

**Top CPU-Verbraucher**:
1. kube-apiserver: 141m (3.5%)
2. kube-controller-manager: 93m (2.3%)
3. GitLab: 82m (2.1%)
4. Metrics Server: 74m (1.9%)
5. etcd: 60m (1.5%)

**Fazit**: CPU-Auslastung ist im normalen Bereich. Die Warnung über hohe Last (5.2 > 4) im Pi-hole Log stammt vermutlich von einem früheren Peak oder der Gesamtlast des Systems.

**Pi-hole CPU-Request**: Von `100m` auf `50m` reduziert, damit der Pod starten kann.

## 3. DNS-Problem von WSL2-Umgebung ⚠️

**Problem**: DNS-Abfragen von der aktuellen WSL2-Umgebung zu `192.168.178.54` timeouts.

**Befunde**:
- Pi-hole läuft und lauscht auf Port 53 (`0.0.0.0:53`)
- DNS funktioniert von anderen Geräten im Netzwerk (192.168.178.20, 192.178.178.34, etc.)
- WSL2 verwendet `nameserver 10.255.255.254` (interner WSL2 DNS-Resolver)
- Routing zu `192.168.178.54` geht über `172.31.16.1 dev eth0`
- Port 53 ist nicht direkt erreichbar von WSL2 aus (timeout bei `nc`)

**Ursache**: WSL2-Netzwerk-Konfiguration blockiert DNS-Pakete an den Host. Dies ist ein bekanntes WSL2-Problem, wenn DNS-Pakete nicht korrekt weitergeleitet werden.

**Lösungsansätze**:
1. WSL2 `/etc/resolv.conf` manuell auf `192.168.178.54` setzen (temporär)
2. Windows DNS-Einstellungen anpassen
3. WSL2-Netzwerk-Bridge-Konfiguration prüfen

**Status**: Pi-hole DNS funktioniert korrekt für alle anderen Geräte im Netzwerk. Das Problem ist spezifisch für die WSL2-Umgebung.

## 4. Pi-hole Webserver-Problem ⚠️

**Problem**: Pi-hole Webserver kann nicht auf Port 80 binden.

**Befunde**:
- Port 80 lauscht mehrfach (mehrere Prozesse)
- Webserver-Log zeigt: `cannot bind to 80o: 98 (Address in use)`
- Port-Konfiguration in `pihole.toml`: `"80o,443os,[::]:80o,[::]:443os"`
- HTTP-Anfragen an Port 80 geben `404 Not Found` zurück

**Ursache**: Port 80 ist bereits von einem anderen Prozess belegt. Mögliche Kandidaten:
- nginx-ingress-controller (läuft mit `hostNetwork: true`?)
- Anderer Service auf dem Host

**Lösungsansätze**:
1. Prüfen, welcher Prozess Port 80 verwendet
2. Pi-hole Webserver auf anderen Port konfigurieren (z.B. 8080)
3. Oder nginx-ingress so konfigurieren, dass er Port 80 freigibt

**Status**: Webserver läuft nicht korrekt, aber DNS funktioniert.

## Nächste Schritte

1. ✅ Metrics API installiert
2. ✅ CPU-Analyse abgeschlossen
3. ⚠️ DNS-Problem von WSL2 analysieren und beheben
4. ⚠️ Webserver-Problem identifizieren und beheben

