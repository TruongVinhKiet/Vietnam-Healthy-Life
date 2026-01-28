const db = require("../db");

/**
 * GET /admin/ai-meals
 * Danh sách các món đã phân tích bởi AI (từ ảnh hoặc chatbot)
 * Query:
 *  - accepted: true/false (optional)
 *  - promoted: true/false (optional)
 *  - item_type: food/drink (optional)
 *  - search: text filter theo item_name (optional)
 *  - limit, offset
 */
async function listAiMeals(req, res) {
  try {
    const {
      accepted,
      promoted,
      item_type,
      search = "",
      limit = 50,
      offset = 0,
    } = req.query;

    const params = [];
    let where = "WHERE 1=1";

    if (accepted !== undefined) {
      params.push(accepted === "true");
      where += ` AND aam.accepted = $${params.length}`;
    }

    if (promoted !== undefined) {
      params.push(promoted === "true");
      where += ` AND COALESCE(aam.promoted, false) = $${params.length}`;
    }

    if (item_type) {
      params.push(item_type);
      where += ` AND aam.item_type = $${params.length}`;
    }

    if (search) {
      params.push(`%${search}%`);
      where += ` AND LOWER(aam.item_name) LIKE LOWER($${params.length})`;
    }

    const baseSelect = `
      SELECT
        aam.*,
        -- phát hiện trùng tên theo vietnamese_name của Dish/Drink
        d.dish_id    AS existing_dish_id,
        d.vietnamese_name AS existing_dish_name,
        dr.drink_id  AS existing_drink_id,
        dr.vietnamese_name AS existing_drink_name
      FROM AI_Analyzed_Meals aam
      LEFT JOIN Dish d
        ON LOWER(TRIM(d.vietnamese_name)) = LOWER(TRIM(aam.item_name))
      LEFT JOIN Drink dr
        ON LOWER(TRIM(dr.vietnamese_name)) = LOWER(TRIM(aam.item_name))
      ${where}
      ORDER BY aam.analyzed_at DESC
      LIMIT $${params.length + 1} OFFSET $${params.length + 2}
    `;

    params.push(parseInt(limit, 10), parseInt(offset, 10));

    const rows = await db.query(baseSelect, params);

    res.json({
      success: true,
      meals: rows.rows,
    });
  } catch (err) {
    console.error("[adminAiController] listAiMeals error:", err);
    return res
      .status(500)
      .json({ error: "Không thể lấy danh sách AI meals", details: err.message });
  }
}

/**
 * POST /admin/ai-meals/:id/promote
 * body: { target_type: 'dish' | 'drink' }
 * - Tạo Dish/Drink mới từ AI_Analyzed_Meals
 * - Tự map nutrients sang DishNutrient/DrinkNutrient nếu có estimated_weight_g / estimated_volume_ml
 */
async function promoteAiMeal(req, res) {
  const { id } = req.params;
  const { target_type } = req.body || {};
  const adminId = req.admin && req.admin.admin_id;

  if (!target_type || !["dish", "drink"].includes(target_type)) {
    return res
      .status(400)
      .json({ error: "target_type phải là 'dish' hoặc 'drink'" });
  }

  try {
    const mealRes = await db.query(
      "SELECT * FROM AI_Analyzed_Meals WHERE id = $1",
      [id]
    );

    if (mealRes.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy AI meal" });
    }

    const meal = mealRes.rows[0];

    // Nếu đã promote rồi thì trả về luôn
    if (meal.promoted === true) {
      return res.json({
        success: true,
        promoted: true,
        meal,
      });
    }

    // Map đầy đủ tất cả nutrient từ các cột của AI_Analyzed_Meals
    // Mapping từ tên cột DB sang nutrient_code chuẩn
    const columnToCodeMap = {
      // Macros
      enerc_kcal: "ENERC_KCAL",
      procnt: "PROCNT",
      fat: "FAT",
      chocdf: "CHOCDF",
      // Fiber
      fibtg: "FIBTG",
      fib_sol: "FIB_SOL",
      fib_insol: "FIB_INSOL",
      fib_rs: "FIB_RS",
      fib_bglu: "FIB_BGLU",
      // Cholesterol
      cholesterol: "CHOLESTEROL",
      // Vitamins
      vita: "VITA",
      vitd: "VITD",
      vite: "VITE",
      vitk: "VITK",
      vitc: "VITC",
      vitb1: "VITB1",
      vitb2: "VITB2",
      vitb3: "VITB3",
      vitb5: "VITB5",
      vitb6: "VITB6",
      vitb7: "VITB7",
      vitb9: "VITB9",
      vitb12: "VITB12",
      // Minerals
      ca: "CA",
      p: "P",
      mg: "MG",
      k: "K",
      na: "NA",
      fe: "FE",
      zn: "ZN",
      cu: "CU",
      mn: "MN",
      i: "I",
      se: "SE",
      cr: "CR",
      mo: "MO",
      f: "F",
      // Fatty Acids
      fams: "FAMS",
      fapu: "FAPU",
      fasat: "FASAT",
      fatrn: "FATRN",
      faepa: "FAEPA",
      fadha: "FADHA",
      faepa_dha: "FAEPA_DHA",
      fa18_2n6c: "FA18_2N6C",
      fa18_3n3: "FA18_3N3",
      // Amino Acids
      amino_his: "AMINO_HIS",
      amino_ile: "AMINO_ILE",
      amino_leu: "AMINO_LEU",
      amino_lys: "AMINO_LYS",
      amino_met: "AMINO_MET",
      amino_phe: "AMINO_PHE",
      amino_thr: "AMINO_THR",
      amino_trp: "AMINO_TRP",
      amino_val: "AMINO_VAL",
      // Other
      ala: "ALA",
      epa_dha: "EPA_DHA",
      la: "LA",
    };

    const codeMap = {};

    // Ưu tiên lấy từ raw_ai_response nếu có
    if (meal.raw_ai_response) {
      try {
        const raw = meal.raw_ai_response;
        const nutrients = Array.isArray(raw.nutrients)
          ? raw.nutrients
          : Array.isArray(raw.items)
          ? raw.items.flatMap((i) => i.nutrients || [])
          : [];
        for (const n of nutrients) {
          const code = (n.nutrient_code || n.code || "").toUpperCase();
          if (!code) continue;
          const amount = Number(n.amount) || 0;
          if (amount > 0) {
            codeMap[code] = amount;
          }
        }
      } catch (e) {
        // ignore parsing errors, we'll fallback to columns
      }
    }

    // Fallback: lấy từ các cột numeric của bảng AI_Analyzed_Meals
    for (const [columnName, nutrientCode] of Object.entries(columnToCodeMap)) {
      if (codeMap[nutrientCode] !== undefined) continue; // Đã có từ raw_ai_response
      const value = meal[columnName];
      if (value !== undefined && value !== null) {
        const numValue = Number(value) || 0;
        if (numValue > 0) {
          codeMap[nutrientCode] = numValue;
        }
      }
    }

    const client = await db.pool.connect();

    try {
      await client.query("BEGIN");

      let newId;
      if (target_type === "dish") {
        const dishInsert = await client.query(
          `
          INSERT INTO Dish (name, vietnamese_name, description, category, serving_size_g, image_url, created_by_admin)
          VALUES ($1, $2, $3, $4, $5, $6, $7)
          RETURNING dish_id
        `,
          [
            meal.item_name,
            meal.item_name,
            "Tạo từ phân tích AI",
            "AI",
            meal.estimated_weight_g || 100,
            meal.image_path || null,
            adminId || null,
          ]
        );
        newId = dishInsert.rows[0].dish_id;

        // Map nutrients sang DishNutrient (per 100g)
        const weight = Number(meal.estimated_weight_g) || 100;
        const nutrientCodes = Object.entries(codeMap);
        for (const [code, amount] of nutrientCodes) {
          if (!amount || amount <= 0) continue;
          const nutRes = await client.query(
            "SELECT nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = $1 LIMIT 1",
            [code]
          );
          if (nutRes.rows.length === 0) continue;
          const nutrientId = nutRes.rows[0].nutrient_id;
          const per100g = (amount * 100) / weight;
          await client.query(
            `
            INSERT INTO DishNutrient (dish_id, nutrient_id, amount_per_100g)
            VALUES ($1, $2, $3)
          `,
            [newId, nutrientId, per100g]
          );
        }
      } else {
        // drink
        const drinkInsert = await client.query(
          `
          INSERT INTO Drink (name, vietnamese_name, description, category, base_liquid, default_volume_ml, image_url, created_by_admin)
          VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
          RETURNING drink_id
        `,
          [
            meal.item_name,
            meal.item_name,
            "Tạo từ phân tích AI",
            "AI",
            "water",
            meal.estimated_volume_ml || 250,
            meal.image_path || null,
            adminId || null,
          ]
        );
        newId = drinkInsert.rows[0].drink_id;

        const volume = Number(meal.estimated_volume_ml) || 250;
        const nutrientCodes = Object.entries(codeMap);
        for (const [code, amount] of nutrientCodes) {
          if (!amount || amount <= 0) continue;
          const nutRes = await client.query(
            "SELECT nutrient_id FROM Nutrient WHERE UPPER(nutrient_code) = $1 LIMIT 1",
            [code]
          );
          if (nutRes.rows.length === 0) continue;
          const nutrientId = nutRes.rows[0].nutrient_id;
          const per100ml = (amount * 100) / volume;
          await client.query(
            `
            INSERT INTO DrinkNutrient (drink_id, nutrient_id, amount_per_100ml)
            VALUES ($1, $2, $3)
          `,
            [newId, nutrientId, per100ml]
          );
        }
      }

      // Đánh dấu promoted (sử dụng ALTER TABLE IF NOT EXISTS để đảm bảo các cột tồn tại)
      try {
        await client.query(`
          ALTER TABLE AI_Analyzed_Meals 
          ADD COLUMN IF NOT EXISTS promoted BOOLEAN DEFAULT FALSE,
          ADD COLUMN IF NOT EXISTS promoted_at TIMESTAMPTZ,
          ADD COLUMN IF NOT EXISTS promoted_by_admin INT,
          ADD COLUMN IF NOT EXISTS linked_dish_id INT,
          ADD COLUMN IF NOT EXISTS linked_drink_id INT
        `);
      } catch (alterErr) {
        // Ignore nếu các cột đã tồn tại
        console.log('[adminAiController] Columns may already exist:', alterErr.message);
      }

      // Update với cast rõ ràng kiểu dữ liệu
      const updatePromoted = await client.query(
        `
        UPDATE AI_Analyzed_Meals
        SET promoted = TRUE,
            promoted_at = NOW(),
            promoted_by_admin = $1::INT
        WHERE id = $2
      `,
        [adminId || null, id]
      );

      // Update linked_dish_id hoặc linked_drink_id tùy theo target_type
      if (target_type === 'dish' && newId != null) {
        await client.query(
          `UPDATE AI_Analyzed_Meals SET linked_dish_id = $1::INT WHERE id = $2`,
          [newId, id]
        );
      } else if (target_type === 'drink' && newId != null) {
        await client.query(
          `UPDATE AI_Analyzed_Meals SET linked_drink_id = $1::INT WHERE id = $2`,
          [newId, id]
        );
      }

      await client.query("COMMIT");

      return res.json({
        success: true,
        target_type,
        new_id: newId,
      });
    } catch (txErr) {
      await client.query("ROLLBACK");
      console.error("[adminAiController] promoteAiMeal tx error:", txErr);
      return res.status(500).json({
        error: "Không thể promote AI meal",
        details: txErr.message,
      });
    } finally {
      client.release();
    }
  } catch (err) {
    console.error("[adminAiController] promoteAiMeal error:", err);
    return res.status(500).json({
      error: "Không thể promote AI meal",
      details: err.message,
    });
  }
}

/**
 * DELETE /admin/ai-meals/:id/reject
 * Từ chối AI meal (xóa hoặc đánh dấu rejected)
 */
async function rejectAiMeal(req, res) {
  const { id } = req.params;
  const adminId = req.admin && req.admin.admin_id;

  try {
    const mealRes = await db.query(
      "SELECT * FROM AI_Analyzed_Meals WHERE id = $1",
      [id]
    );

    if (mealRes.rows.length === 0) {
      return res.status(404).json({ error: "Không tìm thấy AI meal" });
    }

    // Xóa record (hoặc có thể đánh dấu rejected nếu có cột rejected)
    await db.query("DELETE FROM AI_Analyzed_Meals WHERE id = $1", [id]);

    return res.json({
      success: true,
      message: "Đã từ chối AI meal",
    });
  } catch (err) {
    console.error("[adminAiController] rejectAiMeal error:", err);
    return res.status(500).json({
      error: "Không thể từ chối AI meal",
      details: err.message,
    });
  }
}

module.exports = {
  listAiMeals,
  promoteAiMeal,
  rejectAiMeal,
};


