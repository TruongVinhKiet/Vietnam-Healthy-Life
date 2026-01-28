const db = require('./db');

async function listDishTables() {
  try {
    const result = await db.query(`
      SELECT table_name, table_type
      FROM information_schema.tables
      WHERE table_schema = 'public'
      AND (table_name LIKE '%dish%' OR table_name LIKE '%Dish%')
      ORDER BY table_name;
    `);
    
    console.log('Tables containing "dish":');
    result.rows.forEach(row => {
      console.log(`  - ${row.table_name} (${row.table_type})`);
    });
    
    // Check columns in dish table
    const colResult = await db.query(`
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_name = 'dish'
      ORDER BY ordinal_position
      LIMIT 15;
    `);
    
    console.log('\nColumns in "dish" table:');
    colResult.rows.forEach(row => {
      console.log(`  - ${row.column_name} (${row.data_type})`);
    });
    
    process.exit(0);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

listDishTables();
