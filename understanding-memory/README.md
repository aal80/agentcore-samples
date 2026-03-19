# Understanding Memory in Amazon Bedrock AgentCore

This sample demonstrates how to use short and long-term memory in Amazon Bedrock AgentCore. It covers creating a memory resource, configuring memory strategies, ingesting conversation events, and monitoring memory processing with a CloudWatch dashboard.

There's no agent in this sample. Memory only.

## Architecture

The sample provisions:
- A **Memory resource** with 7-day event expiry
- Three **memory strategies** with different namespace scoping:
  - **User Preference** (`USER_PREFERENCE`) — extracts user preferences, scoped per actor
  - **Semantic** (`SEMANTIC`) — extracts factual information, scoped per actor + session
  - **Session Summary** (`SUMMARIZATION`) — creates running conversation summaries, scoped per actor + session
- **Log delivery** for memory's application logs (CloudWatch Logs) and traces (CloudWatch Transactional Search)
- A **CloudWatch dashboard** for monitoring event ingestion, strategy processing (extraction & consolidation), errors, and token usage

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0

## Project Structure

```
.
├── Makefile                        # Commands for deploy, test, and query
├── terraform/
│   ├── providers.tf                # AWS provider config
│   ├── memory.tf                   # Memory resource, IAM role, test identifiers
│   ├── memory-strategies.tf        # Memory strategy definitions
│   ├── log-delivery-logs.tf        # Application logs delivery to CloudWatch Logs
│   ├── log-delivery-traces.tf      # Traces delivery to CloudWatch Transactional Search
│   └── dashboard.tf                # CloudWatch monitoring dashboard
└── test-data/
    ├── payload.json                # Sample conversation payload
    └── search-criteria.json        # Semantic search query for retrieve
```

## Getting Started

### 1. Deploy infrastructure

```bash
make deploy-infra
```

This creates the memory resource, strategies, CloudWatch dashboard, and writes resource IDs to `./tmp/`.

### 2. Create an event

Send a sample conversation to the memory resource:

```bash
make create-event
```

This sends the conversation in `test-data/payload.json` — a user and assistant discussing building a gaming PC.

### 3. List events

View ingested events for the current session:

```bash
make list-events
```

### 4. List memory records

View memory records extracted by the summarization strategy:

```bash
make list-memory-records
```

> Note: Memory strategies process events asynchronously. There may be a short delay between `create-event` and records appearing in `list-memory-records`.

### 5. Retrieve memory records (semantic search)

Search memory records using a semantic query defined in `test-data/search-criteria.json`:

```bash
make retrieve-memory-records
```

This performs an embedding-based search against extracted memory records, returning the most relevant results ranked by cosine similarity.

## Monitoring

The Terraform config deploys a CloudWatch dashboard with:

- **Event Ingestion** — CreateEvent invocations, latency (avg/p99), events vs memory records created
- **Errors & Token Count** — errors by operation, user errors, token consumption
- **Strategy Extraction** — invocations and latency per strategy for the extraction step
- **Strategy Consolidation** — invocations and latency per strategy for the consolidation step
- **Token Usage by Strategy** — token consumption broken down by strategy

## Cleanup

```bash
make destroy
```
