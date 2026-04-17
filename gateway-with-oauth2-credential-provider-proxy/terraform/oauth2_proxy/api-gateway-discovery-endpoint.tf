resource "aws_api_gateway_resource" "well_known" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = ".well-known"
}

resource "aws_api_gateway_resource" "openid_configuration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.well_known.id
  path_part   = "openid-configuration"
}

resource "aws_api_gateway_method" "openid_configuration_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.openid_configuration.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "openid_configuration_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.openid_configuration.id
  http_method             = aws_api_gateway_method.openid_configuration_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.discovery_endpoint.invoke_arn
}

resource "aws_lambda_permission" "discovery_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.discovery_endpoint.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

