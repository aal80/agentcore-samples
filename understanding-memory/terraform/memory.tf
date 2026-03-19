resource "aws_iam_role" "agentcore_memory" {
  name = "${local.project_name}"
  
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

resource "aws_iam_role_policy_attachment" "agentcore_memory" {
    role = aws_iam_role.agentcore_memory.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonBedrockAgentCoreMemoryBedrockModelInferenceExecutionRolePolicy"
} 

resource "aws_iam_role_policy" "memory_permissions" {
  role = aws_iam_role.agentcore_memory.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "xray:PutTraceSegments", 
          "xray:PutTelemetryRecords"
        ]
        
        Resource = "*"
      }
    ]
  })
}

resource "aws_bedrockagentcore_memory" "this" {
    name = "${local.project_name_underscore}"
    memory_execution_role_arn = aws_iam_role.agentcore_memory.arn
    event_expiry_duration = 7
}

resource "local_file" "memory_id" {
  content         = aws_bedrockagentcore_memory.this.id
  filename        = "${path.module}/../tmp/memory_id.txt"
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "local_file" "session_id" {
  content         = "abcd1234abcd1234abcd1234abcd1234abcd1234abcd1234"
  filename        = "${path.module}/../tmp/session_id.txt"
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "local_file" "actor_id" {
  content         = "test-actor"
  filename        = "${path.module}/../tmp/actor_id.txt"
  directory_permission = "0755"
  file_permission      = "0644"
}
