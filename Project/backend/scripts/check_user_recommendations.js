const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function checkUserRecommendations(userId = 1) {
  try {
    console.log('\n' + '='.repeat(78));
    console.log(`📋 USER ${userId} - FOOD & DISH RECOMMENDATIONS`);
    console.log('='.repeat(78));
    
    // Get user info (userprofile doesn't have name/email, just show ID)
    const userInfo = await pool.query(`
      SELECT user_id
      FROM userprofile 
      WHERE user_id = $1
    `, [userId]);
    
    if (userInfo.rows.length === 0) {
      console.log(`\n❌ User ID ${userId} not found!`);
      return;
    }
    
    console.log(`\n👤 User ID: ${userId}`);
    
    // Get user's health conditions
    const conditions = await pool.query(`
      SELECT 
        hc.condition_id,
        hc.condition_name,
        uhc.diagnosed_date,
        uhc.treatment_start_date,
        uhc.treatment_end_date
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= CURRENT_DATE)
      ORDER BY uhc.diagnosed_date DESC
    `, [userId]);
    
    console.log(`\n🏥 Active Health Conditions: ${conditions.rows.length}`);
    console.log('-'.repeat(78));
    conditions.rows.forEach(c => {
      const status = c.treatment_end_date ? `Ends: ${c.treatment_end_date.toISOString().split('T')[0]}` : 'Ongoing';
      console.log(`  - ${c.condition_name} (ID: ${c.condition_id}) | ${status}`);
    });
    
    if (conditions.rows.length === 0) {
      console.log('  ⚠️  No active health conditions found for this user');
      return;
    }
    
    const conditionIds = conditions.rows.map(c => c.condition_id);
    
    // Get FOOD recommendations
    console.log(`\n🥗 FOOD RECOMMENDATIONS:`);
    console.log('-'.repeat(78));
    
    const foodRecs = await pool.query(`
      SELECT 
        f.food_id,
        COALESCE(f.name_vi, f.name) as food_name,
        f.category,
        cfr.recommendation_type,
        hc.condition_name,
        hc.condition_id
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1)
      ORDER BY cfr.recommendation_type, f.name_vi, f.name
    `, [conditionIds]);
    
    const foodAvoid = foodRecs.rows.filter(r => r.recommendation_type === 'avoid');
    const foodRecommend = foodRecs.rows.filter(r => r.recommendation_type === 'recommend');
    
    console.log(`\n🚫 FOODS TO AVOID: ${foodAvoid.length}`);
    if (foodAvoid.length > 0) {
      const grouped = {};
      foodAvoid.forEach(f => {
        if (!grouped[f.food_name]) {
          grouped[f.food_name] = { category: f.category, conditions: [] };
        }
        grouped[f.food_name].conditions.push(f.condition_name);
      });
      
      Object.entries(grouped).forEach(([name, data]) => {
        console.log(`  • ${name} (${data.category || 'N/A'})`);
        console.log(`    Conditions: ${data.conditions.join(', ')}`);
      });
    }
    
    console.log(`\n✅ FOODS TO RECOMMEND: ${foodRecommend.length}`);
    if (foodRecommend.length > 0) {
      const grouped = {};
      foodRecommend.forEach(f => {
        if (!grouped[f.food_name]) {
          grouped[f.food_name] = { category: f.category, conditions: [] };
        }
        grouped[f.food_name].conditions.push(f.condition_name);
      });
      
      Object.entries(grouped).slice(0, 20).forEach(([name, data]) => {
        console.log(`  • ${name} (${data.category || 'N/A'})`);
        console.log(`    Conditions: ${data.conditions.join(', ')}`);
      });
      
      if (Object.keys(grouped).length > 20) {
        console.log(`  ... and ${Object.keys(grouped).length - 20} more foods`);
      }
    }
    
    // Get DISH recommendations
    console.log(`\n\n🍲 DISH RECOMMENDATIONS:`);
    console.log('-'.repeat(78));
    
    const dishRecs = await pool.query(`
      SELECT 
        d.dish_id,
        COALESCE(d.vietnamese_name, d.name) as dish_name,
        d.category,
        cdr.recommendation_type,
        hc.condition_name,
        hc.condition_id
      FROM conditiondishrecommendation cdr
      JOIN dish d ON cdr.dish_id = d.dish_id
      JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
      WHERE cdr.condition_id = ANY($1)
      ORDER BY cdr.recommendation_type, d.vietnamese_name, d.name
    `, [conditionIds]);
    
    const dishAvoid = dishRecs.rows.filter(r => r.recommendation_type === 'avoid');
    const dishRecommend = dishRecs.rows.filter(r => r.recommendation_type === 'recommend');
    
    console.log(`\n🚫 DISHES TO AVOID: ${dishAvoid.length}`);
    if (dishAvoid.length > 0) {
      const grouped = {};
      dishAvoid.forEach(d => {
        if (!grouped[d.dish_name]) {
          grouped[d.dish_name] = { category: d.category, conditions: [] };
        }
        grouped[d.dish_name].conditions.push(d.condition_name);
      });
      
      Object.entries(grouped).forEach(([name, data]) => {
        console.log(`  • ${name} (${data.category || 'N/A'})`);
        console.log(`    Conditions: ${data.conditions.join(', ')}`);
      });
    }
    
    console.log(`\n✅ DISHES TO RECOMMEND: ${dishRecommend.length}`);
    if (dishRecommend.length > 0) {
      const grouped = {};
      dishRecommend.forEach(d => {
        if (!grouped[d.dish_name]) {
          grouped[d.dish_name] = { category: d.category, conditions: [] };
        }
        grouped[d.dish_name].conditions.push(d.condition_name);
      });
      
      Object.entries(grouped).slice(0, 20).forEach(([name, data]) => {
        console.log(`  • ${name} (${data.category || 'N/A'})`);
        console.log(`    Conditions: ${data.conditions.join(', ')}`);
      });
      
      if (Object.keys(grouped).length > 20) {
        console.log(`  ... and ${Object.keys(grouped).length - 20} more dishes`);
      }
    }
    
    // Summary statistics
    console.log(`\n\n📊 SUMMARY STATISTICS:`);
    console.log('-'.repeat(78));
    console.log(`Active Health Conditions: ${conditions.rows.length}`);
    console.log(`Foods to Avoid: ${new Set(foodAvoid.map(f => f.food_id)).size}`);
    console.log(`Foods to Recommend: ${new Set(foodRecommend.map(f => f.food_id)).size}`);
    console.log(`Dishes to Avoid: ${new Set(dishAvoid.map(d => d.dish_id)).size}`);
    console.log(`Dishes to Recommend: ${new Set(dishRecommend.map(d => d.dish_id)).size}`);
    
    console.log('\n' + '='.repeat(78));
    console.log('✅ Check complete!');
    console.log('='.repeat(78) + '\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
  } finally {
    await pool.end();
  }
}

// Get user ID from command line argument or default to 1
const userId = process.argv[2] ? parseInt(process.argv[2]) : 1;
checkUserRecommendations(userId);
