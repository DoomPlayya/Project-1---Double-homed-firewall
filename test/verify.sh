#!/bin/bash

INVENTORY="${ANSIBLE_INVENTORY:-/vagrant/ansible/inventory.ini}"
WEB_IP="${WEB_IP:-10.0.5.2}"
DB_IP="${DB_IP:-10.0.3.2}"
DB_PORT="${DB_PORT:-5432}"
DOMAIN="minhemsida.test"

echo "--- STARTAR VERIFIERING AV LABB ---"

echo "[1/4] Testar kontakt med Webbservern på ${WEB_IP}..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${WEB_IP}/")
if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "OK: Webbserver svarar (200 OK)!"
else
    echo "FEL: Webbserver kunde inte nås (Status: $HTTP_STATUS)!"
fi

echo "[2/4] Kontrollerar domän: ${DOMAIN}..."
HTTP_DOM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://${DOMAIN}/")
if [ "$HTTP_DOM_STATUS" -eq 200 ]; then
    echo "OK: HTTP://${DOMAIN} fungerar!"
else
    echo "FEL: HTTP://${DOMAIN} misslyckades (Status: $HTTP_DOM_STATUS)!"
fi

HTTPS_DOM_STATUS=$(curl -s -k -o /dev/null -w "%{http_code}" "https://${DOMAIN}/")
if [ "$HTTPS_DOM_STATUS" -eq 200 ]; then
    echo "OK: HTTPS://${DOMAIN} fungerar (Insecure check)!"
else
    echo "FEL: HTTPS://${DOMAIN} misslyckades (Status: $HTTPS_DOM_STATUS)!"
fi

echo "[3/4] Testar kontakt med Databasen på ${DB_IP}:${DB_PORT}..."
if nc -zv "$DB_IP" "$DB_PORT" -w 2 > /dev/null 2>&1; then
    echo "OK: Databasporten är öppen!"
else
    echo "FEL: Kan inte nå databasen!"
fi

echo "[4/4] Kontrollerar att Flask-tjänsten körs..."
if ansible all -i "$INVENTORY" -m shell -a "systemctl is-active flask" --limit webserver 2>/dev/null | grep -q "active"; then
    echo "OK: Flask-tjänsten är aktiv!"
else
    echo "FEL: Flask-tjänsten är nere!"
fi

echo "--- VERIFIERING KLAR ---"