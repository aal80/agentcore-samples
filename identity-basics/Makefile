define read-vars
	$(eval WORKLOAD_IDENTITY_NAME := $(shell cat ./tmp/workload_identity_name.txt))
	$(eval WORKLOAD_ACCESS_TOKEN := $(shell cat ./tmp/workload_access_token.txt))
	$(eval CREDENTIAL_PROVIDER_NAME := $(shell cat ./tmp/credential_provider_name.txt))

	$(info > WORKLOAD_IDENTITY_NAME=$(WORKLOAD_IDENTITY_NAME))
	$(info > WORKLOAD_ACCESS_TOKEN=$(shell echo $(WORKLOAD_ACCESS_TOKEN) | cut -c1-20)...REDACTED...)
	$(info > CREDENTIAL_PROVIDER_NAME=$(CREDENTIAL_PROVIDER_NAME))
endef

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

get-workload-access-token:
	$(call read-vars)
	@echo "Getting workload access token..."
	aws bedrock-agentcore get-workload-access-token \
		--workload-name $(WORKLOAD_IDENTITY_NAME) \
		--query workloadAccessToken --output text > ./tmp/workload_access_token.txt
	
	@echo ""
	@echo "Stored in ./tmp/workload_access_token.txt (preview: $$(cut -c1-20 ./tmp/workload_access_token.txt)...)"

get-resource-api-key:
	$(call read-vars)
	@echo "Getting API key for provider '$(CREDENTIAL_PROVIDER_NAME)'..."
	aws bedrock-agentcore get-resource-api-key \
		--resource-credential-provider-name $(CREDENTIAL_PROVIDER_NAME) \
		--workload-identity-token $(WORKLOAD_ACCESS_TOKEN)

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp
