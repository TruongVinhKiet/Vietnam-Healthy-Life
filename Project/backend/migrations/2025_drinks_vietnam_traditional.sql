-- Migration: Add 20 Vietnamese traditional drinks
-- Purpose: Diverse drinks for daily meal suggestions
-- Date: 2025-12-08
-- Categories: Traditional (6), Herbal Tea (5), Detox Juice (5), Health Drink (4)

INSERT INTO drink (name, vietnamese_name, description, category, serving_size, hydration_ratio, caffeine_content, is_alcoholic)
VALUES
-- === PART 1: Traditional Vietnamese Drinks (6) ===
('Sweet Tonic Drink', 'Nước Sâm Bổ Lượng', 'Nước sâm bổ lượng với hạt sen, long nhãn, táo đỏ, hạt ý dĩ mát gan', 'Healthy', 300.00, 85.00, 0.00, false),
('White Jelly Dessert', 'Chè Khúc Bạch', 'Chè khúc bạch với thạch dừa, long nhãn, siro ngọt thanh', 'Dessert', 250.00, 75.00, 0.00, false),
('Winter Melon Tea', 'Trà Bí Đao Hạt Sen', 'Trà bí đao hầm hạt sen giải nhiệt, mát gan', 'Tea', 300.00, 90.00, 0.00, false),
('Grass Jelly Drink', 'Nước Sương Sáo', 'Nước sương sáo mát lạnh với đường phèn giải nhiệt', 'Dessert', 300.00, 85.00, 0.00, false),
('Pennywort Juice', 'Nước Rau Má Mật Ong', 'Nước rau má tươi với mật ong thanh nhiệt, giải độc', 'Juice', 250.00, 88.00, 0.00, false),
('Longan Seed Drink', 'Nước Hạt Sen Long Nhãn', 'Nước hạt sen long nhãn táo đỏ bổ tâm an thần', 'Healthy', 300.00, 85.00, 0.00, false),

-- === PART 2: Herbal Tea - Trà Thảo Mộc (5) ===
('Red Artichoke Tea', 'Trà Atisô Đỏ Đà Lạt', 'Trà atisô đỏ Đà Lạt mát gan, giải độc gan', 'Tea', 300.00, 95.00, 5.00, false),
('Goji Berry Tea', 'Trà Kỷ Tử Gừng Mật Ong', 'Trà kỷ tử gừng mật ong ấm bụng, bổ khí huyết', 'Tea', 250.00, 92.00, 3.00, false),
('Chrysanthemum Tea', 'Trà Hoa Cúc Mật Ong', 'Trà hoa cúc mật ong sáng mắt, thanh nhiệt', 'Tea', 300.00, 95.00, 0.00, false),
('Licorice Basil Tea', 'Trà Húng Chanh Cam Thảo', 'Trà húng chanh cam thảo giải cảm, làm dịu cổ họng', 'Tea', 250.00, 94.00, 2.00, false),
('Lotus Leaf Tea', 'Trà Lá Sen Giảm Cân', 'Trà lá sen giảm mỡ máu, hỗ trợ giảm cân tự nhiên', 'Tea', 300.00, 96.00, 0.00, false),

-- === PART 3: Detox Juice - Nước Ép Detox (5) ===
('Mixed Vegetable Juice', 'Nước Ép Rau Củ Thải Độc', 'Nước ép cần tây, dưa leo, táo xanh, chanh detox', 'Juice', 300.00, 90.00, 0.00, false),
('Grapefruit Honey Juice', 'Nước Ép Bưởi Mật Ong', 'Nước ép bưởi da xanh mật ong giảm mỡ máu', 'Juice', 250.00, 88.00, 0.00, false),
('Celery Apple Juice', 'Nước Ép Cần Tây Táo', 'Nước ép cần tây táo xanh giải độc gan', 'Juice', 300.00, 89.00, 0.00, false),
('Beet Carrot Juice', 'Nước Ép Củ Dền Cà Rốt', 'Nước ép củ dền cà rốt bổ máu, sáng mắt', 'Juice', 250.00, 87.00, 0.00, false),
('Pineapple Mint Juice', 'Nước Ép Dứa Bạc Hà', 'Nước ép dứa bạc hà tươi mát, tiêu hóa', 'Juice', 300.00, 88.00, 0.00, false),

-- === PART 4: Health Drinks - Đồ Uống Sức Khỏe (4) ===
('Oat Milk Banana', 'Sữa Yến Mạch Chuối', 'Sữa yến mạch chuối hạt chia giàu chất xơ', 'Milk', 300.00, 85.00, 0.00, false),
('Chia Seed Lemon', 'Nước Hạt Chia Chanh Mật Ong', 'Nước hạt chia chanh mật ong giảm cân', 'Healthy', 300.00, 90.00, 0.00, false),
('Kombucha Probiotics', 'Kombucha Trà Lên Men', 'Kombucha trà lên men có lợi khuẩn tốt cho tiêu hóa', 'Healthy', 250.00, 92.00, 8.00, false),
('Almond Milk Turmeric', 'Sữa Hạnh Nhân Nghệ', 'Sữa hạnh nhân nghệ chống viêm, tăng miễn dịch', 'Milk', 300.00, 88.00, 0.00, false)

ON CONFLICT (name) DO NOTHING;

-- Verify insertion
DO $$
DECLARE
  new_count INTEGER;
  total_drinks INTEGER;
BEGIN
  -- Count new drinks
  SELECT COUNT(*) INTO new_count
  FROM drink
  WHERE vietnamese_name IN (
    'Nước Sâm Bổ Lượng', 'Trà Atisô Đỏ Đà Lạt', 
    'Nước Ép Rau Củ Thải Độc', 'Sữa Yến Mạch Chuối'
  );
  
  SELECT COUNT(*) INTO total_drinks FROM drink;
  
  RAISE NOTICE 'SUCCESS: Inserted % new drinks. Total drinks in system: %', new_count, total_drinks;
END $$;
