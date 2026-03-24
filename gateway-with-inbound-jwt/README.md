# AgentCore Gateway with Inbound JWT Authentication

A sample project demonstrating how to secure an Amazon Bedrock AgentCore Gateway with JWT-based authentication using Amazon Cognito. The gateway uses MCP (Model Context Protocol) and is backed by AWS Lambda functions. Clients authenticate via OAuth2 `client_credentials` flow and pass a Bearer token on every request.

> Note that this sample is using OAuth2 `client_credentials` grant for simplicity. This grant can be used for machine2machine authentication. If your inbound identity is coming from human users, you should use `authorization_code` grant instead. 

## Architecture

The project deploys:

- **AgentCore Gateway** — MCP-compatible gateway configured with `CUSTOM_JWT` authorizer, validating tokens via Cognito's OIDC discovery endpoint
- **AWS Cognito** — User Pool, domain, resource server (`gateway/invoke` scope), and app client configured for `client_credentials` grant
- **get-menu** — Lambda function (Node.js 22) that returns a pizza menu
- **create-order** — Lambda function (Node.js 22) that accepts pizza IDs and creates an order

## Auth Flow

```
Client                        Cognito                     AgentCore Gateway
  |                              |                              |
  |-- POST /oauth2/token ------->|                              |
  |   (client_credentials)       |                              |
  |<-- access_token (JWT) -------|                              |
  |                              |                              |
  |------- POST /mcp (Bearer token) --------------------------->|
  |                              |   validate JWT via OIDC      |
  |                              |<-- /.well-known/openid-conf -|
  |<--- MCP response -------------------------------------------|
```

## Project Structure

```
gateway-with-inbound-jwt/
├── lambda/
│   ├── get_menu/index.js          # Returns pizza menu
│   └── create_order/index.js      # Creates an order from pizza IDs
├── terraform/
│   ├── providers.tf               # AWS provider and naming config
│   ├── gateway.tf                 # Gateway, IAM role, JWT authorizer, and tool targets
│   ├── cognito.tf                 # Cognito User Pool, domain, resource server, app client
│   ├── lambda-get-menu.tf         # get-menu Lambda function
│   └── lambda-create-order.tf     # create-order Lambda function
├── Makefile                       # Deploy, auth, and test commands
└── README.md
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- `curl` and `jq` for testing

## Deploy

```bash
make deploy-all
```

This runs `terraform init` and `terraform apply` to provision all resources.

## Authenticate and Test

### 1. List available MCP tools before authenticating

```bash
make list-tools
```

This call will result in an error since you haven't authenticated yet. 

```json
{
   "jsonrpc":"2.0",
   "id":0,
   "error":{
      "code":-32001,
      "message":"Invalid Bearer token"
   }
}
```


### 2. Get an access token

```bash
make get-token
```

This calls the Cognito token endpoint with `client_credentials` grant, extracts the JWT, and saves it to `./tmp/access_token.txt`.

All `make` targets that send requests to the MCP endpoint automatically read the token from `./tmp/access_token.txt` and pass it as an `Authorization: Bearer` header.

### 3. List available MCP tools, now with token

```bash
make list-tools
```

Successful this time!

```json
{
   "jsonrpc":"2.0",
   "id":1,
   "result":{
      "tools":[
         {
            "inputSchema":{
               "type":"object",
               "properties":{
                  "itemIds":{
                     "description":"Array of pizza IDs to order, always check menu first.",
                     "type":"array",
                     "items":{
                        "type":"integer"
                     }
                  }
               },
               "required":[
                  "itemIds"
               ]
            },
            "name":"create-order___create-order",
            "description":"Use this tool to submit a new pizza order"
         },
         {
            "inputSchema":{
               "type":"object"
            },
            "name":"get-menu___get-menu",
            "description":"This tool returns pizza menu"
         }
      ]
   }
}
```

### 4. Get the pizza menu

```bash
make get-menu
```

```json
{
   "jsonrpc":"2.0",
   "id":1,
   "result":{
      "isError":false,
      "content":[
         {
            "type":"text",
            "text":"{\"menu\":[{\"id\":1,\"name\":\"Margherita\",\"price\":12.99},{\"id\":2,\"name\":\"Pepperoni\",\"price\":14.99},{\"id\":3,\"name\":\"Four Cheese\",\"price\":15.99},{\"id\":4,\"name\":\"BBQ Chicken\",\"price\":16.99},{\"id\":5,\"name\":\"Hawaiian\",\"price\":15.49},{\"id\":6,\"name\":\"Veggie Supreme\",\"price\":14.99}]}"
         }
      ]
   }
}
```

## Cleanup

```bash
make destroy
```
