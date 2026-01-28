const db = require('../db');

async function main() {
  const today = new Date().toISOString().split('T')[0];
  
  // Get meal entries for today
  const meals = await db.query(`
    SELECT me.id, me.food_id, f.name, me.weight_g
    FROM meal_entries me
    JOIN Food f ON f.food_id = me.food_id
    WHERE me.entry_date = $1 AND me.user_id = 5
  `, [today]);
  
  console.log('Meal entries today:', meals.rows);
  
  // For each meal entry, check what fiber/fat nutrients it has
  for (const meal of meals.rows) {
    const fiberNutrients = await db.query(`
      SELECT n.nutrient_code, fn.amount_per_100g, nm.fiber_id, fib.code as fiber_code
      FROM FoodNutrient fn
      JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
      LEFT JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id AND nm.fiber_id IS NOT NULL
      LEFT JOIN Fiber fib ON fib.fiber_id = nm.fiber_id
      WHERE fn.food_id = $1 AND nm.fiber_id IS NOT NULL
    `, [meal.food_id]);
    
    console.log(`\nFood ${meal.food_id} (${meal.name}) fiber nutrients:`, fiberNutrients.rows);
    
    const fatNutrients = await db.query(`
      SELECT n.nutrient_code, fn.amount_per_100g, nm.fatty_acid_id, fa.code as fatty_acid_code
      FROM FoodNutrient fn
      JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id
      LEFT JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id AND nm.fatty_acid_id IS NOT NULL
      LEFT JOIN FattyAcid fa ON fa.fatty_acid_id = nm.fatty_acid_id
      WHERE fn.food_id = $1 AND nm.fatty_acid_id IS NOT NULL
    `, [meal.food_id]);
    
    console.log(`Food ${meal.food_id} (${meal.name}) fatty acid nutrients:`, fatNutrients.rows);
  }
  
  // Check if Perfect Food has been added to any meal today
  const perfectMeal = await db.query(`
    SELECT me.id, me.food_id, f.name, me.weight_g
    FROM meal_entries me
    JOIN Food f ON f.food_id = me.food_id
    WHERE me.entry_date = $1 AND f.name = 'Perfect Food'
  `, [today]);
  
  console.log('\nPerfect Food in meals today:', perfectMeal.rows);
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

