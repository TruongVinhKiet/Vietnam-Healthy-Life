const db = require("../db");

// ============================================================
// USER MANAGEMENT
// ============================================================

// Get all users with pagination and search
async function getUsers(req, res) {
  try {
    const { page = 1, limit = 20, search = "" } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        u.user_id, u.full_name, u.email, u.age, u.gender, 
        u.height_cm, u.weight_kg, u.created_at, u.last_login,
        u.avatar_url,
        COALESCE(uas.is_blocked, FALSE) AS is_blocked,
        uas.blocked_reason,
        up.activity_level, up.diet_type, up.goal_type,
        up.daily_calorie_target, up.daily_protein_target,
        up.daily_fat_target, up.daily_carb_target
      FROM "User" u
      LEFT JOIN UserProfile up ON u.user_id = up.user_id
      LEFT JOIN user_account_status uas ON u.user_id = uas.user_id
    `;

    const params = [];
    if (search) {
      query += ` WHERE u.full_name ILIKE $1 OR u.email ILIKE $1`;
      params.push(`%${search}%`);
    }

    query += ` ORDER BY u.created_at DESC LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await db.query(query, params);

    // Get total count
    let countQuery = 'SELECT COUNT(*) FROM "User" u';
    const countParams = [];
    if (search) {
      countQuery += ` WHERE u.full_name ILIKE $1 OR u.email ILIKE $1`;
      countParams.push(`%${search}%`);
    }
    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      users: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (err) {
    console.error("Error getting users:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Get user details by ID
async function getUserDetails(req, res) {
  try {
    const { id } = req.params;

    const userQuery = `
      SELECT 
        u.*, up.*, uas.is_blocked, uas.blocked_reason, uas.blocked_at,
        us.theme, us.language, us.font_size, us.unit_system,
        us.seasonal_ui_enabled, us.weather_enabled
      FROM "User" u
      LEFT JOIN UserProfile up ON u.user_id = up.user_id
      LEFT JOIN UserSetting us ON u.user_id = us.user_id
      LEFT JOIN user_account_status uas ON u.user_id = uas.user_id
      WHERE u.user_id = $1
    `;
    const userResult = await db.query(userQuery, [id]);

    if (userResult.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy người dùng" });
    }

    // Get user's recent meals from meal_entries (more accurate)
    const mealsQuery = `
      SELECT 
        entry_date as meal_date,
        meal_type,
        COUNT(*)::INTEGER as item_count,
        COALESCE(SUM(kcal), 0)::NUMERIC(10,2) as total_calories,
        MAX(created_at) as created_at
      FROM meal_entries
      WHERE user_id = $1
      GROUP BY entry_date, meal_type
      ORDER BY entry_date DESC, created_at DESC
      LIMIT 10
    `;
    const mealsResult = await db.query(mealsQuery, [id]);

    // Get user's daily summaries
    const summaryQuery = `
      SELECT * FROM DailySummary
      WHERE user_id = $1
      ORDER BY date DESC
      LIMIT 7
    `;
    const summaryResult = await db.query(summaryQuery, [id]);

    res.json({
      user: userResult.rows[0],
      recentMeals: mealsResult.rows,
      recentSummaries: summaryResult.rows,
    });
  } catch (err) {
    console.error("Error getting user details:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Block a user
async function blockUser(req, res) {
  try {
    const { id } = req.params;
    const { reason } = req.body || {};
    const adminId = req.admin && req.admin.admin_id;
    // ensure user exists
    const exists = await db.query('SELECT user_id FROM "User" WHERE user_id = $1 LIMIT 1', [id]);
    if (exists.rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy người dùng' });
    // insert/update status
    await db.query(`INSERT INTO user_account_status(user_id, is_blocked, blocked_reason, blocked_at, blocked_by_admin)
      VALUES ($1, TRUE, $2, now(), $3)
      ON CONFLICT (user_id) DO UPDATE SET is_blocked = TRUE, blocked_reason = EXCLUDED.blocked_reason, blocked_at = now(), blocked_by_admin = EXCLUDED.blocked_by_admin, updated_at = now()`, [id, reason || null, adminId || null]);
    await db.query('INSERT INTO user_block_event(user_id, event_type, reason, admin_id) VALUES ($1, $2, $3, $4)', [id, 'block', reason || null, adminId || null]);
    return res.json({ message: 'Đã chặn người dùng', user_id: Number(id) });
  } catch (err) {
    console.error('blockUser error', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// Unblock a user (direct by admin)
async function unblockUser(req, res) {
  try {
    const { id } = req.params;
    const { admin_response } = req.body || {};
    const adminId = req.admin && req.admin.admin_id;
    const exists = await db.query('SELECT user_id FROM "User" WHERE user_id = $1 LIMIT 1', [id]);
    if (exists.rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy người dùng' });
    await db.query(`INSERT INTO user_account_status(user_id, is_blocked) VALUES ($1, FALSE)
      ON CONFLICT (user_id) DO UPDATE SET is_blocked = FALSE, blocked_reason = NULL, blocked_at = NULL, blocked_by_admin = NULL, updated_at = now()`, [id]);
    await db.query('INSERT INTO user_block_event(user_id, event_type, reason, admin_id) VALUES ($1,$2,$3,$4)', [id, 'unblock', admin_response || null, adminId || null]);
    return res.json({ message: 'Đã gỡ chặn người dùng', user_id: Number(id) });
  } catch (err) {
    console.error('unblockUser error', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// List unblock requests
async function getUnblockRequests(req, res) {
  try {
    const { status = 'pending' } = req.query;
    const rows = await db.query(`SELECT r.*, u.full_name, u.email FROM user_unblock_request r JOIN "User" u ON u.user_id = r.user_id WHERE ($1 = 'all' OR r.status = $1) ORDER BY r.created_at DESC LIMIT 200`, [status]);
    return res.json({ requests: rows.rows });
  } catch (err) {
    console.error('getUnblockRequests error', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// Decide unblock request
async function decideUnblockRequest(req, res) {
  try {
    const { id } = req.params; // request id
    const { decision, admin_response } = req.body || {}; // decision: approve / reject
    if (!decision || !['approve','reject'].includes(decision)) return res.status(400).json({ error: 'decision phải là approve hoặc reject' });
    const adminId = req.admin && req.admin.admin_id;
    const rqRes = await db.query('SELECT * FROM user_unblock_request WHERE request_id = $1 LIMIT 1', [id]);
    if (rqRes.rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy yêu cầu' });
    const rq = rqRes.rows[0];
    if (rq.status !== 'pending') return res.status(409).json({ error: 'Yêu cầu đã được xử lý' });
    const newStatus = decision === 'approve' ? 'approved' : 'rejected';
    await db.query('UPDATE user_unblock_request SET status = $1, admin_response = $2, decided_at = now(), decided_by_admin = $3 WHERE request_id = $4', [newStatus, admin_response || null, adminId || null, id]);
    if (newStatus === 'approved') {
      // unblock user
      await db.query(`INSERT INTO user_account_status(user_id, is_blocked) VALUES ($1, FALSE)
        ON CONFLICT (user_id) DO UPDATE SET is_blocked = FALSE, blocked_reason = NULL, blocked_at = NULL, blocked_by_admin = NULL, updated_at = now()`, [rq.user_id]);
      await db.query('INSERT INTO user_block_event(user_id, event_type, reason, admin_id) VALUES ($1,$2,$3,$4)', [rq.user_id, 'unblock', 'approved request', adminId || null]);
    }
    return res.json({ message: 'Đã xử lý yêu cầu', status: newStatus });
  } catch (err) {
    console.error('decideUnblockRequest error', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// Delete user
async function deleteUser(req, res) {
  try {
    const { id } = req.params;

    const result = await db.query(
      'DELETE FROM "User" WHERE user_id = $1 RETURNING user_id',
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy người dùng" });
    }

    res.json({
      message: "Xóa người dùng thành công",
      userId: result.rows[0].user_id,
    });
  } catch (err) {
    console.error("Error deleting user:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// ============================================================
// FOOD MANAGEMENT
// ============================================================

// Get all foods with pagination and search
async function getFoods(req, res) {
  try {
    const { page = 1, limit = 20, search = "", category = "" } = req.query;
    const offset = (page - 1) * limit;

    let query = `SELECT * FROM Food WHERE 1=1`;
    const params = [];

    if (search) {
      params.push(`%${search}%`);
      query += ` AND name ILIKE $${params.length}`;
    }

    if (category) {
      params.push(category);
      query += ` AND category = $${params.length}`;
    }

    query += ` ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await db.query(query, params);

    // Get total count
    let countQuery = "SELECT COUNT(*) FROM Food WHERE 1=1";
    const countParams = [];
    if (search) {
      countParams.push(`%${search}%`);
      countQuery += ` AND name ILIKE $${countParams.length}`;
    }
    if (category) {
      countParams.push(category);
      countQuery += ` AND category = $${countParams.length}`;
    }

    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      foods: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (err) {
    console.error("Error getting foods:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Get food details with all nutrients
async function getFoodDetails(req, res) {
  try {
    const { id } = req.params;

    // Get food info
    const foodQuery = "SELECT * FROM Food WHERE food_id = $1";
    const foodResult = await db.query(foodQuery, [id]);

    if (foodResult.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy thực phẩm" });
    }

    // Get all nutrients for this food
    const nutrientsQuery = `
      SELECT fn.*, n.name as nutrient_name, n.unit, n.nutrient_code
      FROM FoodNutrient fn
      JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
      WHERE fn.food_id = $1
      ORDER BY n.name
    `;
    const nutrientsResult = await db.query(nutrientsQuery, [id]);

    res.json({
      food: foodResult.rows[0],
      nutrients: nutrientsResult.rows,
    });
  } catch (err) {
    console.error("Error getting food details:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Create or update food
async function upsertFood(req, res) {
  try {
    const { food_id, name, category, image_url, nutrients } = req.body;

    if (!name) {
      return res.status(400).json({ error: "Tên thực phẩm là bắt buộc" });
    }

    const adminId = req.admin_id; // from auth middleware

    let foodResult;
    if (food_id) {
      // Update existing food
      foodResult = await db.query(
        "UPDATE Food SET name = $1, category = $2, image_url = $3 WHERE food_id = $4 RETURNING *",
        [name, category, image_url, food_id]
      );
    } else {
      // Create new food
      foodResult = await db.query(
        "INSERT INTO Food (name, category, image_url, created_by_admin) VALUES ($1, $2, $3, $4) RETURNING *",
        [name, category, image_url, adminId]
      );
    }

    const savedFood = foodResult.rows[0];

    // Update nutrients if provided
    if (nutrients && Array.isArray(nutrients)) {
      // Delete old nutrients
      await db.query("DELETE FROM FoodNutrient WHERE food_id = $1", [
        savedFood.food_id,
      ]);

      // Insert new nutrients
      for (const nutrient of nutrients) {
        if (nutrient.nutrient_id && nutrient.amount_per_100g != null) {
          await db.query(
            "INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES ($1, $2, $3)",
            [savedFood.food_id, nutrient.nutrient_id, nutrient.amount_per_100g]
          );
        }
      }
    }

    res.json({ food: savedFood, message: "Lưu thực phẩm thành công" });
  } catch (err) {
    console.error("Error upserting food:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Delete food
async function deleteFood(req, res) {
  try {
    const { id } = req.params;

    const result = await db.query(
      "DELETE FROM Food WHERE food_id = $1 RETURNING food_id",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy thực phẩm" });
    }

    res.json({ message: "Xóa thực phẩm thành công" });
  } catch (err) {
    console.error("Error deleting food:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// ============================================================
// NUTRIENT MANAGEMENT
// ============================================================

// Get all nutrients
async function getNutrients(req, res) {
  try {
    const { page = 1, limit = 50, search = "" } = req.query;
    const offset = (page - 1) * limit;

    let query = "SELECT * FROM Nutrient WHERE 1=1";
    const params = [];

    if (search) {
      params.push(`%${search}%`);
      query += ` AND name ILIKE $${params.length}`;
    }

    query += ` ORDER BY name LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    params.push(limit, offset);

    const result = await db.query(query, params);

    // Get total count
    let countQuery = "SELECT COUNT(*) FROM Nutrient WHERE 1=1";
    const countParams = [];
    if (search) {
      countParams.push(`%${search}%`);
      countQuery += ` AND name ILIKE $${countParams.length}`;
    }

    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      nutrients: result.rows,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (err) {
    console.error("Error getting nutrients:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Get nutrient details with foods ranked by amount and contraindications
async function getNutrientDetails(req, res) {
  try {
    const { id } = req.params;
    const { limit = 50 } = req.query;

    // Get nutrient info
    const nutrientQuery = "SELECT * FROM Nutrient WHERE nutrient_id = $1";
    const nutrientResult = await db.query(nutrientQuery, [id]);

    if (nutrientResult.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy chất dinh dưỡng" });
    }

    // Get foods ranked by this nutrient (highest to lowest)
    const foodsQuery = `
      SELECT f.food_id, f.name, f.category, f.image_url,
             fn.amount_per_100g,
             n.unit
      FROM FoodNutrient fn
      JOIN Food f ON fn.food_id = f.food_id
      JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
      WHERE fn.nutrient_id = $1
      ORDER BY fn.amount_per_100g DESC
      LIMIT $2
    `;
    const foodsResult = await db.query(foodsQuery, [id, limit]);

    // Get contraindications if table exists
    let contraindications = [];
    try {
      const contraRes = await db.query(
        `SELECT condition_name, note FROM NutrientContraindication WHERE nutrient_id = $1 ORDER BY condition_name`,
        [id]
      );
      contraindications = contraRes.rows;
    } catch (e) {
      // table may not exist yet; ignore
      contraindications = [];
    }

    res.json({
      nutrient: nutrientResult.rows[0],
      foods: foodsResult.rows,
      contraindications,
    });
  } catch (err) {
    console.error("Error getting nutrient details:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Create or update nutrient (supports group_name, image_url, benefits, contraindications[])
async function upsertNutrient(req, res) {
  try {
    const { nutrient_id: bodyId, name, nutrient_code, unit, group_name, image_url, benefits, contraindications } = req.body || {};
    // Support both body.nutrient_id and route param :id for updates
    const paramId = req.params && req.params.id ? parseInt(req.params.id, 10) : undefined;
    const nutrient_id = bodyId ?? paramId;

    if (!name || !unit) {
      return res.status(400).json({ error: "Tên và đơn vị là bắt buộc" });
    }

    const adminId = req.admin_id;

    // Prevent duplicate names (case-insensitive)
    if (!nutrient_id) {
      const dup = await db.query(
        'SELECT nutrient_id FROM Nutrient WHERE LOWER(name) = LOWER($1) LIMIT 1',
        [name]
      );
      if (dup.rows.length > 0) {
        return res.status(409).json({ error: 'Chất dinh dưỡng này đã có trên hệ thống' });
      }
    } else {
      const dupEdit = await db.query(
        'SELECT nutrient_id FROM Nutrient WHERE LOWER(name) = LOWER($1) AND nutrient_id <> $2 LIMIT 1',
        [name, nutrient_id]
      );
      if (dupEdit.rows.length > 0) {
        return res.status(409).json({ error: 'Chất dinh dưỡng này đã có trên hệ thống' });
      }
    }

    let result;
    if (nutrient_id) {
      result = await db.query(
        "UPDATE Nutrient SET name = $1, nutrient_code = $2, unit = $3, group_name = $4, image_url = $5, benefits = $6 WHERE nutrient_id = $7 RETURNING *",
        [name, nutrient_code || null, unit, group_name || null, image_url || null, benefits || null, nutrient_id]
      );
    } else {
      result = await db.query(
        "INSERT INTO Nutrient (name, nutrient_code, unit, group_name, image_url, benefits, created_by_admin) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *",
        [name, nutrient_code || null, unit, group_name || null, image_url || null, benefits || null, adminId]
      );
    }

    const saved = result.rows[0];

    // Upsert contraindications: replace-all strategy if provided as non-empty array
    // Only process when contraindications is explicitly sent and has items to prevent accidental deletion
    if (Array.isArray(contraindications) && contraindications.length > 0) {
      try {
        await db.query('DELETE FROM NutrientContraindication WHERE nutrient_id = $1', [saved.nutrient_id]);
        for (const c of contraindications) {
          if (!c) continue;
          if (typeof c === 'string') {
            await db.query(
              'INSERT INTO NutrientContraindication(nutrient_id, condition_name) VALUES ($1, $2) ON CONFLICT (nutrient_id, condition_name) DO NOTHING',
              [saved.nutrient_id, c]
            );
          } else if (typeof c === 'object' && c.condition_name) {
            await db.query(
              'INSERT INTO NutrientContraindication(nutrient_id, condition_name, note) VALUES ($1, $2, $3) ON CONFLICT (nutrient_id, condition_name) DO UPDATE SET note = EXCLUDED.note',
              [saved.nutrient_id, c.condition_name, c.note || null]
            );
          }
        }
      } catch (e) {
        // ignore if table missing; migration may not be applied yet
        console.warn('Contraindications upsert skipped:', e.message);
      }
    } else if (Array.isArray(contraindications) && contraindications.length === 0) {
      // Explicitly clear contraindications when empty array is sent
      try {
        await db.query('DELETE FROM NutrientContraindication WHERE nutrient_id = $1', [saved.nutrient_id]);
      } catch (e) {
        console.warn('Contraindications deletion skipped:', e.message);
      }
    }

    res.json({ nutrient: saved, message: "Lưu chất dinh dưỡng thành công" });
  } catch (err) {
    // Handle unique constraint violation gracefully
    if (err && err.code === '23505') {
      return res.status(409).json({ error: 'Chất dinh dưỡng này đã có trên hệ thống' });
    }
    console.error("Error upserting nutrient:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Delete nutrient
async function deleteNutrient(req, res) {
  try {
    const { id } = req.params;
    const del = await db.query('DELETE FROM Nutrient WHERE nutrient_id = $1 RETURNING nutrient_id', [id]);
    if (del.rows.length === 0) return res.status(404).json({ error: 'Không tìm thấy chất dinh dưỡng' });
    return res.json({ message: 'Xóa chất dinh dưỡng thành công' });
  } catch (err) {
    console.error('Error deleting nutrient:', err);
    return res.status(500).json({ error: 'Lỗi server' });
  }
}

// ============================================================
// HEALTH CONDITION MANAGEMENT
// ============================================================

// Get all health conditions
async function getHealthConditions(req, res) {
  try {
    const query = `
      SELECT 
        condition_id, name_vi, name_en, category, 
        description, description_vi, image_url,
        article_link_vi, article_link_en,
        prevention_tips, prevention_tips_vi,
        severity_level, is_chronic,
        treatment_duration_reference
      FROM HealthCondition
      ORDER BY category, name_vi
    `;
    const result = await db.query(query);

    res.json(result.rows);
  } catch (err) {
    console.error("Error getting health conditions:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Get condition details with food recommendations
async function getConditionDetails(req, res) {
  try {
    const { id } = req.params; // Changed from name to id

    // Get condition info
    const conditionQuery = `
      SELECT * FROM HealthCondition WHERE condition_id = $1
    `;
    const conditionResult = await db.query(conditionQuery, [id]);

    if (conditionResult.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy bệnh lý" });
    }

    // Get nutrient effects for this condition
    const effectsQuery = `
      SELECT cne.*, n.name as nutrient_name, n.unit, n.nutrient_code
      FROM ConditionNutrientEffect cne
      JOIN Nutrient n ON cne.nutrient_id = n.nutrient_id
      WHERE cne.condition_id = $1
      ORDER BY cne.adjustment_percent DESC
    `;
    const effectsResult = await db.query(effectsQuery, [id]);

    // Get food recommendations (foods to avoid)
    const avoidFoodQuery = `
      SELECT cfr.*, f.name_vi, f.name as food_name, f.category, f.image_url
      FROM ConditionFoodRecommendation cfr
      JOIN Food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = $1 AND cfr.recommendation_type = 'avoid'
      ORDER BY f.name_vi
    `;
    const avoidFoodResult = await db.query(avoidFoodQuery, [id]);

    // Get food recommendations (foods to recommend)
    const recommendFoodQuery = `
      SELECT cfr.*, f.name_vi, f.name as food_name, f.category, f.image_url
      FROM ConditionFoodRecommendation cfr
      JOIN Food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = $1 AND cfr.recommendation_type = 'recommend'
      ORDER BY f.name_vi
    `;
    const recommendFoodResult = await db.query(recommendFoodQuery, [id]);

    // Get drugs for this condition
    const drugsQuery = `
      SELECT d.drug_id, d.name_vi, d.name_en, d.description, d.description_vi, 
             d.image_url, dhc.treatment_notes, dhc.treatment_notes_vi, dhc.is_primary
      FROM DrugHealthCondition dhc
      JOIN Drug d ON dhc.drug_id = d.drug_id
      WHERE dhc.condition_id = $1 AND d.is_active = true
      ORDER BY dhc.is_primary DESC, d.name_vi
    `;
    const drugsResult = await db.query(drugsQuery, [id]);

    res.json({
      condition: conditionResult.rows[0],
      nutrient_effects: effectsResult.rows,
      foods_to_avoid: avoidFoodResult.rows,
      foods_to_recommend: recommendFoodResult.rows,
      drugs: drugsResult.rows,
    });
  } catch (err) {
    console.error("Error getting condition details:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Add or update condition nutrient effect
async function upsertConditionEffect(req, res) {
  try {
    const {
      condition_id,
      nutrient_id,
      adjustment_percent,
    } = req.body;

    if (!condition_id || !nutrient_id || adjustment_percent === undefined) {
      return res.status(400).json({ error: "Thiếu thông tin bắt buộc" });
    }

    // Check if exists
    const checkQuery = `
      SELECT * FROM ConditionNutrientEffect 
      WHERE condition_id = $1 AND nutrient_id = $2
    `;
    const checkResult = await db.query(checkQuery, [
      condition_id,
      nutrient_id,
    ]);

    let result;
    if (checkResult.rows.length > 0) {
      // Update
      result = await db.query(
        `UPDATE ConditionNutrientEffect 
         SET adjustment_percent = $1
         WHERE condition_id = $2 AND nutrient_id = $3
         RETURNING *`,
        [adjustment_percent, condition_id, nutrient_id]
      );
    } else {
      // Insert
      result = await db.query(
        `INSERT INTO ConditionNutrientEffect 
         (condition_id, nutrient_id, adjustment_percent)
         VALUES ($1, $2, $3) RETURNING *`,
        [condition_id, nutrient_id, adjustment_percent]
      );
    }

    res.json({ effect: result.rows[0], message: "Lưu hiệu ứng thành công" });
  } catch (err) {
    console.error("Error upserting condition effect:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Add or update food recommendation for condition
async function upsertConditionFoodRecommendation(req, res) {
  try {
    const { condition_id, food_id, recommendation_type, notes } = req.body;

    if (!condition_id || !food_id || !recommendation_type) {
      return res.status(400).json({ error: "Thiếu thông tin bắt buộc" });
    }

    // Check if exists
    const checkQuery = `
      SELECT * FROM ConditionFoodRecommendation 
      WHERE condition_id = $1 AND food_id = $2
    `;
    const checkResult = await db.query(checkQuery, [condition_id, food_id]);

    let result;
    if (checkResult.rows.length > 0) {
      // Update
      result = await db.query(
        `UPDATE ConditionFoodRecommendation 
         SET recommendation_type = $1, notes = $2
         WHERE condition_id = $3 AND food_id = $4
         RETURNING *`,
        [recommendation_type, notes, condition_id, food_id]
      );
    } else {
      // Insert
      result = await db.query(
        `INSERT INTO ConditionFoodRecommendation 
         (condition_id, food_id, recommendation_type, notes)
         VALUES ($1, $2, $3, $4) RETURNING *`,
        [condition_id, food_id, recommendation_type, notes]
      );
    }

    res.json({
      recommendation: result.rows[0],
      message: "Lưu khuyến nghị thành công",
    });
  } catch (err) {
    console.error("Error upserting food recommendation:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Delete condition food recommendation
async function deleteConditionRecommendation(req, res) {
  try {
    const { id } = req.params;

    const result = await db.query(
      "DELETE FROM ConditionFoodRecommendation WHERE recommendation_id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy" });
    }

    res.json({ message: "Xóa khuyến nghị thành công" });
  } catch (err) {
    console.error("Error deleting recommendation:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Create new health condition
async function createHealthCondition(req, res) {
  try {
    const {
      name_vi,
      name_en,
      category,
      description,
      description_vi,
      causes,
      image_url,
      treatment_duration_reference,
      article_link_vi,
      article_link_en,
      prevention_tips,
      prevention_tips_vi,
      severity_level,
      is_chronic,
    } = req.body;

    if (!name_vi || !name_en) {
      return res.status(400).json({ error: "Tên bệnh là bắt buộc" });
    }

    const result = await db.query(
      `INSERT INTO HealthCondition 
       (name_vi, name_en, category, description, description_vi, causes, 
        image_url, treatment_duration_reference, article_link_vi, article_link_en,
        prevention_tips, prevention_tips_vi, severity_level, is_chronic)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
       RETURNING *`,
      [
        name_vi,
        name_en,
        category,
        description,
        description_vi,
        causes,
        image_url,
        treatment_duration_reference,
        article_link_vi,
        article_link_en,
        prevention_tips,
        prevention_tips_vi,
        severity_level || 'moderate',
        is_chronic || false,
      ]
    );

    res.json({
      condition: result.rows[0],
      message: "Tạo bệnh mới thành công",
    });
  } catch (err) {
    console.error("Error creating health condition:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Update health condition
async function updateHealthCondition(req, res) {
  try {
    const { id } = req.params;
    const {
      name_vi,
      name_en,
      category,
      description,
      description_vi,
      causes,
      image_url,
      treatment_duration_reference,
      article_link_vi,
      article_link_en,
      prevention_tips,
      prevention_tips_vi,
      severity_level,
      is_chronic,
    } = req.body;

    if (!name_vi || !name_en) {
      return res.status(400).json({ error: "Tên bệnh là bắt buộc" });
    }

    const result = await db.query(
      `UPDATE HealthCondition 
       SET name_vi = $1, name_en = $2, category = $3, description = $4, 
           description_vi = $5, causes = $6, image_url = $7, 
           treatment_duration_reference = $8, article_link_vi = $9, 
           article_link_en = $10, prevention_tips = $11, prevention_tips_vi = $12,
           severity_level = $13, is_chronic = $14, updated_at = NOW()
       WHERE condition_id = $15
       RETURNING *`,
      [
        name_vi,
        name_en,
        category,
        description,
        description_vi,
        causes,
        image_url,
        treatment_duration_reference,
        article_link_vi,
        article_link_en,
        prevention_tips,
        prevention_tips_vi,
        severity_level,
        is_chronic,
        id,
      ]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy bệnh" });
    }

    res.json({
      condition: result.rows[0],
      message: "Cập nhật bệnh thành công",
    });
  } catch (err) {
    console.error("Error updating health condition:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Delete health condition
async function deleteHealthCondition(req, res) {
  try {
    const { id } = req.params;

    // Check if condition is used by any user
    const checkQuery = await db.query(
      "SELECT COUNT(*) FROM UserHealthCondition WHERE condition_id = $1",
      [id]
    );

    if (parseInt(checkQuery.rows[0].count) > 0) {
      return res.status(400).json({
        error: "Không thể xóa bệnh này vì có người dùng đang sử dụng",
      });
    }

    const result = await db.query(
      "DELETE FROM HealthCondition WHERE condition_id = $1 RETURNING *",
      [id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy bệnh" });
    }

    res.json({ message: "Xóa bệnh thành công" });
  } catch (err) {
    console.error("Error deleting health condition:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// ============================================================
// APP SETTINGS MANAGEMENT
// ============================================================

// Get app settings statistics
async function getAppSettings(req, res) {
  try {
    // Get theme distribution
    const themeQuery = `
      SELECT theme, COUNT(*) as count
      FROM UserSetting
      GROUP BY theme
      ORDER BY count DESC
    `;
    const themeResult = await db.query(themeQuery);

    // Get language distribution
    const langQuery = `
      SELECT language, COUNT(*) as count
      FROM UserSetting
      GROUP BY language
      ORDER BY count DESC
    `;
    const langResult = await db.query(langQuery);

    // Get seasonal UI stats
    const seasonalQuery = `
      SELECT 
        seasonal_ui_enabled,
        COUNT(*) as count
      FROM UserSetting
      GROUP BY seasonal_ui_enabled
    `;
    const seasonalResult = await db.query(seasonalQuery);

    // Get weather enabled stats
    const weatherQuery = `
      SELECT 
        weather_enabled,
        COUNT(*) as count
      FROM UserSetting
      GROUP BY weather_enabled
    `;
    const weatherResult = await db.query(weatherQuery);

    // Get most popular cities for weather
    const citiesQuery = `
      SELECT weather_city, COUNT(*) as count
      FROM UserSetting
      WHERE weather_city IS NOT NULL
      GROUP BY weather_city
      ORDER BY count DESC
      LIMIT 10
    `;
    const citiesResult = await db.query(citiesQuery);

    res.json({
      theme_distribution: themeResult.rows,
      language_distribution: langResult.rows,
      seasonal_ui_stats: seasonalResult.rows,
      weather_stats: weatherResult.rows,
      popular_cities: citiesResult.rows,
    });
  } catch (err) {
    console.error("Error getting app settings:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

// Get dashboard statistics
async function getDashboardStats(req, res) {
  try {
    // Total users
    const usersResult = await db.query('SELECT COUNT(*) FROM "User"');
    const totalUsers = parseInt(usersResult.rows[0].count);

    // Total foods
    const foodsResult = await db.query("SELECT COUNT(*) FROM Food");
    const totalFoods = parseInt(foodsResult.rows[0].count);

    // Total nutrients
    const nutrientsResult = await db.query("SELECT COUNT(*) FROM Nutrient");
    const totalNutrients = parseInt(nutrientsResult.rows[0].count);

    // Total meals today (Vietnam timezone)
    const todayMealsResult = await db.query(
      "SELECT COUNT(*) FROM Meal WHERE meal_date = (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date"
    );
    const todayMeals = parseInt(todayMealsResult.rows[0].count);

    // Active users (logged meals in last 7 days, Vietnam timezone)
    const activeUsersResult = await db.query(`
      SELECT COUNT(DISTINCT user_id) 
      FROM Meal 
      WHERE meal_date >= (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date - INTERVAL '7 days'
    `);
    const activeUsers = parseInt(activeUsersResult.rows[0].count);

    // New users this month (Vietnam timezone)
    const newUsersResult = await db.query(`
      SELECT COUNT(*) 
      FROM "User" 
      WHERE (created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date >= DATE_TRUNC('month', (CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date)
    `);
    const newUsersThisMonth = parseInt(newUsersResult.rows[0].count);

    const dishesResult = await db.query('SELECT COUNT(*) FROM dish');
    const totalDishes = parseInt(dishesResult.rows[0].count);

    const drinksResult = await db.query('SELECT COUNT(*) FROM Drink');
    const totalDrinks = parseInt(drinksResult.rows[0].count);

    // Total dish logs (sum of times_logged from dishstatistics)
    const dishLogsResult = await db.query(`
      SELECT COALESCE(SUM(total_times_logged), 0) 
      FROM dishstatistics
    `);
    const dishLogs = parseInt(dishLogsResult.rows[0].coalesce);

    // Total health conditions
    const healthConditionsResult = await db.query('SELECT COUNT(*) FROM HealthCondition');
    const totalHealthConditions = parseInt(healthConditionsResult.rows[0].count);

    // Total drugs (active only)
    let totalDrugs = 0;
    try {
      const drugsResult = await db.query('SELECT COUNT(*) FROM Drug WHERE is_active = TRUE');
      totalDrugs = parseInt(drugsResult.rows[0].count);
    } catch (err) {
      console.warn('Drug table may not exist yet:', err.message);
    }

    res.json({
      total_users: totalUsers,
      total_foods: totalFoods,
      total_nutrients: totalNutrients,
      today_meals: todayMeals,
      active_users_7days: activeUsers,
      new_users_this_month: newUsersThisMonth,
      total_dishes: totalDishes,
      total_drinks: totalDrinks,
      dish_logs: dishLogs,
      total_health_conditions: totalHealthConditions,
      total_drugs: totalDrugs,
    });
  } catch (err) {
    console.error("Error getting dashboard stats:", err);
    res.status(500).json({ error: "Lỗi server" });
  }
}

module.exports = {
  // User management
  getUsers,
  getUserDetails,
  deleteUser,
  blockUser,
  unblockUser,
  getUnblockRequests,
  decideUnblockRequest,

  // Food management
  getFoods,
  getFoodDetails,
  upsertFood,
  deleteFood,

  // Nutrient management
  getNutrients,
  getNutrientDetails,
  upsertNutrient,
  deleteNutrient,

  // Health condition management
  getHealthConditions,
  getConditionDetails,
  createHealthCondition,
  updateHealthCondition,
  deleteHealthCondition,
  upsertConditionEffect,
  upsertConditionFoodRecommendation,
  deleteConditionRecommendation,

  // App settings
  getAppSettings,
  getDashboardStats,
};
