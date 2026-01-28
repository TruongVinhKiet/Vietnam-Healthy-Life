const db = require('./db');

async function run() {
  try {
    const userId = 9;
    const code = 'VITC'; // Vitamin C
    const amount = 75; // mg
    const today = new Date().toISOString().split('T')[0];

    // find vitamin id
    const vit = await db.query(`SELECT vitamin_id, unit FROM Vitamin WHERE UPPER(code) = UPPER($1) LIMIT 1`, [code]);
    if (vit.rows.length === 0) {
      console.error('Vitamin code not found:', code);
      process.exit(1);
    }
    const vitaminId = vit.rows[0].vitamin_id;
    const unit = vit.rows[0].unit || 'mg';

    console.log('Upserting tracking for', code, 'id', vitaminId, 'unit', unit);

    await db.query(`
      INSERT INTO UserNutrientTracking (user_id, nutrient_id, date, nutrient_type, current_amount, unit, last_updated)
      VALUES ($1, $2, $3, 'vitamin', $4, $5, NOW())
      ON CONFLICT (user_id, date, nutrient_type, nutrient_id)
      DO UPDATE SET current_amount = EXCLUDED.current_amount, last_updated = NOW()
    `, [userId, vitaminId, today, amount, unit]);

    console.log('Inserted/updated current_amount for', code, 'to', amount);
    process.exit(0);
  } catch (e) {
    console.error('Error:', e);
    process.exit(1);
  }
}

run();
