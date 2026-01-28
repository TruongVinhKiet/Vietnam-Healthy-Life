/**
 * Test script for Daily Meal Suggestion Service
 */

const pool = require('./db');
const dailyMealSuggestionService = require('./services/dailyMealSuggestionService');

async function testService() {
  try {
    console.log('=== Testing Daily Meal Suggestion Service ===\n');

    // Step 1: Check if we have users
    console.log('Step 1: Finding test user...');
    const userResult = await pool.query(`
      SELECT u.user_id, u.age, u.gender, u.weight_kg, u.height_cm, u.email
      FROM "User" u
      WHERE u.age IS NOT NULL 
        AND u.gender IS NOT NULL 
        AND u.weight_kg IS NOT NULL 
        AND u.height_cm IS NOT NULL
      LIMIT 1
    `);

    if (userResult.rows.length === 0) {
      console.log('❌ No valid user found with complete profile.');
      console.log('Please ensure at least one user has age, gender, weight, and height set.');
      return;
    }

    const testUser = userResult.rows[0];
    console.log(`✅ Found test user: ${testUser.email} (ID: ${testUser.user_id})`);
    console.log(`   Age: ${testUser.age}, Gender: ${testUser.gender}, Weight: ${testUser.weight_kg}kg, Height: ${testUser.height_cm}cm\n`);

    // Step 2: Check if user has requirement data
    console.log('Step 2: Checking user requirements...');
    const vitaminReqResult = await pool.query(`
      SELECT COUNT(*) as count FROM uservitaminrequirement WHERE user_id = $1
    `, [testUser.user_id]);
    
    const mineralReqResult = await pool.query(`
      SELECT COUNT(*) as count FROM usermineralrequirement WHERE user_id = $1
    `, [testUser.user_id]);

    console.log(`   Vitamin requirements: ${vitaminReqResult.rows[0].count}`);
    console.log(`   Mineral requirements: ${mineralReqResult.rows[0].count}`);

    if (vitaminReqResult.rows[0].count === 0 && mineralReqResult.rows[0].count === 0) {
      console.log('⚠️  User has no requirement data. Trying to populate...');
      
      // Try to refresh requirements
      await pool.query(`SELECT refresh_user_vitamin_requirements($1)`, [testUser.user_id]);
      await pool.query(`SELECT refresh_user_mineral_requirements($1)`, [testUser.user_id]);
      
      console.log('✅ Requirements refreshed\n');
    } else {
      console.log('✅ User has requirement data\n');
    }

    // Step 3: Generate meal suggestions
    console.log('Step 3: Generating daily meal suggestions...');
    const dateArg = process.argv[2];
    const today = dateArg ? new Date(dateArg) : new Date();
    
    const result = await dailyMealSuggestionService.generateDailySuggestions(testUser.user_id, today);

    console.log('\n=== SUGGESTIONS GENERATED ===\n');
    console.log(`Date: ${result.date.toISOString().split('T')[0]}`);
    console.log(`Success: ${result.success}`);
    console.log(`Total nutrient gaps tracked: ${Object.keys(result.nutrientGaps).length}\n`);
    
    const meals = ['breakfast', 'lunch', 'dinner', 'snack'];
    meals.forEach(meal => {
      const mealSuggestions = result.suggestions[meal] || [];
      console.log(`\n${meal.toUpperCase()}: ${mealSuggestions.length} suggestions`);
      
      if (mealSuggestions.length > 0) {
        const dishes = mealSuggestions.filter(s => s.dish_id);
        const drinks = mealSuggestions.filter(s => s.drink_id);
        
        console.log(`  Dishes (${dishes.length}):`);
        dishes.forEach((s, idx) => {
          console.log(`    ${idx + 1}. Dish ID: ${s.dish_id}, Score: ${s.score}`);
        });
        
        console.log(`  Drinks (${drinks.length}):`);
        drinks.forEach((s, idx) => {
          console.log(`    ${idx + 1}. Drink ID: ${s.drink_id}, Score: ${s.score}`);
        });
      }
    });

    console.log('\n✅ Test completed successfully!');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    console.error('Stack trace:', error.stack);
  }
}

// Run test
testService();
