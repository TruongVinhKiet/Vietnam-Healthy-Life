const db = require('../db');

async function main() {
  try {
    // Check AminoRequirement
    const arCount = await db.query('SELECT COUNT(*) as count FROM AminoRequirement');
    console.log('AminoRequirement count:', arCount.rows[0].count);
    
    const arSample = await db.query('SELECT ar.*, aa.code FROM AminoRequirement ar JOIN AminoAcid aa ON aa.amino_acid_id = ar.amino_acid_id LIMIT 3');
    console.log('Sample AminoRequirement:', JSON.stringify(arSample.rows, null, 2));
    
    // Check User
    const user = await db.query('SELECT user_id, weight_kg, age, gender FROM "User" WHERE user_id = 5');
    console.log('User 5:', JSON.stringify(user.rows[0], null, 2));
    
    // Check if compute_user_amino_requirement works
    const result = await db.query('SELECT * FROM compute_user_amino_requirement(5, 9)');
    console.log('compute_user_amino_requirement(5, 9):', JSON.stringify(result.rows, null, 2));
    
    // Check meal_entries
    const meals = await db.query('SELECT COUNT(*) as count FROM meal_entries WHERE user_id = 5 AND entry_date = CURRENT_DATE');
    console.log('Meal entries today:', meals.rows[0].count);
    
    // Check NutrientMapping
    const nm = await db.query('SELECT COUNT(*) as count FROM NutrientMapping WHERE amino_acid_id IS NOT NULL');
    console.log('NutrientMapping with amino_acid_id:', nm.rows[0].count);
    
    // Check if foods have AMINO_* nutrients
    const foods = await db.query(`
      SELECT DISTINCT fn.food_id 
      FROM FoodNutrient fn 
      JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
      WHERE n.nutrient_code LIKE 'AMINO_%' 
      LIMIT 5
    `);
    console.log('Foods with AMINO_*:', JSON.stringify(foods.rows, null, 2));
    
    process.exit(0);
  } catch (e) {
    console.error('Error:', e.message);
    console.error(e.stack);
    process.exit(1);
  }
}

main();

