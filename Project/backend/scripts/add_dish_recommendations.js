const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function createDishRecommendations() {
  try {
    // Step 1: Create table if not exists
    console.log('📋 Creating conditiondishrecommendation table...\n');
    
    await pool.query(`
      CREATE TABLE IF NOT EXISTS conditiondishrecommendation (
        recommendation_id SERIAL PRIMARY KEY,
        condition_id INTEGER NOT NULL,
        dish_id INTEGER NOT NULL,
        recommendation_type VARCHAR(20) NOT NULL CHECK (recommendation_type IN ('avoid', 'recommend')),
        reason TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (condition_id) REFERENCES healthcondition(condition_id) ON DELETE CASCADE,
        FOREIGN KEY (dish_id) REFERENCES dish(dish_id) ON DELETE CASCADE,
        UNIQUE(condition_id, dish_id, recommendation_type)
      )
    `);
    
    console.log('✅ Table created successfully\n');
    
    // Step 2: Add comprehensive dish recommendations for Vietnamese health conditions
    console.log('📝 Adding dish recommendations...\n');
    
    const recommendations = [
      // Tiểu đường type 2 (condition_id: 1)
      { condition_id: 1, dish_id: 64, type: 'recommend', reason: 'Phở bò: Protein cao, ít đường' },
      { condition_id: 1, dish_id: 71, type: 'recommend', reason: 'Bún bò Huế: Protein tốt, kiểm soát portion' },
      { condition_id: 1, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít calo, nhiều rau' },
      { condition_id: 1, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Ít tinh bột, nhiều chất xơ' },
      { condition_id: 1, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Protein không dầu mỡ' },
      { condition_id: 1, dish_id: 100, type: 'avoid', reason: 'Xôi: Chỉ số đường huyết cao' },
      { condition_id: 1, dish_id: 109, type: 'avoid', reason: 'Chè đậu xanh: Nhiều đường' },
      { condition_id: 1, dish_id: 110, type: 'avoid', reason: 'Bánh flan: Nhiều đường, carbs cao' },
      
      // Cao huyết áp (condition_id: 2)
      { condition_id: 2, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít muối, nhiều rau tươi' },
      { condition_id: 2, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Kali cao, ít natri' },
      { condition_id: 2, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Không muối nhiều' },
      { condition_id: 2, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein không muối' },
      { condition_id: 2, dish_id: 76, type: 'avoid', reason: 'Canh chua cá: Muối và nước mắm cao' },
      { condition_id: 2, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Nước mắm và muối cao' },
      { condition_id: 2, dish_id: 114, type: 'avoid', reason: 'Thịt kho tàu: Nước mắm và natri cao' },
      
      // Mỡ máu cao (condition_id: 3)
      { condition_id: 3, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít dầu mỡ' },
      { condition_id: 3, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Ít cholesterol' },
      { condition_id: 3, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 tốt cho tim mạch' },
      { condition_id: 3, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein nạc' },
      { condition_id: 3, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Ít cholesterol' },
      { condition_id: 3, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Dầu mỡ cao' },
      { condition_id: 3, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Cholesterol và mỡ cao' },
      { condition_id: 3, dish_id: 111, type: 'avoid', reason: 'Bò lúc lắc: Dầu chiên nhiều' },
      
      // Béo phì (condition_id: 4)
      { condition_id: 4, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít calo, nhiều rau' },
      { condition_id: 4, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Ít calo' },
      { condition_id: 4, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Protein không dầu' },
      { condition_id: 4, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Ít calo, protein cao' },
      { condition_id: 4, dish_id: 76, type: 'recommend', reason: 'Canh chua cá: Ít calo, nhiều rau' },
      { condition_id: 4, dish_id: 100, type: 'avoid', reason: 'Xôi: Calo cao từ carbs' },
      { condition_id: 4, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Dầu chiên nhiều' },
      { condition_id: 4, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên nhiều dầu' },
      { condition_id: 4, dish_id: 109, type: 'avoid', reason: 'Chè đậu xanh: Đường và calo cao' },
      
      // Gout (condition_id: 5)
      { condition_id: 5, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Ít purin' },
      { condition_id: 5, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Ít purin' },
      { condition_id: 5, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein ít purin hơn thịt đỏ' },
      { condition_id: 5, dish_id: 64, type: 'avoid', reason: 'Phở bò: Nước dùng purin cao' },
      { condition_id: 5, dish_id: 71, type: 'avoid', reason: 'Bún bò Huế: Thịt bò purin cao' },
      { condition_id: 5, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Cá purin cao' },
      { condition_id: 5, dish_id: 93, type: 'avoid', reason: 'Cá hấp: Hải sản purin cao' },
      
      // Gan nhiễm mỡ (condition_id: 6)
      { condition_id: 6, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít dầu mỡ, nhiều rau' },
      { condition_id: 6, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Chất xơ cao' },
      { condition_id: 6, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 tốt cho gan' },
      { condition_id: 6, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein nạc' },
      { condition_id: 6, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Dầu mỡ cao' },
      { condition_id: 6, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Mỡ động vật cao' },
      { condition_id: 6, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Chiên nhiều dầu' },
      
      // Viêm dạ dày (condition_id: 7)
      { condition_id: 7, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Dễ tiêu, nhẹ dạ dày' },
      { condition_id: 7, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Nhẹ, dễ tiêu hóa' },
      { condition_id: 7, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Mềm, dễ tiêu' },
      { condition_id: 7, dish_id: 76, type: 'avoid', reason: 'Canh chua cá: Chua gây kích ứng dạ dày' },
      { condition_id: 7, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Chiên dầu kích thích dạ dày' },
      { condition_id: 7, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên giòn khó tiêu' },
      
      // Thiếu máu (condition_id: 8)
      { condition_id: 8, dish_id: 64, type: 'recommend', reason: 'Phở bò: Thịt bò giàu sắt' },
      { condition_id: 8, dish_id: 71, type: 'recommend', reason: 'Bún bò Huế: Thịt bò sắt cao' },
      { condition_id: 8, dish_id: 79, type: 'recommend', reason: 'Thịt kho trứng: Sắt từ thịt và trứng' },
      { condition_id: 8, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Sắt từ rau' },
      
      // Thiếu máu do thiếu sắt (condition_id: 14)
      { condition_id: 14, dish_id: 64, type: 'recommend', reason: 'Phở bò: Thịt bò sắt heme cao' },
      { condition_id: 14, dish_id: 71, type: 'recommend', reason: 'Bún bò Huế: Thịt bò giàu sắt' },
      { condition_id: 14, dish_id: 79, type: 'recommend', reason: 'Thịt kho trứng: Sắt từ thịt' },
      { condition_id: 14, dish_id: 111, type: 'recommend', reason: 'Bò lúc lắc: Thịt bò sắt cao' },
      
      // Loãng xương (condition_id: 15)
      { condition_id: 15, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Canxi từ đậu' },
      { condition_id: 15, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Canxi và vitamin D' },
      { condition_id: 15, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Canxi từ rau' },
      
      // Bệnh thận mãn tính (condition_id: 17)
      { condition_id: 17, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein vừa phải' },
      { condition_id: 17, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít muối, protein vừa' },
      { condition_id: 17, dish_id: 64, type: 'avoid', reason: 'Phở bò: Natri và protein cao' },
      { condition_id: 17, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Muối và nước mắm cao' },
      { condition_id: 17, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Protein và phospho cao' },
      
      // Trào ngược dạ dày thực quản (condition_id: 18)
      { condition_id: 18, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Ít dầu mỡ' },
      { condition_id: 18, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Nhẹ, không kích ứng' },
      { condition_id: 18, dish_id: 76, type: 'avoid', reason: 'Canh chua cá: Chua kích thích' },
      { condition_id: 18, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Chiên dầu gây trào ngược' },
      { condition_id: 18, dish_id: 103, type: 'avoid', reason: 'Chả giò: Dầu mỡ gây trào ngược' },
    ];
    
    let added = 0;
    let skipped = 0;
    
    for (const rec of recommendations) {
      try {
        await pool.query(`
          INSERT INTO conditiondishrecommendation 
          (condition_id, dish_id, recommendation_type, reason)
          VALUES ($1, $2, $3, $4)
          ON CONFLICT (condition_id, dish_id, recommendation_type) DO NOTHING
        `, [rec.condition_id, rec.dish_id, rec.type, rec.reason]);
        added++;
      } catch (error) {
        console.log(`⚠️  Skipped: condition ${rec.condition_id}, dish ${rec.dish_id} - ${error.message}`);
        skipped++;
      }
    }
    
    console.log(`\n✅ Added ${added} dish recommendations`);
    if (skipped > 0) {
      console.log(`⚠️  Skipped ${skipped} recommendations (already exist or invalid)`);
    }
    
    // Verification
    const count = await pool.query('SELECT COUNT(*) FROM conditiondishrecommendation');
    console.log(`\n📊 Total dish recommendations in database: ${count.rows[0].count}`);
    
    // Show coverage
    const coverage = await pool.query(`
      SELECT 
        COUNT(DISTINCT condition_id) as conditions_with_recs,
        (SELECT COUNT(*) FROM healthcondition) as total_conditions
      FROM conditiondishrecommendation
    `);
    
    console.log(`📈 Coverage: ${coverage.rows[0].conditions_with_recs}/${coverage.rows[0].total_conditions} conditions have dish recommendations`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
  } finally {
    await pool.end();
  }
}

createDishRecommendations();
