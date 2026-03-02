from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from typing import Optional

from app.database.database import get_db
from app.services.history_service import HistoryService

router = APIRouter()
history_service = HistoryService()

@router.post("/add")
async def add_to_history(
    request: dict,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Header(None),
):
    """
    Add a recipe to user's cooking history
    """
    try:
        if not user_id:
            raise HTTPException(status_code=401, detail="User not authenticated")

        recipe_id = request.get("recipe_id")
        if not recipe_id:
            raise HTTPException(status_code=400, detail="Recipe ID required")

        history_item = history_service.add_to_history(
            db=db,
            user_id=user_id,
            recipe_id=recipe_id,
        )

        return {"status": "success", "history_item": history_item}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/recent")
async def get_recent_history(
    limit: int = 10,
    db: Session = Depends(get_db),
    user_id: Optional[str] = Header(None),
):
    """
    Get user's recent cooking history
    """
    try:
        if not user_id:
            raise HTTPException(status_code=401, detail="User not authenticated")

        history = history_service.get_recent_history(
            db=db,
            user_id=user_id,
            limit=limit,
        )

        return {"history": history}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/statistics")
async def get_history_statistics(
    db: Session = Depends(get_db),
    user_id: Optional[str] = Header(None),
):
    """
    Get cooking history statistics
    """
    try:
        if not user_id:
            raise HTTPException(status_code=401, detail="User not authenticated")

        stats = history_service.get_statistics(
            db=db,
            user_id=user_id,
        )

        return {"statistics": stats}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
