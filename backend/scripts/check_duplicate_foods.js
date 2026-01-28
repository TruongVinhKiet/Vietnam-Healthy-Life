const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function checkDuplicateFoods() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('KIỂM TRA THỰC PHẨM TRÙNG TÊN TRONG BẢNG FOOD');
    console.log('='.repeat(80));

    // Find duplicate food names
    const duplicatesQuery = `
      SELECT 
        LOWER(TRIM(name)) as normalized_name,
        COUNT(*) as count,
        ARRAY_AGG(food_id ORDER BY food_id) as food_ids,
        ARRAY_AGG(name ORDER BY food_id) as names,
        ARRAY_AGG(category ORDER BY food_id) as categories
      FROM food
      GROUP BY LOWER(TRIM(name))
      HAVING COUNT(*) > 1
      ORDER BY COUNT(*) DESC, normalized_name;
    `;

    const duplicates = await client.query(duplicatesQuery);
    
    console.log(`\n📊 Tổng số nhóm thực phẩm trùng tên: ${duplicates.rows.length}\n`);

    if (duplicates.rows.length === 0) {
      console.log('✓ Không có thực phẩm trùng tên!');
      return;
    }

    // For each duplicate group, check which ones are used
    const detailedResults = [];
    
    for (const dup of duplicates.rows) {
      console.log('-'.repeat(80));
      console.log(`📝 Tên: "${dup.names[0]}" (${dup.count} bản ghi)`);
      console.log(`   IDs: ${dup.food_ids.join(', ')}`);
      
      const usageDetails = [];
      
      for (let i = 0; i < dup.food_ids.length; i++) {
        const foodId = dup.food_ids[i];
        
        // Check usage in various tables
        const usageQuery = `
          SELECT 
            (SELECT COUNT(*) FROM mealitem WHERE food_id = $1) as meal_item_count,
            (SELECT COUNT(*) FROM foodnutrient WHERE food_id = $1) as food_nutrient_count,
            (SELECT COUNT(*) FROM dishingredient WHERE food_id = $1) as dish_ingredient_count,
            (SELECT COUNT(*) FROM conditionfoodrecommendation WHERE food_id = $1) as condition_food_count,
            (SELECT category FROM food WHERE food_id = $1) as category;
        `;
        
        const usage = await client.query(usageQuery, [foodId]);
        const u = usage.rows[0];
        
        const totalUsage = parseInt(u.meal_item_count) + 
                          parseInt(u.food_nutrient_count) + 
                          parseInt(u.dish_ingredient_count) + 
                          parseInt(u.condition_food_count);
        
        usageDetails.push({
          food_id: foodId,
          name: dup.names[i],
          category: u.category,
          total_usage: totalUsage,
          meal_items: parseInt(u.meal_item_count),
          nutrients: parseInt(u.food_nutrient_count),
          dish_ingredients: parseInt(u.dish_ingredient_count),
          condition_foods: parseInt(u.condition_food_count)
        });
        
        console.log(`   [${foodId}] Category: ${u.category || 'N/A'}`);
        console.log(`        - MealItem: ${u.meal_item_count}`);
        console.log(`        - FoodNutrient: ${u.food_nutrient_count}`);
        console.log(`        - DishIngredient: ${u.dish_ingredient_count}`);
        console.log(`        - ConditionFood: ${u.condition_food_count}`);
        console.log(`        - TỔNG: ${totalUsage} ${totalUsage === 0 ? '⚠️  CÓ THỂ XÓA' : '✓ ĐANG DÙNG'}`);
      }
      
      detailedResults.push({
        name: dup.names[0],
        normalized_name: dup.normalized_name,
        count: dup.count,
        details: usageDetails
      });
    }

    // Summary and recommendations
    console.log('\n' + '='.repeat(80));
    console.log('📋 TÓM TẮT VÀ KHUYẾN NGHỊ');
    console.log('='.repeat(80));

    let totalCanDelete = 0;
    const deleteRecommendations = [];

    for (const result of detailedResults) {
      const unused = result.details.filter(d => d.total_usage === 0);
      const used = result.details.filter(d => d.total_usage > 0);
      
      if (unused.length > 0) {
        console.log(`\n"${result.name}": ${result.count} bản ghi, ${unused.length} không dùng, ${used.length} đang dùng`);
        
        if (used.length > 0) {
          console.log(`  ✓ Giữ lại: [${used.map(u => u.food_id).join(', ')}]`);
        }
        
        if (unused.length > 0) {
          console.log(`  ⚠️  Có thể xóa: [${unused.map(u => u.food_id).join(', ')}]`);
          totalCanDelete += unused.length;
          deleteRecommendations.push({
            name: result.name,
            ids_to_delete: unused.map(u => u.food_id)
          });
        }
      } else if (result.count > 1 && used.length > 1) {
        // All duplicates are in use - need manual review
        console.log(`\n⚠️  "${result.name}": TẤT CẢ ${result.count} bản ghi đều đang được sử dụng`);
        console.log(`  🔍 Cần xem xét thủ công để quyết định giữ bản ghi nào`);
        result.details.forEach(d => {
          console.log(`     [${d.food_id}] ${d.category}: ${d.total_usage} lần sử dụng`);
        });
      }
    }

    console.log(`\n📊 Tổng số bản ghi có thể xóa an toàn: ${totalCanDelete}`);

    // Generate DELETE script
    if (deleteRecommendations.length > 0) {
      console.log('\n' + '='.repeat(80));
      console.log('🗑️  SCRIPT XÓA DỮ LIỆU TRÙNG (CHỈ XÓA CÁC BẢN GHI KHÔNG DÙNG)');
      console.log('='.repeat(80));
      console.log('\n-- Backup trước khi chạy:');
      console.log('-- pg_dump -U postgres -d Health -t Food > food_backup.sql\n');
      
      const allIdsToDelete = deleteRecommendations.flatMap(r => r.ids_to_delete);
      
      console.log('BEGIN;');
      console.log(`-- Xóa ${totalCanDelete} thực phẩm trùng tên không được sử dụng`);
      console.log(`DELETE FROM food WHERE food_id IN (${allIdsToDelete.join(', ')});`);
      console.log('COMMIT;\n');

      // Also save to file
      const fs = require('fs');
      const scriptPath = require('path').join(__dirname, 'delete_duplicate_foods.sql');
      const scriptContent = `-- Generated: ${new Date().toISOString()}
-- Xóa ${totalCanDelete} thực phẩm trùng tên không được sử dụng

BEGIN;

DELETE FROM food WHERE food_id IN (${allIdsToDelete.join(', ')});

-- Verify
SELECT COUNT(*) as deleted_count FROM food WHERE food_id IN (${allIdsToDelete.join(', ')});

COMMIT;
`;
      
      fs.writeFileSync(scriptPath, scriptContent);
      console.log(`✓ Script đã được lưu tại: ${scriptPath}`);
    }

  } catch (error) {
    console.error('❌ Lỗi:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

checkDuplicateFoods();
