locals {
  gateway_arn = aws_bedrockagentcore_gateway.this.gateway_arn
}

resource "aws_cloudwatch_dashboard" "gateway" {
  dashboard_name = "${local.project_name}-gateway"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Invocations"
          region = data.aws_region.current.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["AWS/Bedrock-AgentCore", "Invocations", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          title  = "Latency (ms)"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/Bedrock-AgentCore", "Latency", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP", { stat = "Average", label = "Avg" }],
            ["...", { stat = "p99", label = "p99" }],
            ["...", { stat = "Maximum", label = "Max" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Target Execution Time (ms)"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/Bedrock-AgentCore", "TargetExecutionTime", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP", { stat = "Average", label = "Avg" }],
            ["...", { stat = "p99", label = "p99" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          title  = "Errors"
          region = data.aws_region.current.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["AWS/Bedrock-AgentCore", "UserErrors", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP", { label = "User Errors" }],
            ["AWS/Bedrock-AgentCore", "SystemErrors", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP", { label = "System Errors" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "Throttles"
          region = data.aws_region.current.region
          stat   = "Sum"
          period = 60
          metrics = [
            ["AWS/Bedrock-AgentCore", "Throttles", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP"]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6
        properties = {
          title  = "Duration (ms)"
          region = data.aws_region.current.region
          stat   = "Average"
          period = 60
          metrics = [
            ["AWS/Bedrock-AgentCore", "Duration", "Resource", local.gateway_arn, "Operation", "InvokeGateway", "Method", "tools/call", "Protocol", "MCP", { stat = "Average", label = "Avg" }],
            ["...", { stat = "p99", label = "p99" }]
          ]
        }
      }
    ]
  })
}
