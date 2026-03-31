resource "aws_iam_role" "lambda_gateway_interceptor" {
  name = "${local.project_name}-lambda-gateway-interceptor"

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

resource "aws_iam_role_policy_attachment" "gateway_interceptor_basic" {
  role       = aws_iam_role.lambda_gateway_interceptor.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_gateway_interceptor" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/gateway-interceptor"
  output_path = "${path.module}/../tmp/lambda_gateway_interceptor.zip"
}

resource "aws_lambda_function" "gateway_interceptor" {
  function_name    = "${local.project_name}-gateway-interceptor"
  role             = aws_iam_role.lambda_gateway_interceptor.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  memory_size      = 512
  filename         = data.archive_file.lambda_gateway_interceptor.output_path
  source_code_hash = data.archive_file.lambda_gateway_interceptor.output_base64sha256

  environment {
    variables = {
      OPA_ENDPOINT = local.opa_endpoint
    }
  }
}
