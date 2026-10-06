import os

from dotenv import load_dotenv
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from google import genai

from config.database import db
from utils.security import get_current_user


# ============================================================
# LOAD ENVIRONMENT VARIABLES
# ============================================================

load_dotenv()


# ============================================================
# ROUTER
# ============================================================

router = APIRouter(
    prefix="/api/ai",
    tags=["AI Assistant"],
)


# ============================================================
# DATABASE COLLECTIONS
# ============================================================

attendance_collection = db["attendance"]
employee_collection = db["employees"]


# ============================================================
# REQUEST MODEL
# ============================================================

class ChatRequest(BaseModel):
    message: str


# ============================================================
# RESPONSE MODEL
# ============================================================

class ChatResponse(BaseModel):
    success: bool
    reply: str


# ============================================================
# GEMINI CLIENT
# ============================================================

def get_gemini_client() -> genai.Client:
    api_key = os.getenv("GEMINI_API_KEY")

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="Gemini API key is not configured.",
        )

    return genai.Client(
        api_key=api_key,
    )


# ============================================================
# AI CHAT ENDPOINT
# ============================================================

@router.post(
    "/chat",
    response_model=ChatResponse,
)
async def chat(
    request: ChatRequest,
    current_user: dict = Depends(get_current_user),
):

    message = request.message.strip()

    if not message:
        raise HTTPException(
            status_code=400,
            detail="Message cannot be empty.",
        )

    try:

        client = get_gemini_client()

        response = client.interactions.create(
            model="gemini-3.6-flash",
            input=message,
        )

        reply = response.output_text

        if not reply:
            reply = (
                "I couldn't generate a response right now."
            )

        return ChatResponse(
            success=True,
            reply=reply,
        )

    except HTTPException:
        raise

    except Exception as exc:

        print(f"Gemini error: {exc}")

        error_text = str(exc)

        if (
            "429" in error_text
            or "Rate limit exceeded" in error_text
            or "too_many_requests" in error_text
        ):
            raise HTTPException(
                status_code=429,
                detail=(
                    "AI service rate limit reached. "
                    "Please try again later."
                ),
            )

        if (
            "API_KEY_INVALID" in error_text
            or "API key not valid" in error_text
        ):
            raise HTTPException(
                status_code=500,
                detail=(
                    "Gemini API key is invalid. "
                    "Check GEMINI_API_KEY in backend/.env."
                ),
            )

        raise HTTPException(
            status_code=500,
            detail="Unable to generate AI response.",
        )
