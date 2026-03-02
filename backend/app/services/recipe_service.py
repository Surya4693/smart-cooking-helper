from sqlalchemy.orm import Session
from sqlalchemy import func, and_, or_
from typing import List, Optional, Dict, Any
from app.database.models import Recipe, NutritionInfo, RecipeStep
import random

class RecipeService:
    
    def search_recipes(
        self,
        db: Session,
        query: str,
        diet_type: Optional[str] = None,
        max_prep_time: Optional[int] = None,
        max_calories: Optional[float] = None,
    ) -> List[Dict[str, Any]]:
        """Search recipes by title or tags"""
        try:
            recipes_query = db.query(Recipe).filter(
                or_(
                    Recipe.title.ilike(f"%{query}%"),
                    Recipe.description.ilike(f"%{query}%"),
                )
            )

            if max_prep_time:
                recipes_query = recipes_query.filter(Recipe.preparation_time <= max_prep_time)

            if max_calories:
                recipes_query = recipes_query.join(NutritionInfo).filter(
                    NutritionInfo.calories <= max_calories
                )

            recipes = recipes_query.limit(20).all()
            return [self.format_recipe(r) for r in recipes]
        except Exception as e:
            raise Exception(f"Search error: {str(e)}")

    def get_recommendations(
        self,
        db: Session,
        available_ingredients: List[str],
        dietary_preferences: Optional[List[str]] = None,
    ) -> List[Dict[str, Any]]:
        """Get AI-powered recipe recommendations based on available ingredients"""
        try:
            # Convert ingredients to lowercase for comparison
            available = [ing.lower() for ing in available_ingredients]

            recipes = db.query(Recipe).limit(100).all()

            # Score recipes based on ingredient match
            scored_recipes = []
            for recipe in recipes:
                recipe_ingredients_lower = [ing.lower() for ing in recipe.ingredients]
                matches = sum(1 for ing in recipe_ingredients_lower if any(
                    avail in ing or ing in avail for avail in available
                ))
                score = matches / len(recipe_ingredients_lower) if recipe_ingredients_lower else 0

                if score > 0.3:  # At least 30% match
                    scored_recipes.append((score, recipe))

            # Sort by score and return top 10
            scored_recipes.sort(key=lambda x: x[0], reverse=True)
            return [self.format_recipe(r[1]) for r in scored_recipes[:10]]
        except Exception as e:
            raise Exception(f"Recommendation error: {str(e)}")

    def get_today_recommendation(
        self,
        db: Session,
        dietary_preferences: Optional[List[str]] = None,
    ) -> Optional[Dict[str, Any]]:
        """Get today's special recipe recommendation"""
        try:
            recipes = db.query(Recipe).all()
            
            if not recipes:
                return None

            # Simple recommendation logic - can be enhanced with ML
            filtered_recipes = recipes
            
            if dietary_preferences:
                filtered_recipes = [
                    r for r in recipes 
                    if any(pref.lower() in ' '.join(r.tags).lower() for pref in dietary_preferences)
                ]
            
            if not filtered_recipes:
                filtered_recipes = recipes

            # Select random recipe from filtered list
            recipe = random.choice(filtered_recipes)
            return self.format_recipe(recipe)
        except Exception as e:
            raise Exception(f"Today recommendation error: {str(e)}")

    def get_recipe_details(
        self,
        db: Session,
        recipe_id: str,
    ) -> Optional[Dict[str, Any]]:
        """Get detailed information about a specific recipe"""
        try:
            recipe = db.query(Recipe).filter(Recipe.id == recipe_id).first()
            if not recipe:
                return None
            return self.format_recipe(recipe)
        except Exception as e:
            raise Exception(f"Get recipe details error: {str(e)}")

    def format_recipe(self, recipe: Recipe) -> Dict[str, Any]:
        """Format recipe object to dictionary"""
        nutrition_data = {
            "calories": 0,
            "protein": 0,
            "carbohydrates": 0,
            "fat": 0,
            "fiber": 0,
            "sodium": 0,
            "sugar": 0,
        }

        if recipe.nutrition_info:
            nutrition_data = {
                "calories": recipe.nutrition_info.calories,
                "protein": recipe.nutrition_info.protein,
                "carbohydrates": recipe.nutrition_info.carbohydrates,
                "fat": recipe.nutrition_info.fat,
                "fiber": recipe.nutrition_info.fiber,
                "sodium": recipe.nutrition_info.sodium,
                "sugar": recipe.nutrition_info.sugar,
            }

        steps = [
            {
                "step_number": step.step_number,
                "instruction": step.instruction,
                "image_url": step.image_url,
                "video_url": step.video_url,
                "duration_seconds": step.duration_seconds,
            }
            for step in sorted(recipe.recipe_steps, key=lambda x: x.step_number)
        ]

        return {
            "id": recipe.id,
            "title": recipe.title,
            "description": recipe.description,
            "ingredients": recipe.ingredients,
            "steps": steps,
            "image_url": recipe.image_url,
            "video_url": recipe.video_url,
            "preparation_time": recipe.preparation_time,
            "cooking_time": recipe.cooking_time,
            "servings": recipe.servings,
            "rating": recipe.rating,
            "nutrition_info": nutrition_data,
            "tags": recipe.tags,
            "created_at": recipe.created_at.isoformat(),
        }
