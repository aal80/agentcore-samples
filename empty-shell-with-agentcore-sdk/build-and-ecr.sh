#!/bin/bash
set -euo pipefail

echo "Starting..."

IMAGE_NAME="empty-shell-with-agentcore-sdk"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}"

echo "IMAGE_NAME:     ${IMAGE_NAME}"
echo "AWS_ACCOUNT_ID: ${AWS_ACCOUNT_ID}"
echo "AWS_REGION:     ${AWS_REGION}"
echo "ECR_REPO:       ${ECR_REPO}"

# Log in to ECR
echo "Logging in into ECR..."
aws ecr get-login-password | finch login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Create repo if it doesn't exist
echo "Checking repo..."
aws ecr describe-repositories --repository-names "${IMAGE_NAME}" --no-cli-pager 2>/dev/null || \
  aws ecr create-repository --repository-name "${IMAGE_NAME}" --no-cli-pager

# Build and push
echo "Building image..."
finch build -t "${ECR_REPO}:latest" .

echo "Pushing to ECS..."
finch push "${ECR_REPO}:latest"

echo "All done!"
echo "test locally using:"
echo "docker run --rm -it -p 8080:8080 ${ECR_REPO}:latest"

