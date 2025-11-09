# Ressourcen-Analyse - 2025-11-09

## 📊 Zusammenfassung

**Tatsächliche Auslastung vs. Limits:**

| Metrik | Tatsächlich | Requests | Limits | Status |
|--------|-------------|----------|--------|--------|
| **CPU** | 1123m (28%) | 4000m (100%) ⚠️ | 14400m (360%) | ✅ OK |
| **Memory** | 12368Mi (38%) | 27476Mi (86%) | 39296Mi (123%) | ✅ OK |

---

## 🔍 Detaillierte Analyse

### 1. Tatsächliche Nutzung (kubectl top)

**CPU:**
- **Gesamt**: 1123m von 4000m verfügbar = **28% Auslastung**
- **Top-Verbraucher**:
  - GitLab: 192m (4.8%)
  - kube-apiserver: 107m (2.7%)
  - etcd: 55m (1.4%)
  - gitlab-redis: 40m (1.0%)

**Memory:**
- **Gesamt**: 12368Mi von ~32GB verfügbar = **38% Auslastung**
- **Top-Verbraucher**:
  - GitLab: 3242Mi (10%)
  - kube-apiserver: 673Mi (2%)
  - Komga: 488Mi (1.5%)
  - ArgoCD: 259Mi (0.8%)

### 2. Allocated Resources (Requests)

**CPU Requests:**
- **Gesamt**: 4000m = **100% belegt** ⚠️
- **Problem**: Alle CPU-Ressourcen sind durch Requests blockiert
- **Auswirkung**: Neue Pods mit CPU-Requests können nicht gestartet werden

**Memory Requests:**
- **Gesamt**: 27476Mi = **86% belegt**
- **Status**: Noch 14% frei für neue Pods

### 3. Limits (Overcommitment)

**CPU Limits:**
- **Gesamt**: 14400m = **360% Overcommitment**
- **Bedeutung**: Pods können theoretisch bis zu 14.4 Cores nutzen, aber nur 4 verfügbar
- **Status**: ✅ OK, da tatsächliche Nutzung nur 28% ist

**Memory Limits:**
- **Gesamt**: 39296Mi = **123% Overcommitment**
- **Bedeutung**: Pods können theoretisch bis zu 39GB nutzen, aber nur ~32GB verfügbar
- **Status**: ✅ OK, da tatsächliche Nutzung nur 38% ist

---

## ⚠️ Problem-Analyse

### Warum zeigt Pi-hole "Load Average 4.6 > 4"?

**Tatsächliche Host-Daten (192.168.178.54):**
- **Load Average**: 6.22 (1min), 4.27 (5min), 2.75 (15min) ⚠️
- **CPU-Nutzung**: 16.7% user, 25.0% system, **58.3% idle** ✅
- **Memory**: 9.2Gi benutzt von 31Gi = **30% Auslastung** ✅
- **I/O-Wartezeit**: 0.52% (sehr niedrig) ✅
- **Prozesse**: 510 Tasks (1 running, 509 sleeping)

**Ursachen der hohen Load Average:**

1. **Viele laufende Prozesse**: 510 Tasks insgesamt, davon viele Kubernetes-Pods und Systemprozesse. Die Load Average misst die Anzahl wartender Prozesse, nicht nur CPU-Nutzung.

2. **Kubernetes Overhead**: 
   - kube-apiserver: 11.2% CPU
   - kubelet: 9.3% CPU
   - etcd: 5.6% CPU
   - Diese Prozesse verursachen Context-Switching, auch wenn die CPU-Nutzung niedrig ist.

3. **GitLab Overhead**: 
   - GitLab Sidekiq: 17.5% CPU
   - GitLab Puma Workers: mehrere Prozesse
   - GitLab Gitaly: läuft im Hintergrund

4. **Context Switching**: Bei vielen Prozessen muss der Kernel häufig zwischen Prozessen wechseln, was die Load Average erhöht, auch wenn die CPU nicht voll ausgelastet ist.

### Ist das ein Problem?

**Nein, aktuell kein kritisches Problem:**

- ✅ Alle Pods laufen (0 Pending, 0 Failed)
- ✅ Tatsächliche CPU-Nutzung ist niedrig (28%)
- ✅ Tatsächliche Memory-Nutzung ist niedrig (38%)
- ✅ Keine Ressourcen-Engpässe bei laufenden Pods
- ⚠️ CPU Requests sind bei 100% belegt (kann neue Pods blockieren)

---

## 💡 Empfehlungen

### Kurzfristig (Optional):

1. **CPU Requests reduzieren**: Einige nicht-kritische Pods haben möglicherweise zu hohe CPU-Requests. Diese könnten reduziert werden, um mehr "Luft" für neue Pods zu schaffen.

2. **Monitoring**: Die Load Average sollte überwacht werden. Wenn sie dauerhaft über 4 bleibt, könnte dies auf I/O-Probleme oder andere Engpässe hinweisen.

### Langfristig (Optional):

1. **Node erweitern**: Wenn mehr Services hinzugefügt werden sollen, könnte der Node um mehr CPU-Kerne erweitert werden.

2. **Workloads verteilen**: Wenn möglich, könnten Workloads auf mehrere Nodes verteilt werden.

---

## 📈 Fazit

**Die Maschine ist NICHT wirklich ausgelastet:**

- ✅ Tatsächliche CPU-Nutzung: **28%** (niedrig)
- ✅ Tatsächliche Memory-Nutzung: **38%** (niedrig)
- ⚠️ CPU Requests: **100%** (blockiert neue Pods, aber keine Auswirkung auf laufende Pods)
- ⚠️ Load Average: **4.6** (höher als erwartet, aber kein kritisches Problem)

**Die hohe Load Average (6.22) ist auf die große Anzahl laufender Prozesse (510 Tasks) und Kubernetes Overhead zurückzuführen, NICHT auf tatsächliche CPU-Auslastung (CPU ist zu 58% idle).**

**Top-Prozesse nach CPU:**
- GitLab Sidekiq: 17.5% CPU
- kube-apiserver: 11.2% CPU  
- kubelet: 9.3% CPU
- etcd: 5.6% CPU

**Top-Prozesse nach Memory:**
- GitLab Sidekiq: 967MB
- GitLab Puma Workers: ~950MB je Worker
- kube-apiserver: 649MB
- Komga (Java): 524MB

Die Limits sind hoch (Overcommitment), aber das ist OK, da die tatsächliche Nutzung niedrig ist. Die Pods können bei Bedarf mehr Ressourcen nutzen, solange die Limits nicht überschritten werden.

---

**Ende der Analyse**

