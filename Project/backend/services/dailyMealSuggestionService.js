const { pool } = require('../db');
const { toVietnamDate } = require('../utils/dateHelper');
const nutrientTrackingService = require('./nutrientTrackingService');
const healthConditionService = require('./healthConditionService');

/**
 * Daily Meal Suggestion Service
 * Algorithm: Calculate daily nutrient gaps -> Distribute by meal % -> Find optimal dish/drink combinations
 */

class DailyMealSuggestionService {

  _remainingObjective(nutrientGaps, totals) {
    const safeTotals = totals || {};
    let objective = 0;
    for (const [nid, gap] of Object.entries(nutrientGaps || {})) {
      const g = parseFloat(gap) || 0;
      if (g <= 0) continue;
      const provided = parseFloat(safeTotals[nid]) || 0;
      objective += Math.max(0, g - provided);
    }
    return objective;
  }

  _applyNutrientsDelta(totals, nutrients, direction) {
    const safeTotals = totals || {};
    if (!nutrients) return safeTotals;
    const dir = direction === -1 ? -1 : 1;
    for (const [nid, amt] of Object.entries(nutrients)) {
      safeTotals[nid] = (parseFloat(safeTotals[nid]) || 0) + dir * (parseFloat(amt) || 0);
    }
    return safeTotals;
  }

  _wouldExceedCapsAfterChange(totals, removeNutrients, addNutrients, caps) {
    const safeTotals = totals || {};
    const safeCaps = caps || {};
    const remove = removeNutrients || {};
    const add = addNutrients || {};

    const nutrientIds = new Set([
      ...Object.keys(remove),
      ...Object.keys(add),
      ...Object.keys(safeCaps)
    ]);

    for (const nid of nutrientIds) {
      const cap = parseFloat(safeCaps[nid]);
      if (!Number.isFinite(cap)) continue;
      const nextTotal =
        (parseFloat(safeTotals[nid]) || 0) - (parseFloat(remove[nid]) || 0) + (parseFloat(add[nid]) || 0);
      if (nextTotal > cap) return true;
    }

    return false;
  }

  _selectItemsUnderCaps(scoredItems, count, totals, caps) {
    const selected = [];
    if (!Array.isArray(scoredItems) || !count || count <= 0) return selected;
    const safeTotals = totals || {};
    const safeCaps = caps || {};

    const wouldExceed = (nutrients) => {
      if (!nutrients) return false;
      for (const [nid, amt] of Object.entries(nutrients)) {
        const cap = parseFloat(safeCaps[nid]);
        if (!Number.isFinite(cap)) continue;
        const nextTotal = (parseFloat(safeTotals[nid]) || 0) + (parseFloat(amt) || 0);
        if (nextTotal > cap) return true;
      }
      return false;
    };

    const applyTotals = (nutrients) => {
      if (!nutrients) return;
      for (const [nid, amt] of Object.entries(nutrients)) {
        safeTotals[nid] = (parseFloat(safeTotals[nid]) || 0) + (parseFloat(amt) || 0);
      }
    };

    for (const item of scoredItems) {
      if (selected.length >= count) break;
      if (wouldExceed(item.nutrients)) continue;
      selected.push(item);
      applyTotals(item.nutrients);
    }

    return selected;
  }
  
  /**
   * Generate daily meal suggestions for a user
   * @param {number} userId 
   * @param {Date} date 
   * @param {Object} mealCounts - Optional meal counts from user
   * @returns {Promise<Object>} Generated suggestions with scores
   */
  async generateDailySuggestions(userId, date = new Date(), mealCounts = {}) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Step 1: Get user settings (meal counts, times, percentages, health conditions)
      const userSettings = await this._getUserSettings(client, userId);
      if (!userSettings) {
        throw new Error('User settings not found');
      }

      userSettings.breakfast_dish_count = 1;
      userSettings.breakfast_drink_count = 1;
      userSettings.lunch_dish_count = 1;
      userSettings.lunch_drink_count = 1;
      userSettings.dinner_dish_count = 1;
      userSettings.dinner_drink_count = 1;
      userSettings.snack_dish_count = 1;
      userSettings.snack_drink_count = 1;

      const rdaTargets = await this._calculateSuggestionTargets(userSettings, client);

      // Step 2: Calculate daily nutrient gaps (target - consumed)
      const nutrientGaps = await this._calculateDailyNutrientGaps(client, userId, date, rdaTargets);

      const nutrientCaps = {};
      for (const [nutrientId, target] of Object.entries(rdaTargets)) {
        const t = parseFloat(target) || 0;
        const g = parseFloat(nutrientGaps[nutrientId]) || 0;
        const consumed = Math.max(0, t - g);
        nutrientCaps[nutrientId] = Math.max(0, t * 1.5 - consumed);
      }

      // Track total nutrients contributed by suggestions (across all meals)
      const suggestionTotals = {};

      // Step 3: Distribute gaps by meal percentages
      const mealGaps = this._distributeMealGaps(nutrientGaps, userSettings);

      // Step 4: Get user's health conditions to filter contraindications
      const userConditions = await this._getUserHealthConditions(client, userId);

      // Step 5: Generate suggestions for each meal
      const mealContexts = {
        breakfast: await this._generateMealSuggestionsDetailed(
          client,
          userId,
          date,
          'breakfast',
          mealGaps.breakfast,
          userConditions,
          userSettings,
          suggestionTotals,
          nutrientCaps
        ),
        lunch: await this._generateMealSuggestionsDetailed(
          client,
          userId,
          date,
          'lunch',
          mealGaps.lunch,
          userConditions,
          userSettings,
          suggestionTotals,
          nutrientCaps
        ),
        dinner: await this._generateMealSuggestionsDetailed(
          client,
          userId,
          date,
          'dinner',
          mealGaps.dinner,
          userConditions,
          userSettings,
          suggestionTotals,
          nutrientCaps
        ),
        snack: await this._generateMealSuggestionsDetailed(
          client,
          userId,
          date,
          'snack',
          mealGaps.snack,
          userConditions,
          userSettings,
          suggestionTotals,
          nutrientCaps
        )
      };

      const coreTargetIds = await this._getCoreTargetNutrientIds(client, rdaTargets);
      const coreGaps = {};
      coreTargetIds.forEach((nid) => {
        const k = String(nid);
        if (nutrientGaps[k] !== undefined) coreGaps[k] = nutrientGaps[k];
      });

      await this._expandDailyPlanToMeetTargets(
        client,
        coreGaps,
        userConditions,
        mealContexts,
        suggestionTotals,
        nutrientCaps
      );

      const suggestions = {
        breakfast: mealContexts.breakfast.suggestions,
        lunch: mealContexts.lunch.suggestions,
        dinner: mealContexts.dinner.suggestions,
        snack: mealContexts.snack.suggestions
      };

      // Step 6: Save suggestions to database
      await this._saveSuggestions(client, userId, date, suggestions);

      await client.query('COMMIT');

      return {
        success: true,
        date: date,
        nutrientGaps,
        suggestions
      };

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Get user settings including meal counts and health profile
   */
  async _getUserSettings(client, userId) {
    // Get user with settings
    const result = await client.query(`
      SELECT 
        u.user_id,
        u.age, 
        u.gender, 
        u.weight_kg as weight, 
        u.height_cm as height,
        COALESCE(up.activity_level, u.activity_level, 'moderately_active') as activity_level,
        COALESCE(up.daily_water_target, u.daily_water_target) as daily_water_target,
        COALESCE(us.breakfast_dish_count, 2) as breakfast_dish_count,
        COALESCE(us.breakfast_drink_count, 1) as breakfast_drink_count,
        COALESCE(us.lunch_dish_count, 2) as lunch_dish_count,
        COALESCE(us.lunch_drink_count, 1) as lunch_drink_count,
        COALESCE(us.dinner_dish_count, 2) as dinner_dish_count,
        COALESCE(us.dinner_drink_count, 1) as dinner_drink_count,
        COALESCE(us.snack_dish_count, 1) as snack_dish_count,
        COALESCE(us.snack_drink_count, 1) as snack_drink_count,
        COALESCE(us.breakfast_percentage, 25) as breakfast_percentage,
        COALESCE(us.lunch_percentage, 35) as lunch_percentage,
        COALESCE(us.dinner_percentage, 30) as dinner_percentage,
        COALESCE(us.snack_percentage, 10) as snack_percentage
      FROM "User" u
      LEFT JOIN UserSetting us ON us.user_id = u.user_id
      LEFT JOIN UserProfile up ON up.user_id = u.user_id
      WHERE u.user_id = $1
    `, [userId]);

    if (result.rows.length === 0) {
      console.log('[DailyMealSuggestion] User query returned no rows for userId:', userId);
      throw new Error('User not found');
    }

    const settings = result.rows[0];

    // Validate required profile fields
    if (!settings.age || settings.age <= 0) {
      throw new Error('User age is missing or invalid. Please complete your profile.');
    }
    if (!settings.gender || !['male', 'female'].includes(settings.gender.toLowerCase())) {
      throw new Error('User gender is missing or invalid. Please complete your profile.');
    }
    if (!settings.weight || settings.weight <= 0) {
      throw new Error('User weight is missing or invalid. Please complete your profile.');
    }
    if (!settings.height || settings.height <= 0) {
      throw new Error('User height is missing or invalid. Please complete your profile.');
    }

    return settings;
  }

  /**
   * Calculate daily nutrient gaps (RDA target - already consumed today)
   */
  async _calculateDailyNutrientGaps(client, userId, date, rdaTargets) {
    const dateStr = toVietnamDate(date);

    const targetNutrientIds = Object.keys(rdaTargets)
      .map((k) => parseInt(k, 10))
      .filter((v) => Number.isFinite(v));

    const consumed = {};

    // If there are no targets, avoid querying with empty ANY()
    if (targetNutrientIds.length > 0) {
      // Sum consumed nutrients from both new system (meal_entries) and old system (Meal/MealItem)
      const consumedResult = await client.query(`
        WITH meal_items_today AS (
          SELECT me.food_id, me.weight_g
          FROM meal_entries me
          WHERE me.user_id = $1 AND me.entry_date = $2
          UNION ALL
          SELECT mi.food_id, mi.weight_g
          FROM MealItem mi
          JOIN Meal m ON m.meal_id = mi.meal_id
          WHERE m.user_id = $1 AND m.meal_date = $2
        ),
        consumed_nutrients AS (
          SELECT fn.nutrient_id,
                 SUM(fn.amount_per_100g * mit.weight_g / 100.0) AS total
          FROM meal_items_today mit
          JOIN FoodNutrient fn ON fn.food_id = mit.food_id
          WHERE fn.nutrient_id = ANY($3::int[])
          GROUP BY fn.nutrient_id
        )
        SELECT nutrient_id, total AS consumed
        FROM consumed_nutrients
      `, [userId, dateStr, targetNutrientIds]);

      consumedResult.rows.forEach(row => {
        consumed[row.nutrient_id] = parseFloat(row.consumed) || 0;
      });

      const manualRes = await client.query(
        `
        SELECT n.nutrient_id,
               SUM(uml.amount) AS total_amount
        FROM UserNutrientManualLog uml
        JOIN nutrient n
          ON (
            UPPER(n.nutrient_code) = UPPER(uml.nutrient_code)
            OR (uml.nutrient_code ILIKE 'MIN_%' AND UPPER(n.nutrient_code) = UPPER(REPLACE(uml.nutrient_code, 'MIN_', '')))
            OR (uml.nutrient_type = 'amino_acid' AND UPPER(n.nutrient_code) = UPPER('AMINO_' || uml.nutrient_code))
          )
        WHERE uml.user_id = $1 AND uml.log_date = $2
          AND n.nutrient_id = ANY($3::int[])
        GROUP BY n.nutrient_id
      `,
        [userId, dateStr, targetNutrientIds]
      );

      manualRes.rows.forEach((row) => {
        const nutrientId = row.nutrient_id;
        consumed[nutrientId] = (parseFloat(consumed[nutrientId]) || 0) + (parseFloat(row.total_amount) || 0);
      });
    }

    const coreIdResult = await client.query(
      `
      SELECT nutrient_id, UPPER(nutrient_code) AS code
      FROM nutrient
      WHERE UPPER(nutrient_code) IN ('ENERC_KCAL','PROCNT','FAT','CHOCDF','WATER')
    `
    );

    const coreIdByCode = {};
    coreIdResult.rows.forEach((row) => {
      coreIdByCode[String(row.code || '').toUpperCase()] = row.nutrient_id;
    });

    const dailySummaryRes = await client.query(
      `
      SELECT
        COALESCE(total_calories, 0) AS total_calories,
        COALESCE(total_protein, 0) AS total_protein,
        COALESCE(total_fat, 0) AS total_fat,
        COALESCE(total_carbs, 0) AS total_carbs,
        COALESCE(total_water, 0) AS total_water
      FROM DailySummary
      WHERE user_id = $1 AND date = $2
      LIMIT 1
    `,
      [userId, dateStr]
    );
    const ds = dailySummaryRes.rows[0] || {};

    const energyNutrientId = coreIdByCode['ENERC_KCAL'];
    const proteinNutrientId = coreIdByCode['PROCNT'];
    const fatNutrientId = coreIdByCode['FAT'];
    const carbNutrientId = coreIdByCode['CHOCDF'];
    const waterNutrientId = coreIdByCode['WATER'];

    if (energyNutrientId && rdaTargets[String(energyNutrientId)] !== undefined) {
      consumed[energyNutrientId] = parseFloat(ds.total_calories) || 0;
    }
    if (proteinNutrientId && rdaTargets[String(proteinNutrientId)] !== undefined) {
      consumed[proteinNutrientId] = parseFloat(ds.total_protein) || 0;
    }
    if (fatNutrientId && rdaTargets[String(fatNutrientId)] !== undefined) {
      consumed[fatNutrientId] = parseFloat(ds.total_fat) || 0;
    }
    if (carbNutrientId && rdaTargets[String(carbNutrientId)] !== undefined) {
      consumed[carbNutrientId] = parseFloat(ds.total_carbs) || 0;
    }
    if (waterNutrientId && rdaTargets[String(waterNutrientId)] !== undefined) {
      const waterConsumed = parseFloat(ds.total_water) || 0;
      consumed[waterNutrientId] = (parseFloat(consumed[waterNutrientId]) || 0) + waterConsumed;
    }

    // Calculate gaps (target - consumed)
    const gaps = {};
    for (const [nutrientId, target] of Object.entries(rdaTargets)) {
      const consumedAmount = consumed[nutrientId] || 0;
      gaps[nutrientId] = Math.max(0, target - consumedAmount); // Only positive gaps
    }

    return gaps;
  }

  async _calculateSuggestionTargets(userSettings, queryClient = null) {
    const { user_id, age, gender, weight, height, activity_level, daily_water_target } = userSettings;

    if (!age || !gender || !weight || !height) {
      throw new Error('User profile incomplete: missing age, gender, weight, or height');
    }

    const bmr = gender === 'male'
      ? 10 * weight + 6.25 * height - 5 * age + 5
      : 10 * weight + 6.25 * height - 5 * age - 161;

    const activityMultipliers = {
      sedentary: 1.2,
      lightly_active: 1.375,
      moderately_active: 1.55,
      very_active: 1.725,
      extra_active: 1.9
    };

    const tdee = bmr * (activityMultipliers[activity_level] || 1.5);

    const q = queryClient || pool;
    const nutrientMappingResult = await q.query(`
      SELECT nutrient_id, name, nutrient_code, unit
      FROM nutrient
      WHERE UPPER(nutrient_code) IN ('ENERC_KCAL','PROCNT','FAT','CHOCDF','WATER')
    `);

    const nutrientCodeMap = {};
    nutrientMappingResult.rows.forEach((row) => {
      if (row.nutrient_code) nutrientCodeMap[String(row.nutrient_code).toUpperCase()] = row.nutrient_id;
    });

    const targets = {};
    const energyId = nutrientCodeMap['ENERC_KCAL'];
    const proteinId = nutrientCodeMap['PROCNT'];
    const fatId = nutrientCodeMap['FAT'];
    const carbId = nutrientCodeMap['CHOCDF'];
    const waterId = nutrientCodeMap['WATER'];

    if (energyId) targets[energyId] = tdee;
    if (proteinId) targets[proteinId] = weight * 0.8;
    if (fatId) targets[fatId] = tdee * 0.3 / 9;
    if (carbId) targets[carbId] = tdee * 0.5 / 4;

    if (waterId) {
      const userWater = parseFloat(daily_water_target);
      const fallbackWater = (parseFloat(weight) || 0) * 35;
      const targetWater = Number.isFinite(userWater) && userWater > 0 ? userWater : fallbackWater;
      if (targetWater > 0) targets[waterId] = targetWater;
    }

    const adjustments = await healthConditionService.getAdjustedRDA(user_id);
    const adjustmentMap = new Map();
    (adjustments || []).forEach((adj) => {
      adjustmentMap.set(String(adj.nutrient_id), parseFloat(adj.total_adjustment) || 0);
    });

    for (const [nid, target] of Object.entries(targets)) {
      const baseTarget = parseFloat(target) || 0;
      const adjustment = adjustmentMap.get(String(nid)) || 0;
      if (adjustment !== 0 && baseTarget > 0) {
        targets[nid] = baseTarget * (1 + adjustment / 100);
      } else {
        targets[nid] = baseTarget;
      }
    }

    return targets;
  }

  /**
   * Calculate RDA targets based on user profile using database requirement tables
   */
  async _calculateRDATargets(userSettings) {
    const { user_id, age, gender, weight, height, activity_level } = userSettings;

    // Validate user profile
    if (!age || !gender || !weight || !height) {
      throw new Error('User profile incomplete: missing age, gender, weight, or height');
    }

    // Calculate BMR and TDEE for energy/macronutrient targets
    const bmr = gender === 'male'
      ? 10 * weight + 6.25 * height - 5 * age + 5
      : 10 * weight + 6.25 * height - 5 * age - 161;

    const activityMultipliers = {
      sedentary: 1.2,
      lightly_active: 1.375,
      moderately_active: 1.55,
      very_active: 1.725,
      extra_active: 1.9
    };

    const tdee = bmr * (activityMultipliers[activity_level] || 1.5);

    const targets = {};

    // Get nutrient IDs dynamically from database
    const nutrientMappingResult = await pool.query(`
      SELECT nutrient_id, name, nutrient_code
      FROM nutrient
      WHERE UPPER(nutrient_code) IN (
        'ENERC_KCAL','PROCNT','FAT','CHOCDF','FIBTG','SUGAR','SUGARS'
      )
         OR name IN (
        'Energy', 'Energy (Calories)',
        'Protein',
        'Fat', 'Total Fat',
        'Carbohydrate', 'Carbohydrate, by difference',
        'Fiber', 'Dietary Fiber (total)',
        'Sugars'
      )
    `);

    const nutrientMap = {};
    const nutrientCodeMap = {};
    nutrientMappingResult.rows.forEach(row => {
      if (row.name) nutrientMap[row.name] = row.nutrient_id;
      if (row.nutrient_code) nutrientCodeMap[String(row.nutrient_code).toUpperCase()] = row.nutrient_id;
    });

    // Set macronutrient targets based on TDEE
    const energyId = nutrientCodeMap['ENERC_KCAL'] || nutrientMap['Energy'] || nutrientMap['Energy (Calories)'];
    const proteinId = nutrientCodeMap['PROCNT'] || nutrientMap['Protein'];
    const fatId = nutrientCodeMap['FAT'] || nutrientMap['Fat'] || nutrientMap['Total Fat'];
    const carbId = nutrientCodeMap['CHOCDF'] || nutrientMap['Carbohydrate'] || nutrientMap['Carbohydrate, by difference'];
    const fiberId = nutrientCodeMap['FIBTG'] || nutrientMap['Fiber'] || nutrientMap['Dietary Fiber (total)'];
    const sugarsId = nutrientCodeMap['SUGARS'] || nutrientCodeMap['SUGAR'] || nutrientMap['Sugars'];

    if (energyId) targets[energyId] = tdee;
    if (proteinId) targets[proteinId] = weight * 0.8; // 0.8g per kg
    if (fatId) targets[fatId] = tdee * 0.3 / 9; // 30% of calories
    if (carbId) targets[carbId] = tdee * 0.5 / 4; // 50% of calories
    if (fiberId) targets[fiberId] = 25; // General recommendation
    if (sugarsId) targets[sugarsId] = 50; // Max limit

    // Get vitamin requirements from uservitaminrequirement
    const vitaminResult = await pool.query(`
      SELECT uvr.vitamin_id, uvr.recommended, n.nutrient_id
      FROM uservitaminrequirement uvr
      JOIN vitamin v ON v.vitamin_id = uvr.vitamin_id
      LEFT JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(v.code)
      WHERE uvr.user_id = $1 AND uvr.recommended IS NOT NULL
    `, [user_id]);

    vitaminResult.rows.forEach(row => {
      if (row.nutrient_id && row.recommended) {
        targets[row.nutrient_id] = parseFloat(row.recommended);
      }
    });

    // Get mineral requirements from usermineralrequirement
    const mineralResult = await pool.query(`
      SELECT umr.mineral_id, umr.recommended, n.nutrient_id
      FROM usermineralrequirement umr
      JOIN mineral m ON m.mineral_id = umr.mineral_id
      LEFT JOIN nutrient n ON UPPER(n.nutrient_code) = UPPER(REPLACE(m.code, 'MIN_', ''))
      WHERE umr.user_id = $1 AND umr.recommended IS NOT NULL
    `, [user_id]);

    mineralResult.rows.forEach(row => {
      if (row.nutrient_id && row.recommended) {
        targets[row.nutrient_id] = parseFloat(row.recommended);
      }
    });

    // TODO: Add amino acid, fiber, and fatty acid requirements mapping
    // These require AminoNutrient, FiberNutrient, FattyAcidNutrient mapping tables
    // Currently focusing on vitamins and minerals which have existing mapping tables

    return targets;
  }

  /**
   * Distribute daily nutrient gaps across meals based on meal percentages
   */
  _distributeMealGaps(dailyGaps, userSettings) {
    const { breakfast_percentage, lunch_percentage, dinner_percentage, snack_percentage } = userSettings;

    return {
      breakfast: this._scaleGaps(dailyGaps, breakfast_percentage / 100),
      lunch: this._scaleGaps(dailyGaps, lunch_percentage / 100),
      dinner: this._scaleGaps(dailyGaps, dinner_percentage / 100),
      snack: this._scaleGaps(dailyGaps, snack_percentage / 100)
    };
  }

  _scaleGaps(gaps, percentage) {
    const scaled = {};
    for (const [nutrientId, amount] of Object.entries(gaps)) {
      scaled[nutrientId] = amount * percentage;
    }
    return scaled;
  }

  /**
   * Get user's health conditions to filter out contraindicated foods
   */
  async _getUserHealthConditions(client, userId) {
    const result = await client.query(`
      SELECT DISTINCT hc.condition_id
      FROM userhealthcondition uhc
      JOIN healthcondition hc ON uhc.condition_id = hc.condition_id
      WHERE uhc.user_id = $1 AND uhc.status = 'active'
    `, [userId]);

    return result.rows.map(row => row.condition_id);
  }

  async _getCoreTargetNutrientIds(client, rdaTargets) {
    const ids = Object.keys(rdaTargets || {})
      .map((k) => parseInt(k, 10))
      .filter((v) => Number.isFinite(v));
    if (ids.length === 0) return [];

    const res = await client.query(
      `
      SELECT nutrient_id, UPPER(nutrient_code) AS code
      FROM nutrient
      WHERE nutrient_id = ANY($1::int[])
    `,
      [ids]
    );

    const keep = new Set(['ENERC_KCAL', 'PROCNT', 'FAT', 'CHOCDF', 'WATER']);
    return res.rows
      .filter((r) => keep.has(String(r.code || '').toUpperCase()))
      .map((r) => r.nutrient_id);
  }

  async _expandDailyPlanToMeetTargets(
    client,
    coreGaps,
    userConditions,
    mealContexts,
    suggestionTotals,
    nutrientCaps
  ) {
    const mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    const maxPerMeal = 10;
    const maxAdds = 40;
    const minPerMealDishes = 2;
    const minPerMealDrinks = 2;

    const objectiveNow = () => this._remainingObjective(coreGaps, suggestionTotals);

    const rebuildSuggestions = (ctx) => {
      const next = [];
      (ctx.selectedDishes || []).forEach((dish) => {
        next.push({ meal_type: ctx.mealType, dish_id: dish.dish_id, drink_id: null, score: dish.score });
      });
      (ctx.selectedDrinks || []).forEach((drink) => {
        next.push({ meal_type: ctx.mealType, dish_id: null, drink_id: drink.drink_id, score: drink.score });
      });
      ctx.suggestions = next;
    };

    const globalDishIds = new Set();
    const globalDrinkIds = new Set();

    // Ensure each meal has candidate lists and selected arrays
    for (const mealType of mealTypes) {
      const ctx = mealContexts[mealType];
      if (!ctx) continue;

      if (!Array.isArray(ctx.scoredDishes) || !Array.isArray(ctx.scoredDrinks)) {
        const dishes = await this._getCandidateDishes(client, userConditions, mealType);
        const drinks = await this._getCandidateDrinks(client, userConditions);
        ctx.scoredDishes = await this._scoreDishes(client, dishes, ctx.mealGaps || {});
        ctx.scoredDrinks = await this._scoreDrinks(client, drinks, ctx.mealGaps || {});
      }

      ctx.selectedDishes = Array.isArray(ctx.selectedDishes) ? ctx.selectedDishes : [];
      ctx.selectedDrinks = Array.isArray(ctx.selectedDrinks) ? ctx.selectedDrinks : [];

      ctx.selectedDishes.forEach((d) => d?.dish_id && globalDishIds.add(d.dish_id));
      ctx.selectedDrinks.forEach((d) => d?.drink_id && globalDrinkIds.add(d.drink_id));
      rebuildSuggestions(ctx);
    }

    const pickFirstUnderCaps = (candidates, kind, mealSelectedIds) => {
      const idKey = kind === 'dish' ? 'dish_id' : 'drink_id';
      const globalIds = kind === 'dish' ? globalDishIds : globalDrinkIds;

      for (const cand of candidates || []) {
        const id = cand?.[idKey];
        if (!id) continue;
        if (mealSelectedIds.has(id)) continue;
        if (globalIds.has(id)) continue;
        if (this._wouldExceedCapsAfterChange(suggestionTotals, null, cand.nutrients, nutrientCaps)) continue;
        return cand;
      }
      return null;
    };

    // Phase 1: enforce per-meal minimums (2 dishes, 2 drinks)
    for (const mealType of mealTypes) {
      const ctx = mealContexts[mealType];
      if (!ctx) continue;

      const mealDishIds = new Set(ctx.selectedDishes.map((d) => d.dish_id));
      const mealDrinkIds = new Set(ctx.selectedDrinks.map((d) => d.drink_id));

      while (ctx.selectedDishes.length < minPerMealDishes && ctx.selectedDishes.length < maxPerMeal) {
        const cand = pickFirstUnderCaps(ctx.scoredDishes, 'dish', mealDishIds);
        if (!cand) break;
        ctx.selectedDishes.push(cand);
        mealDishIds.add(cand.dish_id);
        globalDishIds.add(cand.dish_id);
        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, +1);
      }

      while (ctx.selectedDrinks.length < minPerMealDrinks && ctx.selectedDrinks.length < maxPerMeal) {
        const cand = pickFirstUnderCaps(ctx.scoredDrinks, 'drink', mealDrinkIds);
        if (!cand) break;
        ctx.selectedDrinks.push(cand);
        mealDrinkIds.add(cand.drink_id);
        globalDrinkIds.add(cand.drink_id);
        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, +1);
      }

      rebuildSuggestions(ctx);
    }

    // Phase 2: expand across the day until core gaps are met (>=100%) or no improvement
    const pickBestAdd = (ctx, kind) => {
      const before = objectiveNow();
      const candidates = kind === 'dish' ? ctx.scoredDishes : ctx.scoredDrinks;
      const selected = kind === 'dish' ? ctx.selectedDishes : ctx.selectedDrinks;
      const idKey = kind === 'dish' ? 'dish_id' : 'drink_id';
      const globalIds = kind === 'dish' ? globalDishIds : globalDrinkIds;
      const mealSelectedIds = new Set(selected.map((x) => x[idKey]));

      let best = null;
      for (const cand of candidates || []) {
        const id = cand?.[idKey];
        if (!id) continue;
        if (mealSelectedIds.has(id)) continue;
        if (globalIds.has(id)) continue;
        if (selected.length >= maxPerMeal) continue;
        if (this._wouldExceedCapsAfterChange(suggestionTotals, null, cand.nutrients, nutrientCaps)) continue;

        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, +1);
        const after = objectiveNow();
        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, -1);

        const delta = before - after;
        if (delta > 0 && (!best || delta > best.delta)) {
          best = { cand, delta };
        }
      }

      return best;
    };

    for (let adds = 0; adds < maxAdds; adds++) {
      if (objectiveNow() <= 0) break;

      let bestMove = null;
      for (const mealType of mealTypes) {
        const ctx = mealContexts[mealType];
        if (!ctx) continue;

        const dishMove = pickBestAdd(ctx, 'dish');
        if (dishMove && (!bestMove || dishMove.delta > bestMove.delta)) {
          bestMove = { mealType, kind: 'dish', ...dishMove };
        }
        const drinkMove = pickBestAdd(ctx, 'drink');
        if (drinkMove && (!bestMove || drinkMove.delta > bestMove.delta)) {
          bestMove = { mealType, kind: 'drink', ...drinkMove };
        }
      }

      if (!bestMove) break;

      const ctx = mealContexts[bestMove.mealType];
      if (!ctx) break;
      if (bestMove.kind === 'dish') {
        ctx.selectedDishes.push(bestMove.cand);
        globalDishIds.add(bestMove.cand.dish_id);
      } else {
        ctx.selectedDrinks.push(bestMove.cand);
        globalDrinkIds.add(bestMove.cand.drink_id);
      }
      this._applyNutrientsDelta(suggestionTotals, bestMove.cand.nutrients, +1);
      rebuildSuggestions(ctx);
    }

    return mealContexts;
  }

  /**
   * Generate suggestions for a specific meal
   * Returns array of {dish_id, drink_id, score}
   */
  async _generateMealSuggestions(
    client,
    userId,
    date,
    mealType,
    mealGaps,
    userConditions,
    userSettings,
    suggestionTotals,
    nutrientCaps
  ) {
    const dishCount = userSettings[`${mealType}_dish_count`];
    const drinkCount = userSettings[`${mealType}_drink_count`];

    // Get candidate dishes (not contraindicated)
    const dishes = await this._getCandidateDishes(client, userConditions, mealType);
    
    // Get candidate drinks (not contraindicated)
    const drinks = await this._getCandidateDrinks(client, userConditions);

    // Score each dish based on how well it fills nutrient gaps
    const scoredDishes = await this._scoreDishes(client, dishes, mealGaps);
    
    // Score each drink
    const scoredDrinks = await this._scoreDrinks(client, drinks, mealGaps);

    // Select dishes/drinks under daily caps (<=150% target across all suggested items)
    const selectedDishes = this._selectItemsUnderCaps(
      scoredDishes,
      dishCount,
      suggestionTotals,
      nutrientCaps
    );
    const selectedDrinks = this._selectItemsUnderCaps(
      scoredDrinks,
      drinkCount,
      suggestionTotals,
      nutrientCaps
    );

    // Combine into suggestions
    const suggestions = [];
    selectedDishes.forEach(dish => {
      suggestions.push({
        meal_type: mealType,
        dish_id: dish.dish_id,
        drink_id: null,
        score: dish.score
      });
    });

    selectedDrinks.forEach(drink => {
      suggestions.push({
        meal_type: mealType,
        dish_id: null,
        drink_id: drink.drink_id,
        score: drink.score
      });
    });

    return suggestions;
  }

  async _generateMealSuggestionsDetailed(
    client,
    userId,
    date,
    mealType,
    mealGaps,
    userConditions,
    userSettings,
    suggestionTotals,
    nutrientCaps
  ) {
    const dishCount = userSettings[`${mealType}_dish_count`];
    const drinkCount = userSettings[`${mealType}_drink_count`];

    const dishes = await this._getCandidateDishes(client, userConditions, mealType);
    const drinks = await this._getCandidateDrinks(client, userConditions);

    const scoredDishes = await this._scoreDishes(client, dishes, mealGaps);
    const scoredDrinks = await this._scoreDrinks(client, drinks, mealGaps);

    const selectedDishes = this._selectItemsUnderCaps(
      scoredDishes,
      dishCount,
      suggestionTotals,
      nutrientCaps
    );
    const selectedDrinks = this._selectItemsUnderCaps(
      scoredDrinks,
      drinkCount,
      suggestionTotals,
      nutrientCaps
    );

    const suggestions = [];
    selectedDishes.forEach((dish) => {
      suggestions.push({
        meal_type: mealType,
        dish_id: dish.dish_id,
        drink_id: null,
        score: dish.score
      });
    });
    selectedDrinks.forEach((drink) => {
      suggestions.push({
        meal_type: mealType,
        dish_id: null,
        drink_id: drink.drink_id,
        score: drink.score
      });
    });

    return {
      mealType,
      mealGaps,
      dishCount,
      drinkCount,
      scoredDishes,
      scoredDrinks,
      selectedDishes,
      selectedDrinks,
      suggestions
    };
  }

  async _improveSuggestionsTowardsMinimums(
    client,
    nutrientGaps,
    userConditions,
    userSettings,
    mealContexts,
    suggestionTotals,
    nutrientCaps
  ) {
    const mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

    const objectiveNow = () => this._remainingObjective(nutrientGaps, suggestionTotals);

    const rebuildSuggestions = (ctx) => {
      const next = [];
      (ctx.selectedDishes || []).forEach((dish) => {
        next.push({ meal_type: ctx.mealType, dish_id: dish.dish_id, drink_id: null, score: dish.score });
      });
      (ctx.selectedDrinks || []).forEach((drink) => {
        next.push({ meal_type: ctx.mealType, dish_id: null, drink_id: drink.drink_id, score: drink.score });
      });
      ctx.suggestions = next;
    };

    const pickBestAdd = (candidates, selectedIds, kind) => {
      const before = objectiveNow();
      let best = null;
      for (const cand of candidates || []) {
        const id = kind === 'dish' ? cand.dish_id : cand.drink_id;
        if (!id) continue;
        if (selectedIds.has(id)) continue;
        if (this._wouldExceedCapsAfterChange(suggestionTotals, null, cand.nutrients, nutrientCaps)) continue;

        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, +1);
        const after = objectiveNow();
        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, -1);

        const delta = before - after;
        if (delta > 0 && (!best || delta > best.delta)) {
          best = { cand, delta };
        }
      }
      return best;
    };

    const pickBestSwap = (candidates, selectedIds, currentItem, kind) => {
      const before = objectiveNow();
      let best = null;

      for (const cand of candidates || []) {
        const id = kind === 'dish' ? cand.dish_id : cand.drink_id;
        if (!id) continue;
        if (selectedIds.has(id)) continue;
        if (this._wouldExceedCapsAfterChange(suggestionTotals, currentItem.nutrients, cand.nutrients, nutrientCaps)) continue;

        this._applyNutrientsDelta(suggestionTotals, currentItem.nutrients, -1);
        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, +1);
        const after = objectiveNow();
        this._applyNutrientsDelta(suggestionTotals, cand.nutrients, -1);
        this._applyNutrientsDelta(suggestionTotals, currentItem.nutrients, +1);

        const delta = before - after;
        if (delta > 0 && (!best || delta > best.delta)) {
          best = { cand, delta };
        }
      }

      return best;
    };

    for (let pass = 0; pass < 3; pass++) {
      let improved = false;
      if (objectiveNow() <= 0) break;

      for (const mealType of mealTypes) {
        const ctx = mealContexts[mealType];
        if (!ctx) continue;

        // Ensure we have scored candidate lists (in case ctx came from older call sites)
        if (!Array.isArray(ctx.scoredDishes) || !Array.isArray(ctx.scoredDrinks)) {
          const dishes = await this._getCandidateDishes(client, userConditions, mealType);
          const drinks = await this._getCandidateDrinks(client, userConditions);
          ctx.scoredDishes = await this._scoreDishes(client, dishes, ctx.mealGaps || {});
          ctx.scoredDrinks = await this._scoreDrinks(client, drinks, ctx.mealGaps || {});
        }

        ctx.selectedDishes = Array.isArray(ctx.selectedDishes) ? ctx.selectedDishes : [];
        ctx.selectedDrinks = Array.isArray(ctx.selectedDrinks) ? ctx.selectedDrinks : [];

        // Fill missing dish slots if any (try candidates that reduce remaining gaps)
        const selectedDishIds = new Set(ctx.selectedDishes.map((d) => d.dish_id));
        while (ctx.selectedDishes.length < (ctx.dishCount || 0)) {
          const best = pickBestAdd(ctx.scoredDishes, selectedDishIds, 'dish');
          if (!best) break;
          ctx.selectedDishes.push(best.cand);
          selectedDishIds.add(best.cand.dish_id);
          this._applyNutrientsDelta(suggestionTotals, best.cand.nutrients, +1);
          improved = true;
          if (objectiveNow() <= 0) break;
        }

        // Fill missing drink slots if any
        const selectedDrinkIds = new Set(ctx.selectedDrinks.map((d) => d.drink_id));
        while (ctx.selectedDrinks.length < (ctx.drinkCount || 0)) {
          const best = pickBestAdd(ctx.scoredDrinks, selectedDrinkIds, 'drink');
          if (!best) break;
          ctx.selectedDrinks.push(best.cand);
          selectedDrinkIds.add(best.cand.drink_id);
          this._applyNutrientsDelta(suggestionTotals, best.cand.nutrients, +1);
          improved = true;
          if (objectiveNow() <= 0) break;
        }

        // Swap dish candidates to reduce remaining gaps
        for (let i = 0; i < ctx.selectedDishes.length; i++) {
          const current = ctx.selectedDishes[i];
          if (!current) continue;
          const best = pickBestSwap(ctx.scoredDishes, selectedDishIds, current, 'dish');
          if (!best) continue;
          this._applyNutrientsDelta(suggestionTotals, current.nutrients, -1);
          this._applyNutrientsDelta(suggestionTotals, best.cand.nutrients, +1);
          selectedDishIds.delete(current.dish_id);
          selectedDishIds.add(best.cand.dish_id);
          ctx.selectedDishes[i] = best.cand;
          improved = true;
          if (objectiveNow() <= 0) break;
        }

        // Swap drink candidates
        for (let i = 0; i < ctx.selectedDrinks.length; i++) {
          const current = ctx.selectedDrinks[i];
          if (!current) continue;
          const best = pickBestSwap(ctx.scoredDrinks, selectedDrinkIds, current, 'drink');
          if (!best) continue;
          this._applyNutrientsDelta(suggestionTotals, current.nutrients, -1);
          this._applyNutrientsDelta(suggestionTotals, best.cand.nutrients, +1);
          selectedDrinkIds.delete(current.drink_id);
          selectedDrinkIds.add(best.cand.drink_id);
          ctx.selectedDrinks[i] = best.cand;
          improved = true;
          if (objectiveNow() <= 0) break;
        }

        rebuildSuggestions(ctx);
      }

      if (!improved) break;
    }

    return mealContexts;
  }

  /**
   * Get candidate dishes (excluding contraindicated ones)
   */
  async _getCandidateDishes(client, userConditions, mealType) {
    if (userConditions.length === 0) {
      // No health conditions - all dishes allowed
      const result = await client.query(`
        SELECT d.dish_id, d.name, d.vietnamese_name, d.category,
          0 AS recommend_ingredient_count
        FROM dish d
        WHERE d.is_public = true
        ORDER BY RANDOM()
        LIMIT 50
      `);
      return result.rows;
    }

    // Exclude dishes with contraindicated ingredients
    const result = await client.query(`
      SELECT d.dish_id, d.name, d.vietnamese_name, d.category,
        COALESCE(rec.recommend_ingredient_count, 0) AS recommend_ingredient_count
      FROM dish d
      LEFT JOIN (
        SELECT di.dish_id, COUNT(DISTINCT di.food_id) AS recommend_ingredient_count
        FROM dishingredient di
        JOIN conditionfoodrecommendation cfr
          ON di.food_id = cfr.food_id
        WHERE cfr.condition_id = ANY($1)
          AND cfr.recommendation_type = 'recommend'
        GROUP BY di.dish_id
      ) rec ON rec.dish_id = d.dish_id
      WHERE d.is_public = true
        AND d.dish_id NOT IN (
          SELECT DISTINCT di.dish_id
          FROM dishingredient di
          JOIN conditionfoodrecommendation cfr ON di.food_id = cfr.food_id
          WHERE cfr.condition_id = ANY($1)
            AND cfr.recommendation_type = 'avoid'
        )
      ORDER BY COALESCE(rec.recommend_ingredient_count, 0) DESC, RANDOM()
      LIMIT 50
    `, [userConditions]);

    return result.rows;
  }

  /**
   * Get candidate drinks (excluding contraindicated ones)
   */
  async _getCandidateDrinks(client, userConditions) {
    if (userConditions.length === 0) {
      const result = await client.query(`
        SELECT d.drink_id, d.name, d.vietnamese_name, d.category,
          0 AS recommend_ingredient_count
        FROM drink d
        WHERE d.is_public = true
        ORDER BY RANDOM()
        LIMIT 30
      `);
      return result.rows;
    }

    // Exclude drinks with contraindicated ingredients from health conditions
    const result = await client.query(`
      SELECT d.drink_id, d.name, d.vietnamese_name, d.category,
        COALESCE(rec.recommend_ingredient_count, 0) AS recommend_ingredient_count
      FROM drink d
      LEFT JOIN (
        SELECT di.drink_id, COUNT(DISTINCT di.food_id) AS recommend_ingredient_count
        FROM drinkingredient di
        JOIN conditionfoodrecommendation cfr
          ON di.food_id = cfr.food_id
        WHERE cfr.condition_id = ANY($1)
          AND cfr.recommendation_type = 'recommend'
        GROUP BY di.drink_id
      ) rec ON rec.drink_id = d.drink_id
      WHERE d.is_public = true
        AND EXISTS (
          SELECT 1
          FROM drinkingredient di_any
          WHERE di_any.drink_id = d.drink_id
        )
        AND d.drink_id NOT IN (
          SELECT DISTINCT di.drink_id
          FROM drinkingredient di
          JOIN conditionfoodrecommendation cfr ON di.food_id = cfr.food_id
          WHERE cfr.condition_id = ANY($1)
            AND cfr.recommendation_type = 'avoid'
        )
      ORDER BY COALESCE(rec.recommend_ingredient_count, 0) DESC, RANDOM()
      LIMIT 30
    `, [userConditions]);

    return result.rows;
  }

  /**
   * Score dishes based on nutrient gap filling
   * Score = Sum of (min(nutrient_provided, gap) / gap) for each nutrient
   * Range: 0-100
   * OPTIMIZED: Batch query all nutrients at once to avoid N+1 problem
   */
  async _scoreDishes(client, dishes, mealGaps) {
    if (dishes.length === 0) return [];

    // Extract all dish IDs
    const dishIds = dishes.map(d => d.dish_id);

    // Batch query all dish nutrients in one query (scale by dish serving_size_g)
    const nutrientsResult = await client.query(`
      SELECT
        dn.dish_id,
        dn.nutrient_id,
        (dn.amount_per_100g * (COALESCE(d.serving_size_g, 100) / 100.0)) as amount
      FROM dishnutrient dn
      JOIN dish d ON d.dish_id = dn.dish_id
      WHERE dn.dish_id = ANY($1)
    `, [dishIds]);

    // Group nutrients by dish_id
    const dishNutrients = {};
    nutrientsResult.rows.forEach(row => {
      if (!dishNutrients[row.dish_id]) {
        dishNutrients[row.dish_id] = {};
      }
      dishNutrients[row.dish_id][row.nutrient_id] = parseFloat(row.amount);
    });

    // Score each dish
    const scored = dishes.map(dish => {
      const nutrients = dishNutrients[dish.dish_id] || {};
      
      let score = 0;
      let matchCount = 0;

      for (const [nutrientId, gap] of Object.entries(mealGaps)) {
        if (gap > 0 && nutrients[nutrientId]) {
          const provided = nutrients[nutrientId];
          const fillRatio = Math.min(provided, gap) / gap;
          score += fillRatio;
          matchCount++;
        }
      }

      // Normalize to 0-100
      let finalScore = matchCount > 0 ? (score / matchCount) * 100 : 0;

      const recommendIngredientCount = parseInt(dish.recommend_ingredient_count, 10) || 0;
      if (recommendIngredientCount > 0) {
        finalScore += Math.min(recommendIngredientCount, 4) * 2.5;
      }
      finalScore = Math.min(finalScore, 100);

      return {
        ...dish,
        nutrients,
        score: Math.round(finalScore * 100) / 100
      };
    });

    // Sort by score descending
    return scored.sort((a, b) => b.score - a.score);
  }

  /**
   * Score drinks based on nutrient gap filling
   * OPTIMIZED: Batch query all nutrients at once to avoid N+1 problem
   */
  async _scoreDrinks(client, drinks, mealGaps) {
    if (drinks.length === 0) return [];

    // Extract all drink IDs
    const drinkIds = drinks.map(d => d.drink_id);

    const waterIdResult = await client.query(
      `SELECT nutrient_id FROM nutrient WHERE UPPER(nutrient_code) = 'WATER' LIMIT 1`
    );
    const waterNutrientId = waterIdResult.rows[0]?.nutrient_id;

    const drinkMetaResult = await client.query(
      `
      SELECT drink_id,
        COALESCE(hydration_ratio, 1.0) AS hydration_ratio,
        COALESCE(default_volume_ml, 250) AS default_volume_ml
      FROM drink
      WHERE drink_id = ANY($1)
    `,
      [drinkIds]
    );
    const drinkMeta = {};
    drinkMetaResult.rows.forEach((row) => {
      drinkMeta[row.drink_id] = {
        hydration_ratio: parseFloat(row.hydration_ratio) || 1.0,
        default_volume_ml: parseFloat(row.default_volume_ml) || 250
      };
    });

    // Batch query all drink nutrients in one query (amount is per 100ml)
    // Assuming standard 250ml serving
    const nutrientsResult = await client.query(`
      SELECT
        dn.drink_id,
        dn.nutrient_id,
        (dn.amount_per_100ml * (COALESCE(d.default_volume_ml, 250) / 100.0)) as amount
      FROM drinknutrient dn
      JOIN drink d ON d.drink_id = dn.drink_id
      WHERE dn.drink_id = ANY($1)
    `, [drinkIds]);

    // Group nutrients by drink_id
    const drinkNutrients = {};
    const hasWaterFromNutrients = {};
    nutrientsResult.rows.forEach(row => {
      if (!drinkNutrients[row.drink_id]) {
        drinkNutrients[row.drink_id] = {};
      }
      drinkNutrients[row.drink_id][row.nutrient_id] = parseFloat(row.amount);
      if (waterNutrientId && parseInt(row.nutrient_id, 10) === parseInt(waterNutrientId, 10)) {
        hasWaterFromNutrients[row.drink_id] = true;
      }
    });

    if (waterNutrientId) {
      for (const drinkId of drinkIds) {
        if (!drinkNutrients[drinkId]) drinkNutrients[drinkId] = {};
        if (hasWaterFromNutrients[drinkId]) continue;
        const meta = drinkMeta[drinkId] || { hydration_ratio: 1.0, default_volume_ml: 250 };
        const waterProvided = (parseFloat(meta.hydration_ratio) || 1.0) * (parseFloat(meta.default_volume_ml) || 250);
        if (waterProvided > 0) {
          drinkNutrients[drinkId][waterNutrientId] = waterProvided;
        }
      }
    }

    // Score each drink
    const scored = drinks.map(drink => {
      const nutrients = drinkNutrients[drink.drink_id] || {};
      
      let score = 0;
      let matchCount = 0;

      for (const [nutrientId, gap] of Object.entries(mealGaps)) {
        if (gap > 0 && nutrients[nutrientId]) {
          const provided = nutrients[nutrientId];
          const fillRatio = Math.min(provided, gap) / gap;
          score += fillRatio;
          matchCount++;
        }
      }

      let finalScore = matchCount > 0 ? (score / matchCount) * 100 : 0;

      const recommendIngredientCount =
          parseInt(drink.recommend_ingredient_count, 10) || 0;
      if (recommendIngredientCount > 0) {
        finalScore += Math.min(recommendIngredientCount, 4) * 2.5;
      }
      finalScore = Math.min(finalScore, 100);

      return {
        ...drink,
        nutrients,
        score: Math.round(finalScore * 100) / 100
      };
    });

    return scored.sort((a, b) => b.score - a.score);
  }

  /**
   * Save suggestions to database
   */
  async _saveSuggestions(client, userId, date, suggestions) {
    const dateStr = toVietnamDate(date);

    // Delete old suggestions for this date
    await client.query(`
      DELETE FROM user_daily_meal_suggestions
      WHERE user_id = $1 AND date = $2
    `, [userId, dateStr]);

    // Insert new suggestions
    for (const mealType of ['breakfast', 'lunch', 'dinner', 'snack']) {
      const mealSuggestions = suggestions[mealType];
      
      for (const suggestion of mealSuggestions) {
        await client.query(`
          INSERT INTO user_daily_meal_suggestions 
            (user_id, date, meal_type, dish_id, drink_id, suggestion_score)
          VALUES ($1, $2, $3, $4, $5, $6)
          ON CONFLICT (user_id, date, meal_type, dish_id, drink_id) 
          DO UPDATE SET 
            suggestion_score = EXCLUDED.suggestion_score,
            updated_at = CURRENT_TIMESTAMP
        `, [userId, dateStr, mealType, suggestion.dish_id, suggestion.drink_id, suggestion.score]);
      }
    }
  }

  /**
   * Get suggestions for a user and date
   */
  async getSuggestions(userId, date = new Date()) {
    const dateStr = toVietnamDate(date);
    
    const result = await pool.query(`
      SELECT 
        s.*,
        d.name as dish_name,
        d.vietnamese_name as dish_vietnamese_name,
        d.category as dish_category,
        d.serving_size_g as dish_serving_size_g,
        d.image_url as dish_image_url,
        dr.name as drink_name,
        dr.vietnamese_name as drink_vietnamese_name,
        dr.category as drink_category,
        dr.default_volume_ml as drink_default_volume_ml,
        dr.hydration_ratio as drink_hydration_ratio,
        dr.image_url as drink_image_url
      FROM user_daily_meal_suggestions s
      LEFT JOIN dish d ON s.dish_id = d.dish_id
      LEFT JOIN drink dr ON s.drink_id = dr.drink_id
      WHERE s.user_id = $1 AND s.date = $2
      ORDER BY s.meal_type, s.suggestion_score DESC
    `, [userId, dateStr]);

    // Group by meal type
    const grouped = {
      breakfast: [],
      lunch: [],
      dinner: [],
      snack: []
    };

    result.rows.forEach(row => {
      grouped[row.meal_type].push(row);
    });

    return grouped;
  }

  /**
   * Calculate total nutrients from all suggestions and compare with daily requirements
   */
  async calculateNutrientSummary(userId, date, suggestions) {
    const client = await pool.connect();
    try {
      const dateStr = toVietnamDate(date);
      // Flatten all suggestions
      const allSuggestions = [
        ...suggestions.breakfast,
        ...suggestions.lunch,
        ...suggestions.dinner,
        ...suggestions.snack
      ];

      // Calculate total nutrients from dishes
      const dishIds = allSuggestions.filter(s => s.dish_id).map(s => s.dish_id);
      const drinkIds = allSuggestions.filter(s => s.drink_id).map(s => s.drink_id);

      const totalNutrients = {};

      // Get nutrients from dishes (100g serving)
      if (dishIds.length > 0) {
        const dishNutrients = await client.query(`
          SELECT
            dn.nutrient_id,
            SUM(dn.amount_per_100g * (COALESCE(d.serving_size_g, 100) / 100.0)) as total
          FROM unnest($1::int[]) AS u(dish_id)
          JOIN dish d ON d.dish_id = u.dish_id
          JOIN dishnutrient dn ON dn.dish_id = u.dish_id
          GROUP BY dn.nutrient_id
        `, [dishIds]);

        dishNutrients.rows.forEach(row => {
          totalNutrients[row.nutrient_id] = parseFloat(row.total);
        });
      }

      // Get nutrients from drinks (250ml serving)
      if (drinkIds.length > 0) {
        const drinkNutrients = await client.query(`
          SELECT
            dn.nutrient_id,
            SUM(dn.amount_per_100ml * (COALESCE(d.default_volume_ml, 250) / 100.0)) as total
          FROM unnest($1::int[]) AS u(drink_id)
          JOIN drink d ON d.drink_id = u.drink_id
          JOIN drinknutrient dn ON dn.drink_id = u.drink_id
          GROUP BY dn.nutrient_id
        `, [drinkIds]);

        drinkNutrients.rows.forEach(row => {
          const nutrientId = row.nutrient_id;
          totalNutrients[nutrientId] = (totalNutrients[nutrientId] || 0) + parseFloat(row.total);
        });
      }

      const userSettings = await this._getUserSettings(client, userId);
      const targets = await this._calculateSuggestionTargets(userSettings, client);
      const targetNutrientIds = Object.keys(targets)
        .map((k) => parseInt(k, 10))
        .filter((v) => Number.isFinite(v));

      const nutrientMeta = {};
      if (targetNutrientIds.length > 0) {
        const metaResult = await client.query(`
          SELECT nutrient_id, name, unit, nutrient_code
          FROM nutrient
          WHERE nutrient_id = ANY($1::int[])
        `, [targetNutrientIds]);
        metaResult.rows.forEach((row) => {
          nutrientMeta[row.nutrient_id] = row;
        });
      }

      const consumed = {};
      if (targetNutrientIds.length > 0) {
        const consumedResult = await client.query(`
          WITH meal_items_today AS (
            SELECT me.food_id, me.weight_g
            FROM meal_entries me
            WHERE me.user_id = $1 AND me.entry_date = $2
            UNION ALL
            SELECT mi.food_id, mi.weight_g
            FROM MealItem mi
            JOIN Meal m ON m.meal_id = mi.meal_id
            WHERE m.user_id = $1 AND m.meal_date = $2
          ),
          consumed_nutrients AS (
            SELECT fn.nutrient_id,
                   SUM(fn.amount_per_100g * mit.weight_g / 100.0) AS total
            FROM meal_items_today mit
            JOIN FoodNutrient fn ON fn.food_id = mit.food_id
            WHERE fn.nutrient_id = ANY($3::int[])
            GROUP BY fn.nutrient_id
          )
          SELECT nutrient_id, total AS consumed
          FROM consumed_nutrients
        `, [userId, dateStr, targetNutrientIds]);

        consumedResult.rows.forEach((row) => {
          consumed[row.nutrient_id] = parseFloat(row.consumed) || 0;
        });

        const manualRes = await client.query(
          `
          SELECT n.nutrient_id,
                 SUM(uml.amount) AS total_amount
          FROM UserNutrientManualLog uml
          JOIN nutrient n
            ON (
              UPPER(n.nutrient_code) = UPPER(uml.nutrient_code)
              OR (uml.nutrient_code ILIKE 'MIN_%' AND UPPER(n.nutrient_code) = UPPER(REPLACE(uml.nutrient_code, 'MIN_', '')))
              OR (uml.nutrient_type = 'amino_acid' AND UPPER(n.nutrient_code) = UPPER('AMINO_' || uml.nutrient_code))
            )
          WHERE uml.user_id = $1 AND uml.log_date = $2
            AND n.nutrient_id = ANY($3::int[])
          GROUP BY n.nutrient_id
        `,
          [userId, dateStr, targetNutrientIds]
        );

        manualRes.rows.forEach((row) => {
          const nutrientId = row.nutrient_id;
          consumed[nutrientId] = (parseFloat(consumed[nutrientId]) || 0) + (parseFloat(row.total_amount) || 0);
        });
      }

      const coreIdResult = await client.query(
        `
        SELECT nutrient_id, UPPER(nutrient_code) AS code
        FROM nutrient
        WHERE UPPER(nutrient_code) IN ('ENERC_KCAL','PROCNT','FAT','CHOCDF','WATER')
      `
      );

      const coreIdByCode = {};
      coreIdResult.rows.forEach((row) => {
        coreIdByCode[String(row.code || '').toUpperCase()] = row.nutrient_id;
      });

      const energyNutrientId = coreIdByCode['ENERC_KCAL'];
      const proteinNutrientId = coreIdByCode['PROCNT'];
      const fatNutrientId = coreIdByCode['FAT'];
      const carbNutrientId = coreIdByCode['CHOCDF'];
      const waterNutrientId = coreIdByCode['WATER'];

      const dailySummaryRes = await client.query(
        `
        SELECT
          COALESCE(total_calories, 0) AS total_calories,
          COALESCE(total_protein, 0) AS total_protein,
          COALESCE(total_fat, 0) AS total_fat,
          COALESCE(total_carbs, 0) AS total_carbs,
          COALESCE(total_water, 0) AS total_water
        FROM DailySummary
        WHERE user_id = $1 AND date = $2
        LIMIT 1
      `,
        [userId, dateStr]
      );
      const ds = dailySummaryRes.rows[0] || {};

      if (energyNutrientId && targets[String(energyNutrientId)] !== undefined) {
        consumed[energyNutrientId] = parseFloat(ds.total_calories) || 0;
      }
      if (proteinNutrientId && targets[String(proteinNutrientId)] !== undefined) {
        consumed[proteinNutrientId] = parseFloat(ds.total_protein) || 0;
      }
      if (fatNutrientId && targets[String(fatNutrientId)] !== undefined) {
        consumed[fatNutrientId] = parseFloat(ds.total_fat) || 0;
      }
      if (carbNutrientId && targets[String(carbNutrientId)] !== undefined) {
        consumed[carbNutrientId] = parseFloat(ds.total_carbs) || 0;
      }

      if (waterNutrientId && targets[String(waterNutrientId)] !== undefined) {
        if (drinkIds.length > 0) {
          const waterInDrinkRes = await client.query(
            `
            SELECT DISTINCT drink_id
            FROM drinknutrient
            WHERE drink_id = ANY($1::int[]) AND nutrient_id = $2
          `,
            [drinkIds, waterNutrientId]
          );

          const drinkIdsWithWater = new Set(waterInDrinkRes.rows.map((r) => r.drink_id));
          const missingWaterDrinkIds = drinkIds.filter((id) => !drinkIdsWithWater.has(id));

          if (missingWaterDrinkIds.length > 0) {
            const drinkWaterRes = await client.query(
              `
              SELECT COALESCE(SUM(COALESCE(d.hydration_ratio, 1.0) * COALESCE(d.default_volume_ml, 250)), 0) AS water_ml
              FROM unnest($1::int[]) AS u(drink_id)
              JOIN drink d ON d.drink_id = u.drink_id
            `,
              [missingWaterDrinkIds]
            );
            const suggestedWater = parseFloat(drinkWaterRes.rows[0]?.water_ml) || 0;
            if (suggestedWater > 0) {
              totalNutrients[waterNutrientId] = (parseFloat(totalNutrients[waterNutrientId]) || 0) + suggestedWater;
            }
          }
        }

        const waterConsumed = parseFloat(ds.total_water) || 0;
        consumed[waterNutrientId] = (parseFloat(consumed[waterNutrientId]) || 0) + waterConsumed;
      }

      const adjustments = await healthConditionService.getAdjustedRDA(userId);
      const adjustmentMap = new Map();
      (adjustments || []).forEach((adj) => {
        adjustmentMap.set(String(adj.nutrient_id), parseFloat(adj.total_adjustment) || 0);
      });

      const summary = targetNutrientIds
        .map((nutrientId) => {
          const target = parseFloat(targets[nutrientId]) || 0;
          const current = parseFloat(consumed[nutrientId]) || 0;
          const suggested = parseFloat(totalNutrients[nutrientId]) || 0;
          const provided = current + suggested;
          const rawPercentage = target > 0 ? (provided / target * 100) : 0;
          const percentage = rawPercentage;
          const meta = nutrientMeta[nutrientId] || {};
          const code = String(meta.nutrient_code || '').toUpperCase();
          const name =
            code === 'ENERC_KCAL'
              ? 'Kcal'
              : code === 'CHOCDF'
              ? 'Carb'
              : code === 'FAT'
              ? 'Fat'
              : code === 'PROCNT'
              ? 'Protein'
              : code === 'WATER'
              ? 'Water'
              : meta.name || String(meta.nutrient_code || nutrientId);
          const adjustmentPercent = adjustmentMap.get(String(nutrientId)) || 0;
          const hasAdjustment = adjustmentPercent !== 0 && target > 0;
          return {
            nutrient_id: nutrientId,
            nutrient_name: name,
            provided: Math.round(provided * 100) / 100,
            recommended: target,
            percentage: Math.round(percentage * 100) / 100,
            status:
              rawPercentage > 150
                ? 'high'
                : rawPercentage >= 100
                ? 'met'
                : rawPercentage >= 70
                ? 'near'
                : 'low',
            has_adjustment: hasAdjustment,
            adjustment_percent: adjustmentPercent
          };
        })
        .filter((n) => n.recommended > 0);

      const below100 = summary.filter((n) => Number.isFinite(n.percentage) && n.percentage < 100);
      const above150 = summary.filter((n) => Number.isFinite(n.percentage) && n.percentage > 150);

      // Sort by percentage (low first to highlight gaps)
      summary.sort((a, b) => a.percentage - b.percentage);

      return {
        totalSuggestions: allSuggestions.length,
        nutrients: summary,
        compliance: {
          below100Count: below100.length,
          above150Count: above150.length,
          below100,
          above150
        },
        overallCompletion: summary.length > 0 
          ? Math.round(summary.reduce((sum, n) => sum + Math.min(n.percentage, 100), 0) / summary.length)
          : 0
      };

    } finally {
      client.release();
    }
  }

  /**
   * Accept a suggestion
   */
  async acceptSuggestion(suggestionId) {
    const result = await pool.query(`
      UPDATE user_daily_meal_suggestions
      SET is_accepted = true, is_rejected = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = $1
      RETURNING *
    `, [suggestionId]);

    return result.rows[0];
  }

  /**
   * Reject a suggestion and generate a new one
   */
  async rejectSuggestion(suggestionId) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');

      // Mark as rejected
      const rejectResult = await client.query(`
        UPDATE user_daily_meal_suggestions
        SET is_rejected = true, is_accepted = false, updated_at = CURRENT_TIMESTAMP
        WHERE id = $1
        RETURNING user_id, date, meal_type, dish_id, drink_id
      `, [suggestionId]);

      if (rejectResult.rows.length === 0) {
        throw new Error('Suggestion not found');
      }

      const { user_id, date, meal_type, dish_id, drink_id } = rejectResult.rows[0];

      // Get user settings and gaps (simplified - reuse existing logic)
      const userSettings = await this._getUserSettings(client, user_id);
      const rdaTargets = await this._calculateSuggestionTargets(userSettings, client);
      const nutrientGaps = await this._calculateDailyNutrientGaps(client, user_id, new Date(date), rdaTargets);
      const mealGaps = this._distributeMealGaps(nutrientGaps, userSettings);
      const userConditions = await this._getUserHealthConditions(client, user_id);

      // Generate ONE new suggestion (exclude rejected item)
      const isDish = dish_id !== null;
      
      if (isDish) {
        const dishes = await this._getCandidateDishes(client, userConditions, meal_type);
        const filteredDishes = dishes.filter(d => d.dish_id !== dish_id);
        const scoredDishes = await this._scoreDishes(client, filteredDishes, mealGaps[meal_type]);
        
        if (scoredDishes.length > 0) {
          const newDish = scoredDishes[0];
          await client.query(`
            INSERT INTO user_daily_meal_suggestions 
              (user_id, date, meal_type, dish_id, suggestion_score)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT (user_id, date, meal_type, dish_id, drink_id) DO NOTHING
          `, [user_id, date, meal_type, newDish.dish_id, newDish.score]);
        }
      } else {
        const drinks = await this._getCandidateDrinks(client, userConditions);
        const filteredDrinks = drinks.filter(d => d.drink_id !== drink_id);
        const scoredDrinks = await this._scoreDrinks(client, filteredDrinks, mealGaps[meal_type]);
        
        if (scoredDrinks.length > 0) {
          const newDrink = scoredDrinks[0];
          await client.query(`
            INSERT INTO user_daily_meal_suggestions 
              (user_id, date, meal_type, drink_id, suggestion_score)
            VALUES ($1, $2, $3, $4, $5)
            ON CONFLICT (user_id, date, meal_type, dish_id, drink_id) DO NOTHING
          `, [user_id, date, meal_type, newDrink.drink_id, newDrink.score]);
        }
      }

      await client.query('COMMIT');
      
      return { success: true, message: 'Suggestion rejected and new one generated' };

    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  /**
   * Delete a suggestion
   */
  async deleteSuggestion(suggestionId) {
    const result = await pool.query(`
      DELETE FROM user_daily_meal_suggestions
      WHERE id = $1
      RETURNING *
    `, [suggestionId]);

    return result.rows[0];
  }

  async consumeAcceptedSuggestion({ userId, date, mealType, dishId = null, drinkId = null }) {
    if (!userId || !date) return null;

    if (dishId) {
      const result = await pool.query(
        `
        DELETE FROM user_daily_meal_suggestions
        WHERE user_id = $1
          AND date = $2
          AND ($3::text IS NULL OR meal_type = $3)
          AND dish_id = $4
          AND is_accepted = TRUE
        RETURNING *
      `,
        [userId, date, mealType || null, dishId]
      );
      return result.rows[0] || null;
    }

    if (drinkId) {
      const result = await pool.query(
        `
        DELETE FROM user_daily_meal_suggestions
        WHERE user_id = $1
          AND date = $2
          AND ($3::text IS NULL OR meal_type = $3)
          AND drink_id = $4
          AND is_accepted = TRUE
        RETURNING *
      `,
        [userId, date, mealType || null, drinkId]
      );
      return result.rows[0] || null;
    }

    return null;
  }

  /**
   * Cleanup old suggestions (called by cron job)
   */
  async cleanupOldSuggestions() {
    const result = await pool.query(`SELECT cleanup_old_daily_suggestions()`);
    return result.rows[0];
  }

  /**
   * Cleanup passed meal suggestions for a user
   */
  async cleanupPassedMeals(userId) {
    const result = await pool.query(`SELECT cleanup_passed_meal_suggestions($1)`, [userId]);
    return result.rows[0];
  }
}

module.exports = new DailyMealSuggestionService();
