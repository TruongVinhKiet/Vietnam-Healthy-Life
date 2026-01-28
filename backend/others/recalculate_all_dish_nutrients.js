const db = require('./db');

async function recalculateAllDishNutrients() {
  try {
    console.log('🔄 Recalculating nutrients for all dishes with ingredients...\n');

    // Get all dishes with ingredients
    const dishesQuery = `
      SELECT DISTINCT d.dish_id, d.vietnamese_name, d.name
      FROM dish d
      JOIN dishingredient di ON d.dish_id = di.dish_id
      ORDER BY d.dish_id
    `;
    
    const dishesResult = await db.query(dishesQuery);
    const dishes = dishesResult.rows;
    
    console.log(`Found ${dishes.length} dishes with ingredients\n`);

    let successCount = 0;
    let errorCount = 0;

    // Recalculate nutrients for each dish
    for (const dish of dishes) {
      try {
        console.log(`Processing dish ${dish.dish_id}: ${dish.vietnamese_name} (${dish.name})`);
        
        // Call the calculate_dish_nutrients function
        await db.query('SELECT calculate_dish_nutrients($1)', [dish.dish_id]);
        
        // Verify nutrients were added
        const nutrientCheck = await db.query(
          'SELECT COUNT(*) as count FROM dishnutrient WHERE dish_id = $1',
          [dish.dish_id]
        );
        
        const nutrientCount = parseInt(nutrientCheck.rows[0].count);
        console.log(`  ✅ Calculated ${nutrientCount} nutrients\n`);
        successCount++;
      } catch (error) {
        console.error(`  ❌ Error for dish ${dish.dish_id}: ${error.message}\n`);
        errorCount++;
      }
    }

    console.log('\n📊 SUMMARY:');
    console.log(`✅ Successfully calculated: ${successCount} dishes`);
    console.log(`❌ Errors: ${errorCount} dishes`);

    // Show total nutrients added
    const totalNutrients = await db.query('SELECT COUNT(*) as count FROM dishnutrient');
    console.log(`📈 Total DishNutrient records: ${totalNutrients.rows[0].count}`);

    // Show sample dish with most nutrients
    const sampleQuery = `
      SELECT d.dish_id, d.vietnamese_name, d.name, COUNT(dn.nutrient_id) as nutrient_count
      FROM dish d
      JOIN dishnutrient dn ON d.dish_id = dn.dish_id
      GROUP BY d.dish_id, d.vietnamese_name, d.name
      ORDER BY nutrient_count DESC
      LIMIT 5
    `;
    
    const sampleResult = await db.query(sampleQuery);
    console.log('\n🏆 Top 5 dishes by nutrient count:');
    sampleResult.rows.forEach(row => {
      console.log(`  ${row.vietnamese_name} (ID ${row.dish_id}): ${row.nutrient_count} nutrients`);
    });

    process.exit(0);
  } catch (error) {
    console.error('❌ Fatal error:', error);
    process.exit(1);
  }
}

recalculateAllDishNutrients();
