#!/bin/bash

DB="../database/ids_alerts.db"

mkdir -p ../database

echo "[+] Initializing database..."

sqlite3 "$DB" "

CREATE TABLE IF NOT EXISTS alerts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TEXT,
    src_ip TEXT,
    src_port TEXT,
    dest_ip TEXT,
    dest_port TEXT,
    protocol TEXT,
    signature TEXT,
    severity_level INTEGER,
    severity_text TEXT
);

CREATE TABLE IF NOT EXISTS devices (
    ip TEXT PRIMARY KEY,
    first_seen TEXT,
    last_seen TEXT,
    alert_count INTEGER DEFAULT 0,
    high_count INTEGER DEFAULT 0,
    medium_count INTEGER DEFAULT 0,
    low_count INTEGER DEFAULT 0,
    info_count INTEGER DEFAULT 0,
    risk_score INTEGER DEFAULT 0
);

"

echo "[+] Database ready."