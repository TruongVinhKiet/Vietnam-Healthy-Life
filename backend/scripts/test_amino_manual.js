const db = require('../db');

async function main() {
  try {
    const foodId = 3041;
    const today = new Date().toISOString().split('T')[0];
    
    // Get NutrientMapping for this food
    const nmResult = await db.query(`
      SELECT nm.amino_acid_id, nm.factor, fn.amount_per_100g, aa.code
      FROM FoodNutrient fn
      JOIN NutrientMapping nm ON nm.nutrient_id = fn.nutrient_id
      JOIN AminoAcid aa ON aa.amino_acid_id = nm.amino_acid_id
      WHERE fn.food_id = $1 AND nm.amino_acid_id IS NOT NULL
      LIMIT 3
    `, [foodId]);
    
    console.log('NutrientMapping:', JSON.stringify(nmResult.rows, null, 2));
    
    // Manually call upsert_user_amino_intake_specific
    for (const rec of nmResult.rows) {
      const amount = rec.amount_per_100g * rec.factor * (100 / 100.0);
      console.log(`Calling upsert_user_amino_intake_specific(5, ${today}, ${rec.amino_acid_id}, ${amount})`);
      
      await db.query('SELECT upsert_user_amino_intake_specific($1, $2, $3, $4)', [
        5, today, rec.amino_acid_id, amount
      ]);
    }
    
    // Check result
    const result = await db.query(`
      SELECT uai.*, aa.code 
      FROM UserAminoIntake uai
      JOIN AminoAcid aa ON aa.amino_acid_id = uai.amino_acid_id
      WHERE uai.user_id = 5 AND uai.date = $1
    `, [today]);
    
    console.log('UserAminoIntake after manual insert:', JSON.stringify(result.rows, null, 2));
    
    // Test API
    const apiResult = await db.query('SELECT * FROM calculate_daily_nutrient_intake(5, $1) WHERE nutrient_type = \'amino_acid\'', [today]);
    console.log('API result:', JSON.stringify(apiResult.rows.slice(0, 3), null, 2));
    
    process.exit(0);
  } catch (e) {
    console.error('Error:', e.message);
    console.error(e.stack);
    process.exit(1);
  }
}

main();

