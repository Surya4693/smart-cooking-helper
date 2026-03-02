-- Sample recipes data for testing

INSERT INTO recipes (id, title, description, ingredients, image_url, preparation_time, cooking_time, servings, rating, tags) VALUES
('recipe-1', 'Tomato Rice', 'A simple and delicious tomato rice recipe', ARRAY['tomato', 'rice', 'onion', 'garlic', 'oil', 'salt', 'pepper'], 'https://via.placeholder.com/400', 5, 20, 2, 4.5, ARRAY['vegetarian', 'quick', 'indian']),
('recipe-2', 'Vegetable Stir Fry', 'Healthy and colorful stir fry with mixed vegetables', ARRAY['broccoli', 'bell pepper', 'carrot', 'soy sauce', 'garlic', 'ginger', 'oil'], 'https://via.placeholder.com/400', 10, 15, 4, 4.7, ARRAY['vegetarian', 'vegan', 'healthy']),
('recipe-3', 'Pasta Carbonara', 'Classic Italian pasta with eggs and bacon', ARRAY['pasta', 'eggs', 'bacon', 'parmesan', 'black pepper'], 'https://via.placeholder.com/400', 10, 20, 4, 4.8, ARRAY['italian', 'dinner']),
('recipe-4', 'Grilled Chicken Salad', 'Protein-rich salad with grilled chicken', ARRAY['chicken', 'lettuce', 'tomato', 'cucumber', 'olive oil', 'lemon'], 'https://via.placeholder.com/400', 15, 20, 2, 4.6, ARRAY['healthy', 'salad', 'protein']),
('recipe-5', 'Chocolate Chip Cookies', 'Soft and chewy chocolate chip cookies', ARRAY['flour', 'butter', 'sugar', 'eggs', 'chocolate chips', 'vanilla'], 'https://via.placeholder.com/400', 15, 12, 24, 4.9, ARRAY['dessert', 'baking']);

-- Insert nutrition info
INSERT INTO nutrition_info (id, recipe_id, calories, protein, carbohydrates, fat, fiber, sodium, sugar) VALUES
('nutrition-1', 'recipe-1', 250, 5, 45, 4, 2, 400, 3),
('nutrition-2', 'recipe-2', 180, 8, 22, 7, 5, 600, 4),
('nutrition-3', 'recipe-3', 420, 25, 45, 18, 2, 700, 1),
('nutrition-4', 'recipe-4', 220, 30, 8, 9, 3, 300, 2),
('nutrition-5', 'recipe-5', 280, 3, 35, 14, 1, 200, 20);

-- Insert recipe steps
INSERT INTO recipe_steps (id, recipe_id, step_number, instruction, duration_seconds) VALUES
('step-1-1', 'recipe-1', 1, 'Wash and soak rice for 15 minutes', 900),
('step-1-2', 'recipe-1', 2, 'Heat oil in a pan and add chopped onions', 300),
('step-1-3', 'recipe-1', 3, 'Add chopped tomatoes and cook for 2 minutes', 120),
('step-1-4', 'recipe-1', 4, 'Add soaked rice and water (2:1 ratio)', 60),
('step-1-5', 'recipe-1', 5, 'Cover and cook until rice is tender', 1200),
('step-1-6', 'recipe-1', 6, 'Fluff with fork and serve hot', 120);

INSERT INTO recipe_steps (id, recipe_id, step_number, instruction, duration_seconds) VALUES
('step-2-1', 'recipe-2', 1, 'Chop all vegetables into bite-sized pieces', 300),
('step-2-2', 'recipe-2', 2, 'Heat oil in a wok or large pan', 120),
('step-2-3', 'recipe-2', 3, 'Add garlic and ginger, stir for 30 seconds', 30),
('step-2-4', 'recipe-2', 4, 'Add hard vegetables first (carrot, broccoli)', 180),
('step-2-5', 'recipe-2', 5, 'Add bell peppers and soy sauce', 120),
('step-2-6', 'recipe-2', 6, 'Toss everything and serve immediately', 60);
