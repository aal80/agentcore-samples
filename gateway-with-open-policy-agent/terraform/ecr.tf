data "aws_ecr_repository" "opa" {
  name = local.short_project_name
}


locals {
  opa_image_uri = "${data.aws_ecr_repository.opa.repository_url}:latest"
}

output "opa_image_uri" {
  value = local.opa_image_uri
}