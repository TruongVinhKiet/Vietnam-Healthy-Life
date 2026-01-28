const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function fixMappingsAndAddNutrients() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🔧 Fixing mappings and adding missing nutrients...\n');
    
    // 1. Add missing detailed nutrients
    console.log('📝 Adding detailed USDA nutrients...');
    
    const detailedNutrients = [
      ['VITA_RAE', 'Vitamin A, RAE', 'mcg', 'Vitamins'],
      ['THIA', 'Thiamin', 'mg', 'Vitamins'],
      ['RIBF', 'Riboflavin', 'mg', 'Vitamins'],
      ['NIA', 'Niacin', 'mg', 'Vitamins'],
      ['VITB6A', 'Vitamin B-6', 'mg', 'Vitamins'],
      ['VITD', 'Vitamin D (D2 + D3)', 'mcg', 'Vitamins'],
      ['TOCPHA', 'Vitamin E (alpha-tocopherol)', 'mg', 'Vitamins'],
      ['VITK1', 'Vitamin K (phylloquinone)', 'mcg', 'Vitamins'],
      ['CU', 'Copper', 'mg', 'Minerals'],
      ['MN', 'Manganese', 'mg', 'Minerals'],
      ['SE', 'Selenium', 'mcg', 'Minerals'],
      ['ID', 'Iodine', 'mcg', 'Minerals'],
      ['CR', 'Chromium', 'mcg', 'Minerals'],
      ['MO', 'Molybdenum', 'mcg', 'Minerals'],
      ['FLD', 'Fluoride', 'mg', 'Minerals']
    ];
    
    for (const [code, name, unit, category] of detailedNutrients) {
      await client.query(`
        INSERT INTO Nutrient (nutrient_code, name, unit, category)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (nutrient_code) DO NOTHING
      `, [code, name, unit, category]);
    }
    console.log(`✅ Added ${detailedNutrients.length} detailed nutrients\n`);
    
    // 2. Clear existing mappings
    console.log('📝 Clearing existing mappings...');
    await client.query('DELETE FROM VitaminNutrient');
    await client.query('DELETE FROM MineralNutrient');
    console.log('✅ Cleared old mappings\n');
    
    // 3. Create VitaminNutrient mappings with correct codes
    console.log('📝 Creating VitaminNutrient mappings...');
    const vitNutMappings = [
      ['VIT_A', 'VITA_RAE'],
      ['VIT_B1', 'THIA'],
      ['VIT_B2', 'RIBF'],
      ['VIT_B3', 'NIA'],
      ['VIT_B6', 'VITB6A'],
      ['VIT_B9', 'FOL'],
      ['VIT_B12', 'VITB12'],
      ['VIT_C', 'VITC'],
      ['VIT_D', 'VITD'],
      ['VIT_E', 'TOCPHA'],
      ['VIT_K', 'VITK1']
    ];
    
    let vitMapped = 0;
    for (const [vitCode, nutCode] of vitNutMappings) {
      const result = await client.query(`
        INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, amount)
        SELECT v.vitamin_id, n.nutrient_id, 1.0
        FROM Vitamin v, Nutrient n
        WHERE v.code = $1 AND n.nutrient_code = $2
        RETURNING *
      `, [vitCode, nutCode]);
      
      if (result.rows.length > 0) {
        vitMapped++;
      } else {
        console.log(`⚠️  Could not map ${vitCode} → ${nutCode}`);
      }
    }
    console.log(`✅ Created ${vitMapped} vitamin-nutrient mappings\n`);
    
    // 4. Create MineralNutrient mappings
    console.log('📝 Creating MineralNutrient mappings...');
    const minNutMappings = [
      ['MIN_CA', 'CA'],
      ['MIN_FE', 'FE'],
      ['MIN_MG', 'MG'],
      ['MIN_P', 'P'],
      ['MIN_K', 'K'],
      ['MIN_NA', 'NA'],
      ['MIN_ZN', 'ZN'],
      ['MIN_CU', 'CU'],
      ['MIN_MN', 'MN'],
      ['MIN_SE', 'SE'],
      ['MIN_I', 'ID'],
      ['MIN_CR', 'CR'],
      ['MIN_MO', 'MO'],
      ['MIN_F', 'FLD']
    ];
    
    let minMapped = 0;
    for (const [minCode, nutCode] of minNutMappings) {
      const result = await client.query(`
        INSERT INTO MineralNutrient (mineral_id, nutrient_id, amount)
        SELECT m.mineral_id, n.nutrient_id, 1.0
        FROM Mineral m, Nutrient n
        WHERE m.code = $1 AND n.nutrient_code = $2
        RETURNING *
      `, [minCode, nutCode]);
      
      if (result.rows.length > 0) {
        minMapped++;
      } else {
        console.log(`⚠️  Could not map ${minCode} → ${nutCode}`);
      }
    }
    console.log(`✅ Created ${minMapped} mineral-nutrient mappings\n`);
    
    await client.query('COMMIT');
    
    console.log('\n✅ All mappings fixed!\n');
    
    // Verify
    console.log('📊 Final counts:\n');
    const counts = [
      ['Nutrient', 'Nutrient'],
      ['VitaminNutrient', 'VitaminNutrient'],
      ['MineralNutrient', 'MineralNutrient']
    ];
    
    for (const [label, table] of counts) {
      const result = await client.query(`SELECT COUNT(*) as count FROM ${table}`);
      console.log(`  ${label}: ${result.rows[0].count}`);
    }
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('\n❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

fixMappingsAndAddNutrients();
