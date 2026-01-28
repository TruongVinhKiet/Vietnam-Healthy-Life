/**
 * dishService.js
 * 
 * Service layer for Dish Management System
 * Handles database operations for dishes, ingredients, and nutrient calculations
 */

const db = require('../db');

// noop placeholder to ensure file loaded


const dishService = {
  /**
   * Get all dishes with optional filtering
   * @param {Object} filters - Filtering options
   * @param {string} filters.category - Filter by dish category
   * @param {boolean} filters.isTemplate - Filter template dishes only
   * @param {boolean} filters.isPublic - Filter public dishes only
   * @param {number} filters.userId - Filter user's custom dishes
   * @param {string} filters.search - Search by name (Vietnamese or English)
   * @param {number} filters.limit - Limit results
   * @param {number} filters.offset - Offset for pagination
   * @returns {Promise<Array>} Array of dishes with statistics
   */
  async getAllDishes(filters = {}) {
    try {
      let query = `
        SELECT 
          d.dish_id,
          d.name,
          d.vietnamese_name,
          d.description,
          d.category,
          d.serving_size_g,
          d.image_url,
          d.is_template,
          d.is_public,
          d.created_by_user,
          d.created_by_admin,
          d.created_at,
          d.updated_at,
          COALESCE(ds.total_times_logged, 0) AS times_logged,
          COALESCE(ds.unique_users_count, 0) AS unique_users,
          ds.last_logged_at,
          get_dish_ingredient_count(d.dish_id) AS ingredient_count,
          get_dish_total_weight(d.dish_id) AS total_weight_g
        FROM dish d
        LEFT JOIN dishstatistics ds ON ds.dish_id = d.dish_id
        WHERE (d.is_deleted IS NOT TRUE)
      `;

      const params = [];
      let paramIndex = 1;

      if (filters.viewerUserId !== undefined && filters.viewerUserId !== null) {
        query += ` AND (d.is_public = TRUE OR d.created_by_user = $${paramIndex++})`;
        params.push(filters.viewerUserId);
      }

      // Apply filters
      if (filters.category) {
        query += ` AND d.category = $${paramIndex++}`;
        params.push(filters.category);
      }

      if (filters.isTemplate !== undefined) {
        query += ` AND d.is_template = $${paramIndex++}`;
        params.push(filters.isTemplate);
      }

      if (filters.isPublic !== undefined) {
        query += ` AND d.is_public = $${paramIndex++}`;
        params.push(filters.isPublic);
      }

      if (filters.userId) {
        query += ` AND d.created_by_user = $${paramIndex++}`;
        params.push(filters.userId);
      }

      if (filters.search) {
        query += ` AND (
          d.name ILIKE $${paramIndex} OR 
          d.vietnamese_name ILIKE $${paramIndex} OR
          d.description ILIKE $${paramIndex}
        )`;
        params.push(`%${filters.search}%`);
        paramIndex++;
      }

      // Order by popularity by default
      query += ` ORDER BY times_logged DESC, d.created_at DESC`;

      // Pagination
      if (filters.limit) {
        query += ` LIMIT $${paramIndex++}`;
        params.push(filters.limit);
      }

      if (filters.offset) {
        query += ` OFFSET $${paramIndex++}`;
        params.push(filters.offset);
      }

      const result = await db.query(query, params);
      return result.rows;
    } catch (error) {
      console.error('Error in getAllDishes:', error);
      throw error;
    }
  },

  /**
   * Get a single dish by ID with full details
   * @param {number} dishId - The dish ID
   * @returns {Promise<Object>} Dish object with ingredients and macros
   */
  async getDishById(dishId) {
    try {
      // Get dish details
      const dishQuery = `
        SELECT 
          d.*,
          COALESCE(ds.total_times_logged, 0) AS times_logged,
          COALESCE(ds.unique_users_count, 0) AS unique_users,
          ds.last_logged_at
        FROM dish d
        LEFT JOIN dishstatistics ds ON ds.dish_id = d.dish_id
        WHERE d.dish_id = $1
      `;
      const dishResult = await db.query(dishQuery, [dishId]);

      if (dishResult.rows.length === 0) {
        return null;
      }

      const dish = dishResult.rows[0];

      // Get ingredients
      const ingredientsQuery = `
        SELECT 
          di.dish_ingredient_id,
          di.food_id,
          f.name AS food_name,
          di.weight_g,
          di.notes,
          di.display_order
        FROM dishingredient di
        JOIN food f ON f.food_id = di.food_id
        WHERE di.dish_id = $1
        ORDER BY di.display_order, di.dish_ingredient_id
      `;
      const ingredientsResult = await db.query(ingredientsQuery, [dishId]);
      dish.ingredients = ingredientsResult.rows;

      // Get macronutrients
      const macrosQuery = `
        SELECT 
          COALESCE(kcal.amount_per_100g, 0) AS calories_per_100g,
          COALESCE(prot.amount_per_100g, 0) AS protein_per_100g,
          COALESCE(fat.amount_per_100g, 0) AS fat_per_100g,
          COALESCE(carb.amount_per_100g, 0) AS carbs_per_100g
        FROM (SELECT 1) AS dummy
        LEFT JOIN (
          SELECT amount_per_100g
          FROM dishnutrient dn
          JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
          WHERE dn.dish_id = $1 AND n.nutrient_code = 'ENERC_KCAL'
        ) kcal ON TRUE
        LEFT JOIN (
          SELECT amount_per_100g
          FROM dishnutrient dn
          JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
          WHERE dn.dish_id = $1 AND n.nutrient_code = 'PROCNT'
        ) prot ON TRUE
        LEFT JOIN (
          SELECT amount_per_100g
          FROM dishnutrient dn
          JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
          WHERE dn.dish_id = $1 AND n.nutrient_code = 'FAT'
        ) fat ON TRUE
        LEFT JOIN (
          SELECT amount_per_100g
          FROM dishnutrient dn
          JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
          WHERE dn.dish_id = $1 AND n.nutrient_code = 'CHOCDF'
        ) carb ON TRUE
      `;
      const macrosResult = await db.query(macrosQuery, [dishId]);
      dish.macros = macrosResult.rows[0];

      // Get all images
      const imagesQuery = `
        SELECT 
          dish_image_id,
          image_url,
          image_type,
          is_primary,
          caption,
          uploaded_at
        FROM dishimage
        WHERE dish_id = $1
        ORDER BY is_primary DESC, display_order, uploaded_at DESC
      `;
      const imagesResult = await db.query(imagesQuery, [dishId]);
      dish.images = imagesResult.rows;

      return dish;
    } catch (error) {
      console.error('Error in getDishById:', error);
      throw error;
    }
  },

  /**
   * Create a new dish
   * @param {Object} dishData - Dish information
   * @param {string} dishData.name - Dish name (English)
   * @param {string} dishData.vietnameseName - Vietnamese name
   * @param {string} dishData.description - Description
   * @param {string} dishData.category - Category
   * @param {number} dishData.servingSizeG - Serving size in grams
   * @param {string} dishData.imageUrl - Primary image URL
   * @param {boolean} dishData.isTemplate - Is template dish
   * @param {boolean} dishData.isPublic - Is public dish
   * @param {number} dishData.createdByUser - User ID (if user-created)
   * @param {number} dishData.createdByAdmin - Admin ID (if admin-created)
   * @returns {Promise<Object>} Created dish object
   */
  async createDish(dishData) {
    try {
      const query = `
        INSERT INTO dish (
          name, 
          vietnamese_name, 
          description, 
          category, 
          serving_size_g, 
          image_url,
          is_template,
          is_public,
          created_by_user,
          created_by_admin
        ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING *
      `;

      const params = [
        dishData.name,
        dishData.vietnameseName || null,
        dishData.description || null,
        dishData.category || null,
        dishData.servingSizeG || 100,
        dishData.imageUrl || null,
        dishData.isTemplate || false,
        dishData.isPublic !== undefined ? dishData.isPublic : true,
        dishData.createdByUser || null,
        dishData.createdByAdmin || null
      ];

      const result = await db.query(query, params);
      return result.rows[0];
    } catch (error) {
      console.error('Error in createDish:', error);
      throw error;
    }
  },

  /**
   * Update an existing dish
   * @param {number} dishId - Dish ID to update
   * @param {Object} dishData - Updated dish data
   * @returns {Promise<Object>} Updated dish object
   */
  async updateDish(dishId, dishData) {
    try {
      const updates = [];
      const params = [dishId];
      let paramIndex = 2;

      if (dishData.name !== undefined) {
        updates.push(`name = $${paramIndex++}`);
        params.push(dishData.name);
      }

      if (dishData.vietnameseName !== undefined) {
        updates.push(`vietnamese_name = $${paramIndex++}`);
        params.push(dishData.vietnameseName);
      }

      if (dishData.description !== undefined) {
        updates.push(`description = $${paramIndex++}`);
        params.push(dishData.description);
      }

      if (dishData.category !== undefined) {
        updates.push(`category = $${paramIndex++}`);
        params.push(dishData.category);
      }

      if (dishData.servingSizeG !== undefined) {
        updates.push(`serving_size_g = $${paramIndex++}`);
        params.push(dishData.servingSizeG);
      }

      if (dishData.imageUrl !== undefined) {
        updates.push(`image_url = $${paramIndex++}`);
        params.push(dishData.imageUrl);
      }

      if (dishData.isTemplate !== undefined) {
        updates.push(`is_template = $${paramIndex++}`);
        params.push(dishData.isTemplate);
      }

      if (dishData.isPublic !== undefined) {
        updates.push(`is_public = $${paramIndex++}`);
        params.push(dishData.isPublic);
      }

      if (updates.length === 0) {
        throw new Error('No fields to update');
      }

      updates.push(`updated_at = NOW()`);

      const query = `
        UPDATE dish 
        SET ${updates.join(', ')}
        WHERE dish_id = $1
        RETURNING *
      `;

      const result = await db.query(query, params);

      if (result.rows.length === 0) {
        return null;
      }

      return result.rows[0];
    } catch (error) {
      console.error('Error in updateDish:', error);
      throw error;
    }
  },

  /**
   * Delete a dish (soft delete by setting is_public=false, or hard delete)
   * @param {number} dishId - Dish ID to delete
   * @param {boolean} hardDelete - If true, permanently delete; if false, soft delete
   * @returns {Promise<boolean>} Success status
   */
  async deleteDish(dishId, hardDelete = false) {
    try {
      if (hardDelete) {
        // Delete ingredients first (foreign key)
        await db.query('DELETE FROM DishIngredient WHERE dish_id = $1', [dishId]);
        // Delete nutrients
        await db.query('DELETE FROM DishNutrient WHERE dish_id = $1', [dishId]);
        // Delete statistics
        await db.query('DELETE FROM DishStatistics WHERE dish_id = $1', [dishId]);
        // Hard delete dish
        await db.query('DELETE FROM Dish WHERE dish_id = $1', [dishId]);
        
        console.log(`Hard deleted dish ${dishId} and all related data`);
      } else {
        // Soft delete: set is_deleted flag
        await db.query(
          'UPDATE Dish SET is_deleted = TRUE, updated_at = NOW() WHERE dish_id = $1',
          [dishId]
        );
        
        console.log(`Soft deleted dish ${dishId}`);
      }

      return true;
    } catch (error) {
      console.error('Error in deleteDish:', error);
      throw error;
    }
  },

  /**
   * Add an ingredient to a dish
   * @param {number} dishId - Dish ID
   * @param {Object} ingredientData - Ingredient data
   * @param {number} ingredientData.foodId - Food ID
   * @param {number} ingredientData.weightG - Weight in grams
   * @param {string} ingredientData.notes - Optional notes
   * @param {number} ingredientData.displayOrder - Display order
   * @returns {Promise<Object>} Created ingredient object
   */
  async addIngredient(dishId, ingredientData) {
    try {
      const query = `
        INSERT INTO dishingredient (
          dish_id, 
          food_id, 
          weight_g, 
          notes, 
          display_order
        ) VALUES ($1, $2, $3, $4, $5)
        RETURNING *
      `;

      const params = [
        dishId,
        ingredientData.foodId,
        ingredientData.weightG,
        ingredientData.notes || null,
        ingredientData.displayOrder || 0
      ];

      const result = await db.query(query, params);

      // Trigger will automatically recalculate dish nutrients
      return result.rows[0];
    } catch (error) {
      console.error('Error in addIngredient:', error);
      throw error;
    }
  },

  /**
   * Update an ingredient
   * @param {number} ingredientId - Ingredient ID
   * @param {Object} ingredientData - Updated data
   * @returns {Promise<Object>} Updated ingredient object
   */
  async updateIngredient(ingredientId, ingredientData) {
    try {
      const updates = [];
      const params = [ingredientId];
      let paramIndex = 2;

      if (ingredientData.weightG !== undefined) {
        updates.push(`weight_g = $${paramIndex++}`);
        params.push(ingredientData.weightG);
      }

      if (ingredientData.notes !== undefined) {
        updates.push(`notes = $${paramIndex++}`);
        params.push(ingredientData.notes);
      }

      if (ingredientData.displayOrder !== undefined) {
        updates.push(`display_order = $${paramIndex++}`);
        params.push(ingredientData.displayOrder);
      }

      if (updates.length === 0) {
        throw new Error('No fields to update');
      }

      const query = `
        UPDATE dishingredient 
        SET ${updates.join(', ')}
        WHERE dish_ingredient_id = $1
        RETURNING *
      `;

      const result = await db.query(query, params);

      if (result.rows.length === 0) {
        return null;
      }

      // Trigger will automatically recalculate dish nutrients
      return result.rows[0];
    } catch (error) {
      console.error('Error in updateIngredient:', error);
      throw error;
    }
  },

  /**
   * Remove an ingredient from a dish
   * @param {number} ingredientId - Ingredient ID to remove
   * @returns {Promise<boolean>} Success status
   */
  async removeIngredient(ingredientId) {
    try {
      const result = await db.query(
        'DELETE FROM dishingredient WHERE dish_ingredient_id = $1 RETURNING dish_id',
        [ingredientId]
      );

      // Trigger will automatically recalculate dish nutrients
      return result.rows.length > 0;
    } catch (error) {
      console.error('Error in removeIngredient:', error);
      throw error;
    }
  },

  /**
   * Get all nutrients for a dish
   * @param {number} dishId - Dish ID
   * @returns {Promise<Array>} Array of nutrient objects
   */
  async getDishNutrients(dishId) {
    try {
      const query = `
        SELECT 
          n.nutrient_id,
          n.name AS nutrient_name,
          n.nutrient_code,
          n.unit,
          dn.amount_per_100g
        FROM dishnutrient dn
        JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
        WHERE dn.dish_id = $1 AND dn.amount_per_100g > 0
        ORDER BY n.name
      `;

      const result = await db.query(query, [dishId]);
      return result.rows;
    } catch (error) {
      console.error('Error in getDishNutrients:', error);
      throw error;
    }
  },

  /**
   * Manually recalculate nutrients for a dish
   * @param {number} dishId - Dish ID
   * @returns {Promise<void>}
   */
  async recalculateNutrients(dishId) {
    try {
      await db.query('SELECT calculate_dish_nutrients($1)', [dishId]);
    } catch (error) {
      console.error('Error in recalculateNutrients:', error);
      throw error;
    }
  },

  /**
   * Get dish statistics for admin dashboard
   * @returns {Promise<Object>} Statistics object
   */
  async getDashboardStats() {
    try {
      const query = `
        SELECT 
          COUNT(*) AS total_dishes,
          COUNT(*) FILTER (WHERE is_template = TRUE) AS template_dishes,
          COUNT(*) FILTER (WHERE created_by_user IS NOT NULL) AS user_dishes,
          COUNT(*) FILTER (WHERE created_by_admin IS NOT NULL) AS admin_dishes,
          COALESCE(SUM(ds.total_times_logged), 0) AS total_logs,
          COALESCE(AVG(get_dish_ingredient_count(d.dish_id)), 0) AS avg_ingredients
        FROM dish d
        LEFT JOIN dishstatistics ds ON ds.dish_id = d.dish_id
      `;

      const result = await db.query(query);
      return result.rows[0];
    } catch (error) {
      console.error('Error in getDashboardStats:', error);
      throw error;
    }
  },

  /**
   * Get popular dishes (most logged)
   * @param {number} limit - Number of dishes to return
   * @returns {Promise<Array>} Array of popular dishes
   */
  async getPopularDishes(limit = 10) {
    try {
      const query = `
        SELECT 
          d.dish_id,
          d.name,
          d.vietnamese_name,
          d.category,
          d.image_url,
          ds.total_times_logged,
          ds.unique_users_count
        FROM dish d
        JOIN DishStatistics ds ON ds.dish_id = d.dish_id
        WHERE d.is_public = TRUE
        ORDER BY ds.total_times_logged DESC
        LIMIT $1
      `;

      const result = await db.query(query, [limit]);
      return result.rows;
    } catch (error) {
      console.error('Error in getPopularDishes:', error);
      throw error;
    }
  },

  /**
   * Search dishes by name (for meal logging)
   * @param {string} searchTerm - Search term
   * @param {number} limit - Max results
   * @returns {Promise<Array>} Array of matching dishes
   */
  async searchDishes(searchTerm, limit = 20) {
    try {
      const query = `
        SELECT 
          d.dish_id,
          d.name,
          d.vietnamese_name,
          d.category,
          d.serving_size_g,
          d.image_url,
          COALESCE(kcal.amount_per_100g, 0) AS calories_per_100g,
          COALESCE(prot.amount_per_100g, 0) AS protein_per_100g
        FROM dish d
        LEFT JOIN (
          SELECT dish_id, amount_per_100g
          FROM dishnutrient dn
          JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
          WHERE n.nutrient_code = 'ENERC_KCAL'
        ) kcal ON kcal.dish_id = d.dish_id
        LEFT JOIN (
          SELECT dish_id, amount_per_100g
          FROM dishnutrient dn
          JOIN nutrient n ON n.nutrient_id = dn.nutrient_id
          WHERE n.nutrient_code = 'PROCNT'
        ) prot ON prot.dish_id = d.dish_id
        WHERE d.is_public = TRUE
          AND (
            d.name ILIKE $1 OR 
            d.vietnamese_name ILIKE $1
          )
        ORDER BY 
          CASE 
            WHEN d.name ILIKE $2 THEN 1
            WHEN d.vietnamese_name ILIKE $2 THEN 2
            ELSE 3
          END,
          d.name
        LIMIT $3
      `;

      const result = await db.query(query, [
        `%${searchTerm}%`,
        `${searchTerm}%`,
        limit
      ]);

      return result.rows;
    } catch (error) {
      console.error('Error in searchDishes:', error);
      throw error;
    }
  },

  /**
   * Get dish categories
   * @returns {Promise<Array>} Array of categories with counts
   */
  async getCategories() {
    try {
      const query = `
        SELECT 
          category,
          COUNT(*) as count
        FROM dish
        WHERE category IS NOT NULL AND is_public = TRUE
        GROUP BY category
        ORDER BY count DESC, category
      `;

      const result = await db.query(query);
      return result.rows;
    } catch (error) {
      console.error('Error in getCategories:', error);
      throw error;
    }
  },

  /**
   * Add multiple ingredients to a dish (batch operation)
   * @param {number} dishId - Dish ID
   * @param {Array<Object>} ingredients - Array of ingredient objects [{food_id, weight_g}]
   * @returns {Promise<void>}
   */
  async addIngredients(dishId, ingredients) {
    try {
      for (let i = 0; i < ingredients.length; i++) {
        const ing = ingredients[i];
        await this.addIngredient(dishId, {
          foodId: ing.food_id ?? ing.foodId,
          weightG: ing.weight_g ?? ing.weightG,
          displayOrder: i
        });
      }
    } catch (error) {
      console.error('Error in addIngredients:', error);
      throw error;
    }
  },

  /**
   * Check if dish name exists (for duplicate checking)
   * @param {Object} params - Check parameters
   * @param {string} params.name - English name to check
   * @param {string} params.vietnameseName - Vietnamese name to check
   * @param {number} params.excludeDishId - Dish ID to exclude from check (for updates)
   * @returns {Promise<boolean>} True if name exists
   */
  async checkNameExists({ name, vietnameseName, excludeDishId = null }) {
    try {
      const conditions = [];
      const params = [];
      let paramIndex = 1;

      if (name) {
        conditions.push(`LOWER(TRIM(name)) = LOWER(TRIM($${paramIndex++}))`);
        params.push(name);
      }

      if (vietnameseName) {
        conditions.push(`LOWER(TRIM(vietnamese_name)) = LOWER(TRIM($${paramIndex++}))`);
        params.push(vietnameseName);
      }

      if (conditions.length === 0) {
        return false;
      }

      let query = `SELECT dish_id FROM dish WHERE (${conditions.join(' OR ')})`;
      
      if (excludeDishId) {
        query += ` AND dish_id <> $${paramIndex++}`;
        params.push(excludeDishId);
      }

      const result = await db.query(query, params);
      return result.rowCount > 0;
    } catch (error) {
      console.error('Error in checkNameExists:', error);
      throw error;
    }
  }
};

module.exports = dishService;
