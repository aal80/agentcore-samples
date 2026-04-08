deploy-infra:
	@echo "Running terraform apply"
	mkdir -p tmp
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

run-demo1:
	@echo "Running demo1..."
	cd src && \
		uv sync && \
		uv run demo1.py

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp
