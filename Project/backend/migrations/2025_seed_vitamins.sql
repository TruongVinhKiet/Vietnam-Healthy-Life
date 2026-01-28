-- 2025_seed_vitamins.sql
-- Seed commonly-tracked vitamins if not present

INSERT INTO Vitamin(code, name, description, unit, recommended_daily)
SELECT * FROM (VALUES
    ('VITD','Vitamin D','Supports bone health and immune function','IU',600),
    ('VITC','Vitamin C','Antioxidant; supports immune system','mg',75),
    ('VITB12','Vitamin B12','Important for nerve function and blood formation','µg',2.4),
    ('VITA','Vitamin A','Supports vision and immune function','µg',700),
    ('VITE','Vitamin E','Antioxidant; protects cells','mg',15),
    ('VITB6','Vitamin B6','Supports metabolism and brain health','mg',1.3),
    ('VITK','Vitamin K','Required for blood clotting','µg',120),
    ('VITB1','Vitamin B1 (Thiamine)','Supports energy metabolism','mg',1.2),
    ('VITB2','Vitamin B2 (Riboflavin)','Important for energy production','mg',1.3),
    ('VITB9','Vitamin B9 (Folate)','Key for cell division and DNA synthesis','µg',400)
) AS v(code,name,description,unit,recommended_daily)
WHERE NOT EXISTS (SELECT 1 FROM Vitamin WHERE code = v.code);
