from textblob import TextBlob

def analyze_sentiment(text: str) -> dict:
    """
    Text ka sentiment analyze karo
    Positive / Negative / Neutral return karo
    """
    blob = TextBlob(text)
    score = blob.sentiment.polarity

    # Score -1 to +1 hota hai
    # -1 = very negative
    #  0 = neutral
    # +1 = very positive

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