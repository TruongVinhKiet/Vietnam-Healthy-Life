-- 2025_seed_minerals.sql
-- Seed core minerals if not present

INSERT INTO Mineral(code,name,description,unit,recommended_daily)
SELECT * FROM (VALUES
    ('MIN_CA','Calcium (Ca)','Bone and teeth mineral','mg',1000),
    ('MIN_P','Phosphorus (P)','Bone mineral and energy metabolism','mg',700),
    ('MIN_MG','Magnesium (Mg)','Supports nerve and muscle function','mg',310),
    ('MIN_K','Potassium (K)','Electrolyte; supports blood pressure','mg',4700),
    ('MIN_NA','Sodium (Na)','Electrolyte; fluid balance','mg',1500),
    ('MIN_FE','Iron (Fe)','Essential for hemoglobin and oxygen transport','mg',18),
    ('MIN_ZN','Zinc (Zn)','Supports immune function','mg',11),
    ('MIN_CU','Copper (Cu)','Co-factor in enzymatic reactions','mg',0.9),
    ('MIN_MN','Manganese (Mn)','Cofactor for many enzymes','mg',2.3),
    ('MIN_I','Iodine (I)','Thyroid hormone synthesis','µg',150),
    ('MIN_SE','Selenium (Se)','Antioxidant trace element','µg',55),
    ('MIN_CR','Chromium (Cr)','Involved in macronutrient metabolism','µg',35),
    ('MIN_MO','Molybdenum (Mo)','Enzyme cofactor','µg',45),
    ('MIN_F','Fluoride (F)','Supports dental health','mg',3.0)
) AS m(code,name,description,unit,recommended_daily)
WHERE NOT EXISTS (SELECT 1 FROM Mineral WHERE code = m.code);
