list-api-key-credential-providers:
	@echo "Listing API key credential providers..."
	aws bedrock-agentcore-control list-api-key-credential-providers

create-api-key-credential-provider:
	@echo "Creating an API key credential provider..."
	aws bedrock-agentcore-control create-api-key-credential-provider \
		--name $(API_KEY_PROVIDER_NAME) \
		--api-key $(API_KEY)

get-api-key-credential-provider:
	@echo "Getting the API key credential provider..."
	aws bedrock-agentcore-control get-api-key-credential-provider \
		--name $(API_KEY_PROVIDER_NAME) 

delete-api-key-credential-provider:
	@echo "Deleting API key credential provider..."
	aws bedrock-agentcore-control delete-api-key-credential-provider \
		--name $(API_KEY_PROVIDER_NAME) 
