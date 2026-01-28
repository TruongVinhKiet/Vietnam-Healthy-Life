-- Seed Vietnamese dishes with ingredients
-- Inserting dishes first
INSERT INTO Dish(name, description, category, portion_size, portion_unit, calories, protein, carbs, fat, fiber, user_id) VALUES
('Pho Bo','Traditional Vietnamese beef noodle soup','Breakfast',1.0,'bowl',450,25,60,10,3,1),
('Banh Mi Thit','Vietnamese baguette with pork','Breakfast',1.0,'piece',400,20,45,15,4,1),
('Com Ga','Steamed chicken with rice','Lunch',1.0,'plate',550,35,70,12,2,1),
('Bun Cha','Grilled pork with vermicelli','Lunch',1.0,'bowl',500,28,55,18,3,1),
('Goi Cuon','Fresh spring rolls','Snack',2.0,'pieces',150,8,20,4,2,1),
('Chao Ga','Chicken rice porridge','Dinner',1.0,'bowl',300,18,45,6,1,1)
ON CONFLICT (name) DO NOTHING;

-- Get the dish IDs for reference
DO $$
DECLARE 
    pho_id INT;
    banh_mi_id INT;
    com_ga_id INT;
    bun_cha_id INT;
    goi_cuon_id INT;
    chao_ga_id INT;
    rice_id INT;
    chicken_id INT;
    pork_id INT;
BEGIN
    -- Get dish IDs
    SELECT dish_id INTO pho_id FROM Dish WHERE name = 'Pho Bo';
    SELECT dish_id INTO banh_mi_id FROM Dish WHERE name = 'Banh Mi Thit';
    SELECT dish_id INTO com_ga_id FROM Dish WHERE name = 'Com Ga';
    SELECT dish_id INTO bun_cha_id FROM Dish WHERE name = 'Bun Cha';
    SELECT dish_id INTO goi_cuon_id FROM Dish WHERE name = 'Goi Cuon';
    SELECT dish_id INTO chao_ga_id FROM Dish WHERE name = 'Chao Ga';
    
    -- Get food IDs (using common foods from our database)
    SELECT food_id INTO rice_id FROM Food WHERE name ILIKE '%rice%' LIMIT 1;
    SELECT food_id INTO chicken_id FROM Food WHERE name ILIKE '%chicken%' LIMIT 1;
    SELECT food_id INTO pork_id FROM Food WHERE name ILIKE '%pork%' LIMIT 1;
    
    -- Insert dish ingredients only if IDs exist
    IF pho_id IS NOT NULL AND rice_id IS NOT NULL THEN
        INSERT INTO DishIngredient(dish_id, food_id, amount, unit)
        VALUES (pho_id, rice_id, 200, 'g')
        ON CONFLICT DO NOTHING;
    END IF;
    
    IF com_ga_id IS NOT NULL AND rice_id IS NOT NULL AND chicken_id IS NOT NULL THEN
        INSERT INTO DishIngredient(dish_id, food_id, amount, unit)
        VALUES 
            (com_ga_id, rice_id, 150, 'g'),
            (com_ga_id, chicken_id, 100, 'g')
        ON CONFLICT DO NOTHING;
    END IF;
    
    IF banh_mi_id IS NOT NULL AND pork_id IS NOT NULL THEN
        INSERT INTO DishIngredient(dish_id, food_id, amount, unit)
        VALUES (banh_mi_id, pork_id, 80, 'g')
        ON CONFLICT DO NOTHING;
    END IF;
    
    IF bun_cha_id IS NOT NULL AND pork_id IS NOT NULL THEN
        INSERT INTO DishIngredient(dish_id, food_id, amount, unit)
        VALUES (bun_cha_id, pork_id, 120, 'g')
        ON CONFLICT DO NOTHING;
    END IF;
    
    IF chao_ga_id IS NOT NULL AND rice_id IS NOT NULL AND chicken_id IS NOT NULL THEN
        INSERT INTO DishIngredient(dish_id, food_id, amount, unit)
        VALUES 
            (chao_ga_id, rice_id, 80, 'g'),
            (chao_ga_id, chicken_id, 80, 'g')
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

SELECT 'Successfully seeded ' || COUNT(*) || ' Vietnamese dishes' FROM Dish WHERE user_id = 1;
