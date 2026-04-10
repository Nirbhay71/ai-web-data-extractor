import os
import json
import logging
import google.generativeai as genai

logger = logging.getLogger(__name__)

# Try to load API key from environment, else it must be passed
API_KEY = os.environ.get("GEMINI_API_KEY", "")
if API_KEY:
    genai.configure(api_key=API_KEY)

def extract_structured_data(text_content: str, user_query: str) -> dict:
    """
    Sends cleaned webpage text and a user query to the Gemini API
    and enforces structured JSON output based on the user's extraction query.
    """
    logger.info("Sending prompt to Gemini API...")
    try:
        if not os.environ.get("GEMINI_API_KEY"):
            logger.warning("GEMINI_API_KEY is not set in environment. Extraction may fail.")
            
        model = genai.GenerativeModel("gemini-3-flash-preview")
        
        system_prompt = (
            "You are an expert data extractor. Given the following unstructured text extracted "
            "from a webpage and a user query specifying what data to extract, extract the data "
            "strictly as a JSON array of objects. Do not include any explanation or markdown formatting "
            "like ```json. Return ONLY valid JSON."
        )
        
        full_prompt = f"{system_prompt}\n\nUSER QUERY:\n{user_query}\n\nWEBPAGE CONTENT:\n{text_content}"
        
        response = model.generate_content(
            full_prompt,
            generation_config=genai.GenerationConfig(
                response_mime_type="application/json",
            )
        )
        
        # Parse the JSON response
        try:
            return json.loads(response.text)
        except json.JSONDecodeError as je:
             logger.error(f"Failed to decode Gemini response as JSON: {response.text}")
             raise ValueError(f"Gemini output is not valid JSON: {je}")
             
    except Exception as e:
        logger.error(f"Error accessing Gemini API: {e}")
        raise
