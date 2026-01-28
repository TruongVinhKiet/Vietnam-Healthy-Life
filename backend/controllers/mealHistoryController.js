const db = require('../db');
const { getVietnamDate } = require('../utils/dateHelper');

const MEAL_PERIODS = [
    { key: 'morning', label: 'Buổi sáng', mealTypes: ['breakfast'] },
    { key: 'afternoon', label: 'Buổi trưa', mealTypes: ['lunch'] },
    { key: 'snack', label: 'Bữa phụ', mealTypes: ['snack'] },
    { key: 'evening', label: 'Buổi tối', mealTypes: ['dinner'] },
];

const MEAL_TYPE_TO_PERIOD = MEAL_PERIODS.reduce((acc, period) => {
    period.mealTypes.forEach(type => {
        acc[type] = period.key;
    });
    return acc;
}, {});

const MACRO_CODES = ['ENERC_KCAL', 'PROCNT', 'CHOCDF', 'FAT', 'FIBTG'];

/**
 * Get user's meal history with pagination and filters
 */
const getMealHistory = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { 
            page = 1, 
            limit = 20, 
            mealType, 
            startDate, 
            endDate,
            date, // Single date filter (YYYY-MM-DD)
            favoritesOnly = false 
        } = req.query;
        
        const offset = (page - 1) * limit;
        
        let query = `
            SELECT 
                um.id AS meal_entry_id,
                um.food_id,
                f.name AS food_name,
                NULL::TEXT AS food_name_vi,
                um.weight_g,
                um.meal_type,
                um.created_at,
                -- Use stored macros from meal_entries (already computed)
                COALESCE(um.kcal, 0) as calories,
                COALESCE(um.protein, 0) as protein,
                COALESCE(um.carbs, 0) as carbs,
                COALESCE(um.fat, 0) as fat
            FROM meal_entries um
            LEFT JOIN Food f ON um.food_id = f.food_id
            WHERE um.user_id = $1
        `;
        
        const params = [userId];
        let paramCount = 1;
        
        if (date) {
            // Filter by specific date (UTC+7)
            paramCount++;
            query += ` AND DATE(um.created_at AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh') = $${paramCount}`;
            params.push(date);
        }
        
        if (mealType) {
            paramCount++;
            query += ` AND um.meal_type = $${paramCount}`;
            params.push(mealType);
        }
        
        if (startDate) {
            paramCount++;
            query += ` AND um.created_at >= $${paramCount}`;
            params.push(startDate);
        }
        
        if (endDate) {
            paramCount++;
            query += ` AND um.created_at <= $${paramCount}`;
            params.push(endDate);
        }
        
        // Note: favoritesOnly feature not available in current schema
        
        query += `
            ORDER BY um.created_at DESC
            LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}
        `;
        
        params.push(limit, offset);
        
        const result = await db.query(query, params);
        
        // Get total count
        let countQuery = 'SELECT COUNT(*) FROM meal_entries WHERE user_id = $1';
        const countParams = [userId];
        
        if (mealType) {
            countQuery += ' AND meal_type = $2';
            countParams.push(mealType);
        }
        // Note: favoritesOnly feature not available in current schema
        
        const countResult = await db.query(countQuery, countParams);
        const total = parseInt(countResult.rows[0].count);
        
        // Convert numeric fields to ensure they are numbers, not strings
        const meals = result.rows.map(row => ({
            ...row,
            weight_g: parseFloat(row.weight_g) || 0,
            calories: parseFloat(row.calories) || 0,
            protein: parseFloat(row.protein) || 0,
            carbs: parseFloat(row.carbs) || 0,
            fat: parseFloat(row.fat) || 0,
        }));
        
        res.json({
            meals: meals,
            pagination: {
                page: parseInt(page),
                limit: parseInt(limit),
                total,
                totalPages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        console.error('Get meal history error:', error);
        res.status(500).json({ error: 'Failed to get meal history' });
    }
};

/**
 * Get quick add suggestions (frequently eaten foods)
 */
const getQuickAddSuggestions = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { limit = 10, mealType } = req.query;
        
        let query = `
            SELECT 
                food_id,
                name AS food_name,
                NULL::TEXT AS food_name_vi,
                times_eaten,
                avg_portion_g,
                last_eaten,
                is_favorite
            FROM UserQuickAddFoods
            WHERE user_id = $1
        `;
        
        const params = [userId];
        
        if (mealType) {
            // Filter by meal type if needed (requires additional join)
            query = `
                SELECT 
                    me.food_id,
                    f.name as food_name,
                    COUNT(*) as times_eaten,
                    AVG(me.weight_g) as avg_portion_g,
                    MAX(me.created_at) as last_eaten,
                    false as is_favorite
                FROM meal_entries me
                JOIN Food f ON me.food_id = f.food_id
                WHERE me.user_id = $1 AND me.meal_type = $2
                GROUP BY me.food_id, f.name
                HAVING COUNT(*) >= 2
                ORDER BY times_eaten DESC, last_eaten DESC
                LIMIT $3
            `;
            params.push(mealType, limit);
        } else {
            query += ` ORDER BY times_eaten DESC, last_eaten DESC LIMIT $2`;
            params.push(limit);
        }
        
        const result = await db.query(query, params);
        
        res.json({
            suggestions: result.rows
        });
    } catch (error) {
        console.error('Get quick add suggestions error:', error);
        res.status(500).json({ error: 'Failed to get quick add suggestions' });
    }
};

/**
 * Toggle favorite status for a meal
 */
const toggleFavorite = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { foodId } = req.body;
        
        if (!foodId) {
            return res.status(400).json({ error: 'Food ID is required' });
        }
        
        // Note: meal_entries doesn't have is_favorite column
        // This feature may need to be implemented differently
        return res.status(501).json({ 
            error: 'Favorite feature not yet implemented for new schema',
            message: 'This feature requires database schema updates'
        });
    } catch (error) {
        console.error('Toggle favorite error:', error);
        res.status(500).json({ error: 'Failed to toggle favorite' });
    }
};

/**
 * Quick add a meal from history
 */
const quickAddMeal = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { foodId, weightG, mealType, notes } = req.body;
        
        if (!foodId || !weightG || !mealType) {
            return res.status(400).json({ error: 'Food ID, weight, and meal type are required' });
        }
        
        // Insert new meal entry
        const insertQuery = `
            INSERT INTO meal_entries (user_id, food_id, weight_g, meal_type, entry_date)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING id, created_at
        `;
        
        const insertResult = await db.query(insertQuery, [userId, foodId, weightG, mealType, getVietnamDate()]);
        
        res.json({
            success: true,
            meal_entry_id: insertResult.rows[0].id,
            created_at: insertResult.rows[0].created_at,
            message: 'Meal added successfully'
        });
    } catch (error) {
        console.error('Quick add meal error:', error);
        res.status(500).json({ error: 'Failed to quick add meal' });
    }
};

/**
 * Get meal statistics
 */
const getMealStats = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { days = 7 } = req.query;
        
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);
        
        const query = `
            SELECT 
                COUNT(DISTINCT id) as total_meals,
                COUNT(DISTINCT food_id) as unique_foods,
                COUNT(DISTINCT DATE(created_at)) as days_tracked,
                0 as favorite_meals,
                0 as meals_with_photos,
                AVG(weight_g) as avg_portion_size,
                meal_type,
                COUNT(*) as meals_by_type
            FROM meal_entries
            WHERE user_id = $1 AND created_at >= $2
            GROUP BY meal_type
        `;
        
        const result = await db.query(query, [userId, startDate]);
        
        // Get overall stats
        const overallQuery = `
            SELECT 
                COUNT(DISTINCT id) as total_meals,
                COUNT(DISTINCT food_id) as unique_foods
            FROM meal_entries
            WHERE user_id = $1 AND created_at >= $2
        `;
        
        const overallResult = await db.query(overallQuery, [userId, startDate]);
        
        res.json({
            period_days: parseInt(days),
            overall: overallResult.rows[0],
            by_meal_type: result.rows
        });
    } catch (error) {
        console.error('Get meal stats error:', error);
        res.status(500).json({ error: 'Failed to get meal statistics' });
    }
};

const getMealPeriodSummary = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { date } = req.query;
        const targetDate = date || getVietnamDate();

        const entriesResult = await db.query(
            `
            SELECT 
                me.id AS meal_entry_id,
                me.meal_type,
                me.food_id,
                COALESCE(me.weight_g, 0) AS weight_g,
                COALESCE(me.kcal, 0) AS kcal,
                COALESCE(me.carbs, 0) AS carbs,
                COALESCE(me.protein, 0) AS protein,
                COALESCE(me.fat, 0) AS fat,
                me.created_at,
                f.name AS food_name,
                NULL::TEXT AS food_name_vi,
                f.image_url
            FROM meal_entries me
            LEFT JOIN Food f ON me.food_id = f.food_id
            WHERE me.user_id = $1
              AND me.entry_date = $2
            ORDER BY me.created_at ASC
            `,
            [userId, targetDate]
        );

        const nutrientResult = await db.query(
            `
            SELECT 
                me.id AS meal_entry_id,
                n.nutrient_code,
                n.name AS nutrient_name,
                n.unit,
                COALESCE(fn.amount_per_100g, 0) * COALESCE(me.weight_g, 0) / 100.0 AS amount
            FROM meal_entries me
            JOIN FoodNutrient fn ON me.food_id = fn.food_id
            JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
            WHERE me.user_id = $1
              AND me.entry_date = $2
              AND n.nutrient_code IS NOT NULL
            `,
            [userId, targetDate]
        );

        const nutrientByEntry = new Map();
        nutrientResult.rows.forEach(row => {
            const entryId = row.meal_entry_id;
            if (!nutrientByEntry.has(entryId)) nutrientByEntry.set(entryId, []);
            nutrientByEntry.get(entryId).push({
                nutrient_code: row.nutrient_code,
                nutrient_name: row.nutrient_name,
                unit: row.unit,
                amount: parseFloat(row.amount) || 0,
            });
        });

        nutrientByEntry.forEach(list => {
            list.sort((a, b) => b.amount - a.amount);
        });

        const summaryMap = {};
        const nutrientAggregates = {};
        MEAL_PERIODS.forEach(period => {
            summaryMap[period.key] = {
                key: period.key,
                label: period.label,
                meal_types: period.mealTypes,
                total_kcal: 0,
                total_macros: {
                    calories: 0,
                    protein: 0,
                    carbs: 0,
                    fat: 0,
                },
                entries: [],
                top_nutrients: [],
            };
            nutrientAggregates[period.key] = {};
        });

        console.log(`[getMealPeriodSummary] Found ${entriesResult.rows.length} meal entries`);
        console.log(`[getMealPeriodSummary] MEAL_TYPE_TO_PERIOD:`, MEAL_TYPE_TO_PERIOD);
        
        entriesResult.rows.forEach(entry => {
            console.log(`[getMealPeriodSummary] Processing entry: meal_type=${entry.meal_type}, meal_entry_id=${entry.meal_entry_id}`);
            const periodKey = MEAL_TYPE_TO_PERIOD[entry.meal_type];
            console.log(`[getMealPeriodSummary] Mapped ${entry.meal_type} -> ${periodKey}`);
            if (!periodKey || !summaryMap[periodKey]) {
                console.warn(`[getMealPeriodSummary] Skipping entry: periodKey=${periodKey}, exists=${!!summaryMap[periodKey]}`);
                return;
            }

            const summary = summaryMap[periodKey];
            summary.total_kcal += parseFloat(entry.kcal) || 0;
            summary.total_macros.calories += parseFloat(entry.kcal) || 0;
            summary.total_macros.protein += parseFloat(entry.protein) || 0;
            summary.total_macros.carbs += parseFloat(entry.carbs) || 0;
            summary.total_macros.fat += parseFloat(entry.fat) || 0;

            const nutrientList = nutrientByEntry.get(entry.meal_entry_id) || [];
            const nutrientHighlights = nutrientList
                .filter(n => !MACRO_CODES.includes(n.nutrient_code))
                .slice(0, 3);

            nutrientHighlights.forEach(n => {
                if (!nutrientAggregates[periodKey][n.nutrient_code]) {
                    nutrientAggregates[periodKey][n.nutrient_code] = {
                        nutrient_code: n.nutrient_code,
                        nutrient_name: n.nutrient_name,
                        unit: n.unit,
                        amount: 0,
                    };
                }
                nutrientAggregates[periodKey][n.nutrient_code].amount += n.amount;
            });

            summary.entries.push({
                meal_entry_id: entry.meal_entry_id,
                meal_type: entry.meal_type,
                food_name: entry.food_name,
                food_name_vi: entry.food_name_vi,
                weight_g: parseFloat(entry.weight_g) || 0,
                image_url: entry.image_url || null,
                eaten_at: entry.created_at,
                macros: {
                    calories: parseFloat(entry.kcal) || 0,
                    protein: parseFloat(entry.protein) || 0,
                    carbs: parseFloat(entry.carbs) || 0,
                    fat: parseFloat(entry.fat) || 0,
                },
                nutrients: nutrientHighlights,
            });
        });

        Object.keys(summaryMap).forEach(key => {
            const aggregateList = Object.values(nutrientAggregates[key]);
            aggregateList.sort((a, b) => b.amount - a.amount);
            summaryMap[key].top_nutrients = aggregateList.slice(0, 4);
        });

        const responseData = {
            date: targetDate,
            periods: MEAL_PERIODS.map(period => summaryMap[period.key]),
        };
        
        console.log(`[getMealPeriodSummary] Response summary:`, JSON.stringify({
            date: responseData.date,
            periods_count: responseData.periods.length,
            periods_with_entries: responseData.periods.filter(p => p.entries.length > 0).length,
            period_details: responseData.periods.map(p => ({
                key: p.key,
                label: p.label,
                entries_count: p.entries.length,
                total_calories: p.total_macros.calories
            }))
        }, null, 2));

        res.json(responseData);
    } catch (error) {
        console.error('Get meal period summary error:', error);
        res.status(500).json({ error: 'Failed to build meal period summary' });
    }
};

module.exports = {
    getMealHistory,
    getQuickAddSuggestions,
    toggleFavorite,
    quickAddMeal,
    getMealStats,
    getMealPeriodSummary
};
