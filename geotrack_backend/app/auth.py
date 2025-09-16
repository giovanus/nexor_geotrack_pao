from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status, Request
import os
from datetime import datetime

SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-in-production")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Utiliser sha256 pour le PIN
pwd_context = CryptContext(schemes=["sha256_crypt"], deprecated="auto")

# Simple user database avec PIN uniquement
fake_users_db = {
    "admin": {
        "username": "admin",
        # PIN: 1234 haché avec sha256
        "hashed_pin": pwd_context.hash("1234"),
        "failed_attempts": 0,
        "locked_until": None
    }
}

def verify_pin(plain_pin, hashed_pin):
    return pwd_context.verify(plain_pin, hashed_pin)

def get_pin_hash(pin):
    return pwd_context.hash(pin)

def check_user_locked(user):
    if user["locked_until"] and user["locked_until"] > datetime.utcnow():
        remaining_time = user["locked_until"] - datetime.utcnow()
        raise HTTPException(
            status_code=status.HTTP_423_LOCKED,
            detail=f"Compte verrouillé. Réessayez dans {int(remaining_time.total_seconds() // 60)} minutes"
        )
    return False

def authenticate_user(username: str, pin: str):
    user = fake_users_db.get(username)
    if not user:
        return False
    
    # Vérifier si le compte est verrouillé
    check_user_locked(user)
    
    if not verify_pin(pin, user["hashed_pin"]):
        # Incrémenter le compteur de tentatives échouées
        user["failed_attempts"] += 1
        
        # Verrouiller après 3 tentatives échouées pendant 15 minutes
        if user["failed_attempts"] >= 3:
            user["locked_until"] = datetime.utcnow() + timedelta(minutes=15)
            raise HTTPException(
                status_code=status.HTTP_423_LOCKED,
                detail="Compte verrouillé après 3 tentatives échouées. Réessayez dans 15 minutes."
            )
        
        return False
    
    # Réinitialiser le compteur en cas de succès
    user["failed_attempts"] = 0
    user["locked_until"] = None
    return user

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_token(token: str):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )
        return username
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )