list-workload-identities:
	@echo "Listing workload identities..."
	aws bedrock-agentcore-control list-workload-identities

create-workload-identity:
	@echo "Creating a new workload identity..."
	aws bedrock-agentcore-control create-workload-identity \
		--name $(WORKLOAD_IDENTITY_NAME)

get-workload-identity:
	@echo "Getting the workload identity..."
	aws bedrock-agentcore-control get-workload-identity \
		--name $(WORKLOAD_IDENTITY_NAME)

delete-workload-identity:
	@echo "Deleting workload identity..."
	aws bedrock-agentcore-control delete-workload-identity \
		--name $(WORKLOAD_IDENTITY_NAME)

