const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

async function checkDishIngredients() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    console.log('🔍 KIỂM TRA NGUYÊN LIỆU BỊ HẠN CHẾ CÓ DÙNG TRONG MÓN ĂN:\n');

    // Check restricted foods used in dishes
    const restricted = await client.query(`
      SELECT DISTINCT 
        f.food_id, 
        f.name, 
        f.name_vi, 
        hc.name_vi as condition_name,
        cfr.recommendation_type
      FROM food f
      JOIN conditionfoodrecommendation cfr ON f.food_id = cfr.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.recommendation_type = 'avoid'
        AND EXISTS (
          SELECT 1 FROM dishingredient di 
          WHERE di.food_id = f.food_id
        )
    `);

    console.log('🚫 NGUYÊN LIỆU BỊ HẠN CHẾ ĐANG DÙNG TRONG MÓN ĂN:');
    console.log('Tổng:', restricted.rows.length, 'loại\n');
    
    restricted.rows.forEach(r => {
      console.log(`   [${r.food_id}] ${r.name_vi || r.name} - Bệnh: ${r.condition_name}`);
    });

    console.log('\n📋 CHI TIẾT MÓN ĂN SỬ DỤNG CÁC NGUYÊN LIỆU NÀY:\n');
    
    for (const r of restricted.rows) {
      const dishes = await client.query(`
        SELECT d.dish_id, d.name, d.vietnamese_name
        FROM dish d
        JOIN dishingredient di ON d.dish_id = di.dish_id
        WHERE di.food_id = $1
      `, [r.food_id]);

      console.log(`🚫 [${r.food_id}] ${r.name_vi || r.name}:`);
      dishes.rows.forEach(d => {
        console.log(`      → Món [${d.dish_id}] ${d.vietnamese_name || d.name}`);
      });
    }

    console.log('\n\n🔍 KIỂM TRA NGUYÊN LIỆU ĐƯỢC KHUYẾN NGHỊ CÓ DÙNG TRONG MÓN ĂN:\n');

    // Check recommended foods used in dishes
    const recommended = await client.query(`
      SELECT DISTINCT 
        f.food_id, 
        f.name, 
        f.name_vi, 
        hc.name_vi as condition_name,
        cfr.recommendation_type
      FROM food f
      JOIN conditionfoodrecommendation cfr ON f.food_id = cfr.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.recommendation_type = 'recommend'
        AND EXISTS (
          SELECT 1 FROM dishingredient di 
          WHERE di.food_id = f.food_id
        )
    `);

    console.log('✅ NGUYÊN LIỆU ĐƯỢC KHUYẾN NGHỊ ĐANG DÙNG TRONG MÓN ĂN:');
    console.log('Tổng:', recommended.rows.length, 'loại\n');
    
    recommended.rows.forEach(r => {
      console.log(`   [${r.food_id}] ${r.name_vi || r.name} - Bệnh: ${r.condition_name}`);
    });

    console.log('\n📋 CHI TIẾT MÓN ĂN SỬ DỤNG CÁC NGUYÊN LIỆU NÀY:\n');
    
    for (const r of recommended.rows) {
      const dishes = await client.query(`
        SELECT d.dish_id, d.name, d.vietnamese_name
        FROM dish d
        JOIN dishingredient di ON d.dish_id = di.dish_id
        WHERE di.food_id = $1
      `, [r.food_id]);

      console.log(`✅ [${r.food_id}] ${r.name_vi || r.name}:`);
      dishes.rows.forEach(d => {
        console.log(`      → Món [${d.dish_id}] ${d.vietnamese_name || d.name}`);
      });
    }

    console.log('\n\n📊 TÓM TẮT:');
    console.log(`   - Nguyên liệu bị hạn chế có trong món ăn: ${restricted.rows.length}`);
    console.log(`   - Nguyên liệu được khuyến nghị có trong món ăn: ${recommended.rows.length}`);
    
    if (restricted.rows.length > 0 || recommended.rows.length > 0) {
      console.log('\n✅ CÓ DỮ LIỆU ĐỂ TEST CHỨC NĂNG!');
      console.log('   Bạn có thể test với các món ăn trên trong Add Meal Dialog.');
    } else {
      console.log('\n⚠️  KHÔNG CÓ DỮ LIỆU ĐỂ TEST!');
      console.log('   Cần tạo thêm món ăn sử dụng các nguyên liệu bị avoid/recommend.');
    }

  } catch (err) {
    console.error('❌ Lỗi:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

checkDishIngredients();
