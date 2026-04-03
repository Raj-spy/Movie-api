# Stage 1 — Builder
FROM python:3.11-alpine AS builder
WORKDIR /app

COPY requirements.txt .

# Only install deps (no OS upgrade)
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2 — Tester
FROM python:3.11-alpine AS tester
WORKDIR /app

COPY --from=builder /install /usr/local
COPY tests/ ./tests/

ENV PATH=/usr/local/bin:$PATH

RUN python3 -m textblob.download_corpora && \
    pytest tests/ -v

# Stage 3 — Runner (Final)
FROM python:3.11-alpine

RUN addgroup -S appuser && adduser -S appuser -G appuser

WORKDIR /app

# Copy only installed dependencies (clean)
COPY --from=builder /install /usr/local
COPY app/ ./app/

RUN chown -R appuser:appuser /app

ENV PATH=/usr/local/bin:$PATH

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost:8000/health || exit 1

USER appuser

EXPOSE 8000

CMD ["gunicorn", "app.main:app", "-k", "uvicorn.workers.UvicornWorker", "-w", "4", "-b", "0.0.0.0:8000"]