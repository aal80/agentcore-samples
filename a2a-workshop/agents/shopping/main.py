import logging
import os
import asyncio
from strands import Agent, tool
from strands.agent.conversation_manager import NullConversationManager
from strands.multiagent.a2a import A2AServer
import uvicorn
from fastapi import FastAPI

from ddgs import DDGS
from ddgs.exceptions import RatelimitException, DDGSException

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

runtime_url = os.environ.get('AGENTCORE_RUNTIME_URL', 'http://127.0.0.1:9000/')

@tool
async def search_amazon(query: str, max_results: int = 5) -> str:
    """Search Amazon for clothing and apparel products.
    Args:
        query (str): Product search query (e.g. "waterproof winter jacket men")
        max_results (int): Max results to return (default 5)
    Returns:
        Amazon product listings as formatted text with titles and links
    """
    try:
        async def search_with_timeout():
            return DDGS().text(f"site:amazon.com {query}", region="us-en", max_results=max_results)

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
            return "No results found on Amazon."

    except asyncio.TimeoutError:
        logger.warning(f"Search timeout for: {query}")
        return "Search timed out. Try a more specific query."
    except RatelimitException:
        logger.warning("Rate limit hit")
        return "Rate limit reached. Please try again in a moment."
    except (DDGSException, Exception) as e:
        logger.error(f"Search error: {e}")
        return f"Search unavailable: {str(e)[:50]}"

system_prompt = """You are a Shopping Assistant specializing in weather-appropriate clothing. You receive weather condition descriptions and recommend suitable apparel available on Amazon.

Guidelines:
- Analyze the weather conditions provided (temperature, precipitation, wind, humidity, season)
- Identify the most important clothing needs for those conditions
- Search Amazon for 2-3 specific apparel categories that match the conditions
- For each category, present the top results with product name and Amazon link
- Keep recommendations practical and relevant to the conditions
- Format your response as a clear list of recommendations with Amazon links

Examples of weather-to-apparel mapping:
- Cold + snow → insulated waterproof jacket, thermal base layer, snow boots
- Hot + sunny → lightweight breathable shirt, UV-protection hat, shorts
- Rain + mild → rain jacket, waterproof shoes
- Windy + cool → windbreaker, fleece layer
"""

agent = Agent(
    system_prompt=system_prompt,
    tools=[search_amazon],
    name="Shopping Agent",
    description="An agent that recommends weather-appropriate clothing from Amazon based on current weather conditions.",
)

host, port = "0.0.0.0", 9000

a2a_server = A2AServer(
    agent=agent,
    http_url=runtime_url,
    serve_at_root=True,
)

app = FastAPI()

@app.get("/ping")
def ping():
    return {"status": "healthy"}

app.mount("/", a2a_server.to_fastapi_app())

if __name__ == "__main__":
    uvicorn.run(app, host=host, port=port)
