from flask import Flask
import psycopg2
import os

app = Flask(__name__)

@app.route('/')
def home():
    return """
    <h1>Välkommen till labbet!</h1>
    <p>Nginx skickar trafik till Flask-appen via brandväggen korrekt.</p>
    <ul>
        <li><a href="/db">Testa databasanslutning</a></li>
    </ul>
    """

@app.route('/db')
def test_db():
    try:
        conn = psycopg2.connect(
            host="10.0.3.2",
            database="postgres",
            user="postgres",
            password="mysecretpassword" 
        )
        cur = conn.cursor()
        cur.execute('SELECT version();')
        db_version = cur.fetchone()
        cur.close()
        conn.close()
        return f"<h1>Framgång!</h1><p>Flask-appen lyckades ansluta till PostgreSQL genom brandväggen.</p><p>DB Version: {db_version}</p>"
    except Exception as e:
        return f"<h1>Kunde inte ansluta till databasen</h1><p>Felmeddelande: {e}</p>"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)