# Amazon Bedrock AgentCore Samples

A [growing] collection of sample projects demonstrating how to build, deploy, and run AI agents with [Amazon Bedrock AgentCore](https://aws.amazon.com/bedrock/agentcore/). Each sample shows a different framework, approach, feature.

## Samples

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [simple-strands-agent](simple-strands-agent/) | Strands | Python | Terraform | A simple Strands Agent deployed on AgentCore Runtime. |
| [strands-agent-with-observability](strands-agent-with-observability/) | Strands | Python | Terraform | Strands agent deployed on AgentCore Runtime with full observability via OpenTelemetry, CloudWatch Logs/Traces, and Transacational Search. |
| [memory-basics](memory-basics/) | -- | -- | Terraform | IaC and test scripts illustrating how AgentCore Memory works. There's no agent in this sample. Memory only. |
| [strands-agent-with-memory](strands-agent-with-memory/) | Strands | Python | Terraform | Strands agent deployed on AgentCore Runtime and using AgentCore Memory for persisting conversation history and extracting semantic/summary/user preferences memories. |
| [gateway-basics](gateway-basics/) | -- | -- | Terraform | AgentCore Gateway with MCP backed by Lambda functions. Covers gateway resources, targets, observability, and CloudWatch dashboards. |
| [gateway-with-inbound-jwt](gateway-with-inbound-jwt/) | -- | -- | Terraform | AgentCore Gateway secured with JWT-based authentication using Amazon Cognito. Clients authenticate via OAuth2 `client_credentials` flow. |
| [gateway-with-interceptors](gateway-with-interceptors/) | -- | -- | Terraform | AgentCore Gateway with Lambda interceptors that inspect and transform inbound requests and outbound responses. |
| [empty-shell-with-agentcore-sdk](empty-shell-with-agentcore-sdk/) | AgentCore SDK | Python | Terraform | Minimal runtime using the `bedrock-agentcore` Python SDK. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [empty-shell-with-fastapi](empty-shell-with-fastapi/) | FastAPI | Python | Terraform | Minimal runtime implementing AgentCore's HTTP interface with `FastAPI`. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [empty-shell-with-flask](empty-shell-with-flask/) | Flask | Python | Terraform | Minimal runtime implementing AgentCore's HTTP interface with `Flask`. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [empty-shell-with-expressjs](empty-shell-with-expressjs/) | Express.js | Node.js | Terraform | Minimal runtime implementing AgentCore's HTTP interface with `Express.js`. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [local-strands-agent](local-strands-agent/) | Strands Agents SDK | Python | -- | Local AI agent with custom tools (not deployed to AgentCore) |

[Read AgentCore Runtime docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-http-protocol-contract.html)

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.
