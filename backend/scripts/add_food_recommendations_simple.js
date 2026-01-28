const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function addFoodRecommendationsSimple() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    // Clear existing recommendations first
    await client.query('DELETE FROM conditionfoodrecommendation');
    console.log('✓ Cleared existing recommendations');

    // Define recommendations using actual food IDs and condition IDs from database
    const recommendations = [
      // Cao huyết áp (condition_id = 2)
      { condition_id: 2, food_id: 40, type: 'avoid', notes: 'Nước mắm chứa nhiều muối, làm tăng huyết áp' },
      { condition_id: 2, food_id: 41, type: 'avoid', notes: 'Đường tinh luyện nên hạn chế' },
      { condition_id: 2, food_id: 36, type: 'recommend', notes: 'Dứa giàu kali, giúp kiểm soát huyết áp' },
      { condition_id: 2, food_id: 37, type: 'recommend', notes: 'Đậu xanh tốt cho tim mạch' },
      { condition_id: 2, food_id: 43, type: 'recommend', notes: 'Rau củ giàu chất xơ và khoáng chất' },
      
      // Tiểu đường type 2 (condition_id = 1)
      { condition_id: 1, food_id: 41, type: 'avoid', notes: 'Đường làm tăng đường huyết nhanh' },
      { condition_id: 1, food_id: 26, type: 'avoid', notes: 'Gạo trắng có chỉ số đường huyết cao, nên thay bằng gạo lứt' },
      { condition_id: 1, food_id: 37, type: 'recommend', notes: 'Đậu xanh giàu chất xơ, ổn định đường huyết' },
      { condition_id: 1, food_id: 43, type: 'recommend', notes: 'Rau củ giàu chất xơ, chỉ số đường huyết thấp' },
      { condition_id: 1, food_id: 31, type: 'recommend', notes: 'Ngô giàu chất xơ, tốt cho người tiểu đường' },
      
      // Đái tháo đường tuýp 2 (condition_id = 11)  
      { condition_id: 11, food_id: 41, type: 'avoid', notes: 'Đường làm tăng đường huyết nhanh' },
      { condition_id: 11, food_id: 26, type: 'avoid', notes: 'Gạo trắng nên hạn chế' },
      { condition_id: 11, food_id: 37, type: 'recommend', notes: 'Đậu xanh giàu chất xơ' },
      { condition_id: 11, food_id: 43, type: 'recommend', notes: 'Rau củ tốt cho người tiểu đường' },

      // Mỡ máu cao (condition_id = 3)
      { condition_id: 3, food_id: 40, type: 'avoid', notes: 'Nước mắm chứa nhiều natri' },
      { condition_id: 3, food_id: 41, type: 'avoid', notes: 'Đường nên hạn chế' },
      { condition_id: 3, food_id: 37, type: 'recommend', notes: 'Đậu xanh giúp giảm cholesterol' },
      { condition_id: 3, food_id: 38, type: 'recommend', notes: 'Nấm tốt cho sức khỏe tim mạch' },
      { condition_id: 3, food_id: 43, type: 'recommend', notes: 'Rau củ giàu chất xơ, giảm cholesterol' },

      // Béo phì (condition_id = 4)
      { condition_id: 4, food_id: 41, type: 'avoid', notes: 'Đường gây tăng cân' },
      { condition_id: 4, food_id: 26, type: 'avoid', notes: 'Gạo trắng nhiều calo, nên ăn vừa phải' },
      { condition_id: 4, food_id: 43, type: 'recommend', notes: 'Rau củ ít calo, giàu chất xơ' },
      { condition_id: 4, food_id: 37, type: 'recommend', notes: 'Đậu xanh giàu protein thực vật' },
      { condition_id: 4, food_id: 34, type: 'recommend', notes: 'Dưa leo ít calo, nhiều nước' },

      // Gout (condition_id = 5)
      { condition_id: 5, food_id: 40, type: 'avoid', notes: 'Nước mắm nên hạn chế' },
      { condition_id: 5, food_id: 37, type: 'avoid', notes: 'Đậu xanh chứa purin trung bình, ăn vừa phải' },
      { condition_id: 5, food_id: 43, type: 'recommend', notes: 'Rau củ ít purin, an toàn cho người gout' },
      { condition_id: 5, food_id: 34, type: 'recommend', notes: 'Dưa leo giúp thải độc' },
      { condition_id: 5, food_id: 36, type: 'recommend', notes: 'Dứa có enzyme bromelain, chống viêm' },
    ];

    console.log(`\nAdding ${recommendations.length} food recommendations...`);

    for (const rec of recommendations) {
      await client.query(`
        INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
        VALUES ($1, $2, $3, $4)
      `, [rec.condition_id, rec.food_id, rec.type, rec.notes]);
    }

    await client.query('COMMIT');
    console.log('✅ All food recommendations added successfully!\n');

    // Display summary by condition
    const summary = await client.query(`
      SELECT 
        hc.name_vi as condition,
        COUNT(CASE WHEN cfr.recommendation_type = 'avoid' THEN 1 END) as foods_to_avoid,
        COUNT(CASE WHEN cfr.recommendation_type = 'recommend' THEN 1 END) as foods_to_recommend,
        COUNT(*) as total
      FROM healthcondition hc
      LEFT JOIN conditionfoodrecommendation cfr ON hc.condition_id = cfr.condition_id
      WHERE hc.condition_id IN (1, 2, 3, 4, 5, 11)
      GROUP BY hc.condition_id, hc.name_vi
      ORDER BY hc.condition_id
    `);

    console.log('Summary by Condition:');
    console.table(summary.rows);

    // Display all recommendations
    const details = await client.query(`
      SELECT 
        hc.name_vi as condition,
        f.name as food,
        cfr.recommendation_type as type,
        cfr.notes
      FROM conditionfoodrecommendation cfr
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      JOIN food f ON cfr.food_id = f.food_id
      WHERE hc.condition_id IN (1, 2, 3, 4, 5, 11)
      ORDER BY hc.name_vi, cfr.recommendation_type DESC, f.name
    `);

    console.log(`\nTotal Recommendations: ${details.rows.length}`);
    console.log('\nDetailed Recommendations:');
    console.table(details.rows);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    console.error(error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

require('dotenv').config();
addFoodRecommendationsSimple();
