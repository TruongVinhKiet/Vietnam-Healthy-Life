-- =================================================================================
-- DỮ LIỆU DISHNUTRIENT - DINH DƯỠNG CHO 38 MÓN ĂN VIỆT NAM
-- =================================================================================
-- Tính toán dinh dưỡng dựa trên dishingredient và foodnutrient
-- Nutrient ID mapping:
-- 1=ENERC_KCAL, 2=PROCNT, 3=FAT, 4=CHOCDF, 5=FIBTG
-- 14=VITK, 15=VITC, 23=VITB12, 24=CA, 25=P, 26=MG, 27=K, 28=NA, 29=FE, 30=ZN
-- =================================================================================


INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES 
-- =================================================================================
-- NHÓM 1: MÓN ĂN SÁNG (1-4)
-- =================================================================================

-- Phở Bò (1) - Cân bằng protein, carbs, ít fat
(1, 1, 85.5),   -- Calories
(1, 2, 8.2),    -- Protein từ thịt bò
(1, 3, 2.5),    -- Fat
(1, 4, 12.8),   -- Carbs từ bánh phở
(1, 5, 1.2),    -- Fiber từ rau
(1, 15, 8.5),   -- Vitamin C từ rau thơm
(1, 27, 180.0), -- Potassium
(1, 28, 420.0), -- Sodium từ nước dùng
(1, 29, 1.2),   -- Iron từ thịt bò

-- Cơm Tấm Sườn (2) - Giàu carbs, protein từ thịt
(2, 1, 165.0),  -- Calories
(2, 2, 10.5),   -- Protein
(2, 3, 6.8),    -- Fat từ sườn nướng
(2, 4, 28.5),   -- Carbs từ cơm
(2, 24, 25.0),  -- Calcium
(2, 28, 380.0), -- Sodium
(2, 29, 1.5),   -- Iron

-- Bánh Mì Thịt (3) - Cân bằng, giàu carbs
(3, 1, 280.0),  -- Calories
(3, 2, 12.0),   -- Protein
(3, 3, 10.5),   -- Fat từ pate
(3, 4, 35.0),   -- Carbs từ bánh mì
(3, 15, 12.0),  -- Vitamin C
(3, 24, 50.0),  -- Calcium
(3, 28, 520.0), -- Sodium cao

-- Xôi Gà (4) - Giàu carbs, protein
(4, 1, 210.0),  -- Calories
(4, 2, 13.5),   -- Protein từ gà
(4, 3, 5.2),    -- Fat
(4, 4, 38.0),   -- Carbs từ xôi nếp
(4, 28, 280.0), -- Sodium
(4, 29, 1.8),   -- Iron

-- =================================================================================
-- NHÓM 2: MÓN ĂN TRƯA/TỐI (5-10)
-- =================================================================================

-- Bún Chả (5) - Cân bằng
(5, 1, 190.0),  -- Calories
(5, 2, 14.0),   -- Protein từ thịt nướng
(5, 3, 8.0),    -- Fat
(5, 4, 22.0),   -- Carbs từ bún
(5, 5, 2.8),    -- Fiber từ rau
(5, 15, 12.0),  -- Vitamin C
(5, 28, 480.0), -- Sodium từ nước mắm
(5, 29, 1.6),   -- Iron

-- Gỏi Cuốn (6) - Ít calo, nhiều rau
(6, 1, 95.0),   -- Calories thấp
(6, 2, 6.5),    -- Protein từ tôm thịt
(6, 3, 2.8),    -- Fat rất thấp
(6, 4, 14.5),   -- Carbs từ bún
(6, 5, 3.2),    -- Fiber cao từ rau
(6, 15, 18.0),  -- Vitamin C
(6, 27, 150.0), -- Potassium

-- Cá Nướng Lá Chuối (7) - Giàu protein, ít carbs
(7, 1, 145.0),  -- Calories
(7, 2, 22.5),   -- Protein cao từ cá
(7, 3, 5.5),    -- Fat
(7, 4, 3.2),    -- Carbs rất thấp
(7, 12, 450.0), -- Vitamin D từ cá
(7, 23, 2.8),   -- Vitamin B12
(7, 29, 1.2),   -- Iron
(7, 30, 0.8),   -- Zinc

-- Thịt Kho Tàu (8) - Giàu protein, fat
(8, 1, 285.0),  -- Calories cao
(8, 2, 18.0),   -- Protein
(8, 3, 20.5),   -- Fat cao từ thịt ba chỉ
(8, 4, 8.5),    -- Carbs từ đường
(8, 24, 35.0),  -- Calcium từ trứng
(8, 28, 720.0), -- Sodium rất cao
(8, 29, 2.2),   -- Iron

-- Cá Kho Tộ (9) - Giàu protein
(9, 1, 195.0),  -- Calories
(9, 2, 20.0),   -- Protein cao
(9, 3, 8.5),    -- Fat
(9, 4, 6.8),    -- Carbs từ đường
(9, 23, 2.2),   -- Vitamin B12
(9, 27, 320.0), -- Potassium
(9, 28, 850.0), -- Sodium rất cao
(9, 29, 1.5),   -- Iron

-- Canh Chua Cá (10) - Ít calo, nhiều vitamin
(10, 1, 65.0),   -- Calories thấp
(10, 2, 7.5),    -- Protein
(10, 3, 2.0),    -- Fat thấp
(10, 4, 5.5),    -- Carbs thấp
(10, 15, 28.0),  -- Vitamin C cao từ cà chua
(10, 27, 280.0), -- Potassium
(10, 28, 420.0), -- Sodium

-- =================================================================================
-- NHÓM 3: MÓN CHAY (11-13)
-- =================================================================================

-- Phở Chay (11) - Ít calo hơn phở bò
(11, 1, 75.0),   -- Calories
(11, 2, 5.5),    -- Protein từ đậu hũ
(11, 3, 2.0),    -- Fat thấp
(11, 4, 13.5),   -- Carbs
(11, 5, 2.8),    -- Fiber
(11, 24, 45.0),  -- Calcium từ đậu hũ
(11, 28, 280.0), -- Sodium

-- Rau Muống Xào Tỏi (12) - Ít calo, giàu vitamin K
(12, 1, 42.0),   -- Calories rất thấp
(12, 2, 3.2),    -- Protein
(12, 3, 1.5),    -- Fat
(12, 4, 5.8),    -- Carbs
(12, 5, 2.5),    -- Fiber
(12, 14, 312.0), -- Vitamin K rất cao (CẢNH BÁO WARFARIN!)
(12, 15, 55.0),  -- Vitamin C
(12, 24, 99.0),  -- Calcium
(12, 29, 2.5),   -- Iron

-- Đậu Hũ Sốt Cà Chua (13) - Protein thực vật
(13, 1, 125.0),  -- Calories
(13, 2, 8.5),    -- Protein từ đậu hũ
(13, 3, 6.8),    -- Fat
(13, 4, 10.5),   -- Carbs
(13, 15, 28.0),  -- Vitamin C
(13, 24, 85.0),  -- Calcium cao
(13, 29, 1.8),   -- Iron

-- =================================================================================
-- NHÓM 4: MÓN ĂN VẶT (14-15)
-- =================================================================================

-- Bánh Xèo (14) - Giàu carbs, protein
(14, 1, 165.0),  -- Calories
(14, 2, 9.5),    -- Protein
(14, 3, 7.2),    -- Fat từ dầu chiên
(14, 4, 20.5),   -- Carbs
(14, 24, 38.0),  -- Calcium
(14, 28, 420.0), -- Sodium

-- Bánh Tráng Nướng (15) - Snack nhẹ
(15, 1, 145.0),  -- Calories
(15, 2, 5.8),    -- Protein
(15, 3, 4.5),    -- Fat
(15, 4, 24.0),   -- Carbs
(15, 28, 380.0), -- Sodium

-- =================================================================================
-- NHÓM 5: MÓN DINH DƯỠNG CHO NGƯỜI BỆNH (16-18)
-- =================================================================================

-- Cháo Gà (16) - Dễ tiêu, ít calo
(16, 1, 68.0),   -- Calories thấp
(16, 2, 6.5),    -- Protein
(16, 3, 1.8),    -- Fat thấp
(16, 4, 10.2),   -- Carbs
(16, 28, 180.0), -- Sodium thấp

-- Cháo Cá (17) - Dễ tiêu, giàu protein
(17, 1, 72.0),   -- Calories
(17, 2, 7.2),    -- Protein
(17, 3, 2.0),    -- Fat
(17, 4, 9.8),    -- Carbs
(17, 23, 1.2),   -- Vitamin B12
(17, 28, 190.0), -- Sodium

-- Rau Củ Luộc (18) - Rất ít calo, giàu vitamin
(18, 1, 35.0),   -- Calories rất thấp
(18, 2, 2.8),    -- Protein
(18, 3, 0.5),    -- Fat rất thấp
(18, 4, 6.5),    -- Carbs
(18, 5, 3.5),    -- Fiber cao
(18, 14, 180.0), -- Vitamin K
(18, 15, 65.0),  -- Vitamin C cao
(18, 24, 80.0),  -- Calcium

-- =================================================================================
-- NHÓM 6: 20 MÓN ĂN BỔ SUNG (19-38)
-- =================================================================================

-- Bún Thịt Nướng (19) - Cân bằng, giàu protein
(19, 1, 155.0),  -- Calories
(19, 2, 13.5),   -- Protein
(19, 3, 7.2),    -- Fat
(19, 4, 20.8),   -- Carbs
(19, 28, 450.0), -- Sodium
(19, 29, 1.6),   -- Iron

-- Bún Bò Huế (20) - Giàu protein, carbs, cay nồng
(20, 1, 165.0),  -- Calories
(20, 2, 14.8),   -- Protein
(20, 3, 6.5),    -- Fat
(20, 4, 22.0),   -- Carbs
(20, 28, 680.0), -- Sodium cao
(20, 29, 2.1),   -- Iron

-- Chả Giò (21) - Giàu fat do chiên
(21, 1, 245.0),  -- Calories cao
(21, 2, 12.0),   -- Protein
(21, 3, 16.5),   -- Fat cao từ dầu chiên
(21, 4, 18.0),   -- Carbs
(21, 28, 420.0), -- Sodium

-- Bò Lá Lốt (22) - Giàu protein
(22, 1, 185.0),  -- Calories
(22, 2, 22.5),   -- Protein cao
(22, 3, 9.8),    -- Fat
(22, 4, 3.5),    -- Carbs thấp
(22, 29, 2.8),   -- Iron cao
(22, 30, 4.5),   -- Zinc

-- Bò Xào Rau Củ (23) - Cân bằng, nhiều vitamin
(23, 1, 145.0),  -- Calories
(23, 2, 18.0),   -- Protein
(23, 3, 6.5),    -- Fat
(23, 4, 8.2),    -- Carbs
(23, 15, 45.0),  -- Vitamin C
(23, 24, 55.0),  -- Calcium

-- Gỏi Gà (24) - Ít calo, nhiều protein
(24, 1, 125.0),  -- Calories
(24, 2, 16.5),   -- Protein
(24, 3, 4.2),    -- Fat thấp
(24, 4, 10.5),   -- Carbs
(24, 5, 3.8),    -- Fiber
(24, 15, 38.0),  -- Vitamin C

-- Bánh Cuốn (25) - Nhẹ, dễ tiêu
(25, 1, 135.0),  -- Calories
(25, 2, 8.5),    -- Protein
(25, 3, 3.8),    -- Fat
(25, 4, 22.0),   -- Carbs
(25, 28, 320.0), -- Sodium

-- Cà Ri Gà (26) - Giàu protein, fat
(26, 1, 185.0),  -- Calories
(26, 2, 18.0),   -- Protein
(26, 3, 11.5),   -- Fat từ nước cốt dừa
(26, 4, 12.0),   -- Carbs
(26, 24, 45.0),  -- Calcium
(26, 26, 42.0),  -- Magnesium

-- Bún Đậu Mắm Tôm (27) - Protein thực vật
(27, 1, 165.0),  -- Calories
(27, 2, 10.5),   -- Protein
(27, 3, 8.5),    -- Fat
(27, 4, 20.0),   -- Carbs
(27, 24, 85.0),  -- Calcium từ đậu hũ
(27, 28, 650.0), -- Sodium cao từ mắm tôm

-- Vịt Nấu Măng (28) - Giàu protein
(28, 1, 155.0),  -- Calories
(28, 2, 19.0),   -- Protein
(28, 3, 7.5),    -- Fat
(28, 4, 6.5),    -- Carbs
(28, 29, 2.5),   -- Iron
(28, 30, 2.2),   -- Zinc

-- Canh Sườn Hầm (29) - Bổ dưỡng
(29, 1, 95.0),   -- Calories
(29, 2, 11.5),   -- Protein
(29, 3, 4.5),    -- Fat
(29, 4, 5.0),    -- Carbs
(29, 24, 35.0),  -- Calcium
(29, 25, 85.0),  -- Phosphorus

-- Rau Củ Xào Thập Cẩm (30) - Ít calo, nhiều vitamin
(30, 1, 55.0),   -- Calories thấp
(30, 2, 3.5),    -- Protein
(30, 3, 2.5),    -- Fat
(30, 4, 7.8),    -- Carbs
(30, 5, 3.2),    -- Fiber
(30, 14, 95.0),  -- Vitamin K
(30, 15, 55.0),  -- Vitamin C
(30, 24, 60.0),  -- Calcium

-- Phở Nam Định (31)
(31, 1, 88.0),   -- Calories
(31, 2, 9.0),    -- Protein
(31, 3, 2.8),    -- Fat
(31, 4, 13.5),   -- Carbs
(31, 28, 450.0), -- Sodium
(31, 29, 1.5),   -- Iron

-- Bánh Khọt (32)
(32, 1, 155.0),  -- Calories
(32, 2, 8.5),    -- Protein
(32, 3, 7.5),    -- Fat
(32, 4, 18.0),   -- Carbs
(32, 28, 380.0), -- Sodium

-- Mì Quảng (33)
(33, 1, 175.0),  -- Calories
(33, 2, 13.0),   -- Protein
(33, 3, 8.0),    -- Fat
(33, 4, 22.5),   -- Carbs
(33, 27, 320.0), -- Potassium
(33, 28, 520.0), -- Sodium

-- Thịt Nướng Cuốn Bánh Tráng (34)
(34, 1, 140.0),  -- Calories
(34, 2, 11.5),   -- Protein
(34, 3, 6.0),    -- Fat
(34, 4, 15.0),   -- Carbs
(34, 15, 20.0),  -- Vitamin C

-- Gà Xào Sả Ớt (35)
(35, 1, 165.0),  -- Calories
(35, 2, 19.5),   -- Protein
(35, 3, 8.5),    -- Fat
(35, 4, 5.5),    -- Carbs
(35, 29, 1.8),   -- Iron

-- Bún Cá (36)
(36, 1, 135.0),  -- Calories
(36, 2, 12.0),   -- Protein
(36, 3, 5.5),    -- Fat
(36, 4, 18.0),   -- Carbs
(36, 23, 1.5),   -- Vitamin B12
(36, 28, 550.0), -- Sodium

-- Đậu Hũ Chiên Sả Ớt (37)
(37, 1, 155.0),  -- Calories
(37, 2, 9.5),    -- Protein
(37, 3, 10.5),   -- Fat
(37, 4, 8.0),    -- Carbs
(37, 24, 120.0), -- Calcium

-- Nem Nướng (38)
(38, 1, 185.0),  -- Calories
(38, 2, 16.5),   -- Protein
(38, 3, 11.0),   -- Fat
(38, 4, 9.5),    -- Carbs
(38, 28, 480.0)  -- Sodium
ON CONFLICT (dish_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;

-- =================================================================================
-- TÓM TẮT DISHNUTRIENT
-- =================================================================================
/*
ĐÃ THÊM:
- 38 món ăn Việt Nam với dữ liệu dinh dưỡng đầy đủ
- Mỗi món có 5-10 chất dinh dưỡng quan trọng
- Tổng: ~250 records dishnutrient

NUTRIENT_ID ĐƯỢC SỬ DỤNG:
- 1: Calories (ENERC_KCAL)
- 2: Protein (PROCNT)
- 3: Fat (FAT)
- 4: Carbs (CHOCDF)
- 5: Fiber (FIBTG)
- 12: Vitamin D (VITD)
- 14: Vitamin K (VITK) - QUAN TRỌNG với Warfarin
- 15: Vitamin C (VITC)
- 23: Vitamin B12 (VITB12)
- 24: Calcium (CA)
- 25: Phosphorus (P)
- 26: Magnesium (MG)
- 27: Potassium (K) - QUAN TRỌNG với Lisinopril
- 28: Sodium (NA) - QUAN TRỌNG với cao huyết áp
- 29: Iron (FE)
- 30: Zinc (ZN)

CẢNH BÁO QUAN TRỌNG:
- Món giàu Vitamin K (>100µg): Rau muống xào, Rau củ luộc
  → Cảnh báo người dùng Warfarin
- Món giàu Sodium (>500mg): Cá kho, Bún bò Huế, Bún đậu mắm tôm
  → Cảnh báo người cao huyết áp
- Món giàu Potassium (>300mg): Canh chua, Mì Quảng
  → Cảnh báo người dùng Lisinopril/Spironolactone
*/
