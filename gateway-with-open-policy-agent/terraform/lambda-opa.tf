resource "aws_iam_role" "opa_lambda" {
  name = "${local.project_name}-opa-lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "opa_lambda" {
  role       = aws_iam_role.opa_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "opa" {
  function_name = "${local.project_name}-opa"
  role          = aws_iam_role.opa_lambda.arn
  package_type  = "Image"
  image_uri     = local.opa_image_uri
  timeout       = 30
  memory_size   = 2048
}
