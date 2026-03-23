resource "aws_iam_role" "agentcore_runtime" {
  name = "${local.project_name}-runtime"
  
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

resource "aws_iam_role_policy" "agent_permissions" {
  role = aws_iam_role.agentcore_runtime.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
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
          "xray:PutTelemetryRecords",
          "bedrock-agentcore:CreateEvent",
          "bedrock-agentcore:GetEvent",
          "bedrock-agentcore:ListEvents",
          "bedrock-agentcore:ListMemoryRecords",
          "bedrock-agentcore:RetrieveMemoryRecords",
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = "${local.project_name_underscore}"
  role_arn           = aws_iam_role.agentcore_runtime.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = local.full_ecr_image_uri_with_digest
    }
  }

  environment_variables = {
    AGENTCORE_MEMORY_ID = aws_bedrockagentcore_memory.this.id
    AWS_REGION = data.aws_region.current.region
  }

  network_configuration {
    network_mode = "PUBLIC"
  }

}

output "agent_runtime_arn" {
  value = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
}

resource "local_file" "agent_runtime_arn" {
  content         = aws_bedrockagentcore_agent_runtime.this.agent_runtime_arn
  filename        = "${path.module}/../tmp/agent_runtime_arn.txt"
  directory_permission = "0755"
  file_permission      = "0644"
}

