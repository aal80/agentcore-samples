resource "aws_iam_role" "browser" {
  name = "${local.project_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Action    = "sts:AssumeRole"
      Principal = { Service = "bedrock-agentcore.amazonaws.com" }
    }]
  })
}

resource "aws_s3_bucket" "recordings" {
  bucket_prefix = "${local.project_name}"
  force_destroy = true
}

resource "aws_iam_role_policy" "browser_s3" {
  name = "${local.project_name}-browser-s3-write"
  role = aws_iam_role.browser.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:PutObject", "s3:ListMultipartUploadParts", "s3:AbortMultipartUpload"]
      Resource = [
        aws_s3_bucket.recordings.arn,
        "${aws_s3_bucket.recordings.arn}/*"
      ]
    }]
  })
}

resource "aws_bedrockagentcore_browser" "this" {
  name        = "${local.project_name_underscore}"
  execution_role_arn = aws_iam_role.browser.arn

  network_configuration {
    network_mode = "PUBLIC"
  }

  recording {
    enabled = true
    s3_location {
      bucket = aws_s3_bucket.recordings.bucket
      prefix = "browser-sessions/"
    }
  }
}

output "browser_arn" {
  value = aws_bedrockagentcore_browser.this.browser_arn
}

output "browser_id" {
  value = aws_bedrockagentcore_browser.this.browser_id
}

resource "local_file" "browser_id" {
  content = aws_bedrockagentcore_browser.this.browser_id
  filename = "${path.module}/../tmp/browser_id.txt"
}