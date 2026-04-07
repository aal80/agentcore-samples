resource "aws_cloudwatch_log_group" "code_interpreter_usage" {
  name              = "/aws/vendedlogs/bedrock-agentcore/code-interpreter/USAGE_LOGS/${local.project_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "code_interpreter_usage_logs" {
  name         = "${local.project_name}-code-interpreter-usage-logs"
  log_type     = "USAGE_LOGS"
  resource_arn = aws_bedrockagentcore_code_interpreter.this.code_interpreter_arn
}

resource "aws_cloudwatch_log_delivery_destination" "code_interpreter_usage_logs" {
  name = "${local.project_name}-code-interpreter-usage-logs-dst"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.code_interpreter_usage.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "agentcore_usage_logs" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.code_interpreter_usage_logs.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.code_interpreter_usage_logs.arn
}
