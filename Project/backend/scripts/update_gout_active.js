const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function updateGout() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    console.log('🔄 Updating Gout treatment end date to make it active...\n');
    
    // Update Gout end date to 7 days from now
    const result = await client.query(`
      UPDATE userhealthcondition
      SET treatment_end_date = CURRENT_DATE + INTERVAL '7 days'
      WHERE user_id = 1 
        AND condition_id = 5
      RETURNING 
        user_condition_id,
        condition_id,
        treatment_start_date,
        treatment_end_date,
        status
    `);

    if (result.rows.length > 0) {
      console.log('✅ Updated Gout condition:');
      console.log(`   Start: ${result.rows[0].treatment_start_date}`);
      console.log(`   End: ${result.rows[0].treatment_end_date}`);
      console.log(`   Status: ${result.rows[0].status}`);
      console.log('\n✅ Gout is now ACTIVE and will be included in API!');
    } else {
      console.log('❌ No Gout condition found for User ID 1');
    }

    // Verify active conditions
    console.log('\n📊 ALL ACTIVE CONDITIONS FOR USER 1:');
    const active = await client.query(`
      SELECT 
        hc.condition_id,
        hc.name_vi,
        uhc.treatment_end_date
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = 1
        AND uhc.status = 'active'
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= CURRENT_DATE)
    `);

    active.rows.forEach(c => {
      console.log(`   ✓ [${c.condition_id}] ${c.name_vi} (end: ${c.treatment_end_date})`);
    });

    // Now test the full recommendations
    console.log('\n🔍 TESTING FULL RECOMMENDATIONS:');
    const conditionIds = active.rows.map(r => r.condition_id);
    
    const avoid = await client.query(`
      SELECT DISTINCT f.food_id, f.name_vi, hc.name_vi as condition
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[])
        AND cfr.recommendation_type = 'avoid'
      ORDER BY f.food_id
    `, [conditionIds]);

    const recommend = await client.query(`
      SELECT DISTINCT f.food_id, f.name_vi, hc.name_vi as condition
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[])
        AND cfr.recommendation_type = 'recommend'
      ORDER BY f.food_id
    `, [conditionIds]);

    console.log(`\n🚫 FOODS TO AVOID (${avoid.rows.length}):`);
    avoid.rows.forEach(r => console.log(`   [${r.food_id}] ${r.name_vi} - ${r.condition}`));

    console.log(`\n✅ FOODS TO RECOMMEND (${recommend.rows.length}):`);
    recommend.rows.forEach(r => console.log(`   [${r.food_id}] ${r.name_vi} - ${r.condition}`));

  } catch (err) {
    console.error('❌ ERROR:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

updateGout();
