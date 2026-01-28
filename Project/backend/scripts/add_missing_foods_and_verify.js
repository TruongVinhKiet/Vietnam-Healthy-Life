const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

// ============================================================================
// MISSING FOODS TO ADD
// ============================================================================

const MISSING_FOODS = [
  // PROTEINS
  { name: 'Chicken breast', name_vi: 'Ức gà', category: 'protein', 
    nutrients: {1:165, 2:31, 3:3.6, 10:85, 23:0.4, 29:0.9, 30:1.5} },
  { name: 'Eggs', name_vi: 'Trứng gà', category: 'protein',
    nutrients: {1:155, 2:13, 3:11, 4:1.1, 10:373, 23:1.8, 24:56, 29:2.7} },
  
  // VEGETABLES
  { name: 'Tomatoes', name_vi: 'Cà chua', category: 'vegetables',
    nutrients: {1:18, 2:0.9, 3:0.2, 4:3.9, 5:1.2, 11:833, 15:13.7, 27:237} },
  
  // FRUITS
  { name: 'Avocado', name_vi: 'Bơ', category: 'fruits',
    nutrients: {1:160, 2:2, 3:14.7, 4:8.5, 5:6.7, 11:146, 15:10, 27:485} },
  { name: 'Strawberries', name_vi: 'Dâu tây', category: 'fruits',
    nutrients: {1:32, 2:0.7, 3:0.3, 4:7.7, 5:2, 11:12, 15:58.8, 27:153} },
  { name: 'Orange', name_vi: 'Cam', category: 'fruits',
    nutrients: {1:47, 2:0.9, 3:0.1, 4:11.8, 5:2.4, 15:53.2, 24:40, 27:181} },
  
  // GRAINS & DAIRY
  { name: 'Bread', name_vi: 'Bánh mì', category: 'grains',
    nutrients: {1:265, 2:9, 3:3.2, 4:49, 5:2.7, 26:43, 25:115} },
  { name: 'Greek yogurt', name_vi: 'Sữa chua Hy Lạp', category: 'dairy',
    nutrients: {1:59, 2:10, 3:0.4, 4:3.6, 24:110, 25:141} },
  
  // SEASONINGS
  { name: 'Sesame seeds', name_vi: 'Hạt mè', category: 'grains',
    nutrients: {1:573, 2:17.7, 3:49.7, 4:23.4, 5:11.8, 24:975, 29:14.6} },
];

async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'Health',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'Kiet2004',
  });

  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('🚀 Adding missing foods...\n');

    let foodCount = 0;
    let nutrientCount = 0;

    for (const food of MISSING_FOODS) {
      // Check if food already exists
      const existingFood = await client.query(
        'SELECT food_id FROM food WHERE name = $1 OR name_vi = $2',
        [food.name, food.name_vi]
      );

      let foodId;
      if (existingFood.rows.length > 0) {
        console.log(`⏭️  Food already exists: ${food.name_vi}`);
        foodId = existingFood.rows[0].food_id;
      } else {
        // Insert new food
        const result = await client.query(
          `INSERT INTO food (name, name_vi, category, created_at, updated_at)
           VALUES ($1, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
           RETURNING food_id`,
          [food.name, food.name_vi, food.category]
        );
        foodId = result.rows[0].food_id;
        foodCount++;
        console.log(`✅ Added: ${food.name_vi} (ID: ${foodId})`);
      }

      // Insert nutrients
      for (const [nutrientId, amount] of Object.entries(food.nutrients)) {
        await client.query(
          `INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g)
           VALUES ($1, $2, $3)
           ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = $3`,
          [foodId, parseInt(nutrientId), amount]
        );
        nutrientCount++;
      }
    }

    await client.query('COMMIT');
    console.log(`\n📊 Summary:`);
    console.log(`✅ Added ${foodCount} new foods`);
    console.log(`✅ Updated ${nutrientCount} nutrient entries`);

    // ========================================================================
    // VERIFICATION: Check all conditions and drugs have recommendations
    // ========================================================================
    
    console.log('\n\n' + '='.repeat(80));
    console.log('📋 VERIFICATION REPORT: Food/Dish Recommendations Coverage');
    console.log('='.repeat(80) + '\n');

    // 1. Check food recommendations by condition
    console.log('🏥 HEALTH CONDITIONS - Food Recommendations:');
    console.log('-'.repeat(80));
    
    const conditionFoodStats = await client.query(`
      SELECT 
        hc.condition_id,
        COALESCE(hc.condition_name, hc.name_vi, hc.name_en) as condition_name,
        COUNT(CASE WHEN cfr.recommendation_type = 'avoid' THEN 1 END) as avoid_count,
        COUNT(CASE WHEN cfr.recommendation_type = 'recommend' THEN 1 END) as recommend_count,
        COUNT(*) as total_recommendations
      FROM healthcondition hc
      LEFT JOIN conditionfoodrecommendation cfr ON hc.condition_id = cfr.condition_id
      GROUP BY hc.condition_id, hc.condition_name, hc.name_vi, hc.name_en
      ORDER BY hc.condition_id
    `);

    let conditionsWithNoRecs = 0;
    conditionFoodStats.rows.forEach(row => {
      const status = row.total_recommendations > 0 ? '✅' : '❌';
      const conditionName = (row.condition_name || 'Unknown').padEnd(40);
      console.log(`${status} ${conditionName} | Avoid: ${String(row.avoid_count).padStart(3)} | Recommend: ${String(row.recommend_count).padStart(3)} | Total: ${row.total_recommendations}`);
      if (row.total_recommendations === 0) conditionsWithNoRecs++;
    });

    console.log(`\nSummary: ${conditionFoodStats.rows.length} conditions, ${conditionsWithNoRecs} without recommendations\n`);

    // 2. Check drug-nutrient contraindications
    console.log('💊 DRUGS - Nutrient Contraindications:');
    console.log('-'.repeat(80));
    
    const drugStats = await client.query(`
      SELECT 
        d.drug_id,
        COALESCE(d.name_vi, d.name_en, d.generic_name) as drug_name,
        COUNT(dnc.contra_id) as contraindication_count
      FROM drug d
      LEFT JOIN drugnutrientcontraindication dnc ON d.drug_id = dnc.drug_id
      GROUP BY d.drug_id, d.name_vi, d.name_en, d.generic_name
      ORDER BY contraindication_count DESC, drug_name
      LIMIT 50
    `);

    let drugsWithNoContras = 0;
    drugStats.rows.forEach(row => {
      const status = row.contraindication_count > 0 ? '✅' : '⚠️';
      const drugName = (row.drug_name || 'Unknown').padEnd(50);
      console.log(`${status} ${drugName} | Contraindications: ${row.contraindication_count}`);
      if (row.contraindication_count === 0) drugsWithNoContras++;
    });

    const totalDrugs = await client.query('SELECT COUNT(*) FROM drug');
    console.log(`\nShowing top 50 drugs. Total drugs: ${totalDrugs.rows[0].count}, ${drugsWithNoContras} shown without contraindications\n`);

    // 3. Check total foods and dishes
    console.log('📦 DATABASE STATISTICS:');
    console.log('-'.repeat(80));
    
    const foodCount2 = await client.query('SELECT COUNT(*) FROM food');
    const dishCount = await client.query('SELECT COUNT(*) FROM dish');
    const ingredientCount = await client.query('SELECT COUNT(*) FROM dishingredient');
    const conditionCount = await client.query('SELECT COUNT(*) FROM healthcondition');
    const drugCount = await client.query('SELECT COUNT(*) FROM drug');
    
    console.log(`🥗 Total Foods: ${foodCount2.rows[0].count}`);
    console.log(`🍲 Total Dishes: ${dishCount.rows[0].count}`);
    console.log(`📝 Total Dish Ingredients: ${ingredientCount.rows[0].count}`);
    console.log(`🏥 Total Health Conditions: ${conditionCount.rows[0].count}`);
    console.log(`💊 Total Drugs: ${drugCount.rows[0].count}`);

    // 4. Sample recommendations by category
    console.log('\n📋 SAMPLE RECOMMENDATIONS BY CONDITION:');
    console.log('-'.repeat(80));
    
    const sampleRecs = await client.query(`
      SELECT 
        COALESCE(hc.condition_name, hc.name_vi, hc.name_en) as condition_name,
        cfr.recommendation_type,
        f.name_vi as food_name,
        f.category
      FROM conditionfoodrecommendation cfr
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      JOIN food f ON cfr.food_id = f.food_id
      WHERE hc.condition_id IN (1, 2, 3, 4, 5)
      ORDER BY hc.condition_id, cfr.recommendation_type, f.name_vi
      LIMIT 30
    `);

    let currentCondition = '';
    sampleRecs.rows.forEach(row => {
      if (row.condition_name !== currentCondition) {
        console.log(`\n🏥 ${row.condition_name}:`);
        currentCondition = row.condition_name;
      }
      const icon = row.recommendation_type === 'avoid' ? '🚫' : '✅';
      console.log(`  ${icon} ${row.recommendation_type.toUpperCase().padEnd(9)} - ${row.food_name} (${row.category})`);
    });

    console.log('\n' + '='.repeat(80));
    console.log('✅ Verification complete!');
    console.log('='.repeat(80));

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
