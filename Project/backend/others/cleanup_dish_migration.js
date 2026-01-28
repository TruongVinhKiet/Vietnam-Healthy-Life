const db = require('./db');

async function cleanupDishMigration() {
  try {
    console.log('Cleaning up any partial Dish migration...\n');
    
    // Run without transaction - let each command succeed or fail independently
    
    // Drop constraints on MealItem if they exist
    console.log('Dropping constraints...');
    try {
      await db.query(`ALTER TABLE "MealItem" DROP CONSTRAINT IF EXISTS chk_mealitem_food_or_dish CASCADE;`);
      console.log('  ✓ Constraint dropped');
    } catch (e) {
      console.log('  (constraint not found)');
    }
    
    // Drop triggers
    console.log('Dropping triggers...');
    const triggers = [
      { name: 'trg_dish_updated_at', table: 'Dish' },
      { name: 'trg_dishingredient_notify', table: 'DishIngredient' },
      { name: 'trg_dishnutrient_recalc', table: 'DishIngredient' },
      { name: 'trg_mealitem_dish_stats', table: 'MealItem' },
      { name: 'trg_dish_stats_on_delete', table: 'MealItem' }
    ];
    
    for (const { name, table } of triggers) {
      try {
        await db.query(`DROP TRIGGER IF EXISTS ${name} ON "${table}" CASCADE;`);
      } catch (e) {
        // Ignore errors
      }
    }
    console.log('  ✓ Triggers processed');
    
    // Drop functions
    console.log('Dropping functions...');
    const functions = [
      'update_dish_timestamp()',
      'recalculate_dish_nutrients(integer)',
      'trigger_dish_nutrient_recalc()',
      'update_dish_statistics()',
      'remove_dish_from_stats()'
    ];
    
    for (const func of functions) {
      try {
        await db.query(`DROP FUNCTION IF EXISTS ${func} CASCADE;`);
      } catch (e) {
        // Ignore
      }
    }
    console.log('  ✓ Functions processed');
    
    // Drop views
    console.log('Dropping views...');
    try {
      await db.query(`DROP VIEW IF EXISTS dish_with_stats CASCADE;`);
      await db.query(`DROP VIEW IF EXISTS dish_with_macros CASCADE;`);
      console.log('  ✓ Views processed');
    } catch (e) {
      // Ignore
    }
    
    // Drop tables (in reverse dependency order)
    console.log('Dropping tables...');
    const tables = [
      'DishStatistics',
      'DishNutrient',
      'DishImage',
      'DishIngredient',
      'Dish'
    ];
    
    for (const table of tables) {
      try {
        await db.query(`DROP TABLE IF EXISTS "${table}" CASCADE;`);
        console.log(`  ✓ Dropped ${table}`);
      } catch (e) {
        console.log(`  - ${table} not found`);
      }
    }
    
    console.log('\n✅ Cleanup completed successfully!');
    console.log('Now run the migration again with run_dish_migration_split.js\n');
    
    process.exit(0);
  } catch (err) {
    console.error('❌ Cleanup failed:', err.message);
    process.exit(1);
  }
}

cleanupDishMigration();
