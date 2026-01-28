const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

async function createTestDishes() {
  const client = await pool.connect();
  
  try {
    console.log('Creating test dishes with restricted/recommended ingredients...\n');

    await client.query('BEGIN');

    // Get restricted and recommended foods
    const restricted = await client.query(`
      SELECT DISTINCT f.food_id, f.name, f.name_vi
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      WHERE cfr.recommendation_type = 'avoid'
      LIMIT 2
    `);

    const recommended = await client.query(`
      SELECT DISTINCT f.food_id, f.name, f.name_vi
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      WHERE cfr.recommendation_type = 'recommend'
      LIMIT 2
    `);

    if (restricted.rows.length === 0 || recommended.rows.length === 0) {
      console.log('❌ Not enough restricted/recommended foods');
      return;
    }

    // Create test dish with restricted ingredient
    const dish1 = await client.query(`
      INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_public, created_by_admin)
      VALUES ('Test Dish - Restricted', 'Món Test - Hạn Chế', 'Contains restricted ingredient', 'Lunch', 200, true, 1)
      RETURNING dish_id
    `);

    await client.query(`
      INSERT INTO dishingredient (dish_id, food_id, weight_g)
      VALUES ($1, $2, 100)
    `, [dish1.rows[0].dish_id, restricted.rows[0].food_id]);

    console.log(`✓ Created dish "${dish1.rows[0].dish_id}" with restricted ingredient: ${restricted.rows[0].name_vi || restricted.rows[0].name}`);

    // Create test dish with recommended ingredient
    const dish2 = await client.query(`
      INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_public, created_by_admin)
      VALUES ('Test Dish - Recommended', 'Món Test - Khuyến Nghị', 'Contains recommended ingredient', 'Lunch', 200, true, 1)
      RETURNING dish_id
    `);

    await client.query(`
      INSERT INTO dishingredient (dish_id, food_id, weight_g)
      VALUES ($1, $2, 100)
    `, [dish2.rows[0].dish_id, recommended.rows[0].food_id]);

    console.log(`✓ Created dish "${dish2.rows[0].dish_id}" with recommended ingredient: ${recommended.rows[0].name_vi || recommended.rows[0].name}`);

    // Create mixed dish
    const dish3 = await client.query(`
      INSERT INTO dish (name, vietnamese_name, description, category, serving_size_g, is_public, created_by_admin)
      VALUES ('Test Dish - Mixed', 'Món Test - Hỗn Hợp', 'Contains both types', 'Lunch', 200, true, 1)
      RETURNING dish_id
    `);

    await client.query(`
      INSERT INTO dishingredient (dish_id, food_id, weight_g)
      VALUES ($1, $2, 50), ($1, $3, 50)
    `, [dish3.rows[0].dish_id, restricted.rows[0].food_id, recommended.rows[0].food_id]);

    console.log(`✓ Created dish "${dish3.rows[0].dish_id}" with both restricted and recommended ingredients`);

    await client.query('COMMIT');

    console.log('\n✅ Test dishes created successfully!');
    console.log('\n🧪 Test in app:');
    console.log('1. Open Add Meal dialog');
    console.log('2. Switch to "Món Ăn" tab');
    console.log('3. Search for "Test"');
    console.log('4. You should see:');
    console.log('   - "Món Test - Hạn Chế" (faded, opacity 0.45)');
    console.log('   - "Món Test - Khuyến Nghị" (normal, with green badge)');
    console.log('   - "Món Test - Hỗn Hợp" (faded - restricted takes priority)');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

createTestDishes();
