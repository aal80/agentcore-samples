OPA_ECR_REPO_NAME = "gateway-with-open-policy-agent"

define get-aws-vars
	@echo "get-aws-vars"
	$(eval AWS_ACCOUNT_ID := $(shell aws sts get-caller-identity --query Account --output text))
	$(eval AWS_REGION := $(shell aws configure get region))
	$(eval OPA_ECR_REPO_URI := $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(OPA_ECR_REPO_NAME))

	$(info > AWS_ACCOUNT_ID=$(AWS_ACCOUNT_ID))
	$(info > AWS_REGION=$(AWS_REGION))
	$(info > OPA_ECR_REPO_NAME=$(OPA_ECR_REPO_NAME))
	$(info > OPA_ECR_REPO_URI=$(OPA_ECR_REPO_URI))
endef

define get-agentcore-vars
	@echo "get-agentcore-vars"
	$(eval GATEWAY_URL := $(shell cat ./tmp/gateway_url.txt))
	$(eval COGNITO_TOKEN_ENDPOINT := $(shell cat ./tmp/cognito_token_endpoint.txt))
	$(eval COGNITO_CLIENT1_ID := $(shell cat ./tmp/cognito_client1_id.txt))
	$(eval COGNITO_CLIENT1_SECRET := $(shell cat ./tmp/cognito_client1_secret.txt))
	$(eval COGNITO_CLIENT2_ID := $(shell cat ./tmp/cognito_client2_id.txt))
	$(eval COGNITO_CLIENT2_SECRET := $(shell cat ./tmp/cognito_client2_secret.txt))
	$(eval ACCESS_TOKEN := $(shell cat ./tmp/access_token.txt))

	$(info > GATEWAY_URL=$(GATEWAY_URL))
	$(info > COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT))
	$(info > COGNITO_CLIENT1_ID=$(COGNITO_CLIENT1_ID))
	$(info > COGNITO_CLIENT1_SECRET=$(shell echo $(COGNITO_CLIENT1_SECRET) | cut -c1-3)...REDACTED...)
	$(info > COGNITO_CLIENT2_ID=$(COGNITO_CLIENT2_ID))
	$(info > COGNITO_CLIENT2_SECRET=$(shell echo $(COGNITO_CLIENT2_SECRET) | cut -c1-3)...REDACTED...)
	$(info > ACCESS_TOKEN=$(shell echo $(ACCESS_TOKEN) | cut -c1-10)...REDACTED...)
endef

login-to-ecr:
	@echo "Logging in into ECR..."
	$(get-aws-vars)
	aws ecr-public get-login-password --region us-east-1 | finch login --username AWS --password-stdin public.ecr.aws
	aws ecr get-login-password | finch login --username AWS --password-stdin "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

create-opa-ecr-repo:
	@echo "Creating/validating OPA ECR repo..."
	$(get-aws-vars)
	aws ecr describe-repositories --repository-names "${OPA_ECR_REPO_NAME}" --no-cli-pager 2>/dev/null || \
  		aws ecr create-repository --repository-name "${OPA_ECR_REPO_NAME}" --no-cli-pager

build-opa-image:
	@echo "Building OPA image..."
	$(get-aws-vars)
	cd opa && finch build --platform linux/amd64 -t "${OPA_ECR_REPO_URI}:latest" .
	@echo "test locally using either:"
	@echo "docker run --rm -it -p 8181:8181 ${OPA_ECR_REPO_URI}:latest"
	@echo "finch run --rm -it -p 8181:8181 ${OPA_ECR_REPO_URI}:latest"

push-opa-image:
	@echo "Pushing image to ECR..."
	$(get-aws-vars)
	finch push "${OPA_ECR_REPO_URI}:latest"

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp

define get-token
	@echo "Getting a new token for $(1)..."
	$(eval ACCESS_TOKEN := $(shell curl -s -X POST $(COGNITO_TOKEN_ENDPOINT) \
  		-H "Content-Type: application/x-www-form-urlencoded" \
  		-d "grant_type=client_credentials&client_id=$(2)&client_secret=$(3)" \
		| jq -r '.access_token'))
	
	@echo ""
	@echo "Retrieved access token: $(ACCESS_TOKEN)"
	@echo $(ACCESS_TOKEN) > ./tmp/access_token.txt
	@echo ""
	@echo "Token saved to ./tmp/access_token.txt"
endef

get-client1-token:
	$(call get-agentcore-vars)
	$(call get-token,client1,$(COGNITO_CLIENT1_ID),$(COGNITO_CLIENT1_SECRET))

get-client2-token:
	$(call get-agentcore-vars)
	$(call get-token,client2,$(COGNITO_CLIENT2_ID),$(COGNITO_CLIENT2_SECRET))

list-tools:
	$(get-agentcore-vars)
	@echo "Listing tools...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
		| jq .

get-menu:
	$(get-agentcore-vars)
	@echo "Getting menu...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get-menu___get-menu","arguments":{}}}' \
		| jq .


create-order:
	$(get-agentcore-vars)
	$(eval pizzaId := $(or $(pizzaId),1))
	@echo "Creating a new order for pizzaId=$(pizzaId)...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create-order___create-order","arguments":{"pizzaId":$(pizzaId)}}}' \
		| jq .
