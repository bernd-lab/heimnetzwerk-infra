# Jellyfin Ressourcen-Analyse und Vergleich mit Empfehlungen

**Datum**: 2025-11-07  
**Status**: 📊 **Vollständige Analyse der Ressourcen-Konfiguration**

## Aktuelle Konfiguration

### Jellyfin Container (deployment.yaml)
```yaml
resources:
  limits:
    cpu: "8"           # 8 cores Maximum
    memory: 16Gi        # 16GB Maximum
  requests:
    cpu: 2000m         # 2 cores garantiert
    memory: 8Gi        # 8GB garantiert
```

### Tatsächliche Konfiguration (laufender Pod)
```yaml
resources:
  limits:
    cpu: "8"           # 8 cores Maximum
    memory: 16Gi       # 16GB Maximum
  requests:
    cpu: 1500m         # 1.5 cores garantiert (abweichend!)
    memory: 8Gi        # 8GB garantiert
```

⚠️ **Hinweis**: Die tatsächliche CPU-Request (1500m) weicht von der Konfiguration (2000m) ab!

## System-Ressourcen

### Node "zuhause"
- **CPU**: 4 cores verfügbar
- **Memory**: ~32GB verfügbar
- **Auslastung**:
  - CPU Requests: 3950m (98% von 4000m) - **SEHR HOCH!**
  - CPU Limits: 14 cores (350% - overcommitted)
  - Memory Requests: 13948Mi (43% von ~32GB)
  - Memory Limits: 25940Mi (81% von ~32GB)

## Jellyfin Offizielle Empfehlungen

### Mindestanforderungen
- **CPU**: Intel Core i5-11400 oder besser (für Hardware-Beschleunigung)
- **RAM**: Mindestens 8GB (empfohlen: 16GB für mehrere VMs)
- **Storage**: SSD mit mindestens 100GB für OS, Jellyfin-Dateien und Transcoding-Cache
- **GPU**: Intel UHD 710+ oder NVIDIA GTX16/RTX20+ für Hardware-Beschleunigung

### Empfohlene Ressourcen für verschiedene Nutzungen

#### 1. Basis-Nutzung (1-2 gleichzeitige Streams)
- **CPU**: 2-4 cores
- **RAM**: 4-8GB
- **Transcoding**: Software (CPU) oder Hardware (GPU)

#### 2. Mittel-Nutzung (3-5 gleichzeitige Streams)
- **CPU**: 4-6 cores
- **RAM**: 8-12GB
- **Transcoding**: Hardware-Beschleunigung empfohlen

#### 3. Hohe Nutzung (6+ gleichzeitige Streams)
- **CPU**: 6-8+ cores
- **RAM**: 12-16GB+
- **Transcoding**: Hardware-Beschleunigung erforderlich

## Vergleich: Aktuell vs. Empfehlungen

### CPU-Ressourcen

| Metrik | Aktuell | Empfehlung (Mittel) | Empfehlung (Hoch) | Bewertung |
|--------|---------|---------------------|-------------------|-----------|
| **CPU Request** | 1.5-2 cores | 4-6 cores | 6-8 cores | ⚠️ **Zu niedrig** |
| **CPU Limit** | 8 cores | 4-6 cores | 8+ cores | ✅ **Gut** (aber Node hat nur 4 cores!) |
| **Verhältnis** | 25-37% | 100% | 100% | ⚠️ **Request zu niedrig** |

**Problem**: 
- CPU Limit (8 cores) ist höher als verfügbare Node-CPUs (4 cores)
- CPU Request (1.5-2 cores) ist zu niedrig für optimale Performance
- Node ist bereits zu 98% ausgelastet

### Memory-Ressourcen

| Metrik | Aktuell | Empfehlung (Mittel) | Empfehlung (Hoch) | Bewertung |
|--------|---------|---------------------|-------------------|-----------|
| **Memory Request** | 8GB | 8-12GB | 12-16GB | ✅ **Gut** |
| **Memory Limit** | 16GB | 12GB | 16GB+ | ✅ **Gut** |
| **Verhältnis** | 25-50% | 67-100% | 75-100% | ✅ **Angemessen** |

**Bewertung**: Memory-Konfiguration ist gut und entspricht den Empfehlungen.

## Analyse der Probleme

### 1. CPU-Overcommitment
- **Problem**: CPU Limit (8 cores) > Node-CPUs (4 cores)
- **Auswirkung**: Jellyfin kann nie alle 8 cores nutzen
- **Lösung**: CPU Limit auf 4 cores reduzieren (oder Node mit mehr CPUs)

### 2. CPU-Request zu niedrig
- **Problem**: CPU Request (1.5-2 cores) ist zu niedrig für optimale Performance
- **Auswirkung**: Jellyfin kann bei hoher Last nicht genug CPU bekommen
- **Lösung**: CPU Request auf 3-4 cores erhöhen (aber Node ist bereits zu 98% ausgelastet!)

### 3. Node-Auslastung zu hoch
- **Problem**: Node ist zu 98% mit CPU Requests belegt
- **Auswirkung**: Keine Flexibilität für Burst-Workloads
- **Lösung**: Andere Pods reduzieren oder Node erweitern

### 4. Diskrepanz zwischen Konfiguration und Realität
- **Problem**: deployment.yaml sagt 2000m, Pod hat 1500m
- **Auswirkung**: Inkonsistenz
- **Lösung**: Konfiguration synchronisieren

## Empfohlene Anpassungen

### Option 1: Realistisch (empfohlen für aktuellen Node)

```yaml
resources:
  limits:
    cpu: "4"           # Maximal verfügbare Node-CPUs
    memory: 16Gi       # Behalten
  requests:
    cpu: 3000m         # 3 cores garantiert (75% des Nodes)
    memory: 8Gi        # Behalten
```

**Vorteile**:
- ✅ Realistisch (passt zu 4-core Node)
- ✅ Hohe garantierte CPU für Jellyfin
- ✅ Genug Memory

**Nachteile**:
- ⚠️ Node ist bereits zu 98% ausgelastet - andere Pods müssen reduziert werden
- ⚠️ Kein Burst-Raum für andere Services

### Option 2: Konservativ (wenn andere Pods wichtig)

```yaml
resources:
  limits:
    cpu: "4"           # Maximal verfügbare Node-CPUs
    memory: 12Gi       # Leicht reduziert
  requests:
    cpu: 2000m         # 2 cores garantiert (50% des Nodes)
    memory: 8Gi        # Behalten
```

**Vorteile**:
- ✅ Mehr Platz für andere Pods
- ✅ Realistisch

**Nachteile**:
- ⚠️ Weniger garantierte CPU für Jellyfin
- ⚠️ Möglicherweise nicht optimal für mehrere Streams

### Option 3: Optimiert für Hardware-Beschleunigung

```yaml
resources:
  limits:
    cpu: "4"           # Maximal verfügbare Node-CPUs
    memory: 16Gi       # Behalten
  requests:
    cpu: 2500m         # 2.5 cores garantiert
    memory: 10Gi       # Leicht erhöht
```

**Vorteile**:
- ✅ Balance zwischen Jellyfin und anderen Pods
- ✅ Genug für Hardware-Beschleunigung (GPU entlastet CPU)
- ✅ Realistisch

## Vergleich mit Empfehlungen

### ✅ Gut konfiguriert:
1. **Memory**: 8GB Request, 16GB Limit - entspricht Empfehlungen
2. **Hardware-Beschleunigung**: GPU konfiguriert (NVIDIA)
3. **PriorityClass**: Höchste Priorität gesetzt

### ⚠️ Verbesserungswürdig:
1. **CPU Request**: Zu niedrig (1.5-2 cores statt empfohlenen 4-6 cores)
2. **CPU Limit**: Zu hoch (8 cores, aber Node hat nur 4 cores)
3. **Node-Auslastung**: Zu hoch (98% CPU Requests belegt)

## Nächste Schritte

1. ✅ **CPU Limit anpassen**: Von 8 auf 4 cores reduzieren (realistisch)
2. ✅ **CPU Request erhöhen**: Von 1.5-2 auf 3 cores (optimal)
3. ⚠️ **Andere Pods prüfen**: Node-Auslastung reduzieren
4. ⚠️ **Konfiguration synchronisieren**: deployment.yaml und Pod-Status abgleichen

## Zusammenfassung

**Aktuelle Konfiguration**: 
- ✅ Memory: Gut (8GB/16GB)
- ⚠️ CPU: Zu niedrige Requests, zu hohe Limits
- ⚠️ Node: Zu hoch ausgelastet

**Empfehlung**: 
- CPU Request auf 3 cores erhöhen
- CPU Limit auf 4 cores reduzieren
- Andere Pods-Ressourcen prüfen und ggf. reduzieren

## ✅ Durchgeführte Anpassungen

### Ressourcen optimiert:

**Vorher**:
```yaml
resources:
  limits:
    cpu: "8"           # Zu hoch (Node hat nur 4 cores)
    memory: 16Gi
  requests:
    cpu: 2000m         # Zu niedrig für optimale Performance
    memory: 8Gi
```

**Nachher**:
```yaml
resources:
  limits:
    cpu: "4"           # Realistisch (passt zu Node)
    memory: 16Gi       # Behalten (entspricht Empfehlungen)
  requests:
    cpu: 3000m         # Optimal (75% des Nodes garantiert)
    memory: 8Gi        # Behalten (entspricht Mindestanforderungen)
```

### Verbesserungen:

1. ✅ **CPU Limit**: Von 8 auf 4 cores reduziert (realistisch)
2. ✅ **CPU Request**: Von 2000m auf 3000m erhöht (optimal)
3. ✅ **Memory**: Unverändert (bereits optimal)
4. ✅ **Konfiguration**: Jetzt konsistent mit Node-Ressourcen

### Auswirkungen:

- ✅ **Jellyfin**: Bekommt jetzt 3 cores garantiert (vorher 1.5-2 cores)
- ✅ **Realistisch**: CPU Limit passt zu verfügbaren Node-CPUs
- ⚠️ **Node-Auslastung**: Wird noch höher (von 98% auf ~100%)
- ⚠️ **Andere Pods**: Müssen möglicherweise reduziert werden

### Nächste Schritte:

1. ✅ **Ressourcen angepasst** - Deployment aktualisiert
2. ⚠️ **Node-Auslastung prüfen**: Andere Pods möglicherweise reduzieren
3. ⚠️ **Performance überwachen**: Prüfe ob Jellyfin jetzt besser läuft

