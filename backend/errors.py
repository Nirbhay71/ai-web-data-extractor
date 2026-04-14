import logging

logger = logging.getLogger(__name__)

class ExtractionError(Exception):
    """Base class for all extraction-related errors."""
    def __init__(self, user_message: str, developer_hint: str):
        self.user_message = user_message
        self.developer_hint = developer_hint
        super().__init__(user_message)

class ScraperError(ExtractionError):
    """Errors occurring during the web scraping phase."""
    pass

class GeminiError(ExtractionError):
    """Errors occurring during the AI/LLM processing phase."""
    pass

class ProcessingError(ExtractionError):
    """Errors occurring during data cleaning or JSON parsing."""
    pass

def translate_error(e: Exception) -> dict:
    """
    Translates any technical exception into a human-friendly format
    with both user-facing and developer-facing details.
    """
    # 1. Handle our custom exceptions directly
    if isinstance(e, ExtractionError):
        return {
            "user_message": e.user_message,
            "developer_hint": e.developer_hint
        }

    # 2. Handle known technical exceptions that weren't wrapped
    err_str = str(e).lower()
    
    # Common Network/Scraping errors
    if "403" in err_str or "forbidden" in err_str:
        return {
            "user_message": "ACCESS DENIED: The website is blocking automated access (Bot Detection).",
            "developer_hint": "Status 403. The website's security layer (like Cloudflare) detected our scraper. Consider enabling Stealth mode or using proxies."
        }
    if "timeout" in err_str:
        return {
            "user_message": "CONNECTION TIMEOUT: The website took too long to respond.",
            "developer_hint": f"The target server is either overloaded or intentionally slowing down requests. Original error: {e}"
        }
    if "404" in err_str or "not found" in err_str:
        return {
            "user_message": "PAGE NOT FOUND: The URL provided does not exist.",
            "developer_hint": "Check for typos in the URL or see if the page has been moved or deleted."
        }
    if "quota" in err_str or "exhausted" in err_str or "429" in err_str:
        return {
            "user_message": "USAGE LIMIT REACHED: You have sent too many requests to the Gemini API.",
            "developer_hint": "HTTP 429 Resource Exhausted. Check your Gemini API quota (RPM/TPM) in the Google AI Studio console."
        }
    if "token" in err_str and "limit" in err_str:
        return {
            "user_message": "PAGE TOO LARGE: This webpage contains too much text for the AI to process at once.",
            "developer_hint": "Gemini input token limit exceeded. Try cleaning the HTML more aggressively or truncating the text."
        }

    # 3. Fallback for unknown errors
    return {
        "user_message": "AN UNEXPECTED ERROR OCCURRED: We couldn't finish the extraction.",
        "developer_hint": f"Generic catch-all error. Original exception: {type(e).__name__}: {str(e)}"
    }
