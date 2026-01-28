const db = require('../db');

/**
 * Get portion size suggestions for a food
 */
const getPortionSuggestions = async (req, res) => {
    try {
        const { foodId } = req.params;
        
        // Get food-specific portions
        const foodPortionsQuery = `
            SELECT 
                portion_id,
                portion_name,
                portion_name_vi,
                weight_g,
                is_common
            FROM PortionSize
            WHERE food_id = $1
            ORDER BY is_common DESC, weight_g ASC
        `;
        
        const foodPortions = await db.query(foodPortionsQuery, [foodId]);
        
        // Get generic portions (food_id is NULL)
        const genericPortionsQuery = `
            SELECT 
                portion_id,
                portion_name,
                portion_name_vi,
                weight_g,
                is_common
            FROM PortionSize
            WHERE food_id IS NULL AND is_common = true
            ORDER BY weight_g ASC
        `;
        
        const genericPortions = await db.query(genericPortionsQuery);
        
        // Get user's average portion for this food (if they've eaten it before)
        const userId = req.user?.user_id;
        let userAverage = null;
        
        if (userId) {
            const avgQuery = `
                SELECT AVG(weight_g) as avg_portion
                FROM UserMeal
                WHERE user_id = $1 AND food_id = $2
                GROUP BY food_id
            `;
            const avgResult = await db.query(avgQuery, [userId, foodId]);
            
            if (avgResult.rows.length > 0) {
                userAverage = {
                    portion_name: 'Your usual portion',
                    portion_name_vi: 'Khẩu phần thường dùng',
                    weight_g: Math.round(avgResult.rows[0].avg_portion)
                };
            }
        }
        
        res.json({
            food_specific: foodPortions.rows,
            generic: genericPortions.rows,
            user_average: userAverage
        });
    } catch (error) {
        console.error('Get portion suggestions error:', error);
        res.status(500).json({ error: 'Failed to get portion suggestions' });
    }
};

/**
 * Add custom portion size
 */
const addCustomPortion = async (req, res) => {
    try {
        const { foodId, portionName, portionNameVi, weightG } = req.body;
        
        if (!foodId || !portionName || !weightG) {
            return res.status(400).json({ error: 'Food ID, portion name, and weight are required' });
        }
        
        const query = `
            INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common)
            VALUES ($1, $2, $3, $4, false)
            RETURNING *
        `;
        
        const result = await db.query(query, [foodId, portionName, portionNameVi, weightG]);
        
        res.json({
            success: true,
            portion: result.rows[0]
        });
    } catch (error) {
        console.error('Add custom portion error:', error);
        res.status(500).json({ error: 'Failed to add custom portion' });
    }
};

/**
 * Calculate nutrition for a given portion
 */
const calculatePortionNutrition = async (req, res) => {
    try {
        const { foodId, weightG } = req.query;
        
        if (!foodId || !weightG) {
            return res.status(400).json({ error: 'Food ID and weight are required' });
        }
        
        const query = `
            SELECT 
                f.food_id,
                f.name as food_name,
                n.name as nutrient_name,
                n.unit,
                (fn.amount_per_100g * $2 / 100) as amount
            FROM Food f
            JOIN FoodNutrient fn ON f.food_id = fn.food_id
            JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
            WHERE f.food_id = $1
        `;
        
        const result = await db.query(query, [foodId, weightG]);
        
        if (result.rows.length === 0) {
            return res.status(404).json({ error: 'Food not found' });
        }
        
        // Group nutrients by type
        const nutrition = {
            food_id: result.rows[0].food_id,
            food_name: result.rows[0].food_name,
            weight_g: parseFloat(weightG),
            macros: {},
            vitamins: {},
            minerals: {},
            other: {}
        };
        
        result.rows.forEach(row => {
            const rawAmount = typeof row.amount === 'string' ? parseFloat(row.amount) : row.amount;
            const nutrientData = {
                amount: parseFloat(rawAmount.toFixed(2)),
                unit: row.unit
            };
            
            // Categorize nutrients - handle multiple naming conventions
            const name = row.nutrient_name;
            
            // Macronutrients - check for various naming patterns
            if (name.includes('Energy') || name.includes('Calories') || 
                name === 'Protein' ||
                name.includes('Carbohydrate') ||
                name.includes('Total Fat') || name.includes('Total lipid') ||
                name.includes('Fiber')) {
                nutrition.macros[name] = nutrientData;
            } else if (name.includes('Vitamin')) {
                nutrition.vitamins[name] = nutrientData;
            } else if (['Calcium', 'Iron', 'Magnesium', 'Phosphorus', 'Potassium', 'Sodium', 'Zinc', 'Copper', 'Manganese', 'Iodine', 'Selenium', 'Chromium', 'Molybdenum', 'Fluoride'].some(m => name.includes(m))) {
                nutrition.minerals[name] = nutrientData;
            } else {
                nutrition.other[name] = nutrientData;
            }
        });
        
        res.json(nutrition);
    } catch (error) {
        console.error('Calculate portion nutrition error:', error);
        res.status(500).json({ error: 'Failed to calculate nutrition' });
    }
};

module.exports = {
    getPortionSuggestions,
    addCustomPortion,
    calculatePortionNutrition
};
