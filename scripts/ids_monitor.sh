#!/bin/bash

LOG="/var/log/suricata/eve.json"
OUT="../logs/alerts.csv"

mkdir -p logs

if [ ! -f "$OUT" ]; then
    echo "timestamp,src_ip,src_port,dest_ip,dest_port,protocol,signature,severity" > "$OUT"
fi

echo "[+] Industrial IoT IDS Alert Parser started"
echo "[+] Watching $LOG"
echo "[+] Saving alerts to $OUT"
echo "----------------------------------------"

sudo tail -F "$LOG" | while read line; do
    EVENT_TYPE=$(echo "$line" | jq -r '.event_type // empty')

    if [ "$EVENT_TYPE" = "alert" ]; then
        TIMESTAMP=$(echo "$line" | jq -r '.timestamp')
        SRC_IP=$(echo "$line" | jq -r '.src_ip // "N/A"')
        SRC_PORT=$(echo "$line" | jq -r '.src_port // "N/A"')
        DEST_IP=$(echo "$line" | jq -r '.dest_ip // "N/A"')
        DEST_PORT=$(echo "$line" | jq -r '.dest_port // "N/A"')
        PROTO=$(echo "$line" | jq -r '.proto // "N/A"')
        SIGNATURE=$(echo "$line" | jq -r '.alert.signature // "N/A"')
        SEVERITY=$(echo "$line" | jq -r '.alert.severity // "N/A"')

        echo "[!] ALERT: $SIGNATURE"
        echo "    Time: $TIMESTAMP"
        echo "    Flow: $SRC_IP:$SRC_PORT -> $DEST_IP:$DEST_PORT"
        echo "    Protocol: $PROTO | Severity: $SEVERITY"
        echo "----------------------------------------"

        echo "\"$TIMESTAMP\",\"$SRC_IP\",\"$SRC_PORT\",\"$DEST_IP\",\"$DEST_PORT\",\"$PROTO\",\"$SIGNATURE\",\"$SEVERITY\"" >> "$OUT"
    fi
done
