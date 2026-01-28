const db = require('../db');

async function main() {
  const table = process.argv[2];
  if (!table) {
    console.error('Usage: node scripts/show_table_columns.js <table_name>');
    process.exit(2);
  }

  const res = await db.query(
    `SELECT column_name, data_type, is_nullable
     FROM information_schema.columns
     WHERE table_name = $1
     ORDER BY ordinal_position`,
    [table]
  );

  console.log(`Columns for table: ${table}`);
  console.table(res.rows);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
