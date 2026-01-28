const db = require('../db');
const settingService = require('./settingService');

async function getTargetsForDate(userId, date) {
  // date: 'YYYY-MM-DD'
  const res = await db.query('SELECT * FROM user_meal_targets WHERE user_id = $1 AND target_date = $2', [userId, date]);
  if (res.rows.length > 0) return res.rows;

  // if not present, compute defaults from UserSetting percentages and UserProfile daily targets
  const settings = await settingService.getSettings(userId);
  const pctBreakfast = settings && settings.meal_pct_breakfast != null ? Number(settings.meal_pct_breakfast) : 25.0;
  const pctLunch = settings && settings.meal_pct_lunch != null ? Number(settings.meal_pct_lunch) : 35.0;
  const pctSnack = settings && settings.meal_pct_snack != null ? Number(settings.meal_pct_snack) : 10.0;
  const pctDinner = settings && settings.meal_pct_dinner != null ? Number(settings.meal_pct_dinner) : 30.0;

  // fetch user's daily profile targets from UserProfile (join UserProfile)
  const pf = await db.query('SELECT daily_calorie_target, daily_carb_target, daily_protein_target, daily_fat_target FROM UserProfile WHERE user_id = $1 LIMIT 1', [userId]);
  const profile = pf.rows[0] || { daily_calorie_target: 0, daily_carb_target: 0, daily_protein_target: 0, daily_fat_target: 0 };

  const make = (mealType, pct) => ({
    user_id: userId,
    target_date: date,
    meal_type: mealType,
    target_kcal: Math.round((Number(profile.daily_calorie_target || 0) * (pct / 100.0)) * 100) / 100,
    target_carbs: Math.round((Number(profile.daily_carb_target || 0) * (pct / 100.0)) * 100) / 100,
    target_protein: Math.round((Number(profile.daily_protein_target || 0) * (pct / 100.0)) * 100) / 100,
    target_fat: Math.round((Number(profile.daily_fat_target || 0) * (pct / 100.0)) * 100) / 100,
  });

  return [
    make('breakfast', pctBreakfast),
    make('lunch', pctLunch),
    make('snack', pctSnack),
    make('dinner', pctDinner),
  ];
}

async function upsertTargets(userId, date, targets = []) {
  // targets: array of objects { meal_type, target_kcal, target_carbs, target_protein, target_fat }
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    for (const t of targets) {
      const q = `INSERT INTO user_meal_targets (user_id, target_date, meal_type, target_kcal, target_carbs, target_protein, target_fat, created_at, updated_at)
        VALUES ($1,$2,$3,$4,$5,$6,$7, now(), now())
        ON CONFLICT (user_id, target_date, meal_type) DO UPDATE SET target_kcal = EXCLUDED.target_kcal, target_carbs = EXCLUDED.target_carbs, target_protein = EXCLUDED.target_protein, target_fat = EXCLUDED.target_fat, updated_at = now()`;
      const params = [userId, date, t.meal_type, t.target_kcal || 0, t.target_carbs || 0, t.target_protein || 0, t.target_fat || 0];
      await client.query(q, params);
    }
    await client.query('COMMIT');
    const res = await client.query('SELECT * FROM user_meal_targets WHERE user_id = $1 AND target_date = $2 ORDER BY meal_type', [userId, date]);
    return res.rows;
  } catch (err) {
    await client.query('ROLLBACK').catch(()=>{});
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { getTargetsForDate, upsertTargets };
