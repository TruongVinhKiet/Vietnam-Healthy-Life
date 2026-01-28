-- Complete Nutrients and Foods Seed Data
-- Add missing nutrients and foods to match requirements

BEGIN;

-- ============================================================
-- MISSING FIBER TYPES
-- ============================================================
INSERT INTO Fiber(code, name, description, unit, hex_color, home_display)
VALUES 
('RESISTANT_STARCH', 'Resistant Starch', 'Starch that resists digestion', 'g', '#8B6914', false),
('BETA_GLUCAN', 'Beta-Glucan', 'Soluble fiber found in oats and barley', 'g', '#CD853F', false)
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- MISSING FATTY ACIDS (EPA, DHA, ALA, LA, Cholesterol)
-- ============================================================
INSERT INTO FattyAcid(code, name, description, unit, hex_color, home_display)
VALUES 
('ALA', 'ALA (Alpha-Linolenic Acid)', 'Plant-based omega-3 fatty acid', 'g', '#00CED1', true),
('EPA', 'EPA (Eicosapentaenoic Acid)', 'Marine omega-3 fatty acid', 'g', '#1E90FF', true),
('DHA', 'DHA (Docosahexaenoic Acid)', 'Marine omega-3 fatty acid', 'g', '#4169E1', true),
('EPA_DHA', 'EPA + DHA Combined', 'Combined EPA and DHA', 'g', '#0000CD', true),
('LA', 'LA (Linoleic Acid)', 'Omega-6 fatty acid', 'g', '#FFA500', false),
('CHOLESTEROL', 'Cholesterol', 'Dietary cholesterol', 'mg', '#8B0000', false),
('TOTAL_FAT', 'Total Fat', 'Total fat content', 'g', '#DC143C', true)
ON CONFLICT (code) DO NOTHING;

-- ============================================================
-- MISSING VITAMINS (B3, B5, B7)
-- Already have all vitamins from requirements

-- ============================================================
-- ADD MISSING FOODS (31-48)
-- Food table only has: food_id, name, category, description, image_url, serving_size_g
-- Nutrients are stored in FoodNutrient table separately
-- ============================================================

INSERT INTO Food(name, description, category, serving_size_g)
VALUES 
-- Grains & Starches (31-34)
('Gao', 'White rice grains', 'grains', 100),
('Gao nep', 'Sticky rice grains', 'grains', 100),
('Banh pho', 'Rice noodle sheets', 'grains', 100),
('Banh trang', 'Rice paper', 'grains', 10),

-- Fresh Herbs (35-38)
('Hanh la', 'Green onion/scallion', 'vegetables', 20),
('Ngo', 'Cilantro/coriander', 'vegetables', 10),
('Rau song', 'Fresh vegetables mix', 'vegetables', 50),
('Rau thom', 'Mixed aromatic herbs', 'vegetables', 20),

-- More Vegetables (39-40)
('Dua leo', 'Cucumber', 'vegetables', 100),
('Hanh tay', 'Onion', 'vegetables', 50),

-- Fruits (41)
('Dua', 'Pineapple', 'fruits', 100),

-- Legumes (42)
('Dau xanh', 'Mung beans', 'legumes', 50),

-- Mushrooms (43)
('Nam', 'Mushrooms', 'vegetables', 50),

-- Condiments & Seasonings (44-47)
('Hanh phi', 'Fried shallots', 'condiments', 10),
('Nuoc mam', 'Fish sauce', 'condiments', 15),
('Duong', 'Sugar', 'condiments', 10),
('Tieu', 'Black pepper', 'condiments', 5),

-- Mixed vegetables (48)
('Rau cu', 'Mixed vegetables', 'vegetables', 100);

-- ============================================================
-- VERIFY INSERTIONS
-- ============================================================

COMMIT;

-- Final counts
SELECT 
    'Vitamins' as nutrient_type, COUNT(*) as count FROM Vitamin
UNION ALL SELECT 'Minerals', COUNT(*) FROM Mineral
UNION ALL SELECT 'Amino Acids', COUNT(*) FROM AminoAcid
UNION ALL SELECT 'Fiber Types', COUNT(*) FROM Fiber
UNION ALL SELECT 'Fatty Acids', COUNT(*) FROM FattyAcid
UNION ALL SELECT 'Foods', COUNT(*) FROM Food
ORDER BY nutrient_type;
