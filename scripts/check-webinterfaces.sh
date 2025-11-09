#!/bin/bash

# Webinterfaces Health-Check Script
# Prüft alle Webinterfaces auf Erreichbarkeit und Status
# Erstellt: 2025-11-09

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log-Datei
LOG_FILE="${LOG_FILE:-/tmp/webinterfaces-check-$(date +%Y%m%d-%H%M%S).log}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Funktionen
log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
    log "SUCCESS: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
    log "WARNING: $1"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    log "ERROR: $1"
}

# Webinterface-Definitionen
declare -A WEBINTERFACES=(
    # URL:Name:Namespace:ExpectedStatus:RequiresAuth:Description
    ["https://argocd.k8sops.online"]="ArgoCD:argocd:200:true:GitOps Platform"
    ["https://gitlab.k8sops.online"]="GitLab:gitlab:200:true:Git Repository"
    ["https://grafana.k8sops.online"]="Grafana:monitoring:200:true:Monitoring Dashboard"
    ["https://pihole.k8sops.online/admin/"]="Pi-hole:pihole:200:true:DNS & Ad-Blocking"
    ["https://jellyfin.k8sops.online"]="Jellyfin:default:200:true:Media Server"
    ["https://komga.k8sops.online"]="Komga:komga:200:true:Comic Server"
    ["https://syncthing.k8sops.online"]="Syncthing:syncthing:200:false:File Sync"
    ["https://dashboard.k8sops.online"]="Kubernetes Dashboard:kubernetes-dashboard:200:true:Cluster Dashboard"
    ["https://heimdall.k8sops.online"]="Heimdall:heimdall:200:false:Dashboard"
    ["https://plantuml.k8sops.online"]="PlantUML:default:200:false:Diagram Generator"
    ["https://prometheus.k8sops.online"]="Prometheus:monitoring:200:false:Metrics"
    ["https://jenkins.k8sops.online"]="Jenkins:default:503:false:CI/CD (deaktiviert)"
    ["https://loki.k8sops.online"]="Loki:logging:404:false:Log Aggregator (kein Web-UI)"
)

# Zugangsdaten (aus webinterfaces-zugangsdaten-2025-11-08.md)
declare -A CREDENTIALS=(
    ["argocd"]="admin:Admin123!"
    ["gitlab"]="root:BXE1uwajqBDLgsWiesGB1081"
    ["grafana"]="admin:Montag69"
    ["pihole"]="admin:cK1lubq8C7MZrEgipfUpEAc0"
    ["jellyfin"]="bernd:Montag69"
    ["komga"]="admin@k8sops.online:1zBlOIBqlGTHxb15GnGqyPOi"
)

# Statistik
TOTAL=0
SUCCESS=0
WARNING=0
ERROR=0

# Test-Funktion
test_webinterface() {
    local url=$1
    local name=$(echo "$2" | cut -d':' -f1)
    local namespace=$(echo "$2" | cut -d':' -f2)
    local expected_status=$(echo "$2" | cut -d':' -f3)
    local requires_auth=$(echo "$2" | cut -d':' -f4)
    local description=$(echo "$2" | cut -d':' -f5)
    
    TOTAL=$((TOTAL + 1))
    
    echo ""
    echo -e "${BLUE}Testing: $name${NC}"
    echo "  URL: $url"
    echo "  Namespace: $namespace"
    echo "  Description: $description"
    
    # Prüfe Pod-Status
    local pod_status=$(kubectl get pods -n "$namespace" -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "UNKNOWN")
    if [ "$pod_status" != "Running" ] && [ "$pod_status" != "UNKNOWN" ]; then
        print_warning "Pod Status: $pod_status (nicht Running)"
        WARNING=$((WARNING + 1))
    else
        echo "  Pod Status: $pod_status"
    fi
    
    # HTTP-Test
    local http_code=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 10 --connect-timeout 5 "$url" 2>/dev/null || echo "000")
    local curl_exit=$?
    
    if [ $curl_exit -ne 0 ] || [ "$http_code" == "000" ]; then
        print_error "HTTP Request failed (exit code: $curl_exit, HTTP: $http_code)"
        ERROR=$((ERROR + 1))
        return 1
    fi
    
    if [ "$http_code" == "$expected_status" ]; then
        print_success "HTTP Status: $http_code (erwartet: $expected_status)"
        SUCCESS=$((SUCCESS + 1))
    elif [ "$expected_status" == "503" ] && [ "$http_code" == "503" ]; then
        print_warning "HTTP Status: $http_code (erwartet für deaktivierten Service)"
        WARNING=$((WARNING + 1))
    elif [ "$expected_status" == "404" ] && [ "$http_code" == "404" ]; then
        print_warning "HTTP Status: $http_code (erwartet, kein Web-UI)"
        WARNING=$((WARNING + 1))
    else
        print_error "HTTP Status: $http_code (erwartet: $expected_status)"
        ERROR=$((ERROR + 1))
    fi
    
    # SSL-Zertifikat prüfen (nur für HTTPS)
    if [[ "$url" == https://* ]]; then
        local cert_info=$(echo | openssl s_client -servername "$(echo "$url" | sed 's|https://||' | cut -d'/' -f1)" -connect "$(echo "$url" | sed 's|https://||' | cut -d'/' -f1):443" 2>/dev/null | openssl x509 -noout -dates 2>/dev/null || echo "")
        if [ -n "$cert_info" ]; then
            local cert_expiry=$(echo "$cert_info" | grep "notAfter" | cut -d= -f2)
            echo "  SSL Certificate: Gültig bis $cert_expiry"
        else
            print_warning "SSL-Zertifikat konnte nicht geprüft werden"
        fi
    fi
    
    # Auth-Test (optional, wenn requires_auth=true)
    if [ "$requires_auth" == "true" ] && [ -n "${CREDENTIALS[$namespace]:-}" ]; then
        local creds="${CREDENTIALS[$namespace]}"
        local username=$(echo "$creds" | cut -d':' -f1)
        local password=$(echo "$creds" | cut -d':' -f2)
        
        # Einfacher Auth-Test (nur für einige Services)
        if [ "$namespace" == "pihole" ]; then
            local auth_test=$(curl -k -s -o /dev/null -w "%{http_code}" --max-time 5 -u "$username:$password" "$url" 2>/dev/null || echo "000")
            if [ "$auth_test" == "200" ] || [ "$auth_test" == "401" ] || [ "$auth_test" == "302" ]; then
                echo "  Auth-Test: OK (Status: $auth_test)"
            else
                print_warning "Auth-Test: Unerwarteter Status ($auth_test)"
            fi
        fi
    fi
    
    return 0
}

# Hauptfunktion
main() {
    print_header "Webinterfaces Health-Check"
    log "Starting webinterfaces health check..."
    
    # Prüfe kubectl-Zugriff
    if ! kubectl cluster-info &>/dev/null; then
        print_error "kubectl ist nicht verfügbar oder Cluster nicht erreichbar"
        exit 1
    fi
    
    print_success "Kubernetes Cluster erreichbar"
    
    # Teste alle Webinterfaces
    for url in "${!WEBINTERFACES[@]}"; do
        test_webinterface "$url" "${WEBINTERFACES[$url]}"
    done
    
    # Zusammenfassung
    print_header "Zusammenfassung"
    echo ""
    echo "Gesamt getestet: $TOTAL"
    echo -e "${GREEN}Erfolgreich: $SUCCESS${NC}"
    echo -e "${YELLOW}Warnungen: $WARNING${NC}"
    echo -e "${RED}Fehler: $ERROR${NC}"
    echo ""
    echo "Log-Datei: $LOG_FILE"
    
    # Exit-Code basierend auf Ergebnissen
    if [ $ERROR -gt 0 ]; then
        exit 1
    elif [ $WARNING -gt 0 ]; then
        exit 2
    else
        exit 0
    fi
}

# Script ausführen
main "$@"

