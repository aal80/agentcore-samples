resource "aws_cloudwatch_log_resource_policy" "log_delivery_write" {
  policy_name     = "${local.project_name}-log-delivery-write"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AWSLogDeliveryWrite-${local.project_name}"
      Effect    = "Allow"
      Principal = { Service = "delivery.logs.amazonaws.com" }
      Action    = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource  = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vendedlogs/*"
      Condition = {
        StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        ArnLike      = { "aws:SourceArn" = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*" }
      }
    }]
  })
}

resource "aws_cloudwatch_log_resource_policy" "xray_to_spans" {
  policy_name     = "${local.project_name}-xray-to-spans"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "TransactionSearchXRayAccess-${local.project_name}"
      Effect    = "Allow"
      Principal = { Service = "xray.amazonaws.com" }
      Action    = ["logs:PutLogEvents", "logs:CreateLogStream"]
      Resource  = [
        "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:aws/spans:*",
        "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/application-signals/data:*"

      ]
      Condition = {
        StringEquals = { "aws:SourceAccount" = data.aws_caller_identity.current.account_id }
        ArnEquals    = { "aws:SourceArn" = "arn:aws:xray:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:*" }
      }
    }]
  })
}
