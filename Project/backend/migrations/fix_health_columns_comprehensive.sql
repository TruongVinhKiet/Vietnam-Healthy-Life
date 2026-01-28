-- Fix all health table column issues - Comprehensive Fix

-- 1. Add missing columns to healthcondition table
ALTER TABLE healthcondition 
ADD COLUMN IF NOT EXISTS name_vi VARCHAR(200),
ADD COLUMN IF NOT EXISTS description_vi TEXT,
ADD COLUMN IF NOT EXISTS treatment_duration_reference VARCHAR(200);

-- Update existing data with Vietnamese names
UPDATE healthcondition SET name_vi = 'Tiểu đường type 2', description_vi = 'Bệnh mãn tính ảnh hưởng đến điều hòa đường huyết' WHERE condition_name = 'Diabetes Type 2' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Cao huyết áp', description_vi = 'Tình trạng huyết áp cao' WHERE condition_name = 'Hypertension' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Cholesterol cao', description_vi = 'Mức cholesterol tăng cao' WHERE condition_name = 'High Cholesterol' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Bệnh tim', description_vi = 'Các bệnh lý về tim' WHERE condition_name = 'Heart Disease' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Béo phì', description_vi = 'Tình trạng cân nặng vượt mức' WHERE condition_name = 'Obesity' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Bệnh thận', description_vi = 'Chức năng thận suy giảm' WHERE condition_name = 'Kidney Disease' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Bệnh Celiac', description_vi = 'Không dung nạp gluten' WHERE condition_name = 'Celiac Disease' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Dị ứng thực phẩm', description_vi = 'Phản ứng miễn dịch bất lợi với thực phẩm' WHERE condition_name = 'Food Allergies' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Gút (Gout)', description_vi = 'Viêm khớp do axit uric' WHERE condition_name = 'Gout' AND name_vi IS NULL;
UPDATE healthcondition SET name_vi = 'Thiếu máu', description_vi = 'Số lượng hồng cầu thấp' WHERE condition_name = 'Anemia' AND name_vi IS NULL;

-- 2. Fix conditionnutrienteffect table - Add condition_id and rename columns
ALTER TABLE conditionnutrienteffect 
ADD COLUMN IF NOT EXISTS condition_id INT;

-- Rename impact_percent to adjustment_percent (conditionally)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='conditionnutrienteffect' AND column_name='impact_percent') THEN
        ALTER TABLE conditionnutrienteffect RENAME COLUMN impact_percent TO adjustment_percent;
    END IF;
END $$;

-- Populate condition_id from condition_name if needed
UPDATE conditionnutrienteffect cne
SET condition_id = hc.condition_id
FROM healthcondition hc
WHERE cne.condition_name = hc.condition_name
AND cne.condition_id IS NULL;

-- Add foreign key constraint for condition_id
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.table_constraints 
        WHERE table_name = 'conditionnutrienteffect' 
        AND constraint_name = 'fk_conditionnutrienteffect_condition'
    ) THEN
        ALTER TABLE conditionnutrienteffect 
        ADD CONSTRAINT fk_conditionnutrienteffect_condition 
        FOREIGN KEY (condition_id) REFERENCES healthcondition(condition_id) ON DELETE CASCADE;
    END IF;
END $$;

-- Create index for condition_id
CREATE INDEX IF NOT EXISTS idx_conditionnutrienteffect_condition_id ON conditionnutrienteffect(condition_id);

-- 3. Add missing columns to bodymeasurement table
ALTER TABLE bodymeasurement 
ADD COLUMN IF NOT EXISTS bmi_score INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS body_fat_score INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS muscle_mass_score INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS overall_score INT DEFAULT 0;

-- 4. Add missing columns to usernutrientnotification table  
ALTER TABLE usernutrientnotification 
ADD COLUMN IF NOT EXISTS nutrient_type VARCHAR(50) DEFAULT 'vitamin';

-- 5. Add missing column to User table for avatar
ALTER TABLE "User"
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 6. Fix medicationschedule - add user_condition_id WITHOUT foreign key initially
ALTER TABLE medicationschedule 
ADD COLUMN IF NOT EXISTS user_condition_id INT;

-- Create index for the new column
CREATE INDEX IF NOT EXISTS idx_medicationschedule_user_condition ON medicationschedule(user_condition_id);

-- 7. Ensure adminconversation table exists
CREATE TABLE IF NOT EXISTS adminconversation (
    conversation_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    admin_id INT REFERENCES "User"(user_id) ON DELETE SET NULL,
    status VARCHAR(20) DEFAULT 'active',
    last_message_at TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id)
);

CREATE INDEX IF NOT EXISTS idx_adminconversation_user ON adminconversation(user_id);
CREATE INDEX IF NOT EXISTS idx_adminconversation_admin ON adminconversation(admin_id);
CREATE INDEX IF NOT EXISTS idx_adminconversation_status ON adminconversation(status);

-- 8. Ensure conditionfoodrecommendation table exists
CREATE TABLE IF NOT EXISTS conditionfoodrecommendation (
    recommendation_id SERIAL PRIMARY KEY,
    condition_id INT NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
    food_id INT REFERENCES food(food_id) ON DELETE CASCADE,
    recommendation_type VARCHAR(50),
    reason TEXT,
    priority INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(condition_id, food_id)
);

CREATE INDEX IF NOT EXISTS idx_conditionfoodrecommendation_condition ON conditionfoodrecommendation(condition_id);
CREATE INDEX IF NOT EXISTS idx_conditionfoodrecommendation_food ON conditionfoodrecommendation(food_id);

-- 9. Ensure conditioneffectlog table exists
CREATE TABLE IF NOT EXISTS conditioneffectlog (
    log_id SERIAL PRIMARY KEY,
    user_condition_id INT NOT NULL REFERENCES userhealthcondition(user_condition_id) ON DELETE CASCADE,
    log_date DATE NOT NULL DEFAULT CURRENT_DATE,
    symptom_severity INT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_conditioneffectlog_user_condition ON conditioneffectlog(user_condition_id);
CREATE INDEX IF NOT EXISTS idx_conditioneffectlog_date ON conditioneffectlog(log_date);

-- Add comments
COMMENT ON COLUMN healthcondition.name_vi IS 'Vietnamese name for the condition';
COMMENT ON COLUMN healthcondition.description_vi IS 'Vietnamese description';
COMMENT ON COLUMN conditionnutrienteffect.condition_id IS 'Foreign key to healthcondition';
COMMENT ON COLUMN conditionnutrienteffect.adjustment_percent IS 'Percentage adjustment for nutrient (renamed from impact_percent)';
COMMENT ON COLUMN bodymeasurement.bmi_score IS 'BMI health score (0-100)';
COMMENT ON COLUMN usernutrientnotification.nutrient_type IS 'Type: vitamin, mineral, amino_acid, fiber, fatty_acid';
