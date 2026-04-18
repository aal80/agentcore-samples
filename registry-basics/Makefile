REGISTRY_NAME := "test-registy-1"
MCP_RECORD_NAME := "mcp-server-1"

prep-tmp:
	@mkdir -p tmp

define get-vars
	$(eval REGISTRY_ARN := $(shell cat tmp/registry_arn.txt))
	$(eval RECORD_ARN := $(shell cat tmp/registry_record_arn.txt))
	@echo "REGISTRY_ARN=$(REGISTRY_ARN)"
	@echo "RECORD_ARN=$(RECORD_ARN)"
endef

# ----- REGISTRIES -----
list-registries:
	@echo "Listing registries..."
	aws bedrock-agentcore-control list-registries \
		--output yaml

create-registry: prep-tmp
	@echo "Creating registry..."

	@echo "REGISTRY_NAME=$(REGISTRY_NAME)"

	aws bedrock-agentcore-control create-registry \
		--name $(REGISTRY_NAME) \
		--query 'registryArn' --output text > tmp/registry_arn.txt
	
	@echo "Registry ARN: $$(cat tmp/registry_arn.txt)"
	@echo "Saved to tmp/registry_arn.txt"

get-registry:
	@echo "Getting registry..."
	$(eval REGISTRY_ARN := $(shell cat tmp/registry_arn.txt))

	@echo "REGISTRY_ARN=$(REGISTRY_ARN)"

	aws bedrock-agentcore-control get-registry \
		--registry-id $(REGISTRY_ARN) \
		--output yaml \
		--no-cli-pager
	
delete-registry: 
	@echo "Deleting registry..."
	$(eval REGISTRY_ARN := $(shell cat tmp/registry_arn.txt))

	@echo "REGISTRY_ARN=$(REGISTRY_ARN)"

	aws bedrock-agentcore-control delete-registry \
		--registry-id $(REGISTRY_ARN) \
		--no-cli-pager

# ----- REGISTRY RECORDS -----
list-records:
	@echo "Listing registry records..."
	$(eval REGISTRY_ARN := $(shell cat tmp/registry_arn.txt))

	@echo "REGISTRY_ARN=$(REGISTRY_ARN)"

	aws bedrock-agentcore-control list-registry-records \
		--registry-id $(REGISTRY_ARN) \
		--output yaml

create-mcp-record: prep-tmp
	@echo "Creating MCP registry record..."
	$(eval REGISTRY_ARN := $(shell cat tmp/registry_arn.txt))

	@echo "REGISTRY_ARN=$(REGISTRY_ARN)"
	@echo "MCP_RECORD_NAME=$(MCP_RECORD_NAME)"

	aws bedrock-agentcore-control create-registry-record \
		--registry-id $(REGISTRY_ARN) \
		--name $(MCP_RECORD_NAME) \
		--descriptor-type "MCP" \
		--descriptors '{"mcp": {"server": {"inlineContent": "{\"name\": \"weather/mcp-server\", \"description\": \"Weather data service\", \"version\": \"1.0.0\"}"}}}' \
		--output yaml \
		--query 'recordArn' --output text > tmp/registry_record_arn.txt

	@echo "Registry Record ARN: $$(cat tmp/registry_record_arn.txt)"
	@echo "Saved to tmp/registry_record_arn.txt"

get-record:
	@echo "Getting registry record..."
	$(call get-vars)
	
	aws bedrock-agentcore-control get-registry-record \
		--registry-id $(REGISTRY_ARN) \
		--record-id $(RECORD_ARN) \
		--output yaml \
		--no-cli-pager

delete-record:
	@echo "Deleting registry record",
	$(call get-vars)

	aws bedrock-agentcore-control delete-registry-record \
		--registry-id $(REGISTRY_ARN) \
		--record-id $(RECORD_ARN) \
		--no-cli-pager

# ----- REGISTRY RECORDS APPROVALS -----
submit-registry-record-for-approval:	
	@echo "Submitting registry record for approval...",
	$(call get-vars)

	aws bedrock-agentcore-control submit-registry-record-for-approval \
		--registry-id $(REGISTRY_ARN) \
		--record-id $(RECORD_ARN) \
		--no-cli-pager

approve-registry-record:
	@echo "Approving registry record...",
	$(call get-vars)

	aws bedrock-agentcore-control update-registry-record-status \
		--registry-id $(REGISTRY_ARN) \
		--record-id $(RECORD_ARN) \
		--status "APPROVED" \
		--status-reason "Approved by administrator! All's good!" \
		--no-cli-pager

reject-registry-record:
	@echo "Rejecting registry record...",
	$(call get-vars)

	aws bedrock-agentcore-control update-registry-record-status \
		--registry-id $(REGISTRY_ARN) \
		--record-id $(RECORD_ARN) \
		--status "REJECTED" \
		--status-reason "Rejected, doesn't meet the organizational requirements." \
		--no-cli-pager

deprecate-registry-record:
	@echo "Deprecating registry record...",
	$(call get-vars)
	
	aws bedrock-agentcore-control update-registry-record-status \
		--registry-id $(REGISTRY_ARN) \
		--record-id $(RECORD_ARN) \
		--status "DEPRECATED" \
		--status-reason "Deprecated. Should no longer be used." \
		--no-cli-pager

search-records:
	@echo "Searching records...",
	$(call get-vars)
	
	aws bedrock-agentcore search-registry-records \
		--registry-id $(REGISTRY_ARN) \
		--search-query "weather forecast tool" \
		--max-results 5 \
		--no-cli-pager
