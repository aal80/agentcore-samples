deploy-infra:
	@echo "Running terraform apply"
	cd terraform && \
	terraform init && \
	terraform apply --auto-approve

update-congnito-user-pool-client-with-oauth2-credential-provider-callback-url:
	@echo "Updating Cognito user pool client configuration with Oauth2 Credential Provider callback URL..."
	@CALLBACK_URL=$$(cat ./tmp/credentials_provider_callback_url.txt) && \
	echo "CALLBACK_URL=$$CALLBACK_URL" && \
	echo "credential_provider_callback_url = \"$$CALLBACK_URL\"" > terraform/terraform.tfvars
	
	@echo "credential_provider_callback_url injected into ./terraform/terraform.tfvars"
	@echo ""
	@echo "run 'make deploy-infra' to deploy updated Cognito configuration"

destroy:
	@echo "Destroying everything..."
	cd terraform && terraform destroy
	rm -rf tmp
