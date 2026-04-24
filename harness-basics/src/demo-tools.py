import uuid
import boto3
from pathlib import Path
from mypy_boto3_bedrock_agentcore import BedrockAgentCoreClient

client: BedrockAgentCoreClient = boto3.client("bedrock-agentcore")

harness_arn = (Path(__file__).parent.parent / "tmp" / "harness_arn.txt").read_text().strip()
print(f"harness_arn={harness_arn}")

tools = [
    {
        "type":"remote_mcp",
        "name":"exa",
        "config": {"remoteMcp": {"url": "https://mcp.exa.ai/mcp"}},
    }
]

response = client.invoke_harness(
    harnessArn=harness_arn,
    runtimeSessionId=str(uuid.uuid4()),
    # tools=tools,
    messages=[{
        "role": "user",
        "content": [{"text": "What's the weather in Austin TX tomorrow, is it good for eating out?"}]
    }],
)

for event in response["stream"]:
    if "contentBlockDelta" in event:
        delta = event["contentBlockDelta"].get("delta", {})
        if "text" in delta:
            print(delta["text"], end="", flush=True)
    elif "runtimeClientError" in event:
        print(f"\nError: {event['runtimeClientError']['message']}")


