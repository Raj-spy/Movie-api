from fastapi import FastAPI, HTTPException, Response
from pydantic import BaseModel
from app.sentiment import analyze_sentiment
from dotenv import load_dotenv
from prometheus_client import generate_latest, CONTENT_TYPE_LATEST, Counter
import os
import redis
import json


ANALYZE_COUNTER = Counter(
    "analyze_requests_total",
    "Total analyze API calls"
)

load_dotenv()

redis_client = redis.Redis(
    host=os.getenv("REDIS_HOST", "redis"),
    port=6379,
    decode_responses=True
)

app = FastAPI(
    title="Movie Sentiment API",
    description="Movie reviews ka sentiment analyze karo",
    version="1.0.2"
)


class ReviewRequest(BaseModel):
    text: str
    movie_name: str = "Unknown"


class ReviewResponse(BaseModel):
    movie_name: str
    text: str
    sentiment: str
    score: float
    confidence: float


@app.get("/metrics")
def metrics():
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)


import os

@app.get("/")
def root():
    return {
        "message": "Movie Sentiment API 🚀",
        "version": os.getenv("APP_VERSION", "1.0.2"),
        "docs": "/docs"
    }


@app.get("/health")
def health():
    return {"status": "healthy v2"}


@app.post("/analyze", response_model=ReviewResponse)
def analyze_review(review: ReviewRequest):
    ANALYZE_COUNTER.inc()

    if not review.text.strip():
        raise HTTPException(
            status_code=400,
            detail="Text empty nahi hona chahiye!"
        )

    cache_key = f"sentiment:{review.text}"

    cached = redis_client.get(cache_key)
    if cached:
        result = json.loads(cached)
    else:
        result = analyze_sentiment(review.text)
        redis_client.set(cache_key, json.dumps(result))

    return ReviewResponse(
        movie_name=review.movie_name,
        text=review.text,
        sentiment=result["sentiment"],
        score=result["score"],
        confidence=result["confidence"]
    )
