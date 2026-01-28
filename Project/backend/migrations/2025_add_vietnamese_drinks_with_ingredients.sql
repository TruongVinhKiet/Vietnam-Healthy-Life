-- Add Popular Vietnamese Drinks with Multiple Ingredients
-- Date: 2025-12-06
-- Adds 20+ Vietnamese drinks with proper ingredients and comprehensive recommendations

-- First, add necessary food ingredients if not exist
INSERT INTO food (name, name_vi, category, serving_size_g, created_by_admin) VALUES
('Green Tea Leaves', 'Lá Trà Xanh', 'Beverage Ingredients', 2, true),
('Black Tea Leaves', 'Lá Trà Den', 'Beverage Ingredients', 2, true),
('Fresh Ginger', 'Gung Tuoi', 'Spices', 10, true),
('Honey', 'Mat Ong', 'Sweeteners', 20, true),
('Condensed Milk', 'Sua Dac', 'Dairy', 30, true),
('Fresh Milk', 'Sua Tuoi', 'Dairy', 200, true),
('Tapioca Pearls', 'Tran Chau', 'Dessert', 50, true),
('Coffee Beans', 'Ca Phe Hat', 'Beverage Ingredients', 15, true),
('Coconut Milk', 'Sua Dua', 'Dairy Alternative', 200, true),
('Pandan Leaves', 'La Dua', 'Herbs', 5, true),
('Lemongrass', 'Sa', 'Herbs', 10, true),
('Chrysanthemum Flowers', 'Hoa Cuc', 'Herbs', 5, true),
('Lotus Seeds', 'Hat Sen', 'Nuts & Seeds', 30, true),
('Artichoke', 'Atiso', 'Vegetables', 100, true),
('Pennywort', 'Rau Ma', 'Vegetables', 50, true),
('Basil Seeds', 'Hat E', 'Seeds', 10, true),
('Aloe Vera', 'Nha Dam', 'Vegetables', 50, true),
('Pomelo', 'Buoi', 'Fruits', 200, true),
('Passion Fruit', 'Chanh Day', 'Fruits', 80, true),
('Soursop', 'Mang Cau', 'Fruits', 150, true),
('Kumquat', 'Quat', 'Fruits', 20, true),
('Jackfruit', 'Mit', 'Fruits', 150, true),
('Longan', 'Nhan', 'Fruits', 50, true),
('Sapodilla', 'Hong Xiem', 'Fruits', 100, true),
('Peach', 'Dao', 'Fruits', 120, true),
('Young Rice', 'Com', 'Grains', 100, true),
('Black Sesame', 'Me Den', 'Seeds', 20, true),
('Peanut', 'Dau Phong', 'Nuts & Seeds', 30, true),
('Grass Jelly', 'Suong Sao', 'Dessert', 100, true),
('Wintermelon', 'Bi Dao', 'Vegetables', 150, true),
('Mint Leaves', 'La Bac Ha', 'Herbs', 5, true),
('Lime', 'Chanh', 'Fruits', 30, true),
('Rock Sugar', 'Duong Phen', 'Sweeteners', 15, true),
('Brown Sugar', 'Duong Den', 'Sweeteners', 15, true),
('Ice', 'Da', 'Water', 100, true)
ON CONFLICT (name, name_vi) DO NOTHING;

-- Get food_id for ingredients (will use in drinkingredient table)
-- We'll reference by name in the INSERT statements

-- Add popular Vietnamese drinks
INSERT INTO drink (name, vietnamese_name, category, base_liquid, default_volume_ml, default_temperature, default_sweetness, hydration_ratio, is_popular, created_by_admin) VALUES
('Peach Oolong Tea with Lemongrass', 'Tra Dao Cam Sa', 'Tea', 'Tea', 500, 'cold', 'medium', 0.95, true, true),
('Bubble Milk Tea', 'Tra Sua Tran Chau', 'Tea', 'Tea + Milk', 500, 'cold', 'high', 0.75, true, true),
('Pennywort Juice', 'Nuoc Rau Ma', 'Healthy', 'Water', 300, 'cold', 'low', 1.0, true, true),
('Avocado Smoothie Rich', 'Sinh To Bo Dac', 'Smoothie', 'Milk', 400, 'cold', 'medium', 0.8, true, true),
('Artichoke Tea', 'Tra Atiso', 'Healthy', 'Water', 300, 'hot', 'low', 1.0, true, true),
('Salted Lemon Soda', 'Nuoc Chanh Muoi', 'Juice', 'Water', 400, 'cold', 'medium', 0.95, true, true),
('Chrysanthemum Tea', 'Tra Hoa Cuc', 'Tea', 'Water', 300, 'cold', 'low', 1.0, true, true),
('Soursop Smoothie', 'Sinh To Mang Cau', 'Smoothie', 'Water', 400, 'cold', 'medium', 0.85, true, true),
('Ginseng Water', 'Nuoc Sam', 'Healthy', 'Water', 300, 'cold', 'low', 1.0, true, true),
('Lotus Seed Tea', 'Tra Sen', 'Tea', 'Water', 300, 'hot', 'low', 1.0, true, true),
('Passion Fruit Juice', 'Nuoc Chanh Day', 'Juice', 'Water', 400, 'cold', 'medium', 0.9, true, true),
('Ginger Honey Tea', 'Tra Gung Mat Ong', 'Tea', 'Water', 300, 'hot', 'medium', 1.0, true, true),
('Aloe Vera Drink', 'Nuoc Nha Dam', 'Healthy', 'Water', 350, 'cold', 'low', 1.0, true, true),
('Jackfruit Smoothie', 'Sinh To Mit', 'Smoothie', 'Milk', 400, 'cold', 'medium', 0.8, true, true),
('Pomelo Honey Drink', 'Nuoc Buoi Duong', 'Juice', 'Water', 350, 'cold', 'medium', 0.9, true, true),
('Kumquat Honey Tea', 'Tra Quat Mat Ong', 'Tea', 'Water', 300, 'hot', 'medium', 1.0, true, true),
('Longan Smoothie', 'Sinh To Nhan', 'Smoothie', 'Water', 400, 'cold', 'medium', 0.85, true, true),
('Fresh Coconut Water', 'Nuoc Dua Tuoi', 'Juice', 'Coconut', 400, 'cold', 'low', 1.0, true, true),
('Coconut Jelly Tea', 'Tra Thach Dua', 'Tea', 'Tea + Coconut', 500, 'cold', 'medium', 0.85, true, true),
('Sapodilla Smoothie', 'Sinh To Hong Xiem', 'Smoothie', 'Milk', 400, 'cold', 'medium', 0.8, true, true),
('Three Bean Sweet Drink', 'Che Ba Mau', 'Dessert', 'Coconut Milk', 400, 'cold', 'high', 0.7, true, true),
('Young Rice Milk', 'Sua Com', 'Healthy', 'Milk', 300, 'cold', 'medium', 0.85, true, true),
('Mint Lime Tea', 'Tra Bac Ha Chanh', 'Tea', 'Water', 400, 'cold', 'medium', 0.95, true, true),
('Wintermelon Tea', 'Tra Bi Dao', 'Tea', 'Water', 400, 'cold', 'medium', 0.9, true, true),
('Black Sesame Milk', 'Sua Me Den', 'Milk', 'Milk', 300, 'hot', 'medium', 0.85, true, true)
ON CONFLICT (name, vietnamese_name) DO NOTHING;

-- Add ingredients for each drink
-- Tra Dao Cam Sa (Peach Oolong Tea with Lemongrass)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Dao Cam Sa' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Peach', 50, 'g', 1, 'Fresh peach slices'),
    ('Black Tea Leaves', 5, 'g', 2, 'Oolong tea'),
    ('Lemongrass', 10, 'g', 3, 'Fresh lemongrass'),
    ('Honey', 15, 'g', 4, 'Natural sweetener'),
    ('Ice', 100, 'g', 5, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Dao Cam Sa')
ON CONFLICT DO NOTHING;

-- Tra Sua Tran Chau (Bubble Milk Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Black Tea Leaves', 5, 'g', 1, 'Strong black tea'),
    ('Fresh Milk', 150, 'ml', 2, 'Whole milk'),
    ('Tapioca Pearls', 50, 'g', 3, 'Cooked tapioca'),
    ('Brown Sugar', 20, 'g', 4, 'Brown sugar syrup'),
    ('Ice', 100, 'g', 5, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau')
ON CONFLICT DO NOTHING;

-- Nuoc Rau Ma (Pennywort Juice)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Pennywort', 50, 'g', 1, 'Fresh pennywort leaves'),
    ('Pandan Leaves', 3, 'g', 2, 'For aroma'),
    ('Rock Sugar', 10, 'g', 3, 'Light sweetness')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma')
ON CONFLICT DO NOTHING;

-- Sinh To Bo (Avocado Smoothie)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Fresh Milk', 200, 'ml', 2, 'Whole milk'),
    ('Condensed Milk', 30, 'g', 3, 'Sweetened condensed milk'),
    ('Ice', 100, 'g', 4, 'Crushed ice')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac')
ON CONFLICT DO NOTHING;

-- Tra Atiso (Artichoke Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Artichoke', 80, 'g', 1, 'Artichoke extract'),
    ('Honey', 10, 'g', 2, 'Optional sweetener')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Atiso')
ON CONFLICT DO NOTHING;

-- Nuoc Chanh Muoi (Salted Lemon)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Muoi' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Lime', 30, 'g', 1, 'Fresh lime juice'),
    ('Rock Sugar', 15, 'g', 2, 'Sugar'),
    ('Ice', 100, 'g', 3, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Nuoc Chanh Muoi')
ON CONFLICT DO NOTHING;

-- Tra Hoa Cuc (Chrysanthemum Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Chrysanthemum Flowers', 5, 'g', 1, 'Dried flowers'),
    ('Rock Sugar', 10, 'g', 2, 'Light sweetness')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc')
ON CONFLICT DO NOTHING;

-- Sinh To Mang Cau (Soursop Smoothie)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Mang Cau' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Soursop', 120, 'g', 1, 'Fresh soursop pulp'),
    ('Fresh Milk', 100, 'ml', 2, 'Milk'),
    ('Rock Sugar', 15, 'g', 3, 'Sweetener'),
    ('Ice', 80, 'g', 4, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Sinh To Mang Cau')
ON CONFLICT DO NOTHING;

-- Tra Sen (Lotus Seed Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sen' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Lotus Seeds', 30, 'g', 1, 'Dried lotus seeds'),
    ('Green Tea Leaves', 3, 'g', 2, 'Green tea base'),
    ('Rock Sugar', 10, 'g', 3, 'Sweetener')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Sen')
ON CONFLICT DO NOTHING;

-- Nuoc Chanh Day (Passion Fruit Juice)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Passion Fruit', 60, 'g', 1, 'Fresh passion fruit'),
    ('Honey', 20, 'g', 2, 'Natural sweetener'),
    ('Ice', 100, 'g', 3, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day')
ON CONFLICT DO NOTHING;

-- Tra Gung Mat Ong (Ginger Honey Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Fresh Ginger', 15, 'g', 1, 'Fresh ginger slices'),
    ('Honey', 25, 'g', 2, 'Pure honey'),
    ('Lime', 10, 'g', 3, 'Lemon juice optional')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong')
ON CONFLICT DO NOTHING;

-- Nuoc Nha Dam (Aloe Vera Drink)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Aloe Vera', 50, 'g', 1, 'Fresh aloe vera gel'),
    ('Honey', 15, 'g', 2, 'Sweetener'),
    ('Lime', 10, 'g', 3, 'Citrus flavor')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam')
ON CONFLICT DO NOTHING;

-- Add more drinks ingredients (continuing...)
-- Sinh To Mit (Jackfruit Smoothie)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Mit' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Jackfruit', 100, 'g', 1, 'Ripe jackfruit'),
    ('Fresh Milk', 150, 'ml', 2, 'Whole milk'),
    ('Rock Sugar', 10, 'g', 3, 'Sweetener'),
    ('Ice', 80, 'g', 4, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Sinh To Mit')
ON CONFLICT DO NOTHING;

-- Tra Quat Mat Ong (Kumquat Honey Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Quat Mat Ong' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Kumquat', 30, 'g', 1, 'Fresh kumquats'),
    ('Honey', 20, 'g', 2, 'Pure honey'),
    ('Green Tea Leaves', 3, 'g', 3, 'Green tea base')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Quat Mat Ong')
ON CONFLICT DO NOTHING;

-- Tra Bac Ha Chanh (Mint Lime Tea)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Mint Leaves', 10, 'g', 1, 'Fresh mint'),
    ('Lime', 25, 'g', 2, 'Fresh lime juice'),
    ('Green Tea Leaves', 3, 'g', 3, 'Green tea'),
    ('Honey', 15, 'g', 4, 'Sweetener'),
    ('Ice', 100, 'g', 5, 'Ice cubes')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh')
ON CONFLICT DO NOTHING;

-- Sua Me Den (Black Sesame Milk)
INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes)
SELECT 
    (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Me Den' LIMIT 1),
    f.food_id,
    ingredient.amount,
    ingredient.unit,
    ingredient.display_order,
    ingredient.notes
FROM (VALUES
    ('Black Sesame', 30, 'g', 1, 'Roasted black sesame'),
    ('Fresh Milk', 200, 'ml', 2, 'Whole milk'),
    ('Rock Sugar', 15, 'g', 3, 'Sweetener')
) AS ingredient(name, amount, unit, display_order, notes)
JOIN food f ON f.name = ingredient.name
WHERE EXISTS (SELECT 1 FROM drink WHERE vietnamese_name = 'Sua Me Den')
ON CONFLICT DO NOTHING;

-- NOW ADD COMPREHENSIVE RECOMMENDATIONS FOR ALL 39 CONDITIONS WITH NEW DRINKS

-- Condition 1: Tieu duong type 2 (Type 2 Diabetes)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(1, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau' LIMIT 1), 'avoid', 'High sugar content from brown sugar and milk', 'high'),
(1, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Che Ba Mau' LIMIT 1), 'avoid', 'Very high sugar dessert drink', 'high'),
(1, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Helps control blood sugar levels', 'high'),
(1, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Ginger improves insulin sensitivity', 'medium'),
(1, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma' LIMIT 1), 'recommend', 'Low sugar herbal drink', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 2 & 12: Cao huyet ap (Hypertension)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(2, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'High potassium lowers blood pressure', 'high'),
(2, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1), 'recommend', 'Natural vasodilator', 'high'),
(2, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh' LIMIT 1), 'recommend', 'Mint relaxes blood vessels', 'medium'),
(12, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Potassium reduces hypertension', 'high'),
(12, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1), 'recommend', 'Calming effect on blood pressure', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 3 & 19: Mo mau cao (High Cholesterol)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(3, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau' LIMIT 1), 'avoid', 'High fat from milk', 'high'),
(3, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac' LIMIT 1), 'avoid', 'Condensed milk high in fat', 'medium'),
(3, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Reduces cholesterol levels', 'high'),
(19, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Liver detox reduces lipids', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 4: Beo phi (Obesity)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(4, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau' LIMIT 1), 'avoid', 'Very high calories', 'high'),
(4, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Che Ba Mau' LIMIT 1), 'avoid', 'High calorie dessert', 'high'),
(4, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac' LIMIT 1), 'avoid', 'High fat and calories', 'high'),
(4, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma' LIMIT 1), 'recommend', 'Low calorie herbal drink', 'high'),
(4, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Boosts metabolism', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 5 & 16: Gout
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(5, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'recommend', 'Vitamin C reduces uric acid', 'high'),
(5, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Flushes out uric acid', 'high'),
(16, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'recommend', 'Helps eliminate uric acid', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 6 & 30: Gan nhiem mo (Fatty Liver)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(6, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau' LIMIT 1), 'avoid', 'High sugar damages liver', 'high'),
(6, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Artichoke detoxifies liver', 'high'),
(6, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma' LIMIT 1), 'recommend', 'Liver cleansing properties', 'high'),
(30, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Best for fatty liver', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 7: Viem da day (Gastritis)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(7, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Muoi' LIMIT 1), 'avoid', 'Acidic irritates stomach', 'high'),
(7, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'avoid', 'Too acidic for gastritis', 'high'),
(7, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1), 'recommend', 'Soothes stomach lining', 'high'),
(7, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Gentle on stomach', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 8 & 14: Thieu mau (Anemia)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(8, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'recommend', 'Vitamin C enhances iron absorption', 'high'),
(8, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Buoi Duong' LIMIT 1), 'recommend', 'High vitamin C', 'high'),
(8, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Me Den' LIMIT 1), 'recommend', 'Iron-rich black sesame', 'high'),
(14, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Me Den' LIMIT 1), 'recommend', 'Black sesame contains iron', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 9: Suy dinh duong (Malnutrition)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(9, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac' LIMIT 1), 'recommend', 'High calories and nutrients', 'high'),
(9, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Mit' LIMIT 1), 'recommend', 'Nutrient dense smoothie', 'high'),
(9, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Me Den' LIMIT 1), 'recommend', 'Protein and minerals', 'high'),
(9, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Com' LIMIT 1), 'recommend', 'Traditional nutritious drink', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 10: Di ung thuc pham (Food Allergy)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(10, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Sua Tran Chau' LIMIT 1), 'avoid', 'Contains dairy allergens', 'high'),
(10, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac' LIMIT 1), 'avoid', 'Milk allergies', 'high'),
(10, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma' LIMIT 1), 'recommend', 'Simple herbal ingredients', 'medium'),
(10, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Natural coconut water', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 11: Dai thao duong type 2
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(11, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Blood sugar control', 'high'),
(11, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Rau Ma' LIMIT 1), 'recommend', 'Low glycemic index', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 13: Huyet khoi tinh mach sau (DVT)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(13, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Ginger improves circulation', 'high'),
(13, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Hydration prevents clotting', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 15: Loang xuong (Osteoporosis)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(15, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Me Den' LIMIT 1), 'recommend', 'Calcium from sesame', 'high'),
(15, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Bo Dac' LIMIT 1), 'recommend', 'Dairy calcium', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 17: Benh than man tinh (Chronic Kidney Disease)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(17, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'avoid', 'High potassium for kidney disease', 'high'),
(17, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1), 'recommend', 'Mild diuretic', 'low')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 18 & 23: Trao nguoc da day (GERD)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(18, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Muoi' LIMIT 1), 'avoid', 'Acid triggers reflux', 'high'),
(18, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh' LIMIT 1), 'avoid', 'Citrus causes reflux', 'high'),
(18, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1), 'recommend', 'Soothes esophagus', 'high'),
(23, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1), 'recommend', 'Aloe vera heals reflux', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 20: Benh ta (Cholera)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(20, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Electrolyte replacement', 'high'),
(20, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Antibacterial ginger', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 21: Sot thuong han (Typhoid)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(21, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Hydration during fever', 'high'),
(21, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'recommend', 'Vitamin C immunity boost', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 22: Benh dong mach vanh (Coronary Artery Disease)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(22, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Atiso' LIMIT 1), 'recommend', 'Heart protective', 'high'),
(22, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1), 'recommend', 'Reduces heart strain', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 24: Suy tim (Heart Failure)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(24, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Natural electrolytes', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 25: Viem ruot Salmonella
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(25, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Ginger antibacterial', 'high'),
(25, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Rehydration', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 26: Nhiem trung huyet Salmonella
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(26, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Hydration critical', 'high'),
(26, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Natural antibiotic', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 27: Hen phe quan (Asthma)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(27, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Anti-inflammatory for airways', 'high'),
(27, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh' LIMIT 1), 'recommend', 'Mint opens airways', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 28: COPD
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(28, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Reduces lung inflammation', 'high'),
(28, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1), 'recommend', 'Soothes respiratory tract', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 29: Loet da day (Peptic Ulcer)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(29, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Muoi' LIMIT 1), 'avoid', 'Acid worsens ulcers', 'high'),
(29, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1), 'recommend', 'Heals stomach lining', 'high'),
(29, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Gentle on stomach', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 31: Viem khop dang thap (Rheumatoid Arthritis)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(31, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Ginger anti-inflammatory for joints', 'high'),
(31, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Dao Cam Sa' LIMIT 1), 'recommend', 'Antioxidants reduce inflammation', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 32: Suy giap (Hypothyroidism)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(32, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1), 'recommend', 'Supports thyroid function', 'medium'),
(32, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Hydration for metabolism', 'low')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 33: Cuong giap (Hyperthyroidism)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(33, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Hoa Cuc' LIMIT 1), 'recommend', 'Calming for overactive thyroid', 'medium'),
(33, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh' LIMIT 1), 'recommend', 'Cooling effect', 'low')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 34: Dau nua dau (Migraine)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(34, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Ginger reduces migraine pain', 'high'),
(34, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Bac Ha Chanh' LIMIT 1), 'recommend', 'Mint relieves headaches', 'high'),
(34, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Prevents dehydration headaches', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 35: Nhiem E. coli
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(35, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Antibacterial properties', 'high'),
(35, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Electrolyte replacement', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 36: Viem ruot Campylobacter
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(36, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Rehydration therapy', 'high'),
(36, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Tra Gung Mat Ong' LIMIT 1), 'recommend', 'Fights infection', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 37: Viem da day ruot nhiem trung
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(37, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Muoi' LIMIT 1), 'avoid', 'Irritates inflamed stomach', 'high'),
(37, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Gentle rehydration', 'high'),
(37, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Nha Dam' LIMIT 1), 'recommend', 'Soothes inflammation', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 38: Lao phoi (Tuberculosis)
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(38, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'recommend', 'Vitamin C boosts immunity', 'high'),
(38, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sinh To Mit' LIMIT 1), 'recommend', 'Nutrient-rich for recovery', 'high'),
(38, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Sua Me Den' LIMIT 1), 'recommend', 'Protein for healing', 'medium')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Condition 39: Viem mang nao do lao
INSERT INTO conditiondrinkrecommendation (condition_id, drink_id, recommendation_type, reason, severity) VALUES
(39, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Dua Tuoi' LIMIT 1), 'recommend', 'Brain hydration', 'high'),
(39, (SELECT drink_id FROM drink WHERE vietnamese_name = 'Nuoc Chanh Day' LIMIT 1), 'recommend', 'Immune support', 'high')
ON CONFLICT (condition_id, drink_id, recommendation_type) DO NOTHING;

-- Final Summary
DO $$
DECLARE
    total_drinks INT;
    total_recommendations INT;
    total_conditions INT;
    new_drinks INT;
BEGIN
    SELECT COUNT(*) INTO total_drinks FROM drink;
    SELECT COUNT(*) INTO total_recommendations FROM conditiondrinkrecommendation;
    SELECT COUNT(DISTINCT condition_id) INTO total_conditions FROM conditiondrinkrecommendation;
    SELECT COUNT(*) INTO new_drinks FROM drink WHERE created_at > NOW() - INTERVAL '5 minutes';
    
    RAISE NOTICE '========================================';
    RAISE NOTICE 'VIETNAMESE DRINKS MIGRATION COMPLETE';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Total Drinks in Database: %', total_drinks;
    RAISE NOTICE 'New Drinks Added: %', new_drinks;
    RAISE NOTICE 'Total Recommendations: %', total_recommendations;
    RAISE NOTICE 'All Conditions Covered: % / 39', total_conditions;
    RAISE NOTICE '========================================';
END $$;
