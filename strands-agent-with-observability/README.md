# Strands Agent with Observability

A [Strands Agents](https://github.com/strands-agents/sdk-python) agent deployed on [Amazon Bedrock AgentCore Runtime](https://docs.aws.amazon.com/bedrock/latest/userguide/agentcore.html) with full observability via OpenTelemetry.

## What's included

- **Agent application** (`main.py`) — Strands agent hosted with `BedrockAgentCoreApp`
- **Container** (`Dockerfile`) — ARM64 image with `uv`, OTEL instrumentation via `opentelemetry-instrument`
- **Infrastructure** (`terraform/`) — AgentCore Runtime, ECR, CloudWatch Log Delivery, resource policies
- **Prereq checks** (`scripts/check-observability-prereqs.sh`) — validates manual prerequisites before deploying

## Prerequisites

- AWS CLI configured with credentials and a default region
- [Terraform](https://www.terraform.io/) >= 1.0
- Docker for building container images
- [uv](https://github.com/astral-sh/uv) for local development
- **Transaction Search** enabled in CloudWatch (manual console step — see below)

## Project structure

```
.
├── main.py                              # Agent entrypoint
├── pyproject.toml                       # Python dependencies (uv)
├── Dockerfile                           # Container image (ARM64)
├── Makefile                             # Build/deploy commands
├── scripts/
│   └── check-observability-prereqs.sh   # Pre-deploy validation
└── terraform/
    ├── providers.tf                     # AWS providers, locals
    ├── ecr.tf                           # ECR repository data source
    ├── agentcore_runtime.tf             # AgentCore Runtime + IAM role
    ├── cloudwatch-resource-policies.tf  # Resource policies for log delivery & X-Ray
    ├── log-delivery-app-logs.tf         # APPLICATION_LOGS delivery to CloudWatch
    ├── log-delivery-usage-logs.tf       # USAGE_LOGS delivery to CloudWatch
    └── log-delivery-traces.tf           # TRACES delivery to X-Ray
```

## Setup

### 1. Enable Transaction Search (one-time, manual)

This must be done in the AWS Console before deploying:

1. Go to **CloudWatch** -> **Application Signals** -> **Transaction Search**
2. Enable Transaction Search, selecting **"ingest spans as structured logs"**
3. This auto-creates the `aws/spans` log group required for trace export
4. Wait for ~10 minutes after enabling Transaction Search for all configurations to propagate. 

Verify with:
```bash
make check-cloudwatch-configurations
```

### 2. Build and deploy

```bash
# Login to ECR
make login-to-ecr

# Full deploy: create ECR repo, build image, push, terraform apply
make deploy-all
```

Or run steps individually:
```bash
make create-ecr-repo
make build-image
make push-image
make deploy-infra
```

### 3. Invoke the agent

```bash
RUNTIME_ARN=$(cat tmp/agent_runtime_arn.txt)

aws bedrock-agentcore invoke-agent-runtime \
  --agent-runtime-arn "$RUNTIME_ARN" \
  --content-type "application/json" \
  --payload '{"prompt": "What is the capital of France?"}' \
  tmp/invoke_output.txt \
  --no-cli-pager

cat tmp/invoke_output.txt  
```

## Observability

The agent is instrumented with OpenTelemetry via:
- `strands-agents[otel]` — Strands SDK OTEL integration
- `aws-opentelemetry-distro` — AWS OTEL distro with SigV4-signed trace export
- `opentelemetry-instrument` — auto-instrumentation wrapper in the container CMD (See Dockerfile)

AgentCore Runtime injects all required `OTEL_*` environment variables at runtime.

### CloudWatch Log Delivery

Terraform configures three log delivery pipelines from the AgentCore Runtime:

| Log Type | Destination |
|---|---|
| `APPLICATION_LOGS` | CloudWatch Logs (`/aws/vendedlogs/bedrock-agentcore/runtime/APPLICATION_LOGS/...`) |
| `USAGE_LOGS` | CloudWatch Logs (`/aws/vendedlogs/bedrock-agentcore/runtime/USAGE_LOGS/...`) |
| `TRACES` | X-Ray (via CloudWatch `aws/spans` log group) |

### Where to find traces

**CloudWatch** -> **Application Signals** -> **Transaction Search**

## Makefile targets

| Target | Description |
|---|---|
| `check-cloudwatch-configurations` | Validate observability prerequisites |
| `login-to-ecr` | Authenticate to ECR |
| `create-ecr-repo` | Create ECR repository if not exists |
| `build-image` | Build container image with Docker |
| `push-image` | Push image to ECR |
| `deploy-infra` | Run `terraform init` + `terraform apply` |
| `deploy-all` | Full pipeline: ECR repo + build + push + deploy |
| `destroy` | Tear down all Terraform-managed infrastructure |

## Teardown

```bash
make destroy
```
