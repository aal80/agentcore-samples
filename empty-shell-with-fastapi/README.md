# Empty Shell with FastAPI

A minimal Amazon Bedrock AgentCore runtime that echoes back the received payload. Uses FastAPI to implement AgentCore's HTTP interface. 

## Prerequisites

- Python 3.13
- AWS CLI configured with appropriate credentials
- Terraform
- Docker or Finch for container builds

## Project Structure

```
.
├── main.py                 # AgentCore runtime entrypoint
├── Dockerfile              # Container image definition
├── requirements.txt        # Python dependencies
├── build-and-ecr.sh        # Build container image and push to ECR
├── invoker.sh              # Invoke the runtime via AWS CLI
├── invoker.py              # Invoke the runtime via boto3
└── terraform/              # Infrastructure as code
    ├── providers.tf        # Provider configuration
    ├── ecr.tf              # ECR repository data source
    └── agentcore_runtime.tf # AgentCore runtime + IAM role
```

## Setup

### 1. Build and push the container image

By default, this script uses `finch` to build images. When using Docker, replace `finch` with `docker` in the Build and Push stages. 

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

Or using Python/boto3:

```bash
python invoker.py
```

## Updating the runtime

The `aws_agentcore_runtime` Terraform resource references the image digest, so it will detect changes even when the tag stays `:latest`.

After making changes to app code, redeploy the image and runtime:

```bash
./build-and-ecr.sh

cd terraform
terraform apply
```

