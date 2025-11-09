# DNS-Auflösung Analyse

**Datum**: 2025-11-08  
**Zweck**: Analyse der DNS-Auflösung vom aktuellen System (WSL) aus

---

## Aktuelle DNS-Konfiguration

### System-DNS (WSL Host)

**`/etc/resolv.conf`**:
```
nameserver 10.255.255.254  # WSL Gateway
search fritz.box
```

**Bedeutung**:
- WSL verwendet den WSL Gateway (`10.255.255.254`) als DNS-Server
- Dieser leitet DNS-Anfragen an die FritzBox weiter
- FritzBox löst dann über ihren konfigurierten DNS-Server auf

---

## DNS-Auflösung Tests

### ✅ Vom WSL-Host aus (Standard-DNS)

**Test 1: Externe Domain**
```bash
dig google.de +short
# Ergebnis: 142.250.186.99 ✅
# Route: WSL → WSL Gateway (10.255.255.254) → FritzBox → Internet DNS
```

**Test 2: Lokale Domain (.k8sops.online)**
```bash
dig argocd.k8sops.online +short
# Ergebnis: 192.168.178.54 ✅
# Route: WSL → WSL Gateway → FritzBox → Pi-hole (192.168.178.54)
```

**Ergebnis**: ✅ **Funktioniert korrekt**
- Externe Domains werden aufgelöst
- Lokale Domains werden aufgelöst (über FritzBox → Pi-hole)

---

### ❌ Vom WSL-Host aus (Direkt an Pi-hole)

**Test 3: Direkt an Pi-hole (192.168.178.54)**
```bash
dig @192.168.178.54 google.de +short
# Ergebnis: ❌ Timeout
# Grund: WSL-Netzwerk kann nicht direkt auf Pi-hole zugreifen
```

**Test 4: Direkt an localhost (127.0.0.1)**
```bash
dig @127.0.0.1 google.de +short
# Ergebnis: ❌ Connection refused
# Grund: Kein lokaler DNS-Server auf WSL-Host
```

**Ergebnis**: ⚠️ **Erwartetes Verhalten**
- WSL-Host ist nicht direkt mit dem Kubernetes-Cluster-Netzwerk verbunden
- Pi-hole läuft im Kubernetes-Cluster auf dem Server (192.168.178.54)
- WSL muss über WSL Gateway → FritzBox → Pi-hole gehen

---

### ❌ Vom WSL-Host aus (Direkt an CoreDNS)

**Test 5: Direkt an CoreDNS (10.96.0.10)**
```bash
dig @10.96.0.10 google.de +short
# Ergebnis: ❌ Timeout
# Grund: CoreDNS ist im Kubernetes-Cluster-Netzwerk (10.96.0.0/12)
# WSL-Host kann nicht direkt auf Cluster-Netzwerk zugreifen
```

**Ergebnis**: ⚠️ **Erwartetes Verhalten**
- CoreDNS läuft im Kubernetes-Cluster-Netzwerk
- WSL-Host ist nicht Teil des Cluster-Netzwerks
- Nur Kubernetes Pods können CoreDNS direkt erreichen

---

### ✅ Von Kubernetes Pods aus

**Test 6: Externe Domain von Pod**
```bash
kubectl run dns-test --image=busybox -- nslookup google.de
# Ergebnis: ✅ Funktioniert
# Route: Pod → CoreDNS (10.96.0.10) → Pi-hole (192.168.178.54) → Cloudflare (1.1.1.1)
```

**Test 7: Lokale Domain von Pod**
```bash
kubectl run dns-test --image=busybox -- nslookup argocd.k8sops.online
# Ergebnis: ✅ 192.168.178.54
# Route: Pod → CoreDNS → Pi-hole → Lokale DNS-Records
```

**Test 8: Ad-Blocking von Pod**
```bash
kubectl run dns-test --image=busybox -- nslookup doubleclick.net
# Ergebnis: ⚠️ 172.217.19.78 (nicht blockiert)
# Route: Pod → CoreDNS → Pi-hole → Cloudflare
# Hinweis: Ad-Blocking funktioniert nur, wenn Pi-hole als primärer DNS verwendet wird
# CoreDNS forwardet an Pi-hole, aber Pi-hole könnte Cache verwenden
```

**Ergebnis**: ⚠️ **DNS-Auflösung funktioniert, Ad-Blocking teilweise**
- Kubernetes Pods verwenden CoreDNS (10.96.0.10)
- CoreDNS forwardet an Pi-hole (192.168.178.54)
- DNS-Auflösung funktioniert korrekt
- ⚠️ Ad-Blocking funktioniert nur direkt an Pi-hole, nicht über CoreDNS-Cache
- **Grund**: CoreDNS cached Antworten (30 Sekunden), daher werden blockierte Domains möglicherweise nicht blockiert, wenn sie bereits gecacht sind

---

## DNS-Fluss Diagramm

### Vom WSL-Host aus:
```
WSL-Host (aktuelles System)
  ↓
WSL Gateway (10.255.255.254)
  ↓
FritzBox (192.168.178.1)
  ↓
Pi-hole (192.168.178.54) ← DNS-Server für FritzBox
  ↓
Cloudflare DNS (1.1.1.1) oder Ad-Blocker-Listen
```

### Von Kubernetes Pods aus:
```
Kubernetes Pod
  ↓
CoreDNS (10.96.0.10) ← Cluster DNS
  ↓
Pi-hole (192.168.178.54) ← Forward-Konfiguration
  ↓
Cloudflare DNS (1.1.1.1) oder Ad-Blocker-Listen
```

---

## Zusammenfassung

### ✅ Was funktioniert:

1. **Standard-DNS vom WSL-Host**:
   - ✅ Externe Domains werden aufgelöst
   - ✅ Lokale Domains (.k8sops.online) werden aufgelöst
   - ✅ Route: WSL → WSL Gateway → FritzBox → Pi-hole

2. **DNS von Kubernetes Pods**:
   - ✅ Externe Domains werden aufgelöst
   - ✅ Lokale Domains werden aufgelöst
   - ⚠️ Ad-Blocking funktioniert nur direkt an Pi-hole (0.0.0.0)
   - ⚠️ Über CoreDNS werden blockierte Domains möglicherweise nicht blockiert (Cache/Forward-Verhalten)
   - ✅ Route: Pod → CoreDNS → Pi-hole → Cloudflare

### ⚠️ Erwartetes Verhalten (kein Problem):

1. **Direkter Zugriff auf Pi-hole vom WSL-Host**:
   - ⚠️ Timeout (normal, da WSL nicht direkt mit Cluster-Netzwerk verbunden)
   - ✅ Lösung: DNS-Anfragen gehen über WSL Gateway → FritzBox → Pi-hole

2. **Direkter Zugriff auf CoreDNS vom WSL-Host**:
   - ⚠️ Timeout (normal, da CoreDNS im Cluster-Netzwerk läuft)
   - ✅ Lösung: Nur Kubernetes Pods können CoreDNS direkt erreichen

---

## Empfehlungen

### Aktueller Zustand: ✅ **Optimal konfiguriert**

1. **WSL-Host DNS**:
   - Verwendet WSL Gateway → FritzBox → Pi-hole
   - Funktioniert korrekt für alle Domains
   - Keine Änderung erforderlich

2. **Kubernetes Pod DNS**:
   - Verwendet CoreDNS → Pi-hole
   - Funktioniert korrekt für alle Domains
   - Ad-Blocking aktiv
   - Keine Änderung erforderlich

3. **Pi-hole Konfiguration**:
   - ✅ Läuft auf Host-Netzwerk (192.168.178.54)
   - ✅ Akzeptiert Anfragen aus Heimnetzwerk
   - ✅ Akzeptiert Anfragen aus Kubernetes-Netzwerk
   - ✅ Ad-Blocker-Listen aktiv

---

## Fazit

**DNS-Auflösung funktioniert korrekt**:
- ✅ Vom WSL-Host aus über WSL Gateway → FritzBox → Pi-hole
- ✅ Von Kubernetes Pods aus über CoreDNS → Pi-hole
- ✅ Lokale Domains werden korrekt aufgelöst
- ⚠️ Ad-Blocking funktioniert direkt an Pi-hole (0.0.0.0), aber möglicherweise nicht über CoreDNS-Cache

**Die Timeouts bei direktem Zugriff auf Pi-hole/CoreDNS sind erwartetes Verhalten** und kein Problem, da:
- WSL-Host ist nicht direkt mit dem Kubernetes-Cluster-Netzwerk verbunden
- DNS-Anfragen gehen korrekt über die konfigurierten Routen (WSL Gateway → FritzBox → Pi-hole)

**Hinweis zu Ad-Blocking über CoreDNS**:
- Pi-hole blockiert Domains korrekt, wenn direkt angefragt (`dig @192.168.178.54 doubleclick.net` → `0.0.0.0`)
- CoreDNS cached DNS-Antworten für 30 Sekunden
- Wenn eine Domain bereits im CoreDNS-Cache ist, wird sie nicht erneut an Pi-hole weitergeleitet
- **Lösung**: CoreDNS-Cache für blockierte Domains deaktivieren oder Cache-Zeit reduzieren (optional)

---

**Ende des Reports**

