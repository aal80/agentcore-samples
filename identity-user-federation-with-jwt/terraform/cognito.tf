resource "aws_cognito_user_pool" "this" {
  name                     = local.project_name
  auto_verified_attributes = ["email"]
}

resource "aws_cognito_user" "alice" {
  user_pool_id   = aws_cognito_user_pool.this.id
  username       = "alice@example.com"
  password       = "qweQWE123!@#"
  message_action = "SUPPRESS"

  attributes = {
    email          = "alice@example.com"
    email_verified = "true"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.project_name
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_resource_server" "backend" {
  identifier   = "backend"
  name         = "backend"
  user_pool_id = aws_cognito_user_pool.this.id

  scope {
    scope_name        = "read"
    scope_description = "read"
  }

  scope {
    scope_name        = "write"
    scope_description = "write"
  }
}

variable "credential_provider_callback_url" {
  default = "http://localhost"
}

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "${local.project_name}-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = concat(["openid", "email", "profile"], aws_cognito_resource_server.backend.scope_identifiers)
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = [var.credential_provider_callback_url]
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  depends_on = [aws_cognito_resource_server.backend]
}

locals {
  cognito_token_endpoint         = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/token"
  cognito_authorization_endpoint = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/authorize"
  cognito_issuer                 = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
  cognito_discovery_url          = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/openid-configuration"
}

resource "local_file" "cognito_token_endpoint" {
  content  = local.cognito_token_endpoint
  filename = "${path.module}/../tmp/cognito_token_endpoint.txt"
}

resource "local_file" "cognito_authorization_endpoint" {
  content  = local.cognito_authorization_endpoint
  filename = "${path.module}/../tmp/cognito_authorization_endpoint.txt"
}

resource "local_file" "cognito_issuer" {
  content  = local.cognito_issuer
  filename = "${path.module}/../tmp/cognito_issuer.txt"
}

resource "local_file" "cognito_discovery_url" {
  content  = local.cognito_discovery_url
  filename = "${path.module}/../tmp/cognito_discovery_url.txt"
}

resource "local_file" "cognito_client_id" {
  content  = aws_cognito_user_pool_client.client.id
  filename = "${path.module}/../tmp/cognito_client_id.txt"
}

resource "local_file" "cognito_client_secret" {
  content  = aws_cognito_user_pool_client.client.client_secret
  filename = "${path.module}/../tmp/cognito_client_secret.txt"
}

resource "local_file" "cognito_username" {
  content  = aws_cognito_user.alice.username
  filename = "${path.module}/../tmp/cognito_username.txt"
}

resource "local_file" "cognito_password" {
  content  = aws_cognito_user.alice.password
  filename = "${path.module}/../tmp/cognito_password.txt"
}


