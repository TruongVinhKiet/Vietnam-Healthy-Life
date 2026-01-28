BEGIN;

ALTER TABLE Food ADD COLUMN IF NOT EXISTS name_vi TEXT;
ALTER TABLE Food ADD COLUMN IF NOT EXISTS serving_size_g NUMERIC(10,2) DEFAULT 100.00;

 UPDATE Food SET name_vi = name WHERE name_vi IS NULL;
 
 UPDATE Food SET name_vi = 'Mật ong'
 WHERE lower(trim(name)) = 'honey'
   AND (name_vi IS NULL OR lower(trim(name_vi)) = 'mat ong');
 
 UPDATE Food SET name_vi = 'Gừng tươi'
 WHERE lower(trim(name)) = 'fresh ginger'
   AND (name_vi IS NULL OR lower(trim(name_vi)) = 'gung tuoi');
 
 UPDATE Food SET name_vi = 'Lá trà xanh'
 WHERE lower(trim(name)) = 'green tea leaves'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('la tra xanh','lá trà xanh'));
 
 UPDATE Food SET name_vi = 'Lá trà đen'
 WHERE lower(trim(name)) = 'black tea leaves'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('la trà den','la tra den','lá trà den','lá trà đen'));
 
 UPDATE Food SET name_vi = 'Sữa đặc'
 WHERE lower(trim(name)) = 'condensed milk'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('sua dac','sữa đặc','sữa dac'));
 
 UPDATE Food SET name_vi = 'Sữa tươi'
 WHERE lower(trim(name)) = 'fresh milk'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('sua tuoi','sữa tươi','sữa tuoi'));
 
 UPDATE Food SET name_vi = 'Trân châu'
 WHERE lower(trim(name)) = 'tapioca pearls'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('tran chau','trân châu'));
 
 UPDATE Food SET name_vi = 'Cà phê (hạt)'
 WHERE lower(trim(name)) = 'coffee beans'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('ca phe hat','cà phê hạt','cà phê hat'));
 
 UPDATE Food SET name_vi = 'Đá viên'
 WHERE lower(trim(name)) = 'ice'
   AND (name_vi IS NULL OR lower(trim(name_vi)) IN ('da','đá','đá viên','da vien'));
 
 CREATE OR REPLACE FUNCTION seed_pick_food_id(p_names text[]) RETURNS int AS $$
 DECLARE
   v_id int;
   v_name text;
 BEGIN
   IF p_names IS NULL THEN
     RETURN NULL;
   END IF;
 
   FOREACH v_name IN ARRAY p_names LOOP
     IF v_name IS NULL OR length(trim(v_name)) = 0 THEN
       CONTINUE;
     END IF;
 
     SELECT f.food_id
       INTO v_id
     FROM Food f
     WHERE lower(trim(f.name)) = lower(trim(v_name))
        OR (f.name_vi IS NOT NULL AND lower(trim(f.name_vi)) = lower(trim(v_name)))
     ORDER BY (EXISTS (SELECT 1 FROM FoodNutrient fn WHERE fn.food_id = f.food_id)) DESC, f.food_id
     LIMIT 1;
 
     IF v_id IS NOT NULL THEN
       RETURN v_id;
     END IF;
 
     IF length(trim(v_name)) >= 4 THEN
       SELECT f.food_id
         INTO v_id
       FROM Food f
       WHERE f.name ILIKE '%' || trim(v_name) || '%'
          OR (f.name_vi IS NOT NULL AND f.name_vi ILIKE '%' || trim(v_name) || '%')
       ORDER BY (EXISTS (SELECT 1 FROM FoodNutrient fn WHERE fn.food_id = f.food_id)) DESC, f.food_id
       LIMIT 1;
 
       IF v_id IS NOT NULL THEN
         RETURN v_id;
       END IF;
     END IF;
   END LOOP;
 
   RETURN NULL;
 END;
 $$ LANGUAGE plpgsql;
 
 CREATE OR REPLACE FUNCTION seed_ensure_food(
   p_name text,
   p_name_vi text,
   p_category text,
   p_serving_size_g numeric,
   p_admin_id int,
   p_aliases text[]
 ) RETURNS int AS $$
 DECLARE
   v_id int;
   v_names text[];
 BEGIN
   v_names := COALESCE(p_aliases, ARRAY[]::text[]);
   v_names := v_names || ARRAY[p_name, p_name_vi];
 
   v_id := seed_pick_food_id(v_names);
 
   IF v_id IS NULL THEN
     INSERT INTO Food(name, name_vi, category, serving_size_g, created_by_admin)
     SELECT p_name,
            COALESCE(NULLIF(trim(p_name_vi), ''), p_name),
            p_category,
            COALESCE(p_serving_size_g, 100.00),
            p_admin_id
     WHERE NOT EXISTS (
       SELECT 1
       FROM Food f
       WHERE lower(trim(f.name)) = lower(trim(p_name))
          OR (
            p_name_vi IS NOT NULL
            AND f.name_vi IS NOT NULL
            AND lower(trim(f.name_vi)) = lower(trim(p_name_vi))
          )
     )
     RETURNING food_id INTO v_id;
 
     IF v_id IS NULL THEN
       v_id := seed_pick_food_id(v_names);
     END IF;
   END IF;
 
   IF v_id IS NOT NULL THEN
     UPDATE Food
     SET name_vi = COALESCE(NULLIF(trim(p_name_vi), ''), name_vi, name),
         category = COALESCE(p_category, category),
         serving_size_g = COALESCE(p_serving_size_g, serving_size_g),
         created_by_admin = COALESCE(created_by_admin, p_admin_id)
     WHERE food_id = v_id;
   END IF;
 
   RETURN v_id;
 END;
 $$ LANGUAGE plpgsql;
 
 DO $$
 DECLARE
   v_admin_id int;
   v_has_dish boolean;
   v_has_drink boolean;
   v_food_water int;
   v_food_ice int;
   v_food_bread int;
   v_food_sugar int;
   v_food_fish_sauce int;
   v_food_lime int;
   v_food_onion int;
   v_food_scallion int;
   v_food_herbs int;
   v_food_beansprout int;
   v_food_lettuce int;
   v_food_cucumber int;
   v_food_tomato int;
   v_food_carrot int;
   v_food_daikon int;
   v_food_rice int;
   v_food_rice_noodle int;
   v_food_vermicelli int;
   v_food_rice_paper int;
   v_food_beef int;
   v_food_chicken int;
   v_food_pork int;
   v_food_fish int;
   v_food_shrimp int;
   v_food_egg int;
   v_food_pate int;
   v_food_pineapple int;
   v_food_water_spinach int;
   v_food_glass_noodles int;
   v_food_lemongrass int;
   v_food_condensed_milk int;
   v_food_fresh_milk int;
   v_food_black_tea int;
   v_food_green_tea int;
   v_food_tapioca int;
   v_food_coffee int;
   v_food_orange int;
   v_food_watermelon int;
   v_food_mango int;
   v_food_avocado int;
   v_food_yogurt int;
   v_food_coconut_water int;
 
   v_dish_id int;
   v_drink_id int;
 BEGIN
   SELECT admin_id INTO v_admin_id FROM Admin ORDER BY admin_id LIMIT 1;
 
   v_has_dish := (to_regclass('dish') IS NOT NULL) AND (to_regclass('dishingredient') IS NOT NULL);
   v_has_drink := (to_regclass('drink') IS NOT NULL) AND (to_regclass('drinkingredient') IS NOT NULL);
 
   IF v_admin_id IS NULL THEN
     INSERT INTO Admin(username, password_hash)
     VALUES ('seed-admin', '$2b$10$u6xD8l8twmkO7l1zM0bQme1k7kT3GQWqG9wR4xqv5xwKqGq6i2B2a')
     ON CONFLICT (username) DO UPDATE
       SET password_hash = EXCLUDED.password_hash
     RETURNING admin_id INTO v_admin_id;
 
     IF v_admin_id IS NULL THEN
       SELECT admin_id INTO v_admin_id FROM Admin WHERE username = 'seed-admin' LIMIT 1;
     END IF;
   END IF;
 
   v_food_water := seed_ensure_food('Filtered Water', 'Nước lọc', 'Beverages', 250, v_admin_id, ARRAY['Nước lọc','Nuoc loc','Water']);
   v_food_ice := seed_ensure_food('Ice', 'Đá viên', 'Beverages', 100, v_admin_id, ARRAY['Đá','Da','Da vien']);
   v_food_bread := seed_ensure_food('Bread', 'Bánh mì', 'Grains', 100, v_admin_id, ARRAY['Bánh mì','Banh mi','Vietnamese baguette','Baguette']);
   v_food_sugar := seed_ensure_food('Sugar', 'Đường', 'Condiments', 10, v_admin_id, ARRAY['Đường','Duong','Brown Sugar','Rock Sugar']);
   v_food_fish_sauce := seed_ensure_food('Fish Sauce', 'Nước mắm', 'Condiments', 15, v_admin_id, ARRAY['Nước mắm','Nuoc mam']);
   v_food_lime := seed_ensure_food('Lime', 'Chanh', 'Fruits', 30, v_admin_id, ARRAY['Chanh','Lemon']);
   v_food_onion := seed_ensure_food('Onion', 'Hành tây', 'Vegetables', 50, v_admin_id, ARRAY['Hành tây','Hanh tay']);
   v_food_scallion := seed_ensure_food('Scallion', 'Hành lá', 'Vegetables', 20, v_admin_id, ARRAY['Hành lá','Hanh la']);
   v_food_herbs := seed_ensure_food('Mixed Herbs', 'Rau thơm', 'Vegetables', 20, v_admin_id, ARRAY['Rau thơm','Rau thom','Herbs']);
   v_food_beansprout := seed_ensure_food('Bean Sprouts', 'Giá đỗ', 'Vegetables', 50, v_admin_id, ARRAY['Giá','Gia do','Bean sprouts']);
   v_food_lettuce := seed_ensure_food('Lettuce', 'Xà lách', 'Vegetables', 50, v_admin_id, ARRAY['Xà lách','Xa lach','Lettuce']);
   v_food_cucumber := seed_ensure_food('Cucumber', 'Dưa chuột', 'Vegetables', 100, v_admin_id, ARRAY['Dưa chuột','Dua chuot','Dưa leo','Dua leo']);
   v_food_tomato := seed_ensure_food('Tomato', 'Cà chua', 'Vegetables', 100, v_admin_id, ARRAY['Cà chua','Ca chua','Tomatoes']);
   v_food_carrot := seed_ensure_food('Carrot', 'Cà rốt', 'Vegetables', 100, v_admin_id, ARRAY['Cà rốt','Ca rot']);
   v_food_daikon := seed_ensure_food('Daikon', 'Củ cải trắng', 'Vegetables', 100, v_admin_id, ARRAY['Củ cải','Cu cai']);
   v_food_rice := seed_ensure_food('White Rice', 'Cơm trắng', 'Grains', 100, v_admin_id, ARRAY['Cơm trắng','Com trang','Gạo trắng','Gao']);
   v_food_rice_noodle := seed_ensure_food('Rice Noodles', 'Bánh phở', 'Grains', 100, v_admin_id, ARRAY['Bánh phở','Banh pho','Pho','Phở']);
   v_food_vermicelli := seed_ensure_food('Rice Vermicelli', 'Bún', 'Grains', 100, v_admin_id, ARRAY['Bún','Bun','Vermicelli']);
   v_food_rice_paper := seed_ensure_food('Rice Paper', 'Bánh tráng', 'Grains', 30, v_admin_id, ARRAY['Bánh tráng','Banh trang','Rice paper']);
   v_food_beef := seed_ensure_food('Beef', 'Thịt bò', 'Protein Foods', 100, v_admin_id, ARRAY['Thịt bò','Bo','Beef']);
   v_food_chicken := seed_ensure_food('Chicken', 'Thịt gà', 'Protein Foods', 100, v_admin_id, ARRAY['Thịt gà','Ga','Chicken breast']);
   v_food_pork := seed_ensure_food('Pork', 'Thịt lợn', 'Protein Foods', 100, v_admin_id, ARRAY['Thịt lợn','Thịt heo','Heo','Pork']);
   v_food_fish := seed_ensure_food('Fish', 'Cá', 'Protein Foods', 100, v_admin_id, ARRAY['Cá','Ca','Fish']);
   v_food_shrimp := seed_ensure_food('Shrimp', 'Tôm', 'Protein Foods', 100, v_admin_id, ARRAY['Tôm','Tom','Shrimp']);
   v_food_egg := seed_ensure_food('Egg', 'Trứng gà', 'Protein Foods', 50, v_admin_id, ARRAY['Trứng gà','Eggs']);
   v_food_pate := seed_ensure_food('Pate', 'Pate', 'Protein Foods', 15, v_admin_id, ARRAY['Pate','Pâté']);

   v_food_pineapple := seed_ensure_food('Pineapple', 'Dứa', 'Fruits', 150, v_admin_id, ARRAY['Dứa','Dua','Thơm','Pineapple']);
   v_food_water_spinach := seed_ensure_food('Water Spinach', 'Rau muống', 'Vegetables', 100, v_admin_id, ARRAY['Rau muống','Rau muong','Morning glory']);
   v_food_glass_noodles := seed_ensure_food('Glass Noodles', 'Miến', 'Grains', 100, v_admin_id, ARRAY['Miến','Mien','Glass noodles']);
   v_food_lemongrass := seed_ensure_food('Lemongrass', 'Sả', 'Herbs', 10, v_admin_id, ARRAY['Sả','Sa','Lemongrass']);
 
   v_food_condensed_milk := seed_ensure_food('Condensed Milk', 'Sữa đặc', 'Dairy', 30, v_admin_id, ARRAY['Sữa đặc','Sua dac']);
   v_food_fresh_milk := seed_ensure_food('Fresh Milk', 'Sữa tươi', 'Dairy', 200, v_admin_id, ARRAY['Sữa tươi','Sua tuoi','Sữa bò']);
   v_food_black_tea := seed_ensure_food('Black Tea Leaves', 'Lá trà đen', 'Beverage Ingredients', 2, v_admin_id, ARRAY['Trà đen','Tra den']);
   v_food_green_tea := seed_ensure_food('Green Tea Leaves', 'Lá trà xanh', 'Beverage Ingredients', 2, v_admin_id, ARRAY['Trà xanh','Tra xanh']);
   v_food_tapioca := seed_ensure_food('Tapioca Pearls', 'Trân châu', 'Dessert', 50, v_admin_id, ARRAY['Trân châu','Tran chau']);
   v_food_coffee := seed_ensure_food('Coffee Beans', 'Cà phê (hạt)', 'Beverage Ingredients', 15, v_admin_id, ARRAY['Cà phê','Ca phe','Coffee']);

   v_food_orange := seed_ensure_food('Orange', 'Cam', 'Fruits', 150, v_admin_id, ARRAY['Cam','Cam tươi','Orange','Oranges']);
   v_food_watermelon := seed_ensure_food('Watermelon', 'Dưa hấu', 'Fruits', 200, v_admin_id, ARRAY['Dưa hấu','Dua hau','Watermelon']);
   v_food_mango := seed_ensure_food('Mango', 'Xoài', 'Fruits', 150, v_admin_id, ARRAY['Xoài','Xoai','Mango']);
   v_food_avocado := seed_ensure_food('Avocado', 'Bơ', 'Fruits', 100, v_admin_id, ARRAY['Bơ','Bo','Avocado']);
   v_food_yogurt := seed_ensure_food('Yogurt', 'Sữa chua', 'Dairy', 150, v_admin_id, ARRAY['Sữa chua','Sua chua','Yoghurt','Yogurt']);
   v_food_coconut_water := seed_ensure_food('Coconut Water', 'Nước dừa tươi', 'Beverages', 250, v_admin_id, ARRAY['Nước dừa','Nuoc dua','Coconut water']);
 
   IF v_has_dish THEN
     SELECT dish_id INTO v_dish_id
     FROM Dish
     WHERE vietnamese_name IN ('Phở Bò', 'Pho Bo')
        OR name ILIKE '%Beef Pho%'
     ORDER BY dish_id
     LIMIT 1;
 
     IF v_dish_id IS NULL THEN
       INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
       VALUES ('Beef Pho', 'Phở Bò', 'Traditional Vietnamese beef noodle soup', 'noodle', 600, TRUE, TRUE, v_admin_id)
       RETURNING dish_id INTO v_dish_id;
     ELSE
       UPDATE Dish
       SET name = 'Beef Pho',
           vietnamese_name = 'Phở Bò',
           description = 'Traditional Vietnamese beef noodle soup',
           category = 'noodle',
           serving_size_g = 600,
           is_template = TRUE,
           is_public = TRUE,
           created_by_admin = COALESCE(created_by_admin, v_admin_id)
       WHERE dish_id = v_dish_id;
     END IF;
 
     DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
     INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
     VALUES
       (v_dish_id, v_food_rice_noodle, 200, 'Rice noodles', 1),
       (v_dish_id, v_food_beef, 100, 'Beef slices', 2),
       (v_dish_id, v_food_onion, 30, 'Onion', 3),
       (v_dish_id, v_food_beansprout, 30, 'Bean sprouts', 4),
       (v_dish_id, v_food_herbs, 20, 'Fresh herbs', 5)
     ON CONFLICT (dish_id, food_id) DO UPDATE
     SET weight_g = EXCLUDED.weight_g,
         notes = EXCLUDED.notes,
         display_order = EXCLUDED.display_order;
 
     IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
       PERFORM calculate_dish_nutrients(v_dish_id);
     END IF;

   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Phở Gà', 'Pho Ga')
      OR name ILIKE '%Chicken Pho%'
   ORDER BY dish_id
   LIMIT 1;
 
   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Chicken Pho', 'Phở Gà', 'Light Vietnamese chicken noodle soup', 'noodle', 550, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Chicken Pho',
         vietnamese_name = 'Phở Gà',
         description = 'Light Vietnamese chicken noodle soup',
         category = 'noodle',
         serving_size_g = 550,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;
 
   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_rice_noodle, 200, 'Rice noodles', 1),
     (v_dish_id, v_food_chicken, 120, 'Chicken', 2),
     (v_dish_id, v_food_onion, 20, 'Onion', 3),
     (v_dish_id, v_food_beansprout, 30, 'Bean sprouts', 4),
     (v_dish_id, v_food_herbs, 20, 'Fresh herbs', 5)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;
 
   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;
 
   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Bánh Mì', 'Banh Mi')
      OR name ILIKE '%Baguette%'
   ORDER BY dish_id
   LIMIT 1;
 
   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Banh Mi', 'Bánh Mì', 'Vietnamese baguette sandwich', 'sandwich', 250, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Banh Mi',
         vietnamese_name = 'Bánh Mì',
         description = 'Vietnamese baguette sandwich',
         category = 'sandwich',
         serving_size_g = 250,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;
 
   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_bread, 100, 'Baguette', 1),
     (v_dish_id, v_food_pork, 60, 'Pork', 2),
     (v_dish_id, v_food_pate, 15, 'Pate', 3),
     (v_dish_id, v_food_carrot, 20, 'Pickled carrot', 4),
     (v_dish_id, v_food_daikon, 20, 'Pickled daikon', 5),
     (v_dish_id, v_food_cucumber, 20, 'Cucumber', 6),
     (v_dish_id, v_food_herbs, 10, 'Herbs', 7)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;
 
   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;
 
   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Cơm Tấm Sườn', 'Com Tam Suon', 'Com Tam')
      OR name ILIKE '%Broken Rice%'
   ORDER BY dish_id
   LIMIT 1;
 
   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Com Tam Suon', 'Cơm Tấm Sườn', 'Broken rice with grilled pork and egg', 'rice', 450, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Com Tam Suon',
         vietnamese_name = 'Cơm Tấm Sườn',
         description = 'Broken rice with grilled pork and egg',
         category = 'rice',
         serving_size_g = 450,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;
 
   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_rice, 200, 'Rice', 1),
     (v_dish_id, v_food_pork, 120, 'Grilled pork', 2),
     (v_dish_id, v_food_egg, 50, 'Egg', 3),
     (v_dish_id, v_food_cucumber, 20, 'Cucumber', 4),
     (v_dish_id, v_food_tomato, 20, 'Tomato', 5),
     (v_dish_id, v_food_fish_sauce, 15, 'Fish sauce', 6)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;
 
   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;
 
   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Bún Chả', 'Bun Cha')
      OR name ILIKE '%Bun Cha%'
   ORDER BY dish_id
   LIMIT 1;
 
   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Bun Cha', 'Bún Chả', 'Grilled pork with vermicelli', 'noodle', 500, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Bun Cha',
         vietnamese_name = 'Bún Chả',
         description = 'Grilled pork with vermicelli',
         category = 'noodle',
         serving_size_g = 500,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;
 
   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_vermicelli, 180, 'Vermicelli', 1),
     (v_dish_id, v_food_pork, 120, 'Grilled pork', 2),
     (v_dish_id, v_food_cucumber, 30, 'Cucumber', 3),
     (v_dish_id, v_food_herbs, 30, 'Herbs', 4),
     (v_dish_id, v_food_fish_sauce, 20, 'Fish sauce', 5),
     (v_dish_id, v_food_sugar, 10, 'Sugar', 6)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;
 
   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;
 
   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Gỏi cuốn', 'Goi Cuon')
      OR name ILIKE '%Spring Roll%'
   ORDER BY dish_id
   LIMIT 1;
 
   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Goi Cuon', 'Gỏi cuốn', 'Fresh spring rolls', 'snack', 250, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Goi Cuon',
         vietnamese_name = 'Gỏi cuốn',
         description = 'Fresh spring rolls',
         category = 'snack',
         serving_size_g = 250,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;
 
   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_rice_paper, 20, 'Rice paper', 1),
     (v_dish_id, v_food_vermicelli, 60, 'Vermicelli', 2),
     (v_dish_id, v_food_shrimp, 60, 'Shrimp', 3),
     (v_dish_id, v_food_pork, 40, 'Pork', 4),
     (v_dish_id, v_food_lettuce, 40, 'Lettuce', 5),
     (v_dish_id, v_food_herbs, 20, 'Herbs', 6)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;
 
   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;

   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Bún Bò Huế', 'Bun Bo Hue')
      OR name ILIKE '%Bun Bo Hue%'
   ORDER BY dish_id
   LIMIT 1;

   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Bun Bo Hue', 'Bún Bò Huế', 'Spicy beef and pork noodle soup from Hue', 'noodle', 650, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Bun Bo Hue',
         vietnamese_name = 'Bún Bò Huế',
         description = 'Spicy beef and pork noodle soup from Hue',
         category = 'noodle',
         serving_size_g = 650,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;

   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_vermicelli, 200, 'Round rice vermicelli', 1),
     (v_dish_id, v_food_beef, 90, 'Beef', 2),
     (v_dish_id, v_food_pork, 60, 'Pork', 3),
     (v_dish_id, v_food_lemongrass, 10, 'Lemongrass', 4),
     (v_dish_id, v_food_herbs, 30, 'Herbs', 5)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;

   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;

   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Chả giò', 'Cha Gio')
      OR name ILIKE '%Spring Roll%'
      OR name ILIKE '%Fried Roll%'
   ORDER BY dish_id
   LIMIT 1;

   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Cha Gio', 'Chả giò', 'Crispy fried spring rolls', 'snack', 250, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Cha Gio',
         vietnamese_name = 'Chả giò',
         description = 'Crispy fried spring rolls',
         category = 'snack',
         serving_size_g = 250,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;

   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_rice_paper, 25, 'Rice paper wrappers', 1),
     (v_dish_id, v_food_pork, 90, 'Pork', 2),
     (v_dish_id, v_food_shrimp, 40, 'Shrimp', 3),
     (v_dish_id, v_food_glass_noodles, 40, 'Glass noodles', 4),
     (v_dish_id, v_food_carrot, 30, 'Carrot', 5),
     (v_dish_id, v_food_onion, 25, 'Onion', 6)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;

   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;

   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Cơm Gà', 'Com Ga')
      OR name ILIKE '%Chicken Rice%'
   ORDER BY dish_id
   LIMIT 1;

   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Com Ga', 'Cơm Gà', 'Steamed chicken with rice', 'rice', 450, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Com Ga',
         vietnamese_name = 'Cơm Gà',
         description = 'Steamed chicken with rice',
         category = 'rice',
         serving_size_g = 450,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;

   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_rice, 200, 'Rice', 1),
     (v_dish_id, v_food_chicken, 140, 'Chicken', 2),
     (v_dish_id, v_food_cucumber, 30, 'Cucumber', 3),
     (v_dish_id, v_food_fish_sauce, 15, 'Fish sauce', 4),
     (v_dish_id, v_food_herbs, 20, 'Herbs', 5)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;

   IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
     PERFORM calculate_dish_nutrients(v_dish_id);
   END IF;

   SELECT dish_id INTO v_dish_id
   FROM Dish
   WHERE vietnamese_name IN ('Canh chua', 'Canh Chua')
      OR name ILIKE '%Sour Soup%'
   ORDER BY dish_id
   LIMIT 1;

   IF v_dish_id IS NULL THEN
     INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
     VALUES ('Canh Chua', 'Canh chua', 'Sweet and sour fish soup', 'soup', 450, TRUE, TRUE, v_admin_id)
     RETURNING dish_id INTO v_dish_id;
   ELSE
     UPDATE Dish
     SET name = 'Canh Chua',
         vietnamese_name = 'Canh chua',
         description = 'Sweet and sour fish soup',
         category = 'soup',
         serving_size_g = 450,
         is_template = TRUE,
         is_public = TRUE,
         created_by_admin = COALESCE(created_by_admin, v_admin_id)
     WHERE dish_id = v_dish_id;
   END IF;

   DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
   INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
   VALUES
     (v_dish_id, v_food_fish, 120, 'Fish', 1),
     (v_dish_id, v_food_tomato, 80, 'Tomato', 2),
     (v_dish_id, v_food_pineapple, 60, 'Pineapple', 3),
     (v_dish_id, v_food_water_spinach, 80, 'Water spinach', 4),
     (v_dish_id, v_food_herbs, 20, 'Herbs', 5)
   ON CONFLICT (dish_id, food_id) DO UPDATE
   SET weight_g = EXCLUDED.weight_g,
       notes = EXCLUDED.notes,
       display_order = EXCLUDED.display_order;

    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
      PERFORM calculate_dish_nutrients(v_dish_id);
    END IF;

    SELECT dish_id INTO v_dish_id
    FROM Dish
    WHERE vietnamese_name IN ('Hủ Tiếu Nam Vang', 'Hu Tieu Nam Vang')
       OR name ILIKE '%Hu Tieu%'
    ORDER BY dish_id
    LIMIT 1;

    IF v_dish_id IS NULL THEN
      INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
      VALUES ('Hu Tieu Nam Vang', 'Hủ Tiếu Nam Vang', 'Southern-style noodle soup with pork, shrimp and herbs', 'noodle', 600, TRUE, TRUE, v_admin_id)
      RETURNING dish_id INTO v_dish_id;
    ELSE
      UPDATE Dish
      SET name = 'Hu Tieu Nam Vang',
          vietnamese_name = 'Hủ Tiếu Nam Vang',
          description = 'Southern-style noodle soup with pork, shrimp and herbs',
          category = 'noodle',
          serving_size_g = 600,
          is_template = TRUE,
          is_public = TRUE,
          created_by_admin = COALESCE(created_by_admin, v_admin_id)
      WHERE dish_id = v_dish_id;
    END IF;

    DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
    INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
    VALUES
      (v_dish_id, v_food_rice_noodle, 200, 'Rice noodles', 1),
      (v_dish_id, v_food_pork, 80, 'Pork', 2),
      (v_dish_id, v_food_shrimp, 60, 'Shrimp', 3),
      (v_dish_id, v_food_onion, 20, 'Onion', 4),
      (v_dish_id, v_food_beansprout, 30, 'Bean sprouts', 5),
      (v_dish_id, v_food_herbs, 20, 'Herbs', 6)
    ON CONFLICT (dish_id, food_id) DO UPDATE
    SET weight_g = EXCLUDED.weight_g,
        notes = EXCLUDED.notes,
        display_order = EXCLUDED.display_order;

    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
      PERFORM calculate_dish_nutrients(v_dish_id);
    END IF;

    SELECT dish_id INTO v_dish_id
    FROM Dish
    WHERE vietnamese_name IN ('Bò Kho', 'Bo Kho')
       OR name ILIKE '%Beef Stew%'
       OR name ILIKE '%Bo Kho%'
    ORDER BY dish_id
    LIMIT 1;

    IF v_dish_id IS NULL THEN
      INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
      VALUES ('Bo Kho', 'Bò Kho', 'Vietnamese beef stew served with bread', 'soup', 500, TRUE, TRUE, v_admin_id)
      RETURNING dish_id INTO v_dish_id;
    ELSE
      UPDATE Dish
      SET name = 'Bo Kho',
          vietnamese_name = 'Bò Kho',
          description = 'Vietnamese beef stew served with bread',
          category = 'soup',
          serving_size_g = 500,
          is_template = TRUE,
          is_public = TRUE,
          created_by_admin = COALESCE(created_by_admin, v_admin_id)
      WHERE dish_id = v_dish_id;
    END IF;

    DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
    INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
    VALUES
      (v_dish_id, v_food_beef, 140, 'Beef', 1),
      (v_dish_id, v_food_carrot, 60, 'Carrot', 2),
      (v_dish_id, v_food_onion, 40, 'Onion', 3),
      (v_dish_id, v_food_lemongrass, 10, 'Lemongrass', 4),
      (v_dish_id, v_food_bread, 80, 'Bread', 5)
    ON CONFLICT (dish_id, food_id) DO UPDATE
    SET weight_g = EXCLUDED.weight_g,
        notes = EXCLUDED.notes,
        display_order = EXCLUDED.display_order;

    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
      PERFORM calculate_dish_nutrients(v_dish_id);
    END IF;

    SELECT dish_id INTO v_dish_id
    FROM Dish
    WHERE vietnamese_name IN ('Thịt Kho Tàu', 'Thit Kho Tau')
       OR name ILIKE '%Braised Pork%'
       OR name ILIKE '%Thit Kho%'
    ORDER BY dish_id
    LIMIT 1;

    IF v_dish_id IS NULL THEN
      INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
      VALUES ('Thit Kho Tau', 'Thịt Kho Tàu', 'Braised pork with egg', 'main_dish', 400, TRUE, TRUE, v_admin_id)
      RETURNING dish_id INTO v_dish_id;
    ELSE
      UPDATE Dish
      SET name = 'Thit Kho Tau',
          vietnamese_name = 'Thịt Kho Tàu',
          description = 'Braised pork with egg',
          category = 'main_dish',
          serving_size_g = 400,
          is_template = TRUE,
          is_public = TRUE,
          created_by_admin = COALESCE(created_by_admin, v_admin_id)
      WHERE dish_id = v_dish_id;
    END IF;

    DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
    INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
    VALUES
      (v_dish_id, v_food_pork, 160, 'Pork', 1),
      (v_dish_id, v_food_egg, 50, 'Egg', 2),
      (v_dish_id, v_food_sugar, 10, 'Sugar', 3),
      (v_dish_id, v_food_fish_sauce, 15, 'Fish sauce', 4),
      (v_dish_id, v_food_rice, 165, 'Rice', 5)
    ON CONFLICT (dish_id, food_id) DO UPDATE
    SET weight_g = EXCLUDED.weight_g,
        notes = EXCLUDED.notes,
        display_order = EXCLUDED.display_order;

    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
      PERFORM calculate_dish_nutrients(v_dish_id);
    END IF;

    SELECT dish_id INTO v_dish_id
    FROM Dish
    WHERE vietnamese_name IN ('Cá Kho Tộ', 'Ca Kho To')
       OR name ILIKE '%Braised Fish%'
       OR name ILIKE '%Ca Kho%'
    ORDER BY dish_id
    LIMIT 1;

    IF v_dish_id IS NULL THEN
      INSERT INTO Dish(name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin)
      VALUES ('Ca Kho To', 'Cá Kho Tộ', 'Braised fish served with rice', 'main_dish', 400, TRUE, TRUE, v_admin_id)
      RETURNING dish_id INTO v_dish_id;
    ELSE
      UPDATE Dish
      SET name = 'Ca Kho To',
          vietnamese_name = 'Cá Kho Tộ',
          description = 'Braised fish served with rice',
          category = 'main_dish',
          serving_size_g = 400,
          is_template = TRUE,
          is_public = TRUE,
          created_by_admin = COALESCE(created_by_admin, v_admin_id)
      WHERE dish_id = v_dish_id;
    END IF;

    DELETE FROM DishIngredient WHERE dish_id = v_dish_id;
    INSERT INTO DishIngredient(dish_id, food_id, weight_g, notes, display_order)
    VALUES
      (v_dish_id, v_food_fish, 160, 'Fish', 1),
      (v_dish_id, v_food_fish_sauce, 15, 'Fish sauce', 2),
      (v_dish_id, v_food_sugar, 10, 'Sugar', 3),
      (v_dish_id, v_food_rice, 215, 'Rice', 4)
    ON CONFLICT (dish_id, food_id) DO UPDATE
    SET weight_g = EXCLUDED.weight_g,
        notes = EXCLUDED.notes,
        display_order = EXCLUDED.display_order;

    IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_dish_nutrients') THEN
      PERFORM calculate_dish_nutrients(v_dish_id);
    END IF;
  END IF;

  IF v_has_drink THEN
    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'nuoc-chanh' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_water, 180, 'ml', 1, 'Water'),
        (v_drink_id, v_food_lime, 30, 'g', 2, 'Lime'),
        (v_drink_id, v_food_sugar, 15, 'g', 3, 'Sugar'),
        (v_drink_id, v_food_ice, 50, 'g', 4, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'ca-phe-sua-da' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_coffee, 15, 'g', 1, 'Coffee'),
        (v_drink_id, v_food_condensed_milk, 30, 'g', 2, 'Condensed milk'),
        (v_drink_id, v_food_water, 80, 'ml', 3, 'Water'),
        (v_drink_id, v_food_ice, 80, 'g', 4, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'tra-xanh' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_green_tea, 2, 'g', 1, 'Tea leaves'),
        (v_drink_id, v_food_water, 200, 'ml', 2, 'Water')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'tra-sua-tran-chau' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_black_tea, 5, 'g', 1, 'Black tea'),
        (v_drink_id, v_food_fresh_milk, 150, 'ml', 2, 'Milk'),
        (v_drink_id, v_food_tapioca, 50, 'g', 3, 'Tapioca pearls'),
        (v_drink_id, v_food_sugar, 20, 'g', 4, 'Sugar'),
        (v_drink_id, v_food_ice, 100, 'g', 5, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'nuoc-cam' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_orange, 200, 'g', 1, 'Orange'),
        (v_drink_id, v_food_water, 50, 'ml', 2, 'Water'),
        (v_drink_id, v_food_ice, 50, 'g', 3, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'nuoc-dua-hau' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_watermelon, 250, 'g', 1, 'Watermelon'),
        (v_drink_id, v_food_ice, 50, 'g', 2, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'sinh-to-xoai' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_mango, 160, 'g', 1, 'Mango'),
        (v_drink_id, v_food_fresh_milk, 120, 'ml', 2, 'Milk'),
        (v_drink_id, v_food_sugar, 10, 'g', 3, 'Sugar'),
        (v_drink_id, v_food_ice, 80, 'g', 4, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'sinh-to-bo' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_avocado, 120, 'g', 1, 'Avocado'),
        (v_drink_id, v_food_condensed_milk, 25, 'g', 2, 'Condensed milk'),
        (v_drink_id, v_food_fresh_milk, 120, 'ml', 3, 'Milk'),
        (v_drink_id, v_food_ice, 80, 'g', 4, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'yaourt-uong' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_yogurt, 160, 'g', 1, 'Yogurt'),
        (v_drink_id, v_food_sugar, 10, 'g', 2, 'Sugar'),
        (v_drink_id, v_food_water, 80, 'ml', 3, 'Water')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;

    SELECT drink_id INTO v_drink_id FROM Drink WHERE slug = 'nuoc-dua' LIMIT 1;
    IF v_drink_id IS NOT NULL THEN
      DELETE FROM DrinkIngredient WHERE drink_id = v_drink_id;
      INSERT INTO DrinkIngredient(drink_id, food_id, amount_g, unit, display_order, notes)
      VALUES
        (v_drink_id, v_food_coconut_water, 200, 'ml', 1, 'Coconut water'),
        (v_drink_id, v_food_ice, 50, 'g', 2, 'Ice')
      ON CONFLICT (drink_id, food_id) DO UPDATE
      SET amount_g = EXCLUDED.amount_g,
          unit = EXCLUDED.unit,
          display_order = EXCLUDED.display_order,
          notes = EXCLUDED.notes;

      IF EXISTS (SELECT 1 FROM pg_proc WHERE proname = 'calculate_drink_nutrients') THEN
        PERFORM calculate_drink_nutrients(v_drink_id);
      END IF;
    END IF;
  END IF;
END $$;

DROP FUNCTION IF EXISTS seed_ensure_food(text,text,text,numeric,int,text[]);
DROP FUNCTION IF EXISTS seed_pick_food_id(text[]);

COMMIT;
