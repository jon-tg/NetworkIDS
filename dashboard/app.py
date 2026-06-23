from flask import Flask, render_template, request
import sqlite3

app = Flask(__name__)
DB_PATH = "../database/ids_alerts.db"

def query_db(query, params=()):
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()
    cursor.execute(query, params)
    results = cursor.fetchall()
    conn.close()
    return results

@app.route("/")
def dashboard():
    total_alerts = query_db("SELECT COUNT(*) AS count FROM alerts;")[0]["count"]
    total_devices = query_db("SELECT COUNT(*) AS count FROM devices;")[0]["count"]

    severity_counts = query_db("""
        SELECT severity_text, COUNT(*) AS count
        FROM alerts
        GROUP BY severity_text;
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
        LIMIT 10;
    """)

    severity_labels = [row["severity_text"] for row in severity_counts]
    severity_data = [row["count"] for row in severity_counts]
    signature_labels = [row["signature"] for row in top_signatures]
    signature_data = [row["count"] for row in top_signatures]

    return render_template(
        "dashboard.html",
        total_alerts=total_alerts,
        total_devices=total_devices,
        severity_counts=severity_counts,
        top_signatures=top_signatures,
        recent_alerts=recent_alerts,
        severity_labels=severity_labels,
        severity_data=severity_data,
        signature_labels=signature_labels,
        signature_data=signature_data
    )

@app.route("/alerts")
def alerts():
    search = request.args.get("search", "")

    if search:
        rows = query_db("""
            SELECT *
            FROM alerts
            WHERE src_ip LIKE ?
               OR dest_ip LIKE ?
               OR signature LIKE ?
               OR severity_text LIKE ?
            ORDER BY id DESC
            LIMIT 100;
        """, (f"%{search}%", f"%{search}%", f"%{search}%", f"%{search}%"))
    else:
        rows = query_db("""
            SELECT *
            FROM alerts
            ORDER BY id DESC
            LIMIT 100;
        """)

    return render_template("alerts.html", alerts=rows, search=search)

@app.route("/devices")
def devices():
    rows = query_db("""
        SELECT *
        FROM devices
        ORDER BY risk_score DESC, alert_count DESC;
    """)

    return render_template("devices.html", devices=rows)

@app.route("/stats")
def stats():
    top_sources = query_db("""
        SELECT src_ip, COUNT(*) AS count
        FROM alerts
        GROUP BY src_ip
        ORDER BY count DESC
        LIMIT 10;
    """)

    top_ports = query_db("""
        SELECT dest_port, COUNT(*) AS count
        FROM alerts
        GROUP BY dest_port
        ORDER BY count DESC
        LIMIT 10;
    """)

    return render_template("stats.html", top_sources=top_sources, top_ports=top_ports)

if __name__ == "__main__":
    app.run(debug=True)