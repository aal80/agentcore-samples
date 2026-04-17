COGNITO_SCOPE := gateway_target/invoke

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp

get-cognito-token:
	@echo "Getting a new token..."

	$(eval COGNITO_TOKEN_ENDPOINT := $(shell cat tmp/cognito_token_endpoint.txt))
	$(eval COGNITO_CLIENT_ID := $(shell cat tmp/cognito_client_id.txt))
	$(eval COGNITO_CLIENT_SECRET_ARN := $(shell cat tmp/cognito_client_secret_arn.txt))

	@echo COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT)
	@echo COGNITO_CLIENT_ID=$(COGNITO_CLIENT_ID)
	@echo COGNITO_CLIENT_SECRET_ARN=$(COGNITO_CLIENT_SECRET_ARN)
	@echo COGNITO_SCOPE=$(COGNITO_SCOPE)

	$(eval COGNITO_CLIENT_SECRET := $(shell aws secretsmanager get-secret-value \
		--secret-id $(COGNITO_CLIENT_SECRET_ARN) \
		--query SecretString --output text))

	$(eval ACCESS_TOKEN := $(shell curl -s -X POST $(COGNITO_TOKEN_ENDPOINT) \
  		-H "Content-Type: application/x-www-form-urlencoded" \
  		-d "grant_type=client_credentials&client_id=$(COGNITO_CLIENT_ID)&client_secret=$(COGNITO_CLIENT_SECRET)&scope=$(COGNITO_SCOPE)" \
		| jq -r '.access_token'))
	
	@echo ""
	@echo "Retrieved cognito access token:"
	@echo $(ACCESS_TOKEN)

get-workload-access-token:
	$(eval WORKLOAD_IDENTITY_NAME := $(shell cat tmp/workload_identity_name.txt))

	@echo WORKLOAD_IDENTITY_NAME=$(WORKLOAD_IDENTITY_NAME)


	@echo "Getting workload access token for machine2machine..."
	aws bedrock-agentcore get-workload-access-token \
		--workload-name $(WORKLOAD_IDENTITY_NAME) \
		--query workloadAccessToken --output text > ./tmp/workload_access_token.txt

	@echo ""
	@echo "Retrieved workload access token:"
	@cat ./tmp/workload_access_token.txt
	@echo ""
	@echo "Token saved to ./tmp/workload_access_token.txt"

get-resource-oauth2-token:
	$(eval CREDENTIAL_PROVIDER_NAME := $(shell cat tmp/credential_provider_name.txt))
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat tmp/workload_access_token.txt))


	@echo "Getting OAuth2 token for provider '$(CREDENTIAL_PROVIDER_NAME)'..."
	aws bedrock-agentcore get-resource-oauth2-token \
		--resource-credential-provider-name $(CREDENTIAL_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes $(COGNITO_SCOPE) \
		--oauth2-flow "M2M" \
		--query accessToken --output text > ./tmp/resource_access_token.txt

	@echo ""
	@echo "Retrieved resource access token:"
	@cat ./tmp/resource_access_token.txt
	@echo ""
	@echo "Token saved to ./tmp/resource_access_token.txt"

