ECR_REPO_NAME = "simple-strands-agent"

define get-aws-vars
	@echo "get-aws-vars"
	$(eval AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text))
	$(eval AWS_REGION := $(shell aws configure get region))
	$(eval ECR_REPO_URI := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(ECR_REPO_NAME))

	$(info > AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID))
	$(info > AWS_REGION=$(AWS_REGION))
	$(info > ECR_REPO_NAME=$(ECR_REPO_NAME))
	$(info > ECR_REPO_URI=$(ECR_REPO_URI))
endef

login-to-ecr:
	@echo "Logging in into ECR..."
	$(get-aws-vars)
	aws ecr get-login-password | finch login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

create-ecr-repo:
	@echo "Creating/validating repo..."
	$(get-aws-vars)
	aws ecr describe-repositories --repository-names "${ECR_REPO_NAME}" --no-cli-pager 2>/dev/null || \
  		aws ecr create-repository --repository-name "${ECR_REPO_NAME}" --no-cli-pager

build-image: 
	@echo "Building image..."
	$(get-aws-vars)
	finch build -t "${ECR_REPO_URI}:latest" .
	@echo "test locally using either:"
	@echo "docker run --rm -it -p 8080:8080 ${ECR_REPO_URI}:latest"
	@echo "finch run --rm -it -p 8080:8080 ${ECR_REPO_URI}:latest"

push-image:
	@echo "Pushing image to ECR..."
	$(get-aws-vars)
	finch push "${ECR_REPO_URI}:latest"

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

deploy-all: create-ecr-repo build-image push-image deploy-infra
	@echo "All done!"

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy

invoke:
	@echo "Invoking agent..."
	@./invoker.sh

test:
	@echo "test"
