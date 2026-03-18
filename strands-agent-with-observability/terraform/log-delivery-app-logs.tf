resource "aws_cloudwatch_log_group" "agentcore_app_logs" {
  name              = "/aws/vendedlogs/bedrock-agentcore/runtime/APPLICATION_LOGS/${local.project_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "agentcore_app_logs" {
  name         = "${local.project_name}-app-logs"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

resource "aws_cloudwatch_log_delivery_destination" "agentcore_app_logs" {
  name = "${local.project_name}-app-logs-destination"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.agentcore_app_logs.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "agentcore_app_logs" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agentcore_app_logs.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agentcore_app_logs.arn
}
