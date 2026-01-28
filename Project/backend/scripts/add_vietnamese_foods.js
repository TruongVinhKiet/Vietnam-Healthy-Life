const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

// ============================================================================
// VIETNAMESE FOODS TO ADD - Based on commonly used ingredients
// ============================================================================

const VIETNAMESE_FOODS = [
  // MEATS & PROTEINS
  { name: 'Thịt heo nạc', name_vi: 'Thịt heo nạc', category: 'protein', 
    nutrients: {1:143, 2:20.5, 3:6.3, 10:60, 29:0.9, 30:2.0} },
  { name: 'Thịt bò nạc', name_vi: 'Thịt bò nạc', category: 'protein',
    nutrients: {1:177, 2:20.0, 3:10.2, 10:62, 23:2.6, 29:2.6, 30:4.5} },
  { name: 'Thịt vịt', name_vi: 'Thịt vịt', category: 'protein',
    nutrients: {1:132, 2:18.3, 3:5.9, 10:84, 23:0.9, 29:2.3} },
  { name: 'Cá rô phi', name_vi: 'Cá rô phi', category: 'protein',
    nutrients: {1:96, 2:20.1, 3:1.7, 10:50, 23:1.5, 29:0.6, 34:38} },
  { name: 'Cá tra', name_vi: 'Cá tra', category: 'protein',
    nutrients: {1:105, 2:16.4, 3:3.7, 10:47, 23:1.5} },
  { name: 'Cá chép', name_vi: 'Cá chép', category: 'protein',
    nutrients: {1:127, 2:17.8, 3:5.6, 10:66, 23:1.5, 29:1.2} },
  { name: 'Cá thu', name_vi: 'Cá thu', category: 'protein',
    nutrients: {1:139, 2:18.6, 3:6.3, 10:53, 23:8.8} },
  { name: 'Tôm sú', name_vi: 'Tôm sú', category: 'protein',
    nutrients: {1:106, 2:20.3, 3:1.7, 10:152, 34:38, 30:1.1} },
  { name: 'Tôm thẻ', name_vi: 'Tôm thẻ', category: 'protein',
    nutrients: {1:99, 2:20.9, 3:1.1, 10:161, 34:33} },
  { name: 'Mực ống', name_vi: 'Mực ống', category: 'protein',
    nutrients: {1:92, 2:15.6, 3:1.4, 10:233, 34:44} },
  { name: 'Nghêu', name_vi: 'Nghêu', category: 'protein',
    nutrients: {1:86, 2:14.0, 3:1.0, 10:40, 29:28} },
  
  // VEGETABLES
  { name: 'Rau dền', name_vi: 'Rau dền', category: 'vegetables',
    nutrients: {1:23, 2:2.3, 3:0.3, 4:4.0, 5:2.0, 11:2917, 15:43, 24:215, 29:2.3} },
  { name: 'Bí đỏ', name_vi: 'Bí đỏ', category: 'vegetables',
    nutrients: {1:26, 2:1.0, 3:0.1, 4:6.5, 5:0.5, 11:8510, 15:9, 27:340} },
  { name: 'Bí đao', name_vi: 'Bí đao', category: 'vegetables',
    nutrients: {1:13, 2:0.6, 3:0.1, 4:3.0, 5:0.5, 15:13, 27:150} },
  { name: 'Cà rốt', name_vi: 'Cà rốt', category: 'vegetables',
    nutrients: {1:41, 2:0.9, 3:0.2, 4:9.6, 5:2.8, 11:16706, 15:5.9, 24:33, 27:320} },
  { name: 'Khoai lang', name_vi: 'Khoai lang', category: 'vegetables',
    nutrients: {1:86, 2:1.6, 3:0.1, 4:20.1, 5:3.0, 11:14187, 15:2.4, 27:337} },
  { name: 'Khoai tây', name_vi: 'Khoai tây', category: 'vegetables',
    nutrients: {1:77, 2:2.0, 3:0.1, 4:17.5, 5:2.1, 15:19.7, 27:421} },
  { name: 'Cải bắp', name_vi: 'Cải bắp', category: 'vegetables',
    nutrients: {1:25, 2:1.3, 3:0.1, 4:5.8, 5:2.5, 15:36.6, 24:40, 27:170} },
  { name: 'Bắp cải tím', name_vi: 'Bắp cải tím', category: 'vegetables',
    nutrients: {1:31, 2:1.4, 3:0.2, 4:7.4, 5:2.1, 15:57, 24:45, 27:243} },
  { name: 'Cải ngọt', name_vi: 'Cải ngọt', category: 'vegetables',
    nutrients: {1:20, 2:2.0, 3:0.3, 4:3.2, 5:1.8, 11:3500, 15:30, 24:100, 29:1.5} },
  { name: 'Cải xanh', name_vi: 'Cải xanh', category: 'vegetables',
    nutrients: {1:13, 2:1.5, 3:0.2, 4:2.2, 5:1.0, 11:4000, 15:45, 24:105} },
  { name: 'Su su', name_vi: 'Su su', category: 'vegetables',
    nutrients: {1:19, 2:0.8, 3:0.1, 4:4.5, 5:1.7, 15:7.7, 27:125} },
  { name: 'Mướp đắng', name_vi: 'Mướp đắng (Khổ qua)', category: 'vegetables',
    nutrients: {1:17, 2:1.0, 3:0.2, 4:3.7, 5:2.8, 15:84, 27:296} },
  { name: 'Ớt chuông', name_vi: 'Ớt chuông', category: 'vegetables',
    nutrients: {1:31, 2:1.0, 3:0.3, 4:6.0, 5:2.1, 11:3131, 15:127.7, 27:211} },
  { name: 'Đậu cove', name_vi: 'Đậu cove', category: 'vegetables',
    nutrients: {1:31, 2:2.8, 3:0.2, 4:5.7, 5:2.6, 15:12.2, 27:260} },
  { name: 'Đậu đũa', name_vi: 'Đậu đũa', category: 'vegetables',
    nutrients: {1:31, 2:1.8, 3:0.1, 4:7.1, 5:2.7, 15:16.3, 27:209} },
  
  // LEGUMES & SOY
  { name: 'Đậu phụ non', name_vi: 'Đậu phụ non (Tàu hủ)', category: 'protein',
    nutrients: {1:55, 2:5.3, 3:2.7, 4:2.9, 24:200, 29:2.2} },
  { name: 'Đậu xanh', name_vi: 'Đậu xanh', category: 'grains',
    nutrients: {1:105, 2:7.0, 3:0.4, 4:19.0, 5:7.6, 22:159, 29:1.4} },
  { name: 'Đậu đen', name_vi: 'Đậu đen', category: 'grains',
    nutrients: {1:132, 2:8.9, 3:0.5, 4:23.7, 5:8.7, 22:149, 29:2.1} },
  { name: 'Đậu đỏ', name_vi: 'Đậu đỏ (Đậu ván)', category: 'grains',
    nutrients: {1:127, 2:8.7, 3:0.5, 4:22.8, 5:7.4, 22:230, 29:2.9} },
  
  // FRUITS
  { name: 'Chuối tiêu', name_vi: 'Chuối tiêu', category: 'fruits',
    nutrients: {1:89, 2:1.1, 3:0.3, 4:22.8, 5:2.6, 15:8.7, 27:358} },
  { name: 'Quýt', name_vi: 'Quýt', category: 'fruits',
    nutrients: {1:53, 2:0.8, 3:0.3, 4:13.3, 5:1.8, 15:26.7, 27:166} },
  { name: 'Đu đủ', name_vi: 'Đu đủ (Papaya)', category: 'fruits',
    nutrients: {1:43, 2:0.5, 3:0.3, 4:11.0, 5:1.7, 11:950, 15:60.9, 27:182} },
  { name: 'Ổi', name_vi: 'Ổi', category: 'fruits',
    nutrients: {1:68, 2:2.6, 3:1.0, 4:14.3, 5:5.4, 15:228.3, 24:18, 27:417} },
  { name: 'Bưởi', name_vi: 'Bưởi', category: 'fruits',
    nutrients: {1:42, 2:0.8, 3:0.04, 4:10.7, 5:1.0, 15:61.0, 27:135} },
  { name: 'Nhãn', name_vi: 'Nhãn', category: 'fruits',
    nutrients: {1:60, 2:1.3, 3:0.1, 4:15.1, 5:1.1, 15:84, 27:266} },
  { name: 'Vải thiều', name_vi: 'Vải', category: 'fruits',
    nutrients: {1:66, 2:0.8, 3:0.4, 4:16.5, 5:1.3, 15:71.5, 27:171} },
  { name: 'Măng cụt', name_vi: 'Măng cụt', category: 'fruits',
    nutrients: {1:73, 2:0.4, 3:0.6, 4:17.9, 5:1.8, 15:2.9, 27:48} },
  { name: 'Chôm chôm', name_vi: 'Chôm chôm', category: 'fruits',
    nutrients: {1:82, 2:0.7, 3:0.2, 4:20.9, 5:0.9, 15:4.9, 27:42} },
  { name: 'Chanh', name_vi: 'Chanh', category: 'fruits',
    nutrients: {1:29, 2:1.1, 3:0.3, 4:9.3, 5:2.8, 15:53, 27:138, 24:26} },
  
  // GRAINS
  { name: 'Gạo lứt', name_vi: 'Gạo lứt', category: 'grains',
    nutrients: {1:111, 2:2.6, 3:0.9, 4:23.0, 5:1.8, 26:43, 25:162} },
  { name: 'Gạo nếp', name_vi: 'Gạo nếp', category: 'grains',
    nutrients: {1:97, 2:2.0, 3:0.2, 4:21.1, 5:0.9, 26:3, 25:26} },
  { name: 'Yến mạch', name_vi: 'Yến mạch', category: 'grains',
    nutrients: {1:68, 2:2.4, 3:1.4, 4:12.0, 5:1.7, 26:10, 25:77} },
  { name: 'Bột mì nguyên cám', name_vi: 'Bột mì nguyên cám', category: 'grains',
    nutrients: {1:340, 2:13.2, 3:2.5, 4:72.0, 5:10.7, 26:137, 25:346, 29:3.6} },
  { name: 'Bột gạo', name_vi: 'Bột gạo', category: 'grains',
    nutrients: {1:366, 2:6.0, 3:1.4, 4:80.1, 5:2.4, 26:10, 25:98} },
  { name: 'Bún tươi', name_vi: 'Bún', category: 'grains',
    nutrients: {1:109, 2:1.8, 3:0.2, 4:25.0, 5:0.7, 26:7, 25:43} },
  { name: 'Bánh phở', name_vi: 'Bánh phở', category: 'grains',
    nutrients: {1:109, 2:1.6, 3:0.1, 4:25.9, 5:0.5, 26:6, 25:38} },
  { name: 'Ngô', name_vi: 'Ngô (Bắp)', category: 'grains',
    nutrients: {1:86, 2:3.3, 3:1.4, 4:18.7, 5:2.0, 26:37, 25:89} },
  { name: 'Khoai mì', name_vi: 'Khoai mì (Sắn)', category: 'grains',
    nutrients: {1:160, 2:1.4, 3:0.3, 4:38.1, 5:1.8, 27:271, 26:21} },
  { name: 'Khoai môn', name_vi: 'Khoai môn', category: 'grains',
    nutrients: {1:112, 2:1.5, 3:0.2, 4:26.5, 5:4.1, 27:591, 26:33, 24:43} },
  
  // SEASONINGS & OTHERS
  { name: 'Hành tây', name_vi: 'Hành tây', category: 'vegetables',
    nutrients: {1:40, 2:1.1, 3:0.1, 4:9.3, 5:1.7, 15:7.4, 27:146} },
  { name: 'Tỏi', name_vi: 'Tỏi', category: 'vegetables',
    nutrients: {1:149, 2:6.4, 3:0.5, 4:33.1, 5:2.1, 15:31.2, 27:401, 24:181} },
  { name: 'Gừng', name_vi: 'Gừng', category: 'vegetables',
    nutrients: {1:80, 2:1.8, 3:0.8, 4:17.8, 5:2.0, 15:5, 27:415} },
  { name: 'Nấm rơm', name_vi: 'Nấm rơm', category: 'vegetables',
    nutrients: {1:35, 2:3.1, 3:0.3, 4:6.5, 5:2.3, 25:86, 27:356} },
  { name: 'Mè rang', name_vi: 'Mè (Vừng)', category: 'grains',
    nutrients: {1:573, 2:17.7, 3:49.7, 4:23.4, 5:11.8, 24:975, 29:14.6} },
  { name: 'Hạt điều', name_vi: 'Hạt điều', category: 'grains',
    nutrients: {1:553, 2:18.2, 3:43.8, 4:30.2, 5:3.3, 26:292, 30:5.8} },
  { name: 'Đậu phộng', name_vi: 'Đậu phộng (Lạc)', category: 'grains',
    nutrients: {1:567, 2:25.8, 3:49.2, 4:16.1, 5:8.5, 26:168, 29:4.6} },
  
  // DAIRY & OILS
  { name: 'Sữa bò', name_vi: 'Sữa tươi nguyên chất', category: 'dairy',
    nutrients: {1:61, 2:3.2, 3:3.3, 4:4.8, 24:113, 25:84, 27:143} },
  { name: 'Sữa dê', name_vi: 'Sữa dê', category: 'dairy',
    nutrients: {1:69, 2:3.6, 3:4.1, 4:4.5, 24:134, 25:111, 27:204} },
  { name: 'Sữa đậu nành', name_vi: 'Sữa đậu nành', category: 'dairy',
    nutrients: {1:33, 2:2.9, 3:1.6, 4:1.7, 24:25, 29:0.5} },
  { name: 'Bơ thực vật', name_vi: 'Bơ thực vật', category: 'oils',
    nutrients: {1:717, 2:0.9, 3:81.0, 4:0.1, 11:819} },
  { name: 'Dầu ô liu', name_vi: 'Dầu ô liu', category: 'oils',
    nutrients: {1:884, 2:0, 3:100, 4:0, 38:73.0, 39:10.5} },
  { name: 'Dầu đậu nành', name_vi: 'Dầu đậu nành', category: 'oils',
    nutrients: {1:884, 2:0, 3:100, 4:0, 38:23.3, 39:57.7, 40:15.6} },
  { name: 'Trứng vịt', name_vi: 'Trứng vịt', category: 'protein',
    nutrients: {1:185, 2:13.0, 3:13.8, 4:1.5, 10:884, 23:3.8, 24:64, 29:3.8} },
  { name: 'Gạo tẻ trắng', name_vi: 'Gạo trắng', category: 'grains',
    nutrients: {1:130, 2:2.7, 3:0.3, 4:28.2, 5:0.4, 26:25, 25:115} },
];

async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'Health',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'Kiet2004',
  });

  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('🚀 Adding Vietnamese foods to database...\n');

    let foodCount = 0;
    let nutrientCount = 0;
    const addedFoodIds = [];

    for (const food of VIETNAMESE_FOODS) {
      // Check if food already exists
      const existingFood = await client.query(
        'SELECT food_id FROM food WHERE name = $1 OR name_vi = $2',
        [food.name, food.name_vi]
      );

      let foodId;
      if (existingFood.rows.length > 0) {
        console.log(`⏭️  Food already exists: ${food.name_vi}`);
        foodId = existingFood.rows[0].food_id;
      } else {
        // Insert new food
        const result = await client.query(
          `INSERT INTO food (name, name_vi, category, created_at, updated_at)
           VALUES ($1, $2, $3, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
           RETURNING food_id`,
          [food.name, food.name_vi, food.category]
        );
        foodId = result.rows[0].food_id;
        addedFoodIds.push({ id: foodId, name: food.name_vi });
        foodCount++;
        console.log(`✅ Added: ${food.name_vi} (ID: ${foodId})`);
      }

      // Insert nutrients
      for (const [nutrientId, amount] of Object.entries(food.nutrients)) {
        await client.query(
          `INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g)
           VALUES ($1, $2, $3)
           ON CONFLICT (food_id, nutrient_id) DO UPDATE SET amount_per_100g = $3`,
          [foodId, parseInt(nutrientId), amount]
        );
        nutrientCount++;
      }
    }

    console.log(`\n📊 Summary:`);
    console.log(`✅ Added ${foodCount} new foods`);
    console.log(`✅ Updated ${nutrientCount} nutrient entries`);

    if (addedFoodIds.length > 0) {
      console.log(`\n🆕 New food IDs:`);
      addedFoodIds.forEach(food => {
        console.log(`   ${food.id}: ${food.name}`);
      });
    }

    // Verify total foods
    const totalResult = await client.query('SELECT COUNT(*) FROM food');
    console.log(`\n📈 Total foods in database: ${totalResult.rows[0].count}`);

    await client.query('COMMIT');
    console.log('\n✅ Vietnamese foods added successfully! 🎉');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
