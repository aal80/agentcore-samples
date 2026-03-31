# ─── IAM: allow App Runner to pull from ECR ──────────────────────────────────

resource "aws_iam_role" "app_runner_ecr" {
  name = "${local.project_name}-app-runner-ecr"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "build.apprunner.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_runner_ecr" {
  role       = aws_iam_role.app_runner_ecr.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# ─── App Runner ───────────────────────────────────────────────────────────────

resource "aws_apprunner_service" "opa" {
  service_name = "${local.project_name}-opa"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_ecr.arn
    }

    image_repository {
      image_identifier      = local.opa_image_uri
      image_repository_type = "ECR"

      image_configuration {
        port = "8181"
      }
    }

    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "512"
    memory = "1024"
  }

  health_check_configuration {
    protocol            = "HTTP"
    path                = "/health"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 1
    unhealthy_threshold = 3
  }
}

locals {
  opa_endpoint = "https://${aws_apprunner_service.opa.service_url}"
}
output "opa_endpoint" {
  value = local.opa_endpoint
}
