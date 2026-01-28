// Check database directly
const db = require('./db');

async function checkDatabase() {
  try {
    // Check user 5
    console.log('=== USER 5 INFO ===');
    const userResult = await db.query('SELECT user_id, email FROM "User" WHERE user_id = 5');
    console.log('User:', userResult.rows[0]);

    // Check user conditions
    console.log('\n=== USER 5 CONDITIONS ===');
    const condResult = await db.query(`
      SELECT uhc.*, hc.name_vi, hc.condition_id
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON hc.condition_id = uhc.condition_id
      WHERE uhc.user_id = 5 AND uhc.status = 'active'
    `);
    console.log('Conditions:', condResult.rows);

    // Check drugs for condition 1 (Tiểu đường type 2)
    console.log('\n=== DRUGS FOR CONDITION 1 (Tiểu đường type 2) ===');
    const drugsResult = await db.query(`
      SELECT 
        d.drug_id,
        d.name_vi,
        d.generic_name,
        MAX(dhc.is_primary::int) > 0 as is_primary
      FROM drug d
      JOIN drughealthcondition dhc ON dhc.drug_id = d.drug_id
      WHERE dhc.condition_id = 1
        AND d.is_active = TRUE
      GROUP BY d.drug_id
      ORDER BY MAX(dhc.is_primary::int) DESC, d.name_vi
      LIMIT 10
    `);
    console.log(`Found ${drugsResult.rows.length} drugs:`);
    drugsResult.rows.forEach(drug => {
      console.log(`  - ${drug.name_vi} (Primary: ${drug.is_primary})`);
    });

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

checkDatabase();
