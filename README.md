# Amazon Bedrock AgentCore Samples

A **growing** collection of sample projects demonstrating how to build, deploy, and run AI agents and related workloads with [Amazon Bedrock AgentCore](https://aws.amazon.com/bedrock/agentcore/). Each sample shows a different framework, approach, feature etc. 

## Learning Guide

The samples are organized as a learning path — start from the top to build foundational understanding, then progress to more advanced topics.

**Or jump to:** 

1. [Understanding AgentCore Runtime](#1-understanding-agentcore-runtime)
2. [Running Agents on AgentCore Runtime](#2-running-agents-on-agentcore-runtime)
3. [AgentCore Memory](#3-agentcore-memory)
4. [AgentCore Gateway](#4-agentcore-gateway)
5. [AgentCore Identity](#5-agentcore-identity)
6. [AgentCore Tools](#6-agentcore-tools)
7. [Misc](#7-misc)

### 1. Understanding AgentCore Runtime

Before building agents, understand the Runtime interface itself. These "empty shell" samples implement the AgentCore HTTP contract without running an actual agent — perfect for learning the protocol in isolation.

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [empty-shell-with-agentcore-sdk](empty-shell-with-agentcore-sdk/) | AgentCore SDK | Python | Terraform | Minimal runtime using the `bedrock-agentcore` Python SDK. |
| [empty-shell-with-fastapi](empty-shell-with-fastapi/) | FastAPI | Python | Terraform | Implements the Runtime HTTP interface with FastAPI. |
| [empty-shell-with-flask](empty-shell-with-flask/) | Flask | Python | Terraform | Implements the Runtime HTTP interface with Flask. |
| [empty-shell-with-expressjs](empty-shell-with-expressjs/) | Express.js | Node.js | Terraform | Implements the Runtime HTTP interface with Express.js. |

> [Read AgentCore Runtime docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-http-protocol-contract.html)

### 2. Running Agents on AgentCore Runtime

With the Runtime interface understood, deploy actual agents. Start with a local agent, then move to cloud-deployed agents with observability.

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [local-strands-agent](local-strands-agent/) | Strands | Python | -- | Local AI agent with custom tools — no cloud deployment needed. |
| [simple-strands-agent](simple-strands-agent/) | Strands | Python | Terraform | A simple Strands Agent deployed on AgentCore Runtime. |
| [strands-agent-with-observability](strands-agent-with-observability/) | Strands | Python | Terraform | Strands agent on AgentCore Runtime with full observability via OpenTelemetry, CloudWatch Logs/Traces, and Transactional Search. |

> [Read AgentCore Runtime docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/agents-tools-runtime.html)


### 3. AgentCore Memory

Add persistence and recall to your agents. Start with the memory fundamentals, then see how memory integrates into a deployed agent.

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [memory-basics](memory-basics/) | -- | -- | Terraform | IaC and test scripts illustrating how AgentCore Memory works. No agent — memory only. |
| [strands-agent-with-memory](strands-agent-with-memory/) | Strands | Python | Terraform | Strands agent on AgentCore Runtime using AgentCore Memory for conversation history, semantic memories, summaries, and user preferences. |

> [Read AgentCore Memory docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/memory.html)


### 4. AgentCore Gateway

Expose agents securely through managed MCP gateways. Progress from basic setup to authentication and request/response interception.

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [gateway-basics](gateway-basics/) | -- | -- | Terraform | AgentCore Gateway with MCP backed by Lambda functions. Covers resources, targets, observability, and CloudWatch dashboards. |
| [gateway-with-inbound-jwt](gateway-with-inbound-jwt/) | -- | -- | Terraform | Gateway secured with JWT-based auth using Amazon Cognito. Clients authenticate via OAuth2 `client_credentials` flow. |
| [gateway-with-interceptors](gateway-with-interceptors/) | -- | -- | Terraform | Gateway with Lambda interceptors that inspect and transform inbound requests and outbound responses. |
| [gateway-with-policies](gateway-with-policies/) | -- | -- | Terraform | Gateway with JWT-based auth and AgentCore Policy engine validating incoming request for fine-grained policy adherence. |
| [gateway-with-open-policy-agent](gateway-with-open-policy-agent/) | -- | -- | Terraform | Gateway with JWT-based auth and Open Policy Agent (OPA) integration, validating incoming request for fine-grained policy adherence. |

> [Read AgentCore Gateway docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html)

### 5. AgentCore Identity

Manage workload identities and credentials for agents. Start with the basics, then explore machine-to-machine and user-delegated authentication scenarios.

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [identity-basics](identity-basics/) | -- | -- | -- | Core identity and credential management APIs — create workload identities, create Credential Providers, store and retrieve credentials from the AgentCore vault. |
| [identity-machine-to-machine-jwt](identity-machine-to-machine-jwt/) | -- | -- | Terraform | Agent authenticates itself to a protected downstream service using OAuth2 `client_credentials` flow, mediated by AgentCore Identity. |
| [identity-user-federation-with-jwt](identity-user-federation-with-jwt/) | -- | -- | Terraform | Agent acts on behalf of a human user using OAuth2 `authorization_code` grant, obtaining a user-scoped access token via AgentCore Identity. |

> [Read AgentCore Identity docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/identity.html)


### 6. AgentCore Tools

Samples demonstrating AgentCore built-in tools that extend agent capabilities with managed, sandboxed execution environments.

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [code-interpreter-basics](code-interpreter-basics/) | boto3 | Python | Terraform | Interactive demos for AgentCore Code Interpreter — create sessions, execute Python code and shell commands in a managed sandboxed environment, and stream results. |
| [browser-basics](browser-basics/) | boto3 | Python | Terraform | Interactive demos for AgentCore Browser — create sessions, browse websites in a sandboxed environment, take screenshots, record sessions. |


> [Read AgentCore Code Interpreter docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/APIReference/API_InvokeCodeInterpreter.html)


### 7. Misc

| Sample | Description |
|--------|-------------|
| [resource-policy-for-vpc-only-access](resource-policy-for-vpc-only-access/) | Resource policy example restricting AgentCore Gateway access to a specific VPC. |

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.
