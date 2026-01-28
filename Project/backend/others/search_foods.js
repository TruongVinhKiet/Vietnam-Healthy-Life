const {Pool} = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'Health',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || ''
});

(async () => {
  try {
    // Check total foods
    const count = await pool.query('SELECT COUNT(*) FROM food');
    console.log(`Total foods in database: ${count.rows[0].count}`);
    
    // Search for Vietnamese foods
    const vnFoods = await pool.query(`
      SELECT food_id, name, category 
      FROM food 
      WHERE name ILIKE '%bò%' 
         OR name ILIKE '%thịt%'
         OR name ILIKE '%gà%'
         OR name ILIKE '%tôm%'
         OR name ILIKE '%cá%'
      LIMIT 20
    `);
    
    console.log(`\nFound ${vnFoods.rows.length} Vietnamese-named foods:`);
    vnFoods.rows.forEach(f => {
      console.log(`  ${f.food_id}: ${f.name} (${f.category || 'no category'})`);
    });
    
    // Try English search
    const enFoods = await pool.query(`
      SELECT food_id, name, category 
      FROM food 
      WHERE name ILIKE '%beef%'
         OR name ILIKE '%chicken%'
         OR name ILIKE '%pork%'
         OR name ILIKE '%rice%'
      LIMIT 10
    `);
    
    console.log(`\nFound ${enFoods.rows.length} English-named foods:`);
    enFoods.rows.forEach(f => {
      console.log(`  ${f.food_id}: ${f.name}`);
    });
    
  } catch (e) {
    console.log('Error:', e.message);
  } finally {
    await pool.end();
  }
})();
