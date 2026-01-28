const db = require('../db');

async function main() {
  try {
    // Test trigger by manually inserting a meal entry
    console.log('Testing amino acid trigger...');
    
    // Get a food with AMINO_* nutrients
    const foodResult = await db.query(`
      SELECT DISTINCT fn.food_id 
      FROM FoodNutrient fn 
      JOIN Nutrient n ON n.nutrient_id = fn.nutrient_id 
      WHERE n.nutrient_code LIKE 'AMINO_%' 
      LIMIT 1
    `);
    
    if (foodResult.rows.length === 0) {
      console.log('No foods with AMINO_* nutrients found');
      process.exit(1);
    }
    
    const foodId = foodResult.rows[0].food_id;
    console.log('Using food_id:', foodId);
    
    // Check NutrientMapping
    const nmResult = await db.query(`
      SELECT nm.amino_acid_id, nm.factor, fn.amount_per_100g, aa.code
      FROM FoodNutrient fn
      JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
      JOIN AminoAcid aa ON aa.amino_acid_id = nm.amino_acid_id
      WHERE fn.food_id = $1 AND nm.amino_acid_id IS NOT NULL
      LIMIT 3
    `, [foodId]);
    
    console.log('NutrientMapping found:', JSON.stringify(nmResult.rows, null, 2));
    
    if (nmResult.rows.length === 0) {
      console.log('No NutrientMapping found for this food');
      process.exit(1);
    }
    
    // Check current UserAminoIntake
    const before = await db.query(`
      SELECT COUNT(*) as count FROM UserAminoIntake 
      WHERE user_id = 5 AND date = CURRENT_DATE
    `);
    console.log('UserAminoIntake before:', before.rows[0].count);
    
    // Test by inserting a meal entry directly (this should trigger)
    const today = new Date().toISOString().split('T')[0];
    const insertResult = await db.query(`
      INSERT INTO meal_entries (user_id, entry_date, meal_type, food_id, weight_g, kcal, carbs, protein, fat)
      VALUES (5, $1, 'lunch', $2, 100, 0, 0, 0, 0)
      RETURNING id
    `, [today, foodId]);
    
    console.log('Created meal entry:', insertResult.rows[0].id);
    
    // Wait a bit for trigger
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Check UserAminoIntake after
    const after = await db.query(`
      SELECT COUNT(*) as count FROM UserAminoIntake 
      WHERE user_id = 5 AND date = CURRENT_DATE
    `);
    console.log('UserAminoIntake after:', after.rows[0].count);
    
    const details = await db.query(`
      SELECT uai.*, aa.code 
      FROM UserAminoIntake uai
      JOIN AminoAcid aa ON aa.amino_acid_id = uai.amino_acid_id
      WHERE uai.user_id = 5 AND uai.date = CURRENT_DATE
      LIMIT 3
    `);
    console.log('UserAminoIntake details:', JSON.stringify(details.rows, null, 2));
    
    process.exit(0);
  } catch (e) {
    console.error('Error:', e.message);
    console.error(e.stack);
    process.exit(1);
  }
}

main();

