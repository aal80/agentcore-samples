import logging
import os
import asyncio
from strands import Agent, tool
from strands.multiagent.a2a import A2AServer
import uvicorn
from fastapi import FastAPI

from ddgs import DDGS
from ddgs.exceptions import RatelimitException, DDGSException

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

runtime_url = os.environ.get('AGENTCORE_RUNTIME_URL', 'http://127.0.0.1:9000/')

@tool
async def internet_search(keywords: str, max_results: int = 3) -> str:
    """Search the internet for current information.
    Args:
        keywords (str): Search query keywords
        max_results (int): Max results to return (default 3)
    Returns:
        Search results as formatted text
    """
    try:
        async def search_with_timeout():
            return DDGS().text(keywords, region="us-en", max_results=max_results)

        results = await asyncio.wait_for(search_with_timeout(), timeout=8.0)

        if results:
            formatted = []
            for i, result in enumerate(results[:max_results], 1):
                formatted.append(
                    f"{i}. {result.get('title', 'No title')}\n"
                    f"   {result.get('body', '')}\n"
                    f"   {result.get('href', '')}"
                )
            return "\n".join(formatted)
        else:
            return "No results found."

    except asyncio.TimeoutError:
        logger.warning(f"Search timeout for: {keywords}")
        return "Search timed out. Try a more specific query."
    except RatelimitException:
        logger.warning("Rate limit hit")
        return "Rate limit reached. Please try again in a moment."
    except (DDGSException, Exception) as e:
        logger.error(f"Search error: {e}")
        return f"Search unavailable: {str(e)[:50]}"

system_prompt = """You are a Weather Assistant. Answer weather-related questions by searching the internet for current conditions, forecasts, and weather events.

Guidelines:
- Always search for up-to-date information rather than relying on cached knowledge
- Always return concise answer in format "The weather in {location} is {temperature}. It is {conditions, e.g. cloudy}"
- Specify units clearly (e.g. 72°F / 22°C)
- Keep responses concise and focused on what was asked
- If search fails, acknowledge the limitation
"""

agent = Agent(
    system_prompt=system_prompt,
    tools=[internet_search],
    name="Weather Agent",
    description="An agent that answers weather questions using live internet search.",
)

host, port = "0.0.0.0", 9000

a2a_server = A2AServer(
    agent=agent,
    http_url=runtime_url,
    serve_at_root=True,
    # enable_a2a_compliant_streaming=True
)

app = FastAPI()

@app.get("/ping")
def ping():
    return {"status": "healthy"}

app.mount("/", a2a_server.to_fastapi_app())

if __name__ == "__main__":
    uvicorn.run(app, host=host, port=port)