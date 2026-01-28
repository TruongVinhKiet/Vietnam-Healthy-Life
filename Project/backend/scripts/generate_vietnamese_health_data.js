const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const fs = require('fs');

// Vietnamese dishes data - realistic Vietnamese cuisine
const VIETNAMESE_DISHES = {
  // Cho Tiểu đường / Đái tháo đường
  diabetes: [
    { name: 'Canh rau ngót nấu tôm', category: 'Soup', ingredients: [9, 43], servingSize: 300 },
    { name: 'Gà luộc chấm nước mắm', category: 'Lunch', ingredients: [9, 11], servingSize: 200 },
    { name: 'Cá hấp nấm', category: 'Dinner', ingredients: [9, 38], servingSize: 250 },
  ],
  
  // Cho Cao huyết áp
  hypertension: [
    { name: 'Canh cải thảo nấu thịt nạc', category: 'Soup', ingredients: [43, 9], servingSize: 300 },
    { name: 'Bông cải xanh luộc', category: 'Vegetarian', ingredients: [43], servingSize: 150 },
    { name: 'Salad rau trộn dầu oliu', category: 'Salad', ingredients: [9, 43], servingSize: 200 },
  ],
  
  // Cho Mỡ máu cao
  cholesterol: [
    { name: 'Cá hồi nướng', category: 'Dinner', ingredients: [11], servingSize: 200 },
    { name: 'Cháo yến mạch hạt hạnh nhân', category: 'Breakfast', ingredients: [12], servingSize: 250 },
    { name: 'Rau củ hấp', category: 'Vegetarian', ingredients: [43, 9], servingSize: 200 },
  ],
  
  // Cho Béo phì
  obesity: [
    { name: 'Salad ức gà', category: 'Lunch', ingredients: [9, 43], servingSize: 250 },
    { name: 'Canh rau củ thanh đạm', category: 'Soup', ingredients: [43, 9], servingSize: 300 },
    { name: 'Cá nướng rau củ', category: 'Dinner', ingredients: [11, 43], servingSize: 250 },
  ],
  
  // Cho Gout
  gout: [
    { name: 'Cháo gạo lứt rau củ', category: 'Breakfast', ingredients: [12, 43], servingSize: 300 },
    { name: 'Canh bí đỏ', category: 'Soup', ingredients: [43], servingSize: 250 },
    { name: 'Trứng luộc rau xào', category: 'Lunch', ingredients: [9, 43], servingSize: 200 },
  ],
  
  // Cho Gan nhiễm mỡ
  fattyLiver: [
    { name: 'Canh cải xanh nấu đậu hũ', category: 'Soup', ingredients: [43, 9], servingSize: 300 },
    { name: 'Cá diêu hồng hấp gừng', category: 'Dinner', ingredients: [11], servingSize: 200 },
    { name: 'Rau chân vịt luộc', category: 'Vegetarian', ingredients: [43], servingSize: 150 },
  ],
  
  // Cho Viêm dạ dày
  gastritis: [
    { name: 'Cháo gà nhạt', category: 'Light Meal', ingredients: [12, 9], servingSize: 300 },
    { name: 'Canh bí đao nấu tôm', category: 'Soup', ingredients: [43], servingSize: 250 },
    { name: 'Khoai lang luộc', category: 'Snack', ingredients: [43], servingSize: 200 },
  ],
  
  // Cho Thiếu máu
  anemia: [
    { name: 'Gan gà xào nấm', category: 'Lunch', ingredients: [38], servingSize: 150 },
    { name: 'Thịt bò xào rau củ', category: 'Dinner', ingredients: [9, 43], servingSize: 250 },
    { name: 'Canh rau dền nấu tôm', category: 'Soup', ingredients: [43, 9], servingSize: 300 },
  ],
  
  // Cho Loãng xương
  osteoporosis: [
    { name: 'Canh cá nấu cải', category: 'Soup', ingredients: [11, 43], servingSize: 300 },
    { name: 'Đậu hũ non hấp', category: 'Vegetarian', ingredients: [12], servingSize: 200 },
    { name: 'Sữa đậu nành hạt điều', category: 'Breakfast', ingredients: [12], servingSize: 250 },
  ],
  
  // Cho Bệnh thận
  kidney: [
    { name: 'Canh bí đỏ', category: 'Soup', ingredients: [43], servingSize: 250 },
    { name: 'Ức gà hấp', category: 'Lunch', ingredients: [9], servingSize: 150 },
    { name: 'Trứng trắng luộc', category: 'Breakfast', ingredients: [9], servingSize: 100 },
  ],
};

// Food recommendations for conditions
const CONDITION_FOOD_RECOMMENDATIONS = {
  6: { // Gan nhiễm mỡ
    avoid: [
      { food_id: 1, notes: 'Tránh đường và tinh bột tinh luyện' },
      { food_id: 41, notes: 'Hạn chế đường' },
    ],
    recommend: [
      { food_id: 43, notes: 'Rau củ giàu chất xơ tốt cho gan' },
      { food_id: 9, notes: 'Protein nạc giúp phục hồi gan' },
      { food_id: 11, notes: 'Cá giàu omega-3 giảm mỡ gan' },
    ]
  },
  7: { // Viêm dạ dày
    avoid: [
      { food_id: 40, notes: 'Tránh thức ăn cay nồng' },
      { food_id: 41, notes: 'Hạn chế đồ ngọt' },
    ],
    recommend: [
      { food_id: 12, notes: 'Cháo gạo lứt dễ tiêu hóa' },
      { food_id: 43, notes: 'Rau luộc nhạt' },
    ]
  },
  8: { // Thiếu máu
    avoid: [
      { food_id: 41, notes: 'Hạn chế đường tinh luyện' },
    ],
    recommend: [
      { food_id: 9, notes: 'Thịt đỏ giàu sắt' },
      { food_id: 43, notes: 'Rau lá xanh giàu folate' },
      { food_id: 11, notes: 'Gan động vật giàu sắt' },
    ]
  },
  9: { // Suy dinh dưỡng
    avoid: [
      { food_id: 41, notes: 'Tránh đồ ăn vặt không dinh dưỡng' },
    ],
    recommend: [
      { food_id: 9, notes: 'Protein chất lượng cao' },
      { food_id: 12, notes: 'Ngũ cốc nguyên hạt' },
      { food_id: 43, notes: 'Rau củ đa dạng' },
      { food_id: 6, notes: 'Trái cây giàu vitamin' },
    ]
  },
  10: { // Dị ứng thực phẩm
    avoid: [
      { food_id: 1, notes: 'Tùy vào loại dị ứng cụ thể' },
    ],
    recommend: [
      { food_id: 43, notes: 'Rau củ ít gây dị ứng' },
      { food_id: 12, notes: 'Gạo lứt an toàn' },
    ]
  },
  12: { // Tăng huyết áp (duplicate of 2)
    avoid: [
      { food_id: 40, notes: 'Giảm muối' },
      { food_id: 41, notes: 'Hạn chế đường' },
    ],
    recommend: [
      { food_id: 43, notes: 'Rau củ giàu kali' },
      { food_id: 9, notes: 'Protein nạc' },
      { food_id: 11, notes: 'Cá giàu omega-3' },
    ]
  },
  14: { // Thiếu máu do thiếu sắt
    avoid: [
      { food_id: 41, notes: 'Hạn chế đường' },
    ],
    recommend: [
      { food_id: 9, notes: 'Thịt đỏ giàu sắt heme' },
      { food_id: 43, notes: 'Rau lá xanh' },
      { food_id: 6, notes: 'Vitamin C giúp hấp thu sắt' },
    ]
  },
  15: { // Loãng xương
    avoid: [
      { food_id: 40, notes: 'Giảm muối làm mất canxi' },
      { food_id: 41, notes: 'Hạn chế đường' },
    ],
    recommend: [
      { food_id: 12, notes: 'Đậu nành giàu canxi' },
      { food_id: 9, notes: 'Protein xây dựng xương' },
      { food_id: 43, notes: 'Rau xanh giàu canxi' },
    ]
  },
  17: { // Bệnh thận mãn tính
    avoid: [
      { food_id: 40, notes: 'Hạn chế muối nghiêm ngặt' },
      { food_id: 9, notes: 'Giảm protein' },
    ],
    recommend: [
      { food_id: 43, notes: 'Rau củ hạn chế kali' },
      { food_id: 12, notes: 'Ngũ cốc tinh chế' },
    ]
  },
  18: { // Trào ngược dạ dày
    avoid: [
      { food_id: 40, notes: 'Tránh đồ cay' },
      { food_id: 41, notes: 'Hạn chế đồ ngọt' },
    ],
    recommend: [
      { food_id: 12, notes: 'Cháo nhạt' },
      { food_id: 43, notes: 'Rau luộc' },
    ]
  },
  22: { // Bệnh động mạch vành
    avoid: [
      { food_id: 1, notes: 'Tránh mỡ bão hòa' },
      { food_id: 40, notes: 'Giảm muối' },
    ],
    recommend: [
      { food_id: 11, notes: 'Cá giàu omega-3' },
      { food_id: 43, notes: 'Rau củ giàu chất chống oxy hóa' },
      { food_id: 6, notes: 'Trái cây tươi' },
    ]
  },
  24: { // Suy tim
    avoid: [
      { food_id: 40, notes: 'Hạn chế muối' },
      { food_id: 41, notes: 'Giảm đường' },
    ],
    recommend: [
      { food_id: 43, notes: 'Rau củ giàu kali' },
      { food_id: 11, notes: 'Protein nạc' },
    ]
  },
};

async function generateData() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_DATABASE || 'Health',
  });

  const client = await pool.connect();

  try {
    console.log('🚀 BẮT ĐẦU TẠO DỮ LIỆU VIETNAMESE HEALTH DATA\n');
    console.log('='.repeat(80));

    // Step 1: Add food recommendations for conditions without them
    console.log('\n📋 BƯỚC 1: Thêm Food Recommendations cho các bệnh...\n');
    
    let recommendationCount = 0;
    for (const [conditionId, data] of Object.entries(CONDITION_FOOD_RECOMMENDATIONS)) {
      // Add avoid foods
      for (const avoid of data.avoid) {
        try {
          await client.query(`
            INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, 'avoid', $3)
            ON CONFLICT DO NOTHING
          `, [parseInt(conditionId), avoid.food_id, avoid.notes]);
          recommendationCount++;
          console.log(`   ✓ [${conditionId}] AVOID food ${avoid.food_id}`);
        } catch (e) {
          console.log(`   ✗ [${conditionId}] AVOID food ${avoid.food_id}: ${e.message}`);
        }
      }

      // Add recommend foods
      for (const recommend of data.recommend) {
        try {
          await client.query(`
            INSERT INTO conditionfoodrecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, 'recommend', $3)
            ON CONFLICT DO NOTHING
          `, [parseInt(conditionId), recommend.food_id, recommend.notes]);
          recommendationCount++;
          console.log(`   ✓ [${conditionId}] RECOMMEND food ${recommend.food_id}`);
        } catch (e) {
          console.log(`   ✗ [${conditionId}] RECOMMEND food ${recommend.food_id}: ${e.message}`);
        }
      }
    }

    console.log(`\n✅ Đã thêm ${recommendationCount} food recommendations`);

    // Step 2: Create Vietnamese dishes
    console.log('\n🍽️  BƯỚC 2: Tạo món ăn Việt Nam...\n');
    
    const dishInserts = [];
    const ingredientInserts = [];
    let dishIdStart = 1000; // Start from 1000 to avoid conflicts

    for (const [category, dishes] of Object.entries(VIETNAMESE_DISHES)) {
      for (const dish of dishes) {
        const dishId = dishIdStart++;
        
        // Insert dish
        dishInserts.push({
          dish_id: dishId,
          name: dish.name,
          vietnamese_name: dish.name,
          category: dish.category,
          serving_size_g: dish.servingSize,
          is_template: true,
          is_public: true,
        });

        // Insert ingredients
        dish.ingredients.forEach((foodId, index) => {
          ingredientInserts.push({
            dish_id: dishId,
            food_id: foodId,
            weight_g: Math.round(dish.servingSize / dish.ingredients.length),
            display_order: index
          });
        });

        console.log(`   ✓ Tạo dish ${dishId}: ${dish.name}`);
      }
    }

    console.log(`\n✅ Chuẩn bị ${dishInserts.length} dishes`);

    // Step 3: Insert dishes into database
    console.log('\n💾 BƯỚC 3: Insert dishes vào database...\n');
    
    for (const dish of dishInserts) {
      try {
        await client.query(`
          INSERT INTO dish (dish_id, name, vietnamese_name, category, serving_size_g, is_template, is_public, created_by_admin)
          VALUES ($1, $2, $3, $4, $5, $6, $7, 1)
          ON CONFLICT (dish_id) DO UPDATE SET
            name = EXCLUDED.name,
            vietnamese_name = EXCLUDED.vietnamese_name,
            category = EXCLUDED.category,
            serving_size_g = EXCLUDED.serving_size_g
        `, [dish.dish_id, dish.name, dish.vietnamese_name, dish.category, dish.serving_size_g, dish.is_template, dish.is_public]);
        console.log(`   ✓ Inserted dish ${dish.dish_id}: ${dish.name}`);
      } catch (e) {
        console.log(`   ✗ Error inserting dish ${dish.dish_id}: ${e.message}`);
      }
    }

    // Step 4: Insert dish ingredients
    console.log('\n🥘 BƯỚC 4: Thêm ingredients cho dishes...\n');
    
    for (const ing of ingredientInserts) {
      try {
        await client.query(`
          INSERT INTO dishingredient (dish_id, food_id, weight_g, display_order)
          VALUES ($1, $2, $3, $4)
          ON CONFLICT DO NOTHING
        `, [ing.dish_id, ing.food_id, ing.weight_g, ing.display_order]);
        console.log(`   ✓ Added ingredient: dish ${ing.dish_id} + food ${ing.food_id}`);
      } catch (e) {
        console.log(`   ✗ Error adding ingredient: ${e.message}`);
      }
    }

    console.log(`\n✅ Đã thêm ${ingredientInserts.length} dish ingredients`);

    // Step 5: Calculate dish nutrients based on food nutrients
    console.log('\n⚗️  BƯỚC 5: Tính toán dish nutrients...\n');
    
    for (const dish of dishInserts) {
      try {
        // Calculate nutrients for this dish
        const nutrients = await client.query(`
          SELECT 
            fn.nutrient_id,
            SUM(fn.amount_per_100g * di.weight_g / 100) as total_amount
          FROM dishingredient di
          JOIN foodnutrient fn ON di.food_id = fn.food_id
          WHERE di.dish_id = $1
          GROUP BY fn.nutrient_id
        `, [dish.dish_id]);

        let nutrientCount = 0;
        for (const nutrient of nutrients.rows) {
          try {
            await client.query(`
              INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_serving)
              VALUES ($1, $2, $3)
              ON CONFLICT (dish_id, nutrient_id) DO UPDATE SET
                amount_per_serving = EXCLUDED.amount_per_serving
            `, [dish.dish_id, nutrient.nutrient_id, nutrient.total_amount]);
            nutrientCount++;
          } catch (e) {
            // Ignore conflicts
          }
        }
        
        if (nutrientCount > 0) {
          console.log(`   ✓ Calculated ${nutrientCount} nutrients for dish ${dish.dish_id}`);
        }
      } catch (e) {
        console.log(`   ✗ Error calculating nutrients for dish ${dish.dish_id}: ${e.message}`);
      }
    }

    console.log('\n' + '='.repeat(80));
    console.log('\n🎉 HOÀN THÀNH!\n');
    console.log('📊 TÓM TẮT:');
    console.log(`   - Đã thêm ${recommendationCount} food recommendations`);
    console.log(`   - Đã tạo ${dishInserts.length} dishes mới`);
    console.log(`   - Đã thêm ${ingredientInserts.length} dish ingredients`);
    console.log('\n✅ Dữ liệu đã được import vào database!');

  } catch (err) {
    console.error('\n❌ ERROR:', err.message);
    console.error(err.stack);
  } finally {
    client.release();
    await pool.end();
  }
}

generateData();
