from flask import Flask
import socket

app = Flask(__name__)

@app.route('/')
def hello_world():
    # Gets the Pod name (Hostname)
    pod_name = socket.gethostname()
    return f"""
    <div style='text-align: center; margin-top: 50px; font-family: sans-serif;'>
        <h1 style='color: #2ecc71;'>🛡️ EKS Armor Flow</h1>
        <p>Served by Pod: <b style='color: #e67e22;'>{pod_name}</b></p>
        <p>Status: <span style='color: green;'>Secure (Trivy Scanned)</span></p>
        <hr style='width: 20%;'>
        <p style='font-size: 0.8em;'>Refresh to see the Load Balancer in action!</p>
    </div>
    """

if __name__ == '__main__':
    # Standard port for non-root users
    app.run(host='0.0.0.0', port=8080)
