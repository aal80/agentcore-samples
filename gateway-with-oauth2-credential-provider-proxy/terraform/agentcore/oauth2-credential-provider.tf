variable "project_name" {}
variable "client_id" {}
variable "client_secret_arn" {}
variable "discovery_url" {}

data "aws_secretsmanager_secret_version" "client_secret" {
  secret_id = var.client_secret_arn
}

resource "aws_bedrockagentcore_oauth2_credential_provider" "oauth2_proxy" {
  name                       = var.project_name
  credential_provider_vendor = "CustomOauth2"
  oauth2_provider_config {
    custom_oauth2_provider_config {
      client_id     = var.client_id
      client_secret = data.aws_secretsmanager_secret_version.client_secret.secret_string
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
