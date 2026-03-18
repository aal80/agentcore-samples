# Simple Strands Agent

A minimal sample AI agent deployed on [AWS Bedrock AgentCore](https://docs.aws.amazon.com/bedrock/latest/userguide/agentcore.html) using the [Strands Agents](https://github.com/strands-agents/strands-agents) framework. 

## Architecture

```
Client --> AWS Bedrock AgentCore Runtime --> Strands Agent --> Amazon Bedrock
```

- **Application:** Python 3.13 app using `bedrock-agentcore` SDK
- **Agent framework:** Strands Agents
- **Container:** ARM64 image built with uv, deployed to ECR
- **Infrastructure:** Terraform-managed (IAM, AgentCore runtime)

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (Python package manager)
- AWS CLI configured with appropriate credentials
- Docker or [Finch](https://runfinch.com/) to build and push images to ECR
- Terraform

## Project Structure

```
.
├── main.py                  # Application entrypoint
├── pyproject.toml           # Python dependencies
├── uv.lock                  # Locked dependencies
├── Dockerfile               # Container build (ARM64)
├── Makefile                 # Build and deployment commands
├── invoker.sh               # Script to test the deployed agent
└── terraform/
    ├── providers.tf         # AWS, AWSCC, random, local providers
    ├── ecr.tf               # ECR repository and image lookup
    └── agentcore_runtime.tf # IAM role, policies, AgentCore runtime
```

## Local Development

Install dependencies:

```bash
uv sync
```

Run the agent locally:

```bash
uv run main.py
```

Run with file watching (auto-restart on changes):

```bash
uv run watchfiles "python main.py"
```

## Deployment

### Full deployment (build + push + infrastructure):

```bash
make deploy-all
```

This runs: `create-ecr-repo` -> `build-image` -> `push-image` -> `deploy-infra`

### Individual steps:

```bash
make login-to-ecr    # Authenticate to ECR
make create-ecr-repo # Create ECR repository
make build-image     # Build container image with Finch
make push-image      # Push image to ECR
make deploy-infra    # Run terraform apply
```

## Invoking the Agent

After deployment, test the agent:

```bash
make invoke
```

This runs `invoker.sh`, which:
1. Reads the agent runtime ARN from `tmp/agent_runtime_arn.txt` (created by Terraform)
2. Sends a base64-encoded JSON payload with a prompt
3. Calls `aws bedrock-agentcore invoke-agent-runtime`

### Example request payload:

```json
{"prompt": "give me pizza recipe in one sentence"}
```

### Example response:

```json
{
  "agent_response_text": "Mix 2 cups flour, 1 tsp salt, 1 packet yeast...",
  "request_headers": { "..." },
  "request_payload": { "prompt": "give me pizza recipe in one sentence" }
}
```

## Teardown

```bash
make destroy
```

