from bedrock_agentcore.runtime import BedrockAgentCoreApp
from starlette.responses import JSONResponse
from strands import Agent
import os
import logging
logging.basicConfig(level=logging.INFO)
l = logging.getLogger("main")
app = BedrockAgentCoreApp()

@app.entrypoint
async def app_entrypoint(request_payload, context):
    l.info(f"> app_entrypoint")
    request_headers = dict(context.request.headers)
    l.info(f"request_payload={request_payload}")
    l.info(f"request_headers={request_headers}")

    prompt = request_payload.get("prompt")
    if not prompt:
        l.error("Request payload is missing required field: 'prompt'");
        return JSONResponse({"error": "Missing required field: 'prompt'"}, status_code=400)

    agent = Agent()
    agent_response = agent(prompt=prompt)
    agent_response_text = agent_response.message["content"][0]["text"]

    l.info(f"agent_response_text={agent_response_text}")

    return {
        "agent_response_text": str(agent_response),
        "request_headers": request_headers,
        "request_payload": request_payload,
    }

if __name__ == "__main__":
    l.info("> main")

    # for key, value in sorted(os.environ.items()):
    #     l.info(f"env_var: {key}={value}")

    app.run(host="0.0.0.0", port=8080)
