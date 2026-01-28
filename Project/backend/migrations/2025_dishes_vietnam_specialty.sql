-- Migration: Add 30 Vietnamese specialty dishes
-- Purpose: Diverse dishes for daily meal suggestions
-- Date: 2025-12-08
-- Categories: Miền Trung (10), Chay (8), Healthy (7), Hầm/Súp (5)

INSERT INTO dish (name, vietnamese_name, description, category, serving_size) 
VALUES
-- === PART 1: Món Đặc Sản Miền Trung (10 món) ===
('Fermented Fish Vermicelli', 'Bún Mắm Cá Linh', 'Bún mắm cá linh đặc sản miền Tây với nước mắm cá lóc, cá linh, tôm, thịt ba chỉ, rau thơm', 'main_course', 450.00),
('Mini Savory Pancakes Phan Thiet', 'Bánh Căn Phan Thiết', 'Bánh căn nhỏ xinh Phan Thiết với trứng cút, tôm khô, hành lá, chấm nước mắm chua ngọt', 'snack', 250.00),
('Clam Rice Hue', 'Cơm Hến Huế', 'Cơm nguội trộn hến xào, rau thơm, mỡ hành, đậu phộng rang đặc sản Huế', 'main_course', 350.00),
('Crispy Pancake Hue Style', 'Bánh Khoái Huế', 'Bánh khoái giòn với tôm, thịt, giá đỗ, chấm nước lèo kiểu Huế', 'snack', 300.00),
('Pork Rib Vermicelli', 'Bún Sườn Sụn', 'Bún sườn sụn hầm nhừ với nước dùng ngọt thanh, rau thơm', 'main_course', 400.00),
('Steamed Rice Cake Hue', 'Bánh Bèo Chén Huế', 'Bánh bèo miền Trung với tôm khô, mỡ hành, nước mắm pha chuẩn vị', 'snack', 200.00),
('Quang Noodle Chicken', 'Mì Quảng Gà', 'Mì Quảng với gà xé, đậu phộng rang, bánh tráng, rau thơm đặc sản Quảng Nam', 'main_course', 400.00),
('Steamed Rice Dumpling', 'Bánh Nậm Huế', 'Bánh nậm Huế gói lá chuối với tôm, thịt, nấm mèo', 'snack', 200.00),
('Dry Beef Noodle', 'Bún Bò Nam Bộ', 'Bún trộn bò xào sả ớt, rau thơm, đậu phộng, nước mắm pha', 'main_course', 400.00),
('Grilled Pork Skewer Sugarcane', 'Nem Lụi Nha Trang', 'Nem nướng xiên que mía Nha Trang, ăn kèm bánh tráng, rau sống, nước chấm', 'appetizer', 250.00),

-- === PART 2: Món Chay Cao Cấp (8 món) ===
('Tofu Mushroom Sauce Vegetarian', 'Đậu Hũ Sốt Nấm Chay', 'Đậu phụ chiên giòn sốt nấm đông cô, nấm rơm, nước tương đậm đà', 'vegetarian', 300.00),
('Coconut Curry Vegetarian', 'Cà Ri Chay Dừa', 'Cà ri chay với đậu hũ, khoai tây, cà rốt, nước cốt dừa thơm béo', 'vegetarian', 350.00),
('Glass Noodle Vegetarian Stir-fry', 'Miến Xào Chay', 'Miến xào nấm, rau củ, đậu hũ ky, nước tương', 'vegetarian', 300.00),
('Vegetarian Hotpot Mix', 'Lẩu Chay Thập Cẩm', 'Lẩu chay với nấm các loại, đậu hũ, rau củ, nước dùng nấm hương', 'vegetarian', 400.00),
('Vegetarian Crab Noodle Soup', 'Bún Riêu Chay', 'Bún riêu chay với đậu hũ nghiền, cà chua, rau muống, mùi tàu', 'vegetarian', 350.00),
('Vegetarian Fried Rice', 'Cơm Chiên Chay Dương Châu', 'Cơm chiên chay với nấm, đậu Hà Lan, cà rốt, trứng chay', 'vegetarian', 350.00),
('Vegetarian Crispy Pancake', 'Bánh Xèo Chay', 'Bánh xèo giòn với nấm, giá đỗ, đậu hũ, chấm nước mắm chay', 'vegetarian', 300.00),
('Vegetarian Pho Nutritious', 'Phở Chay Dinh Dưỡng', 'Phở chay với nước dùng nấm, đậu hũ, rau thơm đầy đủ dinh dưỡng', 'vegetarian', 350.00),

-- === PART 3: Món Healthy/Ít Calo (7 món) ===
('Quinoa Vegetable Salad', 'Salad Quinoa Rau Củ', 'Salad quinoa với rau xà lách, cà chua, dưa leo, olive, dầu ô liu', 'salad', 250.00),
('Pumpkin Almond Soup', 'Súp Bí Đỏ Hạnh Nhân', 'Súp bí đỏ nhuyễn với sữa hạnh nhân, hạt bí rang giòn', 'soup', 300.00),
('Steamed Fish Soy Ginger', 'Cá Hấp Xì Dầu Gừng', 'Cá diêu hồng hấp xì dầu, gừng, hành lá kiểu Quảng Đông', 'main_course', 250.00),
('Steamed Vegetables Lemon Sauce', 'Rau Củ Hấp Sốt Chanh', 'Rau củ hấp: bông cải xanh, cà rốt, súp lơ với sốt chanh mật ong', 'vegetarian', 200.00),
('Grilled Chicken Honey Lemon', 'Gà Nướng Mật Ong Chanh', 'Ức gà nướng mật ong chanh, ít dầu, giàu protein', 'main_course', 250.00),
('Oatmeal Porridge Fruit', 'Cháo Yến Mạch Trái Cây', 'Cháo yến mạch với chuối, dâu tây, hạt chia, mật ong', 'breakfast', 300.00),
('Light Seafood Soup', 'Súp Hải Sản Thanh Đạm', 'Súp tôm, cá, mực với rau củ thanh đạm ít dầu', 'soup', 300.00),

-- === PART 4: Món Hầm/Nấu Lâu (5 món) ===
('Chicken E Leaf Hotpot', 'Lẩu Gà Lá É', 'Lẩu gà hầm thuốc bắc với lá é, nấm, rau củ bổ dưỡng', 'main_course', 450.00),
('Pork Rib Radish Soup', 'Canh Sườn Hầm Củ Cải', 'Canh sườn non hầm với củ cải trắng, cà rốt ngọt thanh', 'soup', 350.00),
('Herbal Chicken Soup', 'Gà Hầm Thuốc Bắc', 'Gà ta hầm với đương quy, kỷ tử, táo đỏ bổ khí huyết', 'main_course', 400.00),
('Chicken Almond Soup', 'Canh Gà Hầm Hạnh Nhân', 'Canh gà hầm hạnh nhân, bổ phế nhuận phổi', 'soup', 350.00),
('Beef Stew Coconut', 'Bò Kho Nước Dừa', 'Bò kho nước dừa với cà rốt, khoai tây, ăn kèm bánh mì', 'main_course', 450.00)

ON CONFLICT (name) DO NOTHING;

-- Verify insertion
DO $$
DECLARE
  new_count INTEGER;
  total_dishes INTEGER;
BEGIN
  -- Count new dishes
  SELECT COUNT(*) INTO new_count
  FROM dish
  WHERE vietnamese_name IN (
    'Bún Mắm Cá Linh', 'Bánh Căn Phan Thiết', 'Cơm Hến Huế',
    'Đậu Hũ Sốt Nấm Chay', 'Salad Quinoa Rau Củ', 'Lẩu Gà Lá É'
  );
  
  SELECT COUNT(*) INTO total_dishes FROM dish;
  
  RAISE NOTICE 'SUCCESS: Inserted % new dishes. Total dishes in system: %', new_count, total_dishes;
END $$;
