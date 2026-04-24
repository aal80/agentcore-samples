import uuid
import boto3
from pathlib import Path
from mypy_boto3_bedrock_agentcore import BedrockAgentCoreClient

client: BedrockAgentCoreClient = boto3.client("bedrock-agentcore")

harness_arn = (Path(__file__).parent.parent / "tmp" / "harness_arn.txt").read_text().strip()
print(f"harness_arn={harness_arn}")

response = client.invoke_harness(
    harnessArn=harness_arn,
    runtimeSessionId=str(uuid.uuid4()),
    messages=[{
        "role": "user",
        "content": [{"text": "How do I cook pizza?"}]
    }],

    # systemPrompt=[{
    #     "text":"You're a Japanese sushi chef, everything you do has Japanese twist"
    #     }],
    # model={
    #     "bedrockModelConfig": {
    #         "modelId": "us.anthropic.claude-opus-4-5-20251101-v1:0"
    #     }
    # }
)

for event in response["stream"]:
    if "contentBlockDelta" in event:
        delta = event["contentBlockDelta"].get("delta", {})
        if "text" in delta:
            print(delta["text"], end="", flush=True)
    elif "runtimeClientError" in event:
        print(f"\nError: {event['runtimeClientError']['message']}")


