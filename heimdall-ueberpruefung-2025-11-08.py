#!/usr/bin/env python3
"""
Heimdall Überprüfung und Korrektur
Prüft alle Links und fügt fehlende Apps hinzu.
"""

import sqlite3
import sys

DB_PATH = "/tmp/heimdall-app.sqlite"

# Erwartete Apps mit korrekten URLs
EXPECTED_APPS = [
    {"name": "ArgoCD", "url": "https://argocd.k8sops.online", "type": "application", "appid": "argocd", "pinned": 1},
    {"name": "Jellyfin", "url": "https://jellyfin.k8sops.online", "type": "application", "appid": "jellyfin", "pinned": 1},
    {"name": "Jenkins", "url": "https://jenkins.k8sops.online", "type": "application", "appid": "jenkins", "pinned": 1},
    {"name": "GitLab", "url": "https://gitlab.k8sops.online", "type": "application", "appid": "gitlab", "pinned": 1},
    {"name": "Komga", "url": "https://komga.k8sops.online", "type": "application", "appid": "komga", "pinned": 0},
    {"name": "Loki", "url": "https://loki.k8sops.online", "type": "application", "appid": "loki", "pinned": 0},
    {"name": "Grafana", "url": "https://grafana.k8sops.online", "type": "application", "appid": "grafana", "pinned": 1},
    {"name": "Prometheus", "url": "https://prometheus.k8sops.online", "type": "application", "appid": "prometheus", "pinned": 1},
    {"name": "Syncthing", "url": "https://syncthing.k8sops.online", "type": "application", "appid": "syncthing", "pinned": 0},
    {"name": "Kubernetes Dashboard", "url": "https://dashboard.k8sops.online", "type": "application", "appid": "kubernetes", "pinned": 1},
    {"name": "PlantUML", "url": "https://plantuml.k8sops.online", "type": "bookmark", "appid": None, "pinned": 0},
    {"name": "Pi-hole", "url": "https://pihole.k8sops.online/admin/", "type": "application", "appid": "pihole", "pinned": 1},
]

def get_existing_apps(conn):
    """Hole alle vorhandenen Apps"""
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, url, type, pinned FROM items WHERE deleted_at IS NULL")
    return cursor.fetchall()

def find_app_by_url(conn, url):
    """Finde App anhand URL"""
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, url FROM items WHERE url = ? AND deleted_at IS NULL", (url,))
    return cursor.fetchone()

def fix_broken_links(conn):
    """Korrigiere fehlerhafte Links"""
    cursor = conn.cursor()
    fixed = 0
    
    # Links mit /tag/ korrigieren
    cursor.execute("SELECT id, title, url FROM items WHERE url LIKE '%/tag/%' AND deleted_at IS NULL")
    broken = cursor.fetchall()
    
    for app_id, title, url in broken:
        # Entferne /tag/ Präfix
        new_url = url.replace('/tag/https://', 'https://').replace('/tag/http://', 'http://')
        cursor.execute("UPDATE items SET url = ? WHERE id = ?", (new_url, app_id))
        print(f"✅ Link korrigiert: {title} -> {new_url}")
        fixed += 1
    
    conn.commit()
    return fixed

def add_missing_apps(conn):
    """Füge fehlende Apps hinzu"""
    cursor = conn.cursor()
    added = 0
    
    # Maximale ID finden
    cursor.execute("SELECT MAX(id) FROM items")
    max_id = cursor.fetchone()[0] or 0
    next_id = max_id + 1
    
    for app in EXPECTED_APPS:
        # Prüfe ob App bereits existiert
        existing = find_app_by_url(conn, app["url"])
        if existing:
            # Prüfe ob Name oder URL geändert werden muss
            if existing[1] != app["name"]:
                cursor.execute("UPDATE items SET title = ? WHERE id = ?", (app["name"], existing[0]))
                print(f"✅ Name aktualisiert: {existing[1]} -> {app['name']}")
            continue
        
        # App hinzufügen
        type_value = 1 if app["type"] == "application" else 0
        cursor.execute("""
            INSERT INTO items (id, title, url, type, pinned, deleted_at, created_at, updated_at, user_id, appid, class)
            VALUES (?, ?, ?, ?, ?, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 1, ?, ?)
        """, (next_id, app["name"], app["url"], type_value, app["pinned"], app.get("appid"), app.get("appid", "")))
        print(f"✅ App hinzugefügt: {app['name']} ({app['url']})")
        added += 1
        next_id += 1
    
    conn.commit()
    return added

def remove_test_app(conn):
    """Entferne Test-App wenn vorhanden"""
    cursor = conn.cursor()
    cursor.execute("SELECT id, title FROM items WHERE url LIKE '%test.k8sops.online%' AND deleted_at IS NULL")
    test_apps = cursor.fetchall()
    
    if test_apps:
        for app_id, title in test_apps:
            cursor.execute("UPDATE items SET deleted_at = CURRENT_TIMESTAMP WHERE id = ?", (app_id,))
            print(f"✅ Test-App entfernt: {title}")
        conn.commit()
        return len(test_apps)
    return 0

def main():
    conn = sqlite3.connect(DB_PATH)
    
    print("🔍 Überprüfe Heimdall-Datenbank...\n")
    
    # Vorhandene Apps anzeigen
    existing = get_existing_apps(conn)
    print(f"Vorhandene Apps: {len(existing)}")
    for app in existing:
        print(f"  - {app[1]} ({app[2]})")
    
    print("\n🔧 Korrigiere fehlerhafte Links...")
    fixed = fix_broken_links(conn)
    print(f"  {fixed} Links korrigiert\n")
    
    print("➕ Füge fehlende Apps hinzu...")
    added = add_missing_apps(conn)
    print(f"  {added} Apps hinzugefügt\n")
    
    print("🗑️  Entferne Test-Apps...")
    removed = remove_test_app(conn)
    print(f"  {removed} Test-Apps entfernt\n")
    
    # Finale Übersicht
    final = get_existing_apps(conn)
    print(f"📊 Finale App-Liste ({len(final)} Apps):")
    for app in sorted(final, key=lambda x: (-x[4], x[1])):  # Sortiert nach pinned, dann name
        pinned = "📌" if app[4] else "  "
        print(f"  {pinned} {app[1]} - {app[2]}")
    
    conn.close()
    print("\n✅ Überprüfung abgeschlossen!")

if __name__ == "__main__":
    main()

