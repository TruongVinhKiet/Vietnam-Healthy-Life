const healthConditionService = require('../services/healthConditionService');

// Get all conditions
async function getAllConditions(req, res) {
  try {
    const conditions = await healthConditionService.getAllConditions();
    res.json({ success: true, conditions });
  } catch (err) {
    console.error('[healthConditionController] getAllConditions error:', err);
    res.status(500).json({ error: 'Failed to get conditions' });
  }
}

// Get condition by ID
async function getConditionById(req, res) {
  try {
    const { id } = req.params;
    const condition = await healthConditionService.getConditionById(id);
    
    if (!condition) {
      return res.status(404).json({ error: 'Condition not found' });
    }
    
    res.json({ success: true, condition });
  } catch (err) {
    console.error('[healthConditionController] getConditionById error:', err);
    res.status(500).json({ error: 'Failed to get condition' });
  }
}

// Create condition (admin only)
async function createCondition(req, res) {
  try {
    const condition = await healthConditionService.createCondition(req.body);
    res.status(201).json({ success: true, condition });
  } catch (err) {
    console.error('[healthConditionController] createCondition error:', err);
    res.status(500).json({ error: 'Failed to create condition' });
  }
}

// Update condition (admin only)
async function updateCondition(req, res) {
  try {
    const { id } = req.params;
    const condition = await healthConditionService.updateCondition(id, req.body);
    
    if (!condition) {
      return res.status(404).json({ error: 'Condition not found' });
    }
    
    res.json({ success: true, condition });
  } catch (err) {
    console.error('[healthConditionController] updateCondition error:', err);
    res.status(500).json({ error: 'Failed to update condition' });
  }
}

// Delete condition (admin only)
async function deleteCondition(req, res) {
  try {
    const { id } = req.params;
    await healthConditionService.deleteCondition(id);
    res.json({ success: true, message: 'Condition deleted' });
  } catch (err) {
    console.error('[healthConditionController] deleteCondition error:', err);
    res.status(500).json({ error: 'Failed to delete condition' });
  }
}

// Add nutrient effect (admin only)
async function addNutrientEffect(req, res) {
  try {
    const { id } = req.params;
    const { nutrient_id, effect_type, adjustment_percent, notes } = req.body;
    
    const effect = await healthConditionService.addNutrientEffect(
      id, nutrient_id, effect_type, adjustment_percent, notes
    );
    
    res.json({ success: true, effect });
  } catch (err) {
    console.error('[healthConditionController] addNutrientEffect error:', err);
    res.status(500).json({ error: 'Failed to add nutrient effect' });
  }
}

// Add food restriction (admin only)
async function addFoodRestriction(req, res) {
  try {
    const { id } = req.params;
    const { food_id, recommendation_type, notes } = req.body;
    
    const restriction = await healthConditionService.addFoodRestriction(
      id, food_id, recommendation_type, notes
    );
    
    res.json({ success: true, restriction });
  } catch (err) {
    console.error('[healthConditionController] addFoodRestriction error:', err);
    res.status(500).json({ error: 'Failed to add food restriction' });
  }
}

// Get user's conditions
async function getUserConditions(req, res) {
  try {
    const userId = req.user.user_id;
    const conditions = await healthConditionService.getUserConditions(userId);
    res.json({ success: true, conditions });
  } catch (err) {
    console.error('[healthConditionController] getUserConditions error:', err);
    res.status(500).json({ error: 'Failed to get user conditions' });
  }
}

// Add condition to user
async function addUserCondition(req, res) {
  try {
    const userId = req.user.user_id;
    const { condition_id, treatment_start_date, treatment_end_date, medication_times, medication_details } = req.body;
    
    const userCondition = await healthConditionService.addUserCondition(
      userId, condition_id, treatment_start_date, treatment_end_date, medication_times, medication_details
    );
    
    res.status(201).json({ success: true, user_condition: userCondition });
  } catch (err) {
    console.error('[healthConditionController] addUserCondition error:', err);
    
    // Handle duplicate key constraint
    if (err.code === '23505') {
      return res.status(409).json({ 
        error: 'Bạn đã thêm bệnh này với ngày bắt đầu điều trị trùng lặp. Vui lòng chọn ngày khác hoặc xóa bản ghi cũ.',
        code: 'DUPLICATE_CONDITION'
      });
    }
    
    res.status(500).json({ error: 'Failed to add condition to user' });
  }
}

// Update user condition status
async function updateUserConditionStatus(req, res) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    
    const userCondition = await healthConditionService.updateUserConditionStatus(id, status);
    res.json({ success: true, user_condition: userCondition });
  } catch (err) {
    console.error('[healthConditionController] updateUserConditionStatus error:', err);
    res.status(500).json({ error: 'Failed to update condition status' });
  }
}

// Get adjusted RDA for user
async function getAdjustedRDA(req, res) {
  try {
    const userId = req.user.user_id;
    const adjustments = await healthConditionService.getAdjustedRDA(userId);
    res.json({ success: true, adjustments });
  } catch (err) {
    console.error('[healthConditionController] getAdjustedRDA error:', err);
    res.status(500).json({ error: 'Failed to get adjusted RDA' });
  }
}

// Get restricted foods for user
async function getRestrictedFoods(req, res) {
  try {
    const userId = req.user.user_id;
    const foods = await healthConditionService.getRestrictedFoods(userId);
    res.json({ success: true, restricted_foods: foods });
  } catch (err) {
    console.error('[healthConditionController] getRestrictedFoods error:', err);
    res.status(500).json({ error: 'Failed to get restricted foods' });
  }
}

// Extend treatment end date
async function extendTreatment(req, res) {
  try {
    const { id } = req.params;
    const { new_end_date } = req.body;
    const userId = req.user.user_id;
    
    const result = await healthConditionService.extendTreatment(userId, id, new_end_date);
    res.json({ success: true, user_condition: result });
  } catch (err) {
    console.error('[healthConditionController] extendTreatment error:', err);
    res.status(500).json({ error: 'Failed to extend treatment' });
  }
}

// Mark condition as recovered
async function markRecovered(req, res) {
  try {
    const { id } = req.params;
    const userId = req.user.user_id;
    
    const result = await healthConditionService.markRecovered(userId, id);
    res.json({ success: true, user_condition: result });
  } catch (err) {
    console.error('[healthConditionController] markRecovered error:', err);
    res.status(500).json({ error: 'Failed to mark as recovered' });
  }
}

module.exports = {
  getAllConditions,
  getConditionById,
  createCondition,
  updateCondition,
  deleteCondition,
  addNutrientEffect,
  addFoodRestriction,
  getUserConditions,
  addUserCondition,
  updateUserConditionStatus,
  getAdjustedRDA,
  getRestrictedFoods,
  extendTreatment,
  markRecovered
};
