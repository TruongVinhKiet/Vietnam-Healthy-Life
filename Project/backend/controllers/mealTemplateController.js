const db = require('../db');
const { getVietnamDate } = require('../utils/dateHelper');

/**
 * Get all meal templates for a user
 */
const getTemplates = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { mealType, favoritesOnly } = req.query;
        
        let query = `
            SELECT 
                mt.*,
                COUNT(mti.template_item_id) as item_count,
                -- Calculate total nutrition
                COALESCE(SUM(
                    CASE WHEN n.nutrient_code = 'ENERC_KCAL' 
                    THEN fn.amount_per_100g * mti.weight_g / 100 ELSE 0 END
                ), 0) as total_calories,
                COALESCE(SUM(
                    CASE WHEN n.nutrient_code = 'PROCNT' 
                    THEN fn.amount_per_100g * mti.weight_g / 100 ELSE 0 END
                ), 0) as total_protein,
                COALESCE(SUM(
                    CASE WHEN n.nutrient_code = 'CHOCDF' 
                    THEN fn.amount_per_100g * mti.weight_g / 100 ELSE 0 END
                ), 0) as total_carbs,
                COALESCE(SUM(
                    CASE WHEN n.nutrient_code = 'FAT' 
                    THEN fn.amount_per_100g * mti.weight_g / 100 ELSE 0 END
                ), 0) as total_fat
            FROM MealTemplate mt
            LEFT JOIN MealTemplateItem mti ON mt.template_id = mti.template_id
            LEFT JOIN FoodNutrient fn ON mti.food_id = fn.food_id
            LEFT JOIN Nutrient n ON fn.nutrient_id = n.nutrient_id
            WHERE mt.user_id = $1
        `;
        
        const params = [userId];
        
        if (mealType) {
            query += ` AND mt.meal_type = $${params.length + 1}`;
            params.push(mealType);
        }
        
        if (favoritesOnly === 'true') {
            query += ` AND mt.is_favorite = true`;
        }
        
        query += `
            GROUP BY mt.template_id
            ORDER BY mt.is_favorite DESC, mt.usage_count DESC, mt.created_at DESC
        `;
        
        const result = await db.query(query, params);
        
        res.json({
            templates: result.rows
        });
    } catch (error) {
        console.error('Get templates error:', error);
        res.status(500).json({ error: 'Failed to get meal templates' });
    }
};

/**
 * Get template by ID with all items
 */
const getTemplateById = async (req, res) => {
    try {
        const { templateId } = req.params;
        const userId = req.user.user_id;
        
        // Get template details
        const templateQuery = `
            SELECT * FROM MealTemplate
            WHERE template_id = $1 AND user_id = $2
        `;
        
        const templateResult = await db.query(templateQuery, [templateId, userId]);
        
        if (templateResult.rows.length === 0) {
            return res.status(404).json({ error: 'Template not found' });
        }
        
        // Get items
        const itemsQuery = `
            SELECT 
                mti.template_item_id,
                mti.food_id,
                f.name AS food_name,
                NULL::TEXT AS food_name_vi,
                mti.weight_g,
                mti.item_order
            FROM MealTemplateItem mti
            JOIN Food f ON mti.food_id = f.food_id
            WHERE mti.template_id = $1
            ORDER BY mti.item_order, mti.template_item_id
        `;
        
        const itemsResult = await db.query(itemsQuery, [templateId]);
        
        res.json({
            ...templateResult.rows[0],
            items: itemsResult.rows
        });
    } catch (error) {
        console.error('Get template error:', error);
        res.status(500).json({ error: 'Failed to get template' });
    }
};

/**
 * Create a new meal template
 */
const createTemplate = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const userId = req.user.user_id;
        const { 
            templateName, 
            description, 
            mealType,
            isFavorite = false,
            items // Array of { food_id, weight_g, order }
        } = req.body;
        
        if (!templateName || !mealType || !items || items.length === 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({ error: 'Template name, meal type, and items are required' });
        }
        
        // Insert template
        const templateQuery = `
            INSERT INTO MealTemplate 
            (user_id, template_name, description, meal_type, is_favorite)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *
        `;
        
        const templateResult = await client.query(templateQuery, [
            userId, templateName, description, mealType, isFavorite
        ]);
        
        const templateId = templateResult.rows[0].template_id;
        
        // Insert items
        for (let i = 0; i < items.length; i++) {
            const { food_id, weight_g } = items[i];
            const order = items[i].order || i;
            
            await client.query(
                `INSERT INTO MealTemplateItem 
                 (template_id, food_id, weight_g, item_order)
                 VALUES ($1, $2, $3, $4)`,
                [templateId, food_id, weight_g, order]
            );
        }
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            template: templateResult.rows[0]
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Create template error:', error);
        res.status(500).json({ error: 'Failed to create template' });
    } finally {
        client.release();
    }
};

/**
 * Update a meal template
 */
const updateTemplate = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const { templateId } = req.params;
        const userId = req.user.user_id;
        const { 
            templateName, 
            description, 
            mealType,
            isFavorite,
            items
        } = req.body;
        
        // Check ownership
        const checkQuery = 'SELECT user_id FROM MealTemplate WHERE template_id = $1';
        const checkResult = await client.query(checkQuery, [templateId]);
        
        if (checkResult.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'Template not found' });
        }
        
        if (checkResult.rows[0].user_id !== userId) {
            await client.query('ROLLBACK');
            return res.status(403).json({ error: 'Not authorized to update this template' });
        }
        
        // Update template
        const updateQuery = `
            UPDATE MealTemplate SET
                template_name = COALESCE($1, template_name),
                description = COALESCE($2, description),
                meal_type = COALESCE($3, meal_type),
                is_favorite = COALESCE($4, is_favorite)
            WHERE template_id = $5
            RETURNING *
        `;
        
        const updateResult = await client.query(updateQuery, [
            templateName, description, mealType, isFavorite, templateId
        ]);
        
        // Update items if provided
        if (items && items.length > 0) {
            // Delete existing items
            await client.query('DELETE FROM MealTemplateItem WHERE template_id = $1', [templateId]);
            
            // Insert new items
            for (let i = 0; i < items.length; i++) {
                const { food_id, weight_g } = items[i];
                const order = items[i].order || i;
                
                await client.query(
                    `INSERT INTO MealTemplateItem 
                     (template_id, food_id, weight_g, item_order)
                     VALUES ($1, $2, $3, $4)`,
                    [templateId, food_id, weight_g, order]
                );
            }
        }
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            template: updateResult.rows[0]
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Update template error:', error);
        res.status(500).json({ error: 'Failed to update template' });
    } finally {
        client.release();
    }
};

/**
 * Delete a meal template
 */
const deleteTemplate = async (req, res) => {
    try {
        const { templateId } = req.params;
        const userId = req.user.user_id;
        
        // Check ownership
        const checkQuery = 'SELECT user_id FROM MealTemplate WHERE template_id = $1';
        const checkResult = await db.query(checkQuery, [templateId]);
        
        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Template not found' });
        }
        
        if (checkResult.rows[0].user_id !== userId) {
            return res.status(403).json({ error: 'Not authorized to delete this template' });
        }
        
        // Delete template (cascade will delete items)
        await db.query('DELETE FROM MealTemplate WHERE template_id = $1', [templateId]);
        
        res.json({
            success: true,
            message: 'Template deleted successfully'
        });
    } catch (error) {
        console.error('Delete template error:', error);
        res.status(500).json({ error: 'Failed to delete template' });
    }
};

/**
 * Apply template to add all items as meals
 */
const applyTemplate = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const userId = req.user.user_id;
        const { templateId } = req.body;
        
        if (!templateId) {
            await client.query('ROLLBACK');
            return res.status(400).json({ error: 'Template ID is required' });
        }
        
        // Get template with items
        const templateQuery = `
            SELECT mt.meal_type, mti.food_id, mti.weight_g
            FROM MealTemplate mt
            JOIN MealTemplateItem mti ON mt.template_id = mti.template_id
            WHERE mt.template_id = $1 AND mt.user_id = $2
        `;
        
        const templateResult = await client.query(templateQuery, [templateId, userId]);
        
        if (templateResult.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'Template not found' });
        }
        
        const mealType = templateResult.rows[0].meal_type;
        
        // Add each item as a meal
        for (const item of templateResult.rows) {
            await client.query(
                `INSERT INTO UserMeal (user_id, food_id, weight_g, meal_type)
                 VALUES ($1, $2, $3, $4)`,
                [userId, item.food_id, item.weight_g, mealType]
            );
        }
        
        // Increment usage count
        await client.query(
            'UPDATE MealTemplate SET usage_count = usage_count + 1 WHERE template_id = $1',
            [templateId]
        );
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            message: `Template applied to ${mealType}`,
            items_added: templateResult.rows.length
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Apply template error:', error);
        res.status(500).json({ error: 'Failed to apply template' });
    } finally {
        client.release();
    }
};

/**
 * Save current meal as template
 */
const saveCurrentMealAsTemplate = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const userId = req.user.user_id;
        const { templateName, description, mealType, date } = req.body;
        
        if (!templateName || !mealType) {
            await client.query('ROLLBACK');
            return res.status(400).json({ error: 'Template name and meal type are required' });
        }
        
        // Get today's meals for this meal type (or specific date if provided)
        const targetDate = date || getVietnamDate();
        
        const mealsQuery = `
            SELECT DISTINCT food_id, weight_g
            FROM UserMeal
            WHERE user_id = $1 
            AND meal_type = $2
            AND DATE(created_at) = $3
            ORDER BY created_at DESC
        `;
        
        const mealsResult = await client.query(mealsQuery, [userId, mealType, targetDate]);
        
        if (mealsResult.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({ error: 'No meals found for this meal type today' });
        }
        
        // Create template
        const templateQuery = `
            INSERT INTO MealTemplate 
            (user_id, template_name, description, meal_type)
            VALUES ($1, $2, $3, $4)
            RETURNING *
        `;
        
        const templateResult = await client.query(templateQuery, [
            userId, templateName, description, mealType
        ]);
        
        const templateId = templateResult.rows[0].template_id;
        
        // Add items
        for (let i = 0; i < mealsResult.rows.length; i++) {
            const { food_id, weight_g } = mealsResult.rows[i];
            
            await client.query(
                `INSERT INTO MealTemplateItem 
                 (template_id, food_id, weight_g, item_order)
                 VALUES ($1, $2, $3, $4)`,
                [templateId, food_id, weight_g, i]
            );
        }
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            template: templateResult.rows[0],
            items_count: mealsResult.rows.length
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Save current meal as template error:', error);
        res.status(500).json({ error: 'Failed to save meal as template' });
    } finally {
        client.release();
    }
};

module.exports = {
    getTemplates,
    getTemplateById,
    createTemplate,
    updateTemplate,
    deleteTemplate,
    applyTemplate,
    saveCurrentMealAsTemplate
};
