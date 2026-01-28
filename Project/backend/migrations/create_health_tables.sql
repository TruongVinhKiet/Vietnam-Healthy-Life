-- Drop old healthcondition table if exists (has wrong structure)
DROP TABLE IF EXISTS healthcondition CASCADE;

-- Create healthcondition table first
CREATE TABLE IF NOT EXISTS healthcondition (
    condition_id SERIAL PRIMARY KEY,
    condition_name VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    category VARCHAR(100),
    severity_level VARCHAR(20),
    icd_code VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create userhealthcondition table
CREATE TABLE IF NOT EXISTS userhealthcondition (
    user_condition_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    condition_id INT NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
    diagnosis_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    severity VARCHAR(20),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, condition_id)
);

-- Create usermedication table
CREATE TABLE IF NOT EXISTS usermedication (
    user_medication_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL REFERENCES "User"(user_id) ON DELETE CASCADE,
    medication_name VARCHAR(200) NOT NULL,
    dosage VARCHAR(100),
    frequency VARCHAR(100),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20) DEFAULT 'active',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create dailymedication table
CREATE TABLE IF NOT EXISTS dailymedication (
    daily_med_id SERIAL PRIMARY KEY,
    user_medication_id INT NOT NULL REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    time_scheduled TIME,
    time_taken TIME,
    status VARCHAR(20) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_medication_id, date, time_scheduled)
);

-- Create medicationschedule table
CREATE TABLE IF NOT EXISTS medicationschedule (
    schedule_id SERIAL PRIMARY KEY,
    user_medication_id INT NOT NULL REFERENCES usermedication(user_medication_id) ON DELETE CASCADE,
    time_of_day TIME NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_medication_id, time_of_day)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_healthcondition_name ON healthcondition(condition_name);
CREATE INDEX IF NOT EXISTS idx_healthcondition_category ON healthcondition(category);
CREATE INDEX IF NOT EXISTS idx_userhealthcondition_user ON userhealthcondition(user_id);
CREATE INDEX IF NOT EXISTS idx_userhealthcondition_status ON userhealthcondition(status);
CREATE INDEX IF NOT EXISTS idx_usermedication_user ON usermedication(user_id);
CREATE INDEX IF NOT EXISTS idx_usermedication_status ON usermedication(status);
CREATE INDEX IF NOT EXISTS idx_dailymedication_date ON dailymedication(date);
CREATE INDEX IF NOT EXISTS idx_dailymedication_status ON dailymedication(status);

-- Insert some common health conditions
INSERT INTO healthcondition (condition_name, description, category, severity_level) VALUES
('Diabetes Type 2', 'Chronic condition affecting blood sugar regulation', 'Metabolic', 'Moderate'),
('Hypertension', 'High blood pressure condition', 'Cardiovascular', 'Moderate'),
('High Cholesterol', 'Elevated cholesterol levels', 'Cardiovascular', 'Moderate'),
('Heart Disease', 'Various heart conditions', 'Cardiovascular', 'High'),
('Obesity', 'Excess body weight condition', 'Metabolic', 'Moderate'),
('Kidney Disease', 'Impaired kidney function', 'Renal', 'High'),
('Celiac Disease', 'Gluten intolerance', 'Digestive', 'Moderate'),
('Food Allergies', 'Adverse immune response to foods', 'Allergic', 'Variable'),
('Gout', 'Inflammatory arthritis from uric acid', 'Metabolic', 'Moderate'),
('Anemia', 'Low red blood cell count', 'Hematological', 'Moderate')
ON CONFLICT (condition_name) DO NOTHING;

-- Create ConditionNutrientEffect table to fix query errors
CREATE TABLE IF NOT EXISTS conditionnutrienteffect (
    effect_id SERIAL PRIMARY KEY,
    condition_id INT NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
    nutrient_id INT NOT NULL REFERENCES nutrient(nutrient_id) ON DELETE CASCADE,
    effect_type VARCHAR(50),
    adjustment_percentage DECIMAL(5,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(condition_id, nutrient_id)
);

CREATE INDEX IF NOT EXISTS idx_conditionnutrienteffect_condition ON conditionnutrienteffect(condition_id);
CREATE INDEX IF NOT EXISTS idx_conditionnutrienteffect_nutrient ON conditionnutrienteffect(nutrient_id);

