const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function mergeDuplicates() {
  const client = await pool.connect();
  
  try {
    console.log('Merging duplicate foods that are both in use...\n');

    // For "Dau xanh" - merge nutrients and references to the first one (ID 12)
    console.log('Merging Dau xanh (ID 37 -> 12)...');
    await client.query('BEGIN');
    
    // Update ConditionFoodRecommendation to use ID 12
    await client.query(`
      UPDATE conditionfoodrecommendation 
      SET food_id = 12 
      WHERE food_id = 37 
      AND NOT EXISTS (
        SELECT 1 FROM conditionfoodrecommendation 
        WHERE food_id = 12 AND condition_id = conditionfoodrecommendation.condition_id
      )
    `);
    
    // Delete remaining references to 37
    await client.query('DELETE FROM conditionfoodrecommendation WHERE food_id = 37');
    
    // Delete food 37
    await client.query('DELETE FROM food WHERE food_id = 37');
    console.log('✓ Merged Dau xanh');

    // For "Dua" - merge to ID 11
    console.log('\nMerging Dua (ID 36 -> 11)...');
    await client.query(`
      UPDATE conditionfoodrecommendation 
      SET food_id = 11 
      WHERE food_id = 36
      AND NOT EXISTS (
        SELECT 1 FROM conditionfoodrecommendation 
        WHERE food_id = 11 AND condition_id = conditionfoodrecommendation.condition_id
      )
    `);
    await client.query('DELETE FROM conditionfoodrecommendation WHERE food_id = 36');
    await client.query('DELETE FROM food WHERE food_id = 36');
    console.log('✓ Merged Dua');

    // For "Dua leo" - merge to ID 9
    console.log('\nMerging Dua leo (ID 34 -> 9)...');
    await client.query(`
      UPDATE conditionfoodrecommendation 
      SET food_id = 9 
      WHERE food_id = 34
      AND NOT EXISTS (
        SELECT 1 FROM conditionfoodrecommendation 
        WHERE food_id = 9 AND condition_id = conditionfoodrecommendation.condition_id
      )
    `);
    await client.query('DELETE FROM conditionfoodrecommendation WHERE food_id = 34');
    await client.query('DELETE FROM food WHERE food_id = 34');
    console.log('✓ Merged Dua leo');

    // For "Gao" - merge to ID 1
    console.log('\nMerging Gao (ID 26 -> 1)...');
    await client.query(`
      UPDATE conditionfoodrecommendation 
      SET food_id = 1 
      WHERE food_id = 26
      AND NOT EXISTS (
        SELECT 1 FROM conditionfoodrecommendation 
        WHERE food_id = 1 AND condition_id = conditionfoodrecommendation.condition_id
      )
    `);
    await client.query('DELETE FROM conditionfoodrecommendation WHERE food_id = 26');
    await client.query('DELETE FROM food WHERE food_id = 26');
    console.log('✓ Merged Gao');

    // For "Ngo" - merge to ID 6
    console.log('\nMerging Ngo (ID 31 -> 6)...');
    await client.query(`
      UPDATE conditionfoodrecommendation 
      SET food_id = 6 
      WHERE food_id = 31
      AND NOT EXISTS (
        SELECT 1 FROM conditionfoodrecommendation 
        WHERE food_id = 6 AND condition_id = conditionfoodrecommendation.condition_id
      )
    `);
    await client.query('DELETE FROM conditionfoodrecommendation WHERE food_id = 31');
    await client.query('DELETE FROM food WHERE food_id = 31');
    console.log('✓ Merged Ngo');

    await client.query('COMMIT');
    
    console.log('\n✓ All duplicates merged successfully!');
    
    // Verify
    console.log('\nVerifying...');
    const result = await client.query(`
      SELECT name, COUNT(*) as count
      FROM food
      GROUP BY LOWER(TRIM(name))
      HAVING COUNT(*) > 1
    `);
    
    if (result.rows.length === 0) {
      console.log('✓ No more duplicates found!');
    } else {
      console.log('⚠️  Still have duplicates:');
      console.table(result.rows);
    }

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

mergeDuplicates();
