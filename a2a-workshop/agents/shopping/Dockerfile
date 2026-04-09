# Use uv's ARM64 Python base image (AgentCore runs on ARM)
FROM --platform=linux/arm64 ghcr.io/astral-sh/uv:python3.13-bookworm-slim

WORKDIR /app

# Copy uv files
COPY pyproject.toml uv.lock ./

# Install dependencies (including strands-agents)
RUN uv sync --frozen --no-cache

# Copy agent file
COPY main.py ./

# Expose port
EXPOSE 9000

# Run application
CMD ["uv", "run", "opentelemetry-instrument", "uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9000"]