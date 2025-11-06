# Jellyfin - Maximale Ressourcen-Konfiguration

**Datum**: 2025-11-06  
**Status**: ✅ **Massive Ressourcen-Erhöhung implementiert**

## WSL2-Node Ressourcen

- **CPU**: 16 cores verfügbar
- **Memory**: ~58GB verfügbar
- **Vorteil**: Viel Platz für maximale Jellyfin-Performance

## Neue Jellyfin-Ressourcen

### Vorher
- **CPU Requests**: 3000m (3 cores)
- **CPU Limits**: 4 cores
- **Memory Requests**: 8Gi
- **Memory Limits**: 12Gi

### Nachher (MASSIVE Steigerung!)
- **CPU Requests**: **6000m (6 cores)** - 200% mehr!
- **CPU Limits**: **8 cores** - 100% mehr!
- **Memory Requests**: **12Gi** - 50% mehr!
- **Memory Limits**: **16Gi** - 33% mehr!

## Auslastung auf WSL2-Node

- **CPU Requests**: 6100m (38% von 16 cores)
- **CPU Limits**: 8 cores (50% von 16 cores)
- **Memory Requests**: 12338Mi (21% von ~58GB)
- **Memory Limits**: 16Gi (28% von ~58GB)

## Effekt

✅ **6 cores garantiert** für Jellyfin (37.5% des Nodes)  
✅ **8 cores verfügbar** bei Bedarf (50% des Nodes)  
✅ **12GB Memory garantiert** für große Bibliotheks-Scans  
✅ **16GB Memory verfügbar** für intensive Transcoding-Operationen  

## Verwendung

Jellyfin kann jetzt:
- **Mehrere Streams gleichzeitig** transcodieren
- **Große Bibliotheks-Scans** schneller durchführen
- **Bilder/Thumbnails** parallel generieren
- **Vollständige Hardware-Beschleunigung** nutzen (GPU + massive CPU)

## Vergleich

| Metrik | Vorher | Nachher | Steigerung |
|--------|--------|---------|------------|
| CPU Requests | 3 cores | 6 cores | +100% |
| CPU Limits | 4 cores | 8 cores | +100% |
| Memory Requests | 8Gi | 12Gi | +50% |
| Memory Limits | 12Gi | 16Gi | +33% |

## Wichtige Hinweise

⚠️ **WSL2-Node muss eingeschaltet sein** für Jellyfin  
⚠️ **Andere Services auf WSL2** haben weniger Platz (aber noch genug)  
✅ **Node "zuhause" bleibt entlastet** für kritische Services  

## Nächste Schritte

1. ✅ Jellyfin hat jetzt maximale Ressourcen
2. ⏳ Performance überwachen
3. ⏳ Bei Bedarf: Weitere Optimierungen (z.B. mehr CPU-Limits)

