const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function analyzeData() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    console.log('📊 PHÂN TÍCH DỮ LIỆU HIỆN CÓ\n');
    console.log('='.repeat(80));

    // 1. Health Conditions
    const conditions = await client.query(`
      SELECT condition_id, name_vi, name_en, category
      FROM healthcondition
      ORDER BY condition_id
    `);
    console.log(`\n🏥 HEALTH CONDITIONS: ${conditions.rows.length} bệnh`);
    
    // 2. Conditions with food recommendations
    const conditionsWithFoods = await client.query(`
      SELECT DISTINCT hc.condition_id, hc.name_vi, 
        COUNT(DISTINCT CASE WHEN cfr.recommendation_type = 'avoid' THEN cfr.food_id END) as avoid_count,
        COUNT(DISTINCT CASE WHEN cfr.recommendation_type = 'recommend' THEN cfr.food_id END) as recommend_count
      FROM healthcondition hc
      LEFT JOIN conditionfoodrecommendation cfr ON hc.condition_id = cfr.condition_id
      GROUP BY hc.condition_id, hc.name_vi
      ORDER BY hc.condition_id
    `);
    
    console.log('\n📋 Conditions có food recommendations:');
    const withRecommendations = conditionsWithFoods.rows.filter(c => parseInt(c.avoid_count) > 0 || parseInt(c.recommend_count) > 0);
    const withoutRecommendations = conditionsWithFoods.rows.filter(c => parseInt(c.avoid_count) == 0 && parseInt(c.recommend_count) == 0);
    
    console.log(`\n✅ Có recommendations (${withRecommendations.length}):`);
    withRecommendations.forEach(c => {
      console.log(`   [${c.condition_id}] ${c.name_vi}: ${c.avoid_count} avoid, ${c.recommend_count} recommend`);
    });
    
    console.log(`\n❌ CHƯA có recommendations (${withoutRecommendations.length}):`);
    withoutRecommendations.slice(0, 20).forEach(c => {
      console.log(`   [${c.condition_id}] ${c.name_vi}`);
    });
    if (withoutRecommendations.length > 20) {
      console.log(`   ... và ${withoutRecommendations.length - 20} bệnh khác`);
    }

    // 3. Dishes
    const dishes = await client.query(`
      SELECT COUNT(*) as total,
        COUNT(CASE WHEN created_by_admin IS NOT NULL THEN 1 END) as admin_dishes,
        COUNT(CASE WHEN created_by_user IS NOT NULL THEN 1 END) as user_dishes
      FROM dish
    `);
    console.log(`\n🍽️  DISHES: ${dishes.rows[0].total} món (${dishes.rows[0].admin_dishes} admin, ${dishes.rows[0].user_dishes} user)`);

    // 4. Foods
    const foods = await client.query(`
      SELECT COUNT(*) as total,
        COUNT(DISTINCT category) as categories
      FROM food
    `);
    console.log(`\n🥗 FOODS: ${foods.rows[0].total} loại, ${foods.rows[0].categories} categories`);

    // 5. Drugs
    const drugs = await client.query(`
      SELECT COUNT(*) as total
      FROM drug
    `);
    console.log(`\n💊 DRUGS: ${drugs.rows[0].total} loại thuốc`);

    // 6. Drug-Health Condition relationships
    const drugConditions = await client.query(`
      SELECT COUNT(DISTINCT drug_id) as drugs_with_conditions,
        COUNT(DISTINCT condition_id) as conditions_with_drugs
      FROM drughealthcondition
    `);
    console.log(`\n🔗 Drug-Condition: ${drugConditions.rows[0].drugs_with_conditions} thuốc có liên kết với ${drugConditions.rows[0].conditions_with_drugs} bệnh`);

    // 7. Nutrients
    const nutrients = await client.query(`
      SELECT COUNT(*) as total
      FROM nutrient
    `);
    console.log(`\n⚗️  NUTRIENTS: ${nutrients.rows[0].total} chất dinh dưỡng`);

    // 8. FoodNutrient data
    const foodNutrients = await client.query(`
      SELECT 
        COUNT(DISTINCT food_id) as foods_with_nutrients,
        COUNT(*) as total_mappings,
        AVG(cnt) as avg_nutrients_per_food
      FROM (
        SELECT food_id, COUNT(*) as cnt
        FROM foodnutrient
        GROUP BY food_id
      ) sub
    `);
    console.log(`\n📊 FoodNutrient: ${foodNutrients.rows[0].foods_with_nutrients} foods có nutrients (avg ${Math.round(foodNutrients.rows[0].avg_nutrients_per_food)} nutrients/food)`);

    // 9. Vietnamese dishes analysis
    const vietnameseDishes = await client.query(`
      SELECT category, COUNT(*) as count
      FROM dish
      WHERE vietnamese_name IS NOT NULL
      GROUP BY category
      ORDER BY count DESC
    `);
    console.log(`\n🇻🇳 Vietnamese dishes by category:`);
    vietnameseDishes.rows.forEach(c => {
      console.log(`   ${c.category || 'NULL'}: ${c.count}`);
    });

    // 10. Sample popular Vietnamese foods
    console.log(`\n🥘 Sample Vietnamese foods có sẵn:`);
    const vnFoods = await client.query(`
      SELECT food_id, name, name_vi, category
      FROM food
      WHERE name_vi IS NOT NULL OR name LIKE '%viet%' OR name LIKE '%pho%' OR name LIKE '%banh%'
      LIMIT 15
    `);
    vnFoods.rows.forEach(f => {
      console.log(`   [${f.food_id}] ${f.name_vi || f.name} (${f.category})`);
    });

    console.log('\n' + '='.repeat(80));
    console.log('\n📝 KẾT LUẬN:');
    console.log(`   - Cần tạo food recommendations cho ${withoutRecommendations.length} bệnh`);
    console.log(`   - Cần tạo dishes Việt Nam cho các bệnh phổ biến`);
    console.log(`   - Cần liên kết dishes với foods thông qua dishingredient`);
    console.log(`   - Cần tính toán dishnutrient dựa trên foodnutrient có sẵn`);

  } catch (err) {
    console.error('❌ ERROR:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

analyzeData();
