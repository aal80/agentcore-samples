resource "aws_iam_role" "agentcore_gateway" {
  name = "${local.project_name}-agentcore-gateway"

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

resource "aws_iam_role_policy" "agentcore_gateway_invoke_lambda" {
  name = "invoke-lambda"
  role = aws_iam_role.agentcore_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = "lambda:InvokeFunction"
      Resource = [
        aws_lambda_function.get_menu.arn,
        aws_lambda_function.create_order.arn
      ]
    }]
  })
}

resource "aws_iam_role_policy" "agentcore_gateway_observability" {
  name = "observability"
  role = aws_iam_role.agentcore_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams",
        "xray:PutTraceSegments",
        "xray:PutTelemetryRecords"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy" "agentcore_gateway_policy_engine" {
  name = "policy-engine"
  role = aws_iam_role.agentcore_gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "bedrock-agentcore:AuthorizeAction",
        "bedrock-agentcore:PartiallyAuthorizeActions",
        "bedrock-agentcore:GetPolicyEngine",
        "bedrock-agentcore:CheckAuthorizePermissions"
      ]
      Resource = ["*"]
    }]
  })
}

# This is required since gateway creation/deletion is async process, so to avoid
# naming collisions on re-creation each gateway instance will get a new unique name
resource "random_string" "gateway_name_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "awscc_bedrockagentcore_gateway" "this" {
  name            = "${local.project_name}-${random_string.gateway_name_suffix.result}"
  role_arn        = aws_iam_role.agentcore_gateway.arn
  protocol_type   = "MCP"

  authorizer_type = "NONE" # change to CUSTOM_JWT

  # authorizer_configuration = {
  #   custom_jwt_authorizer = {
  #     discovery_url   = local.cognito_discovery_url
  #     allowed_scopes = ["gateway/get_menu"]
  #     allowed_clients = [
  #       aws_cognito_user_pool_client.client1.id,
  #       aws_cognito_user_pool_client.client2.id,
  #     ]
  #   }
  # }

  # policy_engine_configuration = {
  #   arn  = awscc_bedrockagentcore_policy_engine.this.policy_engine_arn
  #   # mode = "LOG_ONLY" 
  #   mode = "ENFORCE" 
  # }

  exception_level = "DEBUG"

  lifecycle {
    create_before_destroy = true
  }
}

output "gateway_url" {
  value = awscc_bedrockagentcore_gateway.this.gateway_url
}

resource "local_file" "gateway_url" {
  content  = awscc_bedrockagentcore_gateway.this.gateway_url
  filename = "${path.module}/../tmp/gateway_url.txt"
}

resource "aws_bedrockagentcore_gateway_target" "get-menu" {
  name = "get-menu"
  gateway_identifier = awscc_bedrockagentcore_gateway.this.gateway_identifier

  credential_provider_configuration {
    gateway_iam_role {}    
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.get_menu.arn
        tool_schema {
          inline_payload {
            name = "get-menu"
            description = "This tool returns pizza menu"

            input_schema {
              type = "object"
            }
          }
        }
      }
    }
  }

  depends_on = [ aws_lambda_function.get_menu ]
}

resource "aws_bedrockagentcore_gateway_target" "create-order" {
  name = "create-order"
  gateway_identifier = awscc_bedrockagentcore_gateway.this.gateway_identifier

  credential_provider_configuration {
    gateway_iam_role {}    
  }

  target_configuration {
    mcp {
      lambda {
        lambda_arn = aws_lambda_function.create_order.arn
        tool_schema {
          inline_payload {
            name = "create-order"
            description = "Use this tool to submit a new pizza order"

            input_schema {
              type = "object"
              property {
                name        = "pizzaId"
                type        = "integer"
                description = "ID of the pizza to order, always check menu first."
                required    = true
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ aws_lambda_function.get_menu, aws_lambda_function.create_order ]
}

