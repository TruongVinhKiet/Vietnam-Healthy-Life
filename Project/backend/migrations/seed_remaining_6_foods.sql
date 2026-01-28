-- Add 6 more foods to complete the list (43-48)
BEGIN;

INSERT INTO Food(name, description, category, serving_size_g)
VALUES 
('Nam', 'Mushrooms', 'vegetables', 50),
('Hanh phi', 'Fried shallots', 'condiments', 10),
('Nuoc mam', 'Fish sauce', 'condiments', 15),
('Duong', 'Sugar', 'condiments', 10),
('Tieu', 'Black pepper', 'condiments', 5),
('Rau cu', 'Mixed vegetables', 'vegetables', 100);

COMMIT;

SELECT COUNT(*) as total_foods FROM Food;
