#!/bin/bash

echo "[+] Installing system dependencies..."

sudo apt update
sudo apt install -y suricata sqlite3 jq tcpdump nmap python3 python3-venv python3-pip git

echo "[+] Dependencies installed."
