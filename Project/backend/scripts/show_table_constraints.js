const db = require('../db');

async function main() {
  const table = process.argv[2];
  if (!table) {
    console.error('Usage: node scripts/show_table_constraints.js <table_name>');
    process.exit(2);
  }

  const constraints = await db.query(
    `SELECT tc.constraint_name, tc.constraint_type
     FROM information_schema.table_constraints tc
     WHERE tc.table_name = $1
     ORDER BY tc.constraint_type, tc.constraint_name`,
    [table]
  );

  console.log(`Constraints for table: ${table}`);
  console.table(constraints.rows);

  const keyCols = await db.query(
    `SELECT tc.constraint_name, kcu.column_name
     FROM information_schema.table_constraints tc
     JOIN information_schema.key_column_usage kcu
       ON tc.constraint_name = kcu.constraint_name
      AND tc.table_schema = kcu.table_schema
     WHERE tc.table_name = $1
       AND tc.constraint_type IN ('PRIMARY KEY','UNIQUE','FOREIGN KEY')
     ORDER BY tc.constraint_name, kcu.ordinal_position`,
    [table]
  );

  console.log(`\nConstraint columns for table: ${table}`);
  console.table(keyCols.rows);
}

main()
  .then(() => process.exit(0))
  .catch((e) => {
    console.error(e);
    process.exit(1);
  });
