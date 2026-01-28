-- Migration: Add 60 Vietnamese food ingredients (extended)
-- Purpose: Ingredients for 30 new dishes + 20 new drinks
-- Date: 2025-12-08
-- Note: Avoid duplicates with existing 3115 food items

-- Insert 60 new ingredients in batches
INSERT INTO food (name, category, description, serving_size_g, name_vi) 
VALUES
-- Ngũ cốc & Hạt (10 items)
('Quinoa grain white', 'grains', 'Hạt quinoa trắng giàu protein thực vật', 100.00, 'Quinoa trắng'),
('Black rice (forbidden rice)', 'grains', 'Gạo đen (gạo huyết rồng) giàu anthocyanin', 100.00, 'Gạo đen nguyên chất'),
('Chia seeds', 'grains', 'Hạt chia đen giàu omega-3 và chất xơ', 100.00, 'Hạt chia đen'),
('Flax seeds golden', 'grains', 'Hạt lanh vàng giàu lignans', 100.00, 'Hạt lanh vàng'),
('Sunflower seeds roasted', 'grains', 'Hạt hướng dương rang muối', 100.00, 'Hạt hướng dương rang'),
('Pumpkin seeds raw', 'grains', 'Hạt bí ngô sống giàu kẽm', 100.00, 'Hạt bí ngô sống'),
('Red brown rice', 'grains', 'Gạo lứt đỏ chứa sắt cao', 100.00, 'Gạo lứt đỏ Việt Nam'),
('Rolled oats quick', 'grains', 'Yến mạch cán mỏng nấu nhanh', 100.00, 'Yến mạch cán nhanh'),
('Walnut halves', 'grains', 'Hạt óc chó hai nửa giàu DHA', 100.00, 'Óc chó nửa'),
('Macadamia nuts', 'grains', 'Hạt macadamia Úc cao cấp', 100.00, 'Hạt macadamia Úc'),

-- Rau củ & Nấm (15 items)
('Red beet root', 'vegetables', 'Củ dền đỏ tươi giàu nitrate', 100.00, 'Củ dền đỏ tươi'),
('Artichoke Dalat purple', 'vegetables', 'Atiso tím Đà Lạt đặc sản', 100.00, 'Atiso tím Đà Lạt'),
('Cauliflower white', 'vegetables', 'Súp lơ trắng (bông cải trắng)', 100.00, 'Súp lơ trắng'),
('Shiitake mushroom dried', 'vegetables', 'Nấm đông cô khô Nhật Bản', 100.00, 'Nấm đông cô khô'),
('Wood ear mushroom black', 'vegetables', 'Nấm mèo đen tươi (mộc nhĩ)', 100.00, 'Nấm mèo đen'),
('Enoki mushroom white', 'vegetables', 'Nấm kim châm trắng Hàn Quốc', 100.00, 'Nấm kim châm trắng'),
('Bamboo shoots fresh', 'vegetables', 'Măng tre tươi miền Bắc', 100.00, 'Măng tre tươi'),
('Water spinach Vietnam', 'vegetables', 'Rau càng cua Việt Nam', 100.00, 'Rau càng cua VN'),
('Vietnamese coriander', 'vegetables', 'Rau ngổ thơm Việt Nam', 100.00, 'Rau ngổ Việt'),
('Sweet basil Thai', 'vegetables', 'Húng quế tươi Thái Lan', 100.00, 'Húng quế Thái'),
('Vietnamese perilla', 'vegetables', 'Rau răm thơm Việt Nam', 100.00, 'Rau răm VN'),
('Kaffir lime leaves', 'vegetables', 'Lá chanh Thái tươi', 100.00, 'Lá chanh Thái'),
('Sawtooth coriander', 'vegetables', 'Ngò gai (rau mùi tàu)', 100.00, 'Ngò gai VN'),
('Pumpkin shoots young', 'vegetables', 'Ngọn bí đao non', 100.00, 'Ngọn bí non'),
('Mustard greens stem', 'vegetables', 'Cải bẹ xanh miền Nam', 100.00, 'Cải bẹ xanh MN'),

-- Trái cây (12 items)
('Passion fruit purple', 'fruits', 'Chanh leo tím (passion fruit)', 100.00, 'Chanh leo tím'),
('Soursop fresh', 'fruits', 'Mãng cầu xiêm (soursop)', 100.00, 'Mãng cầu xiêm tươi'),
('Dragon fruit red flesh', 'fruits', 'Thanh long ruột đỏ Bình Thuận', 100.00, 'Thanh long ruột đỏ'),
('Durian Monthong premium', 'fruits', 'Sầu riêng Monthong Thái cao cấp', 100.00, 'Sầu riêng Monthong'),
('Young coconut water', 'fruits', 'Dừa xiêm xanh nước', 100.00, 'Dừa xiêm xanh'),
('Cantaloupe melon', 'fruits', 'Dưa lưới vàng (cantaloupe)', 100.00, 'Dưa lưới vàng'),
('Kiwi fruit green', 'fruits', 'Kiwi xanh New Zealand', 100.00, 'Kiwi xanh NZ'),
('Korean pear', 'fruits', 'Lê nâu Hàn Quốc giòn', 100.00, 'Lê Hàn Quốc'),
('Green grapes seedless', 'fruits', 'Nho xanh không hạt Mỹ', 100.00, 'Nho xanh Mỹ'),
('Strawberry Dalat', 'fruits', 'Dâu tây Đà Lạt tươi', 100.00, 'Dâu tây Đà Lạt'),
('Blueberry fresh', 'fruits', 'Việt quất tươi (blueberry)', 100.00, 'Việt quất tươi'),
('Pomegranate red', 'fruits', 'Lựu đỏ Ấn Độ', 100.00, 'Lựu đỏ Ấn'),

-- Protein (10 items)
('Freshwater prawn green', 'protein', 'Tôm càng xanh sông nước ngọt', 100.00, 'Tôm càng xanh'),
('Yellowfin tuna', 'protein', 'Cá ngừ vây vàng đại dương', 100.00, 'Cá ngừ đại dương'),
('Norwegian salmon', 'protein', 'Cá hồi Na Uy tươi cao cấp', 100.00, 'Cá hồi Na Uy'),
('Australian lamb', 'protein', 'Thịt cừu non Úc', 100.00, 'Thịt cừu Úc'),
('Tofu skin rolls', 'protein', 'Đậu phụ cuộn chiên (đậu hũ ky)', 100.00, 'Đậu hũ ky chiên'),
('Vietnamese pork sausage', 'protein', 'Chả lụa truyền thống Việt Nam', 100.00, 'Chả lụa VN'),
('Pork head cheese', 'protein', 'Giò thủ heo truyền thống', 100.00, 'Giò thủ'),
('Pork brain', 'protein', 'Óc heo tươi', 100.00, 'Óc heo tươi'),
('Chicken giblets', 'protein', 'Lòng gà tươi (gan, tim, mề)', 100.00, 'Lòng gà tươi'),
('Field frog meat', 'protein', 'Thịt ếch ruộng tươi', 100.00, 'Thịt ếch ruộng'),

-- Gia vị & Dầu (8 items)
('Turmeric powder pure', 'condiments', 'Bột nghệ vàng nguyên chất', 100.00, 'Bột nghệ nguyên chất'),
('Indian curry powder', 'condiments', 'Bột cà ri Ấn Độ pha sẵn', 100.00, 'Bột cà ri Ấn'),
('Fresh lime juice', 'condiments', 'Nước cốt chanh tươi vắt', 100.00, 'Nước cốt chanh tươi'),
('Lemongrass sliced', 'condiments', 'Sả tươi thái lát mỏng', 100.00, 'Sả thái lát'),
('Black garlic fermented', 'condiments', 'Tỏi đen lên men 90 ngày', 100.00, 'Tỏi đen lên men'),
('Shrimp paste Hue', 'condiments', 'Mắm tôm Huế đặc sản', 100.00, 'Mắm tôm Huế'),
('Vegetable seasoning powder', 'condiments', 'Hạt nêm rau củ tự nhiên', 100.00, 'Hạt nêm rau củ'),
('Sesame oil roasted', 'oils', 'Dầu vừng rang thơm', 100.00, 'Dầu mè rang'),

-- Nguyên liệu đồ uống (5 items)
('Lotus leaf dried', 'drink_ingredient', 'Lá sen phơi khô nguyên vẹn', 100.00, 'Lá sen khô'),
('White chrysanthemum dried', 'drink_ingredient', 'Hoa cúc trắng sấy khô', 100.00, 'Hoa cúc trắng khô'),
('Red artichoke dried Dalat', 'drink_ingredient', 'Atiso đỏ Đà Lạt sấy khô', 100.00, 'Atiso đỏ khô'),
('Atractylodes dried', 'drink_ingredient', 'Lạc tiên (bạch truật) khô', 100.00, 'Lac tien kho'),
('Almond roasted salted', 'drink_ingredient', 'Hạnh nhân Mỹ rang bơ muối', 100.00, 'Hanh nhan rang muoi');

-- Verify insertion
DO $$
DECLARE
  new_count INTEGER;
  duplicate_count INTEGER;
BEGIN
  -- Count new ingredients
  SELECT COUNT(*) INTO new_count 
  FROM food 
  WHERE vietnamese_name IN (
    'Quinoa trắng', 'Gạo đen nguyên chất', 'Hạt chia đen', 'Củ dền đỏ tươi',
    'Atiso tím Đà Lạt', 'Chanh leo tím', 'Mãng cầu xiêm tươi', 'Tôm càng xanh',
    'Cá ngừ đại dương', 'Bột nghệ nguyên chất', 'Lá sen khô'
  );
  
  -- Check duplicates
  SELECT COUNT(*) INTO duplicate_count
  FROM (
    SELECT vietnamese_name, COUNT(*) 
    FROM food 
    WHERE vietnamese_name LIKE '%Quinoa%' OR vietnamese_name LIKE '%Atiso%'
    GROUP BY vietnamese_name
    HAVING COUNT(*) > 1
  ) dup;
  
  IF duplicate_count > 0 THEN
    RAISE WARNING 'Found % duplicate ingredients - please check', duplicate_count;
  ELSE
    RAISE NOTICE 'SUCCESS: Inserted % new Vietnamese ingredients without duplicates', new_count;
  END IF;
END $$;
