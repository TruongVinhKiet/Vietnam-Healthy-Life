const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

const categoryMapping = {
  // Vietnamese dishes
  3011: 'Vietnamese Cuisine', // Phở bò
  3012: 'Vietnamese Cuisine', // Bún chả
  3013: 'Vietnamese Cuisine', // Cơm tấm
  3014: 'Vietnamese Cuisine', // Bánh mì Việt Nam
  3015: 'Vietnamese Cuisine', // Gỏi cuốn
  3016: 'Vietnamese Cuisine', // Canh chua cá
  3017: 'Vietnamese Cuisine', // Rau muống xào tỏi
  3018: 'Vietnamese Cuisine', // Cá kho tộ
  3019: 'Vietnamese Cuisine', // Thịt kho trứng
  3020: 'Vietnamese Cuisine', // Xôi
  3021: 'Vietnamese Cuisine', // Bún bò Huế
  3022: 'Vietnamese Cuisine', // Bánh xèo
  3023: 'Vietnamese Cuisine', // Chả giò
  3024: 'Vietnamese Cuisine', // Mì Quảng
  3025: 'Vietnamese Cuisine', // Cao lầu Hội An
  3026: 'Vietnamese Cuisine', // Bún riêu
  3027: 'Vietnamese Cuisine', // Hủ tiếu Nam Vang
  3028: 'Vietnamese Cuisine', // Bánh cuốn
  3029: 'Vietnamese Cuisine', // Chè đậu xanh
  3030: 'Vietnamese Cuisine', // Bánh flan
  3031: 'Vietnamese Cuisine', // Bò lúc lắc
  3032: 'Vietnamese Cuisine', // Gà kho gừng
  3033: 'Vietnamese Cuisine', // Canh khổ qua nhồi thịt
  3034: 'Vietnamese Cuisine', // Thịt kho tàu
  3035: 'Vietnamese Cuisine', // Cà ri gà
  3036: 'Vietnamese Cuisine', // Gỏi gà bắp cải
  3037: 'Vietnamese Cuisine', // Chạo tôm
  3038: 'Vietnamese Cuisine', // Nem nướng
  3039: 'Vietnamese Cuisine', // Đậu hũ sốt cà chua
  3040: 'Vietnamese Cuisine', // Canh sườn hầm củ cải
  
  // Vegetables
  3001: 'Vegetables', // Rau bina
  3002: 'Vegetables', // Cải xoăn
  3009: 'Vegetables', // Súp lơ xanh
  
  // Meats
  3003: 'Meats', // Gan bò
  
  // Fruits
  3004: 'Fruits', // Chuối
  3005: 'Fruits', // Nước cam ép
  
  // Dairy
  3006: 'Dairy', // Sữa chua không đường
  3010: 'Dairy', // Sữa tươi nguyên kem
  
  // Fish & Seafood
  3007: 'Fish & Seafood', // Cá hồi
  
  // Grains
  3008: 'Grains', // Cơm trắng
  
  // Beverages
  19: 'Beverages', // Bia nhẹ
};

async function fixCategories() {
  try {
    let updated = 0;
    
    for (const [foodId, category] of Object.entries(categoryMapping)) {
      await pool.query(
        'UPDATE food SET category = $1 WHERE food_id = $2',
        [category, parseInt(foodId)]
      );
      updated++;
    }
    
    console.log(`\n✅ Updated ${updated} foods with proper categories`);
    
    // Verify
    const result = await pool.query(`
      SELECT COUNT(*) 
      FROM food 
      WHERE category IS NULL OR category = '' OR category = 'null'
    `);
    
    console.log(`\n📊 Remaining foods with NULL/empty category: ${result.rows[0].count}`);
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await pool.end();
  }
}

fixCategories();
