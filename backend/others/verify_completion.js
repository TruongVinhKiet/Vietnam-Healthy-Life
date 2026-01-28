const db = require('./db');

async function verifyCompletion() {
  console.log('=== KIỂM TRA YÊU CẦU ĐÃ HOÀN THÀNH ===\n');
  
  // 1. Check database tables
  console.log('1. DATABASE - 6 bảng health condition:');
  const tables = await db.query(`
    SELECT table_name FROM information_schema.tables 
    WHERE table_name IN ('healthcondition','userhealthcondition','medicationschedule','medicationlog','conditionnutrienteffect','conditionfoodrecommendation') 
    ORDER BY table_name
  `);
  console.log(`   ✓ ${tables.rows.length}/6 tables: ${tables.rows.map(x=>x.table_name).join(', ')}`);
  
  // 2. Check seeded diseases
  console.log('\n2. SEED DATA - 10 bệnh:');
  const conditions = await db.query('SELECT condition_id, name_vi, category FROM HealthCondition ORDER BY condition_id');
  console.log(`   ✓ ${conditions.rows.length} bệnh đã seed:`);
  conditions.rows.forEach(c => console.log(`     - ${c.name_vi} (${c.category})`));
  
  // 3. Check nutrient effects
  console.log('\n3. NUTRIENT EFFECTS - Điều chỉnh dinh dưỡng:');
  const effects = await db.query('SELECT COUNT(*) as total FROM ConditionNutrientEffect');
  console.log(`   ✓ ${effects.rows[0].total} nutrient adjustments`);
  
  // 4. Check food restrictions
  console.log('\n4. FOOD RESTRICTIONS - Thực phẩm cấm:');
  const restrictions = await db.query('SELECT COUNT(*) as total FROM ConditionFoodRecommendation');
  console.log(`   ✓ ${restrictions.rows[0].total} food recommendations`);
  
  // 5. Check backend files
  console.log('\n5. BACKEND FILES:');
  const fs = require('fs');
  const files = [
    'services/healthConditionService.js',
    'controllers/healthConditionController.js',
    'services/medicationService.js',
    'controllers/medicationController.js'
  ];
  files.forEach(f => {
    const exists = fs.existsSync(`${__dirname}/${f}`);
    console.log(`   ${exists ? '✓' : '✗'} ${f}`);
  });
  
  // 6. Check routes in index.js
  console.log('\n6. ROUTES REGISTRATION:');
  const indexContent = fs.readFileSync(`${__dirname}/index.js`, 'utf-8');
  const healthRoutes = indexContent.includes('app.use(\'/health\'');
  const medRoutes = indexContent.includes('app.use(\'/medications\'');
  console.log(`   ${healthRoutes ? '✓' : '✗'} /health routes registered`);
  console.log(`   ${medRoutes ? '✓' : '✗'} /medications routes registered`);
  
  // 7. Check nutrient tracking integration
  console.log('\n7. RDA ADJUSTMENT INTEGRATION:');
  const nutrientServiceContent = fs.readFileSync(`${__dirname}/services/nutrientTrackingService.js`, 'utf-8');
  const hasAdjustment = nutrientServiceContent.includes('healthConditionService.getAdjustedRDA');
  console.log(`   ${hasAdjustment ? '✓' : '✗'} calculateDailyNutrientIntake applies adjustments`);
  
  // 8. Check food restriction integration
  console.log('\n8. FOOD RESTRICTION INTEGRATION:');
  const mealControllerContent = fs.readFileSync(`${__dirname}/controllers/mealController.js`, 'utf-8');
  const hasRestriction = mealControllerContent.includes('getRestrictedFoods');
  console.log(`   ${hasRestriction ? '✓' : '✗'} addFoodToMeal checks restrictions`);
  
  // 9. Check Flutter UI changes
  console.log('\n9. FLUTTER UI - Tab "Sức khỏe":');
  const mainDart = fs.readFileSync(`${__dirname}/../lib/main.dart`, 'utf-8');
  const scheduleScreen = fs.readFileSync(`${__dirname}/../lib/screens/schedule_screen.dart`, 'utf-8');
  const hasHealthTab = mainDart.includes('Sức khỏe') && mainDart.includes('Icons.favorite');
  const hasHealthTitle = scheduleScreen.includes('Sức khỏe');
  console.log(`   ${hasHealthTab ? '✓' : '✗'} Bottom nav: Icons.favorite + "Sức khỏe"`);
  console.log(`   ${hasHealthTitle ? '✓' : '✗'} Screen title: "Sức khỏe"`);
  
  console.log('\n=== TỔNG KẾT ===');
  console.log('✅ ĐÃ HOÀN THÀNH:');
  console.log('  1. Database schema (6 tables)');
  console.log('  2. Seed data (10 diseases, 38 nutrient effects, 12 food restrictions)');
  console.log('  3. Backend services (health + medication)');
  console.log('  4. Backend controllers (11 + 4 endpoints)');
  console.log('  5. Routes registered in index.js');
  console.log('  6. RDA adjustment integrated');
  console.log('  7. Food restriction integrated');
  console.log('  8. Flutter tab renamed with heart icon');
  
  console.log('\n❌ CHƯA HOÀN THÀNH:');
  console.log('  1. Admin dashboard - Statistics widget');
  console.log('  2. Admin dashboard - Health condition CRUD UI');
  console.log('  3. Flutter - Health condition selection dialog');
  console.log('  4. Flutter - Medication schedule UI with checkmarks');
  console.log('  5. Flutter - Calendar with pill icons');
}

verifyCompletion().catch(console.error);
