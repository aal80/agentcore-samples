deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

run-execute-code-demo:
	@echo "Running execute code demo..."
	cd src && \
		uv sync && \
		uv run demo_execute_code.py

run-execute-shell-command-demo:
	@echo "Running execute shell command demo..."
	cd src && \
		uv sync && \
		uv run demo_execute_shell_command.py

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp
