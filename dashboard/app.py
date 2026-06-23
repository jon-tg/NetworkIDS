from flask import Flask, render_template
import sqlite3
import os

app = Flask(__name__)

DB_PATH = "../database/ids_alerts.db"

def query_db(query):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute(query)
    results = cursor.fetchall()
    conn.close()
    return results

@app.route("/")
def dashboard():
    total_alerts = query_db("SELECT COUNT(*) AS count FROM alerts;")[0]["count"]

    severity_counts = query_db("""
        SELECT severity_text, COUNT(*) AS count
        FROM alerts
        GROUP BY severity_text
        ORDER BY count DESC;
    """)

    top_signatures = query_db("""
        SELECT signature, COUNT(*) AS count
        FROM alerts
        GROUP BY signature
        ORDER BY count DESC
        LIMIT 5;
    """)

    recent_alerts = query_db("""
        SELECT timestamp, src_ip, dest_ip, dest_port, protocol, signature, severity_text
        FROM alerts
        ORDER BY id DESC
        LIMIT 20;
    """)

    return render_template(
        "dashboard.html",
        total_alerts=total_alerts,
        severity_counts=severity_counts,
        top_signatures=top_signatures,
        recent_alerts=recent_alerts
    )

if __name__ == "__main__":
    app.run(debug=True)