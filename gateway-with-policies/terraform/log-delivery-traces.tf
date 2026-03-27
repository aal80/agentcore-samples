resource "aws_cloudwatch_log_delivery_source" "agentcore_gateway_traces" {
  name         = "${local.project_name}-${random_string.gateway_name_suffix.result}-traces"
  log_type     = "TRACES"
  resource_arn = awscc_bedrockagentcore_gateway.this.gateway_arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudwatch_log_delivery_destination" "agentcore_gateway_traces_xray" {
  name = "${local.project_name}-traces-destination-xray"
  delivery_destination_type = "XRAY"
}

resource "aws_cloudwatch_log_delivery" "agentcore_gateway_traces_xray" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.agentcore_gateway_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.agentcore_gateway_traces_xray.arn
}


