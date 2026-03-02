from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List

from app.database.database import get_db
from app.models.schemas import NutritionInfoSchema
from app.services.nutrition_service import NutritionService
from app.services.barcode_service import BarcodeService

router = APIRouter()
nutrition_service = NutritionService()
barcode_service = BarcodeService()

@router.get("/scan-barcode", response_model=dict)
async def scan_barcode(
    barcode: str = Query(..., min_length=1),
    db: Session = Depends(get_db),
):
    """
    Scan a barcode and get nutrition information
    """
    try:
        food_item = await barcode_service.scan_and_fetch_nutrition(
            db=db,
            barcode=barcode,
        )
        if not food_item:
            raise HTTPException(status_code=404, detail="Food item not found")
        return {"food_item": food_item}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/info", response_model=dict)
async def get_nutrition_info(
    food_name: str = Query(..., min_length=1),
    db: Session = Depends(get_db),
):
    """
    Get nutrition information for a specific food
    """
    try:
        nutrition_info = await nutrition_service.get_nutrition_by_food_name(
            db=db,
            food_name=food_name,
        )
        if not nutrition_info:
            raise HTTPException(status_code=404, detail="Nutrition info not found")
        return {"nutrition_info": nutrition_info}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/shopping-list", response_model=dict)
async def get_shopping_list(
    request: dict,
    db: Session = Depends(get_db),
):
    """
    Get missing ingredients for a recipe (shopping list)
    """
    try:
        recipe_id = request.get("recipe_id")
        available_ingredients = request.get("available_ingredients", [])

        missing_ingredients = nutrition_service.calculate_missing_ingredients(
            db=db,
            recipe_id=recipe_id,
            available_ingredients=available_ingredients,
        )

        return {"missing_ingredients": missing_ingredients}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/daily-intake-track", response_model=dict)
async def track_daily_intake(
    request: dict,
    db: Session = Depends(get_db),
):
    """
    Track daily nutrition intake
    """
    try:
        user_id = request.get("user_id")
        food_items = request.get("food_items", [])

        total_nutrition = nutrition_service.calculate_total_nutrition(
            food_items=food_items,
        )

        return {
            "daily_intake": total_nutrition,
            "recommendations": nutrition_service.get_nutrition_recommendations(total_nutrition),
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
