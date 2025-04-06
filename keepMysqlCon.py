from flask import Flask
import mysql.connector
import threading
import time

app = Flask(__name__)

# MySQL konekcija
con = mysql.connector.connect(
    host='localhost',
    port='3306',
    user='root',
    passwd='n3m4nj41M4K4',
    database='kalendar'
)

# Funkcija koja ping-uje MySQL server na svakih sat vremena
def ping_mysql():
    while True:
        try:
            con.ping(reconnect=True, attempts=3, delay=5)
            print("[INFO] Ping to MySQL successful.")
        except mysql.connector.Error as err:
            print(f"[ERROR] MySQL ping failed: {err}")
        time.sleep(3600)  # 3600 sekundi = 1 sat

# Pokreni pingovanje u pozadini
def start_background_ping():
    thread = threading.Thread(target=ping_mysql, daemon=True)
    thread.start()

@app.before_first_request
def before_first_request_func():
    start_background_ping()


if __name__ == '__main__':
    app.run(debug=True)
