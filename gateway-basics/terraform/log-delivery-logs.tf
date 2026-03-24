resource "aws_cloudwatch_log_group" "agentcore_gateway_logs" {
  name              = "/aws/vendedlogs/bedrock-agentcore/gateway/APPLICATION_LOGS/${local.project_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "agentcore_gateway_logs" {
  name         = "${local.project_name}-memory-logs"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagentcore_gateway.this.gateway_arn
}

resource "aws_cloudwatch_log_delivery_destination" "agentcore_gateway_logs" {
  name = "${local.project_name}-gateway-logs-destination"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.agentcore_gateway_logs.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "agentcore_gateway_logs" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agentcore_gateway_logs.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agentcore_gateway_logs.arn
}
