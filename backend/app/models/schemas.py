from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime

class NutritionInfoSchema(BaseModel):
    calories: float
    protein: float
    carbohydrates: float
    fat: float
    fiber: float
    sodium: float
    sugar: float

    class Config:
        from_attributes = True

class RecipeStepSchema(BaseModel):
    step_number: int
    instruction: str
    image_url: Optional[str] = None
    video_url: Optional[str] = None
    duration_seconds: Optional[int] = None

    class Config:
        from_attributes = True

class RecipeSchema(BaseModel):
    id: str
    title: str
    description: str
    ingredients: List[str]
    steps: List[RecipeStepSchema]
    image_url: str
    video_url: Optional[str] = None
    preparation_time: int
    cooking_time: int
    servings: int
    rating: float
    nutrition_info: NutritionInfoSchema
    tags: List[str]
    is_favorite: bool = False
    created_at: datetime

    class Config:
        from_attributes = True

class RecipeSearchRequest(BaseModel):
    q: str
    diet_type: Optional[str] = None
    max_prep_time: Optional[int] = None
    max_calories: Optional[float] = None
    ingredients: Optional[List[str]] = None

class RecipeRecommendationRequest(BaseModel):
    available_ingredients: List[str]
    dietary_preferences: Optional[List[str]] = None

class UserSchema(BaseModel):
    id: str
    email: str
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    dietary_preferences: List[str] = []
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
