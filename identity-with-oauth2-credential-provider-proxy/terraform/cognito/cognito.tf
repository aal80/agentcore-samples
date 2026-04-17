variable "project_name" {}
variable "region" {}

resource "aws_cognito_user_pool" "this" {
  name = var.project_name
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.project_name
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_resource_server" "gateway_target" {
  identifier   = "gateway_target"
  name         = "gateway_target"
  user_pool_id = aws_cognito_user_pool.this.id

  scope {
    scope_name        = "invoke"
    scope_description = "Invoke the gateway target"
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "${var.project_name}-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["gateway_target/invoke"]
  supported_identity_providers         = ["COGNITO"]
  depends_on = [ aws_cognito_resource_server.gateway_target]
}

resource "aws_secretsmanager_secret" "cognito_client_secret" {
  name                    = "${var.project_name}/cognito-client-secret"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "cognito_client_secret" {
  secret_id     = aws_secretsmanager_secret.cognito_client_secret.id
  secret_string = aws_cognito_user_pool_client.this.client_secret
}

locals {
  cognito_token_endpoint = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${var.region}.amazoncognito.com/oauth2/token"
  cognito_issuer = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
  cognito_discovery_url = "https://cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/openid-configuration"
}

output "cognito_discovery_url" {
  value = local.cognito_discovery_url
}

output "cognito_token_endpoint" {
  value = local.cognito_token_endpoint
}

output "cognito_client_id" {
  value = aws_cognito_user_pool_client.this.id
}

output "cognito_client_secret_arn" {
  value = aws_secretsmanager_secret.cognito_client_secret.arn
}

resource "local_file" "cognito_discovery_url" {
  content         = local.cognito_discovery_url
  filename        = "${path.root}/../tmp/cognito_discovery_url.txt"
}

resource "local_file" "cognito_token_endpoint" {
  content         = local.cognito_token_endpoint
  filename        = "${path.root}/../tmp/cognito_token_endpoint.txt"
}

resource "local_file" "cognito_client_id" {
  content         = aws_cognito_user_pool_client.this.id
  filename        = "${path.root}/../tmp/cognito_client_id.txt"
}

resource "local_file" "cognito_client_secret_arn" {
  content  = aws_secretsmanager_secret.cognito_client_secret.arn
  filename = "${path.root}/../tmp/cognito_client_secret_arn.txt"
}
