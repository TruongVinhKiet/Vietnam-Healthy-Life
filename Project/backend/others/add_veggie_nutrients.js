const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function addNutrientData() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🌱 Adding nutrient data for vegetables...\n');
    
    // Get nutrient IDs
    const nutrients = await client.query(`
      SELECT nutrient_id, nutrient_code
      FROM nutrient 
      WHERE nutrient_code IN ('ENERC_KCAL', 'PROCNT', 'FAT', 'CHOCDF', 'FIBTG', 'CA', 'FE', 'VITA_RAE', 'VITC', 'NA')
      ORDER BY nutrient_code
    `);
    
    const nutrientMap = {};
    nutrients.rows.forEach(n => {
      nutrientMap[n.nutrient_code] = n.nutrient_id;
    });
    
    console.log('Found nutrients:', Object.keys(nutrientMap).join(', '), '\n');
    
    // Nutrient data for Vietnamese vegetables (per 100g)
    const foodNutrients = [
      // Ngo (Water Spinach / Rau muong) - food_id 6
      { food_id: 6, food_name: 'Ngo', nutrients: {
        'ENERC_KCAL': 19,    // Calories
        'PROCNT': 2.6,       // Protein
        'FAT': 0.2,          // Fat
        'CHOCDF': 3.1,       // Carbs
        'FIBTG': 2.1,        // Fiber
        'CA': 77,            // Calcium
        'FE': 2.5,           // Iron
        'VITA_RAE': 345,     // Vitamin A
        'VITC': 55,          // Vitamin C
        'NA': 113            // Sodium
      }},
      
      // Rau song (Cabbage) - food_id 7
      { food_id: 7, food_name: 'Rau song', nutrients: {
        'ENERC_KCAL': 25,
        'PROCNT': 1.3,
        'FAT': 0.1,
        'CHOCDF': 5.8,
        'FIBTG': 2.5,
        'CA': 40,
        'FE': 0.5,
        'VITA_RAE': 5,
        'VITC': 37,
        'NA': 18
      }},
      
      // Hanh tay (Scallions / Green Onions) - food_id 10
      { food_id: 10, food_name: 'Hanh tay', nutrients: {
        'ENERC_KCAL': 32,
        'PROCNT': 1.8,
        'FAT': 0.2,
        'CHOCDF': 7.3,
        'FIBTG': 2.6,
        'CA': 72,
        'FE': 1.5,
        'VITA_RAE': 50,
        'VITC': 19,
        'NA': 16
      }},
      
      // Nuoc mam (Fish Sauce) - food_id 22
      { food_id: 22, food_name: 'Nuoc mam', nutrients: {
        'ENERC_KCAL': 35,
        'PROCNT': 5.0,
        'FAT': 0.0,
        'CHOCDF': 3.5,
        'FIBTG': 0.0,
        'CA': 15,
        'FE': 0.5,
        'VITA_RAE': 0,
        'VITC': 0,
        'NA': 6500   // Very high sodium!
      }}
    ];
    
    let totalInserted = 0;
    
    for (const food of foodNutrients) {
      console.log(`\n📊 Adding nutrients for ${food.food_name} (food_id ${food.food_id}):`);
      
      for (const [code, amount] of Object.entries(food.nutrients)) {
        const nutrientId = nutrientMap[code];
        
        if (!nutrientId) {
          console.log(`  ⚠️  Nutrient ${code} not found in database`);
          continue;
        }
        
        try {
          await client.query(`
            INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g)
            VALUES ($1, $2, $3)
            ON CONFLICT (food_id, nutrient_id) 
            DO UPDATE SET amount_per_100g = $3
          `, [food.food_id, nutrientId, amount]);
          
          console.log(`  ✅ ${code}: ${amount}`);
          totalInserted++;
        } catch (err) {
          console.log(`  ❌ ${code}: ${err.message}`);
        }
      }
    }
    
    await client.query('COMMIT');
    
    console.log(`\n✅ Total nutrients added: ${totalInserted}`);
    
    // Verify
    console.log('\n📋 Verification:\n');
    for (const food of foodNutrients) {
      const count = await client.query(`
        SELECT COUNT(*) as count FROM foodnutrient WHERE food_id = $1
      `, [food.food_id]);
      console.log(`${food.food_name}: ${count.rows[0].count} nutrients`);
    }
    
    // Calculate total nutrients for Dish 47
    console.log('\n📊 Total nutrients in Dish #47 (Rau Cu Xao):\n');
    const dishNutrients = await client.query(`
      SELECT 
        n.nutrient_code,
        SUM(fn.amount_per_100g * di.weight_g / 100) as total_amount,
        n.unit
      FROM dishingredient di
      JOIN foodnutrient fn ON di.food_id = fn.food_id
      JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
      WHERE di.dish_id = 47
      GROUP BY n.nutrient_id, n.nutrient_code, n.unit
      ORDER BY n.nutrient_code;
    `);
    
    if (dishNutrients.rows.length > 0) {
      console.table(dishNutrients.rows.map(r => ({
        Code: r.nutrient_code,
        Amount: Number(r.total_amount).toFixed(2),
        Unit: r.unit
      })));
    } else {
      console.log('❌ Still no nutrients calculated!');
    }
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    console.error(error);
  } finally {
    client.release();
    await pool.end();
  }
}

addNutrientData();
