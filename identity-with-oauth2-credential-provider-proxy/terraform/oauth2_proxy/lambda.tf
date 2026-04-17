variable "target_discovery_url" {}
variable "target_token_endpoint" {}

resource "aws_iam_role" "proxy" {
  name = "${var.project_name}-oauth2-proxy"

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

resource "aws_iam_role_policy_attachment" "proxy_basic" {
  role       = aws_iam_role.proxy.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "proxy" {
  type        = "zip"
  source_dir  = "${path.root}/../src/oauth2-proxy"
  output_path = "${path.root}/../tmp/lambda_oauth2_proxy.zip"
}

resource "aws_cloudwatch_log_group" "proxy" {
  name              = "/aws/lambda/${var.project_name}-oauth2-proxy"
  retention_in_days = 7
}

resource "aws_lambda_function" "proxy" {
  function_name    = "${var.project_name}-oauth2-proxy"
  role             = aws_iam_role.proxy.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  memory_size      = 512
  filename         = data.archive_file.proxy.output_path
  source_code_hash = data.archive_file.proxy.output_base64sha256
  environment {
    variables = {
      TARGET_DISCOVERY_URL  = var.target_discovery_url
      TARGET_TOKEN_ENDPOINT = var.target_token_endpoint
      PROXY_TOKEN_ENDPOINT  = local.proxy_token_endpoint
    }
  }

  logging_config {
    log_group  = aws_cloudwatch_log_group.proxy.name
    log_format = "Text"
  }

  depends_on = [aws_cloudwatch_log_group.proxy]
}
