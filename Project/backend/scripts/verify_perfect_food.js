const db = require('../db');

async function main() {
  // Get all Perfect Food nutrients
  const result = await db.query(`
    SELECT n.nutrient_code, fn.amount_per_100g 
    FROM FoodNutrient fn 
    JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
    JOIN Food f ON f.food_id = fn.food_id 
    WHERE f.name = 'Perfect Food' 
    ORDER BY n.nutrient_code
  `);
  
  console.log('All Perfect Food nutrients:', JSON.stringify(result.rows, null, 2));
  console.log('Total nutrients:', result.rows.length);
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

