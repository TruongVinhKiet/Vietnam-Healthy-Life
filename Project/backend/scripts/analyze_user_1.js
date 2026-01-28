const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function checkUserId1() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('PHÂN TÍCH CHI TIẾT USER ID 1');
    console.log('='.repeat(80));

    // 1. User Info
    const user = await client.query('SELECT * FROM "User" WHERE user_id = 1');
    console.log('\n👤 THÔNG TIN USER:');
    console.log(`   Email: ${user.rows[0].email}`);
    console.log(`   Tên: ${user.rows[0].full_name}`);
    console.log(`   User ID: ${user.rows[0].user_id}`);

    // 2. Health Conditions
    const conditions = await client.query(`
      SELECT 
        uhc.user_condition_id,
        hc.condition_id,
        hc.name_vi,
        hc.name_en,
        uhc.status,
        uhc.diagnosed_date,
        uhc.treatment_start_date,
        uhc.treatment_end_date
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = 1
      ORDER BY uhc.status DESC, uhc.treatment_start_date DESC
    `);

    console.log('\n🏥 TÌNH TRẠNG SỨC KHỎE:');
    conditions.rows.forEach(c => {
      const status = c.status === 'active' ? '✓ ĐANG ĐIỀU TRỊ' : '○ Đã hết';
      console.log(`   ${status} [${c.condition_id}] ${c.name_vi || c.name_en}`);
      console.log(`      Chẩn đoán: ${c.diagnosed_date?.toISOString().split('T')[0] || 'N/A'}`);
      console.log(`      Bắt đầu điều trị: ${c.treatment_start_date?.toISOString().split('T')[0] || 'N/A'}`);
      if (c.treatment_end_date) {
        console.log(`      Kết thúc điều trị: ${c.treatment_end_date.toISOString().split('T')[0]}`);
      }
    });

    const activeConditions = conditions.rows.filter(c => c.status === 'active');
    const conditionIds = activeConditions.map(c => c.condition_id);

    if (conditionIds.length === 0) {
      console.log('\n⚠️  User không có tình trạng sức khỏe active!');
      return;
    }

    // 3. Foods to AVOID
    const avoidFoods = await client.query(`
      SELECT 
        f.food_id,
        f.name,
        f.name_vi,
        f.category,
        hc.name_vi as condition_name,
        cfr.notes
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[])
        AND cfr.recommendation_type = 'avoid'
      ORDER BY hc.name_vi, f.name_vi, f.name
    `, [conditionIds]);

    console.log('\n🚫 THỰC PHẨM NÊN TRÁNH:');
    console.log(`   Tổng: ${avoidFoods.rows.length} loại\n`);
    
    const avoidByCondition = {};
    avoidFoods.rows.forEach(f => {
      if (!avoidByCondition[f.condition_name]) {
        avoidByCondition[f.condition_name] = [];
      }
      avoidByCondition[f.condition_name].push(f);
    });

    Object.keys(avoidByCondition).forEach(condition => {
      console.log(`   📋 ${condition}:`);
      avoidByCondition[condition].forEach(f => {
        console.log(`      🚫 [${f.food_id}] ${f.name_vi || f.name}`);
        console.log(`         Category: ${f.category || 'N/A'}`);
        if (f.notes) console.log(`         Lý do: ${f.notes}`);
      });
      console.log('');
    });

    // 4. Foods RECOMMENDED
    const recommendFoods = await client.query(`
      SELECT 
        f.food_id,
        f.name,
        f.name_vi,
        f.category,
        hc.name_vi as condition_name,
        cfr.notes
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[])
        AND cfr.recommendation_type = 'recommend'
      ORDER BY hc.name_vi, f.name_vi, f.name
    `, [conditionIds]);

    console.log('✅ THỰC PHẨM KHUYẾN NGHỊ:');
    console.log(`   Tổng: ${recommendFoods.rows.length} loại\n`);
    
    const recommendByCondition = {};
    recommendFoods.rows.forEach(f => {
      if (!recommendByCondition[f.condition_name]) {
        recommendByCondition[f.condition_name] = [];
      }
      recommendByCondition[f.condition_name].push(f);
    });

    Object.keys(recommendByCondition).forEach(condition => {
      console.log(`   📋 ${condition}:`);
      recommendByCondition[condition].forEach(f => {
        console.log(`      ✅ [${f.food_id}] ${f.name_vi || f.name}`);
        console.log(`         Category: ${f.category || 'N/A'}`);
        if (f.notes) console.log(`         Lợi ích: ${f.notes}`);
      });
      console.log('');
    });

    // 5. Check dishes containing these foods
    const restrictedFoodIds = avoidFoods.rows.map(f => f.food_id);
    const recommendedFoodIds = recommendFoods.rows.map(f => f.food_id);

    console.log('='.repeat(80));
    console.log('PHÂN TÍCH MÓN ĂN (DISHES)');
    console.log('='.repeat(80));

    // Dishes with restricted ingredients
    const restrictedDishes = await client.query(`
      SELECT DISTINCT
        d.dish_id,
        d.name,
        d.vietnamese_name,
        d.category
      FROM dish d
      JOIN dishingredient di ON d.dish_id = di.dish_id
      WHERE di.food_id = ANY($1::int[])
        AND (d.is_public = true OR d.created_by_admin IS NOT NULL)
      ORDER BY d.dish_id
    `, [restrictedFoodIds]);

    console.log(`\n🚫 MÓN ĂN CHỨA NGUYÊN LIỆU BỊ HẠN CHẾ:`);
    console.log(`   Tổng: ${restrictedDishes.rows.length} món\n`);

    for (const dish of restrictedDishes.rows) {
      console.log(`   🚫 [${dish.dish_id}] ${dish.vietnamese_name || dish.name}`);
      console.log(`      Category: ${dish.category || 'N/A'}`);
      
      // Get ingredients
      const ingredients = await client.query(`
        SELECT 
          f.food_id,
          f.name,
          f.name_vi,
          di.weight_g
        FROM dishingredient di
        JOIN food f ON di.food_id = f.food_id
        WHERE di.dish_id = $1
        ORDER BY di.display_order
      `, [dish.dish_id]);

      console.log(`      Nguyên liệu:`);
      ingredients.rows.forEach(ing => {
        const isRestricted = restrictedFoodIds.includes(ing.food_id);
        const marker = isRestricted ? '      ⛔' : '      -';
        console.log(`${marker} ${ing.name_vi || ing.name} (${ing.weight_g}g)${isRestricted ? ' ⚠️ BỊ HẠN CHẾ' : ''}`);
      });
      console.log('');
    }

    // Dishes with recommended ingredients
    const recommendedDishes = await client.query(`
      SELECT DISTINCT
        d.dish_id,
        d.name,
        d.vietnamese_name,
        d.category
      FROM dish d
      JOIN dishingredient di ON d.dish_id = di.dish_id
      WHERE di.food_id = ANY($1::int[])
        AND (d.is_public = true OR d.created_by_admin IS NOT NULL)
        AND NOT EXISTS (
          SELECT 1 FROM dishingredient di2
          WHERE di2.dish_id = d.dish_id
            AND di2.food_id = ANY($2::int[])
        )
      ORDER BY d.dish_id
    `, [recommendedFoodIds, restrictedFoodIds]);

    console.log(`✅ MÓN ĂN CHỨA NGUYÊN LIỆU ĐƯỢC KHUYẾN NGHỊ (không có nguyên liệu bị hạn chế):`);
    console.log(`   Tổng: ${recommendedDishes.rows.length} món\n`);

    for (const dish of recommendedDishes.rows) {
      console.log(`   ✅ [${dish.dish_id}] ${dish.vietnamese_name || dish.name}`);
      console.log(`      Category: ${dish.category || 'N/A'}`);
      
      // Get ingredients
      const ingredients = await client.query(`
        SELECT 
          f.food_id,
          f.name,
          f.name_vi,
          di.weight_g
        FROM dishingredient di
        JOIN food f ON di.food_id = f.food_id
        WHERE di.dish_id = $1
        ORDER BY di.display_order
      `, [dish.dish_id]);

      console.log(`      Nguyên liệu:`);
      ingredients.rows.forEach(ing => {
        const isRecommended = recommendedFoodIds.includes(ing.food_id);
        const marker = isRecommended ? '      ✅' : '      -';
        console.log(`${marker} ${ing.name_vi || ing.name} (${ing.weight_g}g)${isRecommended ? ' 💚 KHUYẾN NGHỊ' : ''}`);
      });
      console.log('');
    }

    // Summary
    console.log('='.repeat(80));
    console.log('TÓM TẮT');
    console.log('='.repeat(80));
    console.log(`\n📊 Thống kê cho User: ${user.rows[0].email}`);
    console.log(`   - Tình trạng sức khỏe đang điều trị: ${activeConditions.length}`);
    console.log(`   - Thực phẩm nên tránh: ${avoidFoods.rows.length}`);
    console.log(`   - Thực phẩm được khuyến nghị: ${recommendFoods.rows.length}`);
    console.log(`   - Món ăn bị hạn chế: ${restrictedDishes.rows.length}`);
    console.log(`   - Món ăn được khuyến nghị: ${recommendedDishes.rows.length}`);

    console.log('\n📱 KHI MỞ ADD MEAL DIALOG:');
    console.log(`   Tab "Nguyên Liệu":`);
    console.log(`   - ${avoidFoods.rows.length} foods sẽ bị làm mờ (opacity 0.45)`);
    console.log(`   - ${recommendFoods.rows.length} foods sẽ có badge "Nên dùng"`);
    console.log(`\n   Tab "Món Ăn":`);
    console.log(`   - ${restrictedDishes.rows.length} dishes sẽ bị làm mờ`);
    console.log(`   - ${recommendedDishes.rows.length} dishes sẽ có badge "Nên dùng"`);

  } catch (error) {
    console.error('❌ Lỗi:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

checkUserId1();
