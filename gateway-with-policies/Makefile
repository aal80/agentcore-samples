define get-agentcore-vars
	@echo "get-agentcore-vars"
	$(eval GATEWAY_URL := $(shell cat ./tmp/gateway_url.txt))
	$(eval COGNITO_TOKEN_ENDPOINT := $(shell cat ./tmp/cognito_token_endpoint.txt))
	$(eval COGNITO_CLIENT1_ID := $(shell cat ./tmp/cognito_client1_id.txt))
	$(eval COGNITO_CLIENT1_SECRET := $(shell cat ./tmp/cognito_client1_secret.txt))
	$(eval COGNITO_CLIENT2_ID := $(shell cat ./tmp/cognito_client2_id.txt))
	$(eval COGNITO_CLIENT2_SECRET := $(shell cat ./tmp/cognito_client2_secret.txt))
	$(eval ACCESS_TOKEN := $(shell cat ./tmp/access_token.txt))

	$(info > GATEWAY_URL=$(GATEWAY_URL))
	$(info > COGNITO_TOKEN_ENDPOINT=$(COGNITO_TOKEN_ENDPOINT))
	$(info > COGNITO_CLIENT1_ID=$(COGNITO_CLIENT1_ID))
	$(info > COGNITO_CLIENT1_SECRET=$(shell echo $(COGNITO_CLIENT1_SECRET) | cut -c1-3)...REDACTED...)
	$(info > COGNITO_CLIENT2_ID=$(COGNITO_CLIENT2_ID))
	$(info > COGNITO_CLIENT2_SECRET=$(shell echo $(COGNITO_CLIENT2_SECRET) | cut -c1-3)...REDACTED...)
	$(info > ACCESS_TOKEN=$(shell echo $(ACCESS_TOKEN) | cut -c1-10)...REDACTED...)
endef

deploy-all-recreate-gateway:
	@echo "Running terraform apply & recreating gateway + related resources"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve \
		--replace="random_string.gateway_name_suffix" \
		--replace="awscc_bedrockagentcore_gateway.this" 

deploy-all: 
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve
	@echo "All done!"

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy

define get-token
	@echo "Getting a new token for $(1)..."
	$(eval ACCESS_TOKEN := $(shell curl -s -X POST $(COGNITO_TOKEN_ENDPOINT) \
  		-H "Content-Type: application/x-www-form-urlencoded" \
  		-d "grant_type=client_credentials&client_id=$(2)&client_secret=$(3)" \
		| jq -r '.access_token'))
	
	@echo ""
	@echo "Retrieved access token: $(ACCESS_TOKEN)"
	@echo $(ACCESS_TOKEN) > ./tmp/access_token.txt
	@echo ""
	@echo "Token saved to ./tmp/access_token.txt"
endef

get-client1-token:
	$(call get-agentcore-vars)
	$(call get-token,client1,$(COGNITO_CLIENT1_ID),$(COGNITO_CLIENT1_SECRET))

get-client2-token:
	$(call get-agentcore-vars)
	$(call get-token,client2,$(COGNITO_CLIENT2_ID),$(COGNITO_CLIENT2_SECRET))

list-tools:
	$(get-agentcore-vars)
	@echo "Listing tools...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
		| jq .

get-menu:
	$(get-agentcore-vars)
	@echo "Getting menu...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get-menu___get-menu","arguments":{}}}' \
		| jq .


create-order:
	$(get-agentcore-vars)
	$(eval pizzaId := $(or $(pizzaId),1))
	@echo "Creating a new order for pizzaId=$(pizzaId)...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $(ACCESS_TOKEN)" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create-order___create-order","arguments":{"pizzaId":$(pizzaId)}}}' \
		| jq .

