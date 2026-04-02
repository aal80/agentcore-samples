# AgentCore Identity Basics

This project demonstrates the core identity and credential management APIs in Amazon Bedrock AgentCore Identity. It shows how to create workload identities, acquire workload access tokens, store credentials in the AgentCore vault, and retrieve them securely at runtime — without hardcoding secrets in agent code.

## Concepts

AgentCore Identity works in two layers:

**Control plane** (`bedrock-agentcore-control`) — set up once:
- **Credential Provider** — stores a credential (API key or OAuth2 config) in the AgentCore vault
- **Workload Identity** — represents the agent itself; acts as the principal for all credential lookups. Workload identities are created and managed automatically when running agents on AgentCore Runtime. They can also be managed manually, as shown in this project for educational purposes. 

**Data plane** (`bedrock-agentcore`) — called at runtime:
- **Workload Access Token** — proves who the agent is and optionally who it's acting on behalf of
- **GetResourceApiKey / GetResourceOauth2Token** — uses Workload Access Token to retrieve credentials from Credential Providers

## Diagrams

The following diagram illustrates a general workflow of using AgentCore Identity

![](./images/sequence.png)

* Step 1 - System operator or administrator registers Credential Providers. This can be either API Key or OAuth2-based provider. 
* Step 2 - A workload identity is registered with AgentCore's identity registry. This step is fully automatic when deploying agents on AgentCore Runtime. However you can use it with any external agents as well, as illustrated in this project. 
* Step 3 - An agent retrieves workload identity access token. This is an opaque token that can only be retrieved by entiries with proper AWS IAM permissions. An agent can either
  * Retrieve workload identity access token representing the agent itself (no user involved)
  * Retrieve workload identity access token that contains user context, as will be described below. 
* Step 4 - The agent uses workload identity access token to request resource access credentials from the Credential Provider registered in Step 1. AgentCore validates that supplied workload identity has permissions to access requested Credentials Provider. Credential provider obtains resource credentials (e.g. API key or OAuth2 access token), stores it in its internal credentials vault and returns to the agent. At no point in time the agent has access to long-lived credentials like client_id or client_secret. 
* Step 5 - The agent uses obtained resource credential to access protected resources, for example an MCP Server. 

The exact workflow depends on several parameters, such as 
* Whether the agent will be accessing protected resource on behalf of itself or on behalf of the user
* Whetner the protected resource requires an API Key or OAuth2 token

The following diagram illustrates which AgentCore SDK methods (or CLI/API calls) should be used for various scenarios

![](./images/decision-tree.png)

If the agent is acting on behalf of
* Itself
  * Get workload identity using the `GetWorkloadAccessToken` method
  * If agent requires
    * An API Key - use `GetResourceApiKey` method
    * An OAuth2 token - use `GetResourceOauth2Token`. In this scenario, the Credentials Provider will use `client_credentials` grant internally to obtain access token. 
* A user
  * Get workload identity using either `GetWorkloadAccessTokenForJWT` (extracts UserId from JWT) or `GetWorkloadAccessTokenForUserId` (uses supplied UserId directly)
  * If agent requires
    * An API Key - use `GetResourceApiKey` method. The API Key credentials are NOT user specific, however the credential access audit record will contain user context. 
    * An OAuth2 token - use `GetResourceOauth2Token`. In this scenario, the Credentials Provider will first try to find existing user-specific access token. If refresh token is available, Credentials Provider will also attempt to refresh expired tokens. When Credentials Provider cannot obtain access token, it will trigger the OAuth2 `authorization_code` grant return and return authorization URL. Your agent needs to be able to handle this. 

## Running this sample project

This project illustrates a simple path using AgentCore Identity. For education purposes you'll trigger each step manually. When using AgentCore, may of these steps are either fully transparent (like Workflow Identity creation) or simplified using AgentCore SDK. 

![](./images/project-workflow.png)

### Prerequisites

- AWS CLI configured with appropriate credentials
- make

### 1. Create a credential provider

The API Key used for this project is hardcoded in `Makefile`, the value is

```text
API_KEY=abcd1234abcd1234
```

Create an API Key Credential Provider:

```bash
make create-api-key-credential-provider
```

Validate that the Credential Provider was successfully created

```bash
make get-api-key-credential-provider
```

```yaml
name: test-api-key-provider
createdTime: '2026-04-02T16:20:16.649000-05:00'
lastUpdatedTime: '2026-04-02T16:20:16.649000-05:00'
credentialProviderArn: arn:aws:bedrock-agentcore:us-east-1:123123123:token-vault/default/apikeycredentialprovider/test-api-key-provider

...redacted...
```

### 2. Create a Workload Identity

```bash
make create-workload-identity
```

Validate that the Workload Identity was successfully created

```bash
make get-workload-identity
```

```yaml
name: test-identity
workloadIdentityArn: arn:aws:bedrock-agentcore:us-east-1:123123123:workload-identity-directory/default/workload-identity/test-identity
createdTime: '2026-04-02T16:22:21.318000-05:00'
lastUpdatedTime: '2026-04-02T16:22:21.318000-05:00'
allowedResourceOauth2ReturnUrls: []
```

### 3. Retrieve the workload access token

```bash
make get-workload-access-token
```

```text
Getting workload access token for machine2machine...
aws bedrock-agentcore get-workload-access-token \
                --workload-name test-identity \
                --query workloadAccessToken --output text > ./tmp/workload_access_token.txt

Stored in ./tmp/workload_access_token.txt (preview: AgV4T5tSAY0N54CCnxe8...)
```

The workload access token was successfully retrieved and stored in `./tmp/workload_access_token.txt`. 

### 4. Retrieve the resource credentials from credentials provider

```bash
make get-resource-api-key
```

This command will read the workload token retrieved in step 3 and use it to obtain the API key from Credential Provider. 

```text
> WORKLOAD_ACCESS_TOKEN=AgV4T5tSAY0N54CCnxe8...REDACTED...
Getting API key for provider 'test-api-key-provider'...

aws bedrock-agentcore get-resource-api-key \
                --resource-credential-provider-name test-api-key-provider \
                --workload-identity-token **REDACTED**

Result:
apiKey: abcd1234abcd1234
```

## Cleanup

```bash
make delete-workload-identity
make delete-api-key-credential-provider
rm -rf tmp
```
