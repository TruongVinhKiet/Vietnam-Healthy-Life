const db = require('./db');

async function updateUltraDish() {
  try {
    console.log('Updating Ultra Dish nutrients to 100% coverage amounts...\n');
    
    // Target: 300g serving = 100% daily needs
    // So per 100g = 33.3% daily needs
    
    const updates = [
      // Vitamins (already good, but ensure 100%)
      { code: 'VITA', amount: 300 }, // 900 μg/day → 300 μg/100g
      { code: 'VITB1', amount: 0.4 }, // 1.2 mg/day → 0.4 mg/100g
      { code: 'VITB2', amount: 0.43 }, // 1.3 mg/day
      { code: 'VITB3', amount: 5.33 }, // 16 mg/day
      { code: 'VITB5', amount: 1.67 }, // 5 mg/day
      { code: 'VITB6', amount: 0.43 }, // 1.3 mg/day
      { code: 'VITB7', amount: 10 }, // 30 μg/day
      { code: 'VITB9', amount: 133 }, // 400 μg/day
      { code: 'VITB12', amount: 0.8 }, // 2.4 μg/day
      { code: 'VITC', amount: 30 }, // 90 mg/day
      { code: 'VITD', amount: 667 }, // 2000 IU/day
      { code: 'VITE', amount: 5 }, // 15 mg/day
      { code: 'VITK', amount: 40 }, // 120 μg/day
      
      // Minerals - INCREASE SIGNIFICANTLY
      { code: 'CA', amount: 333 }, // 1000 mg/day → 333 mg/100g
      { code: 'FE', amount: 6 }, // 18 mg/day → 6 mg/100g
      { code: 'ZN', amount: 3.67 }, // 11 mg/day → 3.67 mg/100g
      { code: 'MG', amount: 133 }, // 400 mg/day → 133 mg/100g
      { code: 'K', amount: 1167 }, // 3500 mg/day → 1167 mg/100g
      { code: 'NA', amount: 500 }, // 1500 mg/day → 500 mg/100g
      { code: 'P', amount: 233 }, // 700 mg/day → 233 mg/100g
      { code: 'CU', amount: 0.3 }, // 0.9 mg/day
      { code: 'MN', amount: 0.77 }, // 2.3 mg/day
      { code: 'SE', amount: 18.3 }, // 55 μg/day
      { code: 'I', amount: 50 }, // 150 μg/day
      { code: 'MO', amount: 15 }, // 45 μg/day
      { code: 'CR', amount: 11.7 }, // 35 μg/day
      { code: 'F', amount: 1.33 }, // 4 mg/day
      
      // Essential Amino Acids - INCREASE
      { code: 'AMINO_LEU', amount: 1387 }, // 42 mg/kg × 70kg = ~3g/day → 1g/100g
      { code: 'AMINO_LYS', amount: 1273 }, // 38 mg/kg × 70kg
      { code: 'AMINO_VAL', amount: 867 }, // 26 mg/kg × 70kg
      { code: 'AMINO_ILE', amount: 633 }, // 19 mg/kg × 70kg
      { code: 'AMINO_MET', amount: 520 }, // 15.6 mg/kg × 70kg
      { code: 'AMINO_PHE', amount: 1107 }, // 33 mg/kg × 70kg
      { code: 'AMINO_THR', amount: 500 }, // 15 mg/kg × 70kg
      { code: 'AMINO_TRP', amount: 133 }, // 4 mg/kg × 70kg
      { code: 'AMINO_HIS', amount: 467 }, // 14 mg/kg × 70kg
      
      // Macros
      { code: 'ENERC_KCAL', amount: 667 }, // 2000 kcal/day → 667/100g
      { code: 'PROCNT', amount: 16.7 }, // 50g protein/day
      { code: 'FAT', amount: 22 }, // 65g fat/day
      { code: 'CHOCDF', amount: 86.7 }, // 260g carbs/day
      { code: 'FIBTG', amount: 8.3 }, // 25g fiber/day
      
      // Essential Fatty Acids
      { code: 'FA18_2N6C', amount: 5.67 }, // 17g LA/day
      { code: 'FA18_3N3', amount: 0.53 }, // 1.6g ALA/day
      { code: 'FAEPA_DHA', amount: 0.17 }, // 500mg EPA+DHA/day
    ];
    
    for (const update of updates) {
      const nutrientResult = await db.query(
        'SELECT nutrient_id FROM Nutrient WHERE nutrient_code = $1',
        [update.code]
      );
      
      if (nutrientResult.rows.length > 0) {
        const nutrientId = nutrientResult.rows[0].nutrient_id;
        
        await db.query(`
          UPDATE DishNutrient 
          SET amount_per_100g = $1, calculated_at = NOW()
          WHERE dish_id = 21 AND nutrient_id = $2
        `, [update.amount, nutrientId]);
        
        console.log(`✅ ${update.code}: ${update.amount}`);
      }
    }
    
    console.log('\n✅ Ultra Dish updated! Now 300g = 100% daily needs for all nutrients.');
    console.log('\nTo see the effect:');
    console.log('1. Add Ultra Dish (300g) to any meal in the app');
    console.log('2. Check homepage - all progress bars should be near 100%!');
    
  } catch (error) {
    console.error('Error:', error.message);
    console.error(error);
  } finally {
    process.exit(0);
  }
}

updateUltraDish();
