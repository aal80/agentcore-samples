resource "aws_cloudwatch_log_group" "browser_usage" {
  name              = "/aws/vendedlogs/bedrock-agentcore/browser/USAGE_LOGS/${local.project_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "browser_usage_logs" {
  name         = "${local.project_name}-browser-usage-logs"
  log_type     = "USAGE_LOGS"
  resource_arn = aws_bedrockagentcore_browser.this.browser_arn
}

resource "aws_cloudwatch_log_delivery_destination" "browser_usage_logs" {
  name = "${local.project_name}-browser-usage-logs-dst"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.browser_usage.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "browser_usage_logs" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.browser_usage_logs.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.browser_usage_logs.arn
}
