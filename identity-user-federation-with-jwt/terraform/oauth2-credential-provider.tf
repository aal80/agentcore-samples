resource "aws_bedrockagentcore_oauth2_credential_provider" "cognito" {
  name                       = local.project_name
  credential_provider_vendor = "CustomOauth2"
  oauth2_provider_config {
    custom_oauth2_provider_config {
      client_id     = aws_cognito_user_pool_client.client.id
      client_secret = aws_cognito_user_pool_client.client.client_secret
      oauth_discovery {
        discovery_url = local.cognito_discovery_url
      }
    }
  }

  depends_on = [ aws_cognito_user_pool_client.client ]
}

# The Terraform provider does not expose callbackUrl from the API response, so we
# fetch it via the AWS CLI and register it with the Cognito client after creation.
# Re-runs whenever the credential provider is recreated (ARN change).
resource "null_resource" "update_cognito_callback" {
  triggers = {
    credential_provider_arn = aws_bedrockagentcore_oauth2_credential_provider.cognito.credential_provider_arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      CALLBACK_URL=$(aws bedrock-agentcore-control get-oauth2-credential-provider \
        --name "${aws_bedrockagentcore_oauth2_credential_provider.cognito.name}" \
        --query 'callbackUrl' --output text)
        
      aws cognito-idp update-user-pool-client \
        --user-pool-id "${aws_cognito_user_pool.this.id}" \
        --client-id "${aws_cognito_user_pool_client.client.id}" \
        --callback-urls "$CALLBACK_URL"
    EOT
  }
}

resource "local_file" "credential_provider_name" {
  filename = "${path.module}/../tmp/credential_provider_name.txt"
  content  = aws_bedrockagentcore_oauth2_credential_provider.cognito.name
}

output "credential_provider_name" {
  value = aws_bedrockagentcore_oauth2_credential_provider.cognito.name
}
