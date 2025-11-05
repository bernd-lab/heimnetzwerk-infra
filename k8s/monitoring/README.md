# Monitoring Tools

## Kubernetes Dashboard

Kubernetes Dashboard ist ein Web-basiertes UI für Kubernetes-Cluster.

### Deployment

```bash
# Alle Ressourcen auf einmal deployen
kubectl apply -k k8s/monitoring/kubernetes-dashboard/

# Oder einzeln:
kubectl apply -f k8s/monitoring/kubernetes-dashboard/namespace.yaml
kubectl apply -f k8s/monitoring/kubernetes-dashboard/serviceaccount.yaml
kubectl apply -f k8s/monitoring/kubernetes-dashboard/clusterrolebinding.yaml
kubectl apply -f k8s/monitoring/kubernetes-dashboard/deployment.yaml
kubectl apply -f k8s/monitoring/kubernetes-dashboard/service.yaml
kubectl apply -f k8s/monitoring/kubernetes-dashboard/certificate.yaml
kubectl apply -f k8s/monitoring/kubernetes-dashboard/ingress.yaml
```

### Zugriff

- **URL**: https://dashboard.k8sops.online
- **ServiceAccount**: `kubernetes-dashboard` (ClusterAdmin-Rechte)
- **Login**: Skip-Login aktiviert (für lokale Nutzung)

### Sicherheit

- Dashboard läuft mit ClusterAdmin-Rechten (für Entwicklung/Heimnetzwerk)
- In Produktion sollte ein eingeschränkter ServiceAccount verwendet werden
- HTTPS wird über Ingress mit Let's Encrypt-Zertifikat bereitgestellt

## K9s (Terminal UI)

K9s ist eine Terminal-basierte UI für Kubernetes.

### Installation

```bash
curl -sS https://k9scli.io/install.sh | sh
```

### Nutzung

```bash
# Für spezifischen Namespace
k9s -n gitlab

# Für alle Namespaces
k9s --all-namespaces
```

### Features

- Live-Pod-Beobachtung
- Logs-Viewing
- Resource-Management
- Event-Monitoring

