# Jellyfin auf WSL2 verschoben - Maximale Performance

**Datum**: 2025-11-06  
**Status**: ✅ **Verschoben und optimiert**

## Durchgeführte Änderungen

### 1. Jellyfin auf WSL2-Node verschoben ✅
- **Node-Selector**: `kubernetes.io/hostname: wsl2-ubuntu`
- **Toleration**: Für `workload-type=development:NoSchedule` Taint
- **Grund**: WSL2-Node hat mehr CPU-Ressourcen verfügbar für maximale Performance

### 2. CPU-Requests wieder erhöht ✅
- **Vorher**: 2000m (2 cores) - reduziert für Pi-hole/Ingress-Controller
- **Nachher**: 3000m (3 cores) - maximale Performance
- **Limits**: 4 cores (kann bei Bedarf alle 4 cores nutzen)

### 3. Node "zuhause" entlastet ✅
- **Vorher**: 97% CPU belegt (3900m von 4000m)
- **Nachher**: 72% CPU belegt (2900m von 4000m)
- **Effekt**: Mehr Platz für andere Services (z.B. Jenkins konnte starten)

## Aktuelle Ressourcen-Verteilung

### Node "zuhause" (Debian-Server, immer an)
- **CPU Requests**: 2900m (72%) von 4000m
- **Verteilung**:
  - Pi-hole: 100m
  - Ingress-Controller: 100m
  - Jenkins: 1000m
  - GitLab: ~500m
  - Andere Services: ~1200m
- **Verfügbar**: ~1100m (28%) für weitere Services

### Node "wsl2-ubuntu" (kann ausgeschaltet werden)
- **CPU Requests**: 3100m (19% von ~16 cores geschätzt)
- **Verteilung**:
  - Jellyfin: 3000m (3 cores)
  - Andere: ~100m
- **Vorteil**: Jellyfin kann volle Performance nutzen ohne andere Services zu beeinträchtigen

## Vorteile der Verschiebung

1. ✅ **Maximale Jellyfin-Performance**: 3 cores garantiert, 4 cores verfügbar
2. ✅ **Node "zuhause" entlastet**: Mehr Platz für kritische Services (Pi-hole, Ingress, Jenkins)
3. ✅ **Jenkins kann starten**: Hat jetzt genug CPU-Ressourcen
4. ✅ **Flexibilität**: WSL2 kann ausgeschaltet werden, wenn Jellyfin nicht benötigt wird

## Wichtige Hinweise

### ⚠️ WSL2-Node kann ausgeschaltet werden
- Wenn WSL2 ausgeschaltet wird, wird Jellyfin nicht verfügbar sein
- Für maximale Verfügbarkeit: Jellyfin zurück auf "zuhause" verschieben
- Für maximale Performance: WSL2 eingeschaltet lassen

### 🔄 Zurück auf "zuhause" verschieben (falls gewünscht)
```yaml
# In k8s/jellyfin/deployment.yaml
# nodeSelector und tolerations entfernen:
# nodeSelector:
#   kubernetes.io/hostname: wsl2-ubuntu
# tolerations:
# - key: workload-type
#   operator: Equal
#   value: development
#   effect: NoSchedule
```

## Verifizierung

✅ **Jellyfin**: Läuft auf WSL2-Node  
✅ **Jenkins**: Läuft jetzt (konnte starten nach Jellyfin-Verschiebung)  
✅ **Pi-hole**: Läuft auf "zuhause" Node  
✅ **Ingress-Controller**: Läuft auf "zuhause" Node  
✅ **Alle kritischen Services**: Laufen

## Nächste Schritte

1. ✅ Jellyfin auf WSL2 verschoben
2. ✅ Jenkins kann jetzt laufen
3. ⏳ Jellyfin Performance überwachen
4. ⏳ Bei Bedarf: Jellyfin zurück auf "zuhause" für maximale Verfügbarkeit

