AWS_CLI_COMMAND_ROOT_AC_CONTROL=aws bedrock-agentcore-control
AWS_CLI_COMMAND_ROOT_AC_DATA=aws bedrock-agentcore
API_KEY_PROVIDER_NAME=test-api-key-provider
API_KEY=abcd1234abcd1234
OAUTH2_PROVIDER_NAME=test-oauth2-provider
OAUTH2_SCOPES=backend/read backend/write
WORKLOAD_IDENTITY_NAME=test-identity

define read-vars
	$(eval COGNITO_ISSUER := $(shell cat ./tmp/cognito_issuer.txt))
	$(eval COGNITO_AUTHZ_ENDPOINT := $(shell cat ./tmp/cognito_authorization_endpoint.txt))
	$(eval COGNITO_TOKEN_ENDPOINT := $(shell cat ./tmp/cognito_token_endpoint.txt))
	$(eval COGNITO_CLIENT_ID := $(shell cat ./tmp/cognito_client_id.txt))
	$(eval COGNITO_CLIENT_SECRET := $(shell cat ./tmp/cognito_client_secret.txt))
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat ./tmp/workload_access_token.txt))

	$(info > COGNITO_ISSUER=$(COGNITO_ISSUER))
	$(info > COGNITO_AUTHZ_ENDPOINT=$(COGNITO_AUTHZ_ENDPOINT))
	$(info > COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT))
	$(info > COGNITO_CLIENT_ID=$(COGNITO_CLIENT_ID))
	$(info > COGNITO_CLIENT_SECRET=$(shell echo $(COGNITO_CLIENT_SECRET) | cut -c1-3)...REDACTED...)
	$(info > WORKLOAD_ACCESS_TOKEN=$(shell echo $(WORKLOAD_ACCESS_TOKEN) | cut -c1-20)...REDACTED...)
endef

include makefiles/infra.mk
include makefiles/oauth2-credential-provider.mk
include makefiles/workload-identities.mk

get-resource-oauth2-token:
	$(call read-vars)
	@echo "Getting OAuth2 token for provider '$(OAUTH2_PROVIDER_NAME)'..."
	$(AWS_CLI_COMMAND_ROOT_AC_DATA) get-resource-oauth2-token \
		--resource-credential-provider-name $(OAUTH2_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes $(OAUTH2_SCOPES) \
		--oauth2-flow "M2M"

