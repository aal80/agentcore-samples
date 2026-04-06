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
}

resource "local_file" "credential_provider_name" {
  filename = "${path.module}/../tmp/credential_provider_name.txt"
  content  = aws_bedrockagentcore_oauth2_credential_provider.cognito.name
}

output "credential_provider_name" {
  value = aws_bedrockagentcore_oauth2_credential_provider.cognito.name
}
