AWS_CLI_COMMAND_ROOT_AC_CONTROL=aws bedrock-agentcore-control
AWS_CLI_COMMAND_ROOT_AC_DATA=aws bedrock-agentcore
API_KEY_PROVIDER_NAME=test-api-key-provider
API_KEY=abcd1234abcd1234
WORKLOAD_IDENTITY_NAME=test-identity

define read-vars
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat ./tmp/workload_access_token.txt))

	$(info > WORKLOAD_ACCESS_TOKEN=$(shell echo $(WORKLOAD_ACCESS_TOKEN) | cut -c1-20)...REDACTED...)
endef

include makefiles/workload-identities.mk
include makefiles/api-key-credential-provider.mk
include makefiles/workload-tokens.mk

get-resource-api-key:
	$(call read-vars)
	@echo "Getting API key for provider '$(API_KEY_PROVIDER_NAME)'..."
	aws bedrock-agentcore get-resource-api-key \
		--resource-credential-provider-name $(API_KEY_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN)

	