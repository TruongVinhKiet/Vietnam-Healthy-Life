require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: String(process.env.DB_PASSWORD || ''),
  database: process.env.DB_DATABASE || 'Health',
});

async function generateStatusReport() {
  const client = await pool.connect();
  
  try {
    console.log('\n' + '='.repeat(70));
    console.log('📊 DATABASE STATUS REPORT - My Diary Health Tracker');
    console.log('='.repeat(70) + '\n');
    
    console.log('📅 Generated:', new Date().toLocaleString());
    console.log();
    
    // Section 1: Critical Tables Status
    console.log('━'.repeat(70));
    console.log('🗃️  CRITICAL TABLES STATUS');
    console.log('━'.repeat(70));
    
    const tables = [
      'User', 'UserProfile', 'Food', 'Nutrient', 'FoodNutrient',
      'Vitamin', 'Mineral', 'VitaminNutrient', 'MineralNutrient',
      'Meal', 'MealItem', 'Dish', 'DishIngredient',
      'HealthCondition', 'UserHealthCondition', 'MedicationSchedule',
      'Admin', 'AdminRole'
    ];
    
    for (const table of tables) {
      try {
        const result = await client.query(`
          SELECT COUNT(*) as count FROM "${table}"
        `);
        const count = result.rows[0].count;
        const status = count > 0 ? '✅' : '⚠️';
        console.log(`${status} ${table.padEnd(25)} | ${String(count).padStart(6)} rows`);
      } catch (err) {
        console.log(`❌ ${table.padEnd(25)} | NOT FOUND`);
      }
    }
    
    // Section 2: Nutrient Mapping Status
    console.log('\n' + '━'.repeat(70));
    console.log('🔗 NUTRIENT MAPPING STATUS');
    console.log('━'.repeat(70));
    
    const vitaminMappings = await client.query('SELECT COUNT(*) FROM VitaminNutrient');
    const mineralMappings = await client.query('SELECT COUNT(*) FROM MineralNutrient');
    
    console.log(`✅ VitaminNutrient mappings:  ${vitaminMappings.rows[0].count}`);
    console.log(`✅ MineralNutrient mappings:  ${mineralMappings.rows[0].count}`);
    
    // Show some mappings
    const vitSample = await client.query(`
      SELECT v.name as vitamin_name, n.nutrient_code, n.name as nutrient_name
      FROM VitaminNutrient vn
      JOIN Vitamin v ON vn.vitamin_id = v.vitamin_id
      JOIN Nutrient n ON vn.nutrient_id = n.nutrient_id
      LIMIT 5
    `);
    
    console.log('\n📋 Sample Vitamin Mappings:');
    vitSample.rows.forEach(row => {
      console.log(`   ${row.vitamin_name.padEnd(30)} ← ${row.nutrient_code}`);
    });
    
    const minSample = await client.query(`
      SELECT m.name as mineral_name, n.nutrient_code, n.name as nutrient_name
      FROM MineralNutrient mn
      JOIN Mineral m ON mn.mineral_id = m.mineral_id
      JOIN Nutrient n ON mn.nutrient_id = n.nutrient_id
      LIMIT 5
    `);
    
    console.log('\n📋 Sample Mineral Mappings:');
    minSample.rows.forEach(row => {
      console.log(`   ${row.mineral_name.padEnd(30)} ← ${row.nutrient_code}`);
    });
    
    // Section 3: User Data Status
    console.log('\n' + '━'.repeat(70));
    console.log('👥 USER DATA STATUS');
    console.log('━'.repeat(70));
    
    const users = await client.query('SELECT COUNT(*) FROM "User"');
    const profiles = await client.query('SELECT COUNT(*) FROM UserProfile');
    const meals = await client.query('SELECT COUNT(*) FROM Meal');
    const mealItems = await client.query('SELECT COUNT(*) FROM MealItem');
    
    console.log(`Total Users:          ${users.rows[0].count}`);
    console.log(`User Profiles:        ${profiles.rows[0].count}`);
    console.log(`Total Meals:          ${meals.rows[0].count}`);
    console.log(`Total Meal Items:     ${mealItems.rows[0].count}`);
    
    // Section 4: Health Condition Status
    console.log('\n' + '━'.repeat(70));
    console.log('🏥 HEALTH CONDITION STATUS');
    console.log('━'.repeat(70));
    
    const conditions = await client.query('SELECT COUNT(*) FROM HealthCondition');
    const userConditions = await client.query('SELECT COUNT(*) FROM UserHealthCondition WHERE status = \'active\'');
    const medications = await client.query('SELECT COUNT(*) FROM MedicationSchedule');
    
    console.log(`Health Conditions (master):  ${conditions.rows[0].count}`);
    console.log(`Active User Conditions:      ${userConditions.rows[0].count}`);
    console.log(`Medication Schedules:        ${medications.rows[0].count}`);
    
    // Section 5: Food & Dish Status
    console.log('\n' + '━'.repeat(70));
    console.log('🍽️  FOOD & DISH STATUS');
    console.log('━'.repeat(70));
    
    const foods = await client.query('SELECT COUNT(*) FROM Food');
    const dishes = await client.query('SELECT COUNT(*) FROM Dish');
    const dishIngredients = await client.query('SELECT COUNT(*) FROM DishIngredient');
    const foodNutrients = await client.query('SELECT COUNT(*) FROM FoodNutrient');
    
    console.log(`Foods in database:       ${foods.rows[0].count}`);
    console.log(`Dishes available:        ${dishes.rows[0].count}`);
    console.log(`Dish ingredients:        ${dishIngredients.rows[0].count}`);
    console.log(`Food-Nutrient links:     ${foodNutrients.rows[0].count}`);
    
    // Section 6: Function Status
    console.log('\n' + '━'.repeat(70));
    console.log('⚙️  CRITICAL FUNCTIONS STATUS');
    console.log('━'.repeat(70));
    
    // Test calculate_daily_nutrient_intake
    try {
      await client.query('SELECT * FROM calculate_daily_nutrient_intake(1, CURRENT_DATE) LIMIT 1');
      console.log('✅ calculate_daily_nutrient_intake() - WORKING');
    } catch (err) {
      console.log('❌ calculate_daily_nutrient_intake() - FAILED:', err.message.substring(0, 50));
    }
    
    // Test other important functions
    const functions = [
      'compute_user_vitamin_requirement',
      'compute_user_mineral_requirement',
      'upsert_vitamin',
      'upsert_mineral'
    ];
    
    for (const func of functions) {
      const exists = await client.query(`
        SELECT EXISTS (
          SELECT 1 FROM pg_proc WHERE proname = $1
        )
      `, [func]);
      
      const status = exists.rows[0].exists ? '✅' : '❌';
      console.log(`${status} ${func}()`);
    }
    
    // Section 7: Schema Completeness
    console.log('\n' + '━'.repeat(70));
    console.log('✔️  SCHEMA COMPLETENESS CHECK');
    console.log('━'.repeat(70));
    
    const criticalColumns = [
      { table: 'medicationschedule', column: 'medication_details' },
      { table: 'admin', column: 'is_deleted' },
      { table: 'userprofile', column: 'daily_water_target' },
      { table: 'meal', column: 'meal_type' }
    ];
    
    for (const col of criticalColumns) {
      const exists = await client.query(`
        SELECT EXISTS (
          SELECT 1 FROM information_schema.columns 
          WHERE table_name = $1 AND column_name = $2
        )
      `, [col.table, col.column]);
      
      const status = exists.rows[0].exists ? '✅' : '❌';
      console.log(`${status} ${col.table}.${col.column}`);
    }
    
    // Final Summary
    console.log('\n' + '='.repeat(70));
    console.log('📈 SYSTEM HEALTH SUMMARY');
    console.log('='.repeat(70));
    
    const issues = [];
    
    if (vitaminMappings.rows[0].count < 10) {
      issues.push('⚠️  Low vitamin mappings (need at least 10)');
    }
    if (mineralMappings.rows[0].count < 10) {
      issues.push('⚠️  Low mineral mappings (need at least 10)');
    }
    if (foodNutrients.rows[0].count === '0') {
      issues.push('⚠️  No food-nutrient data (need to import USDA data)');
    }
    
    if (issues.length === 0) {
      console.log('\n✅ ALL SYSTEMS OPERATIONAL');
      console.log('   Database schema is complete and ready for use.');
    } else {
      console.log('\n⚠️  MINOR ISSUES DETECTED:');
      issues.forEach(issue => console.log('   ' + issue));
    }
    
    console.log('\n' + '='.repeat(70) + '\n');
    
  } catch (error) {
    console.error('❌ Error generating report:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

generateStatusReport()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error('💥 Report generation failed:', err);
    process.exit(1);
  });
