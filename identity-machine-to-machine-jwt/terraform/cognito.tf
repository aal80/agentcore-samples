resource "aws_cognito_user_pool" "this" {
  name = local.project_name
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
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["backend/read", "backend/write"]
  supported_identity_providers         = ["COGNITO"]
  depends_on                           = [aws_cognito_resource_server.backend]
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
