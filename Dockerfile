# Étape 1 : installation des dépendances
FROM python:3.11-slim AS builder
WORKDIR /build
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/deps \
    -r requirements.txt

# Étape 2 : image finale minimale
FROM python:3.11-slim
WORKDIR /app

# Copier les dépendances depuis l'étape builder
COPY --from=builder /deps /usr/local

# Copier le code source (immuable en prod)
COPY app/ .

# Utilisateur non-root pour la sécurité
RUN addgroup --system appgroup && \
    adduser --system --ingroup appgroup appuser && \
    chown -R appuser:appgroup /app
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers=2", "app:app"]