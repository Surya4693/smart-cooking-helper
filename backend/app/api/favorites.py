from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from typing import List, Optional

from app.database.database import get_db
from app.services.favorites_service import FavoritesService

router = APIRouter()
favorites_service = FavoritesService()

@router.post("/add")
async def add_to_favorites(
    request: dict,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Header(None),
):
    """
    Add a recipe to user's favorites
    """
    try:
        if not user_id:
            raise HTTPException(status_code=401, detail="User not authenticated")

        recipe_id = request.get("recipe_id")
        if not recipe_id:
            raise HTTPException(status_code=400, detail="Recipe ID required")

        result = favorites_service.add_favorite(
            db=db,
            user_id=user_id,
            recipe_id=recipe_id,
        )

        return {"status": "success", "favorite": result}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/remove")
async def remove_from_favorites(
    request: dict,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Header(None),
):
    """
    Remove a recipe from user's favorites
    """
    try:
        if not user_id:
            raise HTTPException(status_code=401, detail="User not authenticated")

        recipe_id = request.get("recipe_id")
        if not recipe_id:
            raise HTTPException(status_code=400, detail="Recipe ID required")

        favorites_service.remove_favorite(
            db=db,
            user_id=user_id,
            recipe_id=recipe_id,
        )

        return {"status": "success"}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("")
async def get_favorites(
    db: Session = Depends(get_db),
    user_id: Optional[str] = Header(None),
):
    """
    Get user's favorite recipes
    """
    try:
        if not user_id:
            raise HTTPException(status_code=401, detail="User not authenticated")

        favorites = favorites_service.get_user_favorites(
            db=db,
            user_id=user_id,
        )

        return {"favorites": favorites}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
