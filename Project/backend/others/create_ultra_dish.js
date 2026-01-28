const { pool } = require('./db/index');

async function createUltraDish() {
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    console.log('=== CREATING ULTRA FOOD & ULTRA DISH ===\n');

    // Step 1: Create Ultra Food
    console.log('1. Creating Ultra Food...');
    
    // Check if exists first
    const existingFood = await client.query(
      "SELECT food_id FROM food WHERE name = 'Ultra Food - Complete Nutrition'"
    );
    
    let ultraFoodId;
    if (existingFood.rows.length > 0) {
      ultraFoodId = existingFood.rows[0].food_id;
      console.log(`✅ Found existing: Ultra Food - Complete Nutrition (ID: ${ultraFoodId})\n`);
    } else {
      const foodResult = await client.query(`
        INSERT INTO food (name, category, image_url, created_by_admin)
        VALUES ('Ultra Food - Complete Nutrition', 'Test/Reference', NULL, 1)
        RETURNING food_id, name
      `);
      ultraFoodId = foodResult.rows[0].food_id;
      console.log(`✅ Created: ${foodResult.rows[0].name} (ID: ${ultraFoodId})\n`);
    }

    // Step 2: Get ALL nutrients from database
    console.log('2. Getting all nutrients from database...');
    const nutrientsResult = await client.query(`
      SELECT nutrient_id, name, nutrient_code, unit, group_name
      FROM nutrient
      ORDER BY group_name, name
    `);
    console.log(`✅ Found ${nutrientsResult.rows.length} nutrients\n`);

    // Step 3: Delete existing foodnutrient data for Ultra Food
    await client.query('DELETE FROM foodnutrient WHERE food_id = $1', [ultraFoodId]);
    console.log('3. Cleared old Ultra Food nutrient data\n');

    // Step 4: Insert 100% of all nutrients for Ultra Food
    console.log('4. Adding ALL nutrients to Ultra Food (100% coverage)...');
    const nutrientValues = [];
    
    for (const nutrient of nutrientsResult.rows) {
      // Set appropriate values based on nutrient type
      let amount;
      
      if (nutrient.nutrient_code === 'ENERC_KCAL') {
        amount = 500; // 500 calories per 100g
      } else if (nutrient.nutrient_code === 'PROCNT') {
        amount = 30; // 30g protein
      } else if (nutrient.nutrient_code === 'FAT') {
        amount = 20; // 20g fat
      } else if (nutrient.nutrient_code === 'CHOCDF') {
        amount = 40; // 40g carbs
      } else if (nutrient.nutrient_code === 'FIBTG') {
        amount = 10; // 10g fiber
      } else if (nutrient.group_name === 'Vitamins') {
        // Vitamins: 100-500% RDA
        if (nutrient.unit === 'µg') amount = 100;
        else if (nutrient.unit === 'mg') amount = 10;
        else if (nutrient.unit === 'IU') amount = 1000;
        else amount = 5;
      } else if (nutrient.group_name === 'Minerals') {
        // Minerals: 50-150% RDA
        if (nutrient.unit === 'µg') amount = 50;
        else if (nutrient.unit === 'mg') amount = 15;
        else amount = 10;
      } else if (nutrient.group_name === 'Amino acids') {
        // Amino acids: 1-3g each
        amount = 2.5;
      } else if (nutrient.group_name === 'Dietary Fiber') {
        // Fiber types: 1-5g
        amount = 3;
      } else if (nutrient.group_name === 'Fat / Fatty acids') {
        // Fatty acids
        if (nutrient.nutrient_code === 'CHOLESTEROL') amount = 50; // mg
        else if (nutrient.nutrient_code === 'FASAT') amount = 5; // SFA
        else if (nutrient.nutrient_code === 'FAMS') amount = 8; // MUFA
        else if (nutrient.nutrient_code === 'FAPU') amount = 4; // PUFA
        else amount = 1; // Other fatty acids
      } else {
        amount = 5; // Default
      }

      nutrientValues.push({
        nutrient_id: nutrient.nutrient_id,
        name: nutrient.name,
        code: nutrient.nutrient_code,
        amount: amount.toFixed(2)
      });

      await client.query(
        'INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES ($1, $2, $3)',
        [ultraFoodId, nutrient.nutrient_id, amount]
      );
    }

    console.log(`✅ Added ${nutrientValues.length} nutrients to Ultra Food\n`);

    // Display sample nutrients by group
    const groups = {};
    nutrientValues.forEach(n => {
      const group = nutrientsResult.rows.find(nr => nr.nutrient_id === n.nutrient_id)?.group_name || 'Macros';
      if (!groups[group]) groups[group] = [];
      groups[group].push(n);
    });

    console.log('📊 Nutrient Coverage Summary:');
    Object.entries(groups).forEach(([group, nutrients]) => {
      console.log(`   ${group}: ${nutrients.length} nutrients`);
    });
    console.log();

    // Step 5: Create Ultra Dish
    console.log('5. Creating Ultra Dish...');
    
    // Check if exists first
    const existingDish = await client.query(
      "SELECT dish_id FROM dish WHERE name = 'Ultra Dish - Complete Test'"
    );
    
    let ultraDishId;
    if (existingDish.rows.length > 0) {
      ultraDishId = existingDish.rows[0].dish_id;
      console.log(`✅ Found existing: Ultra Dish - Complete Test (ID: ${ultraDishId})\n`);
      
      // Update description and category
      await client.query(`
        UPDATE dish 
        SET description = 'Món ăn test chứa Ultra Food với đầy đủ 100% tất cả chất dinh dưỡng có trong hệ thống. Dùng để kiểm tra hiển thị nutrient UI.',
            vietnamese_name = 'Món Ăn Ultra - Test Đầy Đủ',
            category = 'test'
        WHERE dish_id = $1
      `, [ultraDishId]);
    } else {
      const dishResult = await client.query(`
        INSERT INTO dish (name, vietnamese_name, category, description, serving_size_g, image_url, created_by_admin)
        VALUES (
          'Ultra Dish - Complete Test',
          'Món Ăn Ultra - Test Đầy Đủ',
          'test',
          'Món ăn test chứa Ultra Food với đầy đủ 100% tất cả chất dinh dưỡng có trong hệ thống. Dùng để kiểm tra hiển thị nutrient UI.',
          300,
          NULL,
          1
        )
        RETURNING dish_id, vietnamese_name
      `);
      ultraDishId = dishResult.rows[0].dish_id;
      console.log(`✅ Created: ${dishResult.rows[0].vietnamese_name} (ID: ${ultraDishId})\n`);
    }

    // Step 6: Add Ultra Food as ingredient
    console.log('6. Adding Ultra Food to Ultra Dish...');
    await client.query('DELETE FROM dishingredient WHERE dish_id = $1', [ultraDishId]);
    await client.query(`
      INSERT INTO dishingredient (dish_id, food_id, weight_g)
      VALUES ($1, $2, 300)
    `, [ultraDishId, ultraFoodId]);
    console.log('✅ Added 300g of Ultra Food to Ultra Dish\n');

    // Step 7: Verify nutrient count
    const verifyResult = await client.query(`
      SELECT COUNT(*) as nutrient_count
      FROM dishnutrient
      WHERE dish_id = $1
    `, [ultraDishId]);
    
    console.log(`7. Verifying dish nutrients...`);
    console.log(`✅ Ultra Dish has ${verifyResult.rows[0].nutrient_count} nutrients calculated\n`);

    await client.query('COMMIT');

    console.log('=== SUCCESS ===');
    console.log(`\n🎉 Ultra Dish created successfully!`);
    console.log(`   - Food ID: ${ultraFoodId}`);
    console.log(`   - Dish ID: ${ultraDishId}`);
    console.log(`   - Total Nutrients: ${nutrientValues.length}`);
    console.log(`\n✅ You can now test in Admin Dashboard:`);
    console.log(`   1. View "Món Ăn Ultra - Test Đầy Đủ" in dish list`);
    console.log(`   2. Click "Xem chi tiết" to see ALL ${nutrientValues.length} nutrients`);
    console.log(`   3. Expand each nutrient group to verify complete coverage\n`);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error creating Ultra Dish:', error.message);
    console.error(error);
    throw error;
  } finally {
    client.release();
  }
}

// Run if called directly
if (require.main === module) {
  createUltraDish()
    .then(() => {
      console.log('Script completed successfully!');
      process.exit(0);
    })
    .catch(error => {
      console.error('Script failed:', error);
      process.exit(1);
    });
}

module.exports = { createUltraDish };
