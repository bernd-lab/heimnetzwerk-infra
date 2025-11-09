# Task: Pi-hole DNS-Reparatur und Systemoptimierung

**Datum**: 2025-11-07  
**Priorität**: HOCH  
**Status**: ⚠️ In Bearbeitung - NodePort funktioniert, LoadBalancer-Problem identifiziert

## Problem

DNS-Abfragen an Pi-hole (192.168.178.10) schlagen fehl trotz korrekter Konfiguration:
- Pi-hole läuft (1/1 Running)
- `listeningMode = "ALL"` ist gesetzt ✅
- DNSmasq ConfigMap korrekt ✅
- Service hat LoadBalancer IP ✅
- Aber: DNS-Abfragen schlagen fehl (timeout)

## Aufgaben

### 1. DNS-Problem analysieren und beheben
**Delegiert an**: `/dns-expert` + `/k8s-expert`

**Aufgabe**:
- Prüfe warum DNS-Abfragen fehlschlagen trotz korrekter Konfiguration
- Teste `externalTrafficPolicy: Local` - könnte Problem sein
- Prüfe MetalLB ARP-Announcements
- Teste Netzwerk-Routing
- Prüfe Firewall-Regeln
- Implementiere Lösung für Anfragen aus nicht-Kubernetes-Netzen

**Erwartetes Ergebnis**:
- DNS-Abfragen funktionieren von allen Clients
- Keine Timeouts mehr
- Pi-hole antwortet auf Anfragen aus Heimnetz (192.168.178.0/24)

### 2. Systemauslastung optimieren
**Delegiert an**: `/k8s-expert` + `/monitoring-expert`

**Aufgabe**:
- Analysiere aktuelle Ressourcen-Auslastung
- Identifiziere Optimierungsmöglichkeiten
- Prüfe CPU/Memory Requests/Limits
- Optimiere Ressourcen-Verteilung

**Aktuelle Auslastung**:
- CPU Requests: 2151m / 4000m (53%)
- Memory Requests: 2055Mi / ~32GB (6%)
- Load Average: 1.80, 2.60, 1.49

**Erwartetes Ergebnis**:
- Optimierte Ressourcen-Verteilung
- Bessere Performance
- Dokumentation der Optimierungen

## Wichtige Informationen

- Pi-hole Pod IP: 10.244.0.93
- Service IP: 192.168.178.10
- ConfigMap: `pihole-dnsmasq-custom` mit korrekter Konfiguration
- pihole.toml: `listeningMode = "ALL"` gesetzt

