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

resource "aws_cognito_user_pool_client" "client" {
  name                                 = "${local.project_name}-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = concat(["openid", "email", "profile"], aws_cognito_resource_server.backend.scope_identifiers)
  supported_identity_providers         = ["COGNITO"]
  callback_urls                        = ["https://example.com"] # Updated in oauth2-credential-provider.tf after creation 
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
  depends_on = [aws_cognito_resource_server.backend]

  lifecycle {
    ignore_changes = [callback_urls]
  }
}

locals {
  cognito_token_endpoint         = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/token"
  cognito_authorization_endpoint = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/authorize"
  cognito_issuer                 = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
  cognito_discovery_url          = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/openid-configuration"
}

resource "local_file" "cognito_username" {
  content  = aws_cognito_user.alice.username
  filename = "${path.module}/../tmp/cognito_username.txt"
}

resource "local_file" "cognito_password" {
  content  = aws_cognito_user.alice.password
  filename = "${path.module}/../tmp/cognito_password.txt"
}

resource "local_file" "cognito_scopes" {
  content  = join(" ", aws_cognito_user_pool_client.client.allowed_oauth_scopes)
  filename = "${path.module}/../tmp/cognito_scopes.txt"
}
