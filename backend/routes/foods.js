/**
 * foods.js
 * Public and user routes for food search
 */

const express = require('express');
const router = express.Router();
const db = require('../db');
const flexibleAuthMiddleware = require('../utils/flexibleAuthMiddleware');

/**
 * GET /api/foods
 * Search foods (requires authentication - accepts both user and admin tokens)
 */
router.get('/', flexibleAuthMiddleware, async (req, res) => {
  try {
    const { search = '', limit = 50, offset = 0 } = req.query;

    let query = `
      SELECT 
        food_id,
        name,
        category,
        image_url
      FROM food
      WHERE 1=1
    `;
    
    const params = [];
    
    if (search) {
      params.push(`%${search}%`);
      query += ` AND (name ILIKE $${params.length} OR category ILIKE $${params.length})`;
    }

    query += ` ORDER BY name LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    res.json({
      success: true,
      foods: result.rows,
      count: result.rows.length
    });
  } catch (error) {
    console.error('Error searching foods:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to search foods' 
    });
  }
});

/**
 * GET /api/foods/:id
 * Get food details with nutrients
 */
router.get('/:id', flexibleAuthMiddleware, async (req, res) => {
  try {
    const foodId = parseInt(req.params.id);

    const foodResult = await db.query(
      'SELECT * FROM food WHERE food_id = $1',
      [foodId]
    );

    if (foodResult.rows.length === 0) {
      return res.status(404).json({ 
        success: false,
        error: 'Food not found' 
      });
    }

    // Get nutrients for this food
    const nutrientsResult = await db.query(
      `SELECT 
        n.nutrient_id,
        n.name,
        n.unit,
        fn.amount_per_100g
      FROM foodnutrient fn
      JOIN nutrient n ON fn.nutrient_id = n.nutrient_id
      WHERE fn.food_id = $1
      ORDER BY n.name`,
      [foodId]
    );

    res.json({
      success: true,
      food: foodResult.rows[0],
      nutrients: nutrientsResult.rows
    });
  } catch (error) {
    console.error('Error getting food details:', error);
    res.status(500).json({ 
      success: false,
      error: 'Failed to get food details' 
    });
  }
});

module.exports = router;
