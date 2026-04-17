
resource "aws_api_gateway_rest_api" "this" {
  name = "${var.project_name}-api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.well_known.id,
      aws_api_gateway_resource.openid_configuration.id,
      aws_api_gateway_method.openid_configuration_get.id,
      aws_api_gateway_integration.openid_configuration_get.id,

      aws_api_gateway_resource.oauth2.id,
      aws_api_gateway_resource.token.id,
      aws_api_gateway_method.token_post.id,
      aws_api_gateway_integration.token_post.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "demo" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = local.stage_name
}

locals {
  stage_name           = "demo"
  proxy_base_url       = "https://${aws_api_gateway_rest_api.this.id}.execute-api.${var.region}.amazonaws.com/${local.stage_name}"
  proxy_discovery_url  = "${local.proxy_base_url}/.well-known/openid-configuration"
  proxy_token_endpoint = "${local.proxy_base_url}/oauth2/token"
}

output "oauth2_proxy_discovery_url" {
  value = local.proxy_discovery_url
}

output "oauth2_proxy_token_endpoint" {
  value = local.proxy_discovery_url
}

resource "local_file" "oauth2_proxy_discovery_url" {
  content  = local.proxy_discovery_url
  filename = "${path.root}/../tmp/oauth2_proxy_discovery_url.txt"
}

resource "local_file" "oauth2_proxy_token_endpoint" {
  content  = local.proxy_token_endpoint
  filename = "${path.root}/../tmp/oauth2_proxy_token_endpoint.txt"
}
