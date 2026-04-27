# 🎬 Movie Sentiment API

> Production-ready FastAPI service — real-time NLP sentiment analysis with caching, monitoring, and full CI/CD automation.

![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=flat&logo=docker&logoColor=white)
![Redis](https://img.shields.io/badge/Redis-DC382D?style=flat&logo=redis&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=prometheus&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=flat&logo=github-actions&logoColor=white)

---

## 🚀 Overview

A production-ready REST API that analyzes movie reviews and classifies sentiment as **positive**, **negative**, or **neutral** — built with real-world DevOps practices: containerization, caching, observability, and automated CI/CD.

---

## ⚙️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | FastAPI + Gunicorn + Uvicorn |
| Sentiment Engine | TextBlob (NLP) |
| Caching | Redis |
| Monitoring | Prometheus |
| Containerization | Docker + Docker Swarm |
| CI/CD | GitHub Actions |

---

## 🧠 Features

- **Sentiment analysis** — NLP-powered classification with confidence score
- **Redis caching** — repeated requests served instantly without recomputation
- **Prometheus metrics** — `/metrics` endpoint for real-time observability
- **Health check** — `/health` endpoint for container reliability and orchestration
- **Fully Dockerized** — production-ready with Gunicorn multi-worker setup
- **Automated CI pipeline** — test → build → push on every commit

---

## 📦 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/` | Root info |
| `GET` | `/health` | Health check |
| `GET` | `/metrics` | Prometheus metrics |
| `POST` | `/analyze` | Analyze movie review sentiment |

---

## 🧪 Example

**Request**
```json
POST /analyze
{
  "text": "This movie was amazing!",
  "movie_name": "Avengers"
}
```

**Response**
```json
{
  "movie_name": "Avengers",
  "text": "This movie was amazing!",
  "sentiment": "positive",
  "score": 0.91,
  "confidence": 91.0
}
```

---

## 🐳 Run with Docker

```bash
# Build image
docker build -t movie-api .

# Run container
docker run -p 8000:8000 movie-api
```

API will be available at `http://localhost:8000`

---

## 🔄 CI/CD Pipeline

```
Push → GitHub Actions → Test → Build Docker Image → Push to Docker Hub
```

Every push to `main` triggers:
1. Automated test suite
2. Docker image build
3. Push to Docker Hub registry

---

## 📈 Architecture

```
User → FastAPI → Redis (Cache) → Sentiment Logic → Response
                     ↓
               Prometheus Metrics
```

---

## 📚 API Docs
Live Swagger Docs: https://raj-spy.github.io/Movie-api/

---

## 🏃 Run Locally (without Docker)

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start server
uvicorn app.main:app --reload
```

---

## 👨‍💻 Author

**Raj Tayde**
- GitHub: [@Raj-spy](https://github.com/Raj-spy)
- Live Project: [LLM Drift Monitor](https://llm-drift-monitor-pi.vercel.app/)