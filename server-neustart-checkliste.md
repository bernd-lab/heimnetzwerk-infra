# Server-Neustart Checkliste

**Datum**: 2025-11-06  
**Server**: 192.168.178.54 (Kubernetes Node)  
**Aktion**: Neustart über Power-Button

## Vor dem Neustart

✅ **Bereit**: Neustart kann durchgeführt werden

## Neustart durchführen

1. **Power-Button kurz drücken** (nicht halten!)
2. **Warten** bis Server herunterfährt
3. **Power-Button erneut drücken** zum Starten
4. **Warten** 2-3 Minuten bis Server hochgefahren ist

## Nach dem Neustart - Prüfungen

### 1. Server erreichbar? (ca. 2-3 Minuten nach Start)

```bash
# Ping-Test
ping -c 3 192.168.178.54

# Erwartung: ✅ Antworten
```

### 2. SSH funktioniert? (ca. 3-5 Minuten nach Start)

```bash
# SSH-Test
ssh kvmhost "echo 'SSH funktioniert'"

# Oder direkt:
ssh -i ~/.ssh/infra_ed25519 bernd@192.168.178.54 "hostname"

# Erwartung: ✅ Verbindung erfolgreich
```

### 3. Kubernetes Cluster läuft? (ca. 5-10 Minuten nach Start)

```bash
# Cluster-Info
kubectl cluster-info

# Nodes prüfen
kubectl get nodes

# Erwartung: ✅ Nodes zeigen "Ready"
```

### 4. Kubernetes Services laufen? (ca. 10 Minuten nach Start)

```bash
# Alle Pods prüfen
kubectl get pods -A

# Services prüfen
kubectl get svc -A

# Ingress prüfen
kubectl get ingress -A

# Erwartung: ✅ Pods laufen, Services haben IPs
```

### 5. Ingress/HTTP funktioniert? (ca. 10-15 Minuten nach Start)

```bash
# HTTP-Test
curl -I http://192.168.178.54

# HTTPS-Test
curl -k -I https://gitlab.k8sops.online

# Erwartung: ✅ HTTP-Antworten (nicht Connection refused)
```

### 6. Pi-hole Status prüfen (ca. 15 Minuten nach Start)

```bash
# Pi-hole Pod
kubectl get pods -n pihole

# Pi-hole Service
kubectl get svc -n pihole

# Pi-hole IP prüfen
kubectl get svc pihole -n pihole -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

# Erwartung: ✅ Pod läuft, Service hat IP 192.168.178.10
```

### 7. Pi-hole DNS testen (ca. 15 Minuten nach Start)

```bash
# DNS-Test
dig @192.168.178.10 google.de +short

# Erwartung: ✅ IP-Adresse wird zurückgegeben
```

## Falls Pi-hole nicht läuft nach Neustart

### Pi-hole Deployment prüfen

```bash
# Prüfen ob Pi-hole deployed ist
kubectl get deployment -n pihole

# Falls nicht vorhanden: Deployen
cd /home/bernd/infra-0511
kubectl apply -k k8s/pihole/

# Oder mit Script:
./scripts/deploy-pihole.sh
```

### Pi-hole Logs prüfen

```bash
# Pod-Logs
kubectl logs -n pihole -l app=pihole

# Pod-Status
kubectl describe pod -n pihole -l app=pihole
```

## Erwartete Zeiten

- **Server-Start**: 2-3 Minuten
- **SSH verfügbar**: 3-5 Minuten
- **Kubernetes bereit**: 5-10 Minuten
- **Services gestartet**: 10-15 Minuten
- **Pi-hole läuft**: 15-20 Minuten (falls deployed)

## Troubleshooting

### SSH funktioniert nicht nach 5 Minuten

- Warten Sie weitere 2-3 Minuten
- Prüfen Sie ob Server wirklich hochgefahren ist (LEDs, Netzwerk-Link)

### Kubernetes nicht erreichbar nach 10 Minuten

```bash
# Auf Server prüfen (falls SSH funktioniert)
ssh kvmhost "sudo systemctl status kubelet"
ssh kvmhost "sudo systemctl status containerd"
```

### Pi-hole läuft nicht

- Prüfen Sie ob Pi-hole überhaupt deployed ist
- Prüfen Sie Pod-Logs
- Prüfen Sie ob MetallB IP-Pool korrekt ist

## Nächste Schritte nach erfolgreichem Neustart

1. ✅ **Pi-hole Status prüfen**
2. ✅ **Falls nicht deployed: Pi-hole deployen**
3. ✅ **DNS-Test durchführen**
4. ✅ **Windows/Laptop DNS auf automatisch umstellen** (siehe `dns-fix-zusammenfassung.md`)

