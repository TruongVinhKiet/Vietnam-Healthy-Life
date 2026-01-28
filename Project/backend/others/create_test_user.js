const db = require('./db');
const bcrypt = require('bcryptjs');

async function createTestUser() {
  try {
    const hashedPassword = await bcrypt.hash('test123', 10);
    
    const result = await db.query(`
      INSERT INTO "User" (full_name, email, password_hash, age, gender, height_cm, weight_kg)
      VALUES ($1, $2, $3, $4, $5, $6, $7)
      ON CONFLICT (email) DO UPDATE SET
        password_hash = EXCLUDED.password_hash
      RETURNING user_id, email
    `, ['Test User', 'testuser@example.com', hashedPassword, 25, 'male', 170, 70]);
    
    console.log('✅ Test user created/updated:');
    console.log(`   Email: testuser@example.com`);
    console.log(`   Password: test123`);
    console.log(`   User ID: ${result.rows[0].user_id}`);
  } catch (error) {
    console.error('Error creating test user:', error);
  }
}

createTestUser();
