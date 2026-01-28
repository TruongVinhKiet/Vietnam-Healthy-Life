const express = require('express');
const router = express.Router();
const db = require('../db');
const authMiddleware = require('../utils/authMiddleware');

// GET /health/conditions - Get all health conditions with optional filters
router.get('/conditions', async (req, res) => {
  try {
    const { category, severity } = req.query;
    
    let query = `
      SELECT 
        condition_id,
        name_vi,
        name_en,
        category,
        description,
        description_vi,
        causes,
        treatment_duration_reference,
        image_url,
        article_link_vi,
        article_link_en,
        prevention_tips_vi,
        prevention_tips,
        severity_level,
        is_chronic,
        created_at,
        updated_at
      FROM healthcondition
      WHERE 1=1
    `;
    
    const params = [];
    let paramIndex = 1;
    
    if (category) {
      query += ` AND category = $${paramIndex}`;
      params.push(category);
      paramIndex++;
    }
    
    if (severity) {
      query += ` AND severity_level = $${paramIndex}`;
      params.push(severity);
      paramIndex++;
    }
    
    query += ' ORDER BY condition_id ASC';
    
    const result = await db.query(query, params);
    
    res.json({
      success: true,
      conditions: result.rows,
      total: result.rows.length
    });
  } catch (error) {
    console.error('Error fetching health conditions:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch health conditions',
      message: error.message
    });
  }
});

// GET /health/conditions/:id - Get single health condition with full details
router.get('/conditions/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get condition details
    const conditionResult = await db.query(
      `SELECT * FROM healthcondition WHERE condition_id = $1`,
      [id]
    );
    
    if (conditionResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Health condition not found'
      });
    }
    
    const condition = conditionResult.rows[0];
    
    // Get nutrient effects
    const nutrientEffectsResult = await db.query(
      `SELECT 
        ne.effect_id,
        ne.nutrient_id,
        n.name as nutrient_name,
        ne.adjustment_percent
      FROM nutrienteffect ne
      JOIN nutrient n ON ne.nutrient_id = n.nutrient_id
      WHERE ne.condition_id = $1
      ORDER BY ne.adjustment_percent DESC`,
      [id]
    );
    
    // Get food recommendations
    const foodRecommendationsResult = await db.query(
      `SELECT 
        cfr.recommendation_id,
        cfr.food_id,
        COALESCE(f.name_vi, f.name, 'Unknown') as food_name,
        cfr.recommendation_type,
        cfr.notes as notes
      FROM conditionfoodrecommendation cfr
      LEFT JOIN food f ON cfr.food_id = f.food_id
      WHERE cfr.condition_id = $1
      ORDER BY cfr.recommendation_type, cfr.food_id`,
      [id]
    );
    
    // Separate foods to avoid and recommend
    const foodsToAvoid = foodRecommendationsResult.rows.filter(
      f => f.recommendation_type === 'avoid'
    );
    const foodsRecommended = foodRecommendationsResult.rows.filter(
      f => f.recommendation_type === 'recommend'
    );
    
    // Get drug treatments
    const drugsResult = await db.query(
      `SELECT 
        d.drug_id,
        d.name_vi,
        d.name_en,
        d.generic_name,
        d.drug_class,
        d.description,
        d.description_vi,
        d.image_url,
        d.source_link,
        d.dosage_form,
        dhc.treatment_notes_vi,
        dhc.treatment_notes,
        dhc.is_primary
      FROM drughealthcondition dhc
      JOIN drug d ON dhc.drug_id = d.drug_id
      WHERE dhc.condition_id = $1 AND d.is_active = true
      ORDER BY dhc.is_primary DESC, d.name_vi ASC`,
      [id]
    );
    
    res.json({
      success: true,
      condition: {
        ...condition,
        nutrient_effects: nutrientEffectsResult.rows,
        foods_to_avoid: foodsToAvoid,
        food_recommendations: foodsRecommended,
        drugs: drugsResult.rows
      }
    });
  } catch (error) {
    console.error('Error fetching health condition details:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch health condition details',
      message: error.message
    });
  }
});

// POST /health/conditions - Create new health condition (admin only)
router.post('/conditions', authMiddleware, async (req, res) => {
  try {
    const {
      name_vi,
      name_en,
      category,
      description,
      description_vi,
      causes,
      treatment_duration_reference,
      image_url,
      article_link_vi,
      article_link_en,
      prevention_tips_vi,
      prevention_tips,
      severity_level,
      is_chronic
    } = req.body;
    
    if (!name_vi || !name_en) {
      return res.status(400).json({
        success: false,
        error: 'name_vi and name_en are required'
      });
    }
    
    const result = await db.query(
      `INSERT INTO healthcondition (
        name_vi, name_en, category, description, description_vi, causes,
        treatment_duration_reference, image_url, article_link_vi, article_link_en,
        prevention_tips_vi, prevention_tips, severity_level, is_chronic,
        created_at, updated_at
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, NOW(), NOW())
      RETURNING *`,
      [
        name_vi, name_en, category, description, description_vi, causes,
        treatment_duration_reference, image_url, article_link_vi, article_link_en,
        prevention_tips_vi, prevention_tips, severity_level, is_chronic
      ]
    );
    
    res.status(201).json({
      success: true,
      condition: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating health condition:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to create health condition',
      message: error.message
    });
  }
});

// PUT /health/conditions/:id - Update health condition (admin only)
router.put('/conditions/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name_vi,
      name_en,
      category,
      description,
      description_vi,
      causes,
      treatment_duration_reference,
      image_url,
      article_link_vi,
      article_link_en,
      prevention_tips_vi,
      prevention_tips,
      severity_level,
      is_chronic
    } = req.body;
    
    const result = await db.query(
      `UPDATE healthcondition SET
        name_vi = $1,
        name_en = $2,
        category = $3,
        description = $4,
        description_vi = $5,
        causes = $6,
        treatment_duration_reference = $7,
        image_url = $8,
        article_link_vi = $9,
        article_link_en = $10,
        prevention_tips_vi = $11,
        prevention_tips = $12,
        severity_level = $13,
        is_chronic = $14,
        updated_at = NOW()
      WHERE condition_id = $15
      RETURNING *`,
      [
        name_vi, name_en, category, description, description_vi, causes,
        treatment_duration_reference, image_url, article_link_vi, article_link_en,
        prevention_tips_vi, prevention_tips, severity_level, is_chronic, id
      ]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Health condition not found'
      });
    }
    
    res.json({
      success: true,
      condition: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating health condition:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to update health condition',
      message: error.message
    });
  }
});

// DELETE /health/conditions/:id - Delete health condition (admin only)
router.delete('/conditions/:id', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(
      'DELETE FROM healthcondition WHERE condition_id = $1 RETURNING *',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Health condition not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Health condition deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting health condition:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to delete health condition',
      message: error.message
    });
  }
});

// POST /health/conditions/:id/nutrient-effects - Add nutrient effect
router.post('/conditions/:id/nutrient-effects', authMiddleware, async (req, res) => {
  try {
    const { id } = req.params;
    const { nutrient_id, adjustment_percent } = req.body;
    
    const result = await db.query(
      `INSERT INTO nutrienteffect (condition_id, nutrient_id, adjustment_percent)
       VALUES ($1, $2, $3)
       RETURNING *`,
      [id, nutrient_id, adjustment_percent]
    );
    
    res.status(201).json({
      success: true,
      nutrient_effect: result.rows[0]
    });
  } catch (error) {
    console.error('Error adding nutrient effect:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to add nutrient effect',
      message: error.message
    });
  }
});

// GET /health/drugs/:id - Get drug details with related conditions
router.get('/drugs/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    // Get drug basic info with all comprehensive fields
    const drugResult = await db.query(
      `SELECT * FROM drug WHERE drug_id = $1 AND is_active = true`,
      [id]
    );
    
    if (drugResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        error: 'Drug not found'
      });
    }
    
    const drug = drugResult.rows[0];
    
    // Get related health conditions
    const conditionsResult = await db.query(
      `SELECT 
        hc.condition_id,
        hc.name_vi,
        hc.name_en,
        hc.category,
        hc.severity_level,
        hc.image_url,
        dhc.treatment_notes_vi,
        dhc.treatment_notes,
        dhc.is_primary
      FROM drughealthcondition dhc
      JOIN healthcondition hc ON dhc.condition_id = hc.condition_id
      WHERE dhc.drug_id = $1
      ORDER BY dhc.is_primary DESC, hc.name_vi ASC`,
      [id]
    );
    
    // Get drug interactions (drug-drug, drug-food, drug-disease)
    const interactionsResult = await db.query(
      `SELECT 
        interaction_id,
        interaction_type,
        interacts_with,
        severity,
        description_vi,
        description_en,
        clinical_effects_vi,
        clinical_effects_en,
        management_vi,
        management_en
      FROM drug_interaction
      WHERE drug_id = $1
      ORDER BY 
        CASE severity
          WHEN 'major' THEN 1
          WHEN 'moderate' THEN 2
          WHEN 'minor' THEN 3
          ELSE 4
        END,
        interaction_type,
        interacts_with`,
      [id]
    );
    
    // Get side effects
    const sideEffectsResult = await db.query(
      `SELECT 
        side_effect_id,
        effect_name_vi,
        effect_name_en,
        frequency,
        severity,
        description_vi,
        description_en,
        is_serious
      FROM drug_side_effect
      WHERE drug_id = $1
      ORDER BY 
        is_serious DESC,
        CASE frequency
          WHEN 'very_common' THEN 1
          WHEN 'common' THEN 2
          WHEN 'uncommon' THEN 3
          WHEN 'rare' THEN 4
          ELSE 5
        END,
        severity DESC`,
      [id]
    );
    
    res.json({
      success: true,
      drug: {
        ...drug,
        related_conditions: conditionsResult.rows,
        interactions: interactionsResult.rows,
        side_effects: sideEffectsResult.rows
      }
    });
  } catch (error) {
    console.error('Error fetching drug details:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch drug details',
      message: error.message
    });
  }
});

module.exports = router;
