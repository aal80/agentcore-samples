resource "aws_bedrockagentcore_oauth2_credential_provider" "oauth2_proxy" {
  name                       = var.project_name
  credential_provider_vendor = "CustomOauth2"
  oauth2_provider_config {
    custom_oauth2_provider_config {
      client_id     = var.client_id
      client_secret = var.client_secret
      oauth_discovery {
        discovery_url = var.discovery_url
      }
    }
  }
}

resource "local_file" "credential_provider_name" {
  filename = "${path.root}/../tmp/credential_provider_name.txt"
  content  = aws_bedrockagentcore_oauth2_credential_provider.oauth2_proxy.name
}

output "credential_provider_name" {
  value = aws_bedrockagentcore_oauth2_credential_provider.oauth2_proxy.name
}
