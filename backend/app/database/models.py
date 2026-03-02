from sqlalchemy import Column, String, Float, Integer, DateTime, Boolean, ARRAY, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class Recipe(Base):
    __tablename__ = "recipes"

    id = Column(String(36), primary_key=True, index=True)
    title = Column(String(255), index=True)
    description = Column(Text)
    ingredients = Column(ARRAY(String), default=[])
    image_url = Column(String(500))
    video_url = Column(String(500), nullable=True)
    preparation_time = Column(Integer)
    cooking_time = Column(Integer)
    servings = Column(Integer)
    rating = Column(Float, default=0.0)
    tags = Column(ARRAY(String), default=[])
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    nutrition_info = relationship("NutritionInfo", back_populates="recipe", uselist=False, cascade="all, delete-orphan")
    recipe_steps = relationship("RecipeStep", back_populates="recipe", cascade="all, delete-orphan")

class NutritionInfo(Base):
    __tablename__ = "nutrition_info"

    id = Column(String(36), primary_key=True)
    recipe_id = Column(String(36), ForeignKey("recipes.id"), index=True)
    calories = Column(Float)
    protein = Column(Float)
    carbohydrates = Column(Float)
    fat = Column(Float)
    fiber = Column(Float)
    sodium = Column(Float)
    sugar = Column(Float)

    recipe = relationship("Recipe", back_populates="nutrition_info")

class RecipeStep(Base):
    __tablename__ = "recipe_steps"

    id = Column(String(36), primary_key=True)
    recipe_id = Column(String(36), ForeignKey("recipes.id"), index=True)
    step_number = Column(Integer)
    instruction = Column(Text)
    image_url = Column(String(500), nullable=True)
    video_url = Column(String(500), nullable=True)
    duration_seconds = Column(Integer, nullable=True)

    recipe = relationship("Recipe", back_populates="recipe_steps")

class FoodItem(Base):
    __tablename__ = "food_items"

    id = Column(String(36), primary_key=True)
    name = Column(String(255), index=True)
    barcode = Column(String(50), unique=True, index=True)
    image_url = Column(String(500))
    serving_size = Column(Float)
    serving_unit = Column(String(50))
    ingredients = Column(ARRAY(String), default=[])
    expiry_date = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)

    nutrition_info = relationship("FoodNutritionInfo", back_populates="food_item", uselist=False, cascade="all, delete-orphan")

class FoodNutritionInfo(Base):
    __tablename__ = "food_nutrition_info"

    id = Column(String(36), primary_key=True)
    food_id = Column(String(36), ForeignKey("food_items.id"), index=True)
    calories = Column(Float)
    protein = Column(Float)
    carbohydrates = Column(Float)
    fat = Column(Float)
    fiber = Column(Float)
    sodium = Column(Float)
    sugar = Column(Float)

    food_item = relationship("FoodItem", back_populates="nutrition_info")

class UserProfile(Base):
    __tablename__ = "user_profiles"

    id = Column(String(36), primary_key=True)
    email = Column(String(255), unique=True, index=True)
    display_name = Column(String(255), nullable=True)
    photo_url = Column(String(500), nullable=True)
    dietary_preferences = Column(ARRAY(String), default=[])
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

class UserFavorite(Base):
    __tablename__ = "user_favorites"

    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user_profiles.id"), index=True)
    recipe_id = Column(String(36), ForeignKey("recipes.id"), index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

class UserHistory(Base):
    __tablename__ = "user_history"

    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user_profiles.id"), index=True)
    recipe_id = Column(String(36), ForeignKey("recipes.id"), index=True)
    cooked_at = Column(DateTime, default=datetime.utcnow)

class ShoppingList(Base):
    __tablename__ = "shopping_lists"

    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("user_profiles.id"), index=True)
    item_name = Column(String(255))
    quantity = Column(Integer)
    unit = Column(String(50))
    is_purchased = Column(Boolean, default=False)
    added_at = Column(DateTime, default=datetime.utcnow)
