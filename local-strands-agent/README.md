# Local Strands Agent

A simple AI agent built with [Strands Agents SDK](https://github.com/strands-agents/sdk-python) that responds in limericks and counts letters using a custom tool.

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (recommended) or pip
- AWS credentials configured (Strands uses Amazon Bedrock by default)

## Setup

```bash
# Create virtual environment and install dependencies
uv sync

# Or using pip
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Usage

```bash
uv run agent.py
```

The agent uses a custom `letter_counter` tool and a system prompt that instructs it to respond in limericks while returning the letter count.

## Project Structure

```
.
├── agent.py           # Agent definition with custom tool and system prompt
├── pyproject.toml     # Project metadata and dependencies
├── requirements.txt   # Pip-compatible dependencies
└── uv.lock            # Locked dependency versions
```
