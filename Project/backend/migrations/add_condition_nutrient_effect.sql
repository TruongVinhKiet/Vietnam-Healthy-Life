-- Create ConditionNutrientEffect table
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
