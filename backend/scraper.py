import logging
import asyncio
import sys
import requests
from bs4 import BeautifulSoup
from errors import ScraperError

logger = logging.getLogger(__name__)

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/122.0.0.0 Safari/537.36"
    ),
    "Accept-Language": "en-US,en;q=0.9",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
}


async def fetch_html(url: str) -> str:
    """
    Fetches a webpage's HTML. Tries Playwright first for JS-heavy pages,
    falls back to requests+BeautifulSoup for simple/static pages.
    """
    logger.info(f"Fetching HTML from {url}...")

    # Try Playwright (works on Windows with proper event loop policy)
    pw_error_msg = "Not attempted"
    try:
        html = await _fetch_with_playwright(url)
        logger.info(f"Successfully fetched HTML via Playwright from {url}.")
        return html
    except Exception as e:
        pw_error_msg = str(e)
        logger.warning(f"Playwright failed ({pw_error_msg}). Falling back to requests...")

    # Fallback: plain HTTP request
    try:
        html = _fetch_with_requests(url)
        logger.info(f"Successfully fetched HTML via requests from {url}.")
        return html
    except requests.exceptions.RequestException as req_err:
        status_code = getattr(req_err.response, 'status_code', 'Unknown')
        
        if status_code == 403 or status_code == 429:
            raise ScraperError(
                user_message=f"ACCESS DENIED: The website is blocking our automated extraction (Status {status_code}).",
                developer_hint=f"Bot Detection triggered. Playwright failed with: '{pw_error_msg}'. Requests failed with: '{req_err}'."
            )
        elif status_code == 404:
            raise ScraperError(
                user_message="PAGE NOT FOUND: The target URL does not exist.",
                developer_hint=f"Verify the URL path. Playwright: {pw_error_msg}. Requests: {req_err}"
            )
        
        raise ScraperError(
            user_message=f"FAILED TO FETCH: Could not connect to the website.",
            developer_hint=f"Network error (Status {status_code}). Playwright: {pw_error_msg}. Requests: {req_err}"
        )
    except Exception as final_err:
        raise ScraperError(
            user_message="UNEXPECTED SCRAPING ERROR: Something went wrong while loading the page.",
            developer_hint=f"General failure: {final_err}. Playwright: {pw_error_msg}"
        )


async def _fetch_with_playwright(url: str) -> str:
    """Use Playwright (headless Chromium) with Stealth — best for JS-rendered pages."""
    from playwright.async_api import async_playwright
    from playwright_stealth import stealth_async
    import random

    # Safety check for Windows asyncio loop policy
    if sys.platform == "win32":
        from asyncio import WindowsProactorEventLoopPolicy
        if not isinstance(asyncio.get_event_loop_policy(), WindowsProactorEventLoopPolicy):
            logger.info("Setting WindowsProactorEventLoopPolicy in scraper...")
            asyncio.set_event_loop_policy(WindowsProactorEventLoopPolicy())

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        
        # Add randomized viewport for fingerprint diversity
        width = random.randint(1280, 1920)
        height = random.randint(720, 1080)
        
        context = await browser.new_context(
            user_agent=HEADERS["User-Agent"],
            viewport={'width': width, 'height': height}
        )
        
        page = await context.new_page()
        
        # APPLY STEALTH
        await stealth_async(page)
        
        await page.goto(url, wait_until="domcontentloaded", timeout=30000)
        
        # Human-like randomized delay
        await asyncio.sleep(random.uniform(1.0, 2.5))
        
        html_content = await page.content()
        await browser.close()
        return html_content


def _fetch_with_requests(url: str) -> str:
    """Simple synchronous HTTP GET — works for static/server-rendered pages."""
    resp = requests.get(url, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    return resp.text
