const mealService = require('../services/mealService');
const db = require('../db');
const { getVietnamDate } = require('../utils/dateHelper');

async function createMeal(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { meal_type, meal_date, items } = req.body || {};
  // meal_date expected as YYYY-MM-DD or null
  const date = meal_date ? meal_date : getVietnamDate();

  try {
    const result = await mealService.createMealWithItems(user.user_id, meal_type, date, items || []);
    return res.status(201).json({ meal_id: result.meal_id, today: result.today });
  } catch (err) {
    console.error('createMeal error', err);
    return res.status(500).json({ error: 'Could not create meal' });
  }
}

async function addDishToMeal(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { mealType, dishId, weightG, date } = req.body;
  const mealDate = date || getVietnamDate();

  console.log('[addDishToMeal] Request body:', req.body);
  console.log('[addDishToMeal] mealType value:', mealType, 'type:', typeof mealType);

  try {
    // Get dish ingredients
    const dishResult = await db.query(
      'SELECT dish_id, name, serving_size_g FROM dish WHERE dish_id = $1',
      [dishId]
    );
    
    if (dishResult.rows.length === 0) {
      return res.status(404).json({ error: 'Dish not found' });
    }

    const dish = dishResult.rows[0];
    
    // Get dish ingredients
    const ingredientsResult = await db.query(
      `SELECT di.food_id, di.weight_g, f.name as food_name
       FROM dishingredient di 
       JOIN Food f ON di.food_id = f.food_id
       WHERE di.dish_id = $1`,
      [dishId]
    );

    // Check if any ingredient is restricted by user's health conditions
    const healthConditionService = require('../services/healthConditionService');
    const restrictedFoods = await healthConditionService.getRestrictedFoods(user.user_id);
    
    for (const ingredient of ingredientsResult.rows) {
      const isRestricted = restrictedFoods.some(rf => rf.food_id === ingredient.food_id);
      
      if (isRestricted) {
        const restrictedFood = restrictedFoods.find(rf => rf.food_id === ingredient.food_id);
        return res.status(400).json({ 
          error: 'Món ăn không được phép',
          message: `Món ăn "${dish.name}" chứa ${restrictedFood.food_name} không phù hợp với tình trạng sức khỏe của bạn (${restrictedFood.condition_name})`,
          restricted: true,
          food_name: restrictedFood.food_name,
          dish_name: dish.name,
          condition_name: restrictedFood.condition_name,
          notes: restrictedFood.notes
        });
      }
    }

    // Scale ingredients based on serving size
    const servingSize = dish.serving_size_g || 100;
    const multiplier = weightG / servingSize;
    
    // Insert each ingredient as a meal entry
    const mealEntriesService = require('../services/mealEntriesService');
    const entryIds = [];
    
    for (const ingredient of ingredientsResult.rows) {
      const scaledWeight = ingredient.weight_g * multiplier;
      const entry = await mealEntriesService.createMealEntry(
        user.user_id,
        mealDate,
        mealType,
        ingredient.food_id,
        scaledWeight
      );
      entryIds.push(entry.entryId);
    }

    // Update nutrient tracking after adding meal
    const nutrientTrackingService = require('../services/nutrientTrackingService');
    await nutrientTrackingService.updateNutrientTracking(user.user_id, mealDate);
    
    // Get today's summary from DailySummary (updated by trigger on meal_entries)
    // This ensures consistency with addFoodToMeal and Mediterranean diet updates
    const summaryResult = await db.query(
      `SELECT total_calories, total_protein, total_fat, total_carbs 
       FROM DailySummary 
       WHERE user_id = $1 AND date = $2`,
      [user.user_id, mealDate]
    );
    
    const summary = summaryResult.rows[0] || {};
    
    return res.status(201).json({ 
      success: true,
      entry_ids: entryIds,
      today: {
        today_calories: parseFloat(summary.total_calories || 0),
        today_protein: parseFloat(summary.total_protein || 0),
        today_fat: parseFloat(summary.total_fat || 0),
        today_carbs: parseFloat(summary.total_carbs || 0),
      }
    });
  } catch (err) {
    console.error('addDishToMeal error:', err);
    console.error('Error stack:', err.stack);
    console.error('Error details:', {
      userId: user.user_id,
      mealType: req.body.mealType,
      dishId: req.body.dishId,
      weightG: req.body.weightG
    });
    return res.status(500).json({ error: 'Could not add dish to meal', details: err.message });
  }
}

async function addFoodToMeal(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { mealType, foodId, weightG, date } = req.body;
  const mealDate = date || getVietnamDate();

  console.log('[addFoodToMeal] Request body:', req.body);
  console.log('[addFoodToMeal] mealType value:', mealType, 'type:', typeof mealType);

  try {
    // Check if food is restricted by user's health conditions
    const healthConditionService = require('../services/healthConditionService');
    const restrictedFoods = await healthConditionService.getRestrictedFoods(user.user_id);
    
    const isRestricted = restrictedFoods.some(rf => rf.food_id === parseInt(foodId));
    
    if (isRestricted) {
      const restrictedFood = restrictedFoods.find(rf => rf.food_id === parseInt(foodId));
      return res.status(400).json({ 
        error: 'Thực phẩm không được phép',
        message: `${restrictedFood.food_name} không phù hợp với tình trạng sức khỏe của bạn (${restrictedFood.condition_name})`,
        restricted: true,
        food_name: restrictedFood.food_name,
        condition_name: restrictedFood.condition_name,
        notes: restrictedFood.notes
      });
    }
    
    const items = [{ food_id: foodId, weight_g: weightG }];
    const result = await mealService.createMealWithItems(user.user_id, mealType, mealDate, items);
    
    // Update nutrient tracking after adding meal
    const nutrientTrackingService = require('../services/nutrientTrackingService');
    await nutrientTrackingService.updateNutrientTracking(user.user_id, mealDate);
    
    return res.status(201).json({ 
      success: true,
      meal_id: result.meal_id, 
      today: result.today 
    });
  } catch (err) {
    console.error('addFoodToMeal error:', err);
    console.error('Error stack:', err.stack);
    console.error('Error details:', {
      userId: user.user_id,
      mealType: req.body.mealType,
      foodId: req.body.foodId,
      weightG: req.body.weightG
    });
    return res.status(500).json({ error: 'Could not add food to meal', details: err.message });
  }
}

module.exports = { createMeal, addDishToMeal, addFoodToMeal };
