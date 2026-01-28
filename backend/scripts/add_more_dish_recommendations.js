const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function addMoreDishRecommendations() {
  try {
    console.log('📝 Adding more dish recommendations for remaining conditions...\n');
    
    const recommendations = [
      // Suy dinh dưỡng (condition_id: 9)
      { condition_id: 9, dish_id: 64, type: 'recommend', reason: 'Phở bò: Protein và calo cao' },
      { condition_id: 9, dish_id: 71, type: 'recommend', reason: 'Bún bò Huế: Dinh dưỡng toàn diện' },
      { condition_id: 9, dish_id: 79, type: 'recommend', reason: 'Thịt kho trứng: Protein và chất béo' },
      { condition_id: 9, dish_id: 111, type: 'recommend', reason: 'Bò lúc lắc: Protein và năng lượng cao' },
      { condition_id: 9, dish_id: 100, type: 'recommend', reason: 'Xôi: Năng lượng từ carbs' },
      
      // Dị ứng thực phẩm (condition_id: 10)
      { condition_id: 10, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít allergen, tươi sạch' },
      { condition_id: 10, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Rau xanh ít dị ứng' },
      { condition_id: 10, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein dễ dung nạp' },
      { condition_id: 10, dish_id: 103, type: 'avoid', reason: 'Chả giò: Nhiều thành phần có thể gây dị ứng' },
      { condition_id: 10, dish_id: 93, type: 'avoid', reason: 'Cá hấp: Hải sản dễ gây dị ứng' },
      
      // Đái tháo đường tuýp 2 (condition_id: 11)
      { condition_id: 11, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít đường, chất xơ cao' },
      { condition_id: 11, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Ít carbs' },
      { condition_id: 11, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Protein không đường' },
      { condition_id: 11, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein nạc' },
      { condition_id: 11, dish_id: 100, type: 'avoid', reason: 'Xôi: Chỉ số đường huyết cao' },
      { condition_id: 11, dish_id: 109, type: 'avoid', reason: 'Chè đậu xanh: Đường cao' },
      { condition_id: 11, dish_id: 110, type: 'avoid', reason: 'Bánh flan: Đường và carbs cao' },
      
      // Tăng huyết áp (condition_id: 12)
      { condition_id: 12, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít muối' },
      { condition_id: 12, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Kali cao' },
      { condition_id: 12, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3, ít natri' },
      { condition_id: 12, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein không muối' },
      { condition_id: 12, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Nước mắm cao' },
      { condition_id: 12, dish_id: 114, type: 'avoid', reason: 'Thịt kho tàu: Muối và nước mắm' },
      
      // Huyết khối tĩnh mạch sâu (condition_id: 13)
      { condition_id: 13, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Vitamin K cân bằng' },
      { condition_id: 13, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 chống viêm' },
      { condition_id: 13, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein ổn định' },
      { condition_id: 13, dish_id: 75, type: 'avoid', reason: 'Gỏi cuốn: Vitamin K cao (nếu dùng Warfarin)' },
      
      // Gút/Gout (condition_id: 16)
      { condition_id: 16, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Ít purin' },
      { condition_id: 16, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Protein thực vật' },
      { condition_id: 16, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Ít purin hơn thịt đỏ' },
      { condition_id: 16, dish_id: 64, type: 'avoid', reason: 'Phở bò: Nước dùng purin cao' },
      { condition_id: 16, dish_id: 71, type: 'avoid', reason: 'Bún bò Huế: Thịt bò purin cao' },
      { condition_id: 16, dish_id: 111, type: 'avoid', reason: 'Bò lúc lắc: Thịt đỏ purin cao' },
      
      // Rối loạn lipid máu (condition_id: 19)
      { condition_id: 19, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít cholesterol' },
      { condition_id: 19, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Chất xơ hòa tan' },
      { condition_id: 19, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 giảm LDL' },
      { condition_id: 19, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Ít cholesterol' },
      { condition_id: 19, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Cholesterol cao' },
      { condition_id: 19, dish_id: 111, type: 'avoid', reason: 'Bò lúc lắc: Dầu mỡ cao' },
      
      // Bệnh tả không đặc hiệu (condition_id: 20)
      { condition_id: 20, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Dễ tiêu, bổ sung protein' },
      { condition_id: 20, dish_id: 100, type: 'recommend', reason: 'Xôi: Năng lượng dễ hấp thu' },
      { condition_id: 20, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên dầu khó tiêu' },
      { condition_id: 20, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Dầu mỡ kích thích ruột' },
      
      // Sốt thương hàn không đặc hiệu (condition_id: 21)
      { condition_id: 21, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein dễ tiêu' },
      { condition_id: 21, dish_id: 100, type: 'recommend', reason: 'Xôi: Năng lượng nhẹ' },
      { condition_id: 21, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên dầu nặng dạ dày' },
      
      // Bệnh động mạch vành (condition_id: 22)
      { condition_id: 22, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 tốt tim mạch' },
      { condition_id: 22, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít chất béo bão hòa' },
      { condition_id: 22, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Chất xơ giảm cholesterol' },
      { condition_id: 22, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Protein thực vật' },
      { condition_id: 22, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Mỡ bão hòa cao' },
      { condition_id: 22, dish_id: 111, type: 'avoid', reason: 'Bò lúc lắc: Cholesterol cao' },
      
      // Rung nhĩ (condition_id: 23)
      { condition_id: 23, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 ổn định nhịp tim' },
      { condition_id: 23, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Magie tốt cho tim' },
      { condition_id: 23, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Natri cao ảnh hưởng nhịp tim' },
      
      // Suy tim (condition_id: 24)
      { condition_id: 24, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Protein nhẹ, ít natri' },
      { condition_id: 24, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein không muối' },
      { condition_id: 24, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít muối, nhiều rau' },
      { condition_id: 24, dish_id: 78, type: 'avoid', reason: 'Cá kho tộ: Muối cao' },
      { condition_id: 24, dish_id: 114, type: 'avoid', reason: 'Thịt kho tàu: Nước mắm và muối' },
      
      // Viêm ruột Salmonella (condition_id: 25)
      { condition_id: 25, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Dễ tiêu, bổ sung protein' },
      { condition_id: 25, dish_id: 100, type: 'recommend', reason: 'Xôi: Dễ tiêu hóa' },
      { condition_id: 25, dish_id: 103, type: 'avoid', reason: 'Chả giò: Dầu mỡ kích thích ruột' },
      
      // Nhiễm trùng huyết Salmonella (condition_id: 26)
      { condition_id: 26, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein tăng miễn dịch' },
      { condition_id: 26, dish_id: 64, type: 'recommend', reason: 'Phở bò: Dinh dưỡng toàn diện' },
      { condition_id: 26, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên dầu giảm miễn dịch' },
      
      // Hen phế quản (condition_id: 27)
      { condition_id: 27, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 chống viêm' },
      { condition_id: 27, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Chống oxy hóa' },
      { condition_id: 27, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên dầu gây viêm' },
      { condition_id: 27, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Dầu mỡ kích ứng' },
      
      // Bệnh phổi tắc nghẽn mãn tính (condition_id: 28)
      { condition_id: 28, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Protein dễ tiêu' },
      { condition_id: 28, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Năng lượng ổn định' },
      { condition_id: 28, dish_id: 103, type: 'avoid', reason: 'Chả giò: Dầu mỡ gây khó thở' },
      
      // Loét dạ dày tá tràng (condition_id: 29)
      { condition_id: 29, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Nhẹ dạ dày' },
      { condition_id: 29, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Dễ tiêu hóa' },
      { condition_id: 29, dish_id: 76, type: 'avoid', reason: 'Canh chua cá: Chua kích ứng loét' },
      { condition_id: 29, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên dầu kích thích' },
      
      // Gan nhiễm mỡ/Fatty Liver (condition_id: 30)
      { condition_id: 30, dish_id: 75, type: 'recommend', reason: 'Gỏi cuốn: Ít dầu mỡ' },
      { condition_id: 30, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Chất xơ giải độc' },
      { condition_id: 30, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 giảm mỡ gan' },
      { condition_id: 30, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Mỡ động vật' },
      { condition_id: 30, dish_id: 102, type: 'avoid', reason: 'Bánh xèo: Dầu chiên nhiều' },
      
      // Viêm khớp dạng thấp (condition_id: 31)
      { condition_id: 31, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Omega-3 chống viêm' },
      { condition_id: 31, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Chống oxy hóa' },
      { condition_id: 31, dish_id: 119, type: 'recommend', reason: 'Đậu hũ sốt cà chua: Protein thực vật' },
      { condition_id: 31, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Mỡ bão hòa gây viêm' },
      
      // Suy giáp (condition_id: 32)
      { condition_id: 32, dish_id: 93, type: 'recommend', reason: 'Cá hấp: Selenium tốt cho tuyến giáp' },
      { condition_id: 32, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein hỗ trợ chuyển hóa' },
      { condition_id: 32, dish_id: 77, type: 'avoid', reason: 'Rau muống xào tỏi: Goitrogen ức chế giáp' },
      
      // Cường giáp (condition_id: 33)
      { condition_id: 33, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Goitrogen giảm hoạt động giáp' },
      { condition_id: 33, dish_id: 93, type: 'avoid', reason: 'Cá hấp: Iốt có thể tăng cường giáp' },
      
      // Đau nửa đầu/Migraine (condition_id: 34)
      { condition_id: 34, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Magie giảm đau đầu' },
      { condition_id: 34, dish_id: 77, type: 'recommend', reason: 'Rau muống xào tỏi: Magie cao' },
      { condition_id: 34, dish_id: 79, type: 'avoid', reason: 'Thịt kho trứng: Tyramine gây đau đầu' },
      
      // Nhiễm E. coli (condition_id: 35)
      { condition_id: 35, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein hỗ trợ phục hồi' },
      { condition_id: 35, dish_id: 100, type: 'recommend', reason: 'Xôi: Dễ tiêu, bổ sung năng lượng' },
      { condition_id: 35, dish_id: 103, type: 'avoid', reason: 'Chả giò: Dầu mỡ kích thích ruột' },
      
      // Viêm ruột Campylobacter (condition_id: 36)
      { condition_id: 36, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Nhẹ, dễ tiêu' },
      { condition_id: 36, dish_id: 100, type: 'recommend', reason: 'Xôi: Dễ hấp thu' },
      { condition_id: 36, dish_id: 103, type: 'avoid', reason: 'Chả giò: Chiên dầu nặng ruột' },
      
      // Viêm dạ dày ruột nhiễm trùng (condition_id: 37)
      { condition_id: 37, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Dễ tiêu hóa' },
      { condition_id: 37, dish_id: 100, type: 'recommend', reason: 'Xôi: Nhẹ dạ dày' },
      { condition_id: 37, dish_id: 103, type: 'avoid', reason: 'Chả giò: Dầu mỡ kích thích' },
      
      // Lao phổi (condition_id: 38)
      { condition_id: 38, dish_id: 64, type: 'recommend', reason: 'Phở bò: Protein tăng sức đề kháng' },
      { condition_id: 38, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Dinh dưỡng dễ hấp thu' },
      { condition_id: 38, dish_id: 79, type: 'recommend', reason: 'Thịt kho trứng: Năng lượng và protein' },
      
      // Viêm màng não do lao (condition_id: 39)
      { condition_id: 39, dish_id: 64, type: 'recommend', reason: 'Phở bò: Dinh dưỡng toàn diện' },
      { condition_id: 39, dish_id: 94, type: 'recommend', reason: 'Gà hấp: Protein hỗ trợ điều trị' },
      { condition_id: 39, dish_id: 79, type: 'recommend', reason: 'Thịt kho trứng: Năng lượng cao' },
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
        skipped++;
      }
    }
    
    console.log(`✅ Added ${added} new dish recommendations`);
    if (skipped > 0) {
      console.log(`⚠️  Skipped ${skipped} recommendations (already exist or invalid)`);
    }
    
    // Statistics
    const total = await pool.query('SELECT COUNT(*) FROM conditiondishrecommendation');
    console.log(`\n📊 Total dish recommendations: ${total.rows[0].count}`);
    
    const coverage = await pool.query(`
      SELECT 
        COUNT(DISTINCT condition_id) as conditions_with_recs,
        (SELECT COUNT(*) FROM healthcondition) as total_conditions
      FROM conditiondishrecommendation
    `);
    
    console.log(`📈 Coverage: ${coverage.rows[0].conditions_with_recs}/${coverage.rows[0].total_conditions} conditions (${Math.round(coverage.rows[0].conditions_with_recs / coverage.rows[0].total_conditions * 100)}%)`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await pool.end();
  }
}

addMoreDishRecommendations();
