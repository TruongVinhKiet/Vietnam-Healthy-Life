const db = require('./db');
const fs = require('fs');

async function fixNutrientFunction() {
  try {
    console.log('Checking table schemas...\n');

    // Check Fiber table
    const fiberCols = await db.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'fiber' 
      ORDER BY ordinal_position
    `);
    console.log('Fiber columns:', fiberCols.rows.map(r => r.column_name).join(', '));

    // Check if Vitamin, Mineral, etc have recommended_daily
    const vitaminCols = await db.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'vitamin' 
      ORDER BY ordinal_position
    `);
    console.log('Vitamin columns:', vitaminCols.rows.map(r => r.column_name).join(', '));

    const mineralCols = await db.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'mineral' 
      ORDER BY ordinal_position
    `);
    console.log('Mineral columns:', mineralCols.rows.map(r => r.column_name).join(', '));

    // Check FattyAcid
    const fattyAcidCols = await db.query(`
      SELECT column_name FROM information_schema.columns 
      WHERE table_name = 'fattyacid' 
      ORDER BY ordinal_position
    `);
    console.log('FattyAcid columns:', fattyAcidCols.rows.map(r => r.column_name).join(', '));

    // Create corrected function
    console.log('\n\nCreating fixed function...');
    
    const sql = `
DROP FUNCTION IF EXISTS calculate_daily_nutrient_intake(INT, DATE);

CREATE OR REPLACE FUNCTION calculate_daily_nutrient_intake(
    p_user_id INT,
    p_date DATE
) RETURNS TABLE(
    nutrient_type VARCHAR(20),
    nutrient_id INT,
    nutrient_code VARCHAR(50),
    nutrient_name VARCHAR(100),
    current_amount NUMERIC,
    target_amount NUMERIC,
    unit VARCHAR(20),
    percentage NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    WITH meal_items_today AS (
        SELECT mi.food_id, mi.weight_g
        FROM MealItem mi
        JOIN Meal m ON m.meal_id = mi.meal_id
        WHERE m.user_id = p_user_id AND m.meal_date = p_date
    ),
    vitamin_intake AS (
        SELECT 
            'vitamin'::VARCHAR(20) as nutrient_type,
            v.vitamin_id::INT as nutrient_id,
            v.code as nutrient_code,
            v.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uvr.recommended, 0) as target_amount,
            v.unit,
            CASE 
                WHEN COALESCE(uvr.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uvr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Vitamin v
        LEFT JOIN UserVitaminRequirement uvr ON uvr.vitamin_id = v.vitamin_id AND uvr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY v.vitamin_id, v.code, v.name, v.unit, uvr.recommended
    ),
    mineral_intake AS (
        SELECT 
            'mineral'::VARCHAR(20) as nutrient_type,
            m.mineral_id::INT as nutrient_id,
            m.code as nutrient_code,
            m.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(umr.recommended, 0) as target_amount,
            m.unit,
            CASE 
                WHEN COALESCE(umr.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(umr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Mineral m
        LEFT JOIN UserMineralRequirement umr ON umr.mineral_id = m.mineral_id AND umr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(REPLACE(m.code, 'MIN_', ''))
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY m.mineral_id, m.code, m.name, m.unit, umr.recommended
    ),
    amino_acid_intake AS (
        SELECT 
            'amino_acid'::VARCHAR(20) as nutrient_type,
            aa.amino_acid_id::INT as nutrient_id,
            aa.code as nutrient_code,
            aa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(uar.recommended, 0) as target_amount,
            'mg'::VARCHAR(20) as unit,
            CASE 
                WHEN COALESCE(uar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(uar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM AminoAcid aa
        LEFT JOIN UserAminoRequirement uar ON uar.amino_acid_id = aa.amino_acid_id AND uar.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(aa.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY aa.amino_acid_id, aa.code, aa.name, uar.recommended
    ),
    fiber_intake AS (
        SELECT 
            'fiber'::VARCHAR(20) as nutrient_type,
            f.fiber_id::INT as nutrient_id,
            f.code as nutrient_code,
            f.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(ufr.recommended, 0) as target_amount,
            f.unit,
            CASE 
                WHEN COALESCE(ufr.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(ufr.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM Fiber f
        LEFT JOIN UserFiberRequirement ufr ON ufr.fiber_id = f.fiber_id AND ufr.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(f.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY f.fiber_id, f.code, f.name, f.unit, ufr.recommended
    ),
    fatty_acid_intake AS (
        SELECT 
            'fatty_acid'::VARCHAR(20) as nutrient_type,
            fa.fatty_acid_id::INT as nutrient_id,
            fa.code as nutrient_code,
            fa.name as nutrient_name,
            COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as current_amount,
            COALESCE(ufar.recommended, 0) as target_amount,
            fa.unit,
            CASE 
                WHEN COALESCE(ufar.recommended, 0) > 0 
                THEN (COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) / COALESCE(ufar.recommended, 1)) * 100
                ELSE 0 
            END as percentage
        FROM FattyAcid fa
        LEFT JOIN UserFattyAcidRequirement ufar ON ufar.fatty_acid_id = fa.fatty_acid_id AND ufar.user_id = p_user_id
        LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(fa.code)
        LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
        LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
        GROUP BY fa.fatty_acid_id, fa.code, fa.name, fa.unit, ufar.recommended
    )
    SELECT * FROM vitamin_intake
    UNION ALL
    SELECT * FROM mineral_intake
    UNION ALL
    SELECT * FROM amino_acid_intake
    UNION ALL
    SELECT * FROM fiber_intake
    UNION ALL
    SELECT * FROM fatty_acid_intake;
END;
$$ LANGUAGE plpgsql;
`;

    await db.query(sql);
    console.log('✅ Function created successfully!\n');

    // Test it
    console.log('Testing function with yesterday\'s data...');
    const yesterday = '2025-11-19';
    const result = await db.query(
      'SELECT * FROM calculate_daily_nutrient_intake(1, $1) WHERE nutrient_type IN (\'vitamin\', \'mineral\') ORDER BY nutrient_type, nutrient_name',
      [yesterday]
    );

    const vitamins = result.rows.filter(n => n.nutrient_type === 'vitamin');
    const minerals = result.rows.filter(n => n.nutrient_type === 'mineral');
    
    const vitaminsWithValue = vitamins.filter(n => parseFloat(n.current_amount || 0) > 0);
    const mineralsWithValue = minerals.filter(n => parseFloat(n.current_amount || 0) > 0);
    
    console.log(`\nVitamins: ${vitamins.length} total, ${vitaminsWithValue.length} with consumption`);
    console.log(`Minerals: ${minerals.length} total, ${mineralsWithValue.length} with consumption`);
    
    if (vitaminsWithValue.length > 0) {
      console.log('\n✅ Sample vitamins with values:');
      vitaminsWithValue.slice(0, 5).forEach(v => {
        console.log(`  ${v.nutrient_name} (${v.nutrient_code}): ${v.current_amount} ${v.unit} (${v.percentage}%)`);
      });
    }
    
    if (mineralsWithValue.length > 0) {
      console.log('\n✅ Sample minerals with values:');
      mineralsWithValue.slice(0, 5).forEach(m => {
        console.log(`  ${m.nutrient_name} (${m.nutrient_code}): ${m.current_amount} ${m.unit} (${m.percentage}%)`);
      });
    }

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

fixNutrientFunction();
