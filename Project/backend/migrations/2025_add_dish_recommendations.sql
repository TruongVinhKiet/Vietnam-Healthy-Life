-- Migration: Add dish recommendations system similar to drinks
-- Date: 2025-12-21

CREATE TABLE IF NOT EXISTS conditiondishrecommendation (
    recommendation_id SERIAL PRIMARY KEY,
    condition_id INT NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
    dish_id INT NOT NULL REFERENCES dish(dish_id) ON DELETE CASCADE,
    recommendation_type VARCHAR(20) NOT NULL CHECK (recommendation_type IN ('avoid', 'recommend')),
    reason TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(condition_id, dish_id, recommendation_type)
);

CREATE INDEX IF NOT EXISTS idx_conditiondishrecommendation_condition
ON conditiondishrecommendation(condition_id);

CREATE INDEX IF NOT EXISTS idx_conditiondishrecommendation_dish
ON conditiondishrecommendation(dish_id);

-- Seed minimal mappings so UI can show avoid/recommend badges.
-- Uses ILIKE on dish names so it works across different dish seed scripts.

-- Condition 1: Tiểu đường type 2
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 1, dish_id, 'avoid', 'Nhiều tinh bột/đường không tốt cho tiểu đường'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Xôi%',
  'Xoi%',
  '%Chè%',
  'Che%',
  '%Bánh flan%',
  'Banh flan%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 1, dish_id, 'recommend', 'Ưu tiên nhiều rau và đạm nạc, ít đường'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Gỏi cuốn%',
  '%Gỏi Cuốn%',
  'Goi Cuon%',
  '%Rau muống xào tỏi%',
  'Rau muong xao toi%',
  '%Salad%',
  '%Cá hấp%',
  'Ca hap%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 2: Cao huyết áp
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 2, dish_id, 'avoid', 'Hàm lượng muối/nước mắm cao không tốt cho huyết áp'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Cá kho%',
  'Ca kho%',
  '%Thịt kho%',
  'Thit kho%',
  '%Bún bò Huế%',
  'Bun Bo Hue%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 2, dish_id, 'recommend', 'Ít muối, nhiều rau, tốt cho huyết áp'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Gỏi cuốn%',
  '%Gỏi Cuốn%',
  'Goi Cuon%',
  '%Rau muống xào tỏi%',
  'Rau muong xao toi%',
  '%Canh%',
  '%Salad%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 3: Mỡ máu cao
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 3, dish_id, 'avoid', 'Nhiều chất béo bão hòa có thể làm tăng mỡ máu'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Bò lúc lắc%',
  'Bo Luc Lac%',
  '%Thịt kho%',
  'Thit kho%',
  '%Chả giò%',
  'Cha Gio%',
  '%Cơm chiên%',
  'Com Chien%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 3, dish_id, 'recommend', 'Ưu tiên cá hấp/salad/rau xanh để hỗ trợ mỡ máu'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Cá hấp%',
  'Ca hap%',
  '%Salad%',
  '%Rau muống%',
  'Rau muong%',
  '%Đậu hũ%',
  'Tau hu%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 4: Béo phì
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 4, dish_id, 'avoid', 'Calo cao (chiên/ngọt/tinh bột) có thể gây tăng cân'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Xôi%',
  'Xoi%',
  '%Chả giò%',
  'Cha Gio%',
  '%Bánh mì%',
  'Banh Mi%',
  '%Cơm chiên%',
  'Com Chien%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 4, dish_id, 'recommend', 'Nhiều rau/ít dầu mỡ giúp kiểm soát cân nặng'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Salad%',
  '%Gỏi%',
  'Goi %',
  '%Rau muống%',
  'Rau muong%',
  '%Canh%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 5: Gout
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 5, dish_id, 'avoid', 'Một số món giàu purine (thịt đỏ/hải sản) không tốt cho gout'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Phở bò%',
  '%Phở Bò%',
  'Pho Bo%',
  '%Bún bò Huế%',
  'Bun Bo Hue%',
  '%Cá%',
  'Ca %'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 5, dish_id, 'recommend', 'Ưu tiên món thanh đạm, nhiều rau'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Salad%',
  '%Rau%',
  'Rau %',
  '%Đậu hũ%',
  'Tau hu%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 6: Gan nhiễm mỡ
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 6, dish_id, 'avoid', 'Món nhiều dầu mỡ có thể làm nặng gan'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Chả giò%',
  'Cha Gio%',
  '%Thịt kho%',
  'Thit kho%',
  '%Cơm chiên%',
  'Com Chien%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 6, dish_id, 'recommend', 'Ưu tiên salad/cá hấp/rau xanh'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Salad%',
  '%Cá hấp%',
  'Ca hap%',
  '%Rau%',
  'Rau %'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 7: Viêm dạ dày
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 7, dish_id, 'avoid', 'Món chua/cay/chiên có thể kích ứng dạ dày'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Canh chua%',
  'Canh Chua%',
  '%Bún bò Huế%',
  'Bun Bo Hue%',
  '%Chả giò%',
  'Cha Gio%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 7, dish_id, 'recommend', 'Ưu tiên món nhẹ, dễ tiêu'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Cháo%',
  'Chao%',
  '%Soup%',
  '%Sup%',
  '%Canh%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 8: Thiếu máu
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 8, dish_id, 'recommend', 'Món giàu sắt/protein giúp hỗ trợ thiếu máu'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Phở bò%',
  '%Phở Bò%',
  'Pho Bo%',
  '%Bò%',
  'Bo %'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 9: Suy dinh dưỡng
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 9, dish_id, 'recommend', 'Bổ sung năng lượng và protein'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Phở%',
  'Pho%',
  '%Xôi%',
  'Xoi%',
  '%Cơm%',
  'Com %'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;

-- Condition 10: Dị ứng thực phẩm
INSERT INTO conditiondishrecommendation (condition_id, dish_id, recommendation_type, reason)
SELECT 10, dish_id, 'avoid', 'Một số món hải sản có thể gây dị ứng'
FROM dish
WHERE COALESCE(vietnamese_name, name) ILIKE ANY(ARRAY[
  '%Tôm%',
  'Tom%',
  '%Cua%',
  'Cua%',
  '%Hải sản%',
  'Hai san%'
])
ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING;
