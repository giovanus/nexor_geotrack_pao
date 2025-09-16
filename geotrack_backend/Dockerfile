# Utilise une image Python légère
FROM python:3.10-slim

# Définit le répertoire de travail
WORKDIR /app

# Empêche Python de créer des fichiers .pyc et active un buffering utile
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


# Copie requirements (si tu utilises poetry, adapte ici)
COPY requirements.txt .

# Installe les dépendances Python
RUN pip install --no-cache-dir -r requirements.txt

# Copie le code source
COPY . .

# Commande par défaut (elle est override dans docker-compose.yml)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
