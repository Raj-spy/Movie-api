from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_root():
    response = client.get("/")
    data = response.json()
    assert data["version"] in ["1.0.2", "canary"]


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy v2"


def test_analyze_positive():
    response = client.post("/analyze", json={
        "text": "Avengers was absolutely amazing!",
        "movie_name": "Avengers"
    })
    assert response.status_code == 200
    assert response.json()["sentiment"] == "positive"


def test_analyze_negative():
    response = client.post("/analyze", json={
        "text": "This movie was terrible and boring",
        "movie_name": "Bad Movie"
    })
    assert response.status_code == 200
    assert response.json()["sentiment"] == "negative"


def test_empty_text():
    response = client.post("/analyze", json={
        "text": "",
        "movie_name": "Test"
    })
    assert response.status_code == 400
