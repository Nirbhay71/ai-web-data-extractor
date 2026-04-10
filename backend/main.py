import sys
import asyncio

from dotenv import load_dotenv
load_dotenv()

# ---- Windows asyncio fix (must be before any async imports) ----
# Playwright requires ProactorEventLoop on Windows; set it early.
if sys.platform == "win32":
    asyncio.set_event_loop_policy(asyncio.WindowsProactorEventLoopPolicy())
# ----------------------------------------------------------------

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import logging

from extractor import run_extraction_pipeline

# Initialize logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

app = FastAPI(
    title="AI Powered Web Scraper API",
    description="Extracts structured data from websites using a specified natural language query and LLMs.",
    version="1.0.0"
)

# Enable CORS for the Flutter Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ExtractRequest(BaseModel):
    url: str
    query: str

class ExtractResponse(BaseModel):
    data: list

@app.get("/")
def read_root():
    return {"message": "AI Web Scraper API is running."}

@app.post("/extract", response_model=ExtractResponse)
async def extract_data(request: ExtractRequest):
    """
    Endpoint to trigger the scraping, HTML cleaning, and Gemini extraction
    based on the provided URL and user query.
    """
    logger.info(f"Received extraction request for {request.url}")
    try:
        extracted_data = await run_extraction_pipeline(request.url, request.query)
        logger.info(f"Successfully processed extraction request for {request.url}")
        return ExtractResponse(data=extracted_data)
    except ValueError as ve:
        logger.error(f"Validation error during extraction: {ve}")
        raise HTTPException(status_code=400, detail=str(ve))
    except Exception as e:
        logger.error(f"Internal server error during extraction: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to extract data: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
