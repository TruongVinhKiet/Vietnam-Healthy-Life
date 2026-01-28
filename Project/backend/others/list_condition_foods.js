const db = require('./db');

async function listConditionFoods() {
  try {
    const q = `
      SELECT hc.condition_id, hc.name_vi, hc.name_en,
             cfr.recommendation_type, cfr.notes,
             f.food_id, f.name as food_name
      FROM ConditionFoodRecommendation cfr
      JOIN HealthCondition hc ON cfr.condition_id = hc.condition_id
      JOIN Food f ON cfr.food_id = f.food_id
      ORDER BY hc.name_vi, cfr.recommendation_type, f.name
    `;

    const res = await db.query(q);
    const map = new Map();

    for (const row of res.rows) {
      const key = `${row.condition_id}::${row.name_vi}`;
      if (!map.has(key)) map.set(key, { condition_id: row.condition_id, name_vi: row.name_vi, name_en: row.name_en, recommendations: [] });
      map.get(key).recommendations.push({
        recommendation_type: row.recommendation_type,
        notes: row.notes,
        food_id: row.food_id,
        food_name: row.food_name
      });
    }

    console.log('=== Condition → Food Recommendations ===\n');
    for (const [k, v] of map.entries()) {
      console.log(`Condition ${v.condition_id}: ${v.name_vi} (${v.name_en || '-'})`);
      const grouped = v.recommendations.reduce((acc, r) => {
        acc[r.recommendation_type] = acc[r.recommendation_type] || [];
        acc[r.recommendation_type].push(r);
        return acc;
      }, {});

      for (const [type, items] of Object.entries(grouped)) {
        console.log(`  - ${type.toUpperCase()}:`);
        for (const it of items) {
          console.log(`     • ${it.food_id}: ${it.food_name}${it.notes ? ' — ' + it.notes : ''}`);
        }
      }
      console.log('');
    }

    if (res.rows.length === 0) console.log('No condition-food recommendations found.');
    process.exit(0);
  } catch (err) {
    console.error('Error listing condition-food recommendations:', err);
    process.exit(1);
  }
}

listConditionFoods();
