get-workload-access-token:
	@echo "Getting workload access token for machine2machine..."
	@mkdir -p ./tmp
	aws bedrock-agentcore get-workload-access-token \
		--workload-name $(WORKLOAD_IDENTITY_NAME) \
		--query workloadAccessToken --output text > ./tmp/workload_access_token.txt
	
	@echo ""
	@echo "Stored in ./tmp/workload_access_token.txt (preview: $$(cut -c1-20 ./tmp/workload_access_token.txt)...)"
