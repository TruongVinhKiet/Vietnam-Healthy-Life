const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function seedHealthConditionData() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🌱 SEEDING HEALTH CONDITION DATA\n');
    console.log('='.repeat(80));
    
    // Get nutrient IDs from actual database
    const nutrients = await client.query(`
      SELECT nutrient_id, nutrient_code 
      FROM nutrient 
      ORDER BY nutrient_code
    `);
    
    const nutrientMap = {};
    nutrients.rows.forEach(n => {
      nutrientMap[n.nutrient_code] = n.nutrient_id;
    });
    
    console.log(`Found ${Object.keys(nutrientMap).length} nutrients\n`);
    
    // Get health conditions
    const conditions = await client.query(`
      SELECT condition_id, name_vi, name_en 
      FROM healthcondition 
      ORDER BY condition_id
    `);
    
    console.log('Health Conditions:');
    console.table(conditions.rows);
    
    // ============================================================
    // 1. SEED CONDITIONNUTRIENTEFFECT
    // ============================================================
    
    console.log('\n📊 Seeding ConditionNutrientEffect...\n');
    
    const nutrientEffects = [
      // Tiểu đường type 2 (Diabetes)
      { condition_id: 1, nutrient_code: 'FIBTG', effect_type: 'increase', adjustment_percent: 40, notes: 'Tăng chất xơ giúp kiểm soát đường huyết' },
      { condition_id: 1, nutrient_code: 'CHOCDF', effect_type: 'decrease', adjustment_percent: -15, notes: 'Giảm carbohydrate đơn giản' },
      { condition_id: 1, nutrient_code: 'PROCNT', effect_type: 'increase', adjustment_percent: 15, notes: 'Tăng protein giúp ổn định đường huyết' },
      
      // Cao huyết áp (Hypertension)
      { condition_id: 2, nutrient_code: 'NA', effect_type: 'decrease', adjustment_percent: -50, notes: 'Giảm natri rất quan trọng' },
      { condition_id: 2, nutrient_code: 'CA', effect_type: 'increase', adjustment_percent: 20, notes: 'Calcium giúp kiểm soát huyết áp' },
      { condition_id: 2, nutrient_code: 'FIBTG', effect_type: 'increase', adjustment_percent: 25, notes: 'Chất xơ giúp giảm huyết áp' },
      
      // Mỡ máu cao (High Cholesterol)
      { condition_id: 3, nutrient_code: 'FIBTG', effect_type: 'increase', adjustment_percent: 35, notes: 'Chất xơ giúp giảm cholesterol' },
      { condition_id: 3, nutrient_code: 'FAT', effect_type: 'decrease', adjustment_percent: -25, notes: 'Giảm tổng chất béo' },
      
      // Béo phì (Obesity)
      { condition_id: 4, nutrient_code: 'FIBTG', effect_type: 'increase', adjustment_percent: 30, notes: 'Chất xơ tạo cảm giác no' },
      { condition_id: 4, nutrient_code: 'PROCNT', effect_type: 'increase', adjustment_percent: 20, notes: 'Protein giúp giữ cơ' },
      { condition_id: 4, nutrient_code: 'ENERC_KCAL', effect_type: 'decrease', adjustment_percent: -20, notes: 'Giảm calories tổng thể' },
      
      // Gout
      { condition_id: 5, nutrient_code: 'VITC', effect_type: 'increase', adjustment_percent: 50, notes: 'Vitamin C giảm acid uric' },
      { condition_id: 5, nutrient_code: 'PROCNT', effect_type: 'decrease', adjustment_percent: -20, notes: 'Giảm protein động vật' },
      
      // Gan nhiễm mỡ (Fatty Liver)
      { condition_id: 6, nutrient_code: 'VITC', effect_type: 'increase', adjustment_percent: 30, notes: 'Chống oxy hóa bảo vệ gan' },
      { condition_id: 6, nutrient_code: 'FAT', effect_type: 'decrease', adjustment_percent: -30, notes: 'Giảm chất béo' },
      
      // Dạ dày (Gastritis)
      { condition_id: 7, nutrient_code: 'FIBTG', effect_type: 'increase', adjustment_percent: 20, notes: 'Chất xơ giúp tiêu hóa' },
      { condition_id: 7, nutrient_code: 'CA', effect_type: 'increase', adjustment_percent: 15, notes: 'Calcium giúp bảo vệ niêm mạc' },
      
      // Thiếu máu (Anemia)
      { condition_id: 8, nutrient_code: 'FE', effect_type: 'increase', adjustment_percent: 100, notes: 'Tăng gấp đôi sắt' },
      { condition_id: 8, nutrient_code: 'VITC', effect_type: 'increase', adjustment_percent: 50, notes: 'Vitamin C giúp hấp thu sắt' },
      { condition_id: 8, nutrient_code: 'PROCNT', effect_type: 'increase', adjustment_percent: 20, notes: 'Protein cần cho hồng cầu' },
      
      // Loãng xương (Osteoporosis)
      { condition_id: 9, nutrient_code: 'CA', effect_type: 'increase', adjustment_percent: 50, notes: 'Calcium rất quan trọng cho xương' },
      { condition_id: 9, nutrient_code: 'PROCNT', effect_type: 'increase', adjustment_percent: 15, notes: 'Protein giúp xây dựng xương' },
      
      // Suy thận (Kidney Disease)
      { condition_id: 10, nutrient_code: 'PROCNT', effect_type: 'decrease', adjustment_percent: -30, notes: 'Giảm protein giảm gánh nặng thận' },
      { condition_id: 10, nutrient_code: 'NA', effect_type: 'decrease', adjustment_percent: -40, notes: 'Giảm muối' }
    ];
    
    let insertedEffects = 0;
    for (const effect of nutrientEffects) {
      const nutrientId = nutrientMap[effect.nutrient_code];
      
      if (!nutrientId) {
        console.log(`⚠️  Nutrient ${effect.nutrient_code} not found, skipping...`);
        continue;
      }
      
      try {
        await client.query(`
          INSERT INTO conditionnutrienteffect 
          (condition_id, nutrient_id, effect_type, adjustment_percent, notes)
          VALUES ($1, $2, $3, $4, $5)
          ON CONFLICT DO NOTHING
        `, [effect.condition_id, nutrientId, effect.effect_type, effect.adjustment_percent, effect.notes]);
        
        insertedEffects++;
      } catch (err) {
        console.log(`❌ Error inserting effect: ${err.message}`);
      }
    }
    
    console.log(`✅ Inserted ${insertedEffects} nutrient effects\n`);
    
    // ============================================================
    // 2. SEED CONDITIONFOODRECOMMENDATION
    // ============================================================
    
    console.log('📊 Seeding ConditionFoodRecommendation...\n');
    
    // Get some foods
    const foods = await client.query(`
      SELECT food_id, name FROM food ORDER BY food_id LIMIT 30
    `);
    
    const foodRecommendations = [
      // Tiểu đường - Khuyến khích
      { condition_id: 1, food_name: 'Rau song', recommendation_type: 'recommend', notes: 'Ít đường, nhiều chất xơ' },
      { condition_id: 1, food_name: 'Ngo', recommendation_type: 'recommend', notes: 'Giàu vitamin, ít calories' },
      { condition_id: 1, food_name: 'Hanh tay', recommendation_type: 'recommend', notes: 'Hỗ trợ kiểm soát đường huyết' },
      
      // Tiểu đường - Tránh  
      { condition_id: 1, food_name: 'Duong', recommendation_type: 'avoid', notes: 'Nhiều đường, tránh hoàn toàn' },
      { condition_id: 1, food_name: 'Gao', recommendation_type: 'avoid', notes: 'Ăn ít, chọn gạo lứt' },
      
      // Cao huyết áp - Khuyến khích
      { condition_id: 2, food_name: 'Rau song', recommendation_type: 'recommend', notes: 'Ít natri, nhiều kali' },
      { condition_id: 2, food_name: 'Ngo', recommendation_type: 'recommend', notes: 'Giúp giảm huyết áp' },
      { condition_id: 2, food_name: 'Dua leo', recommendation_type: 'recommend', notes: 'Lợi tiểu tự nhiên' },
      
      // Cao huyết áp - Tránh
      { condition_id: 2, food_name: 'Nuoc mam', recommendation_type: 'avoid', notes: 'Rất nhiều muối' },
      
      // Béo phì - Khuyến khích
      { condition_id: 4, food_name: 'Rau song', recommendation_type: 'recommend', notes: 'Ít calories, nhiều chất xơ' },
      { condition_id: 4, food_name: 'Dua leo', recommendation_type: 'recommend', notes: 'Nhiều nước, ít calories' },
      { condition_id: 4, food_name: 'Ngo', recommendation_type: 'recommend', notes: 'Giàu dinh dưỡng, ít calories' },
      
      // Béo phì - Tránh
      { condition_id: 4, food_name: 'Duong', recommendation_type: 'avoid', notes: 'Nhiều calories trống' },
      { condition_id: 4, food_name: 'Hanh phi', recommendation_type: 'avoid', notes: 'Nhiều dầu mỡ' },
      
      // Thiếu máu - Khuyến khích
      { condition_id: 8, food_name: 'Ngo', recommendation_type: 'recommend', notes: 'Giàu sắt' },
      { condition_id: 8, food_name: 'Rau thom', recommendation_type: 'recommend', notes: 'Nhiều sắt và vitamin C' }
    ];
    
    let insertedRecs = 0;
    for (const rec of foodRecommendations) {
      const food = foods.rows.find(f => f.name.toLowerCase().includes(rec.food_name.toLowerCase()));
      
      if (!food) {
        console.log(`⚠️  Food ${rec.food_name} not found, skipping...`);
        continue;
      }
      
      try {
        await client.query(`
          INSERT INTO conditionfoodrecommendation 
          (condition_id, food_id, recommendation_type, notes)
          VALUES ($1, $2, $3, $4)
          ON CONFLICT DO NOTHING
        `, [rec.condition_id, food.food_id, rec.recommendation_type, rec.notes]);
        
        insertedRecs++;
      } catch (err) {
        console.log(`❌ Error: ${err.message}`);
      }
    }
    
    console.log(`✅ Inserted ${insertedRecs} food recommendations\n`);
    
    await client.query('COMMIT');
    
    // Verify
    console.log('='.repeat(80));
    console.log('\n📊 VERIFICATION:\n');
    
    const effectCount = await client.query('SELECT COUNT(*) FROM conditionnutrienteffect');
    const recCount = await client.query('SELECT COUNT(*) FROM conditionfoodrecommendation');
    
    console.table([{
      'ConditionNutrientEffect': effectCount.rows[0].count,
      'ConditionFoodRecommendation': recCount.rows[0].count
    }]);
    
    console.log('\n✅ Seeding completed successfully!\n');
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    console.error(error);
  } finally {
    client.release();
    await pool.end();
  }
}

seedHealthConditionData();
