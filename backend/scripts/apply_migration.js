const fs = require('fs');
const path = require('path');
const db = require('../db');

async function main() {
  const fileArg = process.argv[2] || path.resolve(__dirname, '../migrations/2025_add_essential_amino_acids.sql');
  if (!fs.existsSync(fileArg)) {
    console.error('Migration file not found:', fileArg);
    process.exit(2);
  }
  const sql = fs.readFileSync(fileArg, 'utf8');
  try {
    console.log('Applying migration', fileArg);
    // Send the whole SQL file to the DB; pg supports multiple statements in one query
    await db.query(sql);
    console.log('Migration applied successfully');
    process.exit(0);
  } catch (e) {
    console.error('Migration failed:', e && e.message);
    process.exit(1);
  }
}

main();
