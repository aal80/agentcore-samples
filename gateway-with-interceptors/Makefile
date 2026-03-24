ECR_REPO_NAME = "gateway-with-interceptors"

define get-agentcore-vars
	@echo "get-agentcore-vars"
	$(eval GATEWAY_URL := $(shell cat ./tmp/gateway_url.txt))

	$(info > GATEWAY_URL=$(GATEWAY_URL))
endef

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

deploy-all: deploy-infra
	@echo "All done!"

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy

list-tools:
	$(get-agentcore-vars)
	@echo "Listing tools...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

get-menu:
	$(get-agentcore-vars)
	@echo "Getting menu...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get-menu___get-menu","arguments":{}}}'

create-order:
	$(get-agentcore-vars)
	@echo "Creating a new order...."
	curl -s -X POST $(GATEWAY_URL) \
		-H "Content-Type: application/json" \
		-d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create-order___create-order","arguments":{"itemIds":[1,2,3]}}}'

