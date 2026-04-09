resource "aws_cloudwatch_log_group" "shopping_agent" {
  name              = "/aws/vendedlogs/agentcore/shopping-agent/applogs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "shopping_agent" {
  name         = "${local.project_name}-shopping-agent-app-logs"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagentcore_agent_runtime.shopping_agent.agent_runtime_arn
}

resource "aws_cloudwatch_log_delivery_destination" "shopping_agent" {
  name = "${local.project_name}-shopping-agent-dst"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.shopping_agent.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "shopping_agent" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.shopping_agent.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.shopping_agent.arn
}
