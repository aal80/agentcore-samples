list-workload-identities:
	@echo "Listing workload identities..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) list-workload-identities

create-workload-identity:
	@echo "Creating a new workload identity..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) create-workload-identity \
		--name $(WORKLOAD_IDENTITY_NAME)

get-workload-identity:
	@echo "Getting the workload identity..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) get-workload-identity \
		--name $(WORKLOAD_IDENTITY_NAME)

delete-workload-identity:
	@echo "Deleting workload identity..."
	$(AWS_CLI_COMMAND_ROOT_AC_CONTROL) delete-workload-identity \
		--name $(WORKLOAD_IDENTITY_NAME)

get-workload-access-token-for-user-id:
	@echo "Getting workload access token for user federation..."
	$(AWS_CLI_COMMAND_ROOT_AC_DATA) get-workload-access-token-for-user-id \
		--workload-name $(WORKLOAD_IDENTITY_NAME) \
		--user-id test-user \
		--query workloadAccessToken --output text > ./tmp/workload_access_token.txt
	
	@echo ""
	@echo "Stored in ./tmp/workload_access_token.txt (preview: $$(cut -c1-20 ./tmp/workload_access_token.txt)...)"

