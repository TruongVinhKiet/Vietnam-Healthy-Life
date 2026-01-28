const db = require('../db');

async function main() {
  const today = new Date().toISOString().split('T')[0];
  console.log('Checking date:', today);
  
  // Check UserFiberIntake
  const fiberIntake = await db.query(`
    SELECT ufi.fiber_id, f.code, f.name, ufi.amount 
    FROM UserFiberIntake ufi 
    JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
    WHERE ufi.user_id = 5 AND ufi.date = $1
  `, [today]);
  console.log('UserFiberIntake:', JSON.stringify(fiberIntake.rows, null, 2));
  
  // Check UserFattyAcidIntake
  const fatIntake = await db.query(`
    SELECT ufai.fatty_acid_id, fa.code, fa.name, ufai.amount 
    FROM UserFattyAcidIntake ufai 
    JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
    WHERE ufai.user_id = 5 AND ufai.date = $1
  `, [today]);
  console.log('UserFattyAcidIntake:', JSON.stringify(fatIntake.rows, null, 2));
  
  // Check NutrientMapping for fiber
  const fiberMapping = await db.query(`
    SELECT nm.nutrient_id, n.nutrient_code, nm.fiber_id, f.code as fiber_code, nm.factor
    FROM NutrientMapping nm
    JOIN Nutrient n ON n.nutrient_id = nm.nutrient_id
    LEFT JOIN Fiber f ON f.fiber_id = nm.fiber_id
    WHERE nm.fiber_id IS NOT NULL
  `);
  console.log('NutrientMapping (fiber):', JSON.stringify(fiberMapping.rows, null, 2));
  
  // Check NutrientMapping for fatty acids
  const fatMapping = await db.query(`
    SELECT nm.nutrient_id, n.nutrient_code, nm.fatty_acid_id, fa.code as fatty_acid_code, nm.factor
    FROM NutrientMapping nm
    JOIN Nutrient n ON n.nutrient_id = nm.nutrient_id
    LEFT JOIN FattyAcid fa ON fa.fatty_acid_id = nm.fatty_acid_id
    WHERE nm.fatty_acid_id IS NOT NULL
  `);
  console.log('NutrientMapping (fatty_acid):', JSON.stringify(fatMapping.rows, null, 2));
  
  // Check Perfect Food nutrients
  const perfectFood = await db.query(`
    SELECT fn.food_id, n.nutrient_code, fn.amount_per_100g
    FROM FoodNutrient fn
    JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
    JOIN Food f ON f.food_id = fn.food_id
    WHERE f.name = 'Perfect Food'
    AND n.nutrient_code IN ('RESISTANT_STARCH','BETA_GLUCAN','INSOLUBLE_FIBER','TOTAL_FIBER','SOLUBLE_FIBER','ALA','EPA','DHA','EPA_DHA','LA','CHOLESTEROL','TOTAL_FAT','PUFA','TRANS_FAT','MUFA','SFA')
  `);
  console.log('Perfect Food nutrients:', JSON.stringify(perfectFood.rows, null, 2));
  
  // Check trigger function
  const trigger = await db.query(`
    SELECT tgname, tgenabled 
    FROM pg_trigger 
    WHERE tgname LIKE '%fiber%' OR tgname LIKE '%fatty%'
  `);
  console.log('Triggers:', JSON.stringify(trigger.rows, null, 2));
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

