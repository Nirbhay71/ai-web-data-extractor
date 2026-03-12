import logging
from playwright.async_api import async_playwright

logger = logging.getLogger(__name__)

async def fetch_html(url: str) -> str:
    """
    Loads dynamic webpages using Playwright and returns the raw HTML content.
    """
    logger.info(f"Fetching HTML from {url}...")
    try:
        async with async_playwright() as p:
            # Using chromium for broader compatibility
            browser = await p.chromium.launch(headless=True)
            page = await browser.new_page()
            
            # Wait until there are no more than 2 network connections for at least 500 ms.
            await page.goto(url, wait_until="networkidle")
            
            # Extract full HTML
            html_content = await page.content()
            
            await browser.close()
            logger.info(f"Successfully fetched HTML from {url}.")
            return html_content
    except Exception as e:
        logger.error(f"Error fetching HTML from {url}: {e}")
        raise
