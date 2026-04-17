# Empty Shell with Expressjs

A minimal Amazon Bedrock AgentCore runtime that echoes back the received payload. Uses Express.js to implement AgentCore's HTTP interface. 

## Prerequisites

- Node 22+
- AWS CLI configured with appropriate credentials
- Terraform
- Docker for container builds

## Project Structure

```
.
├── index.js                # AgentCore runtime entrypoint
├── Dockerfile              # Container image definition
├── package.json            # Nodejs dependencies
├── build-and-ecr.sh        # Build container image and push to ECR
├── invoker.sh              # Invoke the runtime via AWS CLI
├── invoker.js              # Invoke the runtime via AWS SDK
└── terraform/              # Infrastructure as code
    ├── providers.tf        # Provider configuration
    ├── ecr.tf              # ECR repository data source
    └── agentcore_runtime.tf # AgentCore runtime + IAM role
```

## Setup

### 1. Build and push the container image

```bash
./build-and-ecr.sh
```

This will create the ECR repository (if needed), build the Docker image, and push it.

### 2. Deploy the infrastructure

```bash
cd terraform
terraform init
terraform apply
```

This creates:
- IAM role with ECR pull and Bedrock permissions
- AgentCore agent runtime pointing to the ECR image
- `tmp/agent_runtime_arn.txt` with the runtime ARN

### 3. Invoke the runtime

Using the AWS CLI:

```bash
./invoker.sh
```

Or using Nodejs:

```bash
node invoker.js
```

## Updating the runtime

The `aws_agentcore_runtime` Terraform resource references the image digest, so it will detect changes even when the tag stays `:latest`.

After making changes to app code, redeploy the image and runtime:

```bash
./build-and-ecr.sh

cd terraform
terraform apply
```

