-- Migration: Add 60 Vietnamese food ingredients (clean version)
-- Purpose: Ingredients for 30 new dishes + 20 new drinks
-- Date: 2025-12-08

INSERT INTO food (name, category, description, serving_size_g, name_vi) 
VALUES
-- Grains & Seeds (10 items)
('Quinoa grain white', 'grains', 'White quinoa grain high in plant protein', 100.00, 'Quinoa trang'),
('Black rice (forbidden rice)', 'grains', 'Black rice high in anthocyanin', 100.00, 'Gao den'),
('Chia seeds', 'grains', 'Black chia seeds high in omega-3', 100.00, 'Hat chia'),
('Flax seeds golden', 'grains', 'Golden flax seeds high in lignans', 100.00, 'Hat lanh vang'),
('Sunflower seeds roasted', 'grains', 'Roasted sunflower seeds', 100.00, 'Hat huong duong rang'),
('Pumpkin seeds raw', 'grains', 'Raw pumpkin seeds high in zinc', 100.00, 'Hat bi ngo song'),
('Red brown rice', 'grains', 'Red brown rice high in iron', 100.00, 'Gao lut do'),
('Buckwheat groats', 'grains', 'Buckwheat whole grains', 100.00, 'Tam giac mach'),
('Walnut halves', 'grains', 'Walnut halves high in DHA', 100.00, 'Oc cho'),
('Macadamia nuts', 'grains', 'Premium macadamia nuts', 100.00, 'Hat macadamia'),

-- Vegetables & Mushrooms (15 items)
('Red beet root', 'vegetables', 'Fresh red beet root high in nitrate', 100.00, 'Cu den do'),
('Sweet potato purple', 'vegetables', 'Purple sweet potato high in fiber', 100.00, 'Khoai lang tim'),
('Kabocha squash', 'vegetables', 'Japanese pumpkin kabocha', 100.00, 'Bi do Nhat'),
('Baby bok choy', 'vegetables', 'Baby bok choy tender greens', 100.00, 'Cai thia be'),
('Enoki mushroom', 'vegetables', 'Enoki mushrooms white needle', 100.00, 'Nam kim cham'),
('King oyster mushroom', 'vegetables', 'King oyster mushroom large stem', 100.00, 'Nam bao ngu hoang de'),
('Wood ear mushroom', 'vegetables', 'Black wood ear fungus dried', 100.00, 'Nam meo den kho'),
('Lotus root fresh', 'vegetables', 'Fresh lotus root crispy', 100.00, 'Ngo sen tuoi'),
('Water chestnut', 'vegetables', 'Water chestnut fresh peeled', 100.00, 'Cu nau tuoi'),
('Daikon radish', 'vegetables', 'White daikon radish long', 100.00, 'Cu cai trang lon'),
('Jicama root', 'vegetables', 'Jicama root crispy sweet', 100.00, 'Cu san'),
('Kohlrabi green', 'vegetables', 'Green kohlrabi fresh', 100.00, 'Su hao xanh'),
('Snow pea pods', 'vegetables', 'Tender snow pea pods', 100.00, 'Dau Ha Lan xanh'),
('Chinese water spinach', 'vegetables', 'Water spinach morning glory', 100.00, 'Rau muong'),
('Bitter melon', 'vegetables', 'Bitter gourd green', 100.00, 'Kho qua'),

-- Fruits & Berries (10 items)
('Dragon fruit red', 'fruits', 'Red dragon fruit pitaya', 100.00, 'Thanh long ruot do'),
('Longan fresh', 'fruits', 'Fresh longan fruit sweet', 100.00, 'Nhan tuoi'),
('Lychee fresh', 'fruits', 'Fresh lychee fruit', 100.00, 'Vai tuoi'),
('Star fruit', 'fruits', 'Star fruit carambola yellow', 100.00, 'Khe'),
('Jackfruit ripe', 'fruits', 'Ripe jackfruit flesh', 100.00, 'Mit tuoi chin'),
('Guava white', 'fruits', 'White guava fruit crispy', 100.00, 'Oi trang'),
('Pomelo white', 'fruits', 'White pomelo grapefruit', 100.00, 'Buoi trang'),
('Passion fruit', 'fruits', 'Purple passion fruit chanh day', 100.00, 'Chanh day tim'),
('Rambutan fresh', 'fruits', 'Fresh rambutan hairy fruit', 100.00, 'Chom chom tuoi'),
('Sapodilla fruit', 'fruits', 'Sapodilla brown fruit', 100.00, 'Hong xiem'),

-- Proteins & Seafood (10 items)
('Sea bass fillet', 'protein', 'Fresh sea bass white fish', 100.00, 'Ca ro phi tuoi'),
('Mackerel fish', 'protein', 'Mackerel oily fish high omega-3', 100.00, 'Ca thu'),
('Squid fresh', 'protein', 'Fresh squid cleaned', 100.00, 'Muc tuoi'),
('Shrimp black tiger', 'protein', 'Black tiger prawns large', 100.00, 'Tom su'),
('Clam meat', 'protein', 'Clam meat shelled', 100.00, 'Thit ngao'),
('Duck breast', 'protein', 'Duck breast meat lean', 100.00, 'Thit uc vit'),
('Quail eggs', 'protein', 'Fresh quail eggs small', 100.00, 'Trung cut'),
('Silken tofu', 'protein', 'Japanese silken tofu soft', 100.00, 'Dau phu non'),
('Tempeh fermented', 'protein', 'Fermented soybean tempeh', 100.00, 'Tempeh'),
('Edamame beans', 'protein', 'Frozen edamame soybeans', 100.00, 'Dau nanh xanh'),

-- Herbs & Spices (10 items)
('Lemongrass stalk', 'herbs', 'Fresh lemongrass stalks', 100.00, 'Sa'),
('Thai basil', 'herbs', 'Thai basil purple stem', 100.00, 'Rau que Thai'),
('Vietnamese coriander', 'herbs', 'Vietnamese coriander rau ram', 100.00, 'Rau ram'),
('Sawtooth coriander', 'herbs', 'Sawtooth coriander ngo gai', 100.00, 'Ngo gai'),
('Fish mint leaves', 'herbs', 'Fish mint diep ca leaves', 100.00, 'Diep ca'),
('Perilla leaves', 'herbs', 'Perilla shiso leaves purple', 100.00, 'La tia to'),
('Galangal root', 'herbs', 'Galangal root fresh rieng', 100.00, 'Rieng tuoi'),
('Turmeric fresh', 'herbs', 'Fresh turmeric root yellow', 100.00, 'Nghe tuoi'),
('Kaffir lime leaves', 'herbs', 'Kaffir lime leaves fragrant', 100.00, 'La chanh'),
('Ginger young', 'herbs', 'Young ginger tender pink', 100.00, 'Gung non'),

-- Drink Ingredients (5 items)
('Coconut water fresh', 'drink_ingredient', 'Fresh coconut water natural', 100.00, 'Nuoc dua tuoi'),
('Pandan leaves', 'drink_ingredient', 'Pandan leaves la dua fragrant', 100.00, 'La dua'),
('Chrysanthemum dried', 'drink_ingredient', 'Dried chrysanthemum flowers', 100.00, 'Hoa cuc kho'),
('Atractylodes dried', 'drink_ingredient', 'Dried atractylodes herb', 100.00, 'Lac tien kho'),
('Almond roasted salted', 'drink_ingredient', 'Roasted salted almonds', 100.00, 'Hanh nhan rang muoi');

-- Verify insertion
DO $$
DECLARE
  new_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO new_count FROM food WHERE food_id > 3115;
  IF new_count = 0 THEN
    RAISE WARNING 'No new ingredients were inserted';
  ELSE
    RAISE NOTICE 'SUCCESS: Inserted % new Vietnamese ingredients', new_count;
  END IF;
END $$;
