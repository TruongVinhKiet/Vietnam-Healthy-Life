const express = require('express');
const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

const app = express();
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_DATABASE || 'Health',
});

app.get('/api/suggestions/user-food-recommendations', async (req, res) => {
  try {
    const userId = 1; // Hardcoded for testing

    // Get user's active health conditions (with treatment_end_date check)
    const conditionsResult = await pool.query(`
      SELECT DISTINCT hc.condition_id, hc.name_vi
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 
        AND uhc.status = 'active'
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= CURRENT_DATE)
    `, [userId]);

    if (conditionsResult.rows.length === 0) {
      return res.json({
        success: true,
        foods_to_avoid: [],
        foods_to_recommend: [],
        conditions: []
      });
    }

    const conditionIds = conditionsResult.rows.map(c => c.condition_id);

    // Get foods to avoid for user's conditions
    const avoidResult = await pool.query(`
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
      ORDER BY f.name_vi
    `, [conditionIds]);

    // Get foods to recommend for user's conditions
    const recommendResult = await pool.query(`
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
      ORDER BY f.name_vi
    `, [conditionIds]);

    const response = {
      success: true,
      foods_to_avoid: avoidResult.rows,
      foods_to_recommend: recommendResult.rows,
      conditions: conditionsResult.rows
    };

    console.log('\n✅ API Response:');
    console.log(JSON.stringify(response, null, 2));

    res.json(response);

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy khuyến nghị thực phẩm',
      error: error.message
    });
  }
});

const PORT = 60491;
const server = app.listen(PORT, () => {
  console.log(`🚀 Test server running on http://localhost:${PORT}`);
  console.log(`📍 Endpoint: /api/suggestions/user-food-recommendations`);
  
  // Auto-request after 1 second
  setTimeout(() => {
    const http = require('http');
    http.get(`http://localhost:${PORT}/api/suggestions/user-food-recommendations`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log('\n📥 CLIENT RECEIVED:');
        const parsed = JSON.parse(data);
        console.log(`   Conditions: ${parsed.conditions?.length || 0}`);
        console.log(`   Foods to avoid: ${parsed.foods_to_avoid?.length || 0}`);
        console.log(`   Foods to recommend: ${parsed.foods_to_recommend?.length || 0}`);
        
        console.log('\n🔴 Foods to avoid IDs:', parsed.foods_to_avoid?.map(f => f.food_id));
        console.log('✅ Foods to recommend IDs:', parsed.foods_to_recommend?.map(f => f.food_id));
        
        setTimeout(() => {
          server.close();
          pool.end();
          process.exit(0);
        }, 100);
      });
    }).on('error', (e) => {
      console.error('Request error:', e);
      server.close();
      pool.end();
      process.exit(1);
    });
  }, 1000);
});
