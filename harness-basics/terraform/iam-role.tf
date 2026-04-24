resource "aws_iam_role" "harness" {
  name = "${local.project_name}-harness-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "agentcore_runtime" {
  name = "${local.project_name}-harness-policy"
  role = aws_iam_role.harness.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "BedrockModelInvocation"
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ]
        Resource = ["*"]
      },
      {
        Sid      = "EcrPublicTokenAccess"
        Effect   = "Allow"
        Action   = ["ecr-public:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid      = "StsForEcrPublicPull"
        Effect   = "Allow"
        Action   = ["sts:GetServiceBearerToken"]
        Resource = "*"
      },
      {
        Sid    = "XRayTracingAccess"
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "logs:CreateLogGroup",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      {
        Sid    = "AgentCoreWorkloadIdentity"
        Effect = "Allow"
        Action = [
          "bedrock-agentcore:*"
        ]
        Resource = ["*"]
      },
    ]
  })
}

resource "local_file" "harness_iam_role_arn" {
  filename = "${path.root}/../tmp/harness_iam_role_arn.txt"
  content  = aws_iam_role.harness.arn
}