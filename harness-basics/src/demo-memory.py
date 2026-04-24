import boto3
from pathlib import Path
from mypy_boto3_bedrock_agentcore import BedrockAgentCoreClient

client: BedrockAgentCoreClient = boto3.client("bedrock-agentcore")
RUNTIME_SESSION_ID = "abcd1234abcd1234abcd1234abcd1234abcd1234abcd123"
ACTOR_ID = "user-123"

_tmp = Path(__file__).parent.parent / "tmp"
harness_arn = (_tmp / "harness_arn.txt").read_text().strip()
print(f"harness_arn={harness_arn}")

memory_id = (_tmp / "memory_id.txt").read_text().strip()
print(f"memory_id={memory_id}")

response = client.invoke_harness(
    harnessArn=harness_arn,
    runtimeSessionId=RUNTIME_SESSION_ID,
    actorId=ACTOR_ID,
    messages=[{
        "role": "user",
        "content": [{"text": "I really, REALLY like pizza and sushi, especially with spicy sauce!"}]
        # "content": [{"text": "Can you refresh my memory, what's my favorite food?"}]
        # "content": [{"text": "What did we just talked about?"}]
    }],
)

for event in response["stream"]:
    if "contentBlockDelta" in event:
        delta = event["contentBlockDelta"].get("delta", {})
        if "text" in delta:
            print(delta["text"], end="", flush=True)
    elif "runtimeClientError" in event:
        print(f"\nError: {event['runtimeClientError']['message']}")


