resource "aws_iam_role" "weather_agent" {
  name = "${local.prefix}-${local.project_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "bedrock-agentcore.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "weather_agent" {
  role = aws_iam_role.weather_agent.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:Converse",
          "bedrock:ConverseStream",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_bedrockagentcore_agent_runtime" "weather_agent" {
  agent_runtime_name = "${local.project_name_underscore}_weather_agent"
  role_arn           = aws_iam_role.weather_agent.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = local.weather_agent_ecr_uri
    }
  }

  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url   = local.cognito_discovery_url
      allowed_clients = [aws_cognito_user_pool_client.this.id]
    }
  }

  network_configuration {
    network_mode = "PUBLIC"
  }

  protocol_configuration {
    server_protocol = "A2A"
  }
}

locals {
  weather_agent_runtime_arn_encoded = replace(aws_bedrockagentcore_agent_runtime.weather_agent.agent_runtime_arn, "/", "%2F")
#   weather_agent_card_url = "https://bedrock-agentcore.${data.aws_region.current.name}.amazonaws.com/runtimes/${local.weather_agent_runtime_arn_encoded}/invocations/.well-known/agent-card.json"
  weather_agent_runtime_url = "https://bedrock-agentcore.${data.aws_region.current.name}.amazonaws.com/runtimes/${local.weather_agent_runtime_arn_encoded}/invocations/"
}

# output "weather_agent_runtime_arn" {
#   value = aws_bedrockagentcore_agent_runtime.weather_agent.agent_runtime_arn
# }

output "weather_agent_card_url" {
  value = "https://bedrock-agentcore.${data.aws_region.current.name}.amazonaws.com/runtimes/${local.weather_agent_runtime_arn_encoded}/invocations/.well-known/agent-card.json"
}

resource "local_file" "weather_agent_runtime_url" {
  content  = local.weather_agent_runtime_url
  filename = "${path.module}/../tmp/weather_agent_runtime_url.txt"
}

