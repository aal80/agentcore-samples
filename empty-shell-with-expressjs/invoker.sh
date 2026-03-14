#!/bin/bash
set -euo pipefail

RUNTIME_ARN=$(cat ./tmp/agent_runtime_arn.txt)

echo "> RUNTIME_ARN=${RUNTIME_ARN}"

PAYLOAD=$(echo -n '{"hello": "world"}' | base64)

echo "> Invoking..."
aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "$RUNTIME_ARN" \
  --payload "$PAYLOAD" \
  --content-type "application/json" \
  tmp/invoke_output.txt \
  --no-cli-pager

echo "> Invocation output:"
cat tmp/invoke_output.txt
