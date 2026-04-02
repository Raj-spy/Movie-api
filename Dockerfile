# Stage 1 — Builder
FROM python:3.11-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --upgrade pip wheel starlette
RUN apk update && apk upgrade

# Stage 2 — Tester
FROM python:3.11-alpine AS tester
WORKDIR /app
COPY --from=builder /usr/local /usr/local
COPY tests/ ./tests/
ENV PATH=/usr/local/bin:$PATH
RUN python3 -m textblob.download_corpora
RUN pytest tests/ -v

# Stage 3 — Runner (Final image)
FROM python:3.11-alpine

RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

COPY --from=builder /usr/local /usr/local
COPY app/ ./app/

RUN mkdir -p /home/appuser/.local
RUN chown -R appuser:appuser /app /home/appuser/.local

ENV PATH=/usr/local/bin:$PATH

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

USER appuser

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]