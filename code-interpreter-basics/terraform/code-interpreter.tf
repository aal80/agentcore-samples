resource "aws_iam_role" "code_interpreter" {
  name = "bedrock-agentcore-code-interpreter-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
    }]
  })
}

resource "aws_bedrockagentcore_code_interpreter" "this" {
  name        = "${local.project_name_underscore}"
  execution_role_arn = aws_iam_role.code_interpreter.arn

  network_configuration {
    network_mode = "PUBLIC"
  }
}

output "code_interprepter_arn" {
  value = aws_bedrockagentcore_code_interpreter.this.code_interpreter_arn
}

output "code_interprepter_id" {
  value = aws_bedrockagentcore_code_interpreter.this.code_interpreter_id
}

resource "local_file" "code_interpreter_id" {
  content = aws_bedrockagentcore_code_interpreter.this.code_interpreter_id
  filename = "${path.module}/../tmp/code_interpreter_id.txt"
}