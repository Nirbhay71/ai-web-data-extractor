import logging
import asyncio
import sys
import requests
from bs4 import BeautifulSoup

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
    try:
        html = await _fetch_with_playwright(url)
        logger.info(f"Successfully fetched HTML via Playwright from {url}.")
        return html
    except Exception as pw_err:
        logger.warning(f"Playwright failed ({pw_err}). Falling back to requests...")

    # Fallback: plain HTTP request
    try:
        html = _fetch_with_requests(url)
        logger.info(f"Successfully fetched HTML via requests from {url}.")
        return html
    except Exception as req_err:
        logger.error(f"requests also failed for {url}: {req_err}")
        raise RuntimeError(
            f"Could not fetch '{url}'. Playwright: {pw_err}. Requests: {req_err}"
        )


async def _fetch_with_playwright(url: str) -> str:
    """Use Playwright (headless Chromium) — best for JS-rendered pages."""
    from playwright.async_api import async_playwright

    async with async_playwright() as p:
        browser = await p.chromium.launch(headless=True)
        page = await browser.new_page(extra_http_headers=HEADERS)
        await page.goto(url, wait_until="domcontentloaded", timeout=30000)
        # Small wait to let any quick JS render
        await asyncio.sleep(1)
        html_content = await page.content()
        await browser.close()
        return html_content


def _fetch_with_requests(url: str) -> str:
    """Simple synchronous HTTP GET — works for static/server-rendered pages."""
    resp = requests.get(url, headers=HEADERS, timeout=20)
    resp.raise_for_status()
    return resp.text
