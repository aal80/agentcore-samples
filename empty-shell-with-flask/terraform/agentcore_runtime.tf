resource "aws_iam_role" "agentcore_runtime" {
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

resource "aws_iam_role_policy" "ecr_permissions" {
  role = aws_iam_role.agentcore_runtime.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "bedrock:InvokeModel",
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

resource "aws_bedrockagentcore_agent_runtime" "this" {
  agent_runtime_name = "${local.prefix}_empty_shell_with_flask"
  role_arn           = aws_iam_role.agentcore_runtime.arn

  agent_runtime_artifact {
    container_configuration {
      container_uri = local.full_ecr_image_uri_with_digest
    }
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

