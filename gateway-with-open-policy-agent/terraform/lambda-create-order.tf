resource "aws_iam_role" "lambda_create_order" {
  name = "${local.project_name}-lambda-create-order"

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

resource "aws_iam_role_policy_attachment" "create_order_basic" {
  role       = aws_iam_role.lambda_create_order.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda_create_order" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/create-order"
  output_path = "${path.module}/../tmp/lambda_create_order.zip"
}

resource "aws_lambda_function" "create_order" {
  function_name    = "${local.project_name}-create-order"
  role             = aws_iam_role.lambda_create_order.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  memory_size      = 512
  filename         = data.archive_file.lambda_create_order.output_path
  source_code_hash = data.archive_file.lambda_create_order.output_base64sha256
}
