define get-vars
	@echo "> get-vars"
	$(eval AWS_ACCOUNT_ID := $(shell mkdir -p tmp && (cat ./tmp/aws_account_id.txt 2>/dev/null || aws sts get-caller-identity --query Account --output text | tee ./tmp/aws_account_id.txt)))
	$(eval AWS_REGION := $(shell mkdir -p tmp && (cat ./tmp/aws_region.txt 2>/dev/null || { R=$$(aws configure get region); [ -z "$$R" ] && R=$${AWS_REGION}; echo "$$R" | tee ./tmp/aws_region.txt; })))
endef

login-to-ecr:
	$(call get-vars)
	@echo "> Logging in into ECR..."
	docker logout "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
	aws ecr get-login-password | docker login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

build-and-push-weather-agent:
	$(eval AGENT_IMAGE_NAME := a2a-workshop-weather-agent)
	$(eval AGENT_DIR := agents/weather)
	$(call build-and-push-agent)

build-and-push-shopping-agent:
	$(eval AGENT_IMAGE_NAME := a2a-workshop-shopping-agent)
	$(eval AGENT_DIR := agents/shopping)
	$(call build-and-push-agent)

define build-and-push-agent
	$(call get-vars)
	$(eval AGENT_ECR_REPO := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(AGENT_IMAGE_NAME))
	@echo "> Creating ECR repo (if doesn't exist)..."
	aws ecr describe-repositories --repository-names "$(AGENT_IMAGE_NAME)" --no-cli-pager 2>/dev/null || \
		aws ecr create-repository --repository-name "$(AGENT_IMAGE_NAME)" --no-cli-pager

	@echo "> Building container image from $(AGENT_DIR)..."
	cd $(AGENT_DIR) && \
	docker buildx build --platform linux/arm64 --no-cache --load -t "$(AGENT_ECR_REPO):latest" .

	@echo "> Pushing to ECR..."
	docker push "$(AGENT_ECR_REPO):latest"
	@echo "All done! If you're running on ARM architecture, you can test locally using:"
	@echo "docker run --rm -it -p 9000:9000 $(AGENT_ECR_REPO):latest"
endef

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp

get-cognito-access-token:
	@echo "Getting a new access token..."
	$(eval COGNITO_TOKEN_ENDPOINT := $(shell cat ./tmp/cognito_token_endpoint.txt))
	$(eval COGNITO_CLIENT_ID := $(shell cat ./tmp/cognito_client_id.txt))
	$(eval COGNITO_CLIENT_SECRET := $(shell cat ./tmp/cognito_client_secret.txt))
	
	$(info > COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT))
	$(info > COGNITO_CLIENT_ID=$(COGNITO_CLIENT_ID))
	$(info > COGNITO_CLIENT_SECRET=$(shell echo $(COGNITO_CLIENT_SECRET) | cut -c1-3)...REDACTED...)

	$(eval ACCESS_TOKEN := $(shell curl -s -X POST $(COGNITO_TOKEN_ENDPOINT) \
  		-H "Content-Type: application/x-www-form-urlencoded" \
  		-d "grant_type=client_credentials&client_id=$(COGNITO_CLIENT_ID)&client_secret=$(COGNITO_CLIENT_SECRET)&scope=resource/read" \
		| jq -r '.access_token'))
	@echo ""
	@echo "Retrieved access token: $(ACCESS_TOKEN)"
	@echo $(ACCESS_TOKEN) > ./tmp/access_token.txt
	@echo ""
	@echo "Token saved to ./tmp/access_token.txt"

test-weather-agent:
	$(eval AGENT_RUNTIME_URL_FILE := ./tmp/weather_agent_runtime_url.txt)
	$(eval AGENT_TEST_MESSAGE := What is the weather in Seattle?)
	$(call test-agent)

test-shopping-agent:
	$(eval AGENT_RUNTIME_URL_FILE := ./tmp/shopping_agent_runtime_url.txt)
	$(eval AGENT_TEST_MESSAGE := It is raining in Seattle. What should I wear?)
	$(call test-agent)

define test-agent
	$(eval AGENT_RUNTIME_URL := $(shell cat $(AGENT_RUNTIME_URL_FILE)))
	$(eval ACCESS_TOKEN := $(shell cat ./tmp/access_token.txt))

	@echo "Starting tests..."
	
	@echo "The following test attempts to retrieve the agent-card"
	@read -p "Press ENTER to start..."
	@echo "> Retrieving agent card from $(AGENT_RUNTIME_URL)/.well-known/agent-card.json..."
	@echo ""
	curl "$(AGENT_RUNTIME_URL)/.well-known/agent-card.json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" | jq .

	@echo ""
	@echo "The following test attempts to ask the following question: $(AGENT_TEST_MESSAGE)"
	@read -p "Press ENTER to start..."
	@echo "> Sending A2A message..."
	curl -X POST "$(AGENT_RUNTIME_URL)" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":"1","method":"message/send","params":{"message":{"role":"user","messageId":"msg-001","parts":[{"kind":"text","text":"$(AGENT_TEST_MESSAGE)"}]}}}' \
		| jq .result.artifacts
endef


