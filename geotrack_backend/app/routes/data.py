from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from typing import List
from ..database import get_db
from ..models import GPSData, Device, SyncLog
from ..schemas import GPSDataRequest, GPSDataResponse
from ..auth import verify_token

router = APIRouter()
security = HTTPBearer()

@router.post("/", response_model=GPSDataResponse)
async def create_gps_data(
    gps_data: GPSDataRequest,
    token: str = Depends(security),
    db: Session = Depends(get_db)
):
    verify_token(token.credentials)
    
    # Create or get device
    device = db.query(Device).filter(Device.device_id == gps_data.device_id).first()
    if not device:
        device = Device(device_id=gps_data.device_id)
        db.add(device)
        db.commit()
    
    # Create GPS data entry
    db_gps_data = GPSData(
        device_id=gps_data.device_id,
        lat=gps_data.lat,
        lon=gps_data.lon,
        timestamp=gps_data.timestamp
    )
    db.add(db_gps_data)
    
    # Log sync
    sync_log = SyncLog(
        device_id=gps_data.device_id,
        status="success"
    )
    db.add(sync_log)
    
    db.commit()
    db.refresh(db_gps_data)
    
    return db_gps_data

@router.get("/", response_model=List[GPSDataResponse])
async def get_gps_data(
    device_id: str = None,
    token: str = Depends(security),
    db: Session = Depends(get_db)
):
    verify_token(token.credentials)
    
    query = db.query(GPSData)
    if device_id:
        query = query.filter(GPSData.device_id == device_id)
    
    return query.order_by(GPSData.timestamp.desc()).limit(100).all()