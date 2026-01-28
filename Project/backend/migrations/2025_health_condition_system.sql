-- ============================================================
-- HEALTH CONDITION MANAGEMENT SYSTEM
-- Mở rộng hệ thống quản lý bệnh và điều chỉnh dinh dưỡng
-- ============================================================

-- 1. Mở rộng bảng HealthCondition (bảng master của bệnh)
DROP TABLE IF EXISTS HealthCondition CASCADE;
CREATE TABLE HealthCondition (
    condition_id SERIAL PRIMARY KEY,
    name_vi VARCHAR(200) NOT NULL UNIQUE,
    name_en VARCHAR(200) NOT NULL,
    category VARCHAR(100),                    -- Loại bệnh: Tim mạch, Chuyển hóa, Tiêu hóa...
    description TEXT,                         -- Mô tả bệnh
    causes TEXT,                              -- Nguyên nhân
    image_url TEXT,                           -- URL hình ảnh minh họa
    treatment_duration_reference VARCHAR(100), -- Thời gian điều trị tham khảo (admin nhập)
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- 2. Bảng UserHealthCondition - Bệnh của user
CREATE TABLE IF NOT EXISTS UserHealthCondition (
    user_condition_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    condition_id INT REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
    diagnosed_date DATE DEFAULT CURRENT_DATE,
    treatment_start_date DATE DEFAULT CURRENT_DATE,
    treatment_end_date DATE,                  -- User tự thiết lập
    treatment_duration_days INT,              -- Số ngày điều trị (tính từ start đến end)
    status VARCHAR(20) DEFAULT 'active',      -- active, completed, paused
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, condition_id, treatment_start_date)
);

-- 3. Bảng MedicationSchedule - Lịch uống thuốc
CREATE TABLE IF NOT EXISTS MedicationSchedule (
    medication_id SERIAL PRIMARY KEY,
    user_condition_id INT REFERENCES UserHealthCondition(user_condition_id) ON DELETE CASCADE,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    medication_times TEXT[],                  -- ['07:00', '12:00', '19:00'] - giờ uống thuốc
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 4. Bảng MedicationLog - Lịch sử uống thuốc
CREATE TABLE IF NOT EXISTS MedicationLog (
    log_id SERIAL PRIMARY KEY,
    user_condition_id INT REFERENCES UserHealthCondition(user_condition_id) ON DELETE CASCADE,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    medication_date DATE NOT NULL,
    medication_time TIME NOT NULL,
    taken_at TIMESTAMP,                       -- Thời điểm thực tế đánh dấu đã uống
    status VARCHAR(20) DEFAULT 'pending',     -- pending, taken, skipped
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_condition_id, medication_date, medication_time)
);

-- 5. Cập nhật lại ConditionNutrientEffect (hiệu ứng dinh dưỡng)
DROP TABLE IF EXISTS ConditionNutrientEffect CASCADE;
CREATE TABLE ConditionNutrientEffect (
    effect_id SERIAL PRIMARY KEY,
    condition_id INT REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
    nutrient_id INT REFERENCES Nutrient(nutrient_id) ON DELETE CASCADE,
    effect_type VARCHAR(10) CHECK (effect_type IN ('increase', 'decrease')),
    adjustment_percent NUMERIC(5,2) NOT NULL, -- % điều chỉnh (+40, -20...)
    notes TEXT,
    UNIQUE(condition_id, nutrient_id)
);

-- 6. Cập nhật lại ConditionFoodRecommendation (thực phẩm tránh)
DROP TABLE IF EXISTS ConditionFoodRecommendation CASCADE;
CREATE TABLE ConditionFoodRecommendation (
    recommendation_id SERIAL PRIMARY KEY,
    condition_id INT REFERENCES HealthCondition(condition_id) ON DELETE CASCADE,
    food_id INT REFERENCES Food(food_id) ON DELETE CASCADE,
    recommendation_type VARCHAR(10) DEFAULT 'avoid' CHECK (recommendation_type IN ('recommend', 'avoid')),
    notes TEXT,
    UNIQUE(condition_id, food_id)
);

-- 7. Cập nhật lại ConditionEffectLog (log thay đổi RDA)
DROP TABLE IF EXISTS ConditionEffectLog CASCADE;
CREATE TABLE ConditionEffectLog (
    log_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
    condition_id INT REFERENCES HealthCondition(condition_id),
    nutrient_id INT REFERENCES Nutrient(nutrient_id),
    effect_type VARCHAR(10),
    adjustment_percent NUMERIC(5,2),
    original_rda NUMERIC(10,2),
    adjusted_rda NUMERIC(10,2),
    applied_at TIMESTAMP DEFAULT NOW()
);

-- 8. Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_health_condition_user ON UserHealthCondition(user_id);
CREATE INDEX IF NOT EXISTS idx_user_health_condition_status ON UserHealthCondition(status);
CREATE INDEX IF NOT EXISTS idx_medication_schedule_user ON MedicationSchedule(user_id);
CREATE INDEX IF NOT EXISTS idx_medication_log_user_date ON MedicationLog(user_id, medication_date);
CREATE INDEX IF NOT EXISTS idx_condition_nutrient_effect ON ConditionNutrientEffect(condition_id);
CREATE INDEX IF NOT EXISTS idx_condition_food_recommendation ON ConditionFoodRecommendation(condition_id);

-- 9. Function tự động tính treatment_duration_days
CREATE OR REPLACE FUNCTION calculate_treatment_duration() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.treatment_end_date IS NOT NULL AND NEW.treatment_start_date IS NOT NULL THEN
        NEW.treatment_duration_days := NEW.treatment_end_date - NEW.treatment_start_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_calculate_treatment_duration
    BEFORE INSERT OR UPDATE ON UserHealthCondition
    FOR EACH ROW
    EXECUTE FUNCTION calculate_treatment_duration();

-- 10. Seed data - 10 bệnh mẫu
INSERT INTO HealthCondition (condition_id, name_vi, name_en, category, description, causes, treatment_duration_reference) VALUES
(1, 'Tiểu đường type 2', 'Type 2 Diabetes', 'Chuyển hóa', 'Cơ thể kháng insulin làm đường huyết tăng cao.', 'Thừa cân, ít vận động, ăn nhiều tinh bột tinh chế.', 'Dài hạn'),
(2, 'Cao huyết áp', 'Hypertension', 'Tim mạch', 'Huyết áp tăng cao mạn tính.', 'Ăn mặn, ít kali, stress, di truyền.', 'Dài hạn'),
(3, 'Mỡ máu cao', 'High Cholesterol', 'Tim mạch', 'LDL và Cholesterol cao dẫn đến xơ vữa mạch.', 'Ăn nhiều mỡ bão hòa, trans fat, ít vận động.', '3–6 tháng'),
(4, 'Béo phì', 'Obesity', 'Chuyển hóa', 'Tích lũy mỡ thừa do thừa năng lượng.', 'Ăn nhiều tinh bột tinh chế, chất béo, ít hoạt động.', '3–12 tháng'),
(5, 'Gout', 'Gout', 'Chuyển hóa', 'Acid uric cao gây viêm khớp.', 'Ăn nhiều purine: thịt đỏ, hải sản.', '1–3 tháng (duy trì lâu dài)'),
(6, 'Gan nhiễm mỡ', 'Fatty Liver', 'Gan', 'Mỡ tích tụ trong gan.', 'Dư đường, chất béo bão hòa, béo phì.', '2–6 tháng'),
(7, 'Viêm dạ dày', 'Gastritis', 'Tiêu hóa', 'Viêm niêm mạc dạ dày.', 'HP, stress, đồ chua và dầu mỡ.', '2–8 tuần'),
(8, 'Thiếu máu', 'Anemia', 'Huyết học', 'Thiếu hồng cầu do thiếu sắt, B12 hoặc folate.', 'Ăn thiếu sắt, thiếu vitamin B12 hoặc B9.', '1–3 tháng'),
(9, 'Suy dinh dưỡng', 'Malnutrition', 'Dinh dưỡng', 'Thiếu năng lượng và đạm.', 'Ăn không đủ protein và năng lượng.', '1–3 tháng'),
(10, 'Dị ứng thực phẩm', 'Food Allergy', 'Miễn dịch', 'Phản ứng miễn dịch với protein thực phẩm.', 'Cơ địa dị ứng, di truyền.', 'Lâu dài')
ON CONFLICT (name_vi) DO NOTHING;

-- 11. Seed ConditionNutrientEffect data
-- Tiểu đường type 2
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(1, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Dietary Fiber%' LIMIT 1), 'increase', 40),
(1, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Soluble Fiber%' LIMIT 1), 'increase', 30),
(1, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Magnesium%' LIMIT 1), 'increase', 15),
(1, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Potassium%' LIMIT 1), 'increase', 15),
(1, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Saturated%' LIMIT 1), 'decrease', -20);

-- Cao huyết áp
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(2, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Potassium%' LIMIT 1), 'increase', 30),
(2, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Magnesium%' LIMIT 1), 'increase', 20),
(2, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Calcium%' LIMIT 1), 'increase', 15),
(2, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Dietary Fiber%' LIMIT 1), 'increase', 20),
(2, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Sodium%' LIMIT 1), 'decrease', -50);

-- Mỡ máu cao
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(3, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Monounsaturated%' LIMIT 1), 'increase', 25),
(3, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Polyunsaturated%' LIMIT 1), 'increase', 25),
(3, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Dietary Fiber%' LIMIT 1), 'increase', 30),
(3, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Saturated%' LIMIT 1), 'decrease', -40),
(3, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Trans%' LIMIT 1), 'decrease', -90),
(3, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Cholesterol%' LIMIT 1), 'decrease', -30);

-- Béo phì
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(4, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Dietary Fiber%' LIMIT 1), 'increase', 50),
(4, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Leucine%' LIMIT 1), 'increase', 20),
(4, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Fat%' LIMIT 1), 'decrease', -30),
(4, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Saturated%' LIMIT 1), 'decrease', -30);

-- Gout  
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(5, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Dietary Fiber%' LIMIT 1), 'increase', 20),
(5, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin C%' LIMIT 1), 'increase', 20);

-- Gan nhiễm mỡ
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(6, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Dietary Fiber%' LIMIT 1), 'increase', 30),
(6, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin E%' LIMIT 1), 'increase', 10),
(6, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Saturated%' LIMIT 1), 'decrease', -30),
(6, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Trans%' LIMIT 1), 'decrease', -90);

-- Viêm dạ dày
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(7, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin B12%' LIMIT 1), 'increase', 10),
(7, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Total Fat%' LIMIT 1), 'decrease', -30);

-- Thiếu máu
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(8, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Iron%' LIMIT 1), 'increase', 50),
(8, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin B12%' LIMIT 1), 'increase', 40),
(8, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Folate%' OR name ILIKE '%B9%' LIMIT 1), 'increase', 30),
(8, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin C%' LIMIT 1), 'increase', 30);

-- Suy dinh dưỡng
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(9, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Leucine%' LIMIT 1), 'increase', 50),
(9, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Lysine%' LIMIT 1), 'increase', 50),
(9, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Calcium%' LIMIT 1), 'increase', 20),
(9, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Phosphorus%' LIMIT 1), 'increase', 20);

-- Dị ứng thực phẩm
INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent) VALUES
(10, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin D%' LIMIT 1), 'increase', 10),
(10, (SELECT nutrient_id FROM Nutrient WHERE name ILIKE '%Vitamin A%' LIMIT 1), 'increase', 10);

COMMENT ON TABLE HealthCondition IS 'Danh sách các bệnh/tình trạng sức khỏe';
COMMENT ON TABLE UserHealthCondition IS 'Bệnh mà user đang mắc';
COMMENT ON TABLE MedicationSchedule IS 'Lịch uống thuốc của user';
COMMENT ON TABLE MedicationLog IS 'Lịch sử uống thuốc hàng ngày';
COMMENT ON TABLE ConditionNutrientEffect IS 'Hiệu ứng dinh dưỡng của từng bệnh';
COMMENT ON TABLE ConditionFoodRecommendation IS 'Thực phẩm nên ăn/tránh cho từng bệnh';
