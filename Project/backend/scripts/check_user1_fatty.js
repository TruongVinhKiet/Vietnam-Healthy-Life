const db = require('../db');

async function main() {
  const today = new Date().toISOString().split('T')[0];
  console.log('Checking date:', today);
  
  // Check User 1 FattyAcid intake
  const result = await db.query(`
    SELECT ufai.user_id, fa.code, ufai.amount 
    FROM UserFattyAcidIntake ufai 
    JOIN FattyAcid fa ON fa.fatty_acid_id = ufai.fatty_acid_id 
    WHERE ufai.date = $1 AND ufai.user_id = 1 
    ORDER BY fa.code
  `, [today]);
  
  console.log('User 1 FattyAcid intake:', JSON.stringify(result.rows, null, 2));
  
  // Check User 1 Fiber intake
  const fiberResult = await db.query(`
    SELECT ufi.user_id, f.code, ufi.amount 
    FROM UserFiberIntake ufi 
    JOIN Fiber f ON f.fiber_id = ufi.fiber_id 
    WHERE ufi.date = $1 AND ufi.user_id = 1 
    ORDER BY f.code
  `, [today]);
  
  console.log('User 1 Fiber intake:', JSON.stringify(fiberResult.rows, null, 2));
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

