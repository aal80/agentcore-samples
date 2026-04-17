resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project_name}-oauth2-proxy"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "proxy" {
  api_id                 = aws_apigatewayv2_api.this.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.proxy.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "proxy" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.proxy.id}"
}

resource "aws_apigatewayv2_stage" "demo" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = local.stage_name
  auto_deploy = true
}

resource "aws_lambda_permission" "proxy_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.proxy.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.this.execution_arn}/*/*"
}

locals {
  stage_name           = "demo"
  proxy_base_url       = "https://${aws_apigatewayv2_api.this.id}.execute-api.${var.region}.amazonaws.com/${local.stage_name}"
  proxy_discovery_url  = "${local.proxy_base_url}/.well-known/openid-configuration"
  proxy_token_endpoint = "${local.proxy_base_url}/oauth2/token"
}

output "oauth2_proxy_discovery_url" {
  value = local.proxy_discovery_url
}

output "oauth2_proxy_token_endpoint" {
  value = local.proxy_token_endpoint
}

resource "local_file" "oauth2_proxy_discovery_url" {
  content  = local.proxy_discovery_url
  filename = "${path.root}/../tmp/oauth2_proxy_discovery_url.txt"
}

resource "local_file" "oauth2_proxy_token_endpoint" {
  content  = local.proxy_token_endpoint
  filename = "${path.root}/../tmp/oauth2_proxy_token_endpoint.txt"
}
