const db = require('../db');

/**
 * Get all foods with optional filters
 * GET /api/foods?category=...&search=...&page=1&limit=20
 */
exports.getAllFoods = async (req, res) => {
  try {
    const { category, search, page = 1, limit = 20, active_only = 'true' } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT f.*, 
             COUNT(fn.food_nutrient_id) as nutrient_count,
             a.username as created_by_admin_name
      FROM Food f
      LEFT JOIN FoodNutrient fn ON f.food_id = fn.food_id
      LEFT JOIN Admin a ON f.created_by_admin = a.admin_id
      WHERE 1=1
    `;
    const params = [];
    let paramIndex = 1;

    if (active_only === 'true') {
      query += ` AND f.is_active = TRUE`;
    }

    if (category) {
      query += ` AND f.category = $${paramIndex++}`;
      params.push(category);
    }

    if (search) {
      query += ` AND f.name ILIKE $${paramIndex++}`;
      params.push(`%${search}%`);
    }

    query += ` GROUP BY f.food_id, a.username ORDER BY f.name ASC LIMIT $${paramIndex++} OFFSET $${paramIndex++}`;
    params.push(limit, offset);

    const result = await db.query(query, params);

    // Get total count
    let countQuery = `SELECT COUNT(DISTINCT f.food_id) FROM Food f WHERE 1=1`;
    const countParams = [];
    let countParamIndex = 1;

    if (active_only === 'true') {
      countQuery += ` AND f.is_active = TRUE`;
    }
    if (category) {
      countQuery += ` AND f.category = $${countParamIndex++}`;
      countParams.push(category);
    }
    if (search) {
      countQuery += ` AND f.name ILIKE $${countParamIndex++}`;
      countParams.push(`%${search}%`);
    }

    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    res.json({
      foods: result.rows,
      pagination: {
        total,
        page: parseInt(page),
        limit: parseInt(limit),
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error fetching foods:', error);
    res.status(500).json({ error: 'Failed to fetch foods' });
  }
};

/**
 * Get single food with all nutrients
 * GET /api/foods/:id
 */
exports.getFoodById = async (req, res) => {
  try {
    const { id } = req.params;

    const foodQuery = `
      SELECT f.*, a.username as created_by_admin_name
      FROM Food f
      LEFT JOIN Admin a ON f.created_by_admin = a.admin_id
      WHERE f.food_id = $1
    `;
    const foodResult = await db.query(foodQuery, [id]);

    if (foodResult.rows.length === 0) {
      return res.status(404).json({ error: 'Food not found' });
    }

    const nutrientsQuery = `
      SELECT fn.*, n.name as nutrient_name, n.unit
      FROM FoodNutrient fn
      JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
      WHERE fn.food_id = $1
      ORDER BY n.name
    `;
    const nutrientsResult = await db.query(nutrientsQuery, [id]);

    res.json({
      food: foodResult.rows[0],
      nutrients: nutrientsResult.rows
    });
  } catch (error) {
    console.error('Error fetching food:', error);
    res.status(500).json({ error: 'Failed to fetch food' });
  }
};

/**
 * Create new food
 * POST /api/foods
 */
exports.createFood = async (req, res) => {
  const client = await db.pool.connect();
  try {
    const { name, category, description, image_url, serving_size_g, nutrients } = req.body;
    const adminId = req.admin?.admin_id;

    if (!name) {
      return res.status(400).json({ error: 'Food name is required' });
    }

    await client.query('BEGIN');

    // Insert food
    const foodQuery = `
      INSERT INTO Food (name, category, description, image_url, serving_size_g, created_by_admin, is_verified)
      VALUES ($1, $2, $3, $4, $5, $6, TRUE)
      RETURNING *
    `;
    const foodResult = await client.query(foodQuery, [
      name,
      category || null,
      description || null,
      image_url || null,
      serving_size_g || 100.00,
      adminId || null
    ]);

    const foodId = foodResult.rows[0].food_id;

    // Insert nutrients if provided
    if (nutrients && Array.isArray(nutrients) && nutrients.length > 0) {
      for (const nutrient of nutrients) {
        if (nutrient.nutrient_id && nutrient.amount_per_100g >= 0) {
          await client.query(
            `INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
             VALUES ($1, $2, $3)
             ON CONFLICT (food_id, nutrient_id) DO UPDATE 
             SET amount_per_100g = EXCLUDED.amount_per_100g`,
            [foodId, nutrient.nutrient_id, nutrient.amount_per_100g]
          );
        }
      }
    }

    await client.query('COMMIT');

    // Fetch complete food with nutrients
    const completeFood = await db.query(
      `SELECT f.*, 
              (SELECT json_agg(json_build_object('nutrient_id', fn.nutrient_id, 'nutrient_name', n.name, 'amount_per_100g', fn.amount_per_100g, 'unit', n.unit))
               FROM FoodNutrient fn
               JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
               WHERE fn.food_id = f.food_id) as nutrients
       FROM Food f
       WHERE f.food_id = $1`,
      [foodId]
    );

    res.status(201).json({ food: completeFood.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error creating food:', error);
    res.status(500).json({ error: 'Failed to create food' });
  } finally {
    client.release();
  }
};

/**
 * Update food
 * PUT /api/foods/:id
 */
exports.updateFood = async (req, res) => {
  const client = await db.pool.connect();
  try {
    const { id } = req.params;
    const { name, category, description, image_url, serving_size_g, is_active, nutrients } = req.body;

    await client.query('BEGIN');

    // Update food
    const foodQuery = `
      UPDATE Food
      SET name = COALESCE($1, name),
          category = COALESCE($2, category),
          description = COALESCE($3, description),
          image_url = COALESCE($4, image_url),
          serving_size_g = COALESCE($5, serving_size_g),
          is_active = COALESCE($6, is_active)
      WHERE food_id = $7
      RETURNING *
    `;
    const foodResult = await client.query(foodQuery, [
      name || null,
      category || null,
      description || null,
      image_url || null,
      serving_size_g || null,
      is_active !== undefined ? is_active : null,
      id
    ]);

    if (foodResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Food not found' });
    }

    // Update nutrients if provided
    if (nutrients && Array.isArray(nutrients)) {
      // Delete existing nutrients
      await client.query('DELETE FROM FoodNutrient WHERE food_id = $1', [id]);

      // Insert new nutrients
      for (const nutrient of nutrients) {
        if (nutrient.nutrient_id && nutrient.amount_per_100g >= 0) {
          await client.query(
            `INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g)
             VALUES ($1, $2, $3)`,
            [id, nutrient.nutrient_id, nutrient.amount_per_100g]
          );
        }
      }
    }

    await client.query('COMMIT');

    // Fetch complete food
    const completeFood = await db.query(
      `SELECT f.*, 
              (SELECT json_agg(json_build_object('nutrient_id', fn.nutrient_id, 'nutrient_name', n.name, 'amount_per_100g', fn.amount_per_100g, 'unit', n.unit))
               FROM FoodNutrient fn
               JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
               WHERE fn.food_id = f.food_id) as nutrients
       FROM Food f
       WHERE f.food_id = $1`,
      [id]
    );

    res.json({ food: completeFood.rows[0] });
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error updating food:', error);
    res.status(500).json({ error: 'Failed to update food' });
  } finally {
    client.release();
  }
};

/**
 * Delete food (soft delete by default)
 * DELETE /api/foods/:id?hard=false
 */
exports.deleteFood = async (req, res) => {
  try {
    const { id } = req.params;
    const { hard = 'false' } = req.query;

    if (hard === 'true') {
      // Hard delete
      await db.query('DELETE FROM Food WHERE food_id = $1', [id]);
    } else {
      // Soft delete
      const result = await db.query(
        'UPDATE Food SET is_active = FALSE WHERE food_id = $1 RETURNING *',
        [id]
      );
      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Food not found' });
      }
    }

    res.json({ message: 'Food deleted successfully' });
  } catch (error) {
    console.error('Error deleting food:', error);
    res.status(500).json({ error: 'Failed to delete food' });
  }
};

/**
 * Get food statistics
 * GET /api/foods/stats
 */
exports.getFoodStats = async (req, res) => {
  try {
    const statsQuery = `
      SELECT 
        COUNT(*) as total_foods,
        COUNT(CASE WHEN is_active = TRUE THEN 1 END) as active_foods,
        COUNT(CASE WHEN is_verified = TRUE THEN 1 END) as verified_foods,
        COUNT(DISTINCT category) as categories_count,
        (SELECT COUNT(*) FROM FoodNutrient) as total_nutrient_mappings
      FROM Food
    `;
    const result = await db.query(statsQuery);

    const categoryStatsQuery = `
      SELECT category, COUNT(*) as count
      FROM Food
      WHERE is_active = TRUE
      GROUP BY category
      ORDER BY count DESC
      LIMIT 10
    `;
    const categoryResult = await db.query(categoryStatsQuery);

    res.json({
      overall: result.rows[0],
      byCategory: categoryResult.rows
    });
  } catch (error) {
    console.error('Error fetching food stats:', error);
    res.status(500).json({ error: 'Failed to fetch food statistics' });
  }
};

/**
 * Get all available nutrients
 * GET /api/foods/nutrients/available
 */
exports.getAvailableNutrients = async (req, res) => {
  try {
    const result = await db.query(
      'SELECT * FROM Nutrient ORDER BY name ASC'
    );
    res.json({ nutrients: result.rows });
  } catch (error) {
    console.error('Error fetching nutrients:', error);
    res.status(500).json({ error: 'Failed to fetch nutrients' });
  }
};

/**
 * Search foods by name (for meal entry)
 * GET /api/foods/search?q=...&limit=10
 */
exports.searchFoods = async (req, res) => {
  try {
    const { q, limit = 10 } = req.query;

    if (!q || q.length < 2) {
      return res.json({ foods: [] });
    }

    const query = `
      SELECT f.food_id, f.name, f.category, f.image_url,
             COUNT(fn.food_nutrient_id) as nutrient_count
      FROM Food f
      LEFT JOIN FoodNutrient fn ON f.food_id = fn.food_id
      WHERE f.name ILIKE $1
      GROUP BY f.food_id
      ORDER BY f.name ASC
      LIMIT $2
    `;
    const result = await db.query(query, [`%${q}%`, limit]);

    // Log food search activity if user is authenticated
    if (req.user && req.user.user_id) {
      try {
        await db.query(
          "INSERT INTO UserActivityLog(user_id, action, log_time) VALUES ($1, $2, NOW())",
          [req.user.user_id, "food_searched"]
        );
      } catch (e) {
        console.error("Failed to log food_searched activity", e);
      }
    }

    res.json({ foods: result.rows });
  } catch (error) {
    console.error('Error searching foods:', error);
    res.status(500).json({ error: 'Failed to search foods' });
  }
};
