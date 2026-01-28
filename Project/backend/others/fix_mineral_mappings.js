require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: String(process.env.DB_PASSWORD || ''),
  database: process.env.DB_DATABASE || 'Health',
});

async function cleanAndFixMappings() {
  const client = await pool.connect();
  
  try {
    console.log('🧹 Cleaning up incorrect nutrient mappings...\n');
    
    // Delete all current mappings to start fresh
    await client.query('DELETE FROM MineralNutrient');
    console.log('✓ Cleared all mineral mappings');
    
    // Get exact mappings
    console.log('\n📋 Creating precise mineral mappings...\n');
    
    const mineralMappings = [
      { mineralCode: 'MIN_CA', nutrientCode: 'CA' },
      { mineralCode: 'MIN_P', nutrientCode: 'P' },
      { mineralCode: 'MIN_MG', nutrientCode: 'MG' },
      { mineralCode: 'MIN_K', nutrientCode: 'K' },
      { mineralCode: 'MIN_NA', nutrientCode: 'NA' },
      { mineralCode: 'MIN_FE', nutrientCode: 'FE' },
      { mineralCode: 'MIN_ZN', nutrientCode: 'ZN' },
      { mineralCode: 'MIN_CU', nutrientCode: 'CU' },
      { mineralCode: 'MIN_MN', nutrientCode: 'MN' },
      { mineralCode: 'MIN_SE', nutrientCode: 'SE' },
      { mineralCode: 'MIN_I', nutrientCode: 'I' },
      { mineralCode: 'MIN_CR', nutrientCode: 'CR' },
      { mineralCode: 'MIN_MO', nutrientCode: 'MO' },
      { mineralCode: 'MIN_F', nutrientCode: 'F' }
    ];
    
    let mappedCount = 0;
    
    for (const mapping of mineralMappings) {
      const result = await client.query(`
        INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
        SELECT 
          m.mineral_id,
          n.nutrient_id,
          1.0,
          'Direct mapping: ' || n.nutrient_code || ' -> ' || m.code
        FROM Mineral m
        CROSS JOIN Nutrient n
        WHERE m.code = $1 AND n.nutrient_code = $2
        ON CONFLICT (mineral_id, nutrient_id) DO NOTHING
        RETURNING mineral_nutrient_id
      `, [mapping.mineralCode, mapping.nutrientCode]);
      
      if (result.rows.length > 0) {
        console.log(`✓ Mapped ${mapping.nutrientCode} -> ${mapping.mineralCode}`);
        mappedCount++;
      } else {
        console.log(`⚠ Could not map ${mapping.nutrientCode} -> ${mapping.mineralCode} (not found)`);
      }
    }
    
    console.log(`\n✅ Created ${mappedCount} mineral mappings`);
    
    // Verify counts
    const vitCount = await client.query('SELECT COUNT(*) FROM VitaminNutrient');
    const minCount = await client.query('SELECT COUNT(*) FROM MineralNutrient');
    
    console.log(`\n📊 Final mapping counts:`);
    console.log(`   VitaminNutrient: ${vitCount.rows[0].count}`);
    console.log(`   MineralNutrient: ${minCount.rows[0].count}`);
    
    // Test the function again
    console.log('\n🧪 Testing calculate_daily_nutrient_intake function...');
    try {
      const funcTest = await client.query(`
        SELECT nutrient_type, nutrient_name, total_amount, unit, target_amount, percent_of_target
        FROM calculate_daily_nutrient_intake(1, CURRENT_DATE)
        ORDER BY nutrient_type, nutrient_name
        LIMIT 15
      `);
      
      console.log(`✓ Function works! Returned ${funcTest.rows.length} records`);
      console.log('\nSample results:');
      funcTest.rows.forEach(row => {
        const pct = row.percent_of_target || 0;
        console.log(`  ${row.nutrient_type.padEnd(8)} | ${row.nutrient_name.padEnd(35)} | ${String(row.total_amount).padStart(8)} ${row.unit.padEnd(4)} | Target: ${row.target_amount} ${row.unit} (${pct}%)`);
      });
    } catch (err) {
      console.log(`✗ Function still has errors: ${err.message}`);
    }
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

cleanAndFixMappings()
  .then(() => {
    console.log('\n🎉 Mapping cleanup and fix complete!');
    process.exit(0);
  })
  .catch((err) => {
    console.error('\n💥 Failed:', err);
    process.exit(1);
  });
