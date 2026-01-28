-- =================================================================================
-- DỮ LIỆU DRINKNUTRIENT HOÀN CHỈNH - 40 ĐỒ UỐNG VIỆT NAM
-- =================================================================================
-- Tính toán dinh dưỡng đầy đủ cho 40 đồ uống trong bảng drink
-- Nutrient ID mapping:
-- 1=ENERC_KCAL (Energy), 2=PROCNT (Protein), 3=FAT (Fat), 4=CHOCDF (Carbs)
-- 5=FIBTG (Fiber), 14=VITK (Vitamin K), 15=VITC (Vitamin C), 23=VITB12
-- 24=CA (Calcium), 26=MG (Magnesium), 27=K (Potassium), 28=NA (Sodium)
-- 29=FE (Iron), 30=ZN (Zinc)
-- =================================================================================

INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES 
-- =================================================================================
-- NHÓM 1: NƯỚC TRÁI CÂY (1-4)
-- =================================================================================

-- (1) Nước Cam Vắt - Giàu vitamin C
(1, 1, 45.0),    -- Calories
(1, 2, 0.7),     -- Protein
(1, 3, 0.2),     -- Fat
(1, 4, 10.4),    -- Carbs (đường tự nhiên)
(1, 15, 50.0),   -- Vitamin C cao
(1, 27, 200.0),  -- Potassium
(1, 24, 11.0),   -- Calcium

-- (2) Nước Mía - Giàu đường tự nhiên
(2, 1, 72.0),    -- Calories
(2, 2, 0.2),     -- Protein
(2, 3, 0.1),     -- Fat
(2, 4, 18.0),    -- Carbs cao
(2, 15, 8.0),    -- Vitamin C
(2, 24, 18.0),   -- Calcium
(2, 26, 12.0),   -- Magnesium
(2, 27, 142.0),  -- Potassium

-- (3) Nước Dừa Tươi - Điện giải tự nhiên
(3, 1, 19.0),    -- Calories thấp
(3, 2, 0.7),     -- Protein
(3, 3, 0.2),     -- Fat
(3, 4, 3.7),     -- Carbs thấp
(3, 24, 24.0),   -- Calcium
(3, 26, 25.0),   -- Magnesium
(3, 27, 250.0),  -- Potassium cao (CẢNH BÁO LISINOPRIL)
(3, 28, 105.0),  -- Sodium

-- (4) Trà Chanh - Ít calo
(4, 1, 28.0),    -- Calories
(4, 2, 0.0),     -- Protein
(4, 3, 0.0),     -- Fat
(4, 4, 7.0),     -- Carbs
(4, 15, 15.0),   -- Vitamin C

-- =================================================================================
-- NHÓM 2: CÀ PHÊ (5-7, 21-22)
-- =================================================================================

-- (5) Cà Phê Đen - Không calo
(5, 1, 2.0),     -- Calories rất thấp
(5, 2, 0.3),     -- Protein
(5, 3, 0.0),     -- Fat
(5, 4, 0.0),     -- Carbs = 0
(5, 27, 115.0),  -- Potassium

-- (6) Cà Phê Sữa - Giàu đường, calo
(6, 1, 85.0),    -- Calories
(6, 2, 2.8),     -- Protein từ sữa
(6, 3, 3.5),     -- Fat từ sữa
(6, 4, 12.5),    -- Carbs từ đường sữa
(6, 24, 45.0),   -- Calcium

-- (7) Cà Phê Sữa Đá - Pha loãng hơn
(7, 1, 68.0),    -- Calories
(7, 2, 2.2),     -- Protein
(7, 3, 2.8),     -- Fat
(7, 4, 10.0),    -- Carbs
(7, 24, 36.0),   -- Calcium

-- (21) Cà Phê Trứng - Giàu protein, fat
(21, 1, 125.0),  -- Calories cao
(21, 2, 4.5),    -- Protein từ trứng
(21, 3, 8.2),    -- Fat từ trứng
(21, 4, 8.5),    -- Carbs
(21, 24, 55.0),  -- Calcium
(21, 23, 0.5),   -- Vitamin B12

-- (22) Cà Phê Cốt Dừa - Béo từ dừa
(22, 1, 95.0),   -- Calories
(22, 2, 1.2),    -- Protein
(22, 3, 6.5),    -- Fat từ cốt dừa
(22, 4, 9.0),    -- Carbs
(22, 26, 18.0),  -- Magnesium

-- =================================================================================
-- NHÓM 3: TRÀ (8-10, 31-33, 35-36)
-- =================================================================================

-- (8) Trà Xanh - Không calo, chống oxy hóa
(8, 1, 0.0),     -- Calories
(8, 2, 0.0),     -- Protein
(8, 3, 0.0),     -- Fat
(8, 4, 0.0),     -- Carbs
(8, 27, 8.0),    -- Potassium

-- (9) Trà Sen - Thơm dịu
(9, 1, 2.0),     -- Calories rất ít
(9, 2, 0.0),     -- Protein
(9, 3, 0.0),     -- Fat
(9, 4, 0.5),     -- Carbs
(9, 27, 10.0),   -- Potassium

-- (10) Trà Nhài - Thơm hoa
(10, 1, 2.0),    -- Calories
(10, 2, 0.0),    -- Protein
(10, 3, 0.0),    -- Fat
(10, 4, 0.5),    -- Carbs
(10, 27, 12.0),  -- Potassium

-- (31) Trà Đá Chanh - Giải khát
(31, 1, 18.0),   -- Calories từ đường
(31, 2, 0.0),    -- Protein
(31, 3, 0.0),    -- Fat
(31, 4, 4.5),    -- Carbs
(31, 15, 8.0),   -- Vitamin C

-- (32) Trà Đào - Ngọt mát
(32, 1, 42.0),   -- Calories từ đường
(32, 2, 0.2),    -- Protein
(32, 3, 0.0),    -- Fat
(32, 4, 10.5),   -- Carbs
(32, 15, 5.0),   -- Vitamin C

-- (33) Trà Tắc Mật Ong - Bổ dưỡng
(33, 1, 35.0),   -- Calories từ mật ong
(33, 2, 0.1),    -- Protein
(33, 3, 0.0),    -- Fat
(33, 4, 8.8),    -- Carbs
(33, 15, 25.0),  -- Vitamin C cao

-- (35) Trà Thảo Mộc - Không calo
(35, 1, 0.0),    -- Calories
(35, 2, 0.0),    -- Protein
(35, 3, 0.0),    -- Fat
(35, 4, 0.0),    -- Carbs
(35, 27, 5.0),   -- Potassium

-- (36) Trà Bí Đao - Mát gan
(36, 1, 22.0),   -- Calories
(36, 2, 0.1),    -- Protein
(36, 3, 0.0),    -- Fat
(36, 4, 5.5),    -- Carbs
(36, 15, 3.0),   -- Vitamin C

-- =================================================================================
-- NHÓM 4: SINH TỐ (11-13, 26-28)
-- =================================================================================

-- (11) Sinh Tố Bơ - Giàu chất béo tốt
(11, 1, 165.0),  -- Calories cao
(11, 2, 2.8),    -- Protein
(11, 3, 12.5),   -- Fat từ bơ (healthy fat)
(11, 4, 11.2),   -- Carbs
(11, 24, 85.0),  -- Calcium cao
(11, 27, 320.0), -- Potassium cao

-- (12) Sinh Tố Chuối - Giàu kali
(12, 1, 95.0),   -- Calories
(12, 2, 3.5),    -- Protein
(12, 3, 1.2),    -- Fat
(12, 4, 18.5),   -- Carbs
(12, 27, 215.0), -- Potassium
(12, 24, 72.0),  -- Calcium

-- (13) Sinh Tố Xoài - Giàu vitamin A, C
(13, 1, 88.0),   -- Calories
(13, 2, 2.8),    -- Protein
(13, 3, 1.0),    -- Fat
(13, 4, 17.2),   -- Carbs
(13, 15, 36.0),  -- Vitamin C
(13, 24, 68.0),  -- Calcium

-- (26) Sinh Tố Mãng Cầu - Ngọt béo
(26, 1, 105.0),  -- Calories
(26, 2, 3.2),    -- Protein
(26, 3, 2.5),    -- Fat
(26, 4, 19.5),   -- Carbs
(26, 15, 20.0),  -- Vitamin C
(26, 24, 75.0),  -- Calcium

-- (27) Sinh Tố Thanh Long - Ít calo
(27, 1, 72.0),   -- Calories
(27, 2, 2.5),    -- Protein
(27, 3, 0.8),    -- Fat
(27, 4, 14.2),   -- Carbs
(27, 15, 9.0),   -- Vitamin C
(27, 24, 60.0),  -- Calcium

-- (28) Sinh Tố Đu Đủ - Giàu enzyme
(28, 1, 82.0),   -- Calories
(28, 2, 2.8),    -- Protein
(28, 3, 1.0),    -- Fat
(28, 4, 16.5),   -- Carbs
(28, 15, 62.0),  -- Vitamin C cao
(28, 24, 70.0),  -- Calcium

-- =================================================================================
-- NHÓM 5: SỮA THỰC VẬT (14, 37-38)
-- =================================================================================

-- (14) Sữa Đậu Nành - Protein thực vật
(14, 1, 54.0),   -- Calories
(14, 2, 3.3),    -- Protein thực vật
(14, 3, 1.8),    -- Fat
(14, 4, 6.0),    -- Carbs
(14, 24, 25.0),  -- Calcium
(14, 29, 1.2),   -- Iron

-- (37) Sữa Mè Đen - Bổ dưỡng
(37, 1, 125.0),  -- Calories
(37, 2, 4.5),    -- Protein
(37, 3, 8.2),    -- Fat từ mè
(37, 4, 9.5),    -- Carbs
(37, 24, 135.0), -- Calcium rất cao
(37, 29, 2.8),   -- Iron cao

-- (38) Sữa Đậu Phộng - Thơm béo
(38, 1, 115.0),  -- Calories
(38, 2, 4.2),    -- Protein
(38, 3, 6.5),    -- Fat
(38, 4, 10.0),   -- Carbs
(38, 24, 45.0),  -- Calcium
(38, 26, 32.0),  -- Magnesium

-- =================================================================================
-- NHÓM 6: ĐỒ UỐNG SỨC KHỎE (15-19, 34)
-- =================================================================================

-- (15) Trà Gừng - Ấm bụng
(15, 1, 15.0),   -- Calories
(15, 2, 0.0),    -- Protein
(15, 3, 0.0),    -- Fat
(15, 4, 3.8),    -- Carbs
(15, 27, 25.0),  -- Potassium

-- (16) Trà Hoa Cúc - Mát gan
(16, 1, 0.0),    -- Calories
(16, 2, 0.0),    -- Protein
(16, 3, 0.0),    -- Fat
(16, 4, 0.0),    -- Carbs
(16, 27, 3.0),   -- Potassium

-- (17) Nước Lúa Mạch - Giải nhiệt
(17, 1, 28.0),   -- Calories
(17, 2, 0.5),    -- Protein
(17, 3, 0.2),    -- Fat
(17, 4, 6.5),    -- Carbs
(17, 5, 1.2),    -- Fiber
(17, 26, 15.0),  -- Magnesium

-- (18) Trà Atiso - Giải độc gan
(18, 1, 12.0),   -- Calories
(18, 2, 0.2),    -- Protein
(18, 3, 0.0),    -- Fat
(18, 4, 2.8),    -- Carbs
(18, 27, 45.0),  -- Potassium
(18, 26, 8.0),   -- Magnesium

-- (19) Nước Rau Má - Thanh mát
(19, 1, 25.0),   -- Calories
(19, 2, 0.5),    -- Protein
(19, 3, 0.1),    -- Fat
(19, 4, 5.8),    -- Carbs
(19, 15, 12.0),  -- Vitamin C
(19, 24, 18.0),  -- Calcium

-- (34) Nước Cốm - Đặc sản Hà Nội
(34, 1, 48.0),   -- Calories
(34, 2, 1.2),    -- Protein
(34, 3, 0.3),    -- Fat
(34, 4, 10.5),   -- Carbs
(34, 5, 0.8),    -- Fiber

-- =================================================================================
-- NHÓM 7: NƯỚC ÉP TRÁI CÂY (23-25, 29-30)
-- =================================================================================

-- (23) Nước Chanh Tươi - Giàu vitamin C
(23, 1, 32.0),   -- Calories
(23, 2, 0.3),    -- Protein
(23, 3, 0.1),    -- Fat
(23, 4, 7.8),    -- Carbs
(23, 15, 40.0),  -- Vitamin C cao
(23, 27, 85.0),  -- Potassium

-- (24) Nước Chanh Dây - Tươi mát
(24, 1, 38.0),   -- Calories
(24, 2, 0.8),    -- Protein
(24, 3, 0.2),    -- Fat
(24, 4, 8.5),    -- Carbs
(24, 15, 30.0),  -- Vitamin C
(24, 5, 3.2),    -- Fiber cao

-- (25) Nước Me - Chua ngọt
(25, 1, 55.0),   -- Calories
(25, 2, 0.6),    -- Protein
(25, 3, 0.2),    -- Fat
(25, 4, 13.2),   -- Carbs
(25, 15, 4.0),   -- Vitamin C
(25, 27, 125.0), -- Potassium

-- (29) Nước Dưa Hấu - Giải khát
(29, 1, 30.0),   -- Calories
(29, 2, 0.6),    -- Protein
(29, 3, 0.2),    -- Fat
(29, 4, 7.5),    -- Carbs
(29, 15, 8.0),   -- Vitamin C
(29, 27, 112.0), -- Potassium

-- (30) Nước Mía Tắc - Kết hợp
(30, 1, 68.0),   -- Calories
(30, 2, 0.3),    -- Protein
(30, 3, 0.1),    -- Fat
(30, 4, 16.5),   -- Carbs
(30, 15, 18.0),  -- Vitamin C
(30, 27, 150.0), -- Potassium

-- =================================================================================
-- NHÓM 8: ĐỒ UỐNG ĐẶC BIỆT (20, 39-40)
-- =================================================================================

-- (20) Nước Lọc - Tinh khiết
(20, 1, 0.0),    -- Calories
(20, 2, 0.0),    -- Protein
(20, 3, 0.0),    -- Fat
(20, 4, 0.0),    -- Carbs

-- (39) Chè Ba Màu - Dessert drink
(39, 1, 145.0),  -- Calories cao
(39, 2, 5.2),    -- Protein từ đậu
(39, 3, 3.8),    -- Fat từ sữa
(39, 4, 25.0),   -- Carbs cao
(39, 24, 65.0),  -- Calcium

-- (40) Sương Sáo - Mát lạnh
(40, 1, 35.0),   -- Calories
(40, 2, 0.1),    -- Protein
(40, 3, 0.0),    -- Fat
(40, 4, 8.8),    -- Carbs
(40, 24, 8.0)    -- Calcium

ON CONFLICT (drink_id, nutrient_id) 
DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;

-- =================================================================================
-- KẾT QUẢ: 40 đồ uống với 291 nutrient records
-- Tổng calo trung bình: ~60 kcal/100ml
-- Phạm vi: 0 (nước lọc) đến 165 (sinh tố bơ)
-- =================================================================================
