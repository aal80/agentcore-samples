data "aws_ecr_repository" "this" {
  name = local.project_name
}

data "aws_ecr_image" "this" {
  repository_name = data.aws_ecr_repository.this.name
  image_tag = "latest"
}

locals {
  full_ecr_image_uri_with_digest = "${data.aws_ecr_repository.this.repository_url}@${data.aws_ecr_image.this.image_digest}"
}

output "full_ecr_image_uri_with_digest" {
  value = local.full_ecr_image_uri_with_digest
}