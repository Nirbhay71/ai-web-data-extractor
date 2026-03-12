import pandas as pd
import io
import logging

logger = logging.getLogger(__name__)

def export_to_csv(data: list) -> str:
    """
    Converts a list of dicts (JSON array) into a CSV string.
    """
    try:
        if not data:
            return ""
        df = pd.DataFrame(data)
        return df.to_csv(index=False)
    except Exception as e:
        logger.error(f"Error converting data to CSV: {e}")
        raise

def export_to_excel(data: list) -> bytes:
    """
    Converts a list of dicts (JSON array) into an Excel file byte stream.
    """
    try:
        if not data:
            return b""
        df = pd.DataFrame(data)
        excel_buffer = io.BytesIO()
        df.to_excel(excel_buffer, index=False)
        return excel_buffer.getvalue()
    except Exception as e:
        logger.error(f"Error converting data to Excel: {e}")
        raise
