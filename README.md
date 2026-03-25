# Amazon Bedrock AgentCore Samples

A **growing** collection of sample projects demonstrating how to build, deploy, and run AI agents and related workloads with [Amazon Bedrock AgentCore](https://aws.amazon.com/bedrock/agentcore/). Each sample shows a different framework, approach, feature etc. 

## Learning Guide

The samples are organized as a learning path — start from the top to build foundational understanding, then progress to more advanced topics.

### 1. Understanding AgentCore Runtime

Before building agents, understand the Runtime interface itself. These "empty shell" samples implement the AgentCore HTTP contract without running an actual agent — perfect for learning the protocol in isolation.

| Sample | Framework | Language | Description |
|--------|-----------|----------|-------------|
| [empty-shell-with-agentcore-sdk](empty-shell-with-agentcore-sdk/) | AgentCore SDK | Python | Minimal runtime using the `bedrock-agentcore` Python SDK. |
| [empty-shell-with-fastapi](empty-shell-with-fastapi/) | FastAPI | Python | Implements the Runtime HTTP interface with FastAPI. |
| [empty-shell-with-flask](empty-shell-with-flask/) | Flask | Python | Implements the Runtime HTTP interface with Flask. |
| [empty-shell-with-expressjs](empty-shell-with-expressjs/) | Express.js | Node.js | Implements the Runtime HTTP interface with Express.js. |

> [Read AgentCore Runtime docs for more info](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/runtime-http-protocol-contract.html)

### 2. Running Agents on AgentCore Runtime

With the Runtime interface understood, deploy actual agents. Start with a local agent, then move to cloud-deployed agents with observability.

| Sample | Framework | Language | Description |
|--------|-----------|----------|-------------|
| [local-strands-agent](local-strands-agent/) | Strands | Python | Local AI agent with custom tools — no cloud deployment needed. |
| [simple-strands-agent](simple-strands-agent/) | Strands | Python | A simple Strands Agent deployed on AgentCore Runtime. |
| [strands-agent-with-observability](strands-agent-with-observability/) | Strands | Python | Strands agent on AgentCore Runtime with full observability via OpenTelemetry, CloudWatch Logs/Traces, and Transactional Search. |

### 3. AgentCore Memory

Add persistence and recall to your agents. Start with the memory fundamentals, then see how memory integrates into a deployed agent.

| Sample | Framework | Language | Description |
|--------|-----------|----------|-------------|
| [memory-basics](memory-basics/) | -- | -- | IaC and test scripts illustrating how AgentCore Memory works. No agent — memory only. |
| [strands-agent-with-memory](strands-agent-with-memory/) | Strands | Python | Strands agent on AgentCore Runtime using AgentCore Memory for conversation history, semantic memories, summaries, and user preferences. |

### 4. AgentCore Gateway

Expose agents securely through managed MCP gateways. Progress from basic setup to authentication and request/response interception.

| Sample | Framework | Language | Description |
|--------|-----------|----------|-------------|
| [gateway-basics](gateway-basics/) | -- | -- | AgentCore Gateway with MCP backed by Lambda functions. Covers resources, targets, observability, and CloudWatch dashboards. |
| [gateway-with-inbound-jwt](gateway-with-inbound-jwt/) | -- | -- | Gateway secured with JWT-based auth using Amazon Cognito. Clients authenticate via OAuth2 `client_credentials` flow. |
| [gateway-with-interceptors](gateway-with-interceptors/) | -- | -- | Gateway with Lambda interceptors that inspect and transform inbound requests and outbound responses. |

### 5. Security & Access Control

Lock down access to your AgentCore resources.

| Sample | Description |
|--------|-------------|
| [resource-policy-for-vpc-only-access](resource-policy-for-vpc-only-access/) | Resource policy example restricting AgentCore Gateway access to a specific VPC. |

## License

This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.
