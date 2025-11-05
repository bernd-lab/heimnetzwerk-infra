#!/bin/bash
# Pi-hole Deployment Script
# Deploys Pi-hole to Kubernetes cluster

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
K8S_DIR="$PROJECT_ROOT/k8s/pihole"
KUBECONFIG="${KUBECONFIG:-$HOME/.kube/config}"

log_info() { echo -e "\033[0;34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[0;32m[SUCCESS]\033[0m $1"; }
log_warning() { echo -e "\033[0;33m[WARNING]\033[0m $1"; }
log_error() { echo -e "\033[0;31m[ERROR]\033[0m $1"; }

check_prerequisites() {
    log_info "Prüfe Voraussetzungen..."
    
    # kubectl vorhanden?
    if ! command -v kubectl &> /dev/null; then
        log_error "kubectl nicht gefunden. Bitte installieren."
        exit 1
    fi
    
    # Kubernetes-Cluster erreichbar?
    if ! kubectl --kubeconfig="$KUBECONFIG" cluster-info &> /dev/null; then
        log_error "Kubernetes-Cluster nicht erreichbar!"
        echo "Bitte prüfe:"
        echo "  1. Cluster läuft"
        echo "  2. KUBECONFIG ist gesetzt: $KUBECONFIG"
        echo "  3. Netzwerk-Verbindung zum Cluster"
        exit 1
    fi
    
    log_success "Voraussetzungen erfüllt"
}

check_metallb() {
    log_info "Prüfe MetallB..."
    
    if ! kubectl --kubeconfig="$KUBECONFIG" get namespace metallb-system &> /dev/null; then
        log_error "MetallB Namespace nicht gefunden!"
        echo "Bitte installiere MetallB zuerst:"
        echo "  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml"
        exit 1
    fi
    
    log_success "MetallB gefunden"
}

check_storage() {
    log_info "Prüfe StorageClass..."
    
    local storage_class="local-path"
    if ! kubectl --kubeconfig="$KUBECONFIG" get storageclass "$storage_class" &> /dev/null; then
        log_warning "StorageClass '$storage_class' nicht gefunden"
        echo "Verfügbare StorageClasses:"
        kubectl --kubeconfig="$KUBECONFIG" get storageclass
        echo ""
        echo "Bitte bearbeite k8s/pihole/pvc.yaml und ändere 'storageClassName'"
        read -p "Fortfahren? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        log_success "StorageClass '$storage_class' gefunden"
    fi
}

deploy_pihole() {
    log_info "Deploye Pi-hole..."
    
    # 1. Namespace erstellen
    log_info "Erstelle Namespace..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/namespace.yaml"
    
    # 2. MetallB IP-Pool erweitern (falls nötig)
    log_info "Prüfe MetallB IP-Pool..."
    if kubectl --kubeconfig="$KUBECONFIG" get ipaddresspool pihole-pool -n metallb-system &> /dev/null; then
        log_info "IP-Pool 'pihole-pool' existiert bereits"
    else
        log_info "Erstelle IP-Pool für 192.168.178.10..."
        kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/metallb-pool.yaml"
    fi
    
    # 3. ConfigMap erstellen
    log_info "Erstelle ConfigMap..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/configmap.yaml"
    
    # 4. Secret erstellen
    log_info "Erstelle Secret..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/secret.yaml"
    
    # 5. PersistentVolumeClaim erstellen
    log_info "Erstelle PersistentVolumeClaim..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/pvc.yaml"
    
    # 6. Deployment erstellen
    log_info "Erstelle Deployment..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/deployment.yaml"
    
    # 7. Service erstellen
    log_info "Erstelle Service..."
    kubectl --kubeconfig="$KUBECONFIG" apply -f "$K8S_DIR/service.yaml"
    
    log_success "Pi-hole Deployment abgeschlossen"
}

wait_for_pihole() {
    log_info "Warte auf Pi-hole Pod..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if kubectl --kubeconfig="$KUBECONFIG" get pod -n pihole -l app=pihole -o jsonpath='{.items[0].status.phase}' 2>/dev/null | grep -q "Running"; then
            log_success "Pi-hole Pod läuft!"
            return 0
        fi
        
        attempt=$((attempt + 1))
        echo -n "."
        sleep 2
    done
    
    echo ""
    log_warning "Pi-hole Pod startet noch nicht. Prüfe Logs:"
    echo "  kubectl logs -n pihole -l app=pihole"
    return 1
}

verify_deployment() {
    log_info "Verifiziere Deployment..."
    
    # Pod-Status
    echo ""
    echo "Pod-Status:"
    kubectl --kubeconfig="$KUBECONFIG" get pods -n pihole
    
    # Service-Status
    echo ""
    echo "Service-Status:"
    kubectl --kubeconfig="$KUBECONFIG" get svc -n pihole
    
    # IP-Adresse prüfen
    echo ""
    local service_ip=$(kubectl --kubeconfig="$KUBECONFIG" get svc pihole -n pihole -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
    if [ -n "$service_ip" ]; then
        log_success "Service IP: $service_ip"
        
        # DNS-Test
        echo ""
        log_info "Teste DNS-Auflösung..."
        if command -v dig &> /dev/null; then
            if dig @$service_ip google.de +short +timeout=2 &> /dev/null; then
                log_success "DNS-Auflösung funktioniert!"
            else
                log_warning "DNS-Auflösung schlägt fehl. Prüfe Pod-Logs."
            fi
        else
            log_warning "dig nicht gefunden. DNS-Test übersprungen."
        fi
    else
        log_warning "Service hat noch keine IP. Warte auf MetallB..."
    fi
}

main() {
    echo "=========================================="
    echo "Pi-hole Kubernetes Deployment"
    echo "=========================================="
    echo ""
    
    check_prerequisites
    check_metallb
    check_storage
    
    echo ""
    deploy_pihole
    
    echo ""
    wait_for_pihole
    
    echo ""
    verify_deployment
    
    echo ""
    log_success "Deployment abgeschlossen!"
    echo ""
    echo "Nächste Schritte:"
    echo "  1. Fritzbox DNS-Server auf 192.168.178.10 ändern"
    echo "  2. CoreDNS Upstream auf 192.168.178.10 ändern"
    echo "  3. Custom DNS Records für *.k8sops.online hinzufügen"
    echo ""
    echo "Pi-hole Webinterface: http://192.168.178.10/admin"
}

main "$@"

