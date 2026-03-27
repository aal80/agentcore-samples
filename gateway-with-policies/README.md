# AgentCore Gateway with Policies - Step-by-Step Tutorial

This tutorial demonstrates how to gradually enable security on an [Amazon Bedrock AgentCore Gateway](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html) using JWT authentication and AgentCore Policies.

You'll build a pizza ordering MCP gateway with two tools:
- **get-menu** - Returns the pizza menu
- **create-order** - Submits a pizza order (takes a `pizzaId` parameter)

And two OAuth clients with different scopes:
- **client1** - Has scope `gateway/get_menu` only
- **client2** - Has scopes `gateway/get_menu` and `gateway/create_order`

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0
- `jq` and `make` 

## Architecture

![](/images/architecture.png)

## Walkthrough

### Step 1 - Deploy the sample. 

```bash
make deploy-all
```

This creates the gateway, Lambda functions implementing tools, Cognito resources, policy engine (not yet connected to the gateway), and observability (logs/traces). 

At this point this sample DOES NOT have any authorization controls enabled yet. The gateway starts with `authorizer_type = "NONE"` and no policy engine attached (see [terraform/gateway.tf](./terraform/gateway.tf#L85-L107)).

---

## Step 2: Test no security (open access).

The starting configuration is gateway has no authentication and no policy engine. Anyone can call any tool. 

```bash
# List available tools
make list-tools

Result: 
{
   "jsonrpc":"2.0",
   "id":1,
   "result":{
      "tools":[
         {
            "inputSchema":{... redacted ...},
            "name":"create-order___create-order",
            "description":"Use this tool to submit a new pizza order"
         },
         {
            "inputSchema":{ ... redacted ...},
            "name":"get-menu___get-menu",
            "description":"This tool returns pizza menu"
         }
      ]
   }
}
```

```bash
# Get the pizza menu
make get-menu

Result:
{
   "jsonrpc":"2.0",
   "id":1,
   "result":{
      "isError":false,
      "content":[
         {
            "type":"text",
            "text":"{\"menu\":[
                {\"id\":1,\"name\":\"Margherita\",\"price\":12.99},
                {\"id\":2,\"name\":\"Pepperoni\",\"price\":14.99},
                ... redacted...]}"
         }
      ]
   }
}
```


```bash
# Create an order
make create-order

Result:
{
   "jsonrpc":"2.0",
   "id":1,
   "result":{
      "isError":false,
      "content":[
         {
            "type":"text",
            "text":"{\"date\":\"2026-03-27T19:51:25.698Z\",\"item\":\"Margherita\",\"total\":12.99}"
         }
      ]
   }
}
```

All three calls succeed without any authentication.

---

## Step 3: Enable JWT Authentication

Cognito user pool and two clients were created in previous step. 
* client1 only has access to `gateway/get_menu` scope
* client2 has access to `gateway/get_menu` and `gateway/create_order` scope

See [terraform/cognito.tf](./terraform/cognito.tf#L26-L46) for details. Credentials for both clients were stored under `/tmp/cognito_client*.txt` files.

To enable JWT Authorization on the AgentCore Gateway, update the gateway resouce in [terraform/gateway.tf](terraform/gateway.tf#L85):

1. Change `authorizer_type` from `"NONE"` to `"CUSTOM_JWT"`
2. Uncomment the `authorizer_configuration` block

```hcl
resource "awscc_bedrockagentcore_gateway" "this" {
  # ...
  authorizer_type = "CUSTOM_JWT"

  authorizer_configuration = {
    custom_jwt_authorizer = {
      discovery_url   = local.cognito_discovery_url
      allowed_clients = [
        aws_cognito_user_pool_client.client1.id,
        aws_cognito_user_pool_client.client2.id,
      ]
    }
  }
  # ...
}
```

Deploy the updated configuration. Note that updating authorization configuration requires recreating the AgentCore Gateway. 

```bash
make deploy-all-recreate-gateway
```

## Step 4: Test JWT validation

First, let's test without obtaining access tokens. 

```bash
make list-tools
# => Unauthorized
```

MCP Requests are being rejected since now AgentCore Gateway expects to receive JWT in all requests. Let's get an access token and test

```bash
# Get a token for client1 (has get_menu scope only)
make get-client1-token
```

```bash
# Both tools work - no policy engine means no authorization checks
make list-tools
make get-menu
make create-order
```

```bash
# Get a token for client2 (has get_menu + create_order scopes)
make get-client2-token

make list-tools
make get-menu
make create-order
```

 - both clients can access all tools since there's no policy engine yet:

Both clients can call all tools. Authentication verifies identity, but without a policy engine there are no authorization rules.

---

## Step 3: Enable Policy Engine (No Policies Yet)

In [terraform/gateway.tf](terraform/gateway.tf), uncomment the `policy_engine_configuration` block:

```hcl
resource "awscc_bedrockagentcore_gateway" "this" {
  # ...
  policy_engine_configuration = {
    arn  = awscc_bedrockagentcore_policy_engine.this.policy_engine_arn
    mode = "ENFORCE"
  }
  # ...
}
```

Deploy:

```bash
make deploy-all
```

Now test - **all calls are denied** because Cedar uses default-deny and there are no permit policies:

```bash
make get-client1-token
make list-tools    # => tools list is empty
make get-menu      # => Denied
make create-order  # => Denied
```

---

## Step 4: Enable `permit_all` Policy

In [terraform/policy_engine.tf](terraform/policy_engine.tf), uncomment the `permit_all` policy:

```hcl
resource "awscc_bedrockagentcore_policy" "permit_all" {
  name             = "permit_all"
  policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
  validation_mode  = "IGNORE_ALL_FINDINGS"

  definition = {
    cedar = {
      statement = "permit(principal, action, resource is AgentCore::Gateway);"
    }
  }
}
```

Deploy:

```bash
make deploy-all
```

Now all authenticated clients can use all tools again:

```bash
make get-client1-token
make list-tools    # => Shows get-menu and create-order
make get-menu      # => Returns pizza menu
make create-order  # => Order created
```

---

## Step 5: Restrict to `get-menu` Only

Replace the `permit_all` policy with a targeted `allow_get_menu` policy that only permits the get-menu tool.

In [terraform/policy_engine.tf](terraform/policy_engine.tf):
1. Comment out `permit_all`
2. Uncomment `allow_get_menu`

```hcl
resource "awscc_bedrockagentcore_policy" "allow_get_menu" {
  name             = "allow_get_menu"
  policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
  validation_mode  = "IGNORE_ALL_FINDINGS"

  definition = {
    cedar = {
      statement = <<-EOT
        permit(
          principal,
          action == AgentCore::Action::"get-menu___get-menu",
          resource == AgentCore::Gateway::"${awscc_bedrockagentcore_gateway.this.gateway_arn}"
        );
      EOT
    }
  }
}
```

Deploy:

```bash
make deploy-all
```

Test - both clients can get the menu, but neither can create orders:

```bash
make get-client1-token
make get-menu      # => Returns pizza menu
make create-order  # => Denied

make get-client2-token
make get-menu      # => Returns pizza menu
make create-order  # => Denied
```

---

## Step 6: Allow `create-order` with Scope Check

Add a policy that permits `create-order` only if the caller has the `gateway/create_order` scope in their JWT token.

In [terraform/policy_engine.tf](terraform/policy_engine.tf), uncomment `allow_create_order_with_scope`:

```hcl
resource "awscc_bedrockagentcore_policy" "allow_create_order_with_scope" {
  name             = "allow_create_order_with_scope"
  policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
  validation_mode  = "IGNORE_ALL_FINDINGS"

  definition = {
    cedar = {
      statement = <<-EOT
        permit(
          principal,
          action == AgentCore::Action::"create-order___create-order",
          resource == AgentCore::Gateway::"${awscc_bedrockagentcore_gateway.this.gateway_arn}"
        )
        when {
          principal.hasTag("scope") &&
          principal.getTag("scope") like "*gateway/create_order*"
        };
      EOT
    }
  }
}
```

Deploy:

```bash
make deploy-all
```

Test - client1 (missing scope) is denied, client2 (has scope) succeeds:

```bash
# client1 only has gateway/get_menu scope
make get-client1-token
make get-menu      # => Returns pizza menu
make create-order  # => Denied (missing gateway/create_order scope)

# client2 has both gateway/get_menu and gateway/create_order scopes
make get-client2-token
make get-menu      # => Returns pizza menu
make create-order  # => Order created!
```

---

## Step 7: Forbid Pineapple Pizza

Add a `forbid` policy that blocks ordering Hawaiian pizza (id=5), regardless of any permit policies. Cedar's `forbid` always wins over `permit`.

In [terraform/policy_engine.tf](terraform/policy_engine.tf), uncomment `forbid_pineapple_pizza`:

```hcl
resource "awscc_bedrockagentcore_policy" "forbid_pineapple_pizza" {
  name             = "forbid_pineapple_pizza"
  policy_engine_id = awscc_bedrockagentcore_policy_engine.this.policy_engine_id
  validation_mode  = "IGNORE_ALL_FINDINGS"

  definition = {
    cedar = {
      statement = <<-EOT
        forbid (
          principal,
          action == AgentCore::Action::"create-order___create-order",
          resource == AgentCore::Gateway::"${awscc_bedrockagentcore_gateway.this.gateway_arn}"
        )
        when {
          context.input.pizzaId == 5
        };
      EOT
    }
  }
}
```

Deploy:

```bash
make deploy-all
```

Test - client2 can order any pizza except Hawaiian:

```bash
make get-client2-token

# Order a Margherita - works!
make create-order pizzaId=1
# => { "date": "...", "item": "Margherita", "total": 12.99 }

# Order a Hawaiian (id=5) - forbidden!
make create-order pizzaId=5
# => Denied
```

---

## Summary

| Step | Auth | Policy Engine | Policies | client1 | client2 |
|------|------|--------------|----------|---------|---------|
| 1 | None | Off | - | Full access | Full access |
| 2 | JWT | Off | - | Full access | Full access |
| 3 | JWT | Enforce | None | All denied | All denied |
| 4 | JWT | Enforce | permit_all | Full access | Full access |
| 5 | JWT | Enforce | allow_get_menu | Menu only | Menu only |
| 6 | JWT | Enforce | allow_get_menu + allow_create_order (scoped) | Menu only | Menu + Orders |
| 7 | JWT | Enforce | above + forbid_pineapple | Menu only | Menu + Orders (no Hawaiian) |

## Key Concepts

- **Default deny**: Without any permit policy, Cedar denies all requests
- **Forbid wins**: A `forbid` policy always overrides `permit` policies
- **Scope-based access**: JWT scopes from Cognito are available via `principal.getTag("scope")` in Cedar
- **Tool input validation**: Cedar can inspect tool arguments via `context.input.<field>` to enforce business rules
- **Action naming**: AgentCore uses the format `TargetName___ToolName` (triple underscore) for Cedar actions

## Useful Commands

```bash
make deploy-all                    # Deploy/update infrastructure
make deploy-all-recreate-gateway   # Recreate gateway (use when gateway config changes fail)
make destroy                       # Tear down everything

make get-client1-token             # Get OAuth token for client1
make get-client2-token             # Get OAuth token for client2

make list-tools                    # List available MCP tools
make get-menu                      # Call the get-menu tool
make create-order                  # Order pizza (default: pizzaId=1)
make create-order pizzaId=5        # Order a specific pizza by ID
```

## Cleanup

```bash
make destroy
```
