from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer
from datetime import timedelta
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import random
import os
from sqlalchemy.orm import Session

from ..schemas import LoginRequest, RegisterRequest, TokenResponse, ChangePinRequest, ForgotPinRequest
from ..auth import authenticate_user, create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES, get_pin_hash, verify_token
from ..database import get_db
from ..models import User

router = APIRouter()
security = HTTPBearer()

@router.post("/register")
async def register(
    register_data: RegisterRequest,
    db: Session = Depends(get_db)
):
    # Vérifier si l'email existe déjà
    existing_user = db.query(User).filter(User.email == register_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Un utilisateur avec cet email existe déjà"
        )
    
    # Créer un nouvel utilisateur
    new_user = User(
        email=register_data.email,
        hashed_pin=get_pin_hash(register_data.pin)
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return {"message": "Utilisateur créé avec succès", "email": new_user.email}

@router.post("/login", response_model=TokenResponse)
async def login(
    login_data: LoginRequest,
    db: Session = Depends(get_db)
):
    # Utiliser seulement le PIN pour l'authentification
    user = authenticate_user(db, login_data.pin)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="PIN incorrect",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.post("/change-pin")
async def change_pin(
    change_data: ChangePinRequest,
    token: str = Depends(security),
    db: Session = Depends(get_db)
):
    # Vérifier le token
    email_from_token = verify_token(token.credentials)
    
    # Vérifier que l'email du token correspond à celui de la requête
    if email_from_token != change_data.email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Non autorisé à modifier ce compte"
        )
    
    # Vérifier l'utilisateur
    user = db.query(User).filter(User.email == change_data.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Utilisateur non trouvé"
        )
    
    # Vérifier l'ancien PIN
    from ..auth import verify_pin
    if not verify_pin(change_data.old_pin, user.hashed_pin):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Ancien PIN incorrect"
        )
    
    # Mettre à jour le PIN
    user.hashed_pin = get_pin_hash(change_data.new_pin)
    
    db.commit()
    
    return {"message": "PIN modifié avec succès"}

@router.post("/forgot-pin")
async def forgot_pin(
    forgot_data: ForgotPinRequest,
    db: Session = Depends(get_db)
):
    # Vérifier que l'email existe dans la base de données
    user = db.query(User).filter(User.email == forgot_data.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Aucun utilisateur trouvé avec cet email"
        )
    
    # Générer un nouveau PIN aléatoire
    new_pin = str(random.randint(1000, 9999))  # PIN à 4 chiffres
    
    # Mettre à jour le PIN dans la base de données
    user.hashed_pin = get_pin_hash(new_pin)
    
    db.commit()
    
    # Envoyer le nouveau PIN par email
    try:
        await send_pin_email(forgot_data.email, new_pin)
        return {"message": "Nouveau PIN envoyé par email"}
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Erreur lors de l'envoi de l'email: {str(e)}"
        )

async def send_pin_email(email: str, new_pin: str):
    # Configuration SMTP (à mettre dans les variables d'environnement)
    smtp_host = os.getenv("SMTP_HOST", "smtp.gmail.com")
    smtp_port = int(os.getenv("SMTP_PORT", 587))
    smtp_username = os.getenv("SMTP_USERNAME", "your-email@gmail.com")
    smtp_password = os.getenv("SMTP_PASSWORD", "your-app-password")
    
    # Création du message
    msg = MIMEMultipart()
    msg['From'] = smtp_username
    msg['To'] = email
    msg['Subject'] = "Nexor GeoTrack - Récupération de PIN"
    
    body = f"""
    <html>
    <body>
        <h2>Récupération de PIN Nexor GeoTrack</h2>
        <p>Votre nouveau PIN est : <strong>{new_pin}</strong></p>
        <p>Vous pouvez utiliser ce PIN pour vous connecter à l'application.</p>
        <p>Il est recommandé de changer ce PIN après votre première connexion.</p>
        <br>
        <p><em>Cet email a été généré automatiquement, merci de ne pas y répondre.</em></p>
    </body>
    </html>
    """
    
    msg.attach(MIMEText(body, 'html'))
    
    # Envoi de l'email
    with smtplib.SMTP(smtp_host, smtp_port) as server:
        server.starttls()
        server.login(smtp_username, smtp_password)
        server.send_message(msg)