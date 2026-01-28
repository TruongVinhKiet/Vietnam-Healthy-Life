const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function testAddMealFlow() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('TEST: ADD MEAL - FOOD & DISH RECOMMENDATIONS');
    console.log('='.repeat(80));

    // Get test user
    const userResult = await client.query(`
      SELECT u.user_id, u.email
      FROM "User" u
      JOIN userhealthcondition uhc ON u.user_id = uhc.user_id
      WHERE uhc.status = 'active'
      LIMIT 1
    `);

    if (userResult.rows.length === 0) {
      console.log('❌ No user with active health conditions found');
      return;
    }

    const userId = userResult.rows[0].user_id;
    const userEmail = userResult.rows[0].email;

    console.log(`\n👤 Test User: ${userEmail} (ID: ${userId})\n`);

    // Get conditions
    const conditions = await client.query(`
      SELECT hc.condition_id, hc.name_vi
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 AND uhc.status = 'active'
    `, [userId]);

    console.log('🏥 Active Health Conditions:');
    conditions.rows.forEach(c => console.log(`   - ${c.name_vi}`));

    const conditionIds = conditions.rows.map(c => c.condition_id);

    // Get restricted and recommended foods
    const restrictedFoods = await client.query(`
      SELECT DISTINCT f.food_id, f.name, f.name_vi
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = ANY($1::int[]) AND cfr.recommendation_type = 'avoid'
    `, [conditionIds]);

    const recommendedFoods = await client.query(`
      SELECT DISTINCT f.food_id, f.name, f.name_vi
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = ANY($1::int[]) AND cfr.recommendation_type = 'recommend'
    `, [conditionIds]);

    console.log(`\n🚫 Restricted Foods (${restrictedFoods.rows.length}):`);
    restrictedFoods.rows.forEach(f => 
      console.log(`   [${f.food_id}] ${f.name_vi || f.name}`)
    );

    console.log(`\n✅ Recommended Foods (${recommendedFoods.rows.length}):`);
    recommendedFoods.rows.forEach(f => 
      console.log(`   [${f.food_id}] ${f.name_vi || f.name}`)
    );

    const restrictedIds = new Set(restrictedFoods.rows.map(f => f.food_id));
    const recommendedIds = new Set(recommendedFoods.rows.map(f => f.food_id));

    // Test dishes
    console.log('\n' + '='.repeat(80));
    console.log('TESTING DISHES');
    console.log('='.repeat(80));

    const dishes = await client.query(`
      SELECT d.dish_id, d.name, d.vietnamese_name
      FROM dish d
      WHERE d.is_public = true OR d.created_by_admin IS NOT NULL
      LIMIT 20
    `);

    console.log(`\nAnalyzing ${dishes.rows.length} dishes...\n`);

    const dishResults = [];

    for (const dish of dishes.rows) {
      const ingredients = await client.query(`
        SELECT di.food_id, f.name, f.name_vi
        FROM dishingredient di
        JOIN food f ON di.food_id = f.food_id
        WHERE di.dish_id = $1
      `, [dish.dish_id]);

      const hasRestricted = ingredients.rows.some(ing => restrictedIds.has(ing.food_id));
      const hasRecommended = ingredients.rows.some(ing => recommendedIds.has(ing.food_id));

      if (hasRestricted || hasRecommended) {
        dishResults.push({
          dish_id: dish.dish_id,
          name: dish.vietnamese_name || dish.name,
          is_restricted: hasRestricted,
          is_recommended: hasRecommended,
          ingredients: ingredients.rows
        });
      }
    }

    console.log(`Found ${dishResults.length} dishes with restricted/recommended ingredients:\n`);

    dishResults.forEach(d => {
      let badge = '';
      if (d.is_restricted) badge = '🚫 RESTRICTED';
      else if (d.is_recommended) badge = '✅ RECOMMENDED';

      console.log(`${badge} [${d.dish_id}] ${d.name}`);
      console.log(`   Ingredients (${d.ingredients.length}):`);
      d.ingredients.forEach(ing => {
        let ingBadge = '   ';
        if (restrictedIds.has(ing.food_id)) ingBadge = '🚫 ';
        else if (recommendedIds.has(ing.food_id)) ingBadge = '✅ ';
        console.log(`   ${ingBadge}- ${ing.name_vi || ing.name}`);
      });
      console.log('');
    });

    // Summary
    console.log('='.repeat(80));
    console.log('EXPECTED BEHAVIOR IN ADD MEAL DIALOG');
    console.log('='.repeat(80));
    
    console.log('\n📱 FOOD (Nguyên Liệu) Tab:');
    console.log('   ✓ Restricted foods: opacity 0.45 (mờ)');
    console.log('   ✓ Tap restricted food: Show Dialog with warning + OK button');
    console.log('   ✓ Recommended foods: Show green "Nên dùng" badge');
    console.log('   ✓ Normal foods: opacity 1.0, no badge');

    console.log('\n🍽️  DISH (Món Ăn) Tab:');
    console.log('   ✓ Dishes with restricted ingredients: opacity 0.45 (mờ)');
    console.log('   ✓ Tap restricted dish: Show Dialog with warning + OK button');
    console.log('   ✓ Dishes with recommended ingredients: Show green "Nên dùng" badge');
    console.log('   ✓ Normal dishes: opacity 1.0, no badge');

    console.log('\n🔍 Test Cases:');
    console.log(`   1. Search for food in restricted list → Should be faded`);
    console.log(`   2. Tap on restricted food → Dialog appears`);
    console.log(`   3. Search for food in recommended list → Badge shows`);
    console.log(`   4. Search for dish containing restricted food → Dish is faded`);
    console.log(`   5. Tap on restricted dish → Dialog appears`);
    console.log(`   6. Search for dish containing recommended food → Badge shows`);

    console.log('\n📊 Statistics:');
    console.log(`   - Restricted foods: ${restrictedFoods.rows.length}`);
    console.log(`   - Recommended foods: ${recommendedFoods.rows.length}`);
    console.log(`   - Dishes analyzed: ${dishes.rows.length}`);
    console.log(`   - Restricted dishes: ${dishResults.filter(d => d.is_restricted).length}`);
    console.log(`   - Recommended dishes: ${dishResults.filter(d => d.is_recommended && !d.is_restricted).length}`);

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

testAddMealFlow();
