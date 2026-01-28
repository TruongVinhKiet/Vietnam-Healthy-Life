-- ============================================================
-- AI Analyzed Meals System
-- ------------------------------------------------------------
-- AI image analysis system (Gemini Vision)
-- Store analysis results for food/drinks from images
-- Support 76 nutrients + water content
-- ============================================================

BEGIN;

-- ------------------------------------------------------------
-- TABLE AI_ANALYZED_MEALS
-- Store each food/drink item analyzed from image
-- Each item in image = 1 separate record
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS AI_Analyzed_Meals (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    
    -- Basic information
    image_path VARCHAR(500) NOT NULL,                    -- image path (uploads/ai_analysis/xxx.jpg)
    item_name VARCHAR(255) NOT NULL,                     -- item name (e.g., "Pho Bo", "Coca Cola")
    item_type VARCHAR(20) CHECK (item_type IN ('food', 'drink')), -- item type
    confidence_score NUMERIC(5,2) DEFAULT 0,             -- confidence 0-100 (e.g., 92.5)
    
    -- Volume/Weight information
    estimated_volume_ml NUMERIC(10,2) DEFAULT 0,         -- estimated volume (ml)
    estimated_weight_g NUMERIC(10,2) DEFAULT 0,          -- estimated weight (grams)
    
    -- Metadata
    analyzed_at TIMESTAMPTZ DEFAULT NOW(),
    accepted BOOLEAN DEFAULT FALSE,                       -- user accepted or not
    accepted_at TIMESTAMPTZ,

    -- Origin information (image/chatbot/etc.)
    source VARCHAR(20) DEFAULT 'image',                   -- 'image' | 'chatbot' | ...
    source_ref VARCHAR(100),                              -- e.g. chatbot message id

    -- Admin promotion metadata
    promoted BOOLEAN DEFAULT FALSE,                       -- promoted into Dish/Drink catalog
    promoted_at TIMESTAMPTZ,
    promoted_by_admin INT,
    linked_dish_id INT,                                   -- reference to Dish.dish_id
    linked_drink_id INT,                                  -- reference to Drink.drink_id
    
    -- === NUTRIENTS (76 types + water) ===
    
    -- Macronutrients (4)
    enerc_kcal NUMERIC(10,2) DEFAULT 0,                  -- 1. Energy (Calories)
    procnt NUMERIC(10,2) DEFAULT 0,                      -- 2. Protein
    fat NUMERIC(10,2) DEFAULT 0,                         -- 3. Total Fat
    chocdf NUMERIC(10,2) DEFAULT 0,                      -- 4. Carbohydrate
    
    -- Dietary Fiber (5)
    fibtg NUMERIC(10,2) DEFAULT 0,                       -- 5. Dietary Fiber (total)
    fib_sol NUMERIC(10,2) DEFAULT 0,                     -- 6. Soluble Fiber
    fib_insol NUMERIC(10,2) DEFAULT 0,                   -- 7. Insoluble Fiber
    fib_rs NUMERIC(10,2) DEFAULT 0,                      -- 8. Resistant Starch
    fib_bglu NUMERIC(10,2) DEFAULT 0,                    -- 9. Beta-Glucan
    
    -- Cholesterol (1)
    cholesterol NUMERIC(10,2) DEFAULT 0,                 -- 10. Cholesterol
    
    -- Vitamins (13)
    vita NUMERIC(10,2) DEFAULT 0,                        -- 11. Vitamin A (µg)
    vitd NUMERIC(10,2) DEFAULT 0,                        -- 12. Vitamin D (IU)
    vite NUMERIC(10,2) DEFAULT 0,                        -- 13. Vitamin E (mg)
    vitk NUMERIC(10,2) DEFAULT 0,                        -- 14. Vitamin K (µg)
    vitc NUMERIC(10,2) DEFAULT 0,                        -- 15. Vitamin C (mg)
    vitb1 NUMERIC(10,2) DEFAULT 0,                       -- 16. Vitamin B1 (Thiamine)
    vitb2 NUMERIC(10,2) DEFAULT 0,                       -- 17. Vitamin B2 (Riboflavin)
    vitb3 NUMERIC(10,2) DEFAULT 0,                       -- 18. Vitamin B3 (Niacin)
    vitb5 NUMERIC(10,2) DEFAULT 0,                       -- 19. Vitamin B5 (Pantothenic acid)
    vitb6 NUMERIC(10,2) DEFAULT 0,                       -- 20. Vitamin B6 (Pyridoxine)
    vitb7 NUMERIC(10,2) DEFAULT 0,                       -- 21. Vitamin B7 (Biotin)
    vitb9 NUMERIC(10,2) DEFAULT 0,                       -- 22. Vitamin B9 (Folate)
    vitb12 NUMERIC(10,2) DEFAULT 0,                      -- 23. Vitamin B12 (Cobalamin)
    
    -- Minerals (14)
    ca NUMERIC(10,2) DEFAULT 0,                          -- 24. Calcium (Ca)
    p NUMERIC(10,2) DEFAULT 0,                           -- 25. Phosphorus (P)
    mg NUMERIC(10,2) DEFAULT 0,                          -- 26. Magnesium (Mg)
    k NUMERIC(10,2) DEFAULT 0,                           -- 27. Potassium (K)
    na NUMERIC(10,2) DEFAULT 0,                          -- 28. Sodium (Na)
    fe NUMERIC(10,2) DEFAULT 0,                          -- 29. Iron (Fe)
    zn NUMERIC(10,2) DEFAULT 0,                          -- 30. Zinc (Zn)
    cu NUMERIC(10,2) DEFAULT 0,                          -- 31. Copper (Cu)
    mn NUMERIC(10,2) DEFAULT 0,                          -- 32. Manganese (Mn)
    i NUMERIC(10,2) DEFAULT 0,                           -- 33. Iodine (I)
    se NUMERIC(10,2) DEFAULT 0,                          -- 34. Selenium (Se)
    cr NUMERIC(10,2) DEFAULT 0,                          -- 35. Chromium (Cr)
    mo NUMERIC(10,2) DEFAULT 0,                          -- 36. Molybdenum (Mo)
    f NUMERIC(10,2) DEFAULT 0,                           -- 37. Fluoride (F)
    
    -- Fatty Acids (9)
    fams NUMERIC(10,2) DEFAULT 0,                        -- 38. Monounsaturated Fat (MUFA)
    fapu NUMERIC(10,2) DEFAULT 0,                        -- 39. Polyunsaturated Fat (PUFA)
    fasat NUMERIC(10,2) DEFAULT 0,                       -- 40. Saturated Fat (SFA)
    fatrn NUMERIC(10,2) DEFAULT 0,                       -- 41. Trans Fat
    faepa NUMERIC(10,2) DEFAULT 0,                       -- 42. EPA
    fadha NUMERIC(10,2) DEFAULT 0,                       -- 43. DHA
    faepa_dha NUMERIC(10,2) DEFAULT 0,                   -- 44. EPA + DHA
    fa18_2n6c NUMERIC(10,2) DEFAULT 0,                   -- 45. Linoleic acid (LA)
    fa18_3n3 NUMERIC(10,2) DEFAULT 0,                    -- 46. Alpha-linolenic acid (ALA)
    
    -- Amino Acids (9)
    amino_his NUMERIC(10,2) DEFAULT 0,                   -- 47. Histidine
    amino_ile NUMERIC(10,2) DEFAULT 0,                   -- 48. Isoleucine
    amino_leu NUMERIC(10,2) DEFAULT 0,                   -- 49. Leucine
    amino_lys NUMERIC(10,2) DEFAULT 0,                   -- 50. Lysine
    amino_met NUMERIC(10,2) DEFAULT 0,                   -- 51. Methionine
    amino_phe NUMERIC(10,2) DEFAULT 0,                   -- 52. Phenylalanine
    amino_thr NUMERIC(10,2) DEFAULT 0,                   -- 53. Threonine
    amino_trp NUMERIC(10,2) DEFAULT 0,                   -- 54. Tryptophan
    amino_val NUMERIC(10,2) DEFAULT 0,                   -- 55. Valine
    
    -- Additional Nutrients (3)
    ala NUMERIC(10,2) DEFAULT 0,                         -- 72. ALA (Alpha-Linolenic Acid)
    epa_dha NUMERIC(10,2) DEFAULT 0,                     -- 75. EPA + DHA Combined
    la NUMERIC(10,2) DEFAULT 0,                          -- 76. LA (Linoleic Acid)
    
    -- === WATER CONTENT ===
    water_ml NUMERIC(10,2) DEFAULT 0,                    -- Lượng nước (ml) - QUAN TRỌNG
    
    -- Notes
    notes TEXT,                                          -- Notes from AI or user
    raw_ai_response JSONB                                -- Raw response from Gemini (debug)
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_ai_meals_user ON AI_Analyzed_Meals(user_id);
CREATE INDEX IF NOT EXISTS idx_ai_meals_analyzed_at ON AI_Analyzed_Meals(analyzed_at);
CREATE INDEX IF NOT EXISTS idx_ai_meals_accepted ON AI_Analyzed_Meals(accepted);
CREATE INDEX IF NOT EXISTS idx_ai_meals_item_type ON AI_Analyzed_Meals(item_type);

COMMIT;

-- ============================================================
-- COMMENTS
-- ============================================================
COMMENT ON TABLE AI_Analyzed_Meals IS 'Store AI analysis results for food/drink items (images, chatbot, etc.)';
COMMENT ON COLUMN AI_Analyzed_Meals.confidence_score IS 'Analysis confidence 0-100 (e.g., 92.5 = 92.5%)';
COMMENT ON COLUMN AI_Analyzed_Meals.water_ml IS 'Water content in item (ml). From both drinks AND food (pho, soup...)';
COMMENT ON COLUMN AI_Analyzed_Meals.accepted IS 'TRUE = user accepted and saved to system';
COMMENT ON COLUMN AI_Analyzed_Meals.source IS 'Origin of analysis: image, chatbot, etc.';
COMMENT ON COLUMN AI_Analyzed_Meals.promoted IS 'TRUE = admin already promoted this item into Dish/Drink catalog';

