const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../utils/authMiddleware');
const { getVietnamDate } = require('../utils/dateHelper');

// GET /api/suggestions/daily - Get food suggestions based on nutrient deficiencies
router.get('/daily', async (req, res) => {
  try {
    const userId = req.user?.user_id || req.query.user_id || 1;
    const date = req.query.date || getVietnamDate();
    
    // Get daily nutrient intake
    const intakeResult = await db.query(`
      SELECT * FROM calculate_daily_nutrient_intake($1, $2)
    `, [userId, date]);
    
    // Find deficient nutrients (< 70% of target)
    const deficientNutrients = intakeResult.rows.filter(n => 
      n.target_amount > 0 && n.percent_of_target < 70
    );
    
    if (deficientNutrients.length === 0) {
      return res.json({
        success: true,
        message: 'Bạn đã đạt đủ dinh dưỡng hôm nay!',
        suggestions: []
      });
    }
    
    // Get food suggestions for deficient nutrients
    const suggestions = [];
    
    for (const nutrient of deficientNutrients.slice(0, 5)) { // Top 5 deficiencies
      // Find foods rich in this nutrient
      const foodsResult = await db.query(`
        SELECT 
          f.food_id,
          f.name,
          f.name_vi,
          fn.amount_per_100g,
          n.unit,
          f.category
        FROM Food f
        JOIN FoodNutrient fn ON f.food_id = fn.food_id
        JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
        WHERE fn.nutrient_id = $1
          AND fn.amount_per_100g > 0
        ORDER BY fn.amount_per_100g DESC
        LIMIT 5
      `, [nutrient.nutrient_id]);
      
      if (foodsResult.rows.length > 0) {
        suggestions.push({
          nutrient_name: nutrient.nutrient_name,
          nutrient_type: nutrient.nutrient_type,
          current_amount: nutrient.total_amount,
          target_amount: nutrient.target_amount,
          deficit_amount: nutrient.target_amount - nutrient.total_amount,
          percent_of_target: nutrient.percent_of_target,
          unit: nutrient.unit,
          suggested_foods: foodsResult.rows
        });
      }
    }
    
    res.json({
      success: true,
      date: date,
      total_deficiencies: deficientNutrients.length,
      suggestions: suggestions
    });
    
  } catch (error) {
    console.error('Error getting suggestions:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy gợi ý',
      error: error.message
    });
  }
});

// GET /api/suggestions/condition/:conditionId - Get food suggestions for a health condition
router.get('/condition/:conditionId', async (req, res) => {
  try {
    const { conditionId } = req.params;
    
    // Get condition info
    const conditionResult = await db.query(`
      SELECT condition_id, name_vi, name_en, description
      FROM HealthCondition
      WHERE condition_id = $1
    `, [conditionId]);
    
    if (conditionResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy tình trạng sức khỏe'
      });
    }
    
    const condition = conditionResult.rows[0];
    
    // Get recommended foods
    const recommendedResult = await db.query(`
      SELECT 
        f.food_id,
        f.name,
        f.name_vi,
        f.category,
        cfr.notes,
        cfr.recommendation_type
      FROM ConditionFoodRecommendation cfr
      JOIN Food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = $1 AND cfr.recommendation_type = 'recommend'
      ORDER BY f.name
    `, [conditionId]);
    
    // Get foods to avoid
    const avoidResult = await db.query(`
      SELECT 
        f.food_id,
        f.name,
        f.name_vi,
        f.category,
        cfr.notes,
        cfr.recommendation_type
      FROM ConditionFoodRecommendation cfr
      JOIN Food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = $1 AND cfr.recommendation_type = 'avoid'
      ORDER BY f.name
    `, [conditionId]);
    
    // Get nutrient adjustments
    const nutrientEffectsResult = await db.query(`
      SELECT 
        n.name as nutrient_name,
        n.unit,
        cne.effect_type,
        cne.adjustment_percent,
        cne.notes
      FROM ConditionNutrientEffect cne
      JOIN Nutrient n ON cne.nutrient_id = n.nutrient_id
      WHERE cne.condition_id = $1
      ORDER BY ABS(cne.adjustment_percent) DESC
    `, [conditionId]);
    
    res.json({
      success: true,
      condition: condition,
      recommended_foods: recommendedResult.rows,
      foods_to_avoid: avoidResult.rows,
      nutrient_adjustments: nutrientEffectsResult.rows
    });
    
  } catch (error) {
    console.error('Error getting condition suggestions:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy gợi ý theo tình trạng sức khỏe',
      error: error.message
    });
  }
});

// GET /api/suggestions/user-food-recommendations - Get user's food recommendations based on their health conditions
router.get('/user-food-recommendations', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.user_id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    // Get user's active health conditions
    const conditionsResult = await db.query(`
      SELECT DISTINCT hc.condition_id, hc.name_vi
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 
        AND uhc.status = 'active'
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= get_vietnam_date())
    `, [userId]);

    if (conditionsResult.rows.length === 0) {
      return res.json({
        success: true,
        foods_to_avoid: [],
        foods_to_recommend: [],
        conditions: []
      });
    }

    const conditionIds = conditionsResult.rows.map(c => c.condition_id);

    // Get foods to avoid for user's conditions
    const avoidResult = await db.query(`
      SELECT DISTINCT 
        cfr.food_id,
        f.name_vi,
        f.name,
        cfr.notes,
        hc.name_vi as condition_name
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[]) 
        AND cfr.recommendation_type = 'avoid'
      ORDER BY f.name_vi
    `, [conditionIds]);

    // Get foods to recommend for user's conditions
    const recommendResult = await db.query(`
      SELECT DISTINCT 
        cfr.food_id,
        f.name_vi,
        f.name,
        cfr.notes,
        hc.name_vi as condition_name
      FROM conditionfoodrecommendation cfr
      JOIN food f ON cfr.food_id = f.food_id
      JOIN healthcondition hc ON cfr.condition_id = hc.condition_id
      WHERE cfr.condition_id = ANY($1::int[]) 
        AND cfr.recommendation_type = 'recommend'
      ORDER BY f.name_vi
    `, [conditionIds]);

    res.json({
      success: true,
      foods_to_avoid: avoidResult.rows,
      foods_to_recommend: recommendResult.rows,
      conditions: conditionsResult.rows
    });

  } catch (error) {
    console.error('Error getting user food recommendations:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy khuyến nghị thực phẩm',
      error: error.message
    });
  }
});

// GET /api/suggestions/user-dish-recommendations - Get user's dish recommendations based on their health conditions
router.get('/user-dish-recommendations', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.user_id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    // Get user's active health conditions
    const conditionsResult = await db.query(`
      SELECT DISTINCT hc.condition_id, hc.condition_name
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 
        AND uhc.status = 'active'
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= get_vietnam_date())
    `, [userId]);

    if (conditionsResult.rows.length === 0) {
      return res.json({
        success: true,
        dishes_to_avoid: [],
        dishes_to_recommend: [],
        conditions: []
      });
    }

    const conditionIds = conditionsResult.rows.map(c => c.condition_id);

    // Get dishes to avoid for user's conditions
    const avoidResult = await db.query(`
      SELECT DISTINCT 
        cdr.dish_id,
        COALESCE(d.vietnamese_name, d.name) as dish_name,
        d.category,
        cdr.reason,
        hc.condition_name
      FROM conditiondishrecommendation cdr
      JOIN dish d ON cdr.dish_id = d.dish_id
      JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
      WHERE cdr.condition_id = ANY($1::int[]) 
        AND cdr.recommendation_type = 'avoid'
    `, [conditionIds]);

    // Get dishes to recommend for user's conditions
    const recommendResult = await db.query(`
      SELECT DISTINCT 
        cdr.dish_id,
        COALESCE(d.vietnamese_name, d.name) as dish_name,
        d.category,
        cdr.reason,
        hc.condition_name
      FROM conditiondishrecommendation cdr
      JOIN dish d ON cdr.dish_id = d.dish_id
      JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
      WHERE cdr.condition_id = ANY($1::int[]) 
        AND cdr.recommendation_type = 'recommend'
    `, [conditionIds]);

    res.json({
      success: true,
      dishes_to_avoid: avoidResult.rows,
      dishes_to_recommend: recommendResult.rows,
      conditions: conditionsResult.rows
    });

  } catch (error) {
    console.error('Error getting user dish recommendations:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy khuyến nghị món ăn',
      error: error.message
    });
  }
});

// GET /api/suggestions/user-drink-recommendations - Get user's drink recommendations based on their health conditions
router.get('/user-drink-recommendations', authMiddleware, async (req, res) => {
  try {
    const userId = req.user?.user_id;
    
    if (!userId) {
      return res.status(401).json({
        success: false,
        message: 'Unauthorized'
      });
    }

    // Get user's active health conditions
    const conditionsResult = await db.query(`
      SELECT DISTINCT hc.condition_id, hc.condition_name
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 
        AND uhc.status = 'active'
        AND (uhc.treatment_end_date IS NULL OR uhc.treatment_end_date >= get_vietnam_date())
    `, [userId]);

    if (conditionsResult.rows.length === 0) {
      return res.json({
        success: true,
        drinks_to_avoid: [],
        drinks_to_recommend: [],
        conditions: []
      });
    }

    const conditionIds = conditionsResult.rows.map(c => c.condition_id);

    // Get drinks to avoid for user's conditions
    const avoidResult = await db.query(`
      SELECT DISTINCT 
        cdr.drink_id,
        COALESCE(d.vietnamese_name, d.name) as drink_name,
        d.category,
        cdr.reason,
        hc.condition_name
      FROM conditiondrinkrecommendation cdr
      JOIN drink d ON cdr.drink_id = d.drink_id
      JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
      WHERE cdr.condition_id = ANY($1::int[]) 
        AND cdr.recommendation_type = 'avoid'
    `, [conditionIds]);

    // Get drinks to recommend for user's conditions
    const recommendResult = await db.query(`
      SELECT DISTINCT 
        cdr.drink_id,
        COALESCE(d.vietnamese_name, d.name) as drink_name,
        d.category,
        cdr.reason,
        hc.condition_name
      FROM conditiondrinkrecommendation cdr
      JOIN drink d ON cdr.drink_id = d.drink_id
      JOIN healthcondition hc ON cdr.condition_id = hc.condition_id
      WHERE cdr.condition_id = ANY($1::int[]) 
        AND cdr.recommendation_type = 'recommend'
    `, [conditionIds]);

    res.json({
      success: true,
      drinks_to_avoid: avoidResult.rows,
      drinks_to_recommend: recommendResult.rows,
      conditions: conditionsResult.rows
    });

  } catch (error) {
    console.error('Error getting user drink recommendations:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy khuyến nghị đồ uống',
      error: error.message
    });
  }
});

// POST /api/suggestions - Create a suggestion record
router.post('/', async (req, res) => {
  try {
    const { user_id, date, nutrient_id, deficiency_amount, suggested_food_id, note } = req.body;
    
    if (!user_id || !nutrient_id) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu thông tin bắt buộc'
      });
    }
    
    const result = await db.query(`
      INSERT INTO Suggestion (user_id, date, nutrient_id, deficiency_amount, suggested_food_id, note)
      VALUES ($1, $2, $3, $4, $5, $6)
      RETURNING *
    `, [user_id, date || getVietnamDate(), nutrient_id, deficiency_amount, suggested_food_id, note]);
    
    res.json({
      success: true,
      suggestion: result.rows[0]
    });
    
  } catch (error) {
    console.error('Error creating suggestion:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo gợi ý',
      error: error.message
    });
  }
});

module.exports = router;
