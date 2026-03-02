-- Smart Cooking Helper Database Schema

-- Create extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Users table
CREATE TABLE IF NOT EXISTS user_profiles (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    display_name VARCHAR(255),
    photo_url VARCHAR(500),
    dietary_preferences TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_email UNIQUE(email)
);

-- Recipes table
CREATE TABLE IF NOT EXISTS recipes (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    ingredients TEXT[] DEFAULT ARRAY[]::TEXT[],
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    preparation_time INTEGER DEFAULT 0,
    cooking_time INTEGER DEFAULT 0,
    servings INTEGER DEFAULT 1,
    rating FLOAT DEFAULT 0.0,
    tags TEXT[] DEFAULT ARRAY[]::TEXT[],
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for recipe searches
CREATE INDEX idx_recipes_title ON recipes USING gin(title gin_trgm_ops);
CREATE INDEX idx_recipes_tags ON recipes USING gin(tags);
CREATE INDEX idx_recipes_created_at ON recipes(created_at DESC);

-- Nutrition Info table
CREATE TABLE IF NOT EXISTS nutrition_info (
    id VARCHAR(36) PRIMARY KEY,
    recipe_id VARCHAR(36) UNIQUE NOT NULL,
    calories FLOAT,
    protein FLOAT,
    carbohydrates FLOAT,
    fat FLOAT,
    fiber FLOAT,
    sodium FLOAT,
    sugar FLOAT,
    CONSTRAINT fk_recipe FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- Recipe Steps table
CREATE TABLE IF NOT EXISTS recipe_steps (
    id VARCHAR(36) PRIMARY KEY,
    recipe_id VARCHAR(36) NOT NULL,
    step_number INTEGER NOT NULL,
    instruction TEXT NOT NULL,
    image_url VARCHAR(500),
    video_url VARCHAR(500),
    duration_seconds INTEGER,
    CONSTRAINT fk_recipe_steps FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

CREATE INDEX idx_recipe_steps_recipe_id ON recipe_steps(recipe_id);
CREATE INDEX idx_recipe_steps_number ON recipe_steps(recipe_id, step_number);

-- Food Items table
CREATE TABLE IF NOT EXISTS food_items (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    image_url VARCHAR(500),
    serving_size FLOAT,
    serving_unit VARCHAR(50),
    ingredients TEXT[] DEFAULT ARRAY[]::TEXT[],
    expiry_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_food_items_barcode ON food_items(barcode);
CREATE INDEX idx_food_items_name ON food_items USING gin(name gin_trgm_ops);

-- Food Nutrition Info table
CREATE TABLE IF NOT EXISTS food_nutrition_info (
    id VARCHAR(36) PRIMARY KEY,
    food_id VARCHAR(36) UNIQUE NOT NULL,
    calories FLOAT,
    protein FLOAT,
    carbohydrates FLOAT,
    fat FLOAT,
    fiber FLOAT,
    sodium FLOAT,
    sugar FLOAT,
    CONSTRAINT fk_food FOREIGN KEY (food_id) REFERENCES food_items(id) ON DELETE CASCADE
);

-- User Favorites table
CREATE TABLE IF NOT EXISTS user_favorites (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    recipe_id VARCHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_fav FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE,
    CONSTRAINT fk_recipe_fav FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    CONSTRAINT unique_favorite UNIQUE(user_id, recipe_id)
);

CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);

-- User History table
CREATE TABLE IF NOT EXISTS user_history (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    recipe_id VARCHAR(36) NOT NULL,
    cooked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_history FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE,
    CONSTRAINT fk_recipe_history FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_history_user_id ON user_history(user_id);
CREATE INDEX idx_user_history_cooked_at ON user_history(user_id, cooked_at DESC);

-- Shopping Lists table
CREATE TABLE IF NOT EXISTS shopping_lists (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    quantity INTEGER,
    unit VARCHAR(50),
    is_purchased BOOLEAN DEFAULT FALSE,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_shopping FOREIGN KEY (user_id) REFERENCES user_profiles(id) ON DELETE CASCADE
);

CREATE INDEX idx_shopping_lists_user_id ON shopping_lists(user_id);
CREATE INDEX idx_shopping_lists_purchased ON shopping_lists(user_id, is_purchased);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE ON recipes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
