resource "aws_cloudwatch_log_delivery_source" "agentcore_memory_traces" {
  name         = "${local.project_name}-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_memory.this.arn
}

resource "aws_cloudwatch_log_delivery_destination" "agentcore_memory_traces_xray" {
  name = "${local.project_name}-traces-destination-xray"
  delivery_destination_type = "XRAY"
}

resource "aws_cloudwatch_log_delivery" "agentcore_memory_traces_xray" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agentcore_memory_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agentcore_memory_traces_xray.arn
}


