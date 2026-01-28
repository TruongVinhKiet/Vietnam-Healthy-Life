require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const db = require('../db');

async function createTestMeal() {
  try {
    console.log('Creating test meal with Ultra Food Complete for user 9...\n');
    
    // Get Ultra Food ID
    const foodResult = await db.query(`SELECT food_id FROM Food WHERE name = 'Ultra Food Complete' LIMIT 1`);
    if (!foodResult.rows || foodResult.rows.length === 0) {
      throw new Error('Ultra Food Complete not found!');
    }
    const foodId = foodResult.rows[0].food_id;
    console.log(`✓ Found Ultra Food (ID: ${foodId})`);
    
    // Delete old test meals for today
    await db.query(`
      DELETE FROM MealItem WHERE meal_id IN (
        SELECT meal_id FROM Meal WHERE user_id = 9 AND meal_date = '2025-01-24' AND meal_type = 'breakfast'
      )
    `);
    await db.query(`
      DELETE FROM Meal WHERE user_id = 9 AND meal_date = '2025-01-24' AND meal_type = 'breakfast'
    `);
    console.log('✓ Cleared old breakfast meals');
    
    // Create meal
    const mealResult = await db.query(`
      INSERT INTO Meal (user_id, meal_date, meal_type)
      VALUES (9, '2025-01-24', 'breakfast')
      RETURNING meal_id
    `);
    const mealId = mealResult.rows[0].meal_id;
    console.log(`✓ Created meal (ID: ${mealId})`);
    
    // Add meal item (100g = 100% of amounts in FoodNutrient)
    await db.query(`
      INSERT INTO MealItem (meal_id, food_id, weight_g)
      VALUES ($1, $2, 100)
    `, [mealId, foodId]);
    console.log('✓ Added 100g Ultra Food to meal\n');
    
    console.log('═══════════════════════════════════════');
    console.log('Test meal created successfully!');
    console.log('═══════════════════════════════════════');
    console.log('User: 9 (hello@gmail.com)');
    console.log('Date: 2025-01-24');
    console.log('Meal: Breakfast - Ultra Nutrition Test');
    console.log('Food: Ultra Food Complete (100g)');
    console.log('Expected: ~800% for ALL nutrients\n');
    
    process.exit(0);
  } catch (error) {
    console.error('✗ Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

createTestMeal();
