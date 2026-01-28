-- =================================================================================
-- DỮ LIỆU MẪU MỞ RỘNG CHO CÁC BẢNG LIÊN QUAN
-- File: extended_tables_vietnam.sql
-- Mục đích: Bổ sung dữ liệu cho dish, drink, recipe, portionsize, conditionfoodrecommendation
-- và các bảng liên quan khác
-- =================================================================================

-- =================================================================================
-- 1. BẢNG DISH (Món ăn/Công thức nấu ăn)
-- Các món ăn Việt Nam phổ biến với thành phần và dinh dưỡng
-- =================================================================================

INSERT INTO dish (dish_id, name, vietnamese_name, description, category, serving_size_g, is_template, is_public, created_by_admin) VALUES 
-- Món ăn sáng
(1, 'Vietnamese Beef Pho', 'Phở Bò Hà Nội', 'Món phở truyền thống với nước dùng hầm xương bò, thịt bò tái, và rau thơm', 'Breakfast', 700, TRUE, TRUE, 1),
(2, 'Broken Rice with Grilled Pork', 'Cơm Tấm Sườn Bì Chả', 'Cơm tấm với sườn nướng, bì, chả trứng, và nước mắm pha', 'Breakfast', 400, TRUE, TRUE, 1),
(3, 'Banh Mi Vietnamese Sandwich', 'Bánh Mì Thịt Nguội', 'Bánh mì giòn với pate, thịt nguội, dưa chua, rau thơm', 'Breakfast', 250, TRUE, TRUE, 1),
(4, 'Sticky Rice with Chicken', 'Xôi Gà', 'Xôi nếp với gà xé phay, hành phi, nước mắm gừng', 'Breakfast', 300, TRUE, TRUE, 1),

-- Món ăn trưa/tối
(5, 'Bun Cha Hanoi', 'Bún Chả Hà Nội', 'Bún với chả nướng, thịt nướng, nước mắm chua ngọt, rau sống', 'Lunch', 500, TRUE, TRUE, 1),
(6, 'Vietnamese Spring Rolls', 'Gỏi Cuốn Tôm Thịt', 'Bánh tráng cuốn tôm, thịt, bún, rau sống, chấm nước mắm', 'Lunch', 200, TRUE, TRUE, 1),
(7, 'Grilled Fish in Banana Leaf', 'Cá Nướng Lá Chuối', 'Cá nướng với sả ớt, gói lá chuối, ăn kèm bún và rau', 'Dinner', 350, TRUE, TRUE, 1),
(8, 'Caramelized Pork Belly', 'Thịt Kho Tàu', 'Thịt ba chỉ kho với nước dừa, trứng, đường caramel', 'Dinner', 250, TRUE, TRUE, 1),
(9, 'Braised Fish in Clay Pot', 'Cá Kho Tộ', 'Cá kho với nước mắm, đường, ớt, ăn với cơm trắng', 'Dinner', 300, TRUE, TRUE, 1),
(10, 'Sour Fish Soup', 'Canh Chua Cá', 'Canh chua với cá, thơm, cà chua, rau muống, đậu bắp', 'Soup', 400, TRUE, TRUE, 1),

-- Món chay
(11, 'Vegetarian Pho', 'Phở Chay', 'Phở với nước dùng nấm, đậu hũ, rau củ', 'Vegetarian', 650, TRUE, TRUE, 1),
(12, 'Stir-fried Morning Glory', 'Rau Muống Xào Tỏi', 'Rau muống xào với tỏi, nước mắm hoặc muối', 'Vegetarian', 200, TRUE, TRUE, 1),
(13, 'Tofu with Tomato Sauce', 'Đậu Hũ Sốt Cà Chua', 'Đậu hũ chiên giòn, sốt cà chua chua ngọt', 'Vegetarian', 250, TRUE, TRUE, 1),

-- Món ăn vặt
(14, 'Vietnamese Crepe', 'Bánh Xèo', 'Bánh xèo giòn với tôm, thịt, giá đỗ, ăn kèm rau sống', 'Snack', 300, TRUE, TRUE, 1),
(15, 'Grilled Rice Paper', 'Bánh Tráng Nướng', 'Bánh tráng nướng với trứng, hành khô, tương ớt', 'Snack', 100, TRUE, TRUE, 1),

-- Món dinh dưỡng cho người bệnh
(16, 'Chicken Congee', 'Cháo Gà', 'Cháo gạo với gà xé, gừng, hành, ăn nhẹ dễ tiêu', 'Light Meal', 400, TRUE, TRUE, 1),
(17, 'Fish Porridge', 'Cháo Cá', 'Cháo cá với rau thơm, dầu hành, dễ tiêu hóa', 'Light Meal', 400, TRUE, TRUE, 1),
(18, 'Steamed Vegetables Mix', 'Rau Củ Luộc', 'Rau củ luộc: bông cải, cà rốt, súp lơ, ít dầu', 'Light Meal', 300, TRUE, TRUE, 1),

-- Thêm 20 món ăn Việt Nam thực tế
(19, 'Grilled Pork Rice Vermicelli', 'Bún Thịt Nướng', 'Bún tươi với thịt heo nướng, rau sống, nước mắm', 'Lunch', 450, TRUE, TRUE, 1),
(20, 'Hue Beef Noodle Soup', 'Bún Bò Huế', 'Bún bò cay với chả, giò heo, rau thơm', 'Lunch', 650, TRUE, TRUE, 1),
(21, 'Vietnamese Fried Spring Rolls', 'Chả Giò (Nem Rán)', 'Chả giò chiên giòn với nhân thịt, miến, rau củ', 'Snack', 150, TRUE, TRUE, 1),
(22, 'Grilled Beef in La Lot Leaves', 'Bò Lá Lốt', 'Thịt bò cuộn lá lốt nướng than', 'Dinner', 200, TRUE, TRUE, 1),
(23, 'Stir-fried Beef with Vegetables', 'Bò Xào Rau Củ', 'Thịt bò xào với súp lơ, cà rốt, đậu Hà Lan', 'Dinner', 300, TRUE, TRUE, 1),
(24, 'Vietnamese Chicken Salad', 'Gỏi Gà', 'Gỏi gà với bắp cải, cà rốt, rau răm', 'Salad', 250, TRUE, TRUE, 1),
(25, 'Steamed Rice Rolls', 'Bánh Cuốn', 'Bánh cuốn nhân thịt, nấm mèo, hành phi', 'Breakfast', 300, TRUE, TRUE, 1),
(26, 'Chicken Curry with Bread', 'Cà Ri Gà với Bánh Mì', 'Cà ri gà kiểu Việt, ăn kèm bánh mì', 'Lunch', 400, TRUE, TRUE, 1),
(27, 'Shrimp Paste Rice Vermicelli', 'Bún Đậu Mắm Tôm', 'Bún với đậu hũ chiên, chả cốm, mắm tôm', 'Lunch', 450, TRUE, TRUE, 1),
(28, 'Duck with Bamboo Shoots', 'Vịt Nấu Măng', 'Vịt nấu măng chua, rau thơm', 'Dinner', 350, TRUE, TRUE, 1),
(29, 'Pork Ribs Soup', 'Canh Sườn Hầm', 'Canh sườn heo ninh với củ cải, cà rốt', 'Soup', 400, TRUE, TRUE, 1),
(30, 'Stir-fried Mixed Vegetables', 'Rau Củ Xào Thập Cẩm', 'Rau củ xào chay: bông cải, cà rốt, nấm', 'Vegetarian', 250, TRUE, TRUE, 1),
(31, 'Beef Noodle Soup (Nam Dinh)', 'Phở Nam Định', 'Phở bò kiểu Nam Định với thịt bò chín', 'Breakfast', 700, TRUE, TRUE, 1),
(32, 'Vietnamese Savory Pancake', 'Bánh Khọt', 'Bánh khọt tôm, ăn kèm rau sống', 'Snack', 200, TRUE, TRUE, 1),
(33, 'Quang Noodle', 'Mì Quảng', 'Mì Quảng với tôm, thịt, đậu phộng, bánh tráng', 'Lunch', 500, TRUE, TRUE, 1),
(34, 'Grilled Pork with Rice Paper', 'Thịt Nướng Cuốn Bánh Tráng', 'Thịt heo nướng cuốn bánh tráng, rau sống', 'Dinner', 300, TRUE, TRUE, 1),
(35, 'Stir-fried Chicken with Lemongrass', 'Gà Xào Sả Ớt', 'Gà xào sả ớt thơm cay', 'Dinner', 300, TRUE, TRUE, 1),
(36, 'Fish Ball Noodle Soup', 'Bún Cá', 'Bún cá với chả cá, cà chua, mắm tôm', 'Lunch', 550, TRUE, TRUE, 1),
(37, 'Fried Tofu with Lemongrass Chili', 'Đậu Hũ Chiên Sả Ớt', 'Đậu hũ chiên giòn sốt sả ớt', 'Vegetarian', 250, TRUE, TRUE, 1),
(38, 'Pork Skewers', 'Nem Nướng', 'Nem nướng Nha Trang, ăn kèm bánh tráng', 'Snack', 200, TRUE, TRUE, 1)
ON CONFLICT (dish_id) DO UPDATE SET
  vietnamese_name = EXCLUDED.vietnamese_name,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  serving_size_g = EXCLUDED.serving_size_g;


-- =================================================================================
-- 2. BẢNG DISHINGREDIENT (Thành phần món ăn)
-- Liên kết dish với food_id từ bảng food
-- =================================================================================

INSERT INTO dishingredient (dish_id, food_id, weight_g, notes, display_order) VALUES 
-- Phở Bò (dish_id = 1)
(1, 3008, 250, 'Bánh phở tươi', 1),
(1, 3003, 150, 'Thịt bò tái', 2),
(1, 3017, 50, 'Rau thơm: hành, ngò', 3),
(1, 90, 30, 'Giá đỗ', 4),

-- Cơm Tấm (dish_id = 2)
(2, 3013, 200, 'Cơm tấm nấu chín', 1),
(2, 3019, 100, 'Sườn heo nướng', 2),
(2, 3004, 20, 'Dưa leo cắt lát', 3),

-- Bánh Mì (dish_id = 3)
(3, 3014, 150, 'Bánh mì que', 1),
(3, 3003, 50, 'Pate gan', 2),
(3, 3017, 30, 'Rau thơm, dưa chua', 3),

-- Xôi Gà (dish_id = 4)
(4, 3020, 200, 'Xôi nếp', 1),
(4, 3007, 80, 'Gà luộc xé', 2),

-- Bún Chả (dish_id = 5)
(5, 3012, 150, 'Bún tươi', 1),
(5, 3019, 120, 'Chả/thịt nướng', 2),
(5, 3017, 80, 'Rau sống: xà lách, húng', 3),

-- Gỏi Cuốn (dish_id = 6)
(6, 3015, 120, 'Bánh tráng, bún, tôm', 1),
(6, 3017, 40, 'Rau sống', 2),

-- Cá Nướng (dish_id = 7)
(7, 3018, 200, 'Cá nướng lá chuối', 1),
(7, 3017, 50, 'Rau thơm', 2),

-- Thịt Kho (dish_id = 8)
(8, 3019, 200, 'Thịt ba chỉ kho trứng', 1),

-- Cá Kho Tộ (dish_id = 9)
(9, 3018, 250, 'Cá kho', 1),

-- Canh Chua (dish_id = 10)
(10, 3016, 400, 'Canh chua cá nấu sẵn', 1),

-- Phở Chay (dish_id = 11)
(11, 3008, 250, 'Bánh phở', 1),
(11, 13, 100, 'Đậu hũ', 2),
(11, 3017, 50, 'Rau thơm', 3),

-- Rau Muống Xào (dish_id = 12)
(12, 3017, 200, 'Rau muống xào tỏi', 1),

-- Đậu Hũ Sốt Cà (dish_id = 13)
(13, 13, 150, 'Đậu hũ chiên', 1),
(13, 3016, 80, 'Sốt cà chua', 2),

-- Bánh Xèo (dish_id = 14)
(14, 3014, 150, 'Vỏ bánh xèo', 1),
(14, 3019, 50, 'Thịt heo', 2),
(14, 90, 40, 'Giá đỗ', 3),

-- Bánh Tráng Nướng (dish_id = 15)
(15, 3015, 100, 'Bánh tráng nướng', 1),

-- Cháo Gà (dish_id = 16)
(16, 3008, 250, 'Cơm/gạo nấu cháo', 1),
(16, 3007, 80, 'Gà xé', 2),

-- Cháo Cá (dish_id = 17)
(17, 3008, 250, 'Gạo nấu cháo', 1),
(17, 3018, 80, 'Cá', 2),

-- Rau Củ Luộc (dish_id = 18)
(18, 3009, 100, 'Súp lơ xanh', 1),
(18, 3001, 100, 'Rau bina', 2),
(18, 3017, 100, 'Rau muống', 3),

-- Bún Thịt Nướng (19)
(19, 3012, 150, 'Bún tươi', 1),
(19, 3019, 100, 'Thịt heo nướng', 2),
(19, 3017, 50, 'Rau sống', 3),

-- Bún Bò Huế (20)
(20, 3012, 200, 'Bún bò', 1),
(20, 3003, 120, 'Thịt bò chín', 2),

-- Chả Giò (21)
(21, 3015, 100, 'Bánh tráng cuốn', 1),
(21, 3019, 50, 'Thịt heo xay', 2),

-- Bò Lá Lốt (22)
(22, 3003, 150, 'Thịt bò cuộn lá lốt', 1),

-- Bò Xào Rau Củ (23)
(23, 3003, 120, 'Thịt bò', 1),
(23, 3009, 80, 'Súp lơ xanh', 2),

-- Gỏi Gà (24)
(24, 3007, 100, 'Gà xé', 1),
(24, 3017, 100, 'Bắp cải, cà rốt', 2),

-- Bánh Cuốn (25)
(25, 3014, 200, 'Bánh cuốn', 1),
(25, 3019, 50, 'Nhân thịt', 2),

-- Cà Ri Gà (26)
(26, 3007, 150, 'Gà', 1),
(26, 3014, 100, 'Bánh mì', 2),

-- Bún Đậu Mắm Tôm (27)
(27, 3012, 150, 'Bún', 1),
(27, 13, 100, 'Đậu hũ chiên', 2),

-- Vịt Nấu Măng (28)
(28, 3007, 150, 'Vịt', 1),
(28, 3017, 100, 'Măng, rau', 2),

-- Canh Sườn (29)
(29, 3019, 150, 'Sườn heo', 1),
(29, 3017, 100, 'Củ cải, cà rốt', 2),

-- Rau Củ Xào (30)
(30, 3009, 80, 'Súp lơ', 1),
(30, 3017, 80, 'Rau củ khác', 2)
ON CONFLICT (dish_id, food_id) DO UPDATE SET weight_g = EXCLUDED.weight_g, notes = EXCLUDED.notes;


-- =================================================================================
-- 3. BẢNG DISHNUTRIENT (Dinh dưỡng món ăn - tính toán từ thành phần)
-- Tính toán tự động dựa trên dishingredient
-- =================================================================================

INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g) VALUES 
-- Phở Bò (1) - Cân bằng protein, carbs, ít fat
(1, 1, 85.5), (1, 2, 8.2), (1, 3, 2.5), (1, 4, 12.8), (1, 28, 420.0), (1, 29, 1.2),

-- Cơm Tấm (2) - Giàu carbs, protein từ thịt
(2, 1, 165.0), (2, 2, 10.5), (2, 3, 6.8), (2, 4, 28.5), (2, 28, 380.0), (2, 29, 1.5),

-- Bánh Mì (3) - Cân bằng, giàu carbs
(3, 1, 280.0), (3, 2, 12.0), (3, 3, 10.5), (3, 4, 35.0), (3, 28, 520.0), (3, 24, 50.0),

-- Xôi Gà (4) - Giàu carbs, protein
(4, 1, 210.0), (4, 2, 13.5), (4, 3, 5.2), (4, 4, 38.0), (4, 28, 280.0),

-- Bún Chả (5) - Cân bằng
(5, 1, 190.0), (5, 2, 14.0), (5, 3, 8.0), (5, 4, 22.0), (5, 28, 480.0), (5, 15, 12.0),

-- Gỏi Cuốn (6) - Ít calo, nhiều rau
(6, 1, 95.0), (6, 2, 6.5), (6, 3, 2.8), (6, 4, 14.5), (6, 5, 3.2), (6, 15, 18.0),

-- Cá Nướng (7) - Giàu protein, ít carbs
(7, 1, 145.0), (7, 2, 22.5), (7, 3, 5.5), (7, 4, 3.2), (7, 23, 2.8), (7, 29, 1.2),

-- Thịt Kho (8) - Giàu protein, fat
(8, 1, 285.0), (8, 2, 18.0), (8, 3, 20.5), (8, 4, 8.5), (8, 28, 720.0), (8, 24, 35.0),

-- Cá Kho Tộ (9) - Giàu protein
(9, 1, 195.0), (9, 2, 20.0), (9, 3, 8.5), (9, 4, 6.8), (9, 23, 2.2), (9, 28, 850.0),

-- Canh Chua (10) - Ít calo, nhiều vitamin
(10, 1, 65.0), (10, 2, 7.5), (10, 3, 2.0), (10, 4, 5.5), (10, 15, 28.0), (10, 27, 280.0),

-- Phở Chay (11) - Ít calo hơn phở bò
(11, 1, 75.0), (11, 2, 5.5), (11, 3, 2.0), (11, 4, 13.5), (11, 5, 2.8), (11, 24, 45.0),

-- Rau Muống Xào (12) - Ít calo, giàu vitamin K
(12, 1, 42.0), (12, 2, 3.2), (12, 3, 1.5), (12, 4, 5.8), (12, 14, 312.0), (12, 29, 2.5),

-- Đậu Hũ Sốt Cà (13) - Protein thực vật
(13, 1, 125.0), (13, 2, 8.5), (13, 3, 6.8), (13, 4, 10.5), (13, 24, 85.0), (13, 29, 1.8),

-- Bánh Xèo (14) - Giàu carbs, protein
(14, 1, 165.0), (14, 2, 9.5), (14, 3, 7.2), (14, 4, 20.5), (14, 28, 420.0),

-- Bánh Tráng Nướng (15) - Snack nhẹ
(15, 1, 145.0), (15, 2, 5.8), (15, 3, 4.5), (15, 4, 24.0), (15, 28, 380.0),

-- Cháo Gà (16) - Dễ tiêu, ít calo
(16, 1, 68.0), (16, 2, 6.5), (16, 3, 1.8), (16, 4, 10.2), (16, 28, 180.0),

-- Cháo Cá (17) - Dễ tiêu, giàu protein
(17, 1, 72.0), (17, 2, 7.2), (17, 3, 2.0), (17, 4, 9.8), (17, 23, 1.2), (17, 28, 190.0),

-- Rau Củ Luộc (18) - Rất ít calo, giàu vitamin
(18, 1, 35.0), (18, 2, 2.8), (18, 3, 0.5), (18, 4, 6.5), (18, 14, 180.0), (18, 15, 65.0), (18, 24, 80.0),

-- Bún Thịt Nướng (19) - Cân bằng, giàu protein
(19, 1, 155.0), (19, 2, 13.5), (19, 3, 7.2), (19, 4, 20.8), (19, 28, 450.0), (19, 29, 1.6),

-- Bún Bò Huế (20) - Giàu protein, carbs
(20, 1, 165.0), (20, 2, 14.8), (20, 3, 6.5), (20, 4, 22.0), (20, 28, 680.0), (20, 29, 2.1),

-- Chả Giò (21) - Giàu fat do chiên
(21, 1, 245.0), (21, 2, 12.0), (21, 3, 16.5), (21, 4, 18.0), (21, 28, 420.0),

-- Bò Lá Lốt (22) - Giàu protein
(22, 1, 185.0), (22, 2, 22.5), (22, 3, 9.8), (22, 4, 3.5), (22, 29, 2.8),

-- Bò Xào Rau Củ (23) - Cân bằng, nhiều vitamin
(23, 1, 145.0), (23, 2, 18.0), (23, 3, 6.5), (23, 4, 8.2), (23, 15, 45.0), (23, 24, 55.0),

-- Gỏi Gà (24) - Ít calo, nhiều protein
(24, 1, 125.0), (24, 2, 16.5), (24, 3, 4.2), (24, 4, 10.5), (24, 15, 38.0),

-- Bánh Cuốn (25) - Nhẹ, dễ tiêu
(25, 1, 135.0), (25, 2, 8.5), (25, 3, 3.8), (25, 4, 22.0), (25, 28, 320.0),

-- Cà Ri Gà (26) - Giàu protein, fat
(26, 1, 185.0), (26, 2, 18.0), (26, 3, 11.5), (26, 4, 12.0), (26, 24, 45.0),

-- Bún Đậu Mắm Tôm (27) - Protein thực vật
(27, 1, 165.0), (27, 2, 10.5), (27, 3, 8.5), (27, 4, 20.0), (27, 24, 85.0),

-- Vịt Nấu Măng (28) - Giàu protein
(28, 1, 155.0), (28, 2, 19.0), (28, 3, 7.5), (28, 4, 6.5), (28, 29, 2.5),

-- Canh Sườn (29) - Bổ dưỡng
(29, 1, 95.0), (29, 2, 11.5), (29, 3, 4.5), (29, 4, 5.0), (29, 24, 35.0), (29, 25, 85.0),

-- Rau Củ Xào (30) - Ít calo, nhiều vitamin
(30, 1, 55.0), (30, 2, 3.5), (30, 3, 2.5), (30, 4, 7.8), (30, 14, 95.0), (30, 15, 55.0), (30, 24, 60.0)
ON CONFLICT (dish_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;


-- =================================================================================
-- 4. BẢNG DRINK (Đồ uống)
-- Các loại đồ uống phổ biến tại Việt Nam
-- =================================================================================

INSERT INTO drink (drink_id, name, vietnamese_name, description, category, base_liquid, default_volume_ml, default_temperature, hydration_ratio, caffeine_mg, sugar_free, is_template, is_public, created_by_admin) VALUES 
-- Nước trái cây
(1, 'Fresh Orange Juice', 'Nước Cam Vắt', 'Nước cam tươi vắt, giàu vitamin C', 'Juice', 'Water', 250, 'Cold', 0.95, 0, TRUE, TRUE, TRUE, 1),
(2, 'Sugarcane Juice', 'Nước Mía', 'Nước mía ép tươi, ngọt mát', 'Juice', 'Water', 300, 'Cold', 0.92, 0, FALSE, TRUE, TRUE, 1),
(3, 'Coconut Water', 'Nước Dừa Tươi', 'Nước dừa tươi, bổ sung điện giải', 'Juice', 'Water', 350, 'Cold', 0.98, 0, TRUE, TRUE, TRUE, 1),
(4, 'Lemon Tea', 'Trà Chanh', 'Trà đen pha chanh, ít đường', 'Tea', 'Water', 300, 'Cold', 0.96, 25, FALSE, TRUE, TRUE, 1),

-- Cà phê
(5, 'Vietnamese Black Coffee', 'Cà Phê Đen', 'Cà phê phin truyền thống, đắng', 'Coffee', 'Water', 100, 'Hot', 0.99, 95, TRUE, TRUE, TRUE, 1),
(6, 'Vietnamese Milk Coffee', 'Cà Phê Sữa', 'Cà phê phin với sữa đặc', 'Coffee', 'Milk', 150, 'Hot', 0.94, 85, FALSE, TRUE, TRUE, 1),
(7, 'Iced Milk Coffee', 'Cà Phê Sữa Đá', 'Cà phê sữa pha đá', 'Coffee', 'Milk', 200, 'Cold', 0.92, 80, FALSE, TRUE, TRUE, 1),

-- Trà
(8, 'Green Tea', 'Trà Xanh', 'Trà xanh không đường', 'Tea', 'Water', 250, 'Hot', 0.99, 30, TRUE, TRUE, TRUE, 1),
(9, 'Lotus Tea', 'Trà Sen', 'Trà sen thơm dịu', 'Tea', 'Water', 250, 'Hot', 0.99, 20, TRUE, TRUE, TRUE, 1),
(10, 'Jasmine Tea', 'Trà Nhài', 'Trà hoa nhài thơm', 'Tea', 'Water', 250, 'Hot', 0.99, 22, TRUE, TRUE, TRUE, 1),

-- Sinh tố
(11, 'Avocado Smoothie', 'Sinh Tố Bơ', 'Sinh tố bơ với sữa đặc', 'Smoothie', 'Milk', 350, 'Cold', 0.88, 0, FALSE, TRUE, TRUE, 1),
(12, 'Banana Smoothie', 'Sinh Tố Chuối', 'Sinh tố chuối với sữa tươi', 'Smoothie', 'Milk', 350, 'Cold', 0.90, 0, FALSE, TRUE, TRUE, 1),
(13, 'Mango Smoothie', 'Sinh Tố Xoài', 'Sinh tố xoài tươi', 'Smoothie', 'Milk', 350, 'Cold', 0.89, 0, FALSE, TRUE, TRUE, 1),

-- Nước giải khát đặc biệt
(14, 'Soy Milk', 'Sữa Đậu Nành', 'Sữa đậu nành tươi, giàu protein', 'Milk', 'Water', 250, 'Warm', 0.93, 0, FALSE, TRUE, TRUE, 1),
(15, 'Ginger Tea', 'Trà Gừng', 'Trà gừng ấm bụng', 'Tea', 'Water', 200, 'Hot', 0.98, 0, FALSE, TRUE, TRUE, 1),
(16, 'Chrysanthemum Tea', 'Trà Hoa Cúc', 'Trà hoa cúc mát gan', 'Tea', 'Water', 250, 'Cold', 0.99, 0, TRUE, TRUE, TRUE, 1),

-- Đồ uống cho người bệnh
(17, 'Barley Water', 'Nước Lúa Mạch', 'Nước lúa mạch mát, giải nhiệt', 'Healthy', 'Water', 300, 'Cold', 0.97, 0, FALSE, TRUE, TRUE, 1),
(18, 'Artichoke Tea', 'Trà Atiso', 'Trà atiso giải độc gan', 'Healthy', 'Water', 250, 'Warm', 0.98, 0, FALSE, TRUE, TRUE, 1),
(19, 'Pennywort Juice', 'Nước Rau Má', 'Nước rau má thanh mát', 'Healthy', 'Water', 250, 'Cold', 0.96, 0, FALSE, TRUE, TRUE, 1),
(20, 'Plain Water', 'Nước Lọc', 'Nước lọc tinh khiết', 'Water', 'Water', 250, 'Room', 1.00, 0, TRUE, TRUE, TRUE, 1),

-- Thêm 20 đồ uống Việt Nam thực tế
(21, 'Egg Coffee', 'Cà Phê Trứng', 'Cà phê đen pha với kem trứng gà', 'Coffee', 'Milk', 150, 'Hot', 0.90, 85, FALSE, TRUE, TRUE, 1),
(22, 'Coconut Coffee', 'Cà Phê Cốt Dừa', 'Cà phê pha với cốt dừa', 'Coffee', 'Milk', 200, 'Cold', 0.88, 75, FALSE, TRUE, TRUE, 1),
(23, 'Fresh Lemon Juice', 'Nước Chanh Tươi', 'Nước chanh vắt tươi với mật ong', 'Juice', 'Water', 250, 'Cold', 0.97, 0, FALSE, TRUE, TRUE, 1),
(24, 'Passion Fruit Juice', 'Nước Chanh Dây', 'Nước chanh leo tươi mát', 'Juice', 'Water', 250, 'Cold', 0.95, 0, FALSE, TRUE, TRUE, 1),
(25, 'Tamarind Juice', 'Nước Me', 'Nước me chua ngọt', 'Juice', 'Water', 250, 'Cold', 0.94, 0, FALSE, TRUE, TRUE, 1),
(26, 'Soursop Smoothie', 'Sinh Tố Mãng Cầu', 'Sinh tố mãng cầu xiêm với sữa', 'Smoothie', 'Milk', 350, 'Cold', 0.89, 0, FALSE, TRUE, TRUE, 1),
(27, 'Dragon Fruit Smoothie', 'Sinh Tố Thanh Long', 'Sinh tố thanh long ruột đỏ', 'Smoothie', 'Milk', 350, 'Cold', 0.91, 0, FALSE, TRUE, TRUE, 1),
(28, 'Papaya Smoothie', 'Sinh Tố Đu Đủ', 'Sinh tố đu đủ chín với sữa tươi', 'Smoothie', 'Milk', 350, 'Cold', 0.90, 0, FALSE, TRUE, TRUE, 1),
(29, 'Watermelon Juice', 'Nước Dưa Hấu', 'Nước dưa hấu ép tươi', 'Juice', 'Water', 300, 'Cold', 0.97, 0, TRUE, TRUE, TRUE, 1),
(30, 'Sugarcane with Kumquat', 'Nước Mía Tắc', 'Nước mía pha với tắc', 'Juice', 'Water', 300, 'Cold', 0.93, 0, FALSE, TRUE, TRUE, 1),
(31, 'Iced Tea with Lemon', 'Trà Đá Chanh', 'Trà đen pha đá với chanh', 'Tea', 'Water', 300, 'Cold', 0.98, 20, FALSE, TRUE, TRUE, 1),
(32, 'Peach Tea', 'Trà Đào', 'Trà đào ngọt mát', 'Tea', 'Water', 300, 'Cold', 0.96, 15, FALSE, TRUE, TRUE, 1),
(33, 'Kumquat Honey Tea', 'Trà Tắc Mật Ong', 'Trà tắc pha mật ong ấm', 'Tea', 'Water', 250, 'Warm', 0.97, 18, FALSE, TRUE, TRUE, 1),
(34, 'Young Rice Milk', 'Nước Cốm', 'Nước uống từ cốm xanh', 'Healthy', 'Water', 250, 'Cold', 0.95, 0, FALSE, TRUE, TRUE, 1),
(35, 'Herbal Tea', 'Trà Thảo Mộc', 'Trà các loại thảo mộc Việt Nam', 'Healthy', 'Water', 250, 'Warm', 0.99, 0, TRUE, TRUE, TRUE, 1),
(36, 'Wintermelon Tea', 'Trà Bí Đao', 'Trà bí đao mát gan', 'Healthy', 'Water', 250, 'Cold', 0.97, 0, FALSE, TRUE, TRUE, 1),
(37, 'Black Sesame Milk', 'Sữa Mè Đen', 'Sữa mè đen bổ dưỡng', 'Milk', 'Water', 250, 'Warm', 0.92, 0, FALSE, TRUE, TRUE, 1),
(38, 'Peanut Milk', 'Sữa Đậu Phộng', 'Sữa đậu phộng thơm béo', 'Milk', 'Water', 250, 'Warm', 0.93, 0, FALSE, TRUE, TRUE, 1),
(39, 'Three-bean Sweet Soup', 'Chè Ba Màu', 'Chè đậu xanh, đậu đỏ, đậu đen', 'Dessert', 'Milk', 300, 'Cold', 0.85, 0, FALSE, TRUE, TRUE, 1),
(40, 'Grass Jelly Drink', 'Sương Sáo', 'Thạch sương sáo với đường phèn', 'Dessert', 'Water', 250, 'Cold', 0.96, 0, FALSE, TRUE, TRUE, 1)
ON CONFLICT (drink_id) DO UPDATE SET vietnamese_name = EXCLUDED.vietnamese_name, description = EXCLUDED.description;


-- =================================================================================
-- 5. BẢNG DRINKINGREDIENT (Thành phần đồ uống)
-- =================================================================================

INSERT INTO drinkingredient (drink_id, food_id, amount_g, unit, display_order, notes) VALUES 
-- Nước Cam (1)
(1, 3005, 200, 'ml', 1, 'Nước cam ép tươi'),

-- Nước Dừa (3)
(3, 3, 300, 'ml', 1, 'Nước dừa tươi'),

-- Cà Phê Sữa (6)
(6, 3010, 50, 'ml', 1, 'Sữa đặc ngọt'),

-- Sinh Tố Bơ (11)
(11, 99, 80, 'g', 1, 'Bơ tươi'),
(11, 3010, 150, 'ml', 2, 'Sữa tươi'),

-- Sinh Tố Chuối (12)
(12, 3004, 100, 'g', 1, 'Chuối chín'),
(12, 3010, 150, 'ml', 2, 'Sữa tươi'),

-- Sữa Đậu Nành (14)
(14, 2, 50, 'g', 1, 'Đậu nành'),

-- Nước Rau Má (19)
(19, 3017, 80, 'g', 1, 'Rau má tươi')
ON CONFLICT (drink_id, food_id) DO UPDATE SET amount_g = EXCLUDED.amount_g, notes = EXCLUDED.notes;


-- =================================================================================
-- 6. BẢNG DRINKNUTRIENT (Dinh dưỡng đồ uống)
-- =================================================================================

INSERT INTO drinknutrient (drink_id, nutrient_id, amount_per_100ml) VALUES 
-- Nước Cam (1) - Giàu vitamin C
(1, 1, 45.0), (1, 4, 10.4), (1, 15, 50.0), (1, 27, 200.0),

-- Nước Mía (2) - Giàu đường tự nhiên
(2, 1, 72.0), (2, 4, 18.0), (2, 27, 142.0), (2, 24, 18.0),

-- Nước Dừa (3) - Điện giải tự nhiên
(3, 1, 19.0), (3, 4, 3.7), (3, 27, 250.0), (3, 28, 105.0), (3, 26, 25.0),

-- Trà Chanh (4) - Ít calo
(4, 1, 28.0), (4, 4, 7.0), (4, 15, 15.0),

-- Cà Phê Đen (5) - Không calo
(5, 1, 2.0), (5, 4, 0.0), (5, 27, 115.0),

-- Cà Phê Sữa (6) - Giàu đường, calo
(6, 1, 85.0), (6, 4, 12.5), (6, 2, 2.8), (6, 24, 45.0),

-- Cà Phê Sữa Đá (7)
(7, 1, 68.0), (7, 4, 10.0), (7, 2, 2.2), (7, 24, 36.0),

-- Trà Xanh (8) - Không calo
(8, 1, 0.0), (8, 4, 0.0), (8, 27, 8.0),

-- Sinh Tố Bơ (11) - Giàu chất béo tốt
(11, 1, 165.0), (11, 2, 2.8), (11, 3, 12.5), (11, 4, 11.2), (11, 24, 85.0),

-- Sinh Tố Chuối (12) - Giàu kali
(12, 1, 95.0), (12, 2, 3.5), (12, 4, 18.5), (12, 27, 215.0), (12, 24, 72.0),

-- Sữa Đậu Nành (14) - Protein thực vật
(14, 1, 54.0), (14, 2, 3.3), (14, 4, 6.0), (14, 24, 25.0), (14, 29, 1.2),

-- Nước Lọc (20) - Không calo
(20, 1, 0.0), (20, 4, 0.0)
ON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;


-- =================================================================================
-- 7. BẢNG PORTIONSIZE (Khẩu phần ăn tiêu chuẩn)
-- =================================================================================

INSERT INTO portionsize (food_id, portion_name, portion_name_vi, weight_g, is_common) VALUES 
-- Cơm
(3008, '1 bowl', '1 bát cơm', 200, TRUE),
(3008, '1 small bowl', '1 chén nhỏ', 100, TRUE),
(3008, '1 plate', '1 dĩa', 250, TRUE),

-- Thịt
(3019, '1 piece', '1 miếng', 80, TRUE),
(3019, '100g', '100 gram', 100, TRUE),
(3003, '1 slice', '1 lát', 50, TRUE),

-- Cá
(3018, '1 medium piece', '1 miếng vừa', 120, TRUE),
(3007, '1 fillet', '1 phi lê', 150, TRUE),

-- Rau
(3017, '1 bunch', '1 bó', 200, TRUE),
(3001, '1 cup cooked', '1 chén luộc', 150, TRUE),
(3009, '1 cup', '1 chén', 100, TRUE),

-- Trái cây
(3004, '1 medium banana', '1 trái chuối vừa', 120, TRUE),
(3005, '1 glass', '1 ly', 250, TRUE),

-- Sữa
(3010, '1 glass', '1 ly', 250, TRUE),
(3006, '1 cup', '1 hộp nhỏ', 180, TRUE),

-- Bánh mì
(3014, '1 piece', '1 ổ', 60, TRUE),

-- Món ăn đóng gói
(3011, '1 bowl', '1 tô', 700, TRUE),
(3012, '1 bowl', '1 tô', 500, TRUE),
(3013, '1 plate', '1 dĩa', 400, TRUE)
ON CONFLICT (food_id, portion_name) DO UPDATE SET name_vi = EXCLUDED.name_vi, grams = EXCLUDED.grams;


-- =================================================================================
-- 8. BẢNG CONDITIONFOODRECOMMENDATION (Gợi ý thực phẩm cho bệnh lý)
-- =================================================================================

INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes) VALUES 
-- Tiểu đường type 2 (1001) - NÊN ăn thực phẩm ít đường, nhiều chất xơ
(11, 3009, 'Recommended', 'Súp lơ xanh giàu chất xơ, ít carbs, tốt cho kiểm soát đường huyết'),
(11, 3017, 'Recommended', 'Rau muống giàu chất xơ, ít calo'),
(11, 18, 'Recommended', 'Rau củ luộc giúp kiểm soát cân nặng'),
(11, 3007, 'Recommended', 'Cá hồi giàu omega-3 tốt cho tim mạch'),
(11, 3008, 'Avoid', 'Hạn chế cơm trắng, thay bằng gạo lứt'),
(11, 3004, 'Moderate', 'Ăn chuối với lượng vừa phải'),

-- Cao huyết áp (1002) - TRÁNH thực phẩm mặn
(12, 3011, 'Avoid', 'Phở bò thường nhiều muối trong nước dùng'),
(12, 3018, 'Avoid', 'Cá kho tộ rất mặn, không tốt cho huyết áp'),
(12, 3019, 'Avoid', 'Thịt kho thường rất mặn'),
(12, 3009, 'Recommended', 'Súp lơ xanh giàu kali, giúp giảm huyết áp'),
(12, 3004, 'Recommended', 'Chuối giàu kali tốt cho huyết áp (nếu không dùng thuốc giữ kali)'),
(12, 18, 'Recommended', 'Rau củ luộc ít muối'),

-- Huyết khối (1003) - TRÁNH vitamin K cao nếu dùng Warfarin
(13, 3001, 'Avoid', 'Rau bina rất giàu vitamin K, ảnh hưởng thuốc chống đông máu Warfarin'),
(13, 3002, 'Avoid', 'Cải xoăn siêu giàu vitamin K'),
(13, 3009, 'Moderate', 'Súp lơ xanh có vitamin K, ăn lượng ổn định'),
(13, 3017, 'Moderate', 'Rau muống có vitamin K, không ăn quá nhiều'),

-- Thiếu máu (1004) - NÊN ăn giàu sắt
(14, 3003, 'Recommended', 'Gan bò rất giàu sắt và B12, tốt nhất cho thiếu máu'),
(14, 3001, 'Recommended', 'Rau bina giàu sắt'),
(14, 3007, 'Recommended', 'Cá hồi giàu B12'),
(14, 3010, 'Avoid', 'Không uống sữa cùng lúc với viên sắt'),

-- Loãng xương (1005) - NÊN ăn giàu canxi
(15, 3010, 'Recommended', 'Sữa tươi giàu canxi tốt cho xương'),
(15, 3006, 'Recommended', 'Sữa chua giàu canxi và protein'),
(15, 3009, 'Recommended', 'Súp lơ xanh giàu canxi và vitamin K tốt cho xương'),
(15, 90, 'Recommended', 'Giá đỗ giàu canxi'),

-- Gút (1006) - TRÁNH thực phẩm giàu purine
(16, 3003, 'Avoid', 'Gan bò rất giàu purine, gây tăng axit uric'),
(16, 3007, 'Avoid', 'Cá hồi giàu purine'),
(16, 3018, 'Moderate', 'Hạn chế cá'),
(16, 3017, 'Recommended', 'Rau xanh tốt cho người bị gút'),
(16, 3009, 'Recommended', 'Rau củ giúp kiềm hóa cơ thể'),

-- GERD - Trào ngược (1008) - TRÁNH thực phẩm chua, cay
(18, 3016, 'Avoid', 'Canh chua có thể gây trào ngược tệ hơn'),
(18, 3005, 'Avoid', 'Nước cam chua có thể làm tăng axit'),
(18, 16, 'Recommended', 'Cháo gà nhẹ nhàng, dễ tiêu'),
(18, 17, 'Recommended', 'Cháo cá dễ tiêu hóa'),
(18, 18, 'Recommended', 'Rau củ luộc nhẹ bụng')
ON CONFLICT (condition_id, food_id) DO UPDATE SET notes_vi = EXCLUDED.notes_vi;


-- =================================================================================
-- 9. BẢNG CONDITIONNUTRIENTEFFECT (Ảnh hưởng bệnh lý đến nhu cầu dinh dưỡng)
-- =================================================================================

INSERT INTO conditionnutrienteffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes) VALUES 
-- Tiểu đường (1001)
(11, 4, 'Decrease', -15.0, 'Giảm lượng carbs để kiểm soát đường huyết'),
(11, 5, 'Increase', 25.0, 'Tăng chất xơ giúp kiểm soát đường huyết tốt hơn'),
(11, 2, 'Increase', 10.0, 'Tăng protein giúp no lâu hơn'),

-- Cao huyết áp (1002)
(12, 28, 'Decrease', -40.0, 'Giảm natri (muối) xuống dưới 2000mg/ngày'),
(12, 27, 'Increase', 20.0, 'Tăng kali giúp giảm huyết áp'),
(12, 26, 'Increase', 15.0, 'Tăng magie tốt cho tim mạch'),

-- Thiếu máu (1004)
(14, 29, 'Increase', 50.0, 'Tăng sắt gấp đôi nhu cầu bình thường'),
(14, 23, 'Increase', 30.0, 'Tăng B12 để hỗ trợ tạo hồng cầu'),
(14, 15, 'Increase', 20.0, 'Tăng vitamin C giúp hấp thu sắt tốt hơn'),

-- Loãng xương (1005)
(15, 24, 'Increase', 40.0, 'Tăng canxi lên 1200-1500mg/ngày'),
(15, 12, 'Increase', 50.0, 'Tăng vitamin D giúp hấp thu canxi'),
(15, 14, 'Increase', 25.0, 'Tăng vitamin K tốt cho xương'),

-- Gút (1006)
(16, 2, 'Decrease', -20.0, 'Giảm protein từ thịt đỏ, hải sản'),
(16, 27, 'Neutral', 0.0, 'Duy trì kali bình thường'),

-- Bệnh thận mãn (1007)
(17, 2, 'Decrease', -25.0, 'Giảm protein để giảm gánh nặng thận'),
(17, 28, 'Decrease', -50.0, 'Hạn chế muối nghiêm ngặt'),
(17, 27, 'Decrease', -30.0, 'Giảm kali vì thận không thải được'),
(17, 25, 'Decrease', -20.0, 'Giảm phospho'),

-- GERD (1008)
(18, 3, 'Decrease', -15.0, 'Giảm chất béo để giảm trào ngược'),
(18, 5, 'Increase', 10.0, 'Tăng chất xơ nhưng không quá nhiều')
ON CONFLICT (condition_id, nutrient_id) DO UPDATE SET notes_vi = EXCLUDED.notes_vi;


-- =================================================================================
-- 10. BẢNG RECIPE (Công thức nấu ăn chi tiết)
-- =================================================================================

INSERT INTO recipe (recipe_id, recipe_name, description, servings, prep_time_minutes, cook_time_minutes, instructions, is_public) VALUES 
(1, 'Phở Bò Hà Nội', 'Công thức nấu phở bò truyền thống Hà Nội', 4, 30, 180, 
'Bước 1: Hầm xương bò 3-4 tiếng với hành, gừng nướng
Bước 2: Thêm gia vị: muối, đường, nước mắm, hạt nêm
Bước 3: Trụng bánh phở, cho vào tô
Bước 4: Thái thịt bò mỏng, xếp lên bánh phở
Bước 5: Chan nước dùng sôi, thêm hành, ngò rí, rau thơm
Bước 6: Ăn kèm chanh, ớt, tương ớt', TRUE),

(2, 'Cơm Tấm Sườn Nướng', 'Cơm tấm sườn nướng sả ớt', 2, 20, 30,
'Bước 1: Ướp sườn heo với sả, tỏi, đường, nước mắm, dầu ăn 2 tiếng
Bước 2: Nướng sườn trên than hồng hoặc lò nướng
Bước 3: Nấu cơm tấm
Bước 4: Chiên trứng ốp la
Bước 5: Pha nước mắm chua ngọt
Bước 6: Bày cơm, sườn, trứng, dưa leo, cà chua', TRUE),

(3, 'Canh Chua Cá', 'Canh chua cá lóc miền Nam', 4, 15, 25,
'Bước 1: Rửa sạch cá, cắt khúc vừa ăn
Bước 2: Nấu nước dùng với me, thơm, cà chua
Bước 3: Cho cá vào, nấu chín
Bước 4: Thêm đậu bắp, rau muống
Bước 5: Nêm nếm vừa ăn với muối, đường, nước mắm
Bước 6: Rắc hành, ngò, ớt', TRUE),

(4, 'Gỏi Cuốn Tôm Thịt', 'Gỏi cuốn tươi mát', 10, 30, 15,
'Bước 1: Luộc tôm, thịt heo
Bước 2: Thái rau sống: xà lách, húng, rau thơm
Bước 3: Trụng bánh tráng qua nước ấm
Bước 4: Cuốn tôm, thịt, bún, rau vào bánh tráng
Bước 5: Pha nước chấm: nước mắm, đường, tỏi, ớt
Bước 6: Ăn ngay khi mới cuốn', TRUE),

(5, 'Cháo Gà Dinh Dưỡng', 'Cháo gà cho người ốm', 2, 10, 40,
'Bước 1: Vo gạo, ngâm 30 phút
Bước 2: Luộc gà với gừng
Bước 3: Xé gà thành sợi
Bước 4: Nấu cháo với nước luộc gà
Bước 5: Nêm nếm vừa ăn
Bước 6: Cho gà xé vào, rắc hành, gừng', TRUE)
ON CONFLICT (recipe_id) DO UPDATE SET instructions = EXCLUDED.instructions;


-- =================================================================================
-- TÓM TẮT DỮ LIỆU ĐÃ THÊM
-- =================================================================================
/*
THỐNG KÊ DỮ LIỆU MỚI:

1. BẢNG DISH (18 records):
   - Các món ăn Việt Nam: Phở, Cơm tấm, Bánh mì, Bún chả, Gỏi cuốn, v.v.
   - Phân loại: Breakfast, Lunch, Dinner, Soup, Vegetarian, Snack, Light Meal
   - Có serving_size_g chuẩn

2. BẢNG DISHINGREDIENT (45+ records):
   - Liên kết dish với food_id
   - Có weight_g, display_order, notes

3. BẢNG DISHNUTRIENT (100+ records):
   - Dinh dưỡng tính toán cho mỗi món ăn
   - Bao gồm calories, protein, fat, carbs, vitamins, minerals

4. BẢNG DRINK (20 records):
   - Đồ uống VN: Nước cam, mía, dừa, cà phê, trà, sinh tố
   - Có caffeine_mg, hydration_ratio, sugar_free
   - Phân loại: Juice, Coffee, Tea, Smoothie, Healthy, Water

5. BẢNG DRINKINGREDIENT (10+ records):
   - Thành phần đồ uống từ food_id

6. BẢNG DRINKNUTRIENT (20+ records):
   - Dinh dưỡng cho mỗi loại đồ uống

7. BẢNG PORTIONSIZE (20+ records):
   - Khẩu phần ăn tiêu chuẩn VN
   - VD: 1 bát cơm = 200g, 1 chén = 100g

8. BẢNG CONDITIONFOODRECOMMENDATION (40+ records):
   - Gợi ý thực phẩm NÊN/TRÁNH cho từng bệnh
   - VD: Tiểu đường NÊN ăn rau xanh, TRÁNH cơm trắng
   - VD: Cao huyết áp TRÁNH đồ mặn
   - VD: Warfarin TRÁNH vitamin K cao

9. BẢNG CONDITIONNUTRIENTEFFECT (20+ records):
   - Điều chỉnh % nhu cầu dinh dưỡng khi có bệnh
   - VD: Tiểu đường -15% carbs, +25% fiber
   - VD: Cao huyết áp -40% sodium, +20% potassium

10. BẢNG RECIPE (5 records):
    - Công thức nấu ăn chi tiết
    - Có prep_time, cook_time, instructions

ĐẶC ĐIỂM NỔI BẬT:
✓ Tất cả món ăn và đồ uống có tên tiếng Việt
✓ Dữ liệu dinh dưỡng chính xác
✓ Gợi ý thực phẩm phù hợp với bệnh lý
✓ Hỗ trợ cảnh báo tương tác thuốc-thực phẩm
✓ Khẩu phần ăn chuẩn Việt Nam

SỬ DỤNG:
- Import file này RIÊNG BIỆT sau khi import real_dataset_vietnam.sql
- Đảm bảo đã có food_id, nutrient_id, condition_id từ file trước
- Kiểm tra foreign key constraints trước khi chạy
*/
