variable "target_discovery_url" {}

resource "aws_iam_role" "discovery_endpoint" {
  name = "${var.project_name}-discovery-endpoint"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRole"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "discovery_endpoint_basic" {
  role       = aws_iam_role.discovery_endpoint.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "discovery_endpoint" {
  type        = "zip"
  source_dir  = "${path.root}/../src/discovery-endpoint"
  output_path = "${path.root}/../tmp/lambda_discovery_endpoint.zip"
}

resource "aws_lambda_function" "discovery_endpoint" {
  function_name    = "${var.project_name}-discovery-endpoint"
  role             = aws_iam_role.discovery_endpoint.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  memory_size      = 512
  filename         = data.archive_file.discovery_endpoint.output_path
  source_code_hash = data.archive_file.discovery_endpoint.output_base64sha256
  environment {
    variables = {
      TARGET_DISCOVERY_URL = var.target_discovery_url
      PROXY_TOKEN_ENDPOINT = local.proxy_token_endpoint
    }
  }
}
