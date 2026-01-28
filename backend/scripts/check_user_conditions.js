const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function checkConditions() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    console.log('🔍 USER 1 HEALTH CONDITIONS:');
    console.log('='.repeat(80));
    
    const conditions = await client.query(`
      SELECT 
        uhc.user_condition_id,
        uhc.condition_id,
        hc.name_vi,
        uhc.status,
        uhc.treatment_start_date,
        uhc.treatment_end_date,
        CASE 
          WHEN uhc.treatment_end_date IS NULL THEN 'NO END DATE'
          WHEN uhc.treatment_end_date >= CURRENT_DATE THEN 'ACTIVE (future/today)'
          ELSE 'EXPIRED'
        END as date_status
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = 1
      ORDER BY uhc.treatment_end_date DESC NULLS FIRST
    `);

    console.log(`Total conditions: ${conditions.rows.length}\n`);
    
    conditions.rows.forEach(c => {
      const active = c.status === 'active' && 
                     (!c.treatment_end_date || new Date(c.treatment_end_date) >= new Date());
      const emoji = active ? '✅' : '❌';
      console.log(`${emoji} [${c.condition_id}] ${c.name_vi}`);
      console.log(`   Status: ${c.status}`);
      console.log(`   Start: ${c.treatment_start_date}`);
      console.log(`   End: ${c.treatment_end_date || 'NULL'}`);
      console.log(`   Date check: ${c.date_status}`);
      console.log(`   Will be included in API: ${active ? 'YES' : 'NO'}`);
      console.log();
    });

    console.log('\n📊 CONDITION CHECK FOR API QUERY:');
    console.log('Conditions that match API criteria:');
    console.log('  status = "active" AND (end_date IS NULL OR end_date >= CURRENT_DATE)');
    
    const activeConditions = conditions.rows.filter(c => 
      c.status === 'active' && 
      (!c.treatment_end_date || new Date(c.treatment_end_date) >= new Date())
    );
    
    console.log(`\nResult: ${activeConditions.length} active conditions\n`);
    activeConditions.forEach(c => {
      console.log(`  ✓ [${c.condition_id}] ${c.name_vi}`);
    });

  } catch (err) {
    console.error('❌ ERROR:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

checkConditions();
