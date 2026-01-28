const db = require('../db');
const { getVietnamDate } = require('../utils/dateHelper');

const MACRO_CODES = {
  ENERC_KCAL: 'calories',
  PROCNT: 'protein',
  FAT: 'fat',
  CHOCDF: 'carbs'
};

async function resolveNutrientInfo({ code, nutrientId }) {
  if (!code && !nutrientId) return null;
  const params = [];
  let whereClause = '';

  if (code) {
    params.push(code);
    whereClause = 'UPPER(code) = UPPER($1)';
  } else {
    params.push(nutrientId);
    whereClause = 'id_match = $1';
  }

  // Strip AMINO_ prefix for amino acid lookup
  const searchCode = code && code.toUpperCase().startsWith('AMINO_') 
    ? code.substring(6) // Remove 'AMINO_' prefix
    : code;

  const query = `
    WITH source AS (
      SELECT vitamin_id AS nutrient_id, 'vitamin' AS nutrient_type, code, name, unit, vitamin_id AS id_match
      FROM Vitamin
      UNION ALL
      SELECT mineral_id, 'mineral', code, name, unit, mineral_id FROM Mineral
      UNION ALL
      SELECT fiber_id, 'fiber', code, name, unit, fiber_id FROM Fiber
      UNION ALL
      SELECT fatty_acid_id, 'fatty_acid', code, name, unit, fatty_acid_id FROM FattyAcid
      UNION ALL
      SELECT amino_acid_id, 'amino_acid', code, name, 'mg' AS unit, amino_acid_id FROM AminoAcid
    )
    SELECT nutrient_id, nutrient_type, code, name, unit
    FROM source
    WHERE ${code ? 'UPPER(code) = UPPER($1)' : 'id_match = $1'}
    UNION ALL
    SELECT nutrient_id, 'macro' AS nutrient_type, nutrient_code AS code, name, unit
    FROM Nutrient
    WHERE (${code ? 'UPPER(nutrient_code) = UPPER($1)' : 'nutrient_id = $1'})
      AND nutrient_code NOT LIKE 'AMINO_%'
    LIMIT 1
  `;

  params[0] = searchCode || nutrientId;

  const result = await db.query(query, params);
  return result.rows[0] || null;
}

async function saveManualIntake({
  userId,
  nutrients = [],
  foodName,
  source = 'manual',
  sourceRef,
  date
}) {
  if (!Array.isArray(nutrients) || nutrients.length === 0) {
    return { todayTotals: null };
  }

  const logDate = date || getVietnamDate();
  const macros = { calories: 0, protein: 0, fat: 0, carbs: 0 };

  for (const nutrient of nutrients) {
    const rawCode = nutrient.nutrient_code || nutrient.code;
    const code = rawCode ? String(rawCode).trim().toUpperCase() : null;
    const amount = parseFloat(
      nutrient.amount ??
        nutrient.current_amount ??
        nutrient.value ??
        0
    );

    if (!code || Number.isNaN(amount) || amount === 0) continue;

    // Handle macros separately (they don't exist in Nutrient table)
    const macroKey = MACRO_CODES[code];
    if (macroKey) {
      macros[macroKey] += amount;
      continue; // Skip database insert for macros, they go to DailySummary
    }

    // Only resolve nutrient info for non-macro nutrients
    const nutrientInfo = await resolveNutrientInfo({
      code,
      nutrientId: nutrient.nutrient_id
    });

    if (!nutrientInfo) {
      console.warn(`[ManualNutrition] Nutrient code ${code} not found, skipping.`);
      continue;
    }
    
    // Debug log for minerals and amino acids
    if (code.startsWith('MIN_') || code.startsWith('AMINO_')) {
      console.log(`[ManualNutrition] Found ${code}: type=${nutrientInfo.nutrient_type}, id=${nutrientInfo.nutrient_id}, amount=${amount}`);
    }

    const metadata = {
      food_name: nutrient.food_name || foodName || null,
      confidence: nutrient.confidence || null,
      source
    };

    try {
      await db.query(
      `
        INSERT INTO UserNutrientManualLog (
          user_id, log_date, nutrient_id, nutrient_type, nutrient_code,
          nutrient_name, unit, amount, source, source_ref, metadata
        )
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
        ON CONFLICT ON CONSTRAINT ux_manual_nutrient_user_date_nutrient_type
        DO UPDATE SET
          amount = UserNutrientManualLog.amount + EXCLUDED.amount,
          source = EXCLUDED.source,
          source_ref = EXCLUDED.source_ref,
          metadata = COALESCE(EXCLUDED.metadata, UserNutrientManualLog.metadata),
          updated_at = NOW()
      `,
      [
        userId,
        logDate,
        nutrientInfo.nutrient_id,
        nutrientInfo.nutrient_type,
        nutrientInfo.code,
        nutrientInfo.name || nutrient.nutrient_name,
        nutrientInfo.unit || nutrient.unit,
        amount,
        source,
        sourceRef || null,
        metadata
      ]
    );
      
      // Debug log successful insert
      if (code.startsWith('MIN_') || code.startsWith('AMINO_')) {
        console.log(`[ManualNutrition] ✓ Inserted ${code} into UserNutrientManualLog`);
      }
    } catch (insertError) {
      console.error(`[ManualNutrition] ERROR inserting ${code}:`, insertError.message);
      throw insertError;
    }
  }

  let todayTotals = null;
  const hasMacros =
    macros.calories || macros.protein || macros.fat || macros.carbs;

  if (hasMacros) {
    const totals = await db.query(
      `
        INSERT INTO DailySummary (user_id, date, total_calories, total_protein, total_fat, total_carbs)
        VALUES ($1,$2,$3,$4,$5,$6)
        ON CONFLICT (user_id, date) DO UPDATE SET
          total_calories = COALESCE(DailySummary.total_calories,0) + EXCLUDED.total_calories,
          total_protein = COALESCE(DailySummary.total_protein,0) + EXCLUDED.total_protein,
          total_fat = COALESCE(DailySummary.total_fat,0) + EXCLUDED.total_fat,
          total_carbs = COALESCE(DailySummary.total_carbs,0) + EXCLUDED.total_carbs
        RETURNING total_calories, total_protein, total_fat, total_carbs
      `,
      [
        userId,
        logDate,
        macros.calories,
        macros.protein,
        macros.fat,
        macros.carbs
      ]
    );
    todayTotals = totals.rows[0];
  } else {
    const existing = await db.query(
      `
        SELECT total_calories, total_protein, total_fat, total_carbs
        FROM DailySummary
        WHERE user_id = $1 AND date = $2
      `,
      [userId, logDate]
    );
    todayTotals = existing.rows[0];
  }

  const normalizedTotals = {
    today_calories: parseFloat(
      todayTotals?.total_calories ?? todayTotals?.today_calories ?? 0
    ),
    today_protein: parseFloat(
      todayTotals?.total_protein ?? todayTotals?.today_protein ?? 0
    ),
    today_fat: parseFloat(
      todayTotals?.total_fat ?? todayTotals?.today_fat ?? 0
    ),
    today_carbs: parseFloat(
      todayTotals?.total_carbs ?? todayTotals?.today_carbs ?? 0
    ),
  };

  return { todayTotals: normalizedTotals };
}

module.exports = { saveManualIntake };

