# Nexor GeoTrack

Système de suivi GPS avec capacités hors ligne, développé avec React (frontend) et FastAPI (backend).

## 🚀 Fonctionnalités

- Authentification sécurisée avec PIN et JWT
- Collecte GPS en temps réel avec géolocalisation HTML5
- Mode hors ligne avec stockage local et synchronisation automatique
- Dashboard en temps réel avec statut de connexion et GPS
- Configuration flexible des paramètres de collecte
- API REST complète avec documentation Swagger
- Base de données PostgreSQL pour le stockage persistant
- Déploiement Docker pour un setup facile

## 🏗️ Architecture
nexor-geotrack/
├── backend/ # API FastAPI
├── frontend/ # Application React
└── docker-compose.yml


## 🛠️ Installation et Démarrage

### Prérequis

- Docker et Docker Compose
- Git

### Démarrage avec Docker (Recommandé)

1. Cloner le projet
   ```bash
   git clone <repository-url>
   cd nexor-geotrack