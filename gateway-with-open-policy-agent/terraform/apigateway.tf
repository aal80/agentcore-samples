resource "aws_apigatewayv2_api" "opa" {
  name          = "${local.project_name}-opa"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "opa" {
  api_id                 = aws_apigatewayv2_api.opa.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.opa.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "opa" {
  api_id    = aws_apigatewayv2_api.opa.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.opa.id}"
}

resource "aws_apigatewayv2_stage" "opa" {
  api_id      = aws_apigatewayv2_api.opa.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_opa" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.opa.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.opa.execution_arn}/*/*"
}

locals {
  opa_endpoint = aws_apigatewayv2_stage.opa.invoke_url
}

output "opa_endpoint" {
  value = local.opa_endpoint
}
