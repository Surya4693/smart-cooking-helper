from sqlalchemy.orm import Session
from app.database.models import FoodItem, FoodNutritionInfo
from uuid import uuid4
from datetime import datetime
from typing import Optional, Dict, Any

class BarcodeService:
    
    async def scan_and_fetch_nutrition(
        self,
        db: Session,
        barcode: str,
    ) -> Optional[Dict[str, Any]]:
        """Scan barcode and fetch nutrition information"""
        try:
            # First check local database
            food = db.query(FoodItem).filter(
                FoodItem.barcode == barcode
            ).first()

            if food and food.nutrition_info:
                return self._format_food_item(food)

            # If not found locally, you would call external API (e.g., Open Food Facts)
            # For demo purposes, returning None
            # In production, implement actual barcode scanning API integration
            
            return None
        except Exception as e:
            raise Exception(f"Barcode scan error: {str(e)}")

    def _format_food_item(self, food: FoodItem) -> Dict[str, Any]:
        """Format food item to dictionary"""
        nutrition_data = {}
        if food.nutrition_info:
            nutrition_data = {
                "calories": food.nutrition_info.calories,
                "protein": food.nutrition_info.protein,
                "carbohydrates": food.nutrition_info.carbohydrates,
                "fat": food.nutrition_info.fat,
                "fiber": food.nutrition_info.fiber,
                "sodium": food.nutrition_info.sodium,
                "sugar": food.nutrition_info.sugar,
            }

        return {
            "id": food.id,
            "name": food.name,
            "barcode": food.barcode,
            "image_url": food.image_url,
            "nutrition_info": nutrition_data,
            "serving_size": food.serving_size,
            "serving_unit": food.serving_unit,
            "ingredients": food.ingredients,
            "expiry_date": food.expiry_date.isoformat(),
            "scanned_at": datetime.utcnow().isoformat(),
        }
