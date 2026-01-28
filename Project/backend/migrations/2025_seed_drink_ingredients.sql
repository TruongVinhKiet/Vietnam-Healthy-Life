-- Seed core drink ingredients and nutrient data
BEGIN;

-- Helper to insert food if not exists
INSERT INTO Food (name, category, image_url)
SELECT 'Trà đen khô', 'drink_ingredient', NULL
WHERE NOT EXISTS (SELECT 1 FROM Food WHERE name = 'Trà đen khô');

INSERT INTO Food (name, category, image_url)
SELECT 'Syrup đường', 'drink_ingredient', NULL
WHERE NOT EXISTS (SELECT 1 FROM Food WHERE name = 'Syrup đường');

INSERT INTO Food (name, category, image_url)
SELECT 'Sữa đặc có đường', 'drink_ingredient', NULL
WHERE NOT EXISTS (SELECT 1 FROM Food WHERE name = 'Sữa đặc có đường');

INSERT INTO Food (name, category, image_url)
SELECT 'Sữa tươi thanh trùng', 'drink_ingredient', NULL
WHERE NOT EXISTS (SELECT 1 FROM Food WHERE name = 'Sữa tươi thanh trùng');

INSERT INTO Food (name, category, image_url)
SELECT 'Nước cốt dừa', 'drink_ingredient', NULL
WHERE NOT EXISTS (SELECT 1 FROM Food WHERE name = 'Nước cốt dừa');

INSERT INTO Food (name, category, image_url)
SELECT 'Nước cam cô đặc', 'drink_ingredient', NULL
WHERE NOT EXISTS (SELECT 1 FROM Food WHERE name = 'Nước cam cô đặc');

-- Helper macro to insert nutrient data
WITH data AS (
  SELECT 'Trà đen khô'::text AS food, 'ENERC_KCAL'::text AS code, 10::numeric AS amount UNION ALL
  SELECT 'Trà đen khô','PROCNT',1.1 UNION ALL
  SELECT 'Trà đen khô','FAT',0.2 UNION ALL
  SELECT 'Trà đen khô','CHOCDF',2.4 UNION ALL
  SELECT 'Trà đen khô','K',250 UNION ALL
  SELECT 'Trà đen khô','MG',30 UNION ALL

  SELECT 'Syrup đường','ENERC_KCAL',310 UNION ALL
  SELECT 'Syrup đường','CHOCDF',77 UNION ALL
  SELECT 'Syrup đường','K',10 UNION ALL
  SELECT 'Syrup đường','NA',5 UNION ALL

  SELECT 'Sữa đặc có đường','ENERC_KCAL',321 UNION ALL
  SELECT 'Sữa đặc có đường','PROCNT',8 UNION ALL
  SELECT 'Sữa đặc có đường','FAT',8.7 UNION ALL
  SELECT 'Sữa đặc có đường','CHOCDF',54 UNION ALL
  SELECT 'Sữa đặc có đường','CA',284 UNION ALL
  SELECT 'Sữa đặc có đường','NA',127 UNION ALL
  SELECT 'Sữa đặc có đường','VITA',95 UNION ALL

  SELECT 'Sữa tươi thanh trùng','ENERC_KCAL',42 UNION ALL
  SELECT 'Sữa tươi thanh trùng','PROCNT',3.4 UNION ALL
  SELECT 'Sữa tươi thanh trùng','FAT',1 UNION ALL
  SELECT 'Sữa tươi thanh trùng','CHOCDF',5 UNION ALL
  SELECT 'Sữa tươi thanh trùng','CA',120 UNION ALL
  SELECT 'Sữa tươi thanh trùng','K',150 UNION ALL
  SELECT 'Sữa tươi thanh trùng','VITB2',0.2 UNION ALL
  SELECT 'Sữa tươi thanh trùng','VITB12',0.4 UNION ALL

  SELECT 'Nước cốt dừa','ENERC_KCAL',230 UNION ALL
  SELECT 'Nước cốt dừa','PROCNT',2.3 UNION ALL
  SELECT 'Nước cốt dừa','FAT',23.8 UNION ALL
  SELECT 'Nước cốt dừa','CHOCDF',5.5 UNION ALL
  SELECT 'Nước cốt dừa','K',263 UNION ALL
  SELECT 'Nước cốt dừa','MG',37 UNION ALL

  SELECT 'Nước cam cô đặc','ENERC_KCAL',45 UNION ALL
  SELECT 'Nước cam cô đặc','PROCNT',0.7 UNION ALL
  SELECT 'Nước cam cô đặc','CHOCDF',10.4 UNION ALL
  SELECT 'Nước cam cô đặc','FIBTG',0.2 UNION ALL
  SELECT 'Nước cam cô đặc','VITC',50 UNION ALL
  SELECT 'Nước cam cô đặc','K',200
)
INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
SELECT f.food_id, n.nutrient_id, data.amount
FROM data
JOIN Food f ON f.name = data.food
JOIN Nutrient n ON n.nutrient_code = data.code
LEFT JOIN FoodNutrient fn ON fn.food_id = f.food_id AND fn.nutrient_id = n.nutrient_id
WHERE fn.food_nutrient_id IS NULL;

COMMIT;

