import logging
from bs4 import BeautifulSoup
import html2text

logger = logging.getLogger(__name__)

def clean_html(raw_html: str) -> str:
    """
    Parses HTML, removes scripts, styles, navigation, etc.,
    and converts the cleaned HTML to readable text.
    """
    logger.info("Cleaning raw HTML...")
    try:
        # Parse HTML
        soup = BeautifulSoup(raw_html, "html.parser")
        
        # Remove unwanted tags
        for element in soup(["script", "style", "nav", "footer", "header", "aside", "noscript"]):
            element.decompose()
            
        cleaned_html = str(soup)
        
        # Convert HTML to Markdown/readable text
        text_maker = html2text.HTML2Text()
        text_maker.ignore_links = True
        text_maker.ignore_images = True
        text_maker.bypass_tables = False
        text_maker.body_width = 0 # don't wrap text automatically
        
        readable_text = text_maker.handle(cleaned_html)
        logger.info("Successfully cleaned HTML and converted to text.")
        
        return readable_text.strip()
    except Exception as e:
        logger.error(f"Error cleaning HTML: {e}")
        raise
