#!/bin/bash

DB="../database/ids_alerts.db"

if [ ! -f "$DB" ]; then
    echo "Database not found: $DB"
    exit 1
fi

echo "Network IDS Report"
echo "Generated: $(date)"
echo "======================================"
echo ""

echo "Total Alerts:"
sqlite3 "$DB" "SELECT COUNT(*) FROM alerts;"
echo ""

echo "Alerts by Severity:"
sqlite3 -header -column "$DB" "
SELECT severity_text, COUNT(*) AS count
FROM alerts
GROUP BY severity_text
ORDER BY count DESC;
"
echo ""

echo "Top Alert Signatures:"
sqlite3 -header -column "$DB" "
SELECT signature, COUNT(*) AS count
FROM alerts
GROUP BY signature
ORDER BY count DESC
LIMIT 10;
"
echo ""

echo "Top Source IPs:"
sqlite3 -header -column "$DB" "
SELECT src_ip, COUNT(*) AS count
FROM alerts
GROUP BY src_ip
ORDER BY count DESC
LIMIT 10;
"
echo ""

echo "Top Destination Ports:"
sqlite3 -header -column "$DB" "
SELECT dest_port, COUNT(*) AS count
FROM alerts
GROUP BY dest_port
ORDER BY count DESC
LIMIT 10;
"