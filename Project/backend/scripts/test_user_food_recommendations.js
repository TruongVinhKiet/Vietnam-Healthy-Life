const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function testUserFoodRecommendations() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('TEST USER FOOD RECOMMENDATIONS API');
    console.log('='.repeat(80));

    // Get a test user with health conditions
    const userResult = await client.query(`
      SELECT u.user_id, u.email, u.full_name
      FROM "User" u
      JOIN userhealthcondition uhc ON u.user_id = uhc.user_id
      WHERE uhc.status = 'active'
      LIMIT 1;
    `);

    if (userResult.rows.length === 0) {
      console.log('❌ Không tìm thấy user nào có health condition active');
      console.log('Tạo dữ liệu test...');
      
      // Create test user if not exists
      const createUser = await client.query(`
        INSERT INTO "User" (email, password_hash, full_name)
        VALUES ('test_food_rec@test.com', 'test', 'Test User Food Rec')
        ON CONFLICT (email) DO UPDATE SET full_name = EXCLUDED.full_name
        RETURNING user_id, email, full_name;
      `);
      
      const testUserId = createUser.rows[0].user_id;
      console.log(`✓ User created/updated: ${createUser.rows[0].email} (ID: ${testUserId})`);
      
      // Add a health condition
      const conditionResult = await client.query(`
        SELECT condition_id FROM healthcondition LIMIT 1;
      `);
      
      if (conditionResult.rows.length === 0) {
        console.log('❌ Không có health condition nào trong database');
        return;
      }
      
      const conditionId = conditionResult.rows[0].condition_id;
      
      await client.query(`
        INSERT INTO userhealthcondition (user_id, condition_id, status, start_date)
        VALUES ($1, $2, 'active', CURRENT_DATE)
        ON CONFLICT DO NOTHING;
      `, [testUserId, conditionId]);
      
      console.log(`✓ Added condition ${conditionId} to user ${testUserId}`);
    }

    const userId = userResult.rows.length > 0 ? userResult.rows[0].user_id : (await client.query(`SELECT user_id FROM "User" WHERE email = 'test_food_rec@test.com'`)).rows[0].user_id;
    const userInfo = userResult.rows.length > 0 ? userResult.rows[0] : (await client.query(`SELECT * FROM "User" WHERE user_id = $1`, [userId])).rows[0];

    console.log(`\n✓ Testing with user: ${userInfo.email} (ID: ${userId})`);

    // Get user's active conditions
    const conditions = await client.query(`
      SELECT DISTINCT hc.condition_id, hc.name_vi, hc.name_en
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 AND uhc.status = 'active';
    `, [userId]);

    console.log(`\n📋 User's active conditions (${conditions.rows.length}):`);
    conditions.rows.forEach(c => {
      console.log(`   - [${c.condition_id}] ${c.name_vi || c.name_en}`);
    });

    if (conditions.rows.length === 0) {
      console.log('\n⚠️  User không có health condition active');
      return;
    }

    const conditionIds = conditions.rows.map(c => c.condition_id);

    // Get foods to avoid
    const avoidResult = await client.query(`
      SELECT DISTINCT 
        cfr.food_id,
        f.name_vi,
        f.name,
        cfr.notes,
        hc.name_vi as condition_name
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[]) 
        AND cfr.recommendation_type = 'avoid'
      ORDER BY f.name_vi;
    `, [conditionIds]);

    // Get foods to recommend
    const recommendResult = await client.query(`
      SELECT DISTINCT 
        cfr.food_id,
        f.name_vi,
        f.name,
        cfr.notes,
        hc.name_vi as condition_name
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[]) 
        AND cfr.recommendation_type = 'recommend'
      ORDER BY f.name_vi;
    `, [conditionIds]);

    console.log(`\n🚫 Foods to AVOID (${avoidResult.rows.length}):`);
    if (avoidResult.rows.length === 0) {
      console.log('   (none)');
    } else {
      avoidResult.rows.slice(0, 10).forEach(f => {
        console.log(`   - [${f.food_id}] ${f.name_vi || f.name} (${f.condition_name})`);
      });
      if (avoidResult.rows.length > 10) {
        console.log(`   ... and ${avoidResult.rows.length - 10} more`);
      }
    }

    console.log(`\n✅ Foods to RECOMMEND (${recommendResult.rows.length}):`);
    if (recommendResult.rows.length === 0) {
      console.log('   (none)');
    } else {
      recommendResult.rows.slice(0, 10).forEach(f => {
        console.log(`   - [${f.food_id}] ${f.name_vi || f.name} (${f.condition_name})`);
      });
      if (recommendResult.rows.length > 10) {
        console.log(`   ... and ${recommendResult.rows.length - 10} more`);
      }
    }

    // Test response format (what API should return)
    console.log('\n' + '='.repeat(80));
    console.log('API RESPONSE FORMAT (for Flutter)');
    console.log('='.repeat(80));
    
    const apiResponse = {
      success: true,
      foods_to_avoid: avoidResult.rows,
      foods_to_recommend: recommendResult.rows,
      conditions: conditions.rows
    };

    console.log('\nEndpoint: GET /api/suggestions/user-food-recommendations');
    console.log('Headers: { "Authorization": "Bearer <token>" }');
    console.log('\nResponse structure:');
    console.log(JSON.stringify({
      success: apiResponse.success,
      foods_to_avoid: `Array(${apiResponse.foods_to_avoid.length}) - each with: food_id, name_vi, name, notes, condition_name`,
      foods_to_recommend: `Array(${apiResponse.foods_to_recommend.length}) - each with: food_id, name_vi, name, notes, condition_name`,
      conditions: `Array(${apiResponse.conditions.length}) - each with: condition_id, name_vi, name_en`
    }, null, 2));

    console.log('\n✓ Test completed successfully!');

  } catch (error) {
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

testUserFoodRecommendations();
