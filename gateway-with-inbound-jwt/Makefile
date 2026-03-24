ECR_REPO_NAME = "gateway-with-inbound-jwt"

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
	$(eval GATEWAY_URL := $(shell cat ./tmp/gateway_url.txt))
	$(eval COGNITO_CLIENT_ID := $(shell cat ./tmp/cognito_client_id.txt))
	$(eval COGNITO_CLIENT_SECRET := $(shell cat ./tmp/cognito_client_secret.txt))
	$(eval COGNITO_TOKEN_ENDPOINT := $(shell cat ./tmp/cognito_token_endpoint.txt))
	$(eval COGNITO_DISCOVERY_URL := $(shell cat ./tmp/cognito_discovery_URL.txt))
	$(eval ACCESS_TOKEN := $(shell cat ./tmp/access_token.txt))

	$(info > GATEWAY_URL=$(GATEWAY_URL))
	$(info > COGNITO_CLIENT_ID=$(COGNITO_CLIENT_ID))
	$(info > COGNITO_CLIENT_SECRET=$(shell echo $(COGNITO_CLIENT_SECRET) | cut -c1-3)...REDACTED...)
	$(info > COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT))
	$(info > COGNITO_DISCOVERY_URL=$(COGNITO_DISCOVERY_URL))
	$(info > ACCESS_TOKEN=$(shell echo $(ACCESS_TOKEN) | cut -c1-10)...REDACTED...)
endef

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

deploy-all: deploy-infra
	@echo "All done!"

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy

get-token:
	$(get-agentcore-vars)
	@echo "Getting a new token..."
	$(eval ACCESS_TOKEN := $(shell curl -s -X POST $(COGNITO_TOKEN_ENDPOINT) \
  		-H "Content-Type: application/x-www-form-urlencoded" \
  		-d "grant_type=client_credentials&client_id=$(COGNITO_CLIENT_ID)&client_secret=$(COGNITO_CLIENT_SECRET)&scope=gateway/invoke" \
		| jq -r '.access_token'))
	@echo ""
	@echo "Retrieved access token: $(ACCESS_TOKEN)"
	@echo $(ACCESS_TOKEN) > ./tmp/access_token.txt
	@echo ""
	@echo "Token saved to ./tmp/access_token.txt"

list-tools:
	$(get-agentcore-vars)
	@echo "Listing tools...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

get-menu:
	$(get-agentcore-vars)
	@echo "Getting menu...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get-menu___get-menu","arguments":{}}}'

create-order:
	$(get-agentcore-vars)
	@echo "Creating a new order...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create-order___create-order","arguments":{"itemIds":[1,2,3]}}}'

