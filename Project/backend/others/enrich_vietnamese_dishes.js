const { pool } = require('./db/index');

/**
 * Script to enrich 10 Vietnamese dishes with complete nutrients based on their ingredients
 * Maps each dish to foods and adds all available nutrients from USDA data
 */

const DISH_FOOD_MAPPING = {
  'Phở Bò': {
    foods: ['Thịt bò', 'Bánh phở', 'Hành lá', 'Ngò'],
    weights: [100, 200, 20, 10], // grams
    expectedNutrients: ['VITB12', 'VITB6', 'VITB2', 'VITB1', 'VITA', 'VITK', 
      'AMINO_HIS', 'AMINO_ILE', 'AMINO_LEU', 'AMINO_LYS', 'AMINO_MET', 'AMINO_PHE', 'AMINO_THR', 'AMINO_TRP', 'AMINO_VAL',
      'FE', 'ZN', 'P', 'K', 'NA', 'MG', 'CA', 'MN', 'FAT', 'FASAT', 'FAMS', 'FAPU', 'CHOLESTEROL']
  },
  'Bún Chả': {
    foods: ['Thịt lợn', 'Bún', 'Rau sống', 'Rau thơm'],
    weights: [100, 150, 80, 20],
    expectedNutrients: ['VITB1', 'VITB3', 'VITB6', 'VITB12', 'VITA', 'VITK', 'VITC',
      'FE', 'ZN', 'P', 'MG', 'K', 'NA', 'FAT', 'FASAT', 'FAMS', 'CHOLESTEROL', 'FIBTG']
  },
  'Cơm Tấm Sườn': {
    foods: ['Gạo', 'Thịt lợn', 'Trứng gà', 'Dưa leo'],
    weights: [150, 100, 50, 30],
    expectedNutrients: ['VITB1', 'VITB3', 'VITB6', 'VITB12', 'VITK',
      'P', 'K', 'NA', 'MG', 'ZN', 'FE', 'FAT', 'FASAT', 'FAMS', 'CHOLESTEROL', 'FIBTG']
  },
  'Bánh Mì Thịt': {
    foods: ['Bánh mì', 'Thịt lợn', 'Dưa leo', 'Rau ngò'],
    weights: [100, 80, 30, 10],
    expectedNutrients: ['VITB1', 'VITB2', 'VITB3', 'VITB6', 'VITK', 'VITA',
      'NA', 'P', 'FE', 'ZN', 'CA', 'K', 'MG', 'FAT', 'FASAT', 'FAMS', 'FAPU', 'CHOLESTEROL', 'FIBTG']
  },
  'Gỏi Cuốn': {
    foods: ['Bánh tráng gạo', 'Tôm', 'Thịt lợn', 'Bún', 'Rau sống'],
    weights: [50, 80, 50, 50, 100],
    expectedNutrients: ['VITA', 'VITC', 'VITK', 'VITB1', 'VITB3',
      'K', 'MG', 'ZN', 'P', 'FE', 'FAT', 'FAMS', 'FAPU', 'FASAT', 'CHOLESTEROL', 'FIBTG']
  },
  'Bún Bò Huế': {
    foods: ['Thịt bò', 'Thịt lợn', 'Bún', 'Rau sống'],
    weights: [100, 50, 200, 50],
    expectedNutrients: ['VITB12', 'VITB6', 'VITB3', 'VITK', 'VITA',
      'FE', 'ZN', 'P', 'NA', 'K', 'MG', 'FAT', 'FASAT', 'CHOLESTEROL', 'FIBTG']
  },
  'Cá Kho Tộ': {
    foods: ['Cá', 'Nước mắm', 'Đường', 'Tiêu'],
    weights: [150, 20, 10, 2],
    expectedNutrients: ['VITB12', 'VITD', 'VITB6', 'VITB3',
      'SE', 'P', 'K', 'MG', 'FAT', 'FAPU', 'FAEPA', 'FADHA', 'CHOLESTEROL']
  },
  'Canh Chua Cá': {
    foods: ['Cá', 'Cà chua', 'Dứa', 'Rau muống'],
    weights: [120, 80, 50, 50],
    expectedNutrients: ['VITC', 'VITA', 'VITB1', 'VITB6', 'VITK',
      'P', 'K', 'MG', 'CA', 'FE', 'FAT', 'FIBTG']
  },
  'Xôi Xéo': {
    foods: ['Gạo nếp', 'Đậu xanh', 'Hành phi'],
    weights: [150, 50, 20],
    expectedNutrients: ['VITB1', 'VITB3', 'VITB6', 'VITK',
      'P', 'K', 'MG', 'ZN', 'FE', 'FAT', 'FIBTG']
  },
  'Chả Giò': {
    foods: ['Bánh tráng', 'Thịt lợn', 'Tôm', 'Nấm', 'Rau củ'],
    weights: [30, 60, 40, 20, 50],
    expectedNutrients: ['VITB1', 'VITB6', 'VITB12', 'VITA', 'VITK', 'VITC',
      'P', 'ZN', 'FE', 'SE', 'MG', 'FAT', 'FASAT', 'FIBTG']
  }
};

async function enrichVietnameseDishes() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    console.log('=== ENRICHING VIETNAMESE DISHES WITH USDA NUTRIENTS ===\n');

    // Step 1: Get all nutrients
    const nutrientsResult = await client.query('SELECT * FROM nutrient ORDER BY nutrient_id');
    const nutrients = nutrientsResult.rows;
    console.log(`✅ Found ${nutrients.length} nutrients in database\n`);

    let dishesEnriched = 0;
    let totalNutrientsAdded = 0;

    // Step 2: Process each dish
    for (const [dishName, mapping] of Object.entries(DISH_FOOD_MAPPING)) {
      console.log(`\n📋 Processing: ${dishName}`);
      
      // Find dish
      const dishResult = await client.query(
        'SELECT dish_id FROM dish WHERE vietnamese_name = $1 OR name = $1',
        [dishName]
      );

      if (dishResult.rows.length === 0) {
        console.log(`   ⚠️  Dish not found: ${dishName}`);
        continue;
      }

      const dishId = dishResult.rows[0].dish_id;
      console.log(`   Found dish ID: ${dishId}`);

      // Clear existing ingredients for this dish
      await client.query('DELETE FROM dishingredient WHERE dish_id = $1', [dishId]);
      console.log(`   Cleared old ingredients`);

      // Add ingredients based on mapping
      let ingredientsAdded = 0;
      for (let i = 0; i < mapping.foods.length; i++) {
        const foodName = mapping.foods[i];
        const weight = mapping.weights[i];

        // Find food (try exact match, then partial)
        const foodResult = await client.query(
          `SELECT food_id FROM food 
           WHERE name ILIKE $1 OR name ILIKE $2 
           LIMIT 1`,
          [`%${foodName}%`, foodName]
        );

        if (foodResult.rows.length > 0) {
          const foodId = foodResult.rows[0].food_id;
          
          await client.query(
            'INSERT INTO dishingredient (dish_id, food_id, weight_g) VALUES ($1, $2, $3)',
            [dishId, foodId, weight]
          );
          
          console.log(`   ✅ Added: ${foodName} (${weight}g)`);
          ingredientsAdded++;
        } else {
          console.log(`   ⚠️  Food not found: ${foodName}`);
        }
      }

      console.log(`   Total ingredients added: ${ingredientsAdded}`);

      // Check nutrients
      const nutrientCheckResult = await client.query(
        'SELECT COUNT(*) as count FROM dishnutrient WHERE dish_id = $1',
        [dishId]
      );
      
      const nutrientCount = parseInt(nutrientCheckResult.rows[0].count);
      console.log(`   ✅ Dish now has ${nutrientCount} nutrients calculated`);
      
      dishesEnriched++;
      totalNutrientsAdded += nutrientCount;
    }

    await client.query('COMMIT');

    console.log('\n=== ENRICHMENT COMPLETE ===');
    console.log(`✅ Dishes enriched: ${dishesEnriched}/10`);
    console.log(`✅ Total nutrients: ${totalNutrientsAdded}`);
    console.log(`✅ Average per dish: ${Math.round(totalNutrientsAdded / dishesEnriched)}\n`);

    // Summary report
    console.log('📊 Dish Summary:');
    const summaryResult = await client.query(`
      SELECT 
        d.vietnamese_name,
        d.name,
        COUNT(DISTINCT di.food_id) as ingredient_count,
        COUNT(DISTINCT dn.nutrient_id) as nutrient_count
      FROM dish d
      LEFT JOIN dishingredient di ON d.dish_id = di.dish_id
      LEFT JOIN dishnutrient dn ON d.dish_id = dn.dish_id
      WHERE d.vietnamese_name IN (
        'Phở Bò', 'Bún Chả', 'Cơm Tấm Sườn', 'Bánh Mì Thịt', 'Gỏi Cuốn',
        'Bún Bò Huế', 'Cá Kho Tộ', 'Canh Chua Cá', 'Xôi Xéo', 'Chả Giò'
      )
      GROUP BY d.dish_id, d.vietnamese_name, d.name
      ORDER BY d.dish_id
    `);

    summaryResult.rows.forEach(row => {
      console.log(`   ${row.vietnamese_name}: ${row.ingredient_count} ingredients, ${row.nutrient_count} nutrients`);
    });

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error enriching dishes:', error.message);
    console.error(error);
    throw error;
  } finally {
    client.release();
  }
}

// Run if called directly
if (require.main === module) {
  enrichVietnameseDishes()
    .then(() => {
      console.log('\n✅ Script completed successfully!');
      process.exit(0);
    })
    .catch(error => {
      console.error('\n❌ Script failed:', error);
      process.exit(1);
    });
}

module.exports = { enrichVietnameseDishes };
