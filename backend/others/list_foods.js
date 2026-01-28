const db = require('./db');

async function listFoods() {
  try {
    const foods = await db.query('SELECT food_id, name FROM food ORDER BY food_id');
    console.log('Available foods in database:\n');
    foods.rows.forEach(f => {
      console.log(`${f.food_id}: ${f.name}`);
    });
    process.exit(0);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

listFoods();
