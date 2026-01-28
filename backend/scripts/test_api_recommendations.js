const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function testAPI() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    const userId = 1;
    
    console.log('🔍 TESTING API QUERY FOR USER ID:', userId);
    console.log('='.repeat(80));
    
    const result = await client.query(`
      SELECT DISTINCT 
        f.food_id, 
        f.name, 
        f.name_vi, 
        cfr.recommendation_type,
        hc.name_vi as condition_name
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      JOIN conditionfoodrecommendation cfr ON hc.condition_id = cfr.condition_id
      JOIN food f ON cfr.food_id = f.food_id
      WHERE uhc.user_id = $1
        AND uhc.status = 'active'
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= CURRENT_DATE)
    `, [userId]);

    console.log('\n📊 RAW QUERY RESULT:');
    console.log('Total rows:', result.rows.length);
    
    result.rows.forEach(row => {
      const emoji = row.recommendation_type === 'avoid' ? '🚫' : '✅';
      console.log(`${emoji} [${row.food_id}] ${row.name_vi || row.name} - ${row.condition_name}`);
    });

    const foodsToAvoid = result.rows
      .filter(r => r.recommendation_type === 'avoid')
      .map(r => r.food_id);
    
    const foodsToRecommend = result.rows
      .filter(r => r.recommendation_type === 'recommend')
      .map(r => r.food_id);

    console.log('\n📤 API RESPONSE WOULD BE:');
    console.log(JSON.stringify({
      foods_to_avoid: foodsToAvoid,
      foods_to_recommend: foodsToRecommend
    }, null, 2));

    console.log('\n📱 FLUTTER APP SHOULD RECEIVE:');
    console.log(`   Foods to avoid: ${foodsToAvoid.length} items - [${foodsToAvoid.join(', ')}]`);
    console.log(`   Foods to recommend: ${foodsToRecommend.length} items - [${foodsToRecommend.join(', ')}]`);

  } catch (err) {
    console.error('❌ ERROR:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

testAPI();
