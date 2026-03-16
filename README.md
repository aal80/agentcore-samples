# Amazon Bedrock AgentCore Samples

A [growing] collection of sample projects demonstrating how to build, deploy, and run AI agents with [Amazon Bedrock AgentCore](https://aws.amazon.com/bedrock/agentcore/). Each sample shows a different framework, approach, feature.

## Samples

| Sample | Framework | Language | IaC | Description |
|--------|-----------|----------|-----|-------------|
| [local-strands-agent](local-strands-agent/) | Strands Agents SDK | Python | -- | Local AI agent with custom tools (not deployed to AgentCore) |
| [empty-shell-with-agentcore-sdk](empty-shell-with-agentcore-sdk/) | AgentCore SDK | Python | Terraform | Minimal runtime using the `bedrock-agentcore` Python SDK. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [empty-shell-with-fastapi](empty-shell-with-fastapi/) | FastAPI | Python | Terraform | Minimal runtime implementing AgentCore's HTTP interface with `FastAPI`. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [empty-shell-with-flask](empty-shell-with-flask/) | Flask | Python | Terraform | Minimal runtime implementing AgentCore's HTTP interface with `Flask`. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |
| [empty-shell-with-expressjs](empty-shell-with-expressjs/) | Express.js | Node.js | Terraform | Minimal runtime implementing AgentCore's HTTP interface with `Express.js`. Illustrates AgentCore Runtime interface implementation, doesn't actually have an agent running. |

## How AgentCore Runtimes Work

1. **Container** -- Your agent runs as a Docker container that listens on port `8080` and exposes two endpoints:
   - `POST /invocations` -- Receives the agent payload and returns a response
   - `GET /ping` -- Health check endpoint

[Read AgentCore Runtime docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-http-protocol-contract.html)

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.
