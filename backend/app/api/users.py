from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Optional

from app.database.database import get_db
from app.services.user_service import UserService

router = APIRouter()
user_service = UserService()

@router.post("/profile")
async def create_user_profile(
    request: dict,
    db: Session = Depends(get_db),
):
    """
    Create a new user profile
    """
    try:
        user = user_service.create_user(
            db=db,
            email=request.get("email"),
            display_name=request.get("display_name"),
            dietary_preferences=request.get("dietary_preferences", []),
        )
        return {"user": user}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/profile/{user_id}")
async def get_user_profile(
    user_id: str,
    db: Session = Depends(get_db),
):
    """
    Get user profile information
    """
    try:
        user = user_service.get_user_by_id(db=db, user_id=user_id)
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return {"user": user}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/profile/{user_id}")
async def update_user_profile(
    user_id: str,
    request: dict,
    db: Session = Depends(get_db),
):
    """
    Update user profile information
    """
    try:
        user = user_service.update_user(
            db=db,
            user_id=user_id,
            display_name=request.get("display_name"),
            photo_url=request.get("photo_url"),
            dietary_preferences=request.get("dietary_preferences"),
        )
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return {"user": user}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/dietary-preferences/{user_id}")
async def update_dietary_preferences(
    user_id: str,
    request: dict,
    db: Session = Depends(get_db),
):
    """
    Update user's dietary preferences
    """
    try:
        preferences = request.get("dietary_preferences", [])
        user = user_service.update_dietary_preferences(
            db=db,
            user_id=user_id,
            preferences=preferences,
        )
        if not user:
            raise HTTPException(status_code=404, detail="User not found")
        return {"user": user}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
