define read-vars
	$(eval WORKLOAD_IDENTITY_NAME := $(shell cat ./tmp/workload_identity_name.txt))
	$(eval CREDENTIAL_PROVIDER_NAME := $(shell cat ./tmp/credential_provider_name.txt))
	$(eval COGNITO_USERNAME := $(shell cat ./tmp/cognito_username.txt))
	$(eval COGNITO_PASSWORD := $(shell cat ./tmp/cognito_password.txt))
	$(eval COGNITO_SCOPES := $(shell cat ./tmp/cognito_scopes.txt))
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat ./tmp/workload_access_token.txt))

	$(info > WORKLOAD_IDENTITY_NAME=$(WORKLOAD_IDENTITY_NAME))
	$(info > CREDENTIAL_PROVIDER_NAME=$(CREDENTIAL_PROVIDER_NAME))
	$(info > COGNITO_USERNAME=$(COGNITO_USERNAME))
	$(info > COGNITO_PASSWORD=$(COGNITO_PASSWORD))
	$(info > COGNITO_SCOPES=$(COGNITO_SCOPES))
	$(info > WORKLOAD_ACCESS_TOKEN=$(shell echo $(WORKLOAD_ACCESS_TOKEN) | cut -c1-20)...REDACTED...)

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

get-workload-access-token-for-user-id:
	$(call read-vars)
	@echo "Getting workload access token for user federation..."
	aws bedrock-agentcore get-workload-access-token-for-user-id \
		--workload-name $(WORKLOAD_IDENTITY_NAME) \
		--user-id $(COGNITO_USERNAME) \
		--query workloadAccessToken --output text > ./tmp/workload_access_token.txt
	
	@echo ""
	@echo "Stored in ./tmp/workload_access_token.txt (preview: $$(cut -c1-20 ./tmp/workload_access_token.txt)...)"

start-resource-oauth2-token-workflow:
	$(call read-vars)
	@echo "Starting authentication workflow for OAuth2 provider '$(CREDENTIAL_PROVIDER_NAME)'..."

	@response=$$(aws bedrock-agentcore get-resource-oauth2-token \
		--resource-credential-provider-name $(CREDENTIAL_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes "$(COGNITO_SCOPES)" \
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
	@echo ""
	@echo "Open the above authorizationUrl in your browser and use username=${COGNITO_USERNAME} password=${COGNITO_PASSWORD}"
	@echo ""
	@echo "After successful authentication browser will be redirected to http://localhost/?session_id=xxxx. You'll get an error. This is expected"

complete-resource-token-auth:
	$(call read-vars)
	@echo "Finishing authentication workflow for OAuth2 provider '$(CREDENTIAL_PROVIDER_NAME)'..."
	@AUTHZ_SESSION_URI=$$(cat ./tmp/authorization_session_uri.txt) && \
		echo AUTHZ_SESSION_URI=$$AUTHZ_SESSION_URI && \
		aws bedrock-agentcore complete-resource-token-auth \
			--session-uri $$AUTHZ_SESSION_URI \
			--user-identifier '{"userId":"$(COGNITO_USERNAME)"}'

get-resource-access-token-after-authentication:
	$(call read-vars)
	aws bedrock-agentcore get-resource-oauth2-token \
		--resource-credential-provider-name $(CREDENTIAL_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN) \
		--scopes "$(COGNITO_SCOPES)" \
		--oauth2-flow "USER_FEDERATION" \
		--resource-oauth2-return-url "http://localhost"

