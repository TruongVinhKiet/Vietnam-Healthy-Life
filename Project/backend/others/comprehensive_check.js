const db = require('./db');

async function comprehensiveCheck() {
  console.log('=== KIỂM TRA TOÀN DIỆN HỆ THỐNG ===\n');
  
  const checks = {
    passed: [],
    failed: []
  };

  try {
    // 1. Check Dish table
    const dishCount = await db.query('SELECT COUNT(*) FROM dish');
    checks.passed.push(`✓ Dish table: ${dishCount.rows[0].count} records`);

    // 2. Check DishNotification table
    const notifCount = await db.query('SELECT COUNT(*) FROM dishnotification');
    checks.passed.push(`✓ DishNotification table: ${notifCount.rows[0].count} records`);

    // 3. Check Food table
    const foodCount = await db.query('SELECT COUNT(*) FROM food');
    checks.passed.push(`✓ Food table: ${foodCount.rows[0].count} records`);

    // 4. Check triggers
    const triggers = await db.query(`
      SELECT trigger_name 
      FROM information_schema.triggers 
      WHERE event_object_table IN ('dish', 'dishstatistics')
      ORDER BY trigger_name
    `);
    checks.passed.push(`✓ Dish triggers: ${triggers.rows.length} found`);
    triggers.rows.forEach(t => {
      checks.passed.push(`  - ${t.trigger_name}`);
    });

    // 5. Check image_urls column
    const imgCol = await db.query(`
      SELECT column_name 
      FROM information_schema.columns 
      WHERE table_name = 'dish' AND column_name = 'image_urls'
    `);
    if (imgCol.rows.length > 0) {
      checks.passed.push('✓ Image upload support: ENABLED');
    } else {
      checks.failed.push('✗ Image upload support: NOT FOUND');
    }

    // 6. Check API routes
    const fs = require('fs');
    const dishRoutes = fs.readFileSync('routes/dishes.js', 'utf8');
    const foodRoutes = fs.readFileSync('routes/foods.js', 'utf8');
    
    if (dishRoutes.includes('uploadDishImage')) {
      checks.passed.push('✓ Image upload routes: CONFIGURED');
    } else {
      checks.failed.push('✗ Image upload routes: MISSING');
    }

    if (foodRoutes.includes('router.get(\'/\'')) {
      checks.passed.push('✓ Food search API: CONFIGURED');
    } else {
      checks.failed.push('✗ Food search API: MISSING');
    }

    // 7. Check notifications API
    if (dishRoutes.includes('dishNotificationController')) {
      checks.passed.push('✓ Notification routes: CONFIGURED');
    } else {
      checks.failed.push('✗ Notification routes: MISSING');
    }

    // 8. Test dish with ingredients
    const dishWithIngredients = await db.query(`
      SELECT d.dish_id, d.vietnamese_name, COUNT(di.dish_ingredient_id) as ingredient_count
      FROM dish d
      LEFT JOIN dishingredient di ON d.dish_id = di.dish_id
      GROUP BY d.dish_id, d.vietnamese_name
      HAVING COUNT(di.dish_ingredient_id) > 0
      LIMIT 1
    `);
    
    if (dishWithIngredients.rows.length > 0) {
      const dish = dishWithIngredients.rows[0];
      checks.passed.push(`✓ Sample dish with ingredients: "${dish.vietnamese_name}" (${dish.ingredient_count} ingredients)`);
    } else {
      checks.failed.push('✗ No dishes with ingredients found');
    }

    // 9. Test nutrient calculation
    const dishNutrients = await db.query(`
      SELECT COUNT(*) FROM dishnutrient WHERE dish_id = 1
    `);
    if (parseInt(dishNutrients.rows[0].count) > 0) {
      checks.passed.push(`✓ Nutrient auto-calculation: WORKING (${dishNutrients.rows[0].count} nutrients for dish 1)`);
    } else {
      checks.failed.push('✗ Nutrient auto-calculation: NO DATA');
    }

    // 10. Check static file serving
    const indexJs = fs.readFileSync('index.js', 'utf8');
    if (indexJs.includes("app.use('/uploads'")) {
      checks.passed.push('✓ Static file serving: CONFIGURED');
    } else {
      checks.failed.push('✗ Static file serving: MISSING');
    }

  } catch (error) {
    checks.failed.push(`✗ Database error: ${error.message}`);
  }

  // Print results
  console.log('📊 PASSED CHECKS:');
  console.log('==================');
  checks.passed.forEach(check => console.log(check));

  if (checks.failed.length > 0) {
    console.log('\n⚠️  FAILED CHECKS:');
    console.log('==================');
    checks.failed.forEach(check => console.log(check));
  }

  console.log(`\n📈 Summary: ${checks.passed.length} passed, ${checks.failed.length} failed`);

  process.exit(checks.failed.length > 0 ? 1 : 0);
}

comprehensiveCheck();
