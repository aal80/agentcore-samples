PROVIDER_CONFIG='{"includedOauth2ProviderConfig":{"clientId":"$(COGNITO_CLIENT_ID)","clientSecret":"$(COGNITO_CLIENT_SECRET)","issuer":"$(COGNITO_ISSUER)","authorizationEndpoint":"$(COGNITO_AUTHZ_ENDPOINT)","tokenEndpoint":"$(COGNITO_TOKEN_ENDPOINT)"}}'

list-oauth2-credential-providers:
	@echo "Listing OAuth2 credential providers..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) list-oauth2-credential-providers

create-oauth2-credential-provider:
	$(call read-vars)
	@echo "Creating an OAuth2 credential provider..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) create-oauth2-credential-provider \
		--name $(OAUTH2_PROVIDER_NAME) \
		--credential-provider-vendor CognitoOauth2 \
		--oauth2-provider-config-input $(PROVIDER_CONFIG)

get-oauth2-credential-provider:
	@echo "Getting the OAuth2 credential provider..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) get-oauth2-credential-provider \
		--name $(OAUTH2_PROVIDER_NAME) 

get-oauth2-credential-provider-callback-url:
	@$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) get-oauth2-credential-provider \
		--name $(OAUTH2_PROVIDER_NAME) \
		--output json | jq -r '.callbackUrl' > ./tmp/credentials_provider_callback_url.txt
	@echo ""
	@echo "callbackUrl stored in ./tmp/credentials_provider_callback_url.txt"
	@cat ./tmp/credentials_provider_callback_url.txt


delete-oauth2-credential-provider:
	@echo "Deleting Oauth2 credential provider..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) delete-oauth2-credential-provider \
		--name $(OAUTH2_PROVIDER_NAME) 

