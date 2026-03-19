define get-vars
	@echo "get-vars"
	$(eval MEMORY_ID := $(shell cat ./tmp/memory_id.txt))
	$(eval ACTOR_ID := $(shell cat ./tmp/actor_id.txt))
	$(eval SESSION_ID := $(shell cat ./tmp/session_id.txt))
	$(eval STRATEGY_ID := $(shell cat ./tmp/summarization_strategy_id.txt))

	$(info > MEMORY_ID=$(MEMORY_ID))
	$(info > ACTOR_ID=$(ACTOR_ID))
	$(info > SESSION_ID=$(SESSION_ID))
	$(info > STRATEGY_ID=$(STRATEGY_ID))
endef

deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy

create-event:
	$(get-vars)
	echo "Creating event..."
	aws bedrock-agentcore create-event \
		--memory-id ${MEMORY_ID} \
		--session-id ${SESSION_ID} \
		--actor-id ${ACTOR_ID} \
		--event-timestamp $(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--payload file://test-data/payload.json

list-events:
	$(get-vars)
	echo "Listing events..."
	aws bedrock-agentcore list-events \
		--memory-id ${MEMORY_ID} \
		--session-id ${SESSION_ID} \
		--actor-id ${ACTOR_ID}

list-memory-records:
	$(get-vars)
	echo "Listing memory records..."
	aws bedrock-agentcore list-memory-records \
		--memory-id ${MEMORY_ID} \
		--namespace "/strategy/${STRATEGY_ID}/summaries/actors/${ACTOR_ID}/" \
		--memory-strategy-id ${STRATEGY_ID}

retrieve-memory-records:
	$(get-vars)
	echo "Retrieving memory records... "
	aws bedrock-agentcore retrieve-memory-records \
		--memory-id ${MEMORY_ID} \
		--namespace "/strategy/${STRATEGY_ID}/summaries/actors/${ACTOR_ID}/" \
		--search-criteria file://test-data/search-criteria.json


