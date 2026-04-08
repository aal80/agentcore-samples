resource "aws_cloudwatch_log_delivery_source" "browser_traces" {
  name         = "${local.project_name}-browser-traces"
  log_type     = "TRACES"
  resource_arn = aws_bedrockagentcore_browser.this.browser_arn
}

resource "aws_cloudwatch_log_delivery_destination" "browser_traces_xray" {
  name = "${local.project_name}-traces-destination-xray"
  delivery_destination_type = "XRAY"
}

resource "aws_cloudwatch_log_delivery" "browser_traces_xray" {
  delivery_source_name     = aws_cloudwatch_log_delivery_source.browser_traces.name
  delivery_destination_arn = aws_cloudwatch_log_delivery_destination.browser_traces_xray.arn
}


