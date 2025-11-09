# Kubernetes Cluster Monitoring Dashboard

## Beschreibung

Dieses Dashboard überwacht den Kubernetes-Cluster über kube-state-metrics. Es zeigt den Status von Pods, Nodes, Deployments und anderen Kubernetes-Ressourcen.

## Überwachte Komponenten

- **Nodes**: Node-Status und -Bedingungen
- **Pods**: Pod-Status, Restarts, Resource-Usage
- **Deployments**: Deployment-Replicas und Status
- **Services**: Service-Status
- **Resources**: CPU/Memory Requests und Limits

## Metriken

| Metrik | Beschreibung | Einheit |
|--------|--------------|---------|
| `kube_node_status_condition` | Node-Status-Bedingungen (Ready, MemoryPressure, DiskPressure, PIDPressure) | Boolean |
| `kube_pod_status_phase` | Pod-Phase (Running, Pending, Failed, Succeeded, Unknown) | Phase |
| `kube_pod_container_status_ready` | Container Ready-Status | Boolean |
| `kube_pod_container_status_restarts_total` | Anzahl Container-Restarts | Count |
| `kube_deployment_status_replicas` | Deployment-Replicas nach Status (available, ready, unavailable) | Count |
| `kube_deployment_spec_replicas` | Gewünschte Anzahl Replicas | Count |
| `kube_pod_container_resource_requests` | Resource Requests nach Container (CPU, Memory) | Resource |
| `kube_pod_container_resource_limits` | Resource Limits nach Container (CPU, Memory) | Resource |

## Panels

1. **Node Status**: Anzahl Ready Nodes
2. **Pod Status**: Anzahl Running Pods
3. **Deployment Replicas**: Gesamtanzahl Deployment-Replicas
4. **Pod Status Distribution**: Verteilung der Pods nach Phase (Pie Chart)
5. **Container Restarts**: Anzahl Container-Restarts über Zeit nach Namespace/Pod
6. **Node Conditions**: Node Ready-Status über Zeit
7. **Deployment Status**: Verhältnis verfügbarer zu gewünschten Replicas

## PromQL Queries

### Ready Nodes
```promql
count(kube_node_status_condition{condition="Ready",status="true"})
```

### Running Pods
```promql
count(kube_pod_status_phase{phase="Running"})
```

### Pod Status Distribution
```promql
count by (phase) (kube_pod_status_phase)
```

### Container Restarts Rate
```promql
sum by (namespace, pod) (increase(kube_pod_container_status_restarts_total[5m]))
```

### Deployment Availability Ratio
```promql
kube_deployment_status_replicas_available / kube_deployment_spec_replicas
```

## Alerts

Mögliche Alerts basierend auf diesen Metriken:

- `count(kube_node_status_condition{condition="Ready",status="true"}) == 0` - Keine Ready Nodes
- `count(kube_pod_status_phase{phase="Failed"}) > 0` - Fehlgeschlagene Pods
- `kube_deployment_status_replicas_available / kube_deployment_spec_replicas < 1` - Deployment nicht vollständig verfügbar
- `increase(kube_pod_container_status_restarts_total[5m]) > 5` - Zu viele Container-Restarts

## Referenzen

- [kube-state-metrics Documentation](https://github.com/kubernetes/kube-state-metrics)
- [Kubernetes Metrics](https://kubernetes.io/docs/concepts/cluster-administration/system-metrics/)

