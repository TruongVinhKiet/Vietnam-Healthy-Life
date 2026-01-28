const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function verifyData() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    console.log('✅ KIỂM TRA KẾT QUẢ SAU KHI IMPORT\n');
    console.log('='.repeat(80));

    // 1. Food recommendations coverage
    console.log('\n📋 FOOD RECOMMENDATIONS:');
    const recommendations = await client.query(`
      SELECT 
        COUNT(DISTINCT condition_id) as conditions_with_recs,
        COUNT(DISTINCT CASE WHEN recommendation_type = 'avoid' THEN condition_id END) as with_avoid,
        COUNT(DISTINCT CASE WHEN recommendation_type = 'recommend' THEN condition_id END) as with_recommend,
        COUNT(*) as total_recommendations
      FROM conditionfoodrecommendation
    `);
    const rec = recommendations.rows[0];
    console.log(`   Conditions có recommendations: ${rec.conditions_with_recs}`);
    console.log(`   Conditions có avoid foods: ${rec.with_avoid}`);
    console.log(`   Conditions có recommend foods: ${rec.with_recommend}`);
    console.log(`   Tổng recommendations: ${rec.total_recommendations}`);

    // 2. Dishes count
    console.log('\n🍽️  DISHES:');
    const dishes = await client.query(`
      SELECT 
        COUNT(*) as total,
        COUNT(CASE WHEN dish_id >= 1000 THEN 1 END) as new_dishes
      FROM dish
    `);
    console.log(`   Tổng dishes: ${dishes.rows[0].total}`);
    console.log(`   Dishes mới thêm: ${dishes.rows[0].new_dishes}`);

    // 3. Sample dishes by category
    console.log('\n📊 DISHES MỚI THEO CATEGORY:');
    const byCategory = await client.query(`
      SELECT category, COUNT(*) as count
      FROM dish
      WHERE dish_id >= 1000
      GROUP BY category
      ORDER BY count DESC
    `);
    byCategory.rows.forEach(c => {
      console.log(`   ${c.category}: ${c.count} món`);
    });

    // 4. Dish ingredients
    console.log('\n🥘 DISH INGREDIENTS:');
    const ingredients = await client.query(`
      SELECT 
        COUNT(DISTINCT dish_id) as dishes_with_ingredients,
        COUNT(*) as total_ingredients,
        ROUND(AVG(cnt), 1) as avg_per_dish
      FROM (
        SELECT dish_id, COUNT(*) as cnt
        FROM dishingredient
        WHERE dish_id >= 1000
        GROUP BY dish_id
      ) sub
    `);
    const ing = ingredients.rows[0];
    console.log(`   Dishes có ingredients: ${ing.dishes_with_ingredients}`);
    console.log(`   Tổng ingredients: ${ing.total_ingredients}`);
    console.log(`   Trung bình ingredients/dish: ${ing.avg_per_dish}`);

    // 5. Sample recommendations for specific conditions
    console.log('\n🏥 SAMPLE RECOMMENDATIONS CHO MỘT SỐ BỆNH:');
    
    const sampleConditions = [6, 7, 8, 15, 17, 22];
    for (const condId of sampleConditions) {
      const cond = await client.query(`
        SELECT name_vi FROM healthcondition WHERE condition_id = $1
      `, [condId]);
      
      if (cond.rows.length > 0) {
        const condName = cond.rows[0].name_vi;
        
        const recs = await client.query(`
          SELECT 
            COUNT(CASE WHEN recommendation_type = 'avoid' THEN 1 END) as avoid_count,
            COUNT(CASE WHEN recommendation_type = 'recommend' THEN 1 END) as recommend_count
          FROM conditionfoodrecommendation
          WHERE condition_id = $1
        `, [condId]);
        
        const r = recs.rows[0];
        console.log(`   [${condId}] ${condName}: ${r.avoid_count} avoid, ${r.recommend_count} recommend`);
      }
    }

    // 6. Dishes for specific conditions (through food recommendations)
    console.log('\n🍲 DISHES PHÙ HỢP CHO TỪNG BỆNH:');
    console.log('   (Dishes không chứa foods bị avoid)\n');

    for (const condId of [1, 5, 6, 7, 8]) {
      const cond = await client.query(`
        SELECT name_vi FROM healthcondition WHERE condition_id = $1
      `, [condId]);
      
      if (cond.rows.length === 0) continue;
      const condName = cond.rows[0].name_vi;

      // Get avoid food IDs for this condition
      const avoidFoods = await client.query(`
        SELECT food_id FROM conditionfoodrecommendation
        WHERE condition_id = $1 AND recommendation_type = 'avoid'
      `, [condId]);
      
      const avoidIds = avoidFoods.rows.map(r => r.food_id);

      // Get dishes that don't contain any avoid foods
      let safeDishes;
      if (avoidIds.length > 0) {
        safeDishes = await client.query(`
          SELECT DISTINCT d.dish_id, d.vietnamese_name, d.category
          FROM dish d
          WHERE d.dish_id >= 1000
            AND NOT EXISTS (
              SELECT 1 FROM dishingredient di
              WHERE di.dish_id = d.dish_id
                AND di.food_id = ANY($1::int[])
            )
          LIMIT 5
        `, [avoidIds]);
      } else {
        safeDishes = await client.query(`
          SELECT dish_id, vietnamese_name, category
          FROM dish
          WHERE dish_id >= 1000
          LIMIT 5
        `);
      }

      console.log(`   [${condId}] ${condName}: ${safeDishes.rows.length} món an toàn`);
      safeDishes.rows.forEach(d => {
        console.log(`      → [${d.dish_id}] ${d.vietnamese_name} (${d.category})`);
      });
      console.log();
    }

    // 7. Dishes with nutrients
    console.log('\n⚗️  DISH NUTRIENTS:');
    const dishNutrients = await client.query(`
      SELECT 
        COUNT(DISTINCT dish_id) as dishes_with_nutrients,
        COUNT(*) as total_nutrient_entries
      FROM dishnutrient
      WHERE dish_id >= 1000
    `);
    const dn = dishNutrients.rows[0];
    console.log(`   Dishes có nutrient data: ${dn.dishes_with_nutrients}`);
    console.log(`   Tổng nutrient entries: ${dn.total_nutrient_entries}`);

    console.log('\n' + '='.repeat(80));
    console.log('\n🎉 KIỂM TRA HOÀN TẤT!');
    console.log('\n📝 SUMMARY:');
    console.log(`   ✅ ${rec.conditions_with_recs} bệnh có food recommendations`);
    console.log(`   ✅ ${dishes.rows[0].new_dishes} món ăn Việt Nam mới`);
    console.log(`   ✅ ${ing.total_ingredients} liên kết dish-food`);
    console.log(`   ✅ Đã tính nutrient cho dishes`);
    console.log('\n🚀 Dữ liệu đã sẵn sàng để test trong app!');

  } catch (err) {
    console.error('\n❌ ERROR:', err.message);
    console.error(err.stack);
  } finally {
    client.release();
    await pool.end();
  }
}

verifyData();
