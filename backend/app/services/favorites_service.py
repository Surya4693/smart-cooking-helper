from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.database.models import UserFavorite, Recipe
from uuid import uuid4
from datetime import datetime
from typing import List, Dict, Any

class FavoritesService:
    
    def add_favorite(
        self,
        db: Session,
        user_id: str,
        recipe_id: str,
    ) -> Dict[str, Any]:
        """Add a recipe to user's favorites"""
        try:
            # Check if already favorite
            existing = db.query(UserFavorite).filter(
                and_(
                    UserFavorite.user_id == user_id,
                    UserFavorite.recipe_id == recipe_id,
                )
            ).first()

            if existing:
                return {"status": "already_favorited"}

            favorite = UserFavorite(
                id=str(uuid4()),
                user_id=user_id,
                recipe_id=recipe_id,
            )

            db.add(favorite)
            db.commit()
            return {"status": "added", "favorite_id": favorite.id}
        except Exception as e:
            db.rollback()
            raise Exception(f"Add favorite error: {str(e)}")

    def remove_favorite(
        self,
        db: Session,
        user_id: str,
        recipe_id: str,
    ) -> bool:
        """Remove a recipe from user's favorites"""
        try:
            db.query(UserFavorite).filter(
                and_(
                    UserFavorite.user_id == user_id,
                    UserFavorite.recipe_id == recipe_id,
                )
            ).delete()

            db.commit()
            return True
        except Exception as e:
            db.rollback()
            raise Exception(f"Remove favorite error: {str(e)}")

    def get_user_favorites(
        self,
        db: Session,
        user_id: str,
    ) -> List[Dict[str, Any]]:
        """Get user's favorite recipes"""
        try:
            from app.services.recipe_service import RecipeService
            recipe_service = RecipeService()

            favorites = db.query(UserFavorite).filter(
                UserFavorite.user_id == user_id
            ).all()

            recipes = []
            for favorite in favorites:
                recipe = db.query(Recipe).filter(
                    Recipe.id == favorite.recipe_id
                ).first()
                if recipe:
                    recipes.append(recipe_service.format_recipe(recipe))

            return recipes
        except Exception as e:
            raise Exception(f"Get favorites error: {str(e)}")

    def is_favorite(
        self,
        db: Session,
        user_id: str,
        recipe_id: str,
    ) -> bool:
        """Check if recipe is favorited by user"""
        try:
            favorite = db.query(UserFavorite).filter(
                and_(
                    UserFavorite.user_id == user_id,
                    UserFavorite.recipe_id == recipe_id,
                )
            ).first()

            return favorite is not None
        except Exception as e:
            raise Exception(f"Check favorite error: {str(e)}")
