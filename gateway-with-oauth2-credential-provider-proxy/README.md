# WORK IN PROGRESS!!!!

# Gateway with OAuth2 Credential Provider Proxy

Sample showing how to front an OAuth2 identity provider (Cognito, in this case) with a proxy built on API Gateway + Lambda, and wire it up as a `CustomOauth2` credential provider in an AgentCore Gateway. Can be useful in case OAuth2 identity provider is not fully compliant with RFC and requires /token request customization. 

The proxy exposes the two OAuth2 endpoints an AgentCore credential provider needs:

- `GET /.well-known/openid-configuration` — OIDC discovery. Fetches the upstream discovery document and rewrites the `token_endpoint` to point back at this proxy.
- `POST /oauth2/token` — Token endpoint. Extracts `client_id` / `client_secret` from the `Authorization: Basic` header and forwards a `client_credentials` grant to the real upstream token endpoint. Use this endpoint to modify `/token` requests.

This lets you observe, modify, or short-circuit the OAuth2 handshake that AgentCore performs when resolving credentials for a gateway target — useful for custom IdPs, debugging, or policy injection.

## Architecture

![](./images/arch.png)

## Project layout

```
src/
  discovery-endpoint/     Lambda: OIDC discovery proxy
  token-endpoint/         Lambda: OAuth2 token proxy
terraform/
  bootstrap.tf            Random project prefix, region/account outputs
  workshop.tf             Wires the modules together
  cognito/                Upstream IdP (user pool, resource server, client)
  oauth2_proxy/           API Gateway REST API + 2 Lambdas
  agentcore/              AgentCore credential provider, workload identity, gateway
```

## Prerequisites

- AWS account with permissions for Cognito, API Gateway, Lambda, IAM, and Bedrock AgentCore
- Terraform `>= 1.x`
- AWS CLI configured
- `jq`

## Deploy

```bash
make deploy-infra
```

This runs `terraform init && terraform apply` in `terraform/` and writes runtime values into `tmp/` (client id/secret, discovery URLs, workload identity name, etc.).

## Validate Cognito is up and running

```bash
make get-cognito-token
```

## Obtain resource access token through the proxy

1. Get a workload access token for your machine identity:

   ```bash
   make get-workload-access-token
   ```

2. Use AgentCore to fetch a resource access token through the credential provider (which goes through the proxy):

   ```bash
   make get-resource-oauth2-token
   ```

   AgentCore Identity OAuth2 Credential Provider will:
   - Call the proxy's discovery endpoint → the rewritten `token_endpoint` points to the proxy
   - POST `client_credentials` to the proxy's token endpoint
   - The token Lambda forwards the request to Cognito and returns the access token

## Tear down

```bash
make destroy
```

## Notes

- The token Lambda logs `client_secret` in plaintext — for demonstration only. Do not run this against production credentials.
- The proxy's `invoke_url` is computed from the REST API ID + region + stage name rather than from `aws_api_gateway_stage.invoke_url`. This avoids a dependency cycle when the Lambda needs the proxy URL in its environment and the stage depends on the Lambda's integration.
