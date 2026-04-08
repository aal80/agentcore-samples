from pathlib import Path
import logging, boto3, base64
from bedrock_agentcore.tools.browser_client import browser_session
from playwright.sync_api import sync_playwright

logging.basicConfig(level=logging.INFO)
l = logging.getLogger()

BROWSER_ID = Path("./../tmp/browser_id.txt").read_text().strip()
REGION = boto3.session.Session().region_name

l.info("BROWSER_ID=%s", BROWSER_ID)

def main():
    l.info("Starting the demo....")

    l.info("Creating new browser session in the browser_id=%s", BROWSER_ID)
    with browser_session(REGION, identifier=BROWSER_ID, viewport={"width": 1200, "height": 800}) as client:
        l.info("Session created, session_id=%s", client.session_id)

        ws_url, headers = client.generate_ws_headers()

        l.info("Connecting a Playwright client to the session via ws_url=%s", ws_url)
        with sync_playwright() as p:
            l.info("Playwright client connected")
            browser = p.chromium.connect_over_cdp(ws_url, headers=headers)
            context = browser.contexts[0] if browser.contexts else browser.new_context()
            page = context.pages[0] if context.pages else context.new_page()

            l.info("Navigating to https://aws.amazon.com")
            page.goto("https://aws.amazon.com")
            l.info("Page opened. Title=%s", page.title())

            l.info("Saving page screenshot...")
            cdp_client = context.new_cdp_session(page)
            screenshot_data = cdp_client.send("Page.captureScreenshot", {
                "format":"jpeg",
                "quality": 80,
                "captureBeyondViewport": True
            })

            image_data = base64.b64decode(screenshot_data['data'])
            with open("./../tmp/screenshot.jpeg", "wb") as f:
                f.write(image_data)
                
            l.info("Screenshot saved as ./tmp/screenshot.jpg...")

            page.close()
            browser.close()

            l.info("All done!")


if __name__ == "__main__":
    main()
