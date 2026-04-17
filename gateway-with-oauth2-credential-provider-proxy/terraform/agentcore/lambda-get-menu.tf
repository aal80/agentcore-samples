# resource "aws_iam_role" "lambda_get_menu" {
#   name = "${local.project_name}-lambda-get-menu"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [{
#       Effect = "Allow"
#       Action = "sts:AssumeRole"
#       Principal = {
#         Service = "lambda.amazonaws.com"
#       }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "get_menu_basic" {
#   role       = aws_iam_role.lambda_get_menu.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# data "archive_file" "lambda_get_menu" {
#   type        = "zip"
#   source_dir  = "${path.module}/../lambda/get_menu"
#   output_path = "${path.module}/../tmp/lambda_get_menu.zip"
# }

# resource "aws_lambda_function" "get_menu" {
#   function_name    = "${local.project_name}-get-menu"
#   role             = aws_iam_role.lambda_get_menu.arn
#   handler          = "index.handler"
#   runtime          = "nodejs22.x"
#   memory_size      = 512
#   filename         = data.archive_file.lambda_get_menu.output_path
#   source_code_hash = data.archive_file.lambda_get_menu.output_base64sha256
# }
