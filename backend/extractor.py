import logging
from scraper import fetch_html
from html_cleaner import clean_html
from gemini_client import extract_structured_data
from errors import ProcessingError

logger = logging.getLogger(__name__)


async def run_extraction_pipeline(url: str, query: str) -> dict:
    """
    Coordinates the extraction pipeline:
    1. Scrape webpage
    2. Clean HTML to readable text
    3. Send text and query to Gemini for structured extraction
    """
    logger.info(f"Starting extraction pipeline for {url} with query: '{query}'")
    
    try:
        # Step 1: Scrape
        raw_html = await fetch_html(url)
        
        # Step 2: Clean
        cleaned_text = clean_html(raw_html)
        
        if not cleaned_text or len(cleaned_text.strip()) < 10:
             raise ProcessingError(
                 user_message="CONTENT MISSING: The scraped page contains no readable text.",
                 developer_hint="The HTML cleaner stripped all content, or the site is a Single Page App (SPA) that requires more time to render. Check if the site loads data via JavaScript."
             )
        
        # Step 3: Extract with LLM
        structured_data = extract_structured_data(cleaned_text, query)
        
        logger.info(f"Extraction pipeline completed successfully for {url}")
        return structured_data
        
    except Exception as e:
        logger.error(f"Pipeline failed for {url}: {e}")
        raise
