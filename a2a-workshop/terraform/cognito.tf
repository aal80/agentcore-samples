resource "aws_cognito_user_pool" "this" {
  name = local.project_name
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = local.project_name
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_resource_server" "resource" {
  identifier   = "resource"
  name         = "resource"
  user_pool_id = aws_cognito_user_pool.this.id

  scope {
    scope_name        = "read"
    scope_description = "Read the resource"
  }
}

resource "aws_cognito_user_pool_client" "this" {
  name                                 = "${local.project_name}-client"
  user_pool_id                         = aws_cognito_user_pool.this.id
  generate_secret                      = true
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["client_credentials"]
  allowed_oauth_scopes                 = ["resource/read"]
  supported_identity_providers         = ["COGNITO"]

  depends_on = [ aws_cognito_resource_server.resource ]
}

locals {
  cognito_token_endpoint = "https://${aws_cognito_user_pool_domain.this.domain}.auth.${data.aws_region.current.region}.amazoncognito.com/oauth2/token"
  cognito_issuer = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}"
  cognito_discovery_url = "https://cognito-idp.${data.aws_region.current.region}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/openid-configuration"
}

# output "cognito_token_endpoint" {
#   value = local.cognito_token_endpoint
# }

# output "cognito_client_id" {
#   value = aws_cognito_user_pool_client.this.id
# }

# output "cognito_client_secret" {
#   value     = aws_cognito_user_pool_client.this.client_secret
#   sensitive = true
# }

# output "cognito_issuer" {
#   value = local.cognito_issuer
# }

# output "cognito_discovery_url" {
#   value = local.cognito_discovery_url
# }

resource "local_file" "cognito_token_endpoint" {
  content         = local.cognito_token_endpoint
  filename        = "${path.module}/../tmp/cognito_token_endpoint.txt"
}

resource "local_file" "cognito_client_id" {
  content         = aws_cognito_user_pool_client.this.id
  filename        = "${path.module}/../tmp/cognito_client_id.txt"
}

resource "local_file" "cognito_client_secret" {
  content         = aws_cognito_user_pool_client.this.client_secret
  filename        = "${path.module}/../tmp/cognito_client_secret.txt"
}
