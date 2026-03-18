resource "aws_cloudwatch_log_delivery_source" "agentcore_traces" {
  name         = "${local.project_name}-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

resource "aws_cloudwatch_log_delivery_destination" "agentcore_traces_xray" {
  name = "${local.project_name}-traces-destination-xray"
  delivery_destination_type = "XRAY"
}

resource "aws_cloudwatch_log_delivery" "agentcore_traces_xray" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agentcore_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agentcore_traces_xray.arn
}


