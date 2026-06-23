#!/bin/bash

INTERFACE="lo"

echo "[+] Starting Suricata..."

echo "[+] Checking database..."
./init_db.sh

sudo pkill suricata 2>/dev/null

sudo suricata -i "$INTERFACE" -c /etc/suricata/suricata.yaml -k none &

sleep 2

echo "[+] Starting alert parser..."

./ids_monitor.sh &

echo ""
echo "Press Ctrl+C to stop."

trap './stop_ids.sh; exit' INT

wait