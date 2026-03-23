from bedrock_agentcore.runtime import BedrockAgentCoreApp
from bedrock_agentcore.memory.integrations.strands.config import AgentCoreMemoryConfig, RetrievalConfig
from bedrock_agentcore.memory.integrations.strands.session_manager import AgentCoreMemorySessionManager

from starlette.responses import JSONResponse
from strands import Agent
import os
import logging
logging.basicConfig(level=logging.INFO)
l = logging.getLogger("main")
app = BedrockAgentCoreApp()


AGENTCORE_MEMORY_ID = os.environ.get("AGENTCORE_MEMORY_ID")
l.info(f"AGENTCORE_MEMORY_ID={AGENTCORE_MEMORY_ID}")
if not AGENTCORE_MEMORY_ID:
    raise ValueError("AGENTCORE_MEMORY_ID environment variable is required")

AWS_REGION = os.environ.get("AWS_REGION")
l.info(f"AWS_REGION={AWS_REGION}")
if not AWS_REGION:
    raise ValueError("AWS_REGION environment variable is required")

ACTOR_ID = "test-actor"

@app.entrypoint
async def app_entrypoint(request_payload, context):
    session_id = context.session_id
    l.info(f"> app_entrypoint session_id={session_id}")

    request_headers = dict(context.request.headers)
    l.info(f"request_payload={request_payload}")
    l.info(f"request_headers={request_headers}")

    prompt = request_payload.get("prompt")
    if not prompt:
        l.error("Request payload is missing required field: 'prompt'");
        return JSONResponse({"error": "Missing required field: 'prompt'"}, status_code=400)

    agentcore_memory_config = AgentCoreMemoryConfig(
        memory_id=AGENTCORE_MEMORY_ID,
        session_id=session_id,
        actor_id=ACTOR_ID,
        retrieval_config={
            "/preferences/{actorId}": RetrievalConfig(
                top_k=5,
                relevance_score=0.7
            )
        }
    )

    agentcore_session_manager = AgentCoreMemorySessionManager(
        agentcore_memory_config=agentcore_memory_config,
        region_name=AWS_REGION
    )

    with agentcore_session_manager as session_manager:
        agent = Agent(
            session_manager=session_manager
        )
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
