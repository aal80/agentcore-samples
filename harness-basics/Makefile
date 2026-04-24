HARNESS_NAME = "test_harness"
HARNESS_IAM_ROLE_ARN = $(shell cat tmp/harness_iam_role_arn.txt 2>/dev/null)
HARNESS_ID = $(shell cat tmp/harness_id.txt 2>/dev/null)
HARNESS_ARN = $(shell cat tmp/harness_arn.txt 2>/dev/null)
MEMORY_ARN = $(shell cat tmp/memory_arn.txt 2>/dev/null)

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp

list-harnesses:
	@echo "listing harness..."
	aws bedrock-agentcore-control list-harnesses \
		--output yaml \
		--no-cli-pager

create-harness:
	@echo "Creating harness..."

	aws bedrock-agentcore-control create-harness \
		--harness-name $(HARNESS_NAME) \
		--execution-role-arn "$(HARNESS_IAM_ROLE_ARN)" \
		--model '{"bedrockModelConfig": {"modelId": "us.amazon.nova-2-lite-v1:0"}}' \
  		--system-prompt '[{"text": "You are a famous chef. Your replies MUST be less than 100 words."}]' \
		--output json \
		--no-cli-pager \
		> ./tmp/_.tmp

	@echo $$(cat ./tmp/_.tmp) | jq .

	@jq -r '.harness.harnessId' ./tmp/_.tmp > ./tmp/harness_id.txt
	@echo "Harness Id=$$(cat ./tmp/harness_id.txt)"

	@jq -r '.harness.arn' ./tmp/_.tmp > ./tmp/harness_arn.txt
	@echo "Harness Arn=$$(cat ./tmp/harness_arn.txt)"
	
	@rm ./tmp/_.tmp

get-harness:
	@echo "Getting harness..."
	aws bedrock-agentcore-control get-harness \
		--harness-id $(HARNESS_ID) \
		--output yaml \
		--no-cli-pager

delete-harness:
	@echo "Deleting harness..."
	aws bedrock-agentcore-control delete-harness \
		--harness-id $(HARNESS_ID) \
		--output yaml \
		--no-cli-pager

demo-basics:
	@echo "Running demo-basics..."
	cd src && uv sync && uv run demo-basics.py

demo-tools:
	@echo "Running demo-tools..."
	cd src && uv sync && uv run demo-tools.py

update-harness-for-memory:
	@echo "Updating harness with memory configuration..."
	aws bedrock-agentcore-control update-harness \
		--harness-id $(HARNESS_ID) \
		--memory '{"optionalValue": {"agentCoreMemoryConfiguration": {"arn": "$(MEMORY_ARN)"}}}' \
		--output yaml \
		--no-cli-pager

demo-memory:
	@echo "Running demo-memory..."
	cd src && uv sync && uv run demo-memory.py