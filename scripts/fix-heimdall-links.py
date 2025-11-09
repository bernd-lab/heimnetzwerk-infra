#!/usr/bin/env python3
"""
Heimdall Links korrigieren
Korrigiert alle fehlerhaften Links in der Heimdall-Datenbank.
"""

import sqlite3
import sys
import os

# Erwartete korrekte URLs
CORRECT_URLS = {
    "ArgoCD": "https://argocd.k8sops.online",
    "Jellyfin": "https://jellyfin.k8sops.online",
    "Jenkins": "https://jenkins.k8sops.online",
    "PlantUML": "https://plantuml.k8sops.online",
    "GitLab": "https://gitlab.k8sops.online",
    "Komga": "https://komga.k8sops.online",
    "Loki": "https://loki.k8sops.online",
    "Grafana": "https://grafana.k8sops.online",
    "Prometheus": "https://prometheus.k8sops.online",
    "Syncthing": "https://syncthing.k8sops.online",
    "Kubernetes Dashboard": "https://dashboard.k8sops.online",
    "Pi-hole": "https://pihole.k8sops.online/admin/",
}

def fix_links(db_path: str):
    """Korrigiere alle Links in der Datenbank"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Alle Apps abrufen
    cursor.execute("SELECT id, title, url FROM items WHERE deleted_at IS NULL")
    apps = cursor.fetchall()
    
    fixed_count = 0
    errors = []
    
    for app_id, title, url in apps:
        if not url:
            continue
            
        # Prüfe auf doppelte Heimdall-URL
        if "heimdall.k8sops.online" in url and url.startswith("https://heimdall.k8sops.online/"):
            # Entferne die Heimdall-URL, behalte nur den Rest
            if url.startswith("https://heimdall.k8sops.online/https://"):
                fixed_url = url.replace("https://heimdall.k8sops.online/", "")
                print(f"🔧 Korrigiere {title}: {url} → {fixed_url}")
                try:
                    cursor.execute("UPDATE items SET url = ? WHERE id = ?", (fixed_url, app_id))
                    fixed_count += 1
                except sqlite3.Error as e:
                    errors.append(f"Fehler bei {title}: {e}")
            elif url.startswith("https://heimdall.k8sops.online/http://"):
                fixed_url = url.replace("https://heimdall.k8sops.online/", "")
                print(f"🔧 Korrigiere {title}: {url} → {fixed_url}")
                try:
                    cursor.execute("UPDATE items SET url = ? WHERE id = ?", (fixed_url, app_id))
                    fixed_count += 1
                except sqlite3.Error as e:
                    errors.append(f"Fehler bei {title}: {e}")
        
        # Prüfe ob URL korrigiert werden muss
        elif title in CORRECT_URLS:
            correct_url = CORRECT_URLS[title]
            if url != correct_url:
                print(f"🔧 Korrigiere {title}: {url} → {correct_url}")
                try:
                    cursor.execute("UPDATE items SET url = ? WHERE id = ?", (correct_url, app_id))
                    fixed_count += 1
                except sqlite3.Error as e:
                    errors.append(f"Fehler bei {title}: {e}")
        else:
            # Prüfe auf fehlerhafte /tag/ URLs
            if url.startswith("/tag/https://") or url.startswith("/tag/http://"):
                # Entferne /tag/ Präfix
                fixed_url = url.replace("/tag/https://", "https://").replace("/tag/http://", "http://")
                print(f"🔧 Korrigiere {title}: {url} → {fixed_url}")
                try:
                    cursor.execute("UPDATE items SET url = ? WHERE id = ?", (fixed_url, app_id))
                    fixed_count += 1
                except sqlite3.Error as e:
                    errors.append(f"Fehler bei {title}: {e}")
    
    conn.commit()
    conn.close()
    
    print(f"\n✅ {fixed_count} Links korrigiert")
    if errors:
        print(f"⚠️  {len(errors)} Fehler:")
        for error in errors:
            print(f"   {error}")
    
    return fixed_count, errors

def main():
    db_path = sys.argv[1] if len(sys.argv) > 1 else "/tmp/heimdall-app.sqlite"
    
    if not os.path.exists(db_path):
        print(f"❌ Datenbank nicht gefunden: {db_path}")
        sys.exit(1)
    
    print(f"📊 Korrigiere Links in: {db_path}\n")
    
    fixed_count, errors = fix_links(db_path)
    
    # Zeige finale Links
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT title, url FROM items WHERE deleted_at IS NULL ORDER BY pinned DESC, title")
    apps = cursor.fetchall()
    print("\n📋 Finale Links:")
    for title, url in apps:
        print(f"  - {title}: {url}")
    conn.close()

if __name__ == "__main__":
    main()
