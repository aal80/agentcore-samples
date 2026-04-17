module "cognito" {
    source = "./cognito"
    project_name = local.project_name
    region = data.aws_region.current.region
}

module "oauth2_proxy" {
    source = "./oauth2_proxy"
    project_name = local.project_name
    region = data.aws_region.current.region
    target_discovery_url = module.cognito.cognito_discovery_url
    target_token_endpoint = module.cognito.cognito_token_endpoint
}

module "agentcore" {
    source = "./agentcore"
    project_name = local.project_name
    client_id = module.cognito.cognito_client_id
    client_secret_arn = module.cognito.cognito_client_secret_arn
    discovery_url = module.oauth2_proxy.oauth2_proxy_discovery_url
}

output "oauth2_proxy_discovery_url" {
    value = module.oauth2_proxy.oauth2_proxy_discovery_url
}

output "oauth2_proxy_token_endpoint" {
    value = module.oauth2_proxy.oauth2_proxy_token_endpoint
}