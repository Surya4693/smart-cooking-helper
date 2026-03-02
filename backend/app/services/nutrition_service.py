from sqlalchemy.orm import Session
from app.database.models import Recipe, FoodItem
from typing import List, Dict, Any, Optional

class NutritionService:
    DAILY_VALUES: Dict[str, float] = {
        "calories": 2000,
        "protein": 50,
        "carbohydrates": 300,
        "fat": 78,
        "fiber": 25,
        "sodium": 2300,
        "sugar": 50,
        # common micronutrients (values are illustrative %DV bases or recommended amounts)
        "vitamin_a": 900,   # mcg
        "vitamin_c": 90,    # mg
        "calcium": 1300,    # mg
        "iron": 18,         # mg
    }

    GRAM_UNITS = {"g", "gram", "grams"}

    async def get_nutrition_by_food_name(
        self,
        db: Session,
        food_name: str,
    ) -> Optional[Dict[str, Any]]:
        """Get nutrition information for a specific food.

        Returns a structure with `per_serving`, `per_100g` (when convertible),
        and percent daily values for the serving.
        """
        try:
            food = db.query(FoodItem).filter(
                FoodItem.name.ilike(f"%{food_name}%")
            ).first()

            if not food or not food.nutrition_info:
                return None

            ni = food.nutrition_info

            # base per-serving nutrition (use values present on the model)
            per_serving = {
                "calories": round(getattr(ni, "calories", 0) or 0, 2),
                "protein": round(getattr(ni, "protein", 0) or 0, 2),
                "carbohydrates": round(getattr(ni, "carbohydrates", 0) or 0, 2),
                "fat": round(getattr(ni, "fat", 0) or 0, 2),
                "fiber": round(getattr(ni, "fiber", 0) or 0, 2),
                "sodium": round(getattr(ni, "sodium", 0) or 0, 2),
                "sugar": round(getattr(ni, "sugar", 0) or 0, 2),
                # micronutrients (optional)
                "vitamin_a": getattr(ni, "vitamin_a", None),
                "vitamin_c": getattr(ni, "vitamin_c", None),
                "calcium": getattr(ni, "calcium", None),
                "iron": getattr(ni, "iron", None),
            }

            per_100g: Optional[Dict[str, Any]] = None
            serving_size = getattr(food, "serving_size", None) or 0
            serving_unit = (getattr(food, "serving_unit", None) or "").lower()

            if serving_size and serving_unit in self.GRAM_UNITS:
                # compute per-100g values from per-serving numbers
                factor = 100.0 / float(serving_size)
                per_100g = {}
                for k, v in per_serving.items():
                    if v is None:
                        per_100g[k] = None
                        continue
                    # only numeric values are converted
                    try:
                        per_100g[k] = round(float(v) * factor, 2)
                    except Exception:
                        per_100g[k] = None

            # percent daily values for the serving
            percent_dv = self.get_nutrition_recommendations(per_serving)

            return {
                "id": food.id,
                "name": food.name,
                "serving_size": serving_size,
                "serving_unit": serving_unit,
                "per_serving": per_serving,
                "per_100g": per_100g,
                "percent_daily_values": percent_dv,
                "source": getattr(ni, "source", "db"),
                "confidence": getattr(ni, "confidence", None),
            }
        except Exception as e:
            raise Exception(f"Get nutrition error: {str(e)}")

    def calculate_missing_ingredients(
        self,
        db: Session,
        recipe_id: str,
        available_ingredients: List[str],
    ) -> List[str]:
        """Calculate missing ingredients for a recipe"""
        try:
            recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
            
            if not recipe:
                return []

            available_lower = [ing.lower() for ing in available_ingredients]
            missing = []

            for ingredient in recipe.ingredients:
                ingredient_lower = ingredient.lower()
                if not any(avail in ingredient_lower or ingredient_lower in avail 
                          for avail in available_lower):
                    missing.append(ingredient)

            return missing
        except Exception as e:
            raise Exception(f"Calculate missing ingredients error: {str(e)}")

    def calculate_total_nutrition(
        self,
        food_items: List[Dict[str, Any]],
    ) -> Dict[str, float]:
        """Calculate total nutrition from food items"""
        try:
            total = {
                "calories": 0.0,
                "protein": 0.0,
                "carbohydrates": 0.0,
                "fat": 0.0,
                "fiber": 0.0,
                "sodium": 0.0,
                "sugar": 0.0,
            }

            for item in food_items:
                nutrition = item.get("nutrition", {})
                quantity = item.get("quantity", 1)
                
                total["calories"] += nutrition.get("calories", 0) * quantity
                total["protein"] += nutrition.get("protein", 0) * quantity
                total["carbohydrates"] += nutrition.get("carbohydrates", 0) * quantity
                total["fat"] += nutrition.get("fat", 0) * quantity
                total["fiber"] += nutrition.get("fiber", 0) * quantity
                total["sodium"] += nutrition.get("sodium", 0) * quantity
                total["sugar"] += nutrition.get("sugar", 0) * quantity

            return total
        except Exception as e:
            raise Exception(f"Calculate total nutrition error: {str(e)}")

    def get_nutrition_recommendations(
        self,
        daily_intake: Dict[str, float],
    ) -> Dict[str, Any]:
        """Get nutrition recommendations based on daily intake"""
        try:
            # Daily recommended values (for average adult)
            daily_values = {
                "calories": 2000,
                "protein": 50,
                "carbohydrates": 300,
                "fat": 78,
                "fiber": 25,
                "sodium": 2300,
                "sugar": 50,
            }

            recommendations = {}
            for nutrient, intake in daily_intake.items():
                dv = daily_values.get(nutrient, 0)
                percentage = (intake / dv * 100) if dv > 0 else 0

                status = "good"
                if percentage > 120:
                    status = "excess"
                elif percentage < 80:
                    status = "insufficient"

                recommendations[nutrient] = {
                    "intake": round(intake, 2),
                    "daily_value": dv,
                    "percentage": round(percentage, 1),
                    "status": status,
                }

            return recommendations
        except Exception as e:
            raise Exception(f"Get recommendations error: {str(e)}")
