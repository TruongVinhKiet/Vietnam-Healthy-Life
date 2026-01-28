const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function addCommonFoodNutrients() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🍚 Adding nutrient data for common Vietnamese foods...\n');
    
    // Get nutrient IDs
    const nutrients = await client.query(`
      SELECT nutrient_id, nutrient_code 
      FROM nutrient 
      WHERE nutrient_code IN ('ENERC_KCAL', 'PROCNT', 'FAT', 'CHOCDF', 'FIBTG', 'CA', 'FE', 'VITC', 'NA')
      ORDER BY nutrient_code
    `);
    
    const nutrientMap = {};
    nutrients.rows.forEach(n => {
      nutrientMap[n.nutrient_code] = n.nutrient_id;
    });
    
    // Vietnamese foods nutrient data (per 100g)
    const foodData = [
      // Rice & grains
      { food_id: 1, name: 'Gao', nutrients: { ENERC_KCAL: 130, PROCNT: 2.7, FAT: 0.3, CHOCDF: 28.2, FIBTG: 0.4, CA: 10, FE: 0.2, VITC: 0, NA: 1 }},
      { food_id: 2, name: 'Gao nep', nutrients: { ENERC_KCAL: 97, PROCNT: 2.0, FAT: 0.2, CHOCDF: 21.1, FIBTG: 0.9, CA: 3, FE: 0.4, VITC: 0, NA: 1 }},
      { food_id: 3, name: 'Banh pho', nutrients: { ENERC_KCAL: 109, PROCNT: 1.8, FAT: 0.2, CHOCDF: 25.0, FIBTG: 0.9, CA: 4, FE: 0.3, VITC: 0, NA: 3 }},
      { food_id: 4, name: 'Banh trang', nutrients: { ENERC_KCAL: 333, PROCNT: 1.1, FAT: 0.3, CHOCDF: 83.1, FIBTG: 0.9, CA: 30, FE: 0.7, VITC: 0, NA: 120 }},
      
      // Vegetables & herbs
      { food_id: 5, name: 'Hanh la', nutrients: { ENERC_KCAL: 32, PROCNT: 1.8, FAT: 0.2, CHOCDF: 7.3, FIBTG: 2.6, CA: 72, FE: 1.5, VITC: 19, NA: 16 }},
      { food_id: 8, name: 'Rau thom', nutrients: { ENERC_KCAL: 23, PROCNT: 2.1, FAT: 0.5, CHOCDF: 3.7, FIBTG: 3.3, CA: 67, FE: 6.2, VITC: 27, NA: 56 }},
      { food_id: 9, name: 'Dua leo', nutrients: { ENERC_KCAL: 15, PROCNT: 0.7, FAT: 0.1, CHOCDF: 3.6, FIBTG: 0.5, CA: 16, FE: 0.3, VITC: 3, NA: 2 }},
      { food_id: 11, name: 'Dua', nutrients: { ENERC_KCAL: 16, PROCNT: 0.6, FAT: 0.1, CHOCDF: 3.9, FIBTG: 0.5, CA: 15, FE: 0.3, VITC: 3, NA: 1 }},
      { food_id: 18, name: 'Rau cu', nutrients: { ENERC_KCAL: 41, PROCNT: 0.9, FAT: 0.2, CHOCDF: 9.6, FIBTG: 2.8, CA: 33, FE: 0.3, VITC: 6, NA: 69 }},
      
      // Beans & legumes
      { food_id: 12, name: 'Dau xanh', nutrients: { ENERC_KCAL: 30, PROCNT: 3.0, FAT: 0.4, CHOCDF: 5.4, FIBTG: 1.8, CA: 13, FE: 1.0, VITC: 13, NA: 6 }},
      
      // Mushrooms
      { food_id: 13, name: 'Nam', nutrients: { ENERC_KCAL: 22, PROCNT: 3.1, FAT: 0.3, CHOCDF: 3.3, FIBTG: 1.0, CA: 3, FE: 0.5, VITC: 2, NA: 5 }},
      { food_id: 20, name: 'Nam', nutrients: { ENERC_KCAL: 22, PROCNT: 3.1, FAT: 0.3, CHOCDF: 3.3, FIBTG: 1.0, CA: 3, FE: 0.5, VITC: 2, NA: 5 }},
      { food_id: 38, name: 'Nam', nutrients: { ENERC_KCAL: 22, PROCNT: 3.1, FAT: 0.3, CHOCDF: 3.3, FIBTG: 1.0, CA: 3, FE: 0.5, VITC: 2, NA: 5 }},
      
      // Condiments & seasonings
      { food_id: 14, name: 'Hanh phi', nutrients: { ENERC_KCAL: 456, PROCNT: 4.4, FAT: 42.0, CHOCDF: 17.0, FIBTG: 2.1, CA: 48, FE: 0.8, VITC: 2, NA: 12 }},
      { food_id: 21, name: 'Hanh phi', nutrients: { ENERC_KCAL: 456, PROCNT: 4.4, FAT: 42.0, CHOCDF: 17.0, FIBTG: 2.1, CA: 48, FE: 0.8, VITC: 2, NA: 12 }},
      { food_id: 39, name: 'Hanh phi', nutrients: { ENERC_KCAL: 456, PROCNT: 4.4, FAT: 42.0, CHOCDF: 17.0, FIBTG: 2.1, CA: 48, FE: 0.8, VITC: 2, NA: 12 }},
      
      { food_id: 15, name: 'Nuoc mam', nutrients: { ENERC_KCAL: 35, PROCNT: 5.0, FAT: 0.0, CHOCDF: 3.5, FIBTG: 0.0, CA: 15, FE: 0.5, VITC: 0, NA: 6500 }},
      { food_id: 40, name: 'Nuoc mam', nutrients: { ENERC_KCAL: 35, PROCNT: 5.0, FAT: 0.0, CHOCDF: 3.5, FIBTG: 0.0, CA: 15, FE: 0.5, VITC: 0, NA: 6500 }},
      
      { food_id: 16, name: 'Duong', nutrients: { ENERC_KCAL: 387, PROCNT: 0.0, FAT: 0.0, CHOCDF: 100.0, FIBTG: 0.0, CA: 1, FE: 0.1, VITC: 0, NA: 1 }},
      { food_id: 23, name: 'Duong', nutrients: { ENERC_KCAL: 387, PROCNT: 0.0, FAT: 0.0, CHOCDF: 100.0, FIBTG: 0.0, CA: 1, FE: 0.1, VITC: 0, NA: 1 }},
      { food_id: 41, name: 'Duong', nutrients: { ENERC_KCAL: 387, PROCNT: 0.0, FAT: 0.0, CHOCDF: 100.0, FIBTG: 0.0, CA: 1, FE: 0.1, VITC: 0, NA: 1 }},
      
      { food_id: 17, name: 'Tieu', nutrients: { ENERC_KCAL: 251, PROCNT: 10.4, FAT: 3.3, CHOCDF: 64.0, FIBTG: 25.3, CA: 443, FE: 9.7, VITC: 21, NA: 20 }},
      { food_id: 24, name: 'Tieu', nutrients: { ENERC_KCAL: 251, PROCNT: 10.4, FAT: 3.3, CHOCDF: 64.0, FIBTG: 25.3, CA: 443, FE: 9.7, VITC: 21, NA: 20 }},
      { food_id: 42, name: 'Tieu', nutrients: { ENERC_KCAL: 251, PROCNT: 10.4, FAT: 3.3, CHOCDF: 64.0, FIBTG: 25.3, CA: 443, FE: 9.7, VITC: 21, NA: 20 }},
      
      { food_id: 25, name: 'Rau cu', nutrients: { ENERC_KCAL: 41, PROCNT: 0.9, FAT: 0.2, CHOCDF: 9.6, FIBTG: 2.8, CA: 33, FE: 0.3, VITC: 6, NA: 69 }},
      { food_id: 43, name: 'Rau cu', nutrients: { ENERC_KCAL: 41, PROCNT: 0.9, FAT: 0.2, CHOCDF: 9.6, FIBTG: 2.8, CA: 33, FE: 0.3, VITC: 6, NA: 69 }},
      
      // Duplicates (foods 26-43 seem to be duplicates of 1-25)
      { food_id: 26, name: 'Gao', nutrients: { ENERC_KCAL: 130, PROCNT: 2.7, FAT: 0.3, CHOCDF: 28.2, FIBTG: 0.4, CA: 10, FE: 0.2, VITC: 0, NA: 1 }},
      { food_id: 27, name: 'Gao nep', nutrients: { ENERC_KCAL: 97, PROCNT: 2.0, FAT: 0.2, CHOCDF: 21.1, FIBTG: 0.9, CA: 3, FE: 0.4, VITC: 0, NA: 1 }},
      { food_id: 28, name: 'Banh pho', nutrients: { ENERC_KCAL: 109, PROCNT: 1.8, FAT: 0.2, CHOCDF: 25.0, FIBTG: 0.9, CA: 4, FE: 0.3, VITC: 0, NA: 3 }},
      { food_id: 29, name: 'Banh trang', nutrients: { ENERC_KCAL: 333, PROCNT: 1.1, FAT: 0.3, CHOCDF: 83.1, FIBTG: 0.9, CA: 30, FE: 0.7, VITC: 0, NA: 120 }},
      { food_id: 30, name: 'Hanh la', nutrients: { ENERC_KCAL: 32, PROCNT: 1.8, FAT: 0.2, CHOCDF: 7.3, FIBTG: 2.6, CA: 72, FE: 1.5, VITC: 19, NA: 16 }},
      { food_id: 31, name: 'Ngo', nutrients: { ENERC_KCAL: 19, PROCNT: 2.6, FAT: 0.2, CHOCDF: 3.1, FIBTG: 2.1, CA: 77, FE: 2.5, VITC: 55, NA: 113 }},
      { food_id: 32, name: 'Rau song', nutrients: { ENERC_KCAL: 25, PROCNT: 1.3, FAT: 0.1, CHOCDF: 5.8, FIBTG: 2.5, CA: 40, FE: 0.5, VITC: 37, NA: 18 }},
      { food_id: 33, name: 'Rau thom', nutrients: { ENERC_KCAL: 23, PROCNT: 2.1, FAT: 0.5, CHOCDF: 3.7, FIBTG: 3.3, CA: 67, FE: 6.2, VITC: 27, NA: 56 }},
      { food_id: 34, name: 'Dua leo', nutrients: { ENERC_KCAL: 15, PROCNT: 0.7, FAT: 0.1, CHOCDF: 3.6, FIBTG: 0.5, CA: 16, FE: 0.3, VITC: 3, NA: 2 }},
      { food_id: 35, name: 'Hanh tay', nutrients: { ENERC_KCAL: 32, PROCNT: 1.8, FAT: 0.2, CHOCDF: 7.3, FIBTG: 2.6, CA: 72, FE: 1.5, VITC: 19, NA: 16 }},
      { food_id: 36, name: 'Dua', nutrients: { ENERC_KCAL: 16, PROCNT: 0.6, FAT: 0.1, CHOCDF: 3.9, FIBTG: 0.5, CA: 15, FE: 0.3, VITC: 3, NA: 1 }},
      { food_id: 37, name: 'Dau xanh', nutrients: { ENERC_KCAL: 30, PROCNT: 3.0, FAT: 0.4, CHOCDF: 5.4, FIBTG: 1.8, CA: 13, FE: 1.0, VITC: 13, NA: 6 }}
    ];
    
    let totalInserted = 0;
    
    for (const food of foodData) {
      console.log(`📊 ${food.name} (ID ${food.food_id}):`);
      
      for (const [code, amount] of Object.entries(food.nutrients)) {
        const nutrientId = nutrientMap[code];
        
        if (!nutrientId) continue;
        
        try {
          await client.query(`
            INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g)
            VALUES ($1, $2, $3)
            ON CONFLICT (food_id, nutrient_id) 
            DO UPDATE SET amount_per_100g = $3
          `, [food.food_id, nutrientId, amount]);
          
          totalInserted++;
        } catch (err) {
          console.log(`  ❌ ${code}: ${err.message}`);
        }
      }
    }
    
    await client.query('COMMIT');
    
    console.log(`\n✅ Total nutrients added: ${totalInserted}\n`);
    
    // Verify
    console.log('📊 VERIFICATION:\n');
    const remaining = await client.query(`
      SELECT COUNT(*) as count
      FROM food f
      LEFT JOIN foodnutrient fn ON f.food_id = fn.food_id
      WHERE fn.food_nutrient_id IS NULL;
    `);
    
    console.log(`Foods still without nutrients: ${remaining.rows[0].count}`);
    
    const total = await client.query('SELECT COUNT(*) FROM foodnutrient');
    console.log(`Total FoodNutrient records: ${total.rows[0].count}\n`);
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

addCommonFoodNutrients();
