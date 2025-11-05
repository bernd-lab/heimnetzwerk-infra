#!/usr/bin/env python3
"""
Heimdall Apps Setup Script
Fügt automatisch alle bekannten Webinterfaces zum Heimdall-Dashboard hinzu.
"""

import sqlite3
import sys
import os
from typing import List, Dict, Optional

# App-Definitionen für alle bekannten Webinterfaces
APPS = [
    {
        "name": "ArgoCD",
        "url": "https://argocd.k8sops.online",
        "type": "application",
        "appid": "argocd",
        "color": "#EF4444",
        "tags": "GitOps",
        "pinned": 1,
    },
    {
        "name": "Jellyfin",
        "url": "https://jellyfin.k8sops.online",
        "type": "application",
        "appid": "jellyfin",
        "color": "#AA5CC3",
        "tags": "Media",
        "pinned": 1,
    },
    {
        "name": "Jenkins",
        "url": "https://jenkins.k8sops.online",
        "type": "application",
        "appid": "jenkins",
        "color": "#D24939",
        "tags": "Development",
        "pinned": 1,
    },
    {
        "name": "PlantUML",
        "url": "https://plantuml.k8sops.online",
        "type": "bookmark",
        "appid": None,
        "color": "#10B981",
        "tags": "Development",
        "pinned": 0,
    },
    {
        "name": "GitLab",
        "url": "https://gitlab.k8sops.online",
        "type": "application",
        "appid": "gitlab",
        "color": "#FC6D26",
        "tags": "Development",
        "pinned": 1,
    },
    {
        "name": "Komga",
        "url": "https://komga.k8sops.online",
        "type": "application",
        "appid": "komga",
        "color": "#3B82F6",
        "tags": "Media",
        "pinned": 0,
    },
    {
        "name": "Loki",
        "url": "https://loki.k8sops.online",
        "type": "application",
        "appid": "loki",
        "color": "#8B5CF6",
        "tags": "Monitoring",
        "pinned": 0,
    },
    {
        "name": "Grafana",
        "url": "https://grafana.k8sops.online",
        "type": "application",
        "appid": "grafana",
        "color": "#F46800",
        "tags": "Monitoring",
        "pinned": 1,
    },
    {
        "name": "Prometheus",
        "url": "https://prometheus.k8sops.online",
        "type": "application",
        "appid": "prometheus",
        "color": "#E6522C",
        "tags": "Monitoring",
        "pinned": 1,
    },
    {
        "name": "Syncthing",
        "url": "https://syncthing.k8sops.online",
        "type": "application",
        "appid": "syncthing",
        "color": "#3B82F6",
        "tags": "Tools",
        "pinned": 0,
    },
    {
        "name": "Kubernetes Dashboard",
        "url": "https://dashboard.k8sops.online",
        "type": "application",
        "appid": "kubernetes",
        "color": "#326CE5",
        "tags": "Monitoring",
        "pinned": 1,
    },
]


def analyze_database(db_path: str) -> Dict:
    """Analysiere die Heimdall-Datenbankstruktur"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Tabellen auflisten
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = [row[0] for row in cursor.fetchall()]
    print(f"Gefundene Tabellen: {tables}")
    
    # Schema der items-Tabelle prüfen
    cursor.execute("PRAGMA table_info(items);")
    columns = cursor.fetchall()
    print(f"\nItems-Tabelle Spalten:")
    for col in columns:
        print(f"  - {col[1]} ({col[2]})")
    
    # Vorhandene Apps auflisten
    cursor.execute("SELECT id, title, url, type FROM items WHERE deleted_at IS NULL;")
    existing_apps = cursor.fetchall()
    print(f"\nVorhandene Apps ({len(existing_apps)}):")
    for app in existing_apps:
        print(f"  - {app[1]} (type={app[3]}) - {app[2]}")
    
    conn.close()
    
    return {
        "tables": tables,
        "columns": columns,
        "existing_apps": existing_apps,
    }


def get_max_id(db_path: str) -> int:
    """Ermittle die maximale ID in der items-Tabelle"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT MAX(id) FROM items;")
    result = cursor.fetchone()
    conn.close()
    return result[0] if result[0] else 0


def app_exists(db_path: str, url: str) -> bool:
    """Prüfe ob eine App mit dieser URL bereits existiert"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM items WHERE url = ? AND deleted_at IS NULL;", (url,))
    count = cursor.fetchone()[0]
    conn.close()
    return count > 0


def add_app(db_path: str, app: Dict, next_id: int) -> bool:
    """Füge eine App zur Datenbank hinzu"""
    if app_exists(db_path, app["url"]):
        print(f"⚠️  App bereits vorhanden: {app['name']} ({app['url']})")
        return False
    
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Prüfe alle verfügbaren Spalten
    cursor.execute("PRAGMA table_info(items);")
    columns = [col[1] for col in cursor.fetchall()]
    
    # Bestimme den type-Wert (0 = bookmark, 1 = application)
    type_value = 1 if app["type"] == "application" else 0
    
    # Basis-Felder für INSERT
    fields = ["id", "title", "url", "type", "pinned", "deleted_at", "created_at", "updated_at", "user_id"]
    placeholders = ["?", "?", "?", "?", "?", "?", "CURRENT_TIMESTAMP", "CURRENT_TIMESTAMP", "?"]
    values = [
        next_id,
        app["name"],
        app["url"],
        type_value,
        app.get("pinned", 0),
        None,  # deleted_at
        1,  # user_id (default user)
    ]
    
    # Optionale Felder hinzufügen
    if "colour" in columns and app.get("color"):
        fields.append("colour")
        placeholders.append("?")
        values.append(app["color"])
    
    if "appid" in columns and app.get("appid"):
        fields.append("appid")
        placeholders.append("?")
        values.append(app["appid"])
    
    if "class" in columns:
        fields.append("class")
        placeholders.append("?")
        # Class für application type
        class_value = app.get("appid", "") if app["type"] == "application" else ""
        values.append(class_value)
    
    # SQL-Statement zusammenstellen
    sql = f"""INSERT INTO items ({', '.join(fields)}) 
              VALUES ({', '.join(placeholders)});"""
    
    try:
        cursor.execute(sql, values)
        conn.commit()
        print(f"✅ App hinzugefügt: {app['name']} ({app['url']})")
        conn.close()
        return True
    except sqlite3.Error as e:
        print(f"❌ Fehler beim Hinzufügen von {app['name']}: {e}")
        print(f"   SQL: {sql}")
        print(f"   Values: {values}")
        conn.rollback()
        conn.close()
        return False


def main():
    # Datenbank-Pfad bestimmen
    if len(sys.argv) > 1:
        db_path = sys.argv[1]
    else:
        # Standard-Pfad (kopierte Datenbank)
        db_path = "/tmp/heimdall-app.sqlite"
        if not os.path.exists(db_path):
            # Versuche original Pfad im Pod
            db_path = "/config/www/app.sqlite"
    
    if not os.path.exists(db_path):
        print(f"❌ Datenbank nicht gefunden: {db_path}")
        print("Verwendung: python3 setup-heimdall-apps.py [db_path]")
        sys.exit(1)
    
    print(f"📊 Analysiere Datenbank: {db_path}\n")
    
    # Datenbank analysieren
    db_info = analyze_database(db_path)
    
    print(f"\n📝 Füge {len(APPS)} Apps hinzu...\n")
    
    # Maximale ID ermitteln
    max_id = get_max_id(db_path)
    next_id = max_id + 1
    
    # Apps hinzufügen
    added_count = 0
    skipped_count = 0
    
    for app in APPS:
        if add_app(db_path, app, next_id):
            added_count += 1
            next_id += 1
        else:
            skipped_count += 1
    
    print(f"\n✅ Fertig! {added_count} Apps hinzugefügt, {skipped_count} übersprungen.")
    
    # Finale Übersicht
    print("\n📋 Finale App-Liste:")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("SELECT title, url, type FROM items WHERE deleted_at IS NULL ORDER BY pinned DESC, title;")
    all_apps = cursor.fetchall()
    for app in all_apps:
        app_type = "application" if app[2] == 1 else "bookmark"
        print(f"  - {app[0]} ({app_type}) - {app[1]}")
    conn.close()


if __name__ == "__main__":
    main()

