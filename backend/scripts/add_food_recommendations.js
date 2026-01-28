const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function addFoodRecommendations() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    // Get condition IDs
    const conditions = await client.query(`
      SELECT condition_id, name_vi 
      FROM healthcondition 
      WHERE name_vi IN ('Cao huyết áp', 'Tiểu đường type 2', 'Mỡ máu cao', 'Gout', 'Béo phì', 'Đái tháo đường tuýp 2')
    `);

    const conditionMap = {};
    conditions.rows.forEach(row => {
      conditionMap[row.name_vi] = row.condition_id;
    });

    console.log('Found conditions:', conditionMap);

    // Get some common food IDs (we'll query the database for actual food IDs)
    const foods = await client.query(`
      SELECT food_id, name_vi, name 
      FROM food 
      WHERE name_vi IN (
        'Muối', 'Đường', 'Rau chân vịt', 'Chuối', 'Cá hồi', 
        'Rau cải xoăn', 'Thịt đỏ', 'Nội tạng', 'Hải sản', 
        'Yến mạch', 'Gạo lứt', 'Dầu ô liu', 'Quả bơ', 'Hạt óc chó',
        'Sữa không đường', 'Trứng gà', 'Bia', 'Rượu', 'Nước ngọt'
      )
      LIMIT 50
    `);

    console.log(`Found ${foods.rows.length} foods`);

    const foodMap = {};
    foods.rows.forEach(row => {
      foodMap[row.name_vi] = row.food_id;
    });

    // Food recommendations for Cao huyết áp
    const hypertensionId = conditionMap['Cao huyết áp'];
    if (hypertensionId) {
      const recommendations = [
        { foodName: 'Muối', type: 'avoid', notes: 'Muối làm tăng huyết áp, nên hạn chế dưới 5g/ngày' },
        { foodName: 'Rau chân vịt', type: 'recommend', notes: 'Giàu kali, giúp kiểm soát huyết áp' },
        { foodName: 'Chuối', type: 'recommend', notes: 'Giàu kali, hỗ trợ giảm huyết áp' },
        { foodName: 'Thịt đỏ', type: 'avoid', notes: 'Chứa nhiều chất béo bão hòa, nên hạn chế' },
        { foodName: 'Rau cải xoăn', type: 'recommend', notes: 'Giàu vitamin K, kali, magie' },
      ];

      for (const rec of recommendations) {
        if (foodMap[rec.foodName]) {
          await client.query(`
            INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT DO NOTHING
          `, [hypertensionId, foodMap[rec.foodName], rec.type, rec.notes]);
          console.log(`  ✓ ${rec.foodName} (${rec.type}) for Cao huyết áp`);
        }
      }
    }

    // Food recommendations for Tiểu đường / Đái tháo đường
    const diabetesIds = [conditionMap['Tiểu đường type 2'], conditionMap['Đái tháo đường tuýp 2']].filter(Boolean);
    for (const diabetesId of diabetesIds) {
      const recommendations = [
        { foodName: 'Đường', type: 'avoid', notes: 'Tăng đường huyết nhanh, cần tránh' },
        { foodName: 'Nước ngọt', type: 'avoid', notes: 'Chứa nhiều đường, gây tăng đường huyết' },
        { foodName: 'Yến mạch', type: 'recommend', notes: 'Giàu chất xơ, ổn định đường huyết' },
        { foodName: 'Gạo lứt', type: 'recommend', notes: 'Chỉ số đường huyết thấp hơn gạo trắng' },
        { foodName: 'Quả bơ', type: 'recommend', notes: 'Chất béo lành mạnh, ổn định đường huyết' },
      ];

      for (const rec of recommendations) {
        if (foodMap[rec.foodName]) {
          await client.query(`
            INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT DO NOTHING
          `, [diabetesId, foodMap[rec.foodName], rec.type, rec.notes]);
          console.log(`  ✓ ${rec.foodName} (${rec.type}) for Diabetes ID ${diabetesId}`);
        }
      }
    }

    // Food recommendations for Gout
    const goutId = conditionMap['Gout'];
    if (goutId) {
      const recommendations = [
        { foodName: 'Nội tạng', type: 'avoid', notes: 'Rất giàu purin, gây tăng axit uric' },
        { foodName: 'Hải sản', type: 'avoid', notes: 'Chứa nhiều purin, nên hạn chế' },
        { foodName: 'Bia', type: 'avoid', notes: 'Tăng axit uric, gây cơn gout cấp' },
        { foodName: 'Rượu', type: 'avoid', notes: 'Làm tăng axit uric trong máu' },
        { foodName: 'Chuối', type: 'recommend', notes: 'Giúp kiểm soát axit uric' },
      ];

      for (const rec of recommendations) {
        if (foodMap[rec.foodName]) {
          await client.query(`
            INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT DO NOTHING
          `, [goutId, foodMap[rec.foodName], rec.type, rec.notes]);
          console.log(`  ✓ ${rec.foodName} (${rec.type}) for Gout`);
        }
      }
    }

    // Food recommendations for Mỡ máu cao
    const cholesterolId = conditionMap['Mỡ máu cao'];
    if (cholesterolId) {
      const recommendations = [
        { foodName: 'Thịt đỏ', type: 'avoid', notes: 'Chứa nhiều chất béo bão hòa và cholesterol' },
        { foodName: 'Nội tạng', type: 'avoid', notes: 'Rất giàu cholesterol, nên tránh' },
        { foodName: 'Cá hồi', type: 'recommend', notes: 'Giàu omega-3, giảm cholesterol xấu' },
        { foodName: 'Dầu ô liu', type: 'recommend', notes: 'Chất béo không bão hòa đơn, tốt cho tim mạch' },
        { foodName: 'Hạt óc chó', type: 'recommend', notes: 'Giàu omega-3, giúp giảm cholesterol' },
      ];

      for (const rec of recommendations) {
        if (foodMap[rec.foodName]) {
          await client.query(`
            INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, $3, $4)
            ON CONFLICT DO NOTHING
          `, [cholesterolId, foodMap[rec.foodName], rec.type, rec.notes]);
          console.log(`  ✓ ${rec.foodName} (${rec.type}) for Mỡ máu cao`);
        }
      }
    }

    await client.query('COMMIT');
    console.log('\n✅ Food recommendations added successfully!');

    // Display results
    const result = await client.query(`
      SELECT 
        hc.name_vi as condition,
        f.name_vi as food,
        cfr.recommendation_type,
        cfr.notes
      FROM conditionfoodrecommendation cfr
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      JOIN food f ON cfr.food_id = f.food_id
      WHERE hc.condition_id IN ($1, $2, $3, $4, $5, $6)
      ORDER BY hc.name_vi, cfr.recommendation_type, f.name_vi
    `, diabetesIds.concat([hypertensionId, goutId, cholesterolId].filter(Boolean)));

    console.log(`\nTotal recommendations: ${result.rows.length}`);
    console.table(result.rows);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

require('dotenv').config();
addFoodRecommendations();
