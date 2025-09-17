from fastapi import APIRouter, Depends, HTTPException, status  
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from typing import Optional
from ..models import Config, User
from ..schemas import ConfigResponse, ConfigUpdateRequest
from ..database import get_db
from ..auth import verify_token  

router = APIRouter()
security = HTTPBearer()

def get_current_user_email(token: str = Depends(security)):
    return verify_token(token.credentials)

@router.get("/", response_model=ConfigResponse)
async def get_user_config(
    user_email: str = Depends(get_current_user_email),
    db: Session = Depends(get_db)
):
    # Trouver l'utilisateur
    user = db.query(User).filter(User.email == user_email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,  # Ajoutez status. ici
            detail="Utilisateur non trouvé"
        )
    
    # Get user's config or create default one
    config = db.query(Config).filter(Config.user_id == user.id).first()
    if not config:
        config = Config(user_id=user.id)
        db.add(config)
        db.commit()
        db.refresh(config)
    
    return ConfigResponse(
        x_parameter=config.x_parameter,
        y_parameter=config.y_parameter,
        device_id=config.device_id
    )

@router.put("/", response_model=ConfigResponse)
async def update_user_config(
    config_data: ConfigUpdateRequest,
    user_email: str = Depends(get_current_user_email),
    db: Session = Depends(get_db)
):
    # Trouver l'utilisateur
    user = db.query(User).filter(User.email == user_email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,  # Ajoutez status. ici
            detail="Utilisateur non trouvé"
        )
    
    # Get user's config or create if doesn't exist
    config = db.query(Config).filter(Config.user_id == user.id).first()
    if not config:
        config = Config(user_id=user.id)
        db.add(config)
    
    # Update only the provided fields
    if config_data.x_parameter is not None:
        config.x_parameter = config_data.x_parameter
    
    if config_data.y_parameter is not None:
        config.y_parameter = config_data.y_parameter
    
    if config_data.device_id is not None:
        config.device_id = config_data.device_id
    
    db.commit()
    db.refresh(config)
    
    return ConfigResponse(
        x_parameter=config.x_parameter,
        y_parameter=config.y_parameter,
        device_id=config.device_id
    )

@router.patch("/", response_model=ConfigResponse)
async def partial_update_user_config(
    config_data: ConfigUpdateRequest,
    user_email: str = Depends(get_current_user_email),
    db: Session = Depends(get_db)
):
    # Cette route fonctionne de la même manière que PUT
    return await update_user_config(config_data, user_email, db)