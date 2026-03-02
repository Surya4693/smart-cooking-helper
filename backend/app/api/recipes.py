from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from uuid import uuid4
from datetime import datetime

from app.database.database import get_db
from app.database.models import Recipe, RecipeStep, NutritionInfo
from app.models.schemas import RecipeSchema, RecipeRecommendationRequest
from app.services.recipe_service import RecipeService

router = APIRouter()
recipe_service = RecipeService()

@router.get("/search", response_model=dict)
async def search_recipes(
    q: str = Query(..., min_length=1),
    diet_type: str = Query(None),
    max_prep_time: int = Query(None),
    max_calories: float = Query(None),
    db: Session = Depends(get_db),
):
    """
    Search recipes by query and optional filters
    """
    try:
        recipes = recipe_service.search_recipes(
            db=db,
            query=q,
            diet_type=diet_type,
            max_prep_time=max_prep_time,
            max_calories=max_calories,
        )
        return {"recipes": recipes}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/recommendations", response_model=dict)
async def get_recommendations(
    request: RecipeRecommendationRequest,
    db: Session = Depends(get_db),
):
    """
    Get AI-powered recipe recommendations based on available ingredients
    """
    try:
        recipes = recipe_service.get_recommendations(
            db=db,
            available_ingredients=request.available_ingredients,
            dietary_preferences=request.dietary_preferences,
        )
        return {"recipes": recipes}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/today-recommendation", response_model=dict)
async def get_today_recommendation(
    request: dict,
    db: Session = Depends(get_db),
):
    """
    Get today's special recipe recommendation
    """
    try:
        recipe = recipe_service.get_today_recommendation(
            db=db,
            dietary_preferences=request.get("dietary_preferences", []),
        )
        if not recipe:
            raise HTTPException(status_code=404, detail="No recipe available")
        return {"recipe": recipe}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{recipe_id}", response_model=dict)
async def get_recipe_details(
    recipe_id: str,
    db: Session = Depends(get_db),
):
    """
    Get detailed information about a specific recipe
    """
    try:
        recipe = recipe_service.get_recipe_details(db=db, recipe_id=recipe_id)
        if not recipe:
            raise HTTPException(status_code=404, detail="Recipe not found")
        return {"recipe": recipe}
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/create", response_model=dict)
async def create_recipe(
    recipe_data: dict,
    db: Session = Depends(get_db),
):
    """
    Create a new recipe (Admin only)
    """
    try:
        recipe_id = str(uuid4())
        recipe = Recipe(
            id=recipe_id,
            title=recipe_data.get("title"),
            description=recipe_data.get("description"),
            ingredients=recipe_data.get("ingredients", []),
            image_url=recipe_data.get("image_url"),
            video_url=recipe_data.get("video_url"),
            preparation_time=recipe_data.get("preparation_time", 0),
            cooking_time=recipe_data.get("cooking_time", 0),
            servings=recipe_data.get("servings", 1),
            rating=recipe_data.get("rating", 0.0),
            tags=recipe_data.get("tags", []),
        )

        # Add nutrition info
        nutrition_data = recipe_data.get("nutrition_info", {})
        nutrition_info = NutritionInfo(
            id=str(uuid4()),
            recipe_id=recipe_id,
            calories=nutrition_data.get("calories", 0),
            protein=nutrition_data.get("protein", 0),
            carbohydrates=nutrition_data.get("carbohydrates", 0),
            fat=nutrition_data.get("fat", 0),
            fiber=nutrition_data.get("fiber", 0),
            sodium=nutrition_data.get("sodium", 0),
            sugar=nutrition_data.get("sugar", 0),
        )

        # Add recipe steps
        for step_data in recipe_data.get("steps", []):
            step = RecipeStep(
                id=str(uuid4()),
                recipe_id=recipe_id,
                step_number=step_data.get("step_number"),
                instruction=step_data.get("instruction"),
                image_url=step_data.get("image_url"),
                video_url=step_data.get("video_url"),
                duration_seconds=step_data.get("duration_seconds"),
            )
            recipe.recipe_steps.append(step)

        recipe.nutrition_info = nutrition_info

        db.add(recipe)
        db.commit()
        db.refresh(recipe)

        return {"recipe": recipe_service.format_recipe(recipe)}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
