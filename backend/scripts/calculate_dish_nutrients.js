const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

// ============================================================================
// CALCULATE DISH NUTRIENTS FROM FOOD INGREDIENTS
// Formula: For each nutrient, sum up (food_nutrient * ingredient_weight / 100)
// ============================================================================

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
    console.log('🚀 Calculating dish nutrients from ingredients...\n');

    // Get all dishes with ingredients
    const dishesResult = await client.query(`
      SELECT DISTINCT d.dish_id, d.name
      FROM dish d
      JOIN dishingredient di ON d.dish_id = di.dish_id
      ORDER BY d.dish_id
    `);

    console.log(`Found ${dishesResult.rows.length} dishes with ingredients\n`);

    let processedDishes = 0;
    let totalNutrients = 0;
    let skippedDishes = 0;

    for (const dish of dishesResult.rows) {
      // Get all ingredients for this dish
      const ingredientsResult = await client.query(`
        SELECT di.food_id, di.weight_g, f.name as food_name
        FROM dishingredient di
        JOIN food f ON di.food_id = f.food_id
        WHERE di.dish_id = $1
      `, [dish.dish_id]);

      if (ingredientsResult.rows.length === 0) {
        console.log(`⏭️  Dish ${dish.dish_id} (${dish.name}): No ingredients`);
        skippedDishes++;
        continue;
      }

      // Get total dish weight
      const totalWeight = ingredientsResult.rows.reduce((sum, ing) => 
        sum + parseFloat(ing.weight_g), 0);

      // Calculate nutrients for each nutrient type
      const nutrientCalculations = await client.query(`
        SELECT 
          fn.nutrient_id,
          SUM(fn.amount_per_100g * di.weight_g / 100.0) as total_amount
        FROM dishingredient di
        JOIN foodnutrient fn ON di.food_id = fn.food_id
        WHERE di.dish_id = $1
        GROUP BY fn.nutrient_id
      `, [dish.dish_id]);

      if (nutrientCalculations.rows.length === 0) {
        console.log(`⚠️  Dish ${dish.dish_id} (${dish.name}): No nutrient data for ingredients`);
        skippedDishes++;
        continue;
      }

      // Delete existing dish nutrients
      await client.query('DELETE FROM dishnutrient WHERE dish_id = $1', [dish.dish_id]);

      // Insert calculated nutrients (normalized to per 100g)
      let nutrientCount = 0;
      for (const nutrient of nutrientCalculations.rows) {
        const amountPer100g = (parseFloat(nutrient.total_amount) / totalWeight) * 100;
        
        await client.query(`
          INSERT INTO dishnutrient (dish_id, nutrient_id, amount_per_100g)
          VALUES ($1, $2, $3)
        `, [dish.dish_id, nutrient.nutrient_id, amountPer100g]);
        
        nutrientCount++;
      }

      processedDishes++;
      totalNutrients += nutrientCount;
      console.log(`✅ Dish ${dish.dish_id} (${dish.name}): ${nutrientCount} nutrients calculated (total weight: ${totalWeight.toFixed(0)}g)`);
    }

    await client.query('COMMIT');

    console.log(`\n📊 Summary:`);
    console.log(`✅ Processed ${processedDishes} dishes`);
    console.log(`✅ Calculated ${totalNutrients} nutrient entries`);
    console.log(`⏭️  Skipped ${skippedDishes} dishes (no ingredients or nutrient data)`);

    // Verify
    const totalDishNutrients = await client.query('SELECT COUNT(*) FROM dishnutrient');
    console.log(`\n📈 Total dishnutrient entries in database: ${totalDishNutrients.rows[0].count}`);

    // Show sample dish nutrients
    console.log(`\n📋 Sample dish nutrients:`);
    const sampleDish = await client.query(`
      SELECT 
        d.name as dish_name,
        n.name as nutrient_name,
        dn.amount_per_100g
      FROM dishnutrient dn
      JOIN dish d ON dn.dish_id = d.dish_id
      JOIN nutrient n ON dn.nutrient_id = n.nutrient_id
      WHERE dn.dish_id = (SELECT dish_id FROM dish WHERE dish_id > 60 ORDER BY dish_id LIMIT 1)
      ORDER BY dn.nutrient_id
      LIMIT 15
    `);

    sampleDish.rows.forEach(row => {
      console.log(`  ${row.dish_name}: ${row.nutrient_name} = ${parseFloat(row.amount_per_100g).toFixed(2)}/100g`);
    });

    console.log('\n✅ Dish nutrients calculated successfully! 🎉');

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
