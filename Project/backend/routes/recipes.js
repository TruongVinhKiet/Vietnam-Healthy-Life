const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/recipes - Get all recipes (with optional filters)
router.get('/', async (req, res) => {
  try {
    const userId = req.user?.user_id || req.query.user_id;
    const isPublic = req.query.public === 'true';
    
    let query = `
      SELECT 
        r.*,
        u.full_name as author_name,
        COUNT(DISTINCT ri.recipe_ingredient_id) as ingredient_count
      FROM Recipe r
      LEFT JOIN "User" u ON r.user_id = u.user_id
      LEFT JOIN RecipeIngredient ri ON r.recipe_id = ri.recipe_id
      WHERE 1=1
    `;
    
    const params = [];
    
    if (userId) {
      params.push(userId);
      query += ` AND (r.user_id = $${params.length} OR r.is_public = true)`;
    } else if (isPublic) {
      query += ` AND r.is_public = true`;
    }
    
    query += `
      GROUP BY r.recipe_id, u.full_name
      ORDER BY r.created_at DESC
    `;
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      recipes: result.rows
    });
  } catch (error) {
    console.error('Error fetching recipes:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy công thức',
      error: error.message
    });
  }
});

// GET /api/recipes/:id - Get recipe details with ingredients
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get recipe info
    const recipeResult = await db.query(`
      SELECT 
        r.*,
        u.full_name as author_name
      FROM Recipe r
      LEFT JOIN "User" u ON r.user_id = u.user_id
      WHERE r.recipe_id = $1
    `, [id]);
    
    if (recipeResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy công thức'
      });
    }
    
    // Get ingredients
    const ingredientsResult = await db.query(`
      SELECT 
        ri.*,
        f.name as food_name,
        f.name_vi as food_name_vi,
        f.category
      FROM RecipeIngredient ri
      JOIN Food f ON ri.food_id = f.food_id
      WHERE ri.recipe_id = $1
      ORDER BY ri.ingredient_order
    `, [id]);
    
    res.json({
      success: true,
      recipe: {
        ...recipeResult.rows[0],
        ingredients: ingredientsResult.rows
      }
    });
  } catch (error) {
    console.error('Error fetching recipe:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy chi tiết công thức',
      error: error.message
    });
  }
});

// POST /api/recipes - Create new recipe
router.post('/', async (req, res) => {
  const client = await db.pool.connect();
  
  try {
    await client.query('BEGIN');
    
    const {
      user_id,
      recipe_name,
      description,
      servings,
      prep_time_minutes,
      cook_time_minutes,
      instructions,
      image_url,
      is_public,
      ingredients
    } = req.body;
    
    if (!user_id || !recipe_name || !ingredients || ingredients.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu thông tin bắt buộc'
      });
    }
    
    // Create recipe
    const recipeResult = await client.query(`
      INSERT INTO Recipe (
        user_id, recipe_name, description, servings, 
        prep_time_minutes, cook_time_minutes, instructions, 
        image_url, is_public
      )
      VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
      RETURNING *
    `, [
      user_id, recipe_name, description, servings || 1,
      prep_time_minutes, cook_time_minutes, instructions,
      image_url, is_public || false
    ]);
    
    const recipe = recipeResult.rows[0];
    
    // Add ingredients
    for (let i = 0; i < ingredients.length; i++) {
      const ing = ingredients[i];
      await client.query(`
        INSERT INTO RecipeIngredient (
          recipe_id, food_id, weight_g, ingredient_order, notes
        )
        VALUES ($1, $2, $3, $4, $5)
      `, [recipe.recipe_id, ing.food_id, ing.weight_g, i + 1, ing.notes]);
    }
    
    await client.query('COMMIT');
    
    res.json({
      success: true,
      recipe: recipe
    });
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('Error creating recipe:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo công thức',
      error: error.message
    });
  } finally {
    client.release();
  }
});

// PUT /api/recipes/:id - Update recipe
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const {
      recipe_name,
      description,
      servings,
      prep_time_minutes,
      cook_time_minutes,
      instructions,
      image_url,
      is_public
    } = req.body;
    
    const result = await db.query(`
      UPDATE Recipe
      SET 
        recipe_name = COALESCE($1, recipe_name),
        description = COALESCE($2, description),
        servings = COALESCE($3, servings),
        prep_time_minutes = COALESCE($4, prep_time_minutes),
        cook_time_minutes = COALESCE($5, cook_time_minutes),
        instructions = COALESCE($6, instructions),
        image_url = COALESCE($7, image_url),
        is_public = COALESCE($8, is_public),
        updated_at = CURRENT_TIMESTAMP
      WHERE recipe_id = $9
      RETURNING *
    `, [recipe_name, description, servings, prep_time_minutes, cook_time_minutes, 
        instructions, image_url, is_public, id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy công thức'
      });
    }
    
    res.json({
      success: true,
      recipe: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating recipe:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật công thức',
      error: error.message
    });
  }
});

// DELETE /api/recipes/:id - Delete recipe
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(`
      DELETE FROM Recipe WHERE recipe_id = $1
      RETURNING recipe_id
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy công thức'
      });
    }
    
    res.json({
      success: true,
      message: 'Đã xóa công thức'
    });
  } catch (error) {
    console.error('Error deleting recipe:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa công thức',
      error: error.message
    });
  }
});

// POST /api/recipes/:id/ingredients - Add ingredient to recipe
router.post('/:id/ingredients', async (req, res) => {
  try {
    const { id } = req.params;
    const { food_id, weight_g, notes } = req.body;
    
    if (!food_id || !weight_g) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu thông tin nguyên liệu'
      });
    }
    
    // Get max order
    const orderResult = await db.query(`
      SELECT COALESCE(MAX(ingredient_order), 0) + 1 as next_order
      FROM RecipeIngredient
      WHERE recipe_id = $1
    `, [id]);
    
    const nextOrder = orderResult.rows[0].next_order;
    
    const result = await db.query(`
      INSERT INTO RecipeIngredient (recipe_id, food_id, weight_g, ingredient_order, notes)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [id, food_id, weight_g, nextOrder, notes]);
    
    res.json({
      success: true,
      ingredient: result.rows[0]
    });
  } catch (error) {
    console.error('Error adding ingredient:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi thêm nguyên liệu',
      error: error.message
    });
  }
});

// DELETE /api/recipes/:recipeId/ingredients/:ingredientId
router.delete('/:recipeId/ingredients/:ingredientId', async (req, res) => {
  try {
    const { ingredientId } = req.params;
    
    const result = await db.query(`
      DELETE FROM RecipeIngredient 
      WHERE recipe_ingredient_id = $1
      RETURNING recipe_ingredient_id
    `, [ingredientId]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy nguyên liệu'
      });
    }
    
    res.json({
      success: true,
      message: 'Đã xóa nguyên liệu'
    });
  } catch (error) {
    console.error('Error deleting ingredient:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa nguyên liệu',
      error: error.message
    });
  }
});

module.exports = router;
