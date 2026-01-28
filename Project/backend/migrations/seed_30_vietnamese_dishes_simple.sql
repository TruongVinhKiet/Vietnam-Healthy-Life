-- 30 Vietnamese Dishes (UTF-8 Safe)
BEGIN;

-- 1. Beef Pho
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Beef Pho', 'Pho Bo', 'Traditional Vietnamese beef noodle soup', 'noodle', 600, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 3, 300, 'Rice noodles', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 18, 150, 'Beef', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 50, 'Herbs', 3;

-- 2. Grilled Pork with Vermicelli
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Bun Cha', 'Bun Cha', 'Grilled pork with vermicelli Hanoi style', 'noodle', 500, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 4, 200, 'Vermicelli', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 150, 'Grilled pork', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 100, 'Fresh vegetables', 3;

-- 3. Broken Rice with Grilled Pork
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Broken Rice', 'Com Tam', 'Broken rice with grilled pork and egg', 'rice', 550, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 250, 'Broken rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 120, 'Grilled pork', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 21, 50, 'Fried egg', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 30, 'Tomato', 4
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 50, 'Cucumber', 5;

-- 4. Vietnamese Sandwich
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Banh Mi', 'Banh Mi', 'Vietnamese baguette with pork and vegetables', 'bread', 200, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 2, 100, 'Baguette', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 50, 'Pork', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 20, 'Tomato', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 20, 'Cucumber', 4
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 10, 'Herbs', 5;

-- 5. Fresh Spring Rolls
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Spring Rolls', 'Goi Cuon', 'Fresh spring rolls with shrimp and pork', 'appetizer', 300, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 4, 100, 'Vermicelli', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 20, 80, 'Shrimp', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 50, 'Pork', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 70, 'Lettuce', 4;

-- 6. Hue Beef Noodle Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Bun Bo Hue', 'Bun Bo Hue', 'Spicy beef noodle soup from Central Vietnam', 'noodle', 650, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 4, 300, 'Round noodles', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 18, 150, 'Beef', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 80, 'Herbs', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 50, 'Tomato', 4;

-- 7. Braised Fish
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Braised Fish', 'Ca Kho To', 'Caramelized braised fish in clay pot', 'main_dish', 400, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 200, 'White rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 19, 150, 'Fish', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 50, 'Herbs', 3;

-- 8. Sour Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Sour Soup', 'Canh Chua', 'Sweet and sour fish soup', 'soup', 450, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 19, 120, 'Fish', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 80, 'Tomato', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 6, 100, 'Water spinach', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 50, 'Pineapple substitute', 4;

-- 9. Sticky Rice
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Sticky Rice', 'Xoi Xeo', 'Sticky rice with mung bean and chicken', 'rice', 350, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 200, 'Sticky rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 17, 100, 'Chicken', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 22, 50, 'Mung bean tofu', 3;

-- 10. Fried Spring Rolls
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Fried Rolls', 'Cha Gio', 'Crispy fried spring rolls', 'appetizer', 250, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 16, 100, 'Pork', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 20, 50, 'Shrimp', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 50, 'Vegetables', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 5, 50, 'Glass noodles', 4;

-- 11. Stir-fried Noodles
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Stir-fried Noodles', 'Mi Xao', 'Crispy noodles with seafood and vegetables', 'noodle', 450, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 5, 200, 'Noodles', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 20, 80, 'Shrimp', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 70, 'Pork', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 60, 'Vegetables', 4;

-- 12. Chicken Rice
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Chicken Rice', 'Com Ga', 'Hainanese chicken rice Vietnamese style', 'rice', 450, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 250, 'White rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 17, 150, 'Chicken', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 30, 'Cucumber', 3;

-- 13. Seaweed Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Seaweed Soup', 'Canh Rong Bien', 'Seaweed soup with pork and egg', 'soup', 400, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 16, 100, 'Ground pork', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 21, 50, 'Egg', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 50, 'Tomato', 3;

-- 14. Shaking Beef
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Shaking Beef', 'Bo Luc Lac', 'French-Vietnamese shaking beef', 'main_dish', 350, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 18, 200, 'Beef cubes', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 50, 'Tomato', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 30, 'Lettuce', 3;

-- 15. Southern Noodle Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Hu Tieu', 'Hu Tieu', 'Southern noodle soup with pork and seafood', 'noodle', 550, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 4, 250, 'Hu tieu noodles', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 20, 100, 'Shrimp', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 80, 'Pork', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 60, 'Vegetables', 4;

-- 16. Braised Pork with Eggs
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Braised Pork Eggs', 'Thit Kho Tau', 'Southern style braised pork with eggs', 'main_dish', 400, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 200, 'White rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 150, 'Pork belly', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 21, 50, 'Eggs', 3;

-- 17. Fish Sauce Chicken
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Fish Sauce Chicken', 'Ga Chien Nuoc Mam', 'Crispy chicken wings with fish sauce', 'main_dish', 300, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 17, 250, 'Chicken wings', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 20, 'Cucumber', 2;

-- 18. Fried Rice
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Fried Rice', 'Com Chien', 'Yangzhou fried rice Vietnamese style', 'rice', 400, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 250, 'White rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 21, 50, 'Eggs', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 20, 50, 'Shrimp', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 30, 'Vegetables', 4;

-- 19. Crab Noodle Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Bun Rieu', 'Bun Rieu', 'Crab and tomato noodle soup', 'noodle', 550, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 4, 250, 'Vermicelli', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 22, 100, 'Tofu', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 80, 'Tomato', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 6, 60, 'Water spinach', 4;

-- 20. Grilled Pork Skewers
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Grilled Pork Skewers', 'Nem Nuong', 'Nha Trang grilled pork skewers', 'appetizer', 300, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 16, 150, 'Pork', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 80, 'Fresh vegetables', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 40, 'Cucumber', 3;

-- 21. Crab Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Crab Soup', 'Sup Cua', 'Asian-style crab soup', 'soup', 350, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 20, 100, 'Shrimp as crab substitute', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 21, 50, 'Eggs', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 50, 'Tomato', 3;

-- 22. Soy Fried Rice
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Soy Fried Rice', 'Com Rang', 'Mixed fried rice with meat and vegetables', 'rice', 400, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 250, 'White rice', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 17, 80, 'Chicken', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 21, 50, 'Eggs', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 40, 'Vegetables', 4;

-- 23. Grilled Pork Banh Mi
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Grilled Pork Banh Mi', 'Banh Mi Thit Nuong', 'Saigon grilled pork sandwich', 'bread', 220, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 2, 100, 'Baguette', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 70, 'Grilled pork', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 20, 'Tomato', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 9, 20, 'Cucumber', 4;

-- 24. Quang Style Noodles
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Mi Quang', 'Mi Quang', 'Central Vietnam specialty with turmeric noodles', 'noodle', 500, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 3, 200, 'Flat noodles', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 20, 100, 'Shrimp', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 80, 'Pork', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 60, 'Vegetables', 4;

-- 25. Chicken Congee
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Chicken Congee', 'Chao Ga', 'Nutritious chicken rice porridge', 'rice', 450, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 1, 200, 'Rice for congee', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 17, 120, 'Chicken', 2;

-- 26. Fish Noodle Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Fish Noodle Soup', 'Bun Ca', 'Hanoi fish noodle soup with turmeric', 'noodle', 500, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 4, 250, 'Vermicelli', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 19, 150, 'Fish', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 50, 'Tomato', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 30, 'Herbs', 4;

-- 27. Crispy Fried Shrimp
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Crispy Shrimp', 'Tom Chien Xu', 'Crispy breaded fried shrimp', 'main_dish', 250, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 20, 200, 'Shrimp', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 20, 'Tomato', 2;

-- 28. Pumpkin Soup
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Pumpkin Soup', 'Canh Bi Do', 'Pumpkin soup with ground pork', 'soup', 400, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 9, 150, 'Cucumber as pumpkin substitute', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 16, 100, 'Ground pork', 2;

-- 29. Tofu in Tomato Sauce
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Tofu Tomato Sauce', 'Dau Hu Sot Ca Chua', 'Fried tofu in tomato sauce', 'main_dish', 350, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 22, 200, 'Tofu', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 8, 100, 'Tomato', 2;

-- 30. Stir-fried Vegetables
INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
VALUES ('Stir-fried Veggies', 'Rau Cu Xao', 'Healthy stir-fried mixed vegetables', 'main_dish', 350, TRUE, TRUE, 1);
INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order)
SELECT currval('dish_dish_id_seq'), 6, 100, 'Water spinach', 1
UNION ALL SELECT currval('dish_dish_id_seq'), 7, 80, 'Cabbage', 2
UNION ALL SELECT currval('dish_dish_id_seq'), 10, 70, 'Vegetables', 3
UNION ALL SELECT currval('dish_dish_id_seq'), 22, 50, 'Tofu', 4;

COMMIT;

-- Verify
SELECT COUNT(*) as total_dishes FROM dish WHERE is_template = TRUE;
SELECT 
    d.dish_id,
    d.name,
    d.vietnamese_name,
    d.category,
    COUNT(di.dish_ingredient_id) as ingredients
FROM dish d
LEFT JOIN dishingredient di ON d.dish_id = di.dish_id
WHERE d.is_template = TRUE
GROUP BY d.dish_id, d.name, d.vietnamese_name, d.category
ORDER BY d.dish_id DESC
LIMIT 30;
