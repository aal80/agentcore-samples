locals {
  weather_agent_ecr_uri = "${data.aws_ecr_repository.weather_agent.repository_url}@${data.aws_ecr_image.weather_agent.image_digest}"
}

data "aws_ecr_repository" "weather_agent" {
  name = "${local.project_name_short}-weather-agent"
}

data "aws_ecr_image" "weather_agent" {
  repository_name = data.aws_ecr_repository.weather_agent.name
  image_tag = "latest"
}

# output "weather_agent_ecr_uri" {
#   value = local.weather_agent_ecr_uri
# }