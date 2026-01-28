require('dotenv').config();
const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

async function main() {
  const fileArg = process.argv[2];
  if (!fileArg) {
    console.error('Usage: node apply_sql_file.js <path/to/file.sql>');
    process.exit(1);
  }

  const filePath = path.isAbsolute(fileArg) ? fileArg : path.join(process.cwd(), fileArg);
  if (!fs.existsSync(filePath)) {
    console.error('SQL file not found:', filePath);
    process.exit(1);
  }

  const sql = fs.readFileSync(filePath, 'utf8');

  const connectionString = process.env.DATABASE_URL || null;
  const clientConfig = connectionString
    ? { connectionString }
    : {
        host: process.env.DB_HOST || 'localhost',
        port: process.env.DB_PORT ? parseInt(process.env.DB_PORT, 10) : 5432,
        user: process.env.DB_USER || process.env.PGUSER,
        password: process.env.DB_PASSWORD || process.env.PGPASSWORD,
        database: process.env.DB_NAME || process.env.PGDATABASE,
      };

  const client = new Client(clientConfig);

  try {
    await client.connect();
    console.log('Connected to DB. Applying', filePath);
    await client.query('BEGIN');
    // split by $$; preserve function bodies by executing whole file in one query
    await client.query(sql);
    await client.query('COMMIT');
    console.log('SQL file applied successfully');
  } catch (err) {
    try { await client.query('ROLLBACK'); } catch (e) {}
    console.error('Error applying SQL file:', err.message || err);
    process.exitCode = 2;
  } finally {
    await client.end().catch(()=>{});
  }
}

main();
