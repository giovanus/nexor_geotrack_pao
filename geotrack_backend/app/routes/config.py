# config.py
from fastapi import APIRouter, Depends, HTTPException
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from ..models import Config
from ..schemas import ConfigResponse
from ..database import get_db
from ..auth import verify_token

router = APIRouter()
security = HTTPBearer()

@router.get("/", response_model=ConfigResponse)
async def get_config(
    token: str = Depends(security),
    db: Session = Depends(get_db)
):
    verify_token(token.credentials)
    
    # Get the first config or create a default one
    config = db.query(Config).first()
    if not config:
        config = Config()
        db.add(config)
        db.commit()
        db.refresh(config)
    
    return ConfigResponse(
        x_parameter=config.x_parameter,
        y_parameter=config.y_parameter,
        device_id=config.device_id
    )