/**
 * Daily Meal Suggestion API Test Script
 * Tests all 8 endpoints with actual HTTP requests
 * 
 * Usage: node test_daily_meal_api.js
 */

const axios = require('axios');

// Configuration
const BASE_URL = 'http://localhost:60491';
const API_PATH = '/api/suggestions/daily-meals';

// Test credentials
const TEST_USER = {
  email: 'truongngoclinh312@gmail.com',
  password: 'Abcd@1234'
};

let authToken = null;
let testSuggestionId = null;

// Axios instance with auth
const api = axios.create({
  baseURL: BASE_URL,
  headers: {
    'Content-Type': 'application/json'
  }
});

// Add auth token to requests
api.interceptors.request.use(config => {
  if (authToken) {
    config.headers.Authorization = `Bearer ${authToken}`;
  }
  return config;
});

/**
 * Login and get JWT token
 */
async function login() {
  try {
    console.log('\n🔐 Logging in...');
    const response = await axios.post(`${BASE_URL}/api/auth/login`, {
      email: TEST_USER.email,
      password: TEST_USER.password
    });

    authToken = response.data.token;
    console.log('✅ Login successful');
    console.log('   Token:', authToken.substring(0, 20) + '...');
    return true;
  } catch (error) {
    console.error('❌ Login failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 1: Generate daily suggestions
 */
async function testGenerateSuggestions() {
  try {
    console.log('\n📋 Test 1: Generate Daily Suggestions');
    console.log('   POST /api/suggestions/daily-meals');

    const today = new Date().toISOString().split('T')[0];
    const response = await api.post(API_PATH, {
      date: today
    });

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);
    console.log('   Message:', response.data.message);
    console.log('   Date:', response.data.data?.date);
    
    if (response.data.data?.suggestions) {
      const suggestions = response.data.data.suggestions;
      console.log('   Suggestions generated:');
      console.log('     - Breakfast:', suggestions.breakfast?.length || 0);
      console.log('     - Lunch:', suggestions.lunch?.length || 0);
      console.log('     - Dinner:', suggestions.dinner?.length || 0);
      console.log('     - Snack:', suggestions.snack?.length || 0);
    }

    if (response.data.data?.nutrientGaps) {
      const gaps = response.data.data.nutrientGaps;
      console.log('   Nutrient gaps tracked:', Object.keys(gaps).length);
    }

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    if (error.response?.data?.error) {
      console.error('   Error:', error.response.data.error);
    }
    return false;
  }
}

/**
 * Test 2: Get suggestions for today
 */
async function testGetSuggestions() {
  try {
    console.log('\n📋 Test 2: Get Suggestions');
    console.log('   GET /api/suggestions/daily-meals');

    const today = new Date().toISOString().split('T')[0];
    const response = await api.get(`${API_PATH}?date=${today}`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);

    if (response.data.data) {
      const data = response.data.data;
      console.log('   Retrieved suggestions:');
      console.log('     - Breakfast:', data.breakfast?.length || 0);
      console.log('     - Lunch:', data.lunch?.length || 0);
      console.log('     - Dinner:', data.dinner?.length || 0);
      console.log('     - Snack:', data.snack?.length || 0);

      // Save first suggestion ID for later tests
      if (data.breakfast?.[0]?.id) {
        testSuggestionId = data.breakfast[0].id;
        console.log('   Saved suggestion ID for testing:', testSuggestionId);
        console.log('     Dish:', data.breakfast[0].dish_name);
        console.log('     Score:', data.breakfast[0].suggestion_score);
      }
    }

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 3: Get statistics
 */
async function testGetStats() {
  try {
    console.log('\n📊 Test 3: Get Statistics');
    console.log('   GET /api/suggestions/daily-meals/stats');

    const endDate = new Date().toISOString().split('T')[0];
    const startDate = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

    const response = await api.get(`${API_PATH}/stats?startDate=${startDate}&endDate=${endDate}`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);

    if (response.data.data && response.data.data.length > 0) {
      console.log('   Statistics:');
      response.data.data.forEach(stat => {
        console.log(`     ${stat.meal_type}:`);
        console.log(`       Total: ${stat.total_suggestions}`);
        console.log(`       Accepted: ${stat.accepted_count}`);
        console.log(`       Rejected: ${stat.rejected_count}`);
        console.log(`       Avg Score: ${stat.avg_score}`);
        console.log(`       Days: ${stat.days_with_suggestions}`);
      });
    } else {
      console.log('   No statistics available yet');
    }

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 4: Accept a suggestion
 */
async function testAcceptSuggestion() {
  if (!testSuggestionId) {
    console.log('\n⚠️  Test 4: Accept Suggestion - SKIPPED (no suggestion ID)');
    return true;
  }

  try {
    console.log('\n✔️  Test 4: Accept Suggestion');
    console.log(`   PUT /api/suggestions/daily-meals/${testSuggestionId}/accept`);

    const response = await api.put(`${API_PATH}/${testSuggestionId}/accept`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);
    console.log('   Message:', response.data.message);
    console.log('   Is Accepted:', response.data.data?.is_accepted);

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 5: Reject a suggestion (generates new one)
 */
async function testRejectSuggestion() {
  if (!testSuggestionId) {
    console.log('\n⚠️  Test 5: Reject Suggestion - SKIPPED (no suggestion ID)');
    return true;
  }

  try {
    console.log('\n🔄 Test 5: Reject Suggestion');
    console.log(`   PUT /api/suggestions/daily-meals/${testSuggestionId}/reject`);

    const response = await api.put(`${API_PATH}/${testSuggestionId}/reject`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);
    console.log('   Message:', response.data.message);

    if (response.data.data?.success) {
      console.log('   New suggestion generated');
    }

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 6: Cleanup passed meals
 */
async function testCleanupPassedMeals() {
  try {
    console.log('\n🧹 Test 6: Cleanup Passed Meals');
    console.log('   POST /api/suggestions/daily-meals/cleanup-passed');

    const response = await api.post(`${API_PATH}/cleanup-passed`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);
    console.log('   Message:', response.data.message);

    if (response.data.data) {
      console.log('   Result:', response.data.data.cleanup_passed_meal_suggestions);
    }

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 7: Delete a suggestion
 */
async function testDeleteSuggestion() {
  // Generate a new suggestion to delete
  try {
    console.log('\n🗑️  Test 7: Delete Suggestion');

    // First get a suggestion to delete
    const today = new Date().toISOString().split('T')[0];
    const getSuggestions = await api.get(`${API_PATH}?date=${today}`);

    let deleteId = null;
    if (getSuggestions.data.data?.snack?.[0]?.id) {
      deleteId = getSuggestions.data.data.snack[0].id;
    } else if (getSuggestions.data.data?.breakfast?.[0]?.id) {
      deleteId = getSuggestions.data.data.breakfast[0].id;
    }

    if (!deleteId) {
      console.log('   ⚠️  No suggestion to delete');
      return true;
    }

    console.log(`   DELETE /api/suggestions/daily-meals/${deleteId}`);

    const response = await api.delete(`${API_PATH}/${deleteId}`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);
    console.log('   Message:', response.data.message);

    return true;
  } catch (error) {
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Test 8: Cleanup old suggestions (admin only)
 */
async function testCleanupOldSuggestions() {
  try {
    console.log('\n🧹 Test 8: Cleanup Old Suggestions (Admin)');
    console.log('   POST /api/suggestions/daily-meals/cleanup');

    const response = await api.post(`${API_PATH}/cleanup`);

    console.log('✅ Status:', response.status);
    console.log('   Success:', response.data.success);
    console.log('   Message:', response.data.message);

    if (response.data.data) {
      console.log('   Result:', response.data.data);
    }

    return true;
  } catch (error) {
    // Expected to fail if user is not admin
    if (error.response?.status === 403) {
      console.log('⚠️  Expected failure - User is not admin');
      console.log('   Message:', error.response.data.message);
      return true;
    }
    console.error('❌ Failed:', error.response?.data?.message || error.message);
    return false;
  }
}

/**
 * Run all tests
 */
async function runAllTests() {
  console.log('═══════════════════════════════════════════════════════════');
  console.log('  Daily Meal Suggestions - API Integration Tests');
  console.log('═══════════════════════════════════════════════════════════');

  // Login first
  const loginSuccess = await login();
  if (!loginSuccess) {
    console.log('\n❌ Cannot continue without authentication');
    return;
  }

  // Run tests in sequence
  const tests = [
    testGenerateSuggestions,
    testGetSuggestions,
    testGetStats,
    testAcceptSuggestion,
    testRejectSuggestion,
    testCleanupPassedMeals,
    testDeleteSuggestion,
    testCleanupOldSuggestions
  ];

  let passed = 0;
  let failed = 0;

  for (const test of tests) {
    const result = await test();
    if (result) {
      passed++;
    } else {
      failed++;
    }
    // Wait a bit between tests
    await new Promise(resolve => setTimeout(resolve, 500));
  }

  // Summary
  console.log('\n═══════════════════════════════════════════════════════════');
  console.log('  Test Summary');
  console.log('═══════════════════════════════════════════════════════════');
  console.log(`  Total Tests: ${passed + failed}`);
  console.log(`  ✅ Passed: ${passed}`);
  console.log(`  ❌ Failed: ${failed}`);
  console.log('═══════════════════════════════════════════════════════════\n');
}

// Run tests
runAllTests().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
