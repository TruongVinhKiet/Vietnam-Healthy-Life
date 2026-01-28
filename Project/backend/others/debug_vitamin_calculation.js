const db = require('./db');

async function debugVitaminCalculation() {
  try {
    const yesterday = '2025-11-19';
    
    // Step 1: Get meals
    console.log('Step 1: Meals for user 1 on', yesterday);
    const meals = await db.query(`
      SELECT DISTINCT mi.food_id, f.name, SUM(mi.weight_g) as total_weight
      FROM meal m
      JOIN mealitem mi ON m.meal_id = mi.meal_id
      JOIN food f ON mi.food_id = f.food_id
      WHERE m.user_id = 1 AND m.meal_date = $1
      GROUP BY mi.food_id, f.name
    `, [yesterday]);
    
    console.log(`Found ${meals.rows.length} distinct foods:`);
    meals.rows.forEach(m => console.log(`  ${m.name} (ID: ${m.food_id}, ${m.total_weight}g total)`));
    
    // Step 2: Check which have vitamin data
    console.log('\n\nStep 2: Checking FoodNutrient for vitamins in those foods');
    for (const meal of meals.rows) {
      const vitamins = await db.query(`
        SELECT n.nutrient_code, n.name, fn.amount_per_100g
        FROM foodnutrient fn
        JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
        WHERE fn.food_id = $1 AND n.nutrient_code LIKE 'VIT%'
        ORDER BY n.nutrient_code
      `, [meal.food_id]);
      
      if (vitamins.rows.length > 0) {
        console.log(`\n  ${meal.name} (ID ${meal.food_id}):`);
        vitamins.rows.forEach(v => {
          const total = (parseFloat(v.amount_per_100g) * parseFloat(meal.total_weight) / 100).toFixed(2);
          console.log(`    ${v.nutrient_code}: ${v.amount_per_100g}/100g × ${meal.total_weight}g = ${total}mg`);
        });
      } else {
        console.log(`\n  ${meal.name} (ID ${meal.food_id}): NO vitamin data in FoodNutrient`);
      }
    }
    
    // Step 3: Manual calculation using the same logic as function
    console.log('\n\nStep 3: Manual vitamin calculation (same as function)');
    const manualCalc = await db.query(`
      WITH meal_items_today AS (
        SELECT mi.food_id, mi.weight_g
        FROM MealItem mi
        JOIN Meal m ON m.meal_id = mi.meal_id
        WHERE m.user_id = 1 AND m.meal_date = $1
      )
      SELECT 
        v.code as vitamin_code,
        v.name as vitamin_name,
        n.nutrient_id,
        n.nutrient_code,
        COUNT(fn.food_nutrient_id) as foodnutrient_matches,
        COUNT(mit.food_id) as meal_item_matches,
        COALESCE(SUM(fn.amount_per_100g * mit.weight_g / 100.0), 0) as total
      FROM Vitamin v
      LEFT JOIN Nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
      LEFT JOIN FoodNutrient fn ON fn.nutrient_id = n.nutrient_id
      LEFT JOIN meal_items_today mit ON mit.food_id = fn.food_id
      GROUP BY v.code, v.name, n.nutrient_id, n.nutrient_code
      ORDER BY v.code
    `, [yesterday]);
    
    console.log('\nManual calculation results:');
    manualCalc.rows.forEach(r => {
      if (parseFloat(r.total) > 0) {
        console.log(`  ✅ ${r.vitamin_code}: ${r.total}mg (${r.foodnutrient_matches} FN records, ${r.meal_item_matches} meal matches)`);
      } else {
        console.log(`  ❌ ${r.vitamin_code}: 0mg (${r.foodnutrient_matches} FN records, ${r.meal_item_matches} meal matches)`);
      }
    });

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

debugVitaminCalculation();
