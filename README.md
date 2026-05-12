# Projekt 1: Double-Homed Firewall Lab

> En automatiserad nätverksinfrastruktur som sätter upp en säker miljö med en brandvägg som gateway.

---

## Innehållsförteckning

- [Topologi](#topologi)
- [Miljöer och IP-adresser](#miljöer-och-ip-adresser)
- [Mappstruktur](#mappstruktur)
- [Komponenter](#komponenter)
- [Krav och förutsättningar](#krav-och-förutsättningar)
- [Kom igång](#kom-igång)
- [Secrets](#secrets)
- [Säkerhetsåtgärder](#säkerhetsåtgärder)
- [Säkerhetsanalys](#säkerhetsanalys)
- [Verifiering](#verifiering)
- [Designval och motivering](#designval-och-motivering)

---

## Topologi
![Projektets Topologi](docs/Topologi.png)

----

## Miljöer och IP-adresser

| VM | Roll | IP-adress | Port forwarding | Beskrivning |
|---|---|---|---|---|
| `firewall` | Brandvägg | Frontend: 10.0.1.1, DMZ: 10.0.5.1, Backend: 10.0.3.1 | `:80 → host:8080` | Tar emot trafik från hosten och skickar vidare till webservern |
| `client` | Användare | 10.0.1.2 | — | Host-datorn som testar systemet |
| `webserver` | Webbserver | 10.0.5.2 | — | Kör Nginx och visar hemsidan |
| `database` | Databas | 10.0.3.2 | — | Lagrar data, isolerad från internet |

---

## Mappstruktur

```

Project-1---Double-homed-firewall/
├── ansible/
│   ├── roles/
│   │   ├── client/          # Konfiguration för klient-maskinen
│   │   │   └── tasks/
│   │   │       └── main.yml
│   │   ├── common/          # Gemensamma inställningar för alla noder
│   │   │   └── tasks/
│   │   │       └── main.yml
│   │   ├── database/        # Installation och setup av PostgreSQL
│   │   │   ├── handlers/
│   │   │   │   └── main.yml
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   └── templates/
│   │   │       └── pg_hba.conf.j2
│   │   ├── firewall/        # Konfiguration av nätverk och säkerhetsregler
│   │   │   └── tasks/
│   │   │       └── main.yml
│   │   ├── flask/           # Driftsättning av Python-appen och Gunicorn
│   │   │   ├── defaults/
│   │   │   │   └── main.yml
│   │   │   ├── files/
│   │   │       ├── app.py
│   │   │       └── requirements.txt
│   │   │   ├── handlers/
│   │   │   │   └── main.yml
│   │   │   ├── tasks/
│   │   │   │   └── main.yml
│   │   │   └── templates/
│   │   │       └── flask.service.j2
│   │   └── nginx/           # Installation av Nginx som Reverse Proxy
│   │       ├── handlers/
│   │       │   └── main.yml
│   │       ├── tasks/
│   │       │   └── main.yml
│   │       └── templates/
│   │           └── nginx.conf.j2
│   ├── vars/
│   │   ├── main.yml         # Globala variabler (IP-adresser, portar)
│   │   ├── secrets.yml      # GITIGNORERAD — känsliga lösenord
│   │   └── secrets_example.yml # Mall för lösenord (utan riktiga värden)
│   ├── ansible.cfg          # Inställningar för Ansible-körningen
│   ├── inventory.ini        # Definition av noder och IP-adresser
│   └── site.yml             # Master playbook som kör alla roller
│
├── docs/
│   └── Topologi.png         # Nätverksdiagram över labbmiljön
│
├── test/
│   └── verify.sh            # Skript för automatiserad verifiering   
│
├── .gitignore               # Exkluderar känsliga filer från Git
├── README.md                # Projektdokumentation (denna fil)
└── Vagrantfile              # Definition av virtuella maskiner och nätverk

```
---

## Komponenter

### Vagrantfile 

Definierar fyra virtuella maskiner i VirtualBox. Brandväggen agerar gateway med två nätverkskort, ett publikt mot host-datorn (10.0.1.1) och ett isolerat backend-nätverk (10.0.3.1) där databasservern ligger. Port forwarding är konfigurerad på brandväggen för att tillåta trafik till webbservern, medan databasen är helt isolerad utan extern åtkomst.

### ansible.cfg

Ser till att Ansible alltid använder samma regler när den konfigurerar miljön, oavsett vilken dator du kör ifrån. Kontrollerar anslutningsmetoder och rättigheter. Den pekar på inventory.ini och anger var alla säkerhetsroller finns.

### inventory.ini

Möjliggör segmentering. Huvuduppgift: Systemets adresslista. Den grupperar maskinerna logiskt i [firewall], [nginx], [flask] och [database].

### site.yml (Playbook)

Koordinerar samtliga roller i projektet och säkerställer en logisk ordning 
1. **firewall** - Nätverksskyddet sätt upp först.
2. **database** - Databasmiljön säkras innan applikationen startar.
3. **flask/nginx** - Applikationslagret driftsätts sist när infrastrukturen är redo.

### Rollen firewall

Aggerar bro mellan det publika nätverket och det isolerade backend nätet. Den hanterar routing och trafikfiltrering via iptables och ser till att ingen obehörig trafik når de interna servrarna.

### Rollen flask

Isolerar applikationen i ett virtual environment (/opt/flask/venv) och körs som en begränsad systemd-tjänst med Restart=always. Installerar Python 3, Gunicorn och beroenden från requirements.txt.

### Rollen Nginx

Döljer backend-servrarnas interna IP-adresser. Den tar emot trafik på prot 80 och skickar den vidare, vilket hindrar externa användare från att prata direkt med Flask-servern.

### Rollen database

Tillämpar principen om Least Privilege. Installerar PostgreSQL och konfigurerar pg_hba.conf så att enbart webbserverns interna IP-adress tillåts ansluta. All extern åtkomst på port 5432 blockeras.

### Flask-applikationen (app.py)

En Python-baserad applikation fom används för att verifiera att hela kedjan fungerar säkert. All konfiguration läses dynamiskt via os.environ.get().

| Endpoint | Metod | Beskrivning |
|---|---|---|
| `/` | GET | Verifierar kontakt mellan Nginx och Flask.motorn. |
| `/info` | GET | Returnerar JSON med hostname och miljödata (för felsökning). |
| `/health` | GET | Health check - bekräftar att applikationen är vid liv. | 

---

## Krav och förutsättningar

**Programvara som måste vara installerad på Windows-hosten:**

- [Oracle VirtualBox](https://www.virtualbox.org/) - testat med version 7.x
- [Vagrant](https://developer.hashicorp.com/vagrant/install) - testat med version 2.x

**Hårdvarukrav:**
- Minst 8 GB RAM, men 16 GB är rekomenderat (projektet använder totalt cirka 3 GB)
- Minst 20 GB ledigt diskutrymme

---

## Kom igång

```bash
# 1. Klona repot
git clone git@github.com:DoomPlayya/Project-1---Double-homed-firewall.git
cd Project-1---Double-homed-firewall

# 2. Sätt egna värden i ansible/vars/secrets.yml
# Skapa och öppna secrets-filen inuti projektet
nano ansible/vars/secrets.yml

# Inuti filen skrivs egna värden
valut_db_password:"Lösenord"

# 3. Skapa maskinerna (utan att konfigurera dem än)
cd vagrant
vagrant up --no-provision

# 4. Kontrollera att maskinerna är igång
vagrant status

# 5. SSH in i brandväggen
vagrant ssh firewall

# 6. Installera Ansible inuti brandväggen
sudo apt update
sudo apt install -y ansible 

# 7. Kör konfigurationen
ansible-playbook -i ansible/inventory.ini
ansible/site.yml 

# 8. Verifiera att allt fungerar
bash test/verify.sh
```

---

## Secrets

Filen ansible/vars/secrets.yml innehåller känslig information såsom lösenord till databasen. Denna fil är inkluderad i .gitignore och ska aldrig committas till GitHub, utan måste skapas manuellt på den maskin där projektet körs.

**Skapa secrets.yml**
Eftersom filen inte finns repot måste man skapa den manuellt:

```bash
# 1. Skapa och öppna secrets-filen inuti projektet
nano ansible/vars/secrets.yml

# 2. Inuti filen skrivs egna värden
valut_db_password:"Lösenord"
```

```
vars_files
- ansible/vars/main.yml
- ansible/vars/secrets.yml
```

---

## Säkerhetsåtgärder

---

## Säkerhetsanalys

---

## Verfiering

Kör det automatiserade verifieringsskriptet inifrån brandväggen:

```bash
# Gå in i brandväggen
vagrant ssh firewall

# Kör skriptet
bash test/verify.sh
```

Vad skriptet kontrollerar:

- Att Nginx och Flask-motorn samarbetar och att /health-endpointen returnerar HTTP 200.
- Att databasporten (5432) är öppen och nårbar inifrån nätverket.
-  Att Flask-applikationen är aktiv och körs som en systemd-tjänst på backend-servern.
- Att rätt trafik tillåts mellan zonerna med hjälp av brandväggen.

Förväntat output:

```
================================
 Verifiering av infrastruktur
================================
✓ Webbserver svarar! (HTTP 200 på /health)
✓ Databasporten är öppen! (Port 5432 nåbar)
✓ Flask-tjänsten är aktiv! (Systemd status: active)
================================
 Resultat: 3 godkända, 0 misslyckade
================================
```

---

## Designval och motivering

---

*Skapad av: Elsa Grahn och Ida-Marie Näsström-Öqvist*
*Kurs: Virtualiseringsteknik*
*Datum: 2026-05-22*