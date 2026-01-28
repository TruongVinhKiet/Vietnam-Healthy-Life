-- Create nutrienteffect table for health condition nutrient adjustments
CREATE TABLE IF NOT EXISTS nutrienteffect (
  effect_id SERIAL PRIMARY KEY,
  condition_id INTEGER NOT NULL REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
  nutrient_id INTEGER NOT NULL REFERENCES nutrient(nutrient_id) ON DELETE CASCADE,
  adjustment_percent NUMERIC(5,2) NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(condition_id, nutrient_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_nutrienteffect_condition ON nutrienteffect(condition_id);
CREATE INDEX IF NOT EXISTS idx_nutrienteffect_nutrient ON nutrienteffect(nutrient_id);

-- Add some sample data for common conditions
-- Diabetes Type 2 (condition_id = 1): Reduce sugar, increase fiber
INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent) 
SELECT 1, nutrient_id, -30 FROM nutrient WHERE name ILIKE '%sugar%' OR name ILIKE '%glucose%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 1, nutrient_id, 20 FROM nutrient WHERE name ILIKE '%fiber%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

-- Hypertension (condition_id = 2): Reduce sodium, increase potassium
INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 2, nutrient_id, -40 FROM nutrient WHERE name ILIKE '%sodium%' OR name ILIKE '%salt%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 2, nutrient_id, 25 FROM nutrient WHERE name ILIKE '%potassium%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

-- High cholesterol (condition_id = 3): Reduce saturated fat, increase omega-3
INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 3, nutrient_id, -35 FROM nutrient WHERE name ILIKE '%saturated%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 3, nutrient_id, 30 FROM nutrient WHERE name ILIKE '%omega%3%' OR name ILIKE '%EPA%' OR name ILIKE '%DHA%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

-- Anemia (condition_id = 8): Increase iron, B12, folate
INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 8, nutrient_id, 40 FROM nutrient WHERE name ILIKE '%iron%' OR name ILIKE '%ferr%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 8, nutrient_id, 35 FROM nutrient WHERE name ILIKE '%B12%' OR name ILIKE '%cobalamin%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 8, nutrient_id, 35 FROM nutrient WHERE name ILIKE '%folate%' OR name ILIKE '%folic%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

-- Osteoporosis (condition_id = 15): Increase calcium, vitamin D
INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 15, nutrient_id, 50 FROM nutrient WHERE name ILIKE '%calcium%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
SELECT 15, nutrient_id, 45 FROM nutrient WHERE name ILIKE '%vitamin D%'
ON CONFLICT (condition_id, nutrient_id) DO NOTHING;

COMMENT ON TABLE nutrienteffect IS 'Stores nutrient adjustment percentages for health conditions';
COMMENT ON COLUMN nutrienteffect.adjustment_percent IS 'Percentage to adjust nutrient recommendation (positive = increase, negative = decrease)';
