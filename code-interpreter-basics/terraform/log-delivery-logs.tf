resource "aws_cloudwatch_log_group" "code_interpreter_logs" {
  name              = "/aws/vendedlogs/bedrock-agentcore/code-interpreter/APPLICATION_LOGS/${local.project_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_delivery_source" "code_interpreter_logs" {
  name         = "${local.project_name}-code-interpreter-logs"
  log_type     = "APPLICATION_LOGS"
  resource_arn = aws_bedrockagentcore_code_interpreter.this.code_interpreter_arn
}

resource "aws_cloudwatch_log_delivery_destination" "code_interpreter_logs" {
  name = "${local.project_name}-code-interpreter-logs-dest"

  delivery_destination_type = "CWL"
  delivery_destination_configuration {
    destination_resource_arn = aws_cloudwatch_log_group.code_interpreter_logs.arn
  }

  output_format = "json"
}

resource "aws_cloudwatch_log_delivery" "code_interpreter_logs" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.code_interpreter_logs.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.code_interpreter_logs.arn
}
