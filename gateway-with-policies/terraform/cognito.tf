resource "aws_cognito_user_pool" "this" {
  name = local.project_name
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.project_name
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_resource_server" "gateway" {
  identifier   = "gateway"
  name         = "gateway"
  user_pool_id = aws_cognito_user_pool.this.id

  scope {
    scope_name        = "get_menu"
    scope_description = "Retrieve the pizza menu"
  }

  scope {
    scope_name        = "create_order"
    scope_description = "Create a new order"
  }
}

resource "aws_cognito_user_pool_client" "client1" {
  name                                 = "${local.project_name}-client1"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["gateway/get_menu"]
  supported_identity_providers         = ["COGNITO"]
  depends_on                           = [aws_cognito_resource_server.gateway]
}

resource "aws_cognito_user_pool_client" "client2" {
  name                                 = "${local.project_name}-client2"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["gateway/get_menu", "gateway/create_order"]
  supported_identity_providers         = ["COGNITO"]
  depends_on                           = [aws_cognito_resource_server.gateway]
}

locals {
  cognito_token_endpoint = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/token"
  cognito_issuer         = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
  cognito_discovery_url  = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/openid-configuration"
}

resource "local_file" "cognito_token_endpoint" {
  content  = local.cognito_token_endpoint
  filename = "${path.module}/../tmp/cognito_token_endpoint.txt"
}

resource "local_file" "cognito_issuer" {
  content  = local.cognito_issuer
  filename = "${path.module}/../tmp/cognito_issuer.txt"
}

resource "local_file" "cognito_discovery_url" {
  content  = local.cognito_discovery_url
  filename = "${path.module}/../tmp/cognito_discovery_url.txt"
}

resource "local_file" "cognito_client1_id" {
  content  = aws_cognito_user_pool_client.client1.id
  filename = "${path.module}/../tmp/cognito_client1_id.txt"
}

resource "local_file" "cognito_client1_secret" {
  content  = aws_cognito_user_pool_client.client1.client_secret
  filename = "${path.module}/../tmp/cognito_client1_secret.txt"
}

resource "local_file" "cognito_client2_id" {
  content  = aws_cognito_user_pool_client.client2.id
  filename = "${path.module}/../tmp/cognito_client2_id.txt"
}

resource "local_file" "cognito_client2_secret" {
  content  = aws_cognito_user_pool_client.client2.client_secret
  filename = "${path.module}/../tmp/cognito_client2_secret.txt"
}
