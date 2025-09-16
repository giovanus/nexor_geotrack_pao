# auth.py (routeur)
from fastapi import APIRouter, HTTPException, status
from datetime import timedelta
from ..schemas import LoginRequest, TokenResponse
from ..auth import authenticate_user, create_access_token, ACCESS_TOKEN_EXPIRE_MINUTES

router = APIRouter()

@router.post("/", response_model=TokenResponse)
async def login(login_data: LoginRequest):

    user = authenticate_user("admin", login_data.pin)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="PIN incorrect",
            headers={"WWW-Authenticate": "Bearer"},
        )
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}