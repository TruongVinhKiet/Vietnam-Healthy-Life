-- Fix all column name issues in health tables

-- 1. Add missing columns to healthcondition table
ALTER TABLE healthcondition 
ADD COLUMN IF NOT EXISTS name_vi VARCHAR(200),
ADD COLUMN IF NOT EXISTS description_vi TEXT,
ADD COLUMN IF NOT EXISTS treatment_duration_reference VARCHAR(200);

-- Update existing data with Vietnamese names
UPDATE healthcondition SET 
  name_vi = 'Tiểu đường type 2',
  description_vi = 'Bệnh mãn tính ảnh hưởng đến điều hòa đường huyết'
WHERE condition_name = 'Diabetes Type 2';

UPDATE healthcondition SET 
  name_vi = 'Cao huyết áp',
  description_vi = 'Tình trạng huyết áp cao'
WHERE condition_name = 'Hypertension';

UPDATE healthcondition SET 
  name_vi = 'Cholesterol cao',
  description_vi = 'Mức cholesterol tăng cao'
WHERE condition_name = 'High Cholesterol';

UPDATE healthcondition SET 
  name_vi = 'Bệnh tim',
  description_vi = 'Các bệnh lý về tim'
WHERE condition_name = 'Heart Disease';

UPDATE healthcondition SET 
  name_vi = 'Béo phì',
  description_vi = 'Tình trạng cân nặng vượt mức'
WHERE condition_name = 'Obesity';

UPDATE healthcondition SET 
  name_vi = 'Bệnh thận',
  description_vi = 'Chức năng thận suy giảm'
WHERE condition_name = 'Kidney Disease';

UPDATE healthcondition SET 
  name_vi = 'Bệnh Celiac',
  description_vi = 'Không dung nạp gluten'
WHERE condition_name = 'Celiac Disease';

UPDATE healthcondition SET 
  name_vi = 'Dị ứng thực phẩm',
  description_vi = 'Phản ứng miễn dịch bất lợi với thực phẩm'
WHERE condition_name = 'Food Allergies';

UPDATE healthcondition SET 
  name_vi = 'Gút (Gout)',
  description_vi = 'Viêm khớp do axit uric'
WHERE condition_name = 'Gout';

UPDATE healthcondition SET 
  name_vi = 'Thiếu máu',
  description_vi = 'Số lượng hồng cầu thấp'
WHERE condition_name = 'Anemia';

-- 2. Fix conditionnutrienteffect - needs major restructuring
-- First check if the table has the old structure
DO $$ 
BEGIN
    -- Add condition_id column if it doesn't exist
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='conditionnutrienteffect' AND column_name='condition_id'
    ) THEN
        ALTER TABLE conditionnutrienteffect ADD COLUMN condition_id INT;
    END IF;
    
    -- Rename impact_percent to adjustment_percent if it exists
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name='conditionnutrienteffect' AND column_name='impact_percent'
    ) THEN
        ALTER TABLE conditionnutrienteffect RENAME COLUMN impact_percent TO adjustment_percent;
    END IF;
END $$;

-- 3. Add missing columns to bodymeasurement table
ALTER TABLE bodymeasurement 
ADD COLUMN IF NOT EXISTS bmi_score INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS body_fat_score INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS muscle_mass_score INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS overall_score INT DEFAULT 0;

-- 4. Add missing columns to usernutrientnotification table  
ALTER TABLE usernutrientnotification 
ADD COLUMN IF NOT EXISTS nutrient_type VARCHAR(50);

-- 5. Add missing column to User table for avatar
ALTER TABLE "User"
ADD COLUMN IF NOT EXISTS avatar_url TEXT;

-- 6. Fix medicationschedule - ensure it has user_condition_id column
ALTER TABLE medicationschedule 
ADD COLUMN IF NOT EXISTS user_condition_id INT REFERENCES userhealthcondition(user_condition_id) ON DELETE CASCADE;

-- Create index for the new column
CREATE INDEX IF NOT EXISTS idx_medicationschedule_user_condition ON medicationschedule(user_condition_id);

-- 7. Ensure adminconversation table exists (for admin chat)
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

-- 8. Create conditionfoodrecommendation table if missing
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

-- 9. Create conditioneffectlog table if missing
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

COMMENT ON TABLE healthcondition IS 'Fixed: Added name_vi, description_vi columns';
COMMENT ON TABLE conditionnutrienteffect IS 'Fixed: Renamed adjustment_percentage to adjustment_percent';
COMMENT ON TABLE bodymeasurement IS 'Fixed: Added bmi_score, body_fat_score, muscle_mass_score, overall_score';
COMMENT ON TABLE usernutrientnotification IS 'Fixed: Added nutrient_type column';
COMMENT ON TABLE "User" IS 'Fixed: Added avatar_url column';
COMMENT ON TABLE medicationschedule IS 'Fixed: Added user_condition_id column';
