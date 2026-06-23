#!/bin/bash

LOG="/var/log/suricata/eve.json"
DB="../database/ids_alerts.db"

mkdir -p logss

echo "[+] Network IDS Alert Parser started"
echo "[+] Watching $LOG"
echo "[+] Saving alerts to $DB"
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

        if [ "$SEVERITY" = "1" ]; then
            SEV_TEXT="HIGH"
        elif [ "$SEVERITY" = "2" ]; then
            SEV_TEXT="MEDIUM"
        elif [ "$SEVERITY" = "3" ]; then
            SEV_TEXT="LOW"
        else
            SEV_TEXT="INFO"
        fi

        echo "[!] ALERT: $SIGNATURE"
        echo "    Time: $TIMESTAMP"
        echo "    Flow: $SRC_IP:$SRC_PORT -> $DEST_IP:$DEST_PORT"
        echo "    Protocol: $PROTO | Severity: $SEV_TEXT"
        echo "----------------------------------------"

        sqlite3 "$DB" "INSERT INTO alerts(timestamp, src_ip, src_port, dest_ip, dest_port, protocol, signature, severity_level, severity_text)
        VALUES('$TIMESTAMP', '$SRC_IP', '$SRC_PORT', '$DEST_IP', '$DEST_PORT', '$PROTO', '$SIGNATURE', '$SEVERITY', '$SEV_TEXT');"

        sqlite3 "$DB" "INSERT INTO devices(ip, first_seen, last_seen, alert_count, high_count, medium_count, low_count, info_count, risk_score)
        VALUES(
        '$SRC_IP',
        '$TIMESTAMP',
        '$TIMESTAMP',
        1,
        CASE WHEN '$SEV_TEXT'='HIGH' THEN 1 ELSE 0 END,
        CASE WHEN '$SEV_TEXT'='MEDIUM' THEN 1 ELSE 0 END,
        CASE WHEN '$SEV_TEXT'='LOW' THEN 1 ELSE 0 END,
        CASE WHEN '$SEV_TEXT'='INFO' THEN 1 ELSE 0 END,
        $RISK_POINTS)

        ON CONFLICT(ip) DO UPDATE SET
        last_seen='$TIMESTAMP',
        alert_count=alert_count+1,
        high_count=high_count+CASE WHEN '$SEV_TEXT'='HIGH' THEN 1 ELSE 0 END,
        medium_count=medium_count+CASE WHEN '$SEV_TEXT'='MEDIUM' THEN 1 ELSE 0 END,
        low_count=low_count+CASE WHEN '$SEV_TEXT'='LOW' THEN 1 ELSE 0 END,
        info_count=info_count+CASE WHEN '$SEV_TEXT'='INFO' THEN 1 ELSE 0 END,
        risk_score=risk_score+$RISK_POINTS;"
    fi
done
