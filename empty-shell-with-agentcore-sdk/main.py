from bedrock_agentcore.runtime import BedrockAgentCoreApp

app = BedrockAgentCoreApp()

@app.entrypoint
async def app_entrypoint(payload, context):
    print(f"payload={payload}")
    print(f"context={context}")

    return {
        "msg":"hello from AgentCore Empty Shell",
        "received_payload": payload,
    }

if __name__ == "__main__":
    print("> main")
    app.run(host="0.0.0.0", port="8080")
