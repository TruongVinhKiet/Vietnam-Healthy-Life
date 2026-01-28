const db = require('../db');

async function main() {
  const result = await db.query(`
    SELECT column_name 
    FROM information_schema.columns 
    WHERE table_name = 'fattyacidrequirement'
  `);
  console.log('FattyAcidRequirement columns:', result.rows.map(x => x.column_name));
  
  // Check existing data
  const data = await db.query('SELECT * FROM FattyAcidRequirement LIMIT 3');
  console.log('Sample data:', JSON.stringify(data.rows, null, 2));
  
  process.exit(0);
}

main().catch(e => { console.error(e); process.exit(1); });

