#!/bin/bash
echo "--- STARTAR VERIFIERING AV LABB ---"

echo "[1/3] Testar kontakt med Webbservern (Nginx)..."
curl -s -o /dev/null -w "%{http_code}" http://10.0.3.2/health | grep 200 > /dev/null
if [ $? -eq 0 ]; then echo "OK: Webbserver svarar!"; else echo "FEL: Webbserver kan inte nås!"; fi

echo "[2/3] Testar kontakt med Databasen från Brandväggen..."
nc -zv 10.0.3.2 5432 -w 2 > /dev/null 2>&1
if [ $? -eq 0 ]; then echo "OK: Databasporten är öppen!"; else echo "FEL: Kan inte nå databasen!"; fi

echo "[3/3] Kontrollerar att Flask-tjänsten körs..."
ansible all -i ansible/inventory.ini -m shell -a "systemctl is-active flask" --limit flask | grep "active" > /dev/null
if [ $? -eq 0 ]; then echo "OK: Flask-tjänsten är aktiv!"; else echo "FEL: Flask-tjänsten är nere!"; fi

echo "--- VERIFIERING KLAR ---"