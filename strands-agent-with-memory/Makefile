ECR_REPO_NAME = "strands-agent-with-memory"

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

define get-agentcore-vars
	@echo "get-agentcore-vars"
	$(eval RUNTIME_ARN := $(shell cat ./tmp/agent_runtime_arn.txt))
	$(eval MEMORY_ID := $(shell cat ./tmp/memory_id.txt))
	$(eval ACTOR_ID := $(shell cat ./tmp/actor_id.txt))
	$(eval SESSION_ID := $(shell cat ./tmp/session_id.txt))
	$(eval STRATEGY_ID := $(shell cat ./tmp/memory_strategy_id.txt))

	$(info > RUNTIME_ARN=$(RUNTIME_ARN))
	$(info > MEMORY_ID=$(MEMORY_ID))
	$(info > ACTOR_ID=$(ACTOR_ID))
	$(info > SESSION_ID=$(SESSION_ID))
	$(info > STRATEGY_ID=$(STRATEGY_ID))
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

invoke1:
	@echo "Invoking agent - telling agent about my food preferences..."
	$(get-agentcore-vars)
	$(eval PAYLOAD := $(shell cat ./test-data/invoke-agent-payload1.json))
	$(eval PAYLOAD_B64 := $(shell echo '$(PAYLOAD)' | base64))
	$(info > PAYLOAD=$(PAYLOAD))
	$(info > PAYLOAD_B64=$(PAYLOAD_B64))

	aws bedrock-agentcore invoke-agent-runtime \
  		--agent-runtime-arn "${RUNTIME_ARN}" \
  		--payload "${PAYLOAD_B64}" \
  		--content-type "application/json" \
  		--runtime-session-id "${SESSION_ID}" \
  		tmp/invoke_output.txt \
  		--no-cli-pager

	@cat tmp/invoke_output.txt | jq .

	@echo ""
	@echo "Wait for several minutes for memory strategy to process data. Call 'make list-memory-records' to validate."

list-memory-records:
	echo "Listing memory records..."
	$(get-agentcore-vars)
	echo "Listing memory records..."
	aws bedrock-agentcore list-memory-records \
		--memory-id ${MEMORY_ID} \
		--namespace ""/preferences/${ACTOR_ID}"" \
		--memory-strategy-id ${STRATEGY_ID}

	@echo ""
	@echo "Once you see memories returned, call 'make invoke2' to see how memory is used during prompt processing."

invoke2:
	@echo "Invoking agent..."
	$(get-agentcore-vars)
	$(eval PAYLOAD := $(shell cat ./test-data/invoke-agent-payload2.json))
	$(eval PAYLOAD_B64 := $(shell echo '$(PAYLOAD)' | base64))
	$(info > PAYLOAD=$(PAYLOAD))
	$(info > PAYLOAD_B64=$(PAYLOAD_B64))

	@echo ""
	@echo "IMPORTANT! Note that this request does NOT specify session_id parameter."
	@echo "This means that it would be processed by a new runtime instance, which "
	@echo "will use AgentCore Memory to retrieve information about user's preferences. "
	@echo ""

	aws bedrock-agentcore invoke-agent-runtime \
  		--agent-runtime-arn "${RUNTIME_ARN}" \
  		--payload "${PAYLOAD_B64}" \
  		--content-type "application/json" \
  		tmp/invoke_output.txt \
  		--no-cli-pager

	@cat tmp/invoke_output.txt | jq .

