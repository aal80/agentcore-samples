import json
from pathlib import Path
import boto3

client = boto3.client("bedrock-agentcore")

runtime_arn = Path("tmp/agent_runtime_arn.txt").read_text().strip()

print(f"> runtime_arn={runtime_arn}")

payload = {"input": {"prompt": "hello"}}
payload = json.dumps(payload)
print(f"> payload={payload}")

print(f"> invoking...")
response = client.invoke_agent_runtime(
    agentRuntimeArn=runtime_arn,
    payload=payload,
)

print(f"> response: {response}")
body = response["response"].read().decode()
print(f"> body: {body}")
