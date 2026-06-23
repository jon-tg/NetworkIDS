#!/bin/bash

sudo pkill suricata
pkill -f ids_monitor.sh

echo "[+] IDS stopped."