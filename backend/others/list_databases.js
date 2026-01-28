const { Pool } = require('pg');
require('dotenv').config();

console.log('📋 Current connection config:');
console.log(`  Host: ${process.env.DB_HOST}`);
console.log(`  Port: ${process.env.DB_PORT}`);
console.log(`  Database: ${process.env.DB_NAME}`);
console.log(`  User: ${process.env.DB_USER}\n`);

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function listDatabases() {
  const client = await pool.connect();
  
  try {
    console.log('🗄️  AVAILABLE DATABASES:\n');
    
    const result = await client.query(`
      SELECT datname, pg_size_pretty(pg_database_size(datname)) as size
      FROM pg_database
      WHERE datistemplate = false
      ORDER BY datname
    `);
    
    console.table(result.rows);
    
    console.log('\n💡 Suggestion:');
    console.log('   Nếu bạn thấy database "Health" có size lớn, đó là database cũ với 79 tables.');
    console.log('   Kiểm tra file .env xem DB_NAME có đúng không.\n');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    client.release();
    await pool.end();
  }
}

listDatabases();
