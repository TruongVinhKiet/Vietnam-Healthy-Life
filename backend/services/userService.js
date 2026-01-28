const db = require('../db');

// Helper to merge user and profile rows into single object
function mergeUserAndProfile(userRow, profileRow) {
  if (!userRow) return null;
  const merged = Object.assign({}, userRow);
  if (profileRow) {
    for (const k of Object.keys(profileRow)) {
      if (k === 'user_id') continue;
      merged[k] = profileRow[k];
    }
  }
  return merged;
}

async function createUser({ full_name, email, password_hash, age, gender, height_cm, weight_kg }) {
  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    const q = `INSERT INTO "User" (full_name, email, password_hash, age, gender, height_cm, weight_kg) VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING user_id, full_name, email, age, gender, height_cm, weight_kg, created_at, password_hash`;
    const values = [full_name || null, email, password_hash, age || null, gender || null, height_cm || null, weight_kg || null];
    const res = await client.query(q, values);
    const user = res.rows[0];
    // ensure a UserProfile row exists
    await client.query('INSERT INTO UserProfile(user_id) VALUES ($1) ON CONFLICT DO NOTHING', [user.user_id]);
    const profRes = await client.query('SELECT * FROM UserProfile WHERE user_id = $1 LIMIT 1', [user.user_id]);
    await client.query('COMMIT');
    return mergeUserAndProfile(user, profRes.rows[0]);
  } catch (err) {
    await client.query('ROLLBACK').catch(()=>{});
    throw err;
  } finally {
    client.release();
  }
}

async function findByEmail(email) {
  const q = `SELECT u.*, up.activity_level, up.diet_type, up.allergies, up.health_goals, up.goal_type, up.goal_weight, up.activity_factor, up.bmr, up.tdee, up.daily_calorie_target, up.daily_protein_target, up.daily_fat_target, up.daily_carb_target, up.daily_water_target
             FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id WHERE u.email = $1 LIMIT 1`;
  const res = await db.query(q, [email]);
  return res.rows[0];
}

async function findByEmailOrName(identifier) {
  const q = `SELECT u.*, up.activity_level, up.diet_type, up.allergies, up.health_goals, up.goal_type, up.goal_weight, up.activity_factor, up.bmr, up.tdee, up.daily_calorie_target, up.daily_protein_target, up.daily_fat_target, up.daily_carb_target, up.daily_water_target
             FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id WHERE u.email = $1 OR u.full_name = $1 LIMIT 1`;
  const res = await db.query(q, [identifier]);
  return res.rows[0];
}

async function findById(id) {
  const q = `SELECT u.*, up.activity_level, up.diet_type, up.allergies, up.health_goals, up.goal_type, up.goal_weight, up.activity_factor, up.bmr, up.tdee, up.daily_calorie_target, up.daily_protein_target, up.daily_fat_target, up.daily_carb_target, up.daily_water_target
             FROM "User" u LEFT JOIN UserProfile up ON up.user_id = u.user_id WHERE u.user_id = $1 LIMIT 1`;
  const res = await db.query(q, [id]);
  return res.rows[0];
}

/**
 * Update a user with the provided fields. Allowed fields: full_name, email, age, gender, height_cm, weight_kg
 * Returns the updated user row (excluding password_hash).
 */
async function updateUser(userId, fields = {}) {
  // Split fields between User and UserProfile
  const userAllowed = ['full_name', 'email', 'age', 'gender', 'height_cm', 'weight_kg', 'password_hash', 'avatar_url'];
  const profileAllowed = ['activity_level', 'diet_type', 'allergies', 'health_goals', 'goal_type', 'goal_weight', 'activity_factor', 'bmr', 'tdee', 'daily_calorie_target', 'daily_protein_target', 'daily_fat_target', 'daily_carb_target', 'daily_water_target'];

  const userFields = {};
  const profileFields = {};
  for (const k of Object.keys(fields)) {
    if (userAllowed.includes(k)) userFields[k] = fields[k];
    if (profileAllowed.includes(k)) profileFields[k] = fields[k];
  }

  const client = await db.pool.connect();
  try {
    await client.query('BEGIN');
    if (Object.keys(userFields).length > 0) {
      const keys = Object.keys(userFields);
      const setClauses = keys.map((k, i) => `"${k}" = $${i + 1}`);
      const values = keys.map(k => userFields[k]);
      const q = `UPDATE "User" SET ${setClauses.join(', ')} WHERE user_id = $${keys.length + 1} RETURNING user_id, full_name, email, age, gender, height_cm, weight_kg, created_at`;
      await client.query(q, [...values, userId]);
    }

    if (Object.keys(profileFields).length > 0) {
      // ensure profile row exists
      await client.query('INSERT INTO UserProfile(user_id) VALUES ($1) ON CONFLICT DO NOTHING', [userId]);
      const keys = Object.keys(profileFields);
      const setClauses = keys.map((k, i) => `${k} = $${i + 1}`);
      const values = keys.map(k => profileFields[k]);
      const q = `UPDATE UserProfile SET ${setClauses.join(', ')} WHERE user_id = $${keys.length + 1} RETURNING *`;
      await client.query(q, [...values, userId]);
    }

    await client.query('COMMIT');
    // return fresh merged row
    const fresh = await findById(userId);
    return fresh;
  } catch (err) {
    await client.query('ROLLBACK').catch(()=>{});
    throw err;
  } finally {
    client.release();
  }
}

module.exports = { createUser, findByEmail, findByEmailOrName, findById, updateUser };
