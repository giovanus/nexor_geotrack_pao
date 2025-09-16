from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class LoginRequest(BaseModel):
    pin: str  

class TokenResponse(BaseModel):
    access_token: str
    token_type: str

class ConfigResponse(BaseModel):
    x_parameter: int  # Intervalle de collecte (minutes)
    y_parameter: int  # Intervalle de synchronisation (minutes)
    device_id: str    # ID de l'appareil

class GPSDataRequest(BaseModel):
    device_id: str
    lat: float
    lon: float
    timestamp: datetime

class GPSDataResponse(BaseModel):
    id: int
    device_id: str
    lat: float
    lon: float
    timestamp: datetime
    synced: bool
    created_at: datetime

    class Config:
        from_attributes = True

class DeviceResponse(BaseModel):
    id: int
    device_id: str
    status: str
    created_at: datetime
    updated_at: Optional[datetime]

    class Config:
        from_attributes = True

class SyncLogResponse(BaseModel):
    id: int
    device_id: str
    timestamp: datetime
    status: str
    error_message: Optional[str]

    class Config:
        from_attributes = True