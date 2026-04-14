import os
import json
import logging
from google import genai
from google.genai import types

logger = logging.getLogger(__name__)

from google.genai import errors
from errors import GeminiError

def extract_structured_data(text_content: str, user_query: str) -> list:
    """
    Sends cleaned webpage text and a user query to the Gemini API
    and enforces structured JSON output using the new google-genai SDK.
    """
    logger.info("Sending prompt to Gemini API...")
    
    api_key = os.environ.get("GEMINI_API_KEY", "")
    if not api_key:
        logger.warning("GEMINI_API_KEY is not set in environment. Extraction may fail.")
        
    client = genai.Client(api_key=api_key)
    
    system_prompt = (
        "You are an expert data extractor. Given the following unstructured text extracted "
        "from a webpage and a user query specifying what data to extract, extract the data "
        "strictly as a JSON array of objects. Do not include any explanation or markdown formatting "
        "like ```json. Return ONLY valid JSON."
    )
    
    full_prompt = f"{system_prompt}\n\nUSER QUERY:\n{user_query}\n\nWEBPAGE CONTENT:\n{text_content}"
    
    try:
        response = client.models.generate_content(
            model="gemini-2.0-flash", # Use 2.0 Flash as in your prompt
            contents=full_prompt,
            config=types.GenerateContentConfig(
                response_mime_type="application/json",
            )
        )
        
        # Check for truncated output (Max Tokens)
        # In current SDK, check response.candidates[0].finish_reason
        try:
            finish_reason = response.candidates[0].finish_reason
            if finish_reason == "MAX_TOKENS":
                raise GeminiError(
                    user_message="RESPONSE TRUNCATED: The extraction was too large for the AI's output limit.",
                    developer_hint="The AI stopped mid-sentence because it reached the MAX_TOKENS limit. Ask for a smaller subset of data or check the output token limit."
                )
            elif finish_reason == "SAFETY":
                 raise GeminiError(
                    user_message="CONTENT BLOCKED: The AI refused to process this content for safety reasons.",
                    developer_hint="SafetyFilter triggered in Gemini. The content might have triggered a policy block."
                )
        except (AttributeError, IndexError):
            pass

        try:
            return json.loads(response.text)
        except json.JSONDecodeError as je:
             logger.error(f"Failed to decode Gemini response as JSON: {response.text}")
             raise GeminiError(
                 user_message="PROCESSING ERROR: The AI provided an invalid data format.",
                 developer_hint=f"Gemini output failed JSON decoding. Raw output was likely corrupted. Error: {je}"
             )
             
    except errors.APIError as e:
        status_code = getattr(e, 'code', 500)
        status_text = getattr(e, 'status', 'UNKNOWN')
        
        if status_code == 429:
             raise GeminiError(
                user_message="USAGE LIMIT REACHED: You are sending too many requests to Gemini.",
                developer_hint=f"Resource Exhausted (429 {status_text}). Check your RPM/TPM quota in Google AI Studio."
            )
        elif status_code == 400 and "token" in str(e).lower():
             raise GeminiError(
                user_message="PAGE TOO LARGE: This webpage contains too much text for the AI's memory.",
                developer_hint=f"Input context limit exceeded. Page length: {len(text_content)} chars. Error from API: {e.message}"
            )
        
        raise GeminiError(
            user_message=f"AI SERVICE ERROR: Gemini API returned an error ({status_code}).",
            developer_hint=f"API Failure: {status_text} - {e.message}"
        )
    except Exception as final_err:
        if isinstance(final_err, GeminiError):
            raise
        raise GeminiError(
            user_message="INTERNAL AI ERROR: Something went wrong during the analysis.",
            developer_hint=f"Unexpected failure in gemini_client: {str(final_err)}"
        )
