Målet med denna uppgift är följande:
"En realistisk nätverkstopologi där all trafik mellan zoner måste passera en dedikerad
brandväggsmaskin. Brandväggen har två nätverksgränssnitt kopplade till separata interna nät —
klienten kan inte nå webbservern direkt, och webbservern kan inte nå databasen utan att trafiken
routas via brandväggen. Brandväggen konfigureras med iptables/nftables och IP-forwarding. Klienten når webbservern via
port 80/443 — inget annat. Webbservern når databasen via port 5432 — inget annat. Klienten kan
inte nå databasen alls."

[Klient-VM]                [DB-VM]
  10.0.1.2                  10.0.3.2
     |                          |
  intnet:                   intnet:
  frontend                   backend
     |                          |
  10.0.1.1 [Firewall-VM] 10.0.3.1
            10.0.2.1               
                |
             intnet:
             dmz-net
                |
           10.0.2.2
        [Webbserver-VM]
