const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function seedEverything() {
  const client = await pool.connect();
  
  try {
    console.log('🌱 Starting comprehensive seeding...\n');
    
    const migrations = [
      '2025_seed_app_nutrients.sql',
      '2025_seed_core_vitamins_minerals.sql',
      '2025_seed_vitamins.sql',
      '2025_seed_minerals.sql',
      '2025_fix_missing_schema_elements.sql',
      '2025_seed_advanced_features.sql'
    ];
    
    for (const migrationFile of migrations) {
      const sqlPath = path.join(__dirname, 'migrations', migrationFile);
      
      if (!fs.existsSync(sqlPath)) {
        console.log(`⏭️  Skipping ${migrationFile} (not found)\n`);
        continue;
      }
      
      console.log(`📝 Running ${migrationFile}...`);
      
      try {
        const sql = fs.readFileSync(sqlPath, 'utf8');
        await client.query(sql);
        console.log(`✅ Completed ${migrationFile}\n`);
      } catch (error) {
        console.error(`❌ Error in ${migrationFile}:`, error.message);
        if (error.message.includes('already exists') || error.message.includes('duplicate')) {
          console.log(`⚠️  Continuing despite duplicate error...\n`);
        } else {
          throw error;
        }
      }
    }
    
    console.log('\n✅ All seeds completed!\n');
    
    // Final verification
    console.log('📊 Final counts:\n');
    
    const tables = [
      'Nutrient',
      'Vitamin',
      'Mineral',
      'VitaminNutrient',
      'MineralNutrient',
      'HealthCondition',
      'ConditionNutrientEffect',
      'ConditionFoodRecommendation',
      'Fiber',
      'FiberRequirement',
      'FoodCategory',
      'PortionSize'
    ];
    
    for (const table of tables) {
      const result = await client.query(`SELECT COUNT(*) as count FROM ${table}`);
      console.log(`  ${table}: ${result.rows[0].count}`);
    }
    
  } catch (error) {
    console.error('\n❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

seedEverything();
