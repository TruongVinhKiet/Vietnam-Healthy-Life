const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function diagnose() {
  const client = await pool.connect();
  
  try {
    console.log('🔍 DIAGNOSING DISH NUTRIENT DATA\n');
    console.log('='.repeat(80));
    
    // 1. Check Dish 47 (Rau Cu Xao) specifically
    console.log('\n📋 1. Checking Dish #47 (Rau Cu Xao):\n');
    
    const dish47 = await client.query(`
      SELECT dish_id, dish_name, description, category
      FROM dish
      WHERE dish_id = 47;
    `);
    
    if (dish47.rows.length > 0) {
      console.log('✅ Dish found:');
      console.table(dish47.rows);
    } else {
      console.log('❌ Dish #47 not found!');
    }
    
    // 2. Check ingredients of Dish 47
    console.log('\n📋 2. Ingredients in Dish #47:\n');
    
    const ingredients = await client.query(`
      SELECT di.dish_ingredient_id, di.food_id, f.food_name, di.quantity_grams
      FROM dishingredient di
      JOIN food f ON di.food_id = f.food_id
      WHERE di.dish_id = 47
      ORDER BY di.dish_ingredient_id;
    `);
    
    console.table(ingredients.rows);
    console.log(`Total ingredients: ${ingredients.rows.length}\n`);
    
    // 3. Check nutrient data for each ingredient
    console.log('📋 3. Nutrient data for each ingredient:\n');
    
    for (const ing of ingredients.rows) {
      const nutrients = await client.query(`
        SELECT 
          fn.food_id,
          f.food_name,
          n.nutrient_name,
          fn.amount_per_100g,
          n.unit,
          (fn.amount_per_100g * $1 / 100) as amount_in_dish
        FROM foodnutrient fn
        JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
        JOIN food f ON fn.food_id = f.food_id
        WHERE fn.food_id = $2
        ORDER BY n.nutrient_name
        LIMIT 10;
      `, [ing.quantity_grams, ing.food_id]);
      
      console.log(`\n${ing.food_name} (${ing.quantity_grams}g):`);
      if (nutrients.rows.length > 0) {
        console.table(nutrients.rows.map(r => ({
          Nutrient: r.nutrient_name,
          'Per 100g': r.amount_per_100g,
          'In Dish': Number(r.amount_in_dish).toFixed(2),
          Unit: r.unit
        })));
      } else {
        console.log(`  ❌ NO NUTRIENT DATA for food_id ${ing.food_id}`);
      }
    }
    
    // 4. Calculate total nutrients for Dish 47
    console.log('\n' + '='.repeat(80));
    console.log('\n📋 4. Total Nutrients in Dish #47 (350g serving):\n');
    
    const totalNutrients = await client.query(`
      SELECT 
        n.nutrient_name,
        n.unit,
        SUM(fn.amount_per_100g * di.quantity_grams / 100) as total_amount
      FROM dishingredient di
      JOIN foodnutrient fn ON di.food_id = fn.food_id
      JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
      WHERE di.dish_id = 47
      GROUP BY n.nutrient_id, n.nutrient_name, n.unit
      ORDER BY n.nutrient_name;
    `);
    
    if (totalNutrients.rows.length > 0) {
      console.table(totalNutrients.rows.map(r => ({
        Nutrient: r.nutrient_name,
        Amount: Number(r.total_amount).toFixed(2),
        Unit: r.unit
      })));
      console.log(`\n✅ Total nutrients calculated: ${totalNutrients.rows.length}`);
    } else {
      console.log('❌ NO NUTRIENTS CALCULATED - ingredients missing nutrient data!');
    }
    
    // 5. Check if dish has DishNutrient pre-calculated data
    console.log('\n' + '='.repeat(80));
    console.log('\n📋 5. Pre-calculated DishNutrient data:\n');
    
    const dishNutrients = await client.query(`
      SELECT dn.dish_id, n.nutrient_name, dn.amount_per_serving, n.unit
      FROM dishnutrient dn
      JOIN nutrient n ON dn.nutrient_id = n.nutrient_id
      WHERE dn.dish_id = 47
      ORDER BY n.nutrient_name;
    `);
    
    if (dishNutrients.rows.length > 0) {
      console.table(dishNutrients.rows);
      console.log(`✅ Pre-calculated nutrients: ${dishNutrients.rows.length}`);
    } else {
      console.log('❌ No pre-calculated DishNutrient data (table is empty)');
      console.log('   This means nutrients must be calculated from ingredients!');
    }
    
    // 6. Check which ingredients are missing nutrient data
    console.log('\n' + '='.repeat(80));
    console.log('\n📋 6. Ingredients MISSING nutrient data:\n');
    
    const missingNutrients = await client.query(`
      SELECT 
        f.food_id,
        f.food_name,
        COUNT(fn.food_nutrient_id) as nutrient_count
      FROM food f
      LEFT JOIN foodnutrient fn ON f.food_id = fn.food_id
      WHERE f.food_id IN (
        SELECT food_id FROM dishingredient WHERE dish_id = 47
      )
      GROUP BY f.food_id, f.food_name
      HAVING COUNT(fn.food_nutrient_id) = 0;
    `);
    
    if (missingNutrients.rows.length > 0) {
      console.log('❌ Foods with NO nutrient data:');
      console.table(missingNutrients.rows);
    } else {
      console.log('✅ All ingredients have nutrient data!');
    }
    
    // 7. Check User table for is_deleted column
    console.log('\n' + '='.repeat(80));
    console.log('\n📋 7. Checking User table structure:\n');
    
    const userColumns = await client.query(`
      SELECT column_name, data_type, column_default
      FROM information_schema.columns
      WHERE table_name = 'User'
        AND column_name IN ('is_deleted', 'user_id', 'email')
      ORDER BY column_name;
    `);
    
    console.table(userColumns.rows);
    
    // Try lowercase table name
    const userColumnsLower = await client.query(`
      SELECT column_name, data_type, column_default
      FROM information_schema.columns
      WHERE table_name = 'user'
        AND column_name IN ('is_deleted', 'user_id', 'email')
      ORDER BY column_name;
    `);
    
    if (userColumnsLower.rows.length > 0) {
      console.log('\n⚠️  Found lowercase "user" table:');
      console.table(userColumnsLower.rows);
    }
    
    // 8. Summary
    console.log('\n' + '='.repeat(80));
    console.log('\n📊 SUMMARY:\n');
    
    const summary = {
      'Dish exists': dish47.rows.length > 0 ? '✅' : '❌',
      'Has ingredients': ingredients.rows.length > 0 ? `✅ (${ingredients.rows.length})` : '❌',
      'Has calculated nutrients': totalNutrients.rows.length > 0 ? `✅ (${totalNutrients.rows.length})` : '❌',
      'Has pre-calculated data': dishNutrients.rows.length > 0 ? `✅ (${dishNutrients.rows.length})` : '❌',
      'Missing nutrient ingredients': missingNutrients.rows.length > 0 ? `❌ (${missingNutrients.rows.length})` : '✅',
      'User.is_deleted exists': userColumns.rows.some(r => r.column_name === 'is_deleted') ? '✅' : '❌'
    };
    
    console.table([summary]);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error);
  } finally {
    client.release();
    await pool.end();
  }
}

diagnose();
