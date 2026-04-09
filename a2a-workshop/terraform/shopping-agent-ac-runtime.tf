resource "aws_iam_role" "shopping_agent" {
  name = "${local.project_name}-shopping-agent"

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

resource "aws_iam_role_policy" "shopping_agent" {
  role = aws_iam_role.shopping_agent.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "xray:PutTraceSegments", 
          "xray:PutTelemetryRecords"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_bedrockagentcore_agent_runtime" "shopping_agent" {
  agent_runtime_name = "${local.project_name_underscore}_shopping_agent"
  role_arn           = aws_iam_role.shopping_agent.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = local.shopping_agent_ecr_uri
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
  shopping_agent_runtime_arn_encoded = replace(aws_bedrockagentcore_agent_runtime.shopping_agent.agent_runtime_arn, "/", "%2F")
  shopping_agent_runtime_url = "https://bedrock-agentcore.${data.aws_region.current.region}.amazonaws.com/runtimes/${local.shopping_agent_runtime_arn_encoded}/invocations/"
}

resource "local_file" "shopping_agent_runtime_url" {
  content  = local.shopping_agent_runtime_url
  filename = "${path.module}/../tmp/shopping_agent_runtime_url.txt"
}

