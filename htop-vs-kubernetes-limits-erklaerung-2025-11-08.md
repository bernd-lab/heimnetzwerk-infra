# Warum sieht man Kubernetes Limits nicht in htop?

## 🔍 Kurze Antwort

**htop zeigt die tatsächliche CPU/Memory-Nutzung der Prozesse, nicht die Kubernetes Requests/Limits.**

Kubernetes Limits werden durch **cgroups** im Linux-Kernel durchgesetzt, aber htop zeigt standardmäßig die Prozess-Nutzung, nicht die cgroup-Limits.

---

## 📊 Unterschied zwischen htop und Kubernetes

### htop zeigt:
- **Tatsächliche CPU-Nutzung** der Prozesse (in %)
- **Tatsächliche Memory-Nutzung** der Prozesse (in MB/GB)
- **Prozess-basierte Sicht** (ein Prozess = eine Zeile)

### Kubernetes Limits sind:
- **Maximale Ressourcen**, die ein Pod verwenden **darf**
- **Durchgesetzt durch cgroups** im Linux-Kernel
- **Pod-basiert** (ein Pod kann mehrere Container haben)

---

## ✅ Bestätigung: Limits sind gesetzt

Die Limits wurden erfolgreich gesetzt. Beispiel für PlantUML Pod:

```json
{
    "limits": {
        "cpu": "500m",
        "memory": "512Mi"
    },
    "requests": {
        "cpu": "10m",
        "memory": "128Mi"
    }
}
```

**Aktuelle Nutzung** (von `kubectl top`):
- CPU: 3m (weit unter dem Limit von 500m)
- Memory: 128Mi (weit unter dem Limit von 512Mi)

---

## 🔧 Wie man Kubernetes Limits im System sieht

### 1. Über kubectl (empfohlen)
```bash
# Pod-Ressourcen anzeigen
kubectl describe pod <pod-name> -n <namespace> | grep -A 10 "Limits\|Requests"

# Aktuelle Nutzung vs. Limits
kubectl top pod <pod-name> -n <namespace>
```

### 2. Über cgroups (im Container)
```bash
# CPU-Limit (cgroup v1)
cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us

# Memory-Limit (cgroup v1)
cat /sys/fs/cgroup/memory/memory.limit_in_bytes

# Memory-Limit (cgroup v2)
cat /sys/fs/cgroup/memory.max
```

### 3. Über containerd (auf dem Host)
```bash
# Container-ID finden
kubectl get pod <pod-name> -n <namespace> -o jsonpath='{.status.containerStatuses[0].containerID}'

# cgroup-Pfad finden
crictl inspect <container-id> | grep cgroupsPath
```

---

## 📈 Warum htop die Limits nicht zeigt

### Technische Gründe:

1. **htop zeigt Prozesse, nicht Pods**
   - Ein Pod kann mehrere Container haben
   - Ein Container kann mehrere Prozesse haben
   - htop zeigt jeden Prozess einzeln

2. **cgroups sind nicht direkt sichtbar**
   - Kubernetes verwendet cgroups für Limits
   - htop zeigt die Prozess-Nutzung, nicht die cgroup-Limits
   - Die Limits werden vom Kernel durchgesetzt, aber nicht in htop angezeigt

3. **Kubernetes abstrahiert die Ressourcen**
   - Kubernetes verwaltet Ressourcen auf Pod-Ebene
   - htop zeigt Ressourcen auf Prozess-Ebene
   - Die Zuordnung ist nicht direkt sichtbar

---

## 🔍 Wie man Limits in htop sehen könnte

### Option 1: cgroup-basierte Tools
```bash
# systemd-cgtop (zeigt cgroup-Nutzung)
systemd-cgtop

# cgroup-tools
cgget -r memory.limit_in_bytes /kubepods.slice/...

# systemd-run mit cgroup
systemd-cgtop
```

### Option 2: Kubernetes-spezifische Tools
```bash
# kubectl top (zeigt Pod-Nutzung)
kubectl top pods --all-namespaces

# Kubernetes Dashboard
# Zeigt Ressourcen-Nutzung vs. Limits

# Grafana mit Kubernetes-Metriken
# Zeigt Ressourcen-Nutzung vs. Limits
```

### Option 3: cgroup v2 (neuere Systeme)
```bash
# cgroup v2 zeigt Limits besser
cat /sys/fs/cgroup/kubepods.slice/.../memory.max
cat /sys/fs/cgroup/kubepods.slice/.../cpu.max
```

---

## ✅ Bestätigung: Die Anzeige stimmt

### Kubernetes zeigt korrekt:
- **CPU Requests**: 4 (100% von 4000m) ✅
- **CPU Limits**: 15900m (397%) ✅
- **Memory Requests**: 19924 Mi (62%) ✅
- **Memory Limits**: 32512 Mi (102%) ✅

### htop zeigt korrekt:
- **Tatsächliche CPU-Nutzung**: ~32% (1315m von 4000m) ✅
- **Tatsächliche Memory-Nutzung**: ~36% (11571 Mi von 32768 Mi) ✅

**Beide Anzeigen sind korrekt**, sie zeigen nur unterschiedliche Dinge:
- **Kubernetes**: Reservierte/limitierte Ressourcen
- **htop**: Tatsächliche Nutzung

---

## 📊 Beispiel: PlantUML Pod

### Kubernetes-Konfiguration:
- **CPU Request**: 10m (garantiert)
- **CPU Limit**: 500m (maximal)
- **Memory Request**: 128Mi (garantiert)
- **Memory Limit**: 512Mi (maximal)

### Tatsächliche Nutzung (kubectl top):
- **CPU**: 3m (3% von 500m Limit)
- **Memory**: 128Mi (25% von 512Mi Limit)

### In htop:
- **CPU**: Wird als Prozess-Nutzung angezeigt (z.B. 0.3% von gesamter CPU)
- **Memory**: Wird als Prozess-Memory angezeigt (z.B. 128 Mi)

**Fazit**: Der Pod nutzt weit unter seinen Limits, daher sieht man in htop keine Limit-Überschreitung.

---

## 🔧 Wie man Limits testet

### CPU-Limit testen:
```bash
# CPU-intensive Aufgabe im Pod starten
kubectl exec -n default <plantuml-pod> -- stress-ng --cpu 4 --timeout 60s

# In htop sollte die CPU-Nutzung steigen, aber nicht über 500m (50% von 1 Core) gehen
```

### Memory-Limit testen:
```bash
# Memory-intensive Aufgabe im Pod starten
kubectl exec -n default <plantuml-pod> -- stress-ng --vm 1 --vm-bytes 600M --timeout 60s

# Der Pod sollte bei ~512Mi gestoppt werden (OOMKilled)
```

---

## 📝 Zusammenfassung

**Warum sieht man Limits nicht in htop?**
- htop zeigt Prozess-Nutzung, nicht Pod-Limits
- Kubernetes Limits werden durch cgroups durchgesetzt
- Die Limits sind gesetzt und funktionieren, aber nicht direkt in htop sichtbar

**Wie kann man die Limits sehen?**
- `kubectl describe pod` - zeigt Limits
- `kubectl top pod` - zeigt Nutzung vs. Limits
- `systemd-cgtop` - zeigt cgroup-Nutzung
- Grafana/Kubernetes Dashboard - zeigt Ressourcen-Metriken

**Stimmt die Anzeige?**
- ✅ **Ja**, beide Anzeigen sind korrekt
- Kubernetes zeigt reservierte/limitierte Ressourcen
- htop zeigt tatsächliche Nutzung
- Die Limits werden durchgesetzt, auch wenn sie nicht direkt in htop sichtbar sind

---

**Erstellt**: 2025-11-08 19:20 CET

