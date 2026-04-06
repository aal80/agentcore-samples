OAUTH2_SCOPES=backend/read backend/write

define read-vars
	$(eval WORKLOAD_IDENTITY_NAME := $(shell cat ./tmp/workload_identity_name.txt))
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat ./tmp/workload_access_token.txt))
	$(eval CREDENTIAL_PROVIDER_NAME := $(shell cat ./tmp/credential_provider_name.txt))
	$(eval COGNITO_SCOPES := $(shell cat ./tmp/cognito_scopes.txt))

	$(info > WORKLOAD_IDENTITY_NAME=$(WORKLOAD_IDENTITY_NAME))
	$(info > WORKLOAD_ACCESS_TOKEN=$(shell echo $(WORKLOAD_ACCESS_TOKEN) | cut -c1-20)...REDACTED...)
	$(info > CREDENTIAL_PROVIDER_NAME=$(CREDENTIAL_PROVIDER_NAME))
	$(info > COGNITO_SCOPES=$(COGNITO_SCOPES))
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

get-workload-access-token:
	$(call read-vars)
	@echo "Getting workload access token for machine2machine..."
	aws bedrock-agentcore get-workload-access-token \
		--workload-name $(WORKLOAD_IDENTITY_NAME) \
		--query workloadAccessToken --output text > ./tmp/workload_access_token.txt
	
	@echo ""
	@echo "Stored in ./tmp/workload_access_token.txt (preview: $$(cut -c1-20 ./tmp/workload_access_token.txt)...)"

get-resource-oauth2-token:
	$(call read-vars)
	@echo "Getting OAuth2 token for provider '$(CREDENTIAL_PROVIDER_NAME)'..."
	aws bedrock-agentcore get-resource-oauth2-token \
		--resource-credential-provider-name $(CREDENTIAL_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes $(COGNITO_SCOPES) \
		--oauth2-flow "M2M"

