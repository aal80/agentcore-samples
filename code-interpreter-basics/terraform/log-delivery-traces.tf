resource "aws_cloudwatch_log_delivery_source" "code_interpreter_traces" {
  name         = "${local.project_name}-code-interpreter-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_code_interpreter.this.code_interpreter_arn
}

resource "aws_cloudwatch_log_delivery_destination" "code_interpreter_traces_xray" {
  name = "${local.project_name}-traces-destination-xray"
  delivery_destination_type = "XRAY"
}

resource "aws_cloudwatch_log_delivery" "code_interpreter_traces_xray" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.code_interpreter_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.code_interpreter_traces_xray.arn
}


