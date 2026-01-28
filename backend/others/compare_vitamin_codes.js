const db = require('./db');

async function compareVitaminCodes() {
  try {
    const vit = await db.query('SELECT code, name FROM vitamin ORDER BY vitamin_id');
    const nut = await db.query(`SELECT nutrient_code, name FROM nutrient WHERE nutrient_code LIKE 'VIT%' ORDER BY nutrient_code`);
    
    console.log('Vitamin table codes:');
    vit.rows.forEach(r => console.log(`  ${r.code}: ${r.name}`));
    
    console.log('\nNutrient table vitamin codes:');
    nut.rows.forEach(r => console.log(`  ${r.nutrient_code}: ${r.name}`));
    
    console.log('\n\nChecking join between Vitamin and Nutrient:');
    const join = await db.query(`
      SELECT v.code as v_code, v.name as v_name, n.nutrient_code as n_code, n.name as n_name
      FROM vitamin v
      LEFT JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
      ORDER BY v.vitamin_id
    `);
    
    console.log('\nJoin results:');
    join.rows.forEach(r => {
      if (r.n_code) {
        console.log(`  ✅ ${r.v_code} (${r.v_name}) → ${r.n_code} (${r.n_name})`);
      } else {
        console.log(`  ❌ ${r.v_code} (${r.v_name}) → NO MATCH`);
      }
    });

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

compareVitaminCodes();
