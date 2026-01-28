// Test script for medication API
const axios = require('axios');

const BASE_URL = 'http://localhost:60491';

async function testMedicationAPI() {
  try {
    console.log('🔐 Step 1: Login as user...');
    const loginResponse = await axios.post(`${BASE_URL}/auth/login`, {
      identifier: 'truonghoankiet1@gmail.com',
      password: '123456'
    });
    
    const token = loginResponse.data.token;
    const userId = loginResponse.data.user.user_id;
    console.log(`✅ Logged in as User ID: ${userId}\n`);

    console.log('📋 Step 2: Get user conditions...');
    const conditionsResponse = await axios.get(`${BASE_URL}/api/health-conditions/user`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log(`Found ${conditionsResponse.data.conditions?.length || 0} conditions:`);
    conditionsResponse.data.conditions?.forEach(c => {
      console.log(`  - ${c.condition_name} (ID: ${c.condition_id}, Status: ${c.status})`);
    });
    console.log('');

    // Test với condition_id = 1 (Tiểu đường type 2)
    console.log('💊 Step 3: Get drugs for Condition 1 (Tiểu đường type 2)...');
    const drugsResponse = await axios.get(`${BASE_URL}/api/medications/conditions/1/drugs`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log(`\n✅ Found ${drugsResponse.data.drugs?.length || 0} drugs:\n`);
    drugsResponse.data.drugs?.forEach(drug => {
      console.log(`📌 ${drug.name_vi}`);
      console.log(`   - Generic: ${drug.generic_name || 'N/A'}`);
      console.log(`   - Primary: ${drug.is_primary ? '✓ YES' : '✗ No'}`);
      console.log(`   - Conditions: ${drug.conditions?.length || 0}`);
      console.log('');
    });

  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

testMedicationAPI();
