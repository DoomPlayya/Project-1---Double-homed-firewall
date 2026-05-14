#!/bin/bash

INVENTORY="${ANSIBLE_INVENTORY:-/vagrant/ansible/inventory.ini}"
WEB_IP="${WEB_IP:-10.0.3.2}"
DB_IP="${DB_IP:-10.0.3.2}"
DB_PORT="${DB_PORT:-5432}"

echo "--- STARTAR VERIFIERING AV LABB ---"

echo "[1/3] Testar kontakt med Webbservern på ${WEB_IP}..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${WEB_IP}/health")
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "OK: Webbserver svarar (200 OK)!"
else
    echo "FEL: Webbserver kunde inte nås (Status: $HTTP_STATUS)!"
fi

echo "[2/3] Testar kontakt med Databasen på ${DB_IP}:${DB_PORT}..."
if nc -zv "$DB_IP" "$DB_PORT" -w 2 > /dev/null 2>&1; then
    echo "OK: Databasporten är öppen!"
else
    echo "FEL: Kan inte nå databasen!"
fi

echo "[3/3] Kontrollerar att Flask-tjänsten körs..."
if ansible all -i "$INVENTORY" -m shell -a "systemctl is-active flask" --limit webserver 2>/dev/null | grep -q "active"; then
    echo "OK: Flask-tjänsten är aktiv!"
else
    echo "FEL: Flask-tjänsten är nere!"
fi

echo "--- VERIFIERING KLAR ---"