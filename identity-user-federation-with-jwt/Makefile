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
	$(eval COGNITO_USERNAME := $(shell cat ./tmp/cognito_username.txt))
	$(eval COGNITO_PASSWORD := $(shell cat ./tmp/cognito_password.txt))
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat ./tmp/workload_access_token.txt))

	$(info > COGNITO_ISSUER=$(COGNITO_ISSUER))
	$(info > COGNITO_AUTHZ_ENDPOINT=$(COGNITO_AUTHZ_ENDPOINT))
	$(info > COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT))
	$(info > COGNITO_CLIENT_ID=$(COGNITO_CLIENT_ID))
	$(info > COGNITO_CLIENT_SECRET=$(shell echo $(COGNITO_CLIENT_SECRET) | cut -c1-3)...REDACTED...)
	$(info > COGNITO_USERNAME=$(COGNITO_USERNAME))
	$(info > COGNITO_PASSWORD=$(COGNITO_PASSWORD))
	$(info > WORKLOAD_ACCESS_TOKEN=$(shell echo $(WORKLOAD_ACCESS_TOKEN) | cut -c1-20)...REDACTED...)

endef

include makefiles/infra.mk
include makefiles/oauth2-credential-provider.mk
include makefiles/workload-identities.mk

start-resource-oauth2-token-workflow:
	$(call read-vars)
	@echo "Starting authentication workflow for OAuth2 provider '$(OAUTH2_PROVIDER_NAME)'..."
	
	@response=$$($(AWS_CLI_COMMAND_ROOT_AC_DATA) get-resource-oauth2-token \
		--resource-credential-provider-name $(OAUTH2_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes "$(OAUTH2_SCOPES)" \
		--oauth2-flow "USER_FEDERATION" \
		--resource-oauth2-return-url "http://localhost" \
		--output json) && \
	echo "$$response" | jq -r '.authorizationUrl' > ./tmp/authorization_url.txt && \
	echo "$$response" | jq -r '.sessionUri' > ./tmp/authorization_session_uri.txt
	
	@echo ""
	@echo "authorizationUrl stored in ./tmp/authorization_url.txt"
	@cat ./tmp/authorization_url.txt
	@echo ""
	@echo "sessionUri stored in ./tmp/authorization_session_uri.txt"
	@cat ./tmp/authorization_session_uri.txt

complete-resource-token-auth:
	$(call read-vars)
	@echo "Finishing authentication workflow for OAuth2 provider '$(OAUTH2_PROVIDER_NAME)'..."
	@AUTHZ_SESSION_URI=$$(cat ./tmp/authorization_session_uri.txt) && \
		echo AUTHZ_SESSION_URI=$$AUTHZ_SESSION_URI && \
		$(AWS_CLI_COMMAND_ROOT_AC_DATA) complete-resource-token-auth \
			--session-uri $$AUTHZ_SESSION_URI \
			--user-identifier '{"userId":"test-user"}'

finish:
	$(call read-vars)
	$(AWS_CLI_COMMAND_ROOT_AC_DATA) get-resource-oauth2-token \
		--resource-credential-provider-name $(OAUTH2_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes "$(OAUTH2_SCOPES)" \
		--oauth2-flow "USER_FEDERATION" \
		--resource-oauth2-return-url "http://localhost"