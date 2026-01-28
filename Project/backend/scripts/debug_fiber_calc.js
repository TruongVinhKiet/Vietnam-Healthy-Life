const db = require('../db');

async function main() {
  const today = new Date().toISOString().split('T')[0];
  
  // Check ALL UserFiberIntake for today (all users)
  const allFiber = await db.query(`
    SELECT ufi.user_id, f.code, ufi.amount 
    FROM UserFiberIntake ufi 
    JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
    WHERE ufi.date = $1
    ORDER BY ufi.user_id, f.code
  `, [today]);
  console.log('ALL UserFiberIntake today:', JSON.stringify(allFiber.rows, null, 2));
  
  // Check ALL UserFattyAcidIntake for today (all users)
  const allFat = await db.query(`
    SELECT ufai.user_id, fa.code, ufai.amount 
    FROM UserFattyAcidIntake ufai 
    JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
    WHERE ufai.date = $1
    ORDER BY ufai.user_id, fa.code
  `, [today]);
  console.log('ALL UserFattyAcidIntake today:', JSON.stringify(allFat.rows, null, 2));
  
  // Check what nutrients FIB_RS maps to
  const fibRsMapping = await db.query(`
    SELECT nm.*, n.nutrient_code, f.code as fiber_code
    FROM NutrientMapping nm
    JOIN Nutrient n ON n.nutrient_id = nm.nutrient_id
    JOIN Fiber f ON f.fiber_id = nm.fiber_id
    WHERE n.nutrient_code = 'FIB_RS'
  `);
  console.log('FIB_RS mapping:', JSON.stringify(fibRsMapping.rows, null, 2));
  
  // Check if any food in meal_entries has FIB_RS nutrient
  const fibRsFoods = await db.query(`
    SELECT DISTINCT me.food_id, f.name, fn.amount_per_100g
    FROM meal_entries me
    JOIN Food f ON f.food_id = me.food_id
    JOIN FoodNutrient fn ON fn.food_id = me.food_id
    JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
    WHERE me.entry_date = $1 AND n.nutrient_code = 'FIB_RS'
  `, [today]);
  console.log('Foods with FIB_RS in meals today:', JSON.stringify(fibRsFoods.rows, null, 2));
  
  // Manual calculation for RESISTANT_STARCH
  const manualCalc = await db.query(`
    SELECT 
        me.user_id,
        nm.fiber_id,
        f.code as fiber_code,
        SUM(fn.amount_per_100g * me.weight_g / 100.0 * COALESCE(nm.factor, 1.0)) as amount
    FROM meal_entries me
    JOIN FoodNutrient fn ON fn.food_id = me.food_id
    JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
    JOIN Fiber f ON f.fiber_id = nm.fiber_id
    WHERE me.entry_date = $1
      AND nm.fiber_id IS NOT NULL
    GROUP BY me.user_id, nm.fiber_id, f.code
    ORDER BY me.user_id, f.code
  `, [today]);
  console.log('Manual fiber calculation:', JSON.stringify(manualCalc.rows, null, 2));
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

