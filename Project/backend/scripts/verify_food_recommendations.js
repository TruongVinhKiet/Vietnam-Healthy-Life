const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function verifyFoodRecommendations() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('VERIFICATION: Food Recommendations System');
    console.log('='.repeat(80));

    // 1. Check for duplicates
    console.log('\n1️⃣  Checking for duplicate foods...');
    const duplicates = await client.query(`
      SELECT LOWER(TRIM(name)) as normalized_name, COUNT(*) as count
      FROM food
      GROUP BY LOWER(TRIM(name))
      HAVING COUNT(*) > 1
    `);
    
    if (duplicates.rows.length === 0) {
      console.log('   ✓ No duplicates found');
    } else {
      console.log(`   ⚠️  Found ${duplicates.rows.length} duplicates:`);
      duplicates.rows.forEach(d => {
        console.log(`      - "${d.normalized_name}": ${d.count} records`);
      });
    }

    // 2. Check user with active conditions
    console.log('\n2️⃣  Checking users with active health conditions...');
    const users = await client.query(`
      SELECT u.user_id, u.email, COUNT(uhc.condition_id) as condition_count
      FROM "User" u
      JOIN userhealthcondition uhc ON u.user_id = uhc.user_id
      WHERE uhc.status = 'active'
      GROUP BY u.user_id, u.email
      LIMIT 5
    `);
    
    console.log(`   Found ${users.rows.length} users with active conditions:`);
    users.rows.forEach(u => {
      console.log(`   - ${u.email}: ${u.condition_count} condition(s)`);
    });

    if (users.rows.length === 0) {
      console.log('\n   ⚠️  No users with active conditions');
      return;
    }

    // 3. Test with first user
    const testUserId = users.rows[0].user_id;
    console.log(`\n3️⃣  Testing with User ID ${testUserId} (${users.rows[0].email})...`);

    const conditions = await client.query(`
      SELECT hc.condition_id, hc.name_vi
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 AND uhc.status = 'active'
    `, [testUserId]);

    console.log(`   Conditions: ${conditions.rows.map(c => c.name_vi).join(', ')}`);

    const conditionIds = conditions.rows.map(c => c.condition_id);

    // 4. Get food recommendations
    console.log('\n4️⃣  Getting food recommendations...');
    
    const avoid = await client.query(`
      SELECT DISTINCT cfr.food_id, f.name, f.name_vi, hc.name_vi as condition
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[]) AND cfr.recommendation_type = 'avoid'
    `, [conditionIds]);

    const recommend = await client.query(`
      SELECT DISTINCT cfr.food_id, f.name, f.name_vi, hc.name_vi as condition
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[]) AND cfr.recommendation_type = 'recommend'
    `, [conditionIds]);

    console.log(`\n   🚫 Foods to AVOID (${avoid.rows.length}):`);
    avoid.rows.forEach(f => {
      console.log(`      [${f.food_id}] ${f.name_vi || f.name} - ${f.condition}`);
    });

    console.log(`\n   ✅ Foods to RECOMMEND (${recommend.rows.length}):`);
    recommend.rows.forEach(f => {
      console.log(`      [${f.food_id}] ${f.name_vi || f.name} - ${f.condition}`);
    });

    // 5. Simulate search
    console.log('\n5️⃣  Simulating food search for "dua"...');
    const searchResults = await client.query(`
      SELECT food_id, name, name_vi, category
      FROM food
      WHERE LOWER(name) LIKE LOWER($1) OR LOWER(COALESCE(name_vi, '')) LIKE LOWER($1)
      ORDER BY name
      LIMIT 10
    `, ['%dua%']);

    console.log(`   Found ${searchResults.rows.length} results:`);
    const avoidIds = new Set(avoid.rows.map(f => f.food_id));
    const recommendIds = new Set(recommend.rows.map(f => f.food_id));

    searchResults.rows.forEach(f => {
      let status = '   ';
      if (avoidIds.has(f.food_id)) {
        status = '🚫 ';
      } else if (recommendIds.has(f.food_id)) {
        status = '✅ ';
      }
      console.log(`   ${status}[${f.food_id}] ${f.name_vi || f.name} (${f.category})`);
    });

    // 6. Summary
    console.log('\n' + '='.repeat(80));
    console.log('SUMMARY');
    console.log('='.repeat(80));
    console.log(`✓ Duplicates: ${duplicates.rows.length === 0 ? 'None' : duplicates.rows.length + ' found'}`);
    console.log(`✓ Users with conditions: ${users.rows.length}`);
    console.log(`✓ Foods to avoid: ${avoid.rows.length}`);
    console.log(`✓ Foods to recommend: ${recommend.rows.length}`);
    console.log(`✓ Search results: ${searchResults.rows.length}`);
    
    console.log('\n📱 Flutter Integration:');
    console.log('   1. UserFoodRecommendationService loads recommendations on init');
    console.log('   2. AddMealDialog calls _loadRestrictedFoods() in initState()');
    console.log('   3. Foods are marked with opacity 0.45 if restricted');
    console.log('   4. Green "Nên dùng" badge shows for recommended foods');
    console.log('   5. API endpoint: /api/suggestions/user-food-recommendations');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

verifyFoodRecommendations();
