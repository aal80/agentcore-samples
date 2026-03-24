# AgentCore Gateway Basics

A sample project demonstrating how to set up an Amazon Bedrock AgentCore Gateway with MCP (Model Context Protocol) backed by AWS Lambda functions. It covers creating a gateway resource, Lambda functions used as tools, gateway targets, observability (logs/metrics/traces), and monitoring gateway processing with a CloudWatch dashboard. Everything is provisioned and managed via Terraform. 

## Architecture

The project deploys:

- **AgentCore Gateway** — an MCP-compatible gateway that exposes Lambda functions as tools
- **get-menu** — Lambda function (Node.js 22) that returns a pizza menu
- **create-order** — Lambda function (Node.js 22) that accepts pizza IDs and creates an order
- **CloudWatch Dashboard** — monitors gateway invocations, latency, errors, and throttles
- **Log Delivery** — CloudWatch Logs and X-Ray traces for observability

## Project Structure

```
gateway-basics/
├── lambda/
│   ├── get_menu/index.js          # Returns pizza menu
│   └── create_order/index.js      # Creates an order from pizza IDs
├── terraform/
│   ├── providers.tf               # AWS provider and naming config
│   ├── gateway.tf                 # Gateway, IAM role, and tool targets
│   ├── lambda-get-menu.tf         # get-menu Lambda function
│   ├── lambda-create-order.tf     # create-order Lambda function
│   ├── dashboard.tf               # CloudWatch dashboard
│   ├── log-delivery-logs.tf       # CloudWatch Logs delivery
│   └── log-delivery-traces.tf     # X-Ray trace delivery
├── Makefile                       # Deploy and test commands
└── README.md
```

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- `curl` for testing

## Deploy

```bash
make deploy-all
```

This runs `terraform init` and `terraform apply` to provision all resources.

## Test

### List available MCP tools

```bash
make list-tools
```

```bash
curl -s -X POST https://{id}.gateway.bedrock-agentcore.{region}.amazonaws.com/mcp \
                -H "Content-Type: application/json" \
                -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'

{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "tools": [
      {
        "inputSchema": {
          "type": "object",
          "properties": {
            "itemIds": {
              "description": "Array of pizza IDs to order, always check menu first.",
              "type": "array",
              "items": {
                "type": "integer"
              }
            }
          },
          "required": [
            "itemIds"
          ]
        },
        "name": "create-order___create-order",
        "description": "Use this tool to submit a new pizza order"
      },
      {
        "inputSchema": {
          "type": "object"
        },
        "name": "get-menu___get-menu",
        "description": "This tool returns pizza menu"
      }
    ]
  }
}
```

### Get the pizza menu

```bash
make get-menu
```

```bash
curl -s -X POST https://{id}.gateway.bedrock-agentcore.{region}.amazonaws.com/mcp \
                -H "Content-Type: application/json" \
                -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"get-menu___get-menu","arguments":{}}}'

{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "isError": false,
    "content": [
      {
        "type": "text",
        "text": "{\"menu\":[{\"id\":1,\"name\":\"Margherita\",\"price\":12.99},{\"id\":2,\"name\":\"Pepperoni\",\"price\":14.99},{\"id\":3,\"name\":\"Four Cheese\",\"price\":15.99},{\"id\":4,\"name\":\"BBQ Chicken\",\"price\":16.99},{\"id\":5,\"name\":\"Hawaiian\",\"price\":15.49},{\"id\":6,\"name\":\"Veggie Supreme\",\"price\":14.99}]}"
      }
    ]
  }
}
```

### Create an order

```bash
make create-order
```

```bash
curl -s -X POST https://utrw-gateway-basics-g5jj3zehny.gateway.bedrock-agentcore.us-east-1.amazonaws.com/mcp \
                -H "Content-Type: application/json" \
                -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"create-order___create-order","arguments":{"itemIds":[1,2,3]}}}'

{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "isError": false,
    "content": [
      {
        "type": "text",
        "text": "{\"date\":\"2026-03-24T20:21:41.882Z\",\"items\":\"Margherita, Pepperoni, Four Cheese\",\"total\":43.97}"
      }
    ]
  }
}
```

## Cleanup

```bash
make destroy
```
