const db = require('../db');

/**
 * Get all recipes for a user
 */
const getRecipes = async (req, res) => {
    try {
        const userId = req.user.user_id;
        const { page = 1, limit = 20, isPublic } = req.query;
        const offset = (page - 1) * limit;
        
        let query = `
            SELECT 
                r.*,
                COUNT(ri.recipe_ingredient_id) as ingredient_count,
                rns.total_calories_kcal,
                rns.total_protein_g,
                rns.total_carbs_g,
                rns.total_fat_g
            FROM Recipe r
            LEFT JOIN RecipeIngredient ri ON r.recipe_id = ri.recipe_id
            LEFT JOIN RecipeNutritionSummary rns ON r.recipe_id = rns.recipe_id
            WHERE r.user_id = $1
        `;
        
        const params = [userId];
        
        if (isPublic !== undefined) {
            query += ` AND r.is_public = $${params.length + 1}`;
            params.push(isPublic === 'true');
        }
        
        query += `
            GROUP BY r.recipe_id, rns.total_calories_kcal, rns.total_protein_g, 
                     rns.total_carbs_g, rns.total_fat_g
            ORDER BY r.created_at DESC
            LIMIT $${params.length + 1} OFFSET $${params.length + 2}
        `;
        
        params.push(limit, offset);
        
        const result = await db.query(query, params);
        
        res.json({
            recipes: result.rows
        });
    } catch (error) {
        console.error('Get recipes error:', error);
        res.status(500).json({ error: 'Failed to get recipes' });
    }
};

/**
 * Get recipe by ID with all ingredients
 */
const getRecipeById = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const userId = req.user.user_id;
        
        // Get recipe details
        const recipeQuery = `
            SELECT r.*, 
                   rns.total_calories_kcal,
                   rns.total_protein_g,
                   rns.total_carbs_g,
                   rns.total_fat_g
            FROM Recipe r
            LEFT JOIN RecipeNutritionSummary rns ON r.recipe_id = rns.recipe_id
            WHERE r.recipe_id = $1 AND (r.user_id = $2 OR r.is_public = true)
        `;
        
        const recipeResult = await db.query(recipeQuery, [recipeId, userId]);
        
        if (recipeResult.rows.length === 0) {
            return res.status(404).json({ error: 'Recipe not found' });
        }
        
        // Get ingredients
        const ingredientsQuery = `
            SELECT 
                ri.recipe_ingredient_id,
                ri.food_id,
                f.name AS food_name,
                NULL::TEXT AS food_name_vi,
                ri.weight_g,
                ri.ingredient_order,
                ri.notes
            FROM RecipeIngredient ri
            JOIN Food f ON ri.food_id = f.food_id
            WHERE ri.recipe_id = $1
            ORDER BY ri.ingredient_order, ri.recipe_ingredient_id
        `;
        
        const ingredientsResult = await db.query(ingredientsQuery, [recipeId]);
        
        res.json({
            ...recipeResult.rows[0],
            ingredients: ingredientsResult.rows
        });
    } catch (error) {
        console.error('Get recipe error:', error);
        res.status(500).json({ error: 'Failed to get recipe' });
    }
};

/**
 * Create a new recipe
 */
const createRecipe = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const userId = req.user.user_id;
        const { 
            recipeName, 
            description, 
            servings = 1, 
            prepTimeMinutes, 
            cookTimeMinutes, 
            instructions, 
            imageUrl,
            isPublic = false,
            ingredients // Array of { food_id, weight_g, notes, order }
        } = req.body;
        
        if (!recipeName || !ingredients || ingredients.length === 0) {
            await client.query('ROLLBACK');
            return res.status(400).json({ error: 'Recipe name and ingredients are required' });
        }
        
        // Insert recipe
        const recipeQuery = `
            INSERT INTO Recipe 
            (user_id, recipe_name, description, servings, prep_time_minutes, 
             cook_time_minutes, instructions, image_url, is_public)
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
            RETURNING *
        `;
        
        const recipeResult = await client.query(recipeQuery, [
            userId, recipeName, description, servings, prepTimeMinutes,
            cookTimeMinutes, instructions, imageUrl, isPublic
        ]);
        
        const recipeId = recipeResult.rows[0].recipe_id;
        
        // Insert ingredients
        for (let i = 0; i < ingredients.length; i++) {
            const { food_id, weight_g, notes } = ingredients[i];
            const order = ingredients[i].order || i;
            
            await client.query(
                `INSERT INTO RecipeIngredient 
                 (recipe_id, food_id, weight_g, ingredient_order, notes)
                 VALUES ($1, $2, $3, $4, $5)`,
                [recipeId, food_id, weight_g, order, notes]
            );
        }
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            recipe: recipeResult.rows[0]
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Create recipe error:', error);
        res.status(500).json({ error: 'Failed to create recipe' });
    } finally {
        client.release();
    }
};

/**
 * Update a recipe
 */
const updateRecipe = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const { recipeId } = req.params;
        const userId = req.user.user_id;
        const { 
            recipeName, 
            description, 
            servings, 
            prepTimeMinutes, 
            cookTimeMinutes, 
            instructions, 
            imageUrl,
            isPublic,
            ingredients
        } = req.body;
        
        // Check ownership
        const checkQuery = 'SELECT user_id FROM Recipe WHERE recipe_id = $1';
        const checkResult = await client.query(checkQuery, [recipeId]);
        
        if (checkResult.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'Recipe not found' });
        }
        
        if (checkResult.rows[0].user_id !== userId) {
            await client.query('ROLLBACK');
            return res.status(403).json({ error: 'Not authorized to update this recipe' });
        }
        
        // Update recipe
        const updateQuery = `
            UPDATE Recipe SET
                recipe_name = COALESCE($1, recipe_name),
                description = COALESCE($2, description),
                servings = COALESCE($3, servings),
                prep_time_minutes = COALESCE($4, prep_time_minutes),
                cook_time_minutes = COALESCE($5, cook_time_minutes),
                instructions = COALESCE($6, instructions),
                image_url = COALESCE($7, image_url),
                is_public = COALESCE($8, is_public)
            WHERE recipe_id = $9
            RETURNING *
        `;
        
        const updateResult = await client.query(updateQuery, [
            recipeName, description, servings, prepTimeMinutes,
            cookTimeMinutes, instructions, imageUrl, isPublic, recipeId
        ]);
        
        // Update ingredients if provided
        if (ingredients && ingredients.length > 0) {
            // Delete existing ingredients
            await client.query('DELETE FROM RecipeIngredient WHERE recipe_id = $1', [recipeId]);
            
            // Insert new ingredients
            for (let i = 0; i < ingredients.length; i++) {
                const { food_id, weight_g, notes } = ingredients[i];
                const order = ingredients[i].order || i;
                
                await client.query(
                    `INSERT INTO RecipeIngredient 
                     (recipe_id, food_id, weight_g, ingredient_order, notes)
                     VALUES ($1, $2, $3, $4, $5)`,
                    [recipeId, food_id, weight_g, order, notes]
                );
            }
        }
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            recipe: updateResult.rows[0]
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Update recipe error:', error);
        res.status(500).json({ error: 'Failed to update recipe' });
    } finally {
        client.release();
    }
};

/**
 * Delete a recipe
 */
const deleteRecipe = async (req, res) => {
    try {
        const { recipeId } = req.params;
        const userId = req.user.user_id;
        
        // Check ownership
        const checkQuery = 'SELECT user_id FROM Recipe WHERE recipe_id = $1';
        const checkResult = await db.query(checkQuery, [recipeId]);
        
        if (checkResult.rows.length === 0) {
            return res.status(404).json({ error: 'Recipe not found' });
        }
        
        if (checkResult.rows[0].user_id !== userId) {
            return res.status(403).json({ error: 'Not authorized to delete this recipe' });
        }
        
        // Delete recipe (cascade will delete ingredients)
        await db.query('DELETE FROM Recipe WHERE recipe_id = $1', [recipeId]);
        
        res.json({
            success: true,
            message: 'Recipe deleted successfully'
        });
    } catch (error) {
        console.error('Delete recipe error:', error);
        res.status(500).json({ error: 'Failed to delete recipe' });
    }
};

/**
 * Add recipe as meal (all servings or partial)
 */
const addRecipeAsMeal = async (req, res) => {
    const client = await db.pool.connect();
    
    try {
        await client.query('BEGIN');
        
        const userId = req.user.user_id;
        const { recipeId, servings = 1, mealType } = req.body;
        
        if (!recipeId || !mealType) {
            await client.query('ROLLBACK');
            return res.status(400).json({ error: 'Recipe ID and meal type are required' });
        }
        
        // Get recipe with ingredients
        const recipeQuery = `
            SELECT r.servings, ri.food_id, ri.weight_g
            FROM Recipe r
            JOIN RecipeIngredient ri ON r.recipe_id = ri.recipe_id
            WHERE r.recipe_id = $1 AND (r.user_id = $2 OR r.is_public = true)
        `;
        
        const recipeResult = await client.query(recipeQuery, [recipeId, userId]);
        
        if (recipeResult.rows.length === 0) {
            await client.query('ROLLBACK');
            return res.status(404).json({ error: 'Recipe not found' });
        }
        
        const recipeServings = recipeResult.rows[0].servings;
        const servingMultiplier = servings / recipeServings;
        
        // Add each ingredient as a meal
        for (const ingredient of recipeResult.rows) {
            const adjustedWeight = ingredient.weight_g * servingMultiplier;
            
            await client.query(
                `INSERT INTO UserMeal (user_id, food_id, weight_g, meal_type)
                 VALUES ($1, $2, $3, $4)`,
                [userId, ingredient.food_id, adjustedWeight, mealType]
            );
        }
        
        await client.query('COMMIT');
        
        res.json({
            success: true,
            message: `Recipe added to ${mealType} (${servings} serving${servings > 1 ? 's' : ''})`
        });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Add recipe as meal error:', error);
        res.status(500).json({ error: 'Failed to add recipe as meal' });
    } finally {
        client.release();
    }
};

module.exports = {
    getRecipes,
    getRecipeById,
    createRecipe,
    updateRecipe,
    deleteRecipe,
    addRecipeAsMeal
};
