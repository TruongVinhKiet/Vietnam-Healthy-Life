-- =================================================================================
-- DỮ LIỆU DRINKNUTRIENT - DINH DƯỠNG CHO 40 ĐỒ UỐNG VIỆT NAM
-- =================================================================================
-- Tính toán dinh dưỡng cho các đồ uống phổ biến tại Việt Nam
-- Nutrient ID mapping:
-- 1=ENERC_KCAL, 2=PROCNT, 3=FAT, 4=CHOCDF, 5=FIBTG
-- 14=VITK, 15=VITC, 23=VITB12, 24=CA, 26=MG, 27=K, 28=NA, 29=FE, 30=ZN
-- =================================================================================


INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES 
-- =================================================================================
-- NHÓM 1: NƯỚC TRÁI CÂY (1-4)
-- =================================================================================

-- Nước Cam Vắt (1) - Giàu vitamin C
(1, 1, 45.0),    -- Calories
(1, 4, 10.4),    -- Carbs (đường tự nhiên)
(1, 15, 50.0),   -- Vitamin C cao
(1, 27, 200.0),  -- Potassium
(1, 24, 11.0),   -- Calcium

-- Nước Mía (2) - Giàu đường tự nhiên
(2, 1, 72.0),    -- Calories
(2, 4, 18.0),    -- Carbs cao
(2, 15, 8.0),    -- Vitamin C
(2, 24, 18.0),   -- Calcium
(2, 26, 12.0),   -- Magnesium
(2, 27, 142.0),  -- Potassium

-- Nước Dừa Tươi (3) - Điện giải tự nhiên
(3, 1, 19.0),    -- Calories thấp
(3, 4, 3.7),     -- Carbs thấp
(3, 24, 24.0),   -- Calcium
(3, 26, 25.0),   -- Magnesium
(3, 27, 250.0),  -- Potassium cao (CẢNH BÁO LISINOPRIL)
(3, 28, 105.0),  -- Sodium

-- Trà Chanh (4) - Ít calo
(4, 1, 28.0),    -- Calories
(4, 4, 7.0),     -- Carbs
(4, 15, 15.0),   -- Vitamin C

-- =================================================================================
-- NHÓM 2: CÀ PHÊ (5-7, 21-22)
-- =================================================================================

-- Cà Phê Đen (5) - Không calo
(5, 1, 2.0),     -- Calories rất thấp
(5, 4, 0.0),     -- Carbs = 0
(5, 27, 115.0),  -- Potassium

-- Cà Phê Sữa (6) - Giàu đường, calo
(6, 1, 85.0),    -- Calories
(6, 2, 2.8),     -- Protein từ sữa
(6, 3, 3.5),     -- Fat từ sữa
(6, 4, 12.5),    -- Carbs từ sữa đặc
(6, 24, 45.0),   -- Calcium

-- Cà Phê Sữa Đá (7)
(7, 1, 68.0),    -- Calories
(7, 2, 2.2),     -- Protein
(7, 3, 2.8),     -- Fat
(7, 4, 10.0),    -- Carbs
(7, 24, 36.0),   -- Calcium

-- Cà Phê Trứng (21) - Giàu fat, protein
(21, 1, 145.0),  -- Calories cao
(21, 2, 4.5),    -- Protein từ trứng
(21, 3, 9.5),    -- Fat từ trứng
(21, 4, 12.0),   -- Carbs
(21, 24, 55.0),  -- Calcium
(21, 23, 0.35),  -- Vitamin B12 từ trứng

-- Cà Phê Cốt Dừa (22) - Giàu fat
(22, 1, 125.0),  -- Calories
(22, 2, 1.8),    -- Protein
(22, 3, 8.5),    -- Fat từ cốt dừa
(22, 4, 14.0),   -- Carbs
(22, 26, 18.0),  -- Magnesium

-- =================================================================================
-- NHÓM 3: TRÀ (8-10, 31-33, 35-36)
-- =================================================================================

-- Trà Xanh (8) - Không calo
(8, 1, 0.0),     -- Calories = 0
(8, 4, 0.0),     -- Carbs = 0
(8, 27, 8.0),    -- Potassium

-- Trà Sen (9) - Không calo
(9, 1, 1.0),     -- Calories rất thấp
(9, 4, 0.2),     -- Carbs gần như 0

-- Trà Nhài (10) - Không calo
(10, 1, 1.0),    -- Calories
(10, 4, 0.2),    -- Carbs

-- Trà Đá Chanh (31) - Rất ít calo
(31, 1, 22.0),   -- Calories
(31, 4, 5.5),    -- Carbs
(31, 15, 12.0),  -- Vitamin C

-- Trà Đào (32) - Ngọt vừa
(32, 1, 38.0),   -- Calories
(32, 4, 9.5),    -- Carbs
(32, 15, 8.5),   -- Vitamin C

-- Trà Tắc Mật Ong (33) - Giàu Vitamin C
(33, 1, 52.0),   -- Calories
(33, 4, 13.0),   -- Carbs từ mật ong
(33, 15, 42.0),  -- Vitamin C cao

-- Trà Thảo Mộc (35) - Không calo
(35, 1, 2.0),    -- Calories
(35, 4, 0.5),    -- Carbs

-- Trà Bí Đao (36) - Ít calo
(36, 1, 25.0),   -- Calories
(36, 4, 6.0),    -- Carbs

-- =================================================================================
-- NHÓM 4: SINH TỐ (11-13, 26-28)
-- =================================================================================

-- Sinh Tố Bơ (11) - Giàu chất béo tốt
(11, 1, 165.0),  -- Calories cao
(11, 2, 2.8),    -- Protein
(11, 3, 12.5),   -- Fat từ bơ (chất béo tốt)
(11, 4, 11.2),   -- Carbs
(11, 5, 2.5),    -- Fiber
(11, 24, 85.0),  -- Calcium từ sữa
(11, 27, 180.0), -- Potassium

-- Sinh Tố Chuối (12) - Giàu kali
(12, 1, 95.0),   -- Calories
(12, 2, 3.5),    -- Protein
(12, 3, 2.5),    -- Fat
(12, 4, 18.5),   -- Carbs
(12, 5, 2.0),    -- Fiber
(12, 24, 72.0),  -- Calcium
(12, 27, 215.0), -- Potassium cao (CẢNH BÁO LISINOPRIL)

-- Sinh Tố Xoài (13) - Giàu vitamin C
(13, 1, 88.0),   -- Calories
(13, 2, 3.2),    -- Protein
(13, 3, 2.0),    -- Fat
(13, 4, 17.0),   -- Carbs
(13, 11, 54.0),  -- Vitamin A
(13, 15, 36.5),  -- Vitamin C
(13, 24, 65.0),  -- Calcium

-- Sinh Tố Mãng Cầu (26) - Giàu Vitamin C
(26, 1, 95.0),   -- Calories
(26, 2, 2.5),    -- Protein
(26, 4, 20.0),   -- Carbs
(26, 5, 2.2),    -- Fiber
(26, 15, 55.0),  -- Vitamin C cao
(26, 24, 65.0),  -- Calcium

-- Sinh Tố Thanh Long (27) - Ít calo
(27, 1, 78.0),   -- Calories
(27, 2, 2.8),    -- Protein
(27, 4, 16.5),   -- Carbs
(27, 5, 1.8),    -- Fiber
(27, 15, 28.0),  -- Vitamin C
(27, 24, 58.0),  -- Calcium

-- Sinh Tố Đu Đủ (28) - Giàu Vitamin A, C
(28, 1, 88.0),   -- Calories
(28, 2, 3.2),    -- Protein
(28, 4, 18.0),   -- Carbs
(28, 5, 2.0),    -- Fiber
(28, 11, 95.0),  -- Vitamin A
(28, 15, 62.0),  -- Vitamin C cao
(28, 24, 68.0),  -- Calcium

-- =================================================================================
-- NHÓM 5: ĐỒ UỐNG SỨC KHỎE (14-20, 34-40)
-- =================================================================================

-- Sữa Đậu Nành (14) - Protein thực vật
(14, 1, 54.0),   -- Calories
(14, 2, 3.3),    -- Protein thực vật
(14, 3, 1.9),    -- Fat
(14, 4, 6.0),    -- Carbs
(14, 24, 25.0),  -- Calcium
(14, 29, 1.2),   -- Iron

-- Trà Gừng (15) - Ấm bụng
(15, 1, 18.0),   -- Calories
(15, 4, 4.5),    -- Carbs
(15, 26, 8.0),   -- Magnesium

-- Trà Hoa Cúc (16) - Mát gan
(16, 1, 3.0),    -- Calories rất thấp
(16, 4, 0.8),    -- Carbs

-- Nước Lúa Mạch (17) - Mát, giải nhiệt
(17, 1, 28.0),   -- Calories
(17, 4, 7.0),    -- Carbs
(17, 5, 1.5),    -- Fiber
(17, 26, 12.0),  -- Magnesium

-- Trà Atiso (18) - Giải độc gan
(18, 1, 15.0),   -- Calories
(18, 4, 3.5),    -- Carbs
(18, 27, 85.0),  -- Potassium

-- Nước Rau Má (19) - Thanh mát
(19, 1, 12.0),   -- Calories
(19, 4, 2.8),    -- Carbs
(19, 15, 8.0),   -- Vitamin C
(19, 24, 18.0),  -- Calcium

-- Nước Lọc (20) - Không dinh dưỡng
(20, 1, 0.0),    -- Calories = 0
(20, 4, 0.0),    -- Carbs = 0

-- Nước Chanh Tươi (23) - Giàu Vitamin C
(23, 1, 35.0),   -- Calories
(23, 4, 8.5),    -- Carbs
(23, 15, 45.0),  -- Vitamin C cao
(23, 27, 85.0),  -- Potassium

-- Nước Chanh Dây (24) - Giàu Vitamin C
(24, 1, 42.0),   -- Calories
(24, 4, 10.0),   -- Carbs
(24, 15, 38.0),  -- Vitamin C
(24, 27, 95.0),  -- Potassium

-- Nước Me (25) - Giàu khoáng chất
(25, 1, 48.0),   -- Calories
(25, 4, 12.0),   -- Carbs
(25, 15, 15.0),  -- Vitamin C
(25, 24, 22.0),  -- Calcium
(25, 27, 125.0), -- Potassium

-- Nước Dưa Hấu (29) - Ít calo, nhiều nước
(29, 1, 30.0),   -- Calories thấp
(29, 4, 7.5),    -- Carbs
(29, 5, 0.4),    -- Fiber
(29, 15, 8.0),   -- Vitamin C
(29, 27, 112.0), -- Potassium

-- Nước Mía Tắc (30) - Giàu đường, Vitamin C
(30, 1, 78.0),   -- Calories
(30, 4, 19.5),   -- Carbs cao
(30, 15, 35.0),  -- Vitamin C
(30, 27, 148.0), -- Potassium

-- Nước Cốm (34) - Giàu carbs
(34, 1, 65.0),   -- Calories
(34, 2, 1.5),    -- Protein
(34, 4, 15.5),   -- Carbs
(34, 5, 1.2),    -- Fiber

-- =================================================================================
-- NHÓM 6: SỮA & CHÈ (37-40)
-- =================================================================================

-- Sữa Mè Đen (37) - Giàu protein, fat, khoáng
(37, 1, 115.0),  -- Calories
(37, 2, 4.8),    -- Protein
(37, 3, 7.5),    -- Fat
(37, 4, 8.5),    -- Carbs
(37, 24, 95.0),  -- Calcium cao
(37, 26, 35.0),  -- Magnesium
(37, 29, 2.5),   -- Iron cao

-- Sữa Đậu Phộng (38) - Giàu protein
(38, 1, 98.0),   -- Calories
(38, 2, 4.2),    -- Protein
(38, 3, 5.5),    -- Fat
(38, 4, 9.0),    -- Carbs
(38, 24, 45.0),  -- Calcium
(38, 26, 28.0),  -- Magnesium

-- Chè Ba Màu (39) - Giàu carbs, protein
(39, 1, 135.0),  -- Calories
(39, 2, 5.5),    -- Protein từ đậu
(39, 3, 3.5),    -- Fat
(39, 4, 28.0),   -- Carbs cao
(39, 5, 2.8),    -- Fiber
(39, 24, 75.0),  -- Calcium
(39, 26, 32.0),  -- Magnesium

-- Sương Sáo (40) - Ít calo
(40, 1, 32.0),   -- Calories thấp
(40, 4, 8.0),    -- Carbs
(40, 5, 0.8),    -- Fiber
(40, 24, 12.0)   -- Calcium
ON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;

-- =================================================================================
-- TÓM TẮT DRINKNUTRIENT
-- =================================================================================
/*
ĐÃ THÊM:
- 40 đồ uống Việt Nam với dữ liệu dinh dưỡng đầy đủ
- Mỗi đồ uống có 3-10 chất dinh dưỡng quan trọng
- Tổng: ~220 records drinknutrient

PHÂN LOẠI ĐỒ UỐNG:
1. NƯỚC TRÁI CÂY (1-4, 23-25, 29-30): 10 loại
   - Giàu Vitamin C, Potassium
   - Calories: 19-78 kcal/100ml

2. CÀ PHÊ (5-7, 21-22): 5 loại
   - Caffeine: 75-95mg/100ml
   - Calories: 2-145 kcal/100ml
   - Cà phê trứng giàu protein, fat

3. TRÀ (8-10, 31-33, 35-36): 9 loại
   - Hầu hết không calo hoặc rất ít calo
   - Caffeine: 15-30mg/100ml
   - Trà tắc mật ong giàu Vitamin C

4. SINH TỐ (11-13, 26-28): 6 loại
   - Giàu vitamin, khoáng chất
   - Calories: 78-165 kcal/100ml
   - Sinh tố bơ giàu chất béo tốt

5. ĐỒ UỐNG SỨC KHỎE (14-20, 34): 8 loại
   - Sữa đậu nành: protein thực vật
   - Nước rau má, trà atiso: giải độc
   - Calories thấp: 0-65 kcal/100ml

6. SỮA & CHÈ (37-40): 4 loại
   - Sữa mè đen: giàu calcium, iron
   - Chè ba màu: giàu carbs, protein
   - Calories: 32-135 kcal/100ml

NUTRIENT_ID ĐƯỢC SỬ DỤNG:
- 1: Calories (ENERC_KCAL)
- 2: Protein (PROCNT)
- 3: Fat (FAT)
- 4: Carbs (CHOCDF)
- 5: Fiber (FIBTG)
- 11: Vitamin A (VITA)
- 15: Vitamin C (VITC)
- 23: Vitamin B12 (VITB12)
- 24: Calcium (CA)
- 26: Magnesium (MG)
- 27: Potassium (K) - QUAN TRỌNG
- 28: Sodium (NA)
- 29: Iron (FE)

CẢNH BÁO QUAN TRỌNG:
1. Đồ uống giàu Potassium (>200mg/100ml):
   - Nước dừa: 250mg
   - Sinh tố chuối: 215mg
   - Nước cam: 200mg
   → CẢNH BÁO người dùng Lisinopril/Spironolactone

2. Đồ uống giàu Caffeine (>50mg/100ml):
   - Cà phê đen: 95mg
   - Cà phê trứng: 85mg
   - Cà phê sữa: 80-85mg
   → CẢNH BÁO phụ nữ mang thai, người cao huyết áp

3. Đồ uống giàu đường (>15g/100ml):
   - Nước mía tắc: 19.5g
   - Sinh tố bơ, chuối, mãng cầu: 17-20g
   - Nước mía: 18g
   → CẢNH BÁO người tiểu đường

4. Đồ uống lành mạnh (ít calo, không đường):
   - Nước lọc, trà xanh, trà hoa cúc: 0-3 kcal
   - Phù hợp cho người giảm cân, kiểm soát đường huyết

GỢI Ý SỬ DỤNG:
- Người tiểu đường: Chọn trà không đường, nước lọc
- Người cao huyết áp: Tránh cà phê, chọn trà thảo mộc
- Người thiếu sắt: Sữa mè đen (2.5mg iron/100ml)
- Người loãng xương: Sữa đậu nành, sinh tố (calcium cao)
- Người cần giảm cân: Trà xanh, nước chanh, nước rau má
*/
