const db = require('../db');

async function main() {
  const today = new Date().toISOString().split('T')[0];
  
  // Check API result for fatty acids
  const result = await db.query(
    "SELECT * FROM calculate_daily_nutrient_intake(1, $1) WHERE nutrient_type = 'fatty_acid'",
    [today]
  );
  
  console.log('API fatty_acid result:', JSON.stringify(result.rows, null, 2));
  
  // Check API result for fiber
  const fiberResult = await db.query(
    "SELECT * FROM calculate_daily_nutrient_intake(1, $1) WHERE nutrient_type = 'fiber'",
    [today]
  );
  
  console.log('API fiber result:', JSON.stringify(fiberResult.rows, null, 2));
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

