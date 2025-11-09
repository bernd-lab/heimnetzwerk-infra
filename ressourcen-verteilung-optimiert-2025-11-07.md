# Optimale Ressourcen-Verteilung für 4-Core Node

**Datum**: 2025-11-07  
**Status**: Berechnung abgeschlossen

## Node-Kapazität

- **CPU**: 4 cores (4000m)
- **Memory**: ~32GB (31963Mi)
- **Verfügbar für Pods**: ~3800m CPU (95% - 200m für System), ~30000Mi Memory (94%)

## Optimierte Ressourcen-Verteilung

### Realistische Lösung für 4-Core Node

Da die Node nur 4 cores hat, müssen wir die Ressourcen realistisch verteilen:

#### 1. Jellyfin (Priorität: HOCH - soll performant sein)
- **CPU Request**: **2000m** (2 cores garantiert - 50% des Nodes, großzügig)
- **CPU Limit**: **4** (alle verfügbaren CPUs)
- **Memory Request**: **12Gi** (großzügig für Bibliotheks-Scans)
- **Memory Limit**: **16Gi** (behalten)

**Begründung**: Jellyfin soll performant sein, Hardware-Beschleunigung aktiviert, mehrere Streams gleichzeitig möglich. 50% des Nodes ist großzügig aber realistisch.

#### 2. GitLab CE
- **CPU Request**: **500m** (0.5 cores garantiert)
- **CPU Limit**: **2** (behalten)
- **Memory Request**: **4Gi** (erhöht für bessere Performance)
- **Memory Limit**: **6Gi** (erhöht)

#### 3. GitLab PostgreSQL
- **CPU Request**: **300m** (0.3 cores garantiert)
- **CPU Limit**: **1** (1 core max)
- **Memory Request**: **1Gi** (erhöht)
- **Memory Limit**: **2Gi**

#### 4. GitLab Redis
- **CPU Request**: **100m**
- **CPU Limit**: **500m** (0.5 cores max)
- **Memory Request**: **512Mi** (erhöht)
- **Memory Limit**: **1Gi**

#### 5. Pi-hole
- **CPU Request**: **100m**
- **CPU Limit**: **500m** (behalten)
- **Memory Request**: **512Mi** (erhöht)
- **Memory Limit**: **1Gi** (erhöht für größere Blocklisten)

#### 6. GitLab Runner (2 Pods)
- **CPU Request**: **100m** pro Pod (200m gesamt)
- **CPU Limit**: **500m** pro Pod
- **Memory Request**: **256Mi** pro Pod (512Mi gesamt)
- **Memory Limit**: **512Mi** pro Pod

#### 7. Ingress-NGINX Controller
- **CPU Request**: **150m**
- **CPU Limit**: **1** (1 core max)
- **Memory Request**: **256Mi** (neu)
- **Memory Limit**: **512Mi** (erhöht)

#### 8. ArgoCD Komponenten
- **application-controller**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **repo-server** (2 Pods): CPU Request: 150m pro Pod (300m gesamt), Limit: 1, Memory Request: 512Mi pro Pod (1Gi gesamt), Limit: 1Gi
- **server** (2 Pods): CPU Request: 50m pro Pod (100m gesamt), Limit: 500m, Memory Request: 256Mi pro Pod (512Mi gesamt), Limit: 512Mi
- **dex-server** (2 Pods): CPU Request: 50m pro Pod (100m gesamt), Limit: 500m, Memory Request: 256Mi pro Pod (512Mi gesamt), Limit: 512Mi
- **notifications-controller**: CPU Request: 50m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **redis** (2 Pods): CPU Request: 50m pro Pod (100m gesamt), Limit: 500m, Memory Request: 256Mi pro Pod (512Mi gesamt), Limit: 512Mi

**ArgoCD Gesamt**: CPU Request: ~850m, Memory Request: ~3.5Gi

#### 9. Cert-Manager Komponenten
- **controller**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **cainjector** (2 Pods): CPU Request: 25m pro Pod (50m gesamt), Limit: 200m, Memory Request: 128Mi pro Pod (256Mi gesamt), Limit: 256Mi
- **webhook** (2 Pods): CPU Request: 25m pro Pod (50m gesamt), Limit: 200m, Memory Request: 128Mi pro Pod (256Mi gesamt), Limit: 256Mi

**Cert-Manager Gesamt**: CPU Request: ~200m, Memory Request: ~768Mi

#### 10. CoreDNS (2 Pods)
- **CPU Request**: 50m pro Pod (100m gesamt)
- **CPU Limit**: 500m pro Pod
- **Memory Request**: 128Mi pro Pod (256Mi gesamt)
- **Memory Limit**: 256Mi pro Pod

#### 11. MetalLB
- **controller**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi
- **speaker**: CPU Request: 50m, Limit: 200m, Memory Request: 128Mi, Limit: 256Mi

**MetalLB Gesamt**: CPU Request: 100m, Memory Request: 256Mi

#### 12. Velero (2 Pods)
- **CPU Request**: 100m pro Pod (200m gesamt)
- **CPU Limit**: 1 pro Pod
- **Memory Request**: 512Mi pro Pod (1Gi gesamt)
- **Memory Limit**: 1Gi pro Pod

#### 13. NFS Provisioner (3 Instanzen)
- **CPU Request**: 50m pro Instanz (150m gesamt)
- **CPU Limit**: 200m pro Instanz
- **Memory Request**: 128Mi pro Instanz (384Mi gesamt)
- **Memory Limit**: 256Mi pro Instanz

#### 14. Weitere Services (geschätzt)
- **Prometheus**: CPU Request: 500m, Limit: 2, Memory Request: 2Gi, Limit: 4Gi
- **Grafana**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **Loki**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **Komga**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **Syncthing**: CPU Request: 200m, Limit: 1, Memory Request: 512Mi, Limit: 1Gi
- **PlantUML**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **Heimdall**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **Kubernetes Dashboard**: CPU Request: 100m, Limit: 500m, Memory Request: 256Mi, Limit: 512Mi
- **GitLab Agent** (2 Pods): CPU Request: 50m pro Pod (100m gesamt), Limit: 500m, Memory Request: 256Mi pro Pod (512Mi gesamt), Limit: 512Mi

**Weitere Services Gesamt**: CPU Request: ~1700m, Memory Request: ~6Gi

## Ressourcen-Berechnung (Summe)

### CPU Requests:
- Jellyfin: 2000m
- GitLab: 500m
- GitLab PostgreSQL: 300m
- GitLab Redis: 100m
- Pi-hole: 100m
- GitLab Runner: 200m
- Ingress-NGINX: 150m
- ArgoCD: 850m
- Cert-Manager: 200m
- CoreDNS: 100m
- MetalLB: 100m
- Velero: 200m
- NFS Provisioner: 150m
- Weitere Services: 1700m
- **Gesamt**: ~6750m

**Problem**: Gesamt-CPU-Requests (6750m) > Verfügbare CPUs (4000m)!

### Memory Requests:
- Jellyfin: 12Gi
- GitLab: 4Gi
- GitLab PostgreSQL: 1Gi
- GitLab Redis: 512Mi
- Pi-hole: 512Mi
- GitLab Runner: 512Mi
- Ingress-NGINX: 256Mi
- ArgoCD: ~3.5Gi
- Cert-Manager: ~768Mi
- CoreDNS: 256Mi
- MetalLB: 256Mi
- Velero: 1Gi
- NFS Provisioner: 384Mi
- Weitere Services: ~6Gi
- **Gesamt**: ~30Gi

**Bewertung**: Memory Requests (~30Gi) < Verfügbare Memory (~32GB) - OK, aber knapp

## Finale Anpassung für 4-Core Node

Da CPU-Requests die verfügbaren CPUs übersteigen, müssen wir die Werte weiter reduzieren:

### Reduzierte CPU Requests:
- Jellyfin: **2000m** (50% des Nodes - Priorität HOCH, beibehalten)
- GitLab: **400m** (reduziert von 500m)
- GitLab PostgreSQL: **200m** (reduziert von 300m)
- GitLab Redis: **100m** (behalten)
- Pi-hole: **100m** (behalten)
- GitLab Runner: **150m** (reduziert von 200m)
- Ingress-NGINX: **100m** (reduziert von 150m)
- ArgoCD: **600m** (reduziert von 850m)
- Cert-Manager: **150m** (reduziert von 200m)
- CoreDNS: **50m** (reduziert von 100m)
- MetalLB: **50m** (reduziert von 100m)
- Velero: **150m** (reduziert von 200m)
- NFS Provisioner: **100m** (reduziert von 150m)
- Weitere Services: **1000m** (reduziert von 1700m)
- **Gesamt**: ~5150m

**Noch immer zu hoch!** Weitere Reduzierung notwendig.

### Finale Lösung: Optimale Balance für 4-Core Node

- Jellyfin: **2000m** (50% - Priorität HOCH, beibehalten)
- GitLab: **300m** (reduziert)
- GitLab PostgreSQL: **200m** (reduziert)
- GitLab Redis: **100m** (behalten)
- Pi-hole: **100m** (behalten)
- GitLab Runner: **100m** (reduziert)
- Ingress-NGINX: **100m** (reduziert)
- ArgoCD: **400m** (reduziert)
- Cert-Manager: **100m** (reduziert)
- CoreDNS: **50m** (reduziert)
- MetalLB: **50m** (reduziert)
- Velero: **100m** (reduziert)
- NFS Provisioner: **75m** (reduziert)
- Weitere Services: **500m** (stark reduziert)
- **Gesamt**: ~4175m

**Noch knapp über Limit!** Weitere kleine Reduzierungen:

- Jellyfin: **2000m** (beibehalten - Priorität)
- GitLab: **300m**
- GitLab PostgreSQL: **200m**
- GitLab Redis: **100m**
- Pi-hole: **100m**
- GitLab Runner: **100m**
- Ingress-NGINX: **100m**
- ArgoCD: **350m** (reduziert)
- Cert-Manager: **100m**
- CoreDNS: **50m**
- MetalLB: **50m**
- Velero: **100m**
- NFS Provisioner: **50m** (reduziert)
- Weitere Services: **400m** (reduziert)
- **Gesamt**: ~3950m

**OK!** Unter 4000m Limit, aber sehr knapp.

## Empfehlung

**Option 1: Node erweitern** (empfohlen)
- Mindestens 6-8 cores für komfortable Ressourcen-Verteilung
- Aktuell: 4 cores sind zu knapp für alle Services

**Option 2: Realistische Ressourcen für 4-Core Node** (implementiert)
- Jellyfin: 2000m CPU Request (50% des Nodes - großzügig)
- Andere Services: Reduzierte Requests, aber Limits höher für Burst
- Memory: Kann großzügiger sein (32GB verfügbar)

## Implementierung

Die finale Lösung verwendet:
- **CPU Requests**: ~3950m (98.75% von 4000m) - sehr knapp, aber machbar
- **Memory Requests**: ~30Gi (94% von 32GB) - OK
- **Limits**: Höher als Requests für Burst-Capability

**Wichtig**: Limits sind höher als Requests, sodass Pods bei Bedarf mehr Ressourcen nutzen können (Burst).

