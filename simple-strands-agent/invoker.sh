#!/bin/bash
set -euo pipefail

RUNTIME_ARN=$(cat ./tmp/agent_runtime_arn.txt)

echo "> RUNTIME_ARN=${RUNTIME_ARN}"

PAYLOAD=$(echo -n '{"prompt": "give me pizza recipe in one sentence"}' | base64)

echo "> Invoking..."
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "$RUNTIME_ARN" \
  --payload "$PAYLOAD" \
  --content-type "application/json" \
  --runtime-session-id "abcd1234abcd1234abcd1234abcd1234abcd1234" \
  tmp/invoke_output.txt \
  --no-cli-pager

echo "> Invocation output:"
cat tmp/invoke_output.txt
