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
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = [
        aws_lambda_function.get_menu.arn, 
        aws_lambda_function.create_order.arn
      ]
    },
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
    }]
  })
}

resource "aws_bedrockagentcore_gateway" "this" {
  name = "${local.project_name}"
  role_arn = aws_iam_role.agentcore_gateway.arn
  protocol_type = "MCP"
  authorizer_type = "CUSTOM_JWT"
  authorizer_configuration {
    custom_jwt_authorizer {
      discovery_url = local.cognito_discovery_url
      allowed_scopes = ["gateway/invoke"]      
    }
  }

}

output "gateway_url" {
    value = aws_bedrockagentcore_gateway.this.gateway_url
}

resource "local_file" "gateway_url" {
  content         = aws_bedrockagentcore_gateway.this.gateway_url
  filename        = "${path.module}/../tmp/gateway_url.txt"
  directory_permission = "0755"
  file_permission      = "0644"
}

resource "aws_bedrockagentcore_gateway_target" "get-menu" {
  name = "get-menu"
  gateway_identifier = aws_bedrockagentcore_gateway.this.gateway_id

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
  gateway_identifier = aws_bedrockagentcore_gateway.this.gateway_id

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
                name        = "itemIds"
                type        = "array"
                description = "Array of pizza IDs to order, always check menu first."
                required    = true
                items {
                  type = "integer"
                }
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ aws_lambda_function.get_menu, aws_lambda_function.create_order ]
}

