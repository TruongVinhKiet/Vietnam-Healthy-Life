const db = require('../db');

// ============================================================
// ADMIN: Drug Management
// ============================================================

// GET /api/admin/drugs - List all drugs
exports.listDrugs = async (req, res) => {
  try {
    const { search, is_active, page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    let query = `
      SELECT 
        d.drug_id,
        d.name_vi,
        d.name_en,
        d.generic_name,
        d.drug_class,
        d.description,
        d.image_url,
        d.source_link,
        d.dosage_form,
        d.is_active,
        d.created_at,
        d.updated_at,
        COUNT(DISTINCT dhc.condition_id) as condition_count
      FROM Drug d
      LEFT JOIN DrugHealthCondition dhc ON dhc.drug_id = d.drug_id
      WHERE 1=1
    `;
    const params = [];
    let paramCount = 0;

    if (search) {
      paramCount++;
      query += ` AND (d.name_vi ILIKE $${paramCount} OR d.name_en ILIKE $${paramCount} OR d.generic_name ILIKE $${paramCount})`;
      params.push(`%${search}%`);
    }

    if (is_active !== undefined) {
      paramCount++;
      query += ` AND d.is_active = $${paramCount}`;
      params.push(is_active === 'true');
    }

    query += ` GROUP BY d.drug_id ORDER BY d.created_at DESC LIMIT $${++paramCount} OFFSET $${++paramCount}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);
    const drugs = result.rows;

    // Get total count
    let countQuery = `SELECT COUNT(*) FROM Drug WHERE 1=1`;
    const countParams = [];
    let countParamCount = 0;

    if (search) {
      countParamCount++;
      countQuery += ` AND (name_vi ILIKE $${countParamCount} OR name_en ILIKE $${countParamCount} OR generic_name ILIKE $${countParamCount})`;
      countParams.push(`%${search}%`);
    }

    if (is_active !== undefined) {
      countParamCount++;
      countQuery += ` AND is_active = $${countParamCount}`;
      countParams.push(is_active === 'true');
    }

    const countResult = await db.query(countQuery, countParams);
    const total = parseInt(countResult.rows[0].count);

    return res.json({
      success: true,
      drugs,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        totalPages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error listing drugs:', error);
    return res.status(500).json({ error: 'Failed to list drugs' });
  }
};

// GET /api/admin/drugs/:id - Get drug details
exports.getDrugDetails = async (req, res) => {
  try {
    const { id } = req.params;

    // Get drug info
    const drugResult = await db.query(
      `SELECT * FROM Drug WHERE drug_id = $1`,
      [id]
    );

    if (drugResult.rows.length === 0) {
      return res.status(404).json({ error: 'Drug not found' });
    }

    const drug = drugResult.rows[0];

    // Get linked conditions
    const conditionsResult = await db.query(
      `SELECT 
        hc.condition_id,
        hc.name_vi,
        hc.name_en,
        hc.category,
        dhc.is_primary,
        dhc.treatment_notes
      FROM DrugHealthCondition dhc
      JOIN HealthCondition hc ON hc.condition_id = dhc.condition_id
      WHERE dhc.drug_id = $1
      ORDER BY dhc.is_primary DESC, hc.name_vi`,
      [id]
    );

    // Get contraindications (side effects)
    const contraResult = await db.query(
      `SELECT 
        nc.contra_id,
        nc.nutrient_id,
        n.name as nutrient_name,
        nc.avoid_hours_before,
        nc.avoid_hours_after,
        nc.warning_message_vi,
        nc.warning_message_en,
        nc.severity
      FROM DrugNutrientContraindication nc
      JOIN Nutrient n ON n.nutrient_id = nc.nutrient_id
      WHERE nc.drug_id = $1
      ORDER BY nc.severity DESC, n.name`,
      [id]
    );

    return res.json({
      success: true,
      drug: {
        ...drug,
        conditions: conditionsResult.rows,
        contraindications: contraResult.rows
      }
    });
  } catch (error) {
    console.error('Error getting drug details:', error);
    return res.status(500).json({ error: 'Failed to get drug details' });
  }
};

// POST /api/admin/drugs - Create drug
exports.createDrug = async (req, res) => {
  try {
    const {
      name_vi,
      name_en,
      generic_name,
      drug_class,
      description,
      image_url,
      source_link,
      dosage_form,
      is_active = true,
      condition_ids = [],
      contraindications = []
    } = req.body;

    if (!name_vi) {
      return res.status(400).json({ error: 'name_vi is required' });
    }

    const admin_id = req.admin.admin_id;

    // Insert drug
    const drugResult = await db.query(
      `INSERT INTO Drug (
        name_vi, name_en, generic_name, drug_class, description,
        image_url, source_link, dosage_form, is_active, created_by_admin
      ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
      RETURNING *`,
      [name_vi, name_en, generic_name, drug_class, description,
       image_url, source_link, dosage_form, is_active, admin_id]
    );

    const drug = drugResult.rows[0];
    const drug_id = drug.drug_id;

    // Link conditions
    if (condition_ids.length > 0) {
      for (const condition of condition_ids) {
        await db.query(
          `INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (drug_id, condition_id) DO UPDATE
           SET is_primary = EXCLUDED.is_primary, treatment_notes = EXCLUDED.treatment_notes`,
          [drug_id, condition.condition_id, condition.is_primary || false, condition.treatment_notes || null]
        );
      }
    }

    // Add contraindications
    if (contraindications.length > 0) {
      for (const contra of contraindications) {
        await db.query(
          `INSERT INTO DrugNutrientContraindication (
            drug_id, nutrient_id, avoid_hours_before, avoid_hours_after,
            warning_message_vi, warning_message_en, severity
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)
          ON CONFLICT (drug_id, nutrient_id) DO UPDATE
          SET avoid_hours_before = EXCLUDED.avoid_hours_before,
              avoid_hours_after = EXCLUDED.avoid_hours_after,
              warning_message_vi = EXCLUDED.warning_message_vi,
              warning_message_en = EXCLUDED.warning_message_en,
              severity = EXCLUDED.severity`,
          [
            drug_id,
            contra.nutrient_id,
            contra.avoid_hours_before || 0,
            contra.avoid_hours_after || 2,
            contra.warning_message_vi,
            contra.warning_message_en,
            contra.severity || 'moderate'
          ]
        );
      }
    }

    return res.json({
      success: true,
      drug
    });
  } catch (error) {
    console.error('Error creating drug:', error);
    return res.status(500).json({ error: 'Failed to create drug' });
  }
};

// PUT /api/admin/drugs/:id - Update drug
exports.updateDrug = async (req, res) => {
  try {
    const { id } = req.params;
    const {
      name_vi,
      name_en,
      generic_name,
      drug_class,
      description,
      image_url,
      source_link,
      dosage_form,
      is_active,
      condition_ids = [],
      contraindications = []
    } = req.body;

    // Update drug
    const drugResult = await db.query(
      `UPDATE Drug SET
        name_vi = COALESCE($1, name_vi),
        name_en = COALESCE($2, name_en),
        generic_name = COALESCE($3, generic_name),
        drug_class = COALESCE($4, drug_class),
        description = COALESCE($5, description),
        image_url = COALESCE($6, image_url),
        source_link = COALESCE($7, source_link),
        dosage_form = COALESCE($8, dosage_form),
        is_active = COALESCE($9, is_active),
        updated_at = NOW()
      WHERE drug_id = $10
      RETURNING *`,
      [name_vi, name_en, generic_name, drug_class, description,
       image_url, source_link, dosage_form, is_active, id]
    );

    if (drugResult.rows.length === 0) {
      return res.status(404).json({ error: 'Drug not found' });
    }

    const drug = drugResult.rows[0];

    // Update conditions (delete old, insert new)
    await db.query(`DELETE FROM DrugHealthCondition WHERE drug_id = $1`, [id]);
    if (condition_ids.length > 0) {
      for (const condition of condition_ids) {
        await db.query(
          `INSERT INTO DrugHealthCondition (drug_id, condition_id, is_primary, treatment_notes)
           VALUES ($1, $2, $3, $4)`,
          [id, condition.condition_id, condition.is_primary || false, condition.treatment_notes || null]
        );
      }
    }

    // Update contraindications (delete old, insert new)
    await db.query(`DELETE FROM DrugNutrientContraindication WHERE drug_id = $1`, [id]);
    if (contraindications.length > 0) {
      for (const contra of contraindications) {
        await db.query(
          `INSERT INTO DrugNutrientContraindication (
            drug_id, nutrient_id, avoid_hours_before, avoid_hours_after,
            warning_message_vi, warning_message_en, severity
          ) VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [
            id,
            contra.nutrient_id,
            contra.avoid_hours_before || 0,
            contra.avoid_hours_after || 2,
            contra.warning_message_vi,
            contra.warning_message_en,
            contra.severity || 'moderate'
          ]
        );
      }
    }

    return res.json({
      success: true,
      drug
    });
  } catch (error) {
    console.error('Error updating drug:', error);
    return res.status(500).json({ error: 'Failed to update drug' });
  }
};

// DELETE /api/admin/drugs/:id - Delete drug
exports.deleteDrug = async (req, res) => {
  try {
    const { id } = req.params;

    // Check if drug is used in medication schedules
    const scheduleResult = await db.query(
      `SELECT COUNT(*) FROM MedicationSchedule WHERE drug_id = $1`,
      [id]
    );

    if (parseInt(scheduleResult.rows[0].count) > 0) {
      return res.status(400).json({
        error: 'Cannot delete drug that is used in medication schedules. Deactivate it instead.'
      });
    }

    const result = await db.query(`DELETE FROM Drug WHERE drug_id = $1 RETURNING *`, [id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Drug not found' });
    }

    return res.json({
      success: true,
      message: 'Drug deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting drug:', error);
    return res.status(500).json({ error: 'Failed to delete drug' });
  }
};

// GET /api/admin/drugs/stats - Get drug statistics
exports.getDrugStats = async (req, res) => {
  try {
    const statsResult = await db.query(`SELECT * FROM DrugStatistics`);
    return res.json({
      success: true,
      stats: statsResult.rows[0] || { active_drugs: 0, inactive_drugs: 0, total_drugs: 0, conditions_covered: 0 }
    });
  } catch (error) {
    console.error('Error getting drug stats:', error);
    return res.status(500).json({ error: 'Failed to get drug statistics' });
  }
};

