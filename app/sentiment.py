from textblob import TextBlob


def analyze_sentiment(text: str) -> dict:

    blob = TextBlob(text)
    score = blob.sentiment.polarity

    if score > 0.1:
        sentiment = "positive"
    elif score < -0.1:
        sentiment = "negative"
    else:
        sentiment = "neutral"

    return {
        "sentiment": sentiment,
        "score": round(score, 2),
        "confidence": round(abs(score) * 100, 1)
    }