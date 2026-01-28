const { pool } = require('./db/index');
const fs = require('fs');
const path = require('path');

/**
 * Add missing Vietnamese foods with nutrients from USDA database
 * Maps Vietnamese food names to USDA food categories for nutrient import
 */

const MISSING_FOODS_USDA_MAPPING = [
  // Carbs/Grains
  { name: 'Gạo', usdaCategory: 'Cereal Grains and Pasta', searchTerm: 'rice, white, long-grain, cooked' },
  { name: 'Gạo nếp', usdaCategory: 'Cereal Grains and Pasta', searchTerm: 'rice, glutinous' },
  { name: 'Bánh phở', usdaCategory: 'Cereal Grains and Pasta', searchTerm: 'rice noodles' },
  { name: 'Bánh tráng', usdaCategory: 'Cereal Grains and Pasta', searchTerm: 'rice paper' },
  
  // Vegetables
  { name: 'Hành lá', usdaCategory: 'Vegetables', searchTerm: 'onions, spring' },
  { name: 'Ngò', usdaCategory: 'Vegetables', searchTerm: 'coriander (cilantro) leaves' },
  { name: 'Rau sống', usdaCategory: 'Vegetables', searchTerm: 'lettuce, green leaf' },
  { name: 'Rau thơm', usdaCategory: 'Vegetables', searchTerm: 'herbs, mixed' },
  { name: 'Dưa leo', usdaCategory: 'Vegetables', searchTerm: 'cucumber, with peel' },
  { name: 'Hành tây', usdaCategory: 'Vegetables', searchTerm: 'onions, raw' },
  { name: 'Dứa', usdaCategory: 'Fruits', searchTerm: 'pineapple, raw' },
  
  // Legumes
  { name: 'Đậu xanh', usdaCategory: 'Legumes', searchTerm: 'mung beans' },
  
  // Other
  { name: 'Nấm', usdaCategory: 'Vegetables', searchTerm: 'mushrooms, white' },
  { name: 'Hành phi', usdaCategory: 'Vegetables', searchTerm: 'onions, dehydrated flakes' },
  { name: 'Nước mắm', usdaCategory: 'Spices and Herbs', searchTerm: 'fish sauce' },
  { name: 'Đường', usdaCategory: 'Sweets', searchTerm: 'sugars, granulated' },
  { name: 'Tiêu', usdaCategory: 'Spices and Herbs', searchTerm: 'pepper, black' },
  { name: 'Rau củ', usdaCategory: 'Vegetables', searchTerm: 'vegetables, mixed' }
];

async function addMissingFoods() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    console.log('=== ADDING MISSING VIETNAMESE FOODS ===\n');

    let foodsAdded = 0;
    let foodsSkipped = 0;

    for (const mapping of MISSING_FOODS_USDA_MAPPING) {
      console.log(`\n📌 Processing: ${mapping.name}`);
      
      // Check if exists
      const existingFood = await client.query(
        'SELECT food_id FROM food WHERE name = $1',
        [mapping.name]
      );

      if (existingFood.rows.length > 0) {
        console.log(`   ⏭️  Already exists (ID: ${existingFood.rows[0].food_id})`);
        foodsSkipped++;
        continue;
      }

      // Insert food
      const foodResult = await client.query(`
        INSERT INTO food (name, category, created_by_admin)
        VALUES ($1, $2, 1)
        RETURNING food_id
      `, [mapping.name, mapping.usdaCategory]);

      const foodId = foodResult.rows[0].food_id;
      console.log(`   ✅ Created food (ID: ${foodId})`);

      // Add basic nutrients (default values - can be enriched later from USDA)
      const basicNutrients = await addBasicNutrients(client, foodId, mapping);
      console.log(`   ✅ Added ${basicNutrients} basic nutrients`);

      foodsAdded++;
    }

    await client.query('COMMIT');

    console.log('\n=== IMPORT COMPLETE ===');
    console.log(`✅ Foods added: ${foodsAdded}`);
    console.log(`⏭️  Foods skipped: ${foodsSkipped}`);
    console.log(`📊 Total: ${foodsAdded + foodsSkipped}/${MISSING_FOODS_USDA_MAPPING.length}\n`);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error adding foods:', error.message);
    console.error(error);
    throw error;
  } finally {
    client.release();
  }
}

async function addBasicNutrients(client, foodId, mapping) {
  // Get nutrients from database
  const nutrientsResult = await client.query('SELECT nutrient_id, nutrient_code FROM nutrient');
  const nutrients = nutrientsResult.rows;

  let count = 0;

  // Add category-specific nutrients with estimated values
  const nutrientValues = getEstimatedNutrients(mapping);

  for (const [code, amount] of Object.entries(nutrientValues)) {
    const nutrient = nutrients.find(n => n.nutrient_code === code);
    if (nutrient && amount > 0) {
      await client.query(
        'INSERT INTO foodnutrient (food_id, nutrient_id, amount_per_100g) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING',
        [foodId, nutrient.nutrient_id, amount]
      );
      count++;
    }
  }

  return count;
}

function getEstimatedNutrients(mapping) {
  const category = mapping.usdaCategory;
  const name = mapping.name.toLowerCase();

  // Base nutrients for all foods
  const nutrients = {
    'ENERC_KCAL': 0,
    'PROCNT': 0,
    'FAT': 0,
    'CHOCDF': 0,
    'FIBTG': 0
  };

  // Category-specific nutrients
  if (category === 'Cereal Grains and Pasta') {
    nutrients.ENERC_KCAL = 130;
    nutrients.CHOCDF = 28;
    nutrients.PROCNT = 2.5;
    nutrients.FAT = 0.3;
    nutrients.FIBTG = 1.0;
    nutrients.VITB1 = 0.07;
    nutrients.VITB3 = 1.6;
    nutrients.FE = 0.8;
    nutrients.MG = 25;
  } else if (category === 'Vegetables') {
    nutrients.ENERC_KCAL = 20;
    nutrients.CHOCDF = 4;
    nutrients.PROCNT = 1;
    nutrients.FAT = 0.2;
    nutrients.FIBTG = 1.5;
    nutrients.VITC = 10;
    nutrients.VITA = 50;
    nutrients.VITK = 20;
    nutrients.CA = 30;
    nutrients.FE = 0.5;
    nutrients.K = 200;
  } else if (category === 'Fruits') {
    nutrients.ENERC_KCAL = 50;
    nutrients.CHOCDF = 13;
    nutrients.PROCNT = 0.5;
    nutrients.FAT = 0.1;
    nutrients.FIBTG = 1.4;
    nutrients.VITC = 20;
    nutrients.VITA = 10;
    nutrients.K = 150;
  } else if (category === 'Legumes') {
    nutrients.ENERC_KCAL = 120;
    nutrients.CHOCDF = 20;
    nutrients.PROCNT = 8;
    nutrients.FAT = 0.5;
    nutrients.FIBTG = 7;
    nutrients.VITB1 = 0.3;
    nutrients.VITB9 = 100;
    nutrients.FE = 2.5;
    nutrients.MG = 50;
    nutrients.P = 150;
  } else if (category === 'Spices and Herbs') {
    nutrients.ENERC_KCAL = 10;
    nutrients.NA = 5000; // Fish sauce has high sodium
  } else if (category === 'Sweets') {
    nutrients.ENERC_KCAL = 387;
    nutrients.CHOCDF = 100;
  }

  return nutrients;
}

// Run if called directly
if (require.main === module) {
  addMissingFoods()
    .then(() => {
      console.log('✅ Script completed successfully!');
      console.log('\n💡 Next step: Run enrich_vietnamese_dishes.js to add these foods to dishes');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n❌ Script failed:', error);
      process.exit(1);
    });
}

module.exports = { addMissingFoods };
