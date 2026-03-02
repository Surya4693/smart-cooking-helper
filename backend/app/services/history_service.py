from sqlalchemy.orm import Session
from app.database.models import UserHistory, Recipe
from uuid import uuid4
from datetime import datetime
from typing import List, Dict, Any

class HistoryService:
    
    def add_to_history(
        self,
        db: Session,
        user_id: str,
        recipe_id: str,
    ) -> Dict[str, Any]:
        """Add a recipe to user's cooking history"""
        try:
            history_item = UserHistory(
                id=str(uuid4()),
                user_id=user_id,
                recipe_id=recipe_id,
                cooked_at=datetime.utcnow(),
            )

            db.add(history_item)
            db.commit()
            return {"status": "added", "history_id": history_item.id}
        except Exception as e:
            db.rollback()
            raise Exception(f"Add to history error: {str(e)}")

    def get_recent_history(
        self,
        db: Session,
        user_id: str,
        limit: int = 10,
    ) -> List[Dict[str, Any]]:
        """Get user's recent cooking history"""
        try:
            from app.services.recipe_service import RecipeService
            recipe_service = RecipeService()

            history = db.query(UserHistory).filter(
                UserHistory.user_id == user_id
            ).order_by(UserHistory.cooked_at.desc()).limit(limit).all()

            recipes = []
            for item in history:
                recipe = db.query(Recipe).filter(
                    Recipe.id == item.recipe_id
                ).first()
                if recipe:
                    recipe_data = recipe_service.format_recipe(recipe)
                    recipe_data["cooked_at"] = item.cooked_at.isoformat()
                    recipes.append(recipe_data)

            return recipes
        except Exception as e:
            raise Exception(f"Get history error: {str(e)}")

    def get_statistics(
        self,
        db: Session,
        user_id: str,
    ) -> Dict[str, Any]:
        """Get cooking history statistics"""
        try:
            from sqlalchemy import func

            history = db.query(UserHistory).filter(
                UserHistory.user_id == user_id
            ).all()

            total_cooked = len(history)
            
            # Get most cooked recipe
            most_cooked = db.query(
                UserHistory.recipe_id,
                func.count(UserHistory.recipe_id).label('count')
            ).filter(
                UserHistory.user_id == user_id
            ).group_by(UserHistory.recipe_id).order_by(
                func.count(UserHistory.recipe_id).desc()
            ).first()

            most_cooked_recipe = None
            if most_cooked:
                recipe = db.query(Recipe).filter(
                    Recipe.id == most_cooked[0]
                ).first()
                if recipe:
                    most_cooked_recipe = {
                        "recipe_id": recipe.id,
                        "title": recipe.title,
                        "count": most_cooked[1],
                    }

            return {
                "total_recipes_cooked": total_cooked,
                "most_cooked_recipe": most_cooked_recipe,
                "unique_recipes": len(set(h.recipe_id for h in history)),
            }
        except Exception as e:
            raise Exception(f"Get statistics error: {str(e)}")
