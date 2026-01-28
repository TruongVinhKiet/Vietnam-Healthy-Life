-- ============================================================
-- VIETNAMESE DISHES SEED DATA
-- Purpose: Populate database with 10 popular Vietnamese dishes
-- Author: System
-- Date: 2025
-- ============================================================
-- 
-- NOTE: This seed file uses generic food_id values as placeholders.
-- Before running, you must replace these with actual food_id values
-- from your Food table that match the described ingredients.
--
-- To find correct food_ids, run:
-- SELECT food_id, name FROM Food WHERE name ILIKE '%beef%';
-- SELECT food_id, name FROM Food WHERE name ILIKE '%rice noodle%';
-- etc.
-- ============================================================

-- ============================================================
-- DISH 1: PHỞ BÒ (Beef Noodle Soup)
-- Total serving: ~600g
-- Description: Traditional Vietnamese beef noodle soup with herbs
-- ============================================================

-- Insert the dish
INSERT INTO Dish (
    name, 
    vietnamese_name, 
    description, 
    category, 
    serving_size_g, 
    image_url,
    is_template,
    is_public,
    created_by_admin
) VALUES (
    'Beef Pho',
    'Phở Bò',
    'Traditional Vietnamese beef noodle soup with fresh herbs, bean sprouts, and aromatic broth',
    'noodle',
    600,
    'https://example.com/images/pho-bo.jpg',  -- Replace with actual image URL
    TRUE,
    TRUE,
    1  -- Assumes admin_id=1 exists
) RETURNING dish_id;  -- Store this ID for reference

-- Insert ingredients (replace food_id values with actual IDs from your database)
-- Assuming the dish_id returned above is stored in a variable, but for static SQL we'll use a subquery

-- Rice noodles (bánh phở) - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES (
    (SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Bò' LIMIT 1),
    1001,  -- REPLACE: food_id for rice noodles
    200,
    'Fresh rice noodles, boiled',
    1
);

-- Beef slices (thịt bò) - 100g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES (
    (SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Bò' LIMIT 1),
    1002,  -- REPLACE: food_id for beef, lean cuts
    100,
    'Thinly sliced rare beef',
    2
);

-- Beef broth (nước dùng) - 250g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES (
    (SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Bò' LIMIT 1),
    1003,  -- REPLACE: food_id for beef broth/stock
    250,
    'Aromatic beef broth with star anise and cinnamon',
    3
);

-- Bean sprouts (giá đỗ) - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES (
    (SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Bò' LIMIT 1),
    1004,  -- REPLACE: food_id for bean sprouts
    30,
    'Fresh mung bean sprouts',
    4
);

-- Fresh herbs mix (rau thơm) - 20g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES (
    (SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Bò' LIMIT 1),
    1005,  -- REPLACE: food_id for herbs (basil, cilantro mix)
    20,
    'Thai basil, cilantro, and mint',
    5
);

-- ============================================================
-- DISH 2: PHỞ GÀ (Chicken Noodle Soup)
-- Total serving: ~550g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Chicken Pho',
    'Phở Gà',
    'Light and flavorful chicken noodle soup with herbs',
    'noodle',
    550,
    'https://example.com/images/pho-ga.jpg',
    TRUE, TRUE, 1
);

-- Rice noodles - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Gà' LIMIT 1), 1001, 200, 'Fresh rice noodles', 1);

-- Chicken breast - 120g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Gà' LIMIT 1), 1006, 120, 'Sliced chicken breast', 2);

-- Chicken broth - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Gà' LIMIT 1), 1007, 200, 'Clear chicken broth', 3);

-- Bean sprouts - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Phở Gà' LIMIT 1), 1004, 30, 'Fresh bean sprouts', 4);

-- ============================================================
-- DISH 3: BÁNH MÌ (Vietnamese Baguette Sandwich)
-- Total serving: ~250g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Vietnamese Baguette Sandwich',
    'Bánh Mì',
    'Crispy baguette with pork, pate, pickled vegetables, and herbs',
    'sandwich',
    250,
    'https://example.com/images/banh-mi.jpg',
    TRUE, TRUE, 1
);

-- Baguette bread - 100g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Mì' LIMIT 1), 1008, 100, 'Vietnamese-style baguette', 1);

-- Grilled pork - 60g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Mì' LIMIT 1), 1009, 60, 'Marinated grilled pork', 2);

-- Pate - 15g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Mì' LIMIT 1), 1010, 15, 'Pork liver pate', 3);

-- Pickled vegetables - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Mì' LIMIT 1), 1011, 40, 'Pickled carrot and daikon', 4);

-- Cucumber - 20g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Mì' LIMIT 1), 1012, 20, 'Fresh cucumber slices', 5);

-- Cilantro - 15g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Mì' LIMIT 1), 1013, 15, 'Fresh cilantro', 6);

-- ============================================================
-- DISH 4: CƠM TẤM (Broken Rice with Grilled Pork)
-- Total serving: ~450g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Broken Rice with Grilled Pork',
    'Cơm Tấm Sườn',
    'Broken rice with grilled pork chop, pickled vegetables, and fish sauce',
    'rice',
    450,
    'https://example.com/images/com-tam.jpg',
    TRUE, TRUE, 1
);

-- Broken rice - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Tấm Sườn' LIMIT 1), 1014, 200, 'Steamed broken rice', 1);

-- Grilled pork chop - 120g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Tấm Sườn' LIMIT 1), 1015, 120, 'Marinated grilled pork chop', 2);

-- Fried egg - 50g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Tấm Sườn' LIMIT 1), 1016, 50, 'Fried egg, sunny side up', 3);

-- Pickled vegetables - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Tấm Sườn' LIMIT 1), 1011, 40, 'Pickled vegetables', 4);

-- Cucumber & tomato - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Tấm Sườn' LIMIT 1), 1017, 40, 'Fresh cucumber and tomato', 5);

-- ============================================================
-- DISH 5: BÚN BÒ HUẾ (Spicy Beef Noodle Soup)
-- Total serving: ~650g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Hue-style Spicy Beef Noodle Soup',
    'Bún Bò Huế',
    'Spicy and aromatic beef and pork noodle soup from Hue',
    'noodle',
    650,
    'https://example.com/images/bun-bo-hue.jpg',
    TRUE, TRUE, 1
);

-- Round rice noodles (bún) - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Bò Huế' LIMIT 1), 1018, 200, 'Round rice vermicelli', 1);

-- Beef shank - 80g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Bò Huế' LIMIT 1), 1019, 80, 'Sliced beef shank', 2);

-- Pork hock - 60g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Bò Huế' LIMIT 1), 1020, 60, 'Sliced pork hock', 3);

-- Spicy broth - 280g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Bò Huế' LIMIT 1), 1021, 280, 'Lemongrass and chili broth', 4);

-- Herbs and vegetables - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Bò Huế' LIMIT 1), 1005, 30, 'Herbs, banana blossom, cabbage', 5);

-- ============================================================
-- DISH 6: BÚN CHẢ (Grilled Pork with Vermicelli)
-- Total serving: ~500g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Grilled Pork with Vermicelli',
    'Bún Chả',
    'Hanoi-style grilled pork patties with vermicelli and dipping sauce',
    'noodle',
    500,
    'https://example.com/images/bun-cha.jpg',
    TRUE, TRUE, 1
);

-- Rice vermicelli - 150g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Chả' LIMIT 1), 1018, 150, 'Fresh rice vermicelli', 1);

-- Grilled pork patties - 100g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Chả' LIMIT 1), 1022, 100, 'Grilled pork meatballs', 2);

-- Grilled pork slices - 80g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Chả' LIMIT 1), 1009, 80, 'Grilled pork belly slices', 3);

-- Dipping sauce - 100g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Chả' LIMIT 1), 1023, 100, 'Sweet fish sauce with pickles', 4);

-- Fresh herbs - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Chả' LIMIT 1), 1005, 40, 'Lettuce, herbs, cucumber', 5);

-- Pickled vegetables - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bún Chả' LIMIT 1), 1011, 30, 'Pickled papaya', 6);

-- ============================================================
-- DISH 7: BÁNH CUỐN (Steamed Rice Rolls)
-- Total serving: ~300g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Steamed Rice Rolls',
    'Bánh Cuốn',
    'Delicate steamed rice rolls with pork and mushroom filling',
    'rice',
    300,
    'https://example.com/images/banh-cuon.jpg',
    TRUE, TRUE, 1
);

-- Rice rolls - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Cuốn' LIMIT 1), 1024, 200, 'Steamed rice flour sheets', 1);

-- Minced pork - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Cuốn' LIMIT 1), 1025, 40, 'Ground pork filling', 2);

-- Wood ear mushrooms - 20g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Cuốn' LIMIT 1), 1026, 20, 'Sliced wood ear mushrooms', 3);

-- Fish sauce dip - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Cuốn' LIMIT 1), 1023, 30, 'Nuoc cham dipping sauce', 4);

-- Fried shallots - 10g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Bánh Cuốn' LIMIT 1), 1027, 10, 'Crispy fried shallots', 5);

-- ============================================================
-- DISH 8: GỎI CUỐN (Fresh Spring Rolls)
-- Total serving: ~200g (2 rolls)
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Fresh Spring Rolls',
    'Gỏi Cuốn',
    'Fresh rice paper rolls with shrimp, pork, vegetables and herbs',
    'appetizer',
    200,
    'https://example.com/images/goi-cuon.jpg',
    TRUE, TRUE, 1
);

-- Rice paper - 20g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Gỏi Cuốn' LIMIT 1), 1028, 20, 'Fresh rice paper wrappers', 1);

-- Shrimp - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Gỏi Cuốn' LIMIT 1), 1029, 40, 'Boiled shrimp', 2);

-- Pork belly - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Gỏi Cuốn' LIMIT 1), 1030, 30, 'Boiled pork belly', 3);

-- Rice vermicelli - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Gỏi Cuốn' LIMIT 1), 1018, 40, 'Cooked vermicelli', 4);

-- Lettuce and herbs - 40g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Gỏi Cuốn' LIMIT 1), 1031, 40, 'Lettuce, mint, cilantro', 5);

-- Peanut sauce - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Gỏi Cuốn' LIMIT 1), 1032, 30, 'Hoisin peanut dipping sauce', 6);

-- ============================================================
-- DISH 9: CƠM GÀ (Chicken Rice)
-- Total serving: ~400g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Vietnamese Chicken Rice',
    'Cơm Gà',
    'Fragrant rice cooked in chicken broth with poached chicken',
    'rice',
    400,
    'https://example.com/images/com-ga.jpg',
    TRUE, TRUE, 1
);

-- Jasmine rice - 200g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Gà' LIMIT 1), 1033, 200, 'Rice cooked in chicken broth', 1);

-- Poached chicken - 130g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Gà' LIMIT 1), 1034, 130, 'Poached chicken thigh', 2);

-- Cucumber - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Gà' LIMIT 1), 1012, 30, 'Sliced cucumber', 3);

-- Ginger fish sauce - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Gà' LIMIT 1), 1035, 30, 'Ginger-infused fish sauce', 4);

-- Fried shallots - 10g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Cơm Gà' LIMIT 1), 1027, 10, 'Crispy fried shallots', 5);

-- ============================================================
-- DISH 10: HỦ TIẾU (Southern-Style Noodle Soup)
-- Total serving: ~600g
-- ============================================================

INSERT INTO Dish (
    name, vietnamese_name, description, category, serving_size_g, 
    image_url, is_template, is_public, created_by_admin
) VALUES (
    'Southern-Style Noodle Soup',
    'Hủ Tiếu Nam Vang',
    'Clear pork and seafood noodle soup with rice noodles',
    'noodle',
    600,
    'https://example.com/images/hu-tieu.jpg',
    TRUE, TRUE, 1
);

-- Rice noodles (hu tieu) - 180g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Hủ Tiếu Nam Vang' LIMIT 1), 1036, 180, 'Flat rice noodles', 1);

-- Pork - 60g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Hủ Tiếu Nam Vang' LIMIT 1), 1037, 60, 'Minced pork and liver', 2);

-- Shrimp - 50g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Hủ Tiếu Nam Vang' LIMIT 1), 1029, 50, 'Fresh shrimp', 3);

-- Squid - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Hủ Tiếu Nam Vang' LIMIT 1), 1038, 30, 'Sliced squid', 4);

-- Pork broth - 250g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Hủ Tiếu Nam Vang' LIMIT 1), 1039, 250, 'Clear pork bone broth', 5);

-- Bean sprouts and herbs - 30g
INSERT INTO DishIngredient (dish_id, food_id, weight_g, notes, display_order)
VALUES ((SELECT dish_id FROM Dish WHERE vietnamese_name = 'Hủ Tiếu Nam Vang' LIMIT 1), 1040, 30, 'Bean sprouts, chives, lettuce', 6);

-- ============================================================
-- CALCULATE NUTRIENTS FOR ALL DISHES
-- ============================================================

-- After all ingredients are inserted, calculate nutrients for each dish
SELECT calculate_dish_nutrients(dish_id) FROM Dish WHERE is_template = TRUE;

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- View all dishes with their ingredient counts
-- SELECT d.dish_id, d.vietnamese_name, d.name, COUNT(di.dish_ingredient_id) as ingredient_count
-- FROM Dish d
-- LEFT JOIN DishIngredient di ON di.dish_id = d.dish_id
-- WHERE d.is_template = TRUE
-- GROUP BY d.dish_id, d.vietnamese_name, d.name
-- ORDER BY d.dish_id;

-- View dish with calculated macros
-- SELECT * FROM dish_with_macros WHERE is_template = TRUE ORDER BY dish_id;

-- View specific dish ingredients
-- SELECT d.vietnamese_name, f.name as ingredient_name, di.weight_g, di.notes
-- FROM Dish d
-- JOIN DishIngredient di ON di.dish_id = d.dish_id
-- JOIN Food f ON f.food_id = di.food_id
-- WHERE d.vietnamese_name = 'Phở Bò'
-- ORDER BY di.display_order;

-- ============================================================
-- IMPORTANT SETUP NOTES FOR ADMIN
-- ============================================================

/*
BEFORE RUNNING THIS MIGRATION:

1. Find correct food_id values from your Food table:
   - Search for ingredients similar to Vietnamese dishes
   - Map generic USDA foods to Vietnamese equivalents
   - Example mapping:
     * Rice noodles → "Noodles, rice, cooked"
     * Beef → "Beef, round, lean"
     * Chicken → "Chicken, breast, skinless"
     * etc.

2. Update all food_id placeholder values (1001-1040) in this file
   with actual food_id values from your database.

3. Update image URLs:
   - Upload dish images to your server or use a CDN
   - Replace placeholder URLs with actual image paths

4. Ensure admin_id=1 exists:
   - Check: SELECT admin_id FROM Admin LIMIT 1;
   - If different, update created_by_admin value

5. After running migration, verify:
   - SELECT * FROM Dish WHERE is_template = TRUE;
   - SELECT * FROM dish_with_macros WHERE is_template = TRUE;
   - Check that nutrients are calculated correctly

6. Troubleshooting:
   - If nutrients are zero, check that Food and FoodNutrient tables
     have correct data for the mapped food_ids
   - Run: SELECT calculate_dish_nutrients(dish_id) FROM Dish;
     to recalculate nutrients manually

FOOD ID MAPPING TEMPLATE:
Copy this template and fill in actual food_ids from your database:

-- Noodles & Grains
1001 → _____ (Rice noodles, fresh/bánh phở)
1014 → _____ (Broken rice/cơm tấm)
1018 → _____ (Round rice noodles/bún)
1024 → _____ (Rice flour sheets/bánh cuốn)
1028 → _____ (Rice paper/bánh tráng)
1033 → _____ (Jasmine rice)
1036 → _____ (Flat rice noodles/hủ tiếu)

-- Meats & Proteins
1002 → _____ (Beef, lean)
1006 → _____ (Chicken breast)
1009 → _____ (Pork, grilled)
1015 → _____ (Pork chop)
1016 → _____ (Egg, fried)
1019 → _____ (Beef shank)
1020 → _____ (Pork hock)
1022 → _____ (Ground pork)
1025 → _____ (Minced pork)
1029 → _____ (Shrimp)
1030 → _____ (Pork belly)
1034 → _____ (Chicken thigh)
1037 → _____ (Pork liver)
1038 → _____ (Squid)

-- Vegetables & Herbs
1004 → _____ (Bean sprouts)
1005 → _____ (Fresh herbs mix)
1011 → _____ (Pickled vegetables)
1012 → _____ (Cucumber)
1013 → _____ (Cilantro)
1017 → _____ (Tomato/cucumber mix)
1026 → _____ (Mushrooms)
1031 → _____ (Lettuce)
1040 → _____ (Mixed vegetables)

-- Bread & Bakery
1008 → _____ (Baguette)
1010 → _____ (Pate)

-- Sauces & Condiments
1003 → _____ (Beef broth)
1007 → _____ (Chicken broth)
1021 → _____ (Spicy broth)
1023 → _____ (Fish sauce)
1027 → _____ (Fried shallots)
1032 → _____ (Peanut sauce)
1035 → _____ (Ginger sauce)
1039 → _____ (Pork broth)
*/

-- ============================================================
-- END OF VIETNAMESE DISHES SEED FILE
-- ============================================================
