from flask import Flask, request
import json

app = Flask(__name__)

@app.route("/invocations", methods=["POST"])
def app_entrypoint():
    payload = request.get_data(as_text=True)
    payload = json.loads(payload)
    print(payload)
    
    return {
        "msg":"hello from AgentCore Empty Shell",
        "received_headers": dict(request.headers),
        "received_payload": payload,
    }


@app.route("/ping", methods=["GET"])
def ping():
    return {
        "status":"Healthy"
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)