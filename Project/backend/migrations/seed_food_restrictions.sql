-- Seed data for food restrictions based on health conditions
-- Links Vietnamese foods to health conditions with recommendation type

-- First, let's add some common Vietnamese foods if not exists (optional, as foods should exist)
-- This script assumes foods are already in the database

-- Diabetes (Tiểu đường type 2) - avoid high sugar and refined carbs
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%cơm trắng%' THEN 'Cơm trắng có chỉ số đường huyết cao'
    WHEN f.name ILIKE '%bánh mì%' THEN 'Bánh mì trắng tăng đường huyết nhanh'
    WHEN f.name ILIKE '%nước ngọt%' THEN 'Nước ngọt chứa đường cao'
    WHEN f.name ILIKE '%kẹo%' THEN 'Kẹo chứa đường tinh luyện'
    WHEN f.name ILIKE '%kem%' THEN 'Kem chứa đường và chất béo cao'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Tiểu đường type 2'
  AND (
    f.name ILIKE '%cơm trắng%' OR
    f.name ILIKE '%bánh mì trắng%' OR
    f.name ILIKE '%nước ngọt%' OR
    f.name ILIKE '%kẹo%' OR
    f.name ILIKE '%kem%'
  )
ON CONFLICT DO NOTHING;

-- Hypertension (Cao huyết áp) - avoid high sodium foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%muối%' THEN 'Hạn chế muối để kiểm soát huyết áp'
    WHEN f.name ILIKE '%nước mắm%' THEN 'Nước mắm chứa natri cao'
    WHEN f.name ILIKE '%dưa muối%' THEN 'Dưa muối chứa natri rất cao'
    WHEN f.name ILIKE '%xúc xích%' THEN 'Thực phẩm chế biến sẵn chứa muối cao'
    WHEN f.name ILIKE '%thịt xông khói%' THEN 'Thịt xông khói chứa natri cao'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Cao huyết áp'
  AND (
    f.name ILIKE '%muối%' OR
    f.name ILIKE '%nước mắm%' OR
    f.name ILIKE '%dưa muối%' OR
    f.name ILIKE '%xúc xích%' OR
    f.name ILIKE '%thịt xông khói%'
  )
ON CONFLICT DO NOTHING;

-- High Cholesterol (Mỡ máu cao) - avoid saturated fats
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%thịt lợn%' THEN 'Thịt lợn chứa chất béo bão hòa cao'
    WHEN f.name ILIKE '%mỡ%' THEN 'Mỡ động vật tăng cholesterol'
    WHEN f.name ILIKE '%da gà%' THEN 'Da gà chứa chất béo cao'
    WHEN f.name ILIKE '%óc%' THEN 'Óc động vật chứa cholesterol rất cao'
    WHEN f.name ILIKE '%lòng%' THEN 'Lòng động vật chứa cholesterol cao'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Mỡ máu cao'
  AND (
    f.name ILIKE '%thịt lợn%' OR
    f.name ILIKE '%mỡ%' OR
    f.name ILIKE '%da gà%' OR
    f.name ILIKE '%óc%' OR
    f.name ILIKE '%lòng%'
  )
ON CONFLICT DO NOTHING;

-- Obesity (Béo phì) - avoid high calorie dense foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%đồ chiên%' THEN 'Đồ chiên chứa nhiều calo và chất béo'
    WHEN f.name ILIKE '%bánh ngọt%' THEN 'Bánh ngọt chứa đường và chất béo cao'
    WHEN f.name ILIKE '%nước ngọt%' THEN 'Nước ngọt cung cấp calo rỗng'
    WHEN f.name ILIKE '%fast food%' THEN 'Thức ăn nhanh chứa calo cao'
    WHEN f.name ILIKE '%bia%' THEN 'Bia chứa calo cao'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Béo phì'
  AND (
    f.name ILIKE '%đồ chiên%' OR
    f.name ILIKE '%bánh ngọt%' OR
    f.name ILIKE '%nước ngọt%' OR
    f.name ILIKE '%fast food%' OR
    f.name ILIKE '%bia%'
  )
ON CONFLICT DO NOTHING;

-- Gout (Gút) - avoid high purine foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%nội tạng%' THEN 'Nội tạng chứa purine rất cao'
    WHEN f.name ILIKE '%hải sản%' THEN 'Hải sản chứa purine cao'
    WHEN f.name ILIKE '%tôm%' THEN 'Tôm chứa purine cao'
    WHEN f.name ILIKE '%cua%' THEN 'Cua chứa purine cao'
    WHEN f.name ILIKE '%rượu%' THEN 'Rượu làm tăng acid uric'
    WHEN f.name ILIKE '%bia%' THEN 'Bia chứa purine và làm tăng acid uric'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Gút (Bệnh gút)'
  AND (
    f.name ILIKE '%nội tạng%' OR
    f.name ILIKE '%hải sản%' OR
    f.name ILIKE '%tôm%' OR
    f.name ILIKE '%cua%' OR
    f.name ILIKE '%rượu%' OR
    f.name ILIKE '%bia%'
  )
ON CONFLICT DO NOTHING;

-- Fatty Liver (Gan nhiễm mỡ) - avoid alcohol and high fat foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%rượu%' THEN 'Rượu gây tổn thương gan'
    WHEN f.name ILIKE '%bia%' THEN 'Bia chứa calo rỗng và gây hại gan'
    WHEN f.name ILIKE '%đồ chiên%' THEN 'Đồ chiên chứa chất béo cao'
    WHEN f.name ILIKE '%thực phẩm chế biến%' THEN 'Thực phẩm chế biến chứa chất béo trans'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Gan nhiễm mỡ'
  AND (
    f.name ILIKE '%rượu%' OR
    f.name ILIKE '%bia%' OR
    f.name ILIKE '%đồ chiên%' OR
    f.name ILIKE '%thực phẩm chế biến%'
  )
ON CONFLICT DO NOTHING;

-- Gastritis (Viêm dạ dày) - avoid spicy and acidic foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'avoid',
  CASE 
    WHEN f.name ILIKE '%ớt%' THEN 'Ớt kích thích niêm mạc dạ dày'
    WHEN f.name ILIKE '%cà phê%' THEN 'Cà phê tăng acid dạ dày'
    WHEN f.name ILIKE '%chanh%' THEN 'Chanh quá chua gây kích ứng'
    WHEN f.name ILIKE '%rượu%' THEN 'Rượu gây tổn thương niêm mạc dạ dày'
    WHEN f.name ILIKE '%đồ chua%' THEN 'Đồ chua tăng acid dạ dày'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Viêm dạ dày'
  AND (
    f.name ILIKE '%ớt%' OR
    f.name ILIKE '%cà phê%' OR
    f.name ILIKE '%chanh%' OR
    f.name ILIKE '%rượu%' OR
    f.name ILIKE '%đồ chua%'
  )
ON CONFLICT DO NOTHING;

-- Anemia (Thiếu máu) - recommend iron-rich foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'recommend',
  CASE 
    WHEN f.name ILIKE '%thịt bò%' THEN 'Thịt bò giàu sắt heme dễ hấp thu'
    WHEN f.name ILIKE '%gan%' THEN 'Gan động vật giàu sắt và vitamin B12'
    WHEN f.name ILIKE '%rau bina%' THEN 'Rau bina giàu sắt phi-heme'
    WHEN f.name ILIKE '%trứng%' THEN 'Trứng cung cấp sắt và protein'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Thiếu máu'
  AND (
    f.name ILIKE '%thịt bò%' OR
    f.name ILIKE '%gan%' OR
    f.name ILIKE '%rau bina%' OR
    f.name ILIKE '%trứng%'
  )
ON CONFLICT DO NOTHING;

-- Malnutrition (Suy dinh dưỡng) - recommend nutrient-dense foods
INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
SELECT 
  hc.condition_id,
  f.food_id,
  'recommend',
  CASE 
    WHEN f.name ILIKE '%trứng%' THEN 'Trứng giàu protein và chất dinh dưỡng'
    WHEN f.name ILIKE '%sữa%' THEN 'Sữa cung cấp protein, canxi, vitamin D'
    WHEN f.name ILIKE '%thịt%' THEN 'Thịt giàu protein và khoáng chất'
    WHEN f.name ILIKE '%cá%' THEN 'Cá giàu protein và omega-3'
    WHEN f.name ILIKE '%hạt%' THEN 'Hạt giàu năng lượng và chất dinh dưỡng'
  END
FROM HealthCondition hc
CROSS JOIN Food f
WHERE hc.name_vi = 'Suy dinh dưỡng'
  AND (
    f.name ILIKE '%trứng%' OR
    f.name ILIKE '%sữa%' OR
    f.name ILIKE '%thịt%' OR
    f.name ILIKE '%cá%' OR
    f.name ILIKE '%hạt%'
  )
ON CONFLICT DO NOTHING;

-- Display results
SELECT 
  hc.name_vi as condition_name,
  COUNT(*) as total_food_recommendations
FROM ConditionFoodRecommendation cfr
JOIN HealthCondition hc ON cfr.condition_id = hc.condition_id
GROUP BY hc.condition_id, hc.name_vi
ORDER BY hc.condition_id;
