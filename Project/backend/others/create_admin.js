const bcrypt = require('bcrypt');
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

(async () => {
  try {
    const hash = await bcrypt.hash('admin123', 10);
    await pool.query(
      `INSERT INTO admin (email, password_hash, name, role) 
       VALUES ('admin', $1, 'Admin User', 'super_admin') 
       ON CONFLICT (email) DO UPDATE SET password_hash = $1`,
      [hash]
    );
    console.log('✓ Admin created/updated (email: admin, password: admin123)');
  } catch (e) {
    console.log('✗ Error:', e.message);
  } finally {
    await pool.end();
  }
})();
