resource "aws_cloudwatch_log_group" "weather_agent" {
  name              = "/aws/vendedlogs/agentcore/weather-agent/applogs"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "weather_agent" {
  name         = "${local.project_name}-weather-agent-app-logs"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagentcore_agent_runtime.weather_agent.agent_runtime_arn
}

resource "aws_cloudwatch_log_delivery_destination" "weather_agent" {
  name = "${local.project_name}-weather-agent-dst"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.weather_agent.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "weather_agent" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.weather_agent.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.weather_agent.arn
}
