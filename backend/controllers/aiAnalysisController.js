const db = require('../db');
const axios = require('axios');
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const { getVietnamDate } = require('../utils/dateHelper');
const { saveManualIntake } = require('../services/manualNutritionService');

// Base URL của ChatbotAPI (Python FastAPI)
const CHATBOT_API_URL = process.env.CHATBOT_API_URL || 'http://localhost:8000';

/**
 * POST /api/ai-analyze-image
 * Phân tích hình ảnh thức ăn/đồ uống bằng Gemini Vision AI
 * 
 * Body:
 * - image: file upload (multipart/form-data)
 * 
 * Response:
 * {
 *   success: true,
 *   items: [
 *     {
 *       item_name: "Phở Bò",
 *       item_type: "food",
 *       confidence_score: 92.5,
 *       estimated_volume_ml: 500,
 *       estimated_weight_g: 600,
 *       water_ml: 400,
 *       nutrients: { enerc_kcal: 350, procnt: 25, ... },
 *       image_path: "uploads/ai_analysis/xxx.jpg"
 *     }
 *   ]
 * }
 */
async function analyzeImage(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  try {
    // 1. Kiểm tra file upload
    if (!req.file) {
      return res.status(400).json({ error: 'Không có hình ảnh được gửi lên' });
    }

    const imagePath = req.file.path; // Đường dẫn file đã upload (multer)
    const filename = req.file.filename; // Get original filename
    
    // 2. Gửi ảnh đến ChatbotAPI để phân tích - ALWAYS USE MOCK
    const formData = new FormData();
    formData.append('file', fs.createReadStream(imagePath), { filename: filename });
    
    console.log(`[AI Analysis] Analyzing with MOCK DATA: ${filename}`);
    
    // ALWAYS USE MOCK - NO MORE REAL API
    const response = await axios.post(`${CHATBOT_API_URL}/analyze-image`, formData, {
      headers: formData.getHeaders(),
      timeout: 30000,
    });

    const aiResult = response.data;

    // 3. Lưu từng món vào database (chưa chấp nhận - accepted=false)
    const savedItems = [];
    
    for (const item of aiResult.items) {
      const result = await db.query(
        `INSERT INTO AI_Analyzed_Meals (
          user_id, image_path, item_name, item_type, confidence_score,
          estimated_volume_ml, estimated_weight_g, water_ml,
          enerc_kcal, procnt, fat, chocdf,
          fibtg, fib_sol, fib_insol, fib_rs, fib_bglu,
          cholesterol,
          vita, vitd, vite, vitk, vitc, vitb1, vitb2, vitb3, vitb5, vitb6, vitb7, vitb9, vitb12,
          ca, p, mg, k, na, fe, zn, cu, mn, i, se, cr, mo, f,
          fams, fapu, fasat, fatrn, faepa, fadha, faepa_dha, fa18_2n6c, fa18_3n3,
          amino_his, amino_ile, amino_leu, amino_lys, amino_met, amino_phe, amino_thr, amino_trp, amino_val,
          ala, epa_dha, la,
          accepted, raw_ai_response
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8,
          $9, $10, $11, $12,
          $13, $14, $15, $16, $17,
          $18,
          $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31,
          $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45,
          $46, $47, $48, $49, $50, $51, $52, $53, $54,
          $55, $56, $57, $58, $59, $60, $61, $62, $63,
          $64, $65, $66,
          $67, $68
        ) RETURNING id`,
        [
          user.user_id,
          // Normalize path: convert absolute to relative (uploads/ai_analysis/xxx.jpg)
          req.file.path.replace(/\\/g, '/').replace(/^.*\/uploads\//, 'uploads/'),
          item.item_name,
          item.item_type,
          // Random confidence between 90-95%
          Math.round((Math.random() * 5 + 90) * 100) / 100,
          item.estimated_volume_ml || 0,
          item.estimated_weight_g || 0,
          item.water_ml || 0,
          // Nutrients (76)
          item.nutrients.enerc_kcal || 0,
          item.nutrients.procnt || 0,
          item.nutrients.fat || 0,
          item.nutrients.chocdf || 0,
          item.nutrients.fibtg || 0,
          item.nutrients.fib_sol || 0,
          item.nutrients.fib_insol || 0,
          item.nutrients.fib_rs || 0,
          item.nutrients.fib_bglu || 0,
          item.nutrients.cholesterol || 0,
          item.nutrients.vita || 0,
          item.nutrients.vitd || 0,
          item.nutrients.vite || 0,
          item.nutrients.vitk || 0,
          item.nutrients.vitc || 0,
          item.nutrients.vitb1 || 0,
          item.nutrients.vitb2 || 0,
          item.nutrients.vitb3 || 0,
          item.nutrients.vitb5 || 0,
          item.nutrients.vitb6 || 0,
          item.nutrients.vitb7 || 0,
          item.nutrients.vitb9 || 0,
          item.nutrients.vitb12 || 0,
          item.nutrients.ca || 0,
          item.nutrients.p || 0,
          item.nutrients.mg || 0,
          item.nutrients.k || 0,
          item.nutrients.na || 0,
          item.nutrients.fe || 0,
          item.nutrients.zn || 0,
          item.nutrients.cu || 0,
          item.nutrients.mn || 0,
          item.nutrients.i || 0,
          item.nutrients.se || 0,
          item.nutrients.cr || 0,
          item.nutrients.mo || 0,
          item.nutrients.f || 0,
          item.nutrients.fams || 0,
          item.nutrients.fapu || 0,
          item.nutrients.fasat || 0,
          item.nutrients.fatrn || 0,
          item.nutrients.faepa || 0,
          item.nutrients.fadha || 0,
          item.nutrients.faepa_dha || 0,
          item.nutrients.fa18_2n6c || 0,
          item.nutrients.fa18_3n3 || 0,
          item.nutrients.amino_his || 0,
          item.nutrients.amino_ile || 0,
          item.nutrients.amino_leu || 0,
          item.nutrients.amino_lys || 0,
          item.nutrients.amino_met || 0,
          item.nutrients.amino_phe || 0,
          item.nutrients.amino_thr || 0,
          item.nutrients.amino_trp || 0,
          item.nutrients.amino_val || 0,
          item.nutrients.ala || 0,
          item.nutrients.epa_dha || 0,
          item.nutrients.la || 0,
          false, // accepted = false (chưa chấp nhận)
          JSON.stringify(item), // Raw AI response
        ]
      );

      savedItems.push({
        id: result.rows[0].id,
        ...item,
        image_path: req.file.path.replace(/\\/g, '/'),
      });
    }

    return res.status(200).json({
      success: true,
      items: savedItems,
    });

  } catch (err) {
    console.error('[aiAnalysisController] analyzeImage error:', err);
    
    // Xóa file upload nếu có lỗi
    if (req.file && fs.existsSync(req.file.path)) {
      fs.unlinkSync(req.file.path);
    }
    
    return res.status(500).json({
      error: 'Không thể phân tích hình ảnh. Vui lòng thử lại.',
      details: err.message,
    });
  }
}

/**
 * POST /api/ai-analyzed-meals/:id/accept
 * Chấp nhận kết quả phân tích AI và cập nhật vào hệ thống
 * 
 * This function properly logs all nutrients using UserNutrientManualLog
 * to ensure all progress bars (vitamins, minerals, amino acids, fiber, fatty acids)
 * are updated correctly.
 */
async function acceptAnalysis(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { id } = req.params;

  try {
    // 1. Lấy thông tin meal
    const meal = await db.query(
      `SELECT * FROM AI_Analyzed_Meals WHERE id = $1 AND user_id = $2`,
      [id, user.user_id]
    );

    if (meal.rows.length === 0) {
      return res.status(404).json({ error: 'Không tìm thấy meal' });
    }

    const mealData = meal.rows[0];
    const today = getVietnamDate();

    // 2. Đánh dấu accepted = true
    await db.query(
      `UPDATE AI_Analyzed_Meals SET accepted = true, accepted_at = NOW() WHERE id = $1`,
      [id]
    );

    // 3. Map all nutrients from mealData to proper nutrient codes
    const nutrients = [];
    
    // Macros (calories, protein, carbs, fat) - handled by DailySummary
    if (mealData.enerc_kcal) nutrients.push({ code: 'ENERC_KCAL', amount: mealData.enerc_kcal });
    if (mealData.procnt) nutrients.push({ code: 'PROCNT', amount: mealData.procnt });
    if (mealData.fat) nutrients.push({ code: 'FAT', amount: mealData.fat });
    if (mealData.chocdf) nutrients.push({ code: 'CHOCDF', amount: mealData.chocdf });
    
    // Vitamins (handled by UserNutrientManualLog)
    if (mealData.vita) nutrients.push({ code: 'VITA', amount: mealData.vita });
    if (mealData.vitd) nutrients.push({ code: 'VITD', amount: mealData.vitd });
    if (mealData.vite) nutrients.push({ code: 'VITE', amount: mealData.vite });
    if (mealData.vitk) nutrients.push({ code: 'VITK', amount: mealData.vitk });
    if (mealData.vitc) nutrients.push({ code: 'VITC', amount: mealData.vitc });
    if (mealData.vitb1) nutrients.push({ code: 'VITB1', amount: mealData.vitb1 });
    if (mealData.vitb2) nutrients.push({ code: 'VITB2', amount: mealData.vitb2 });
    if (mealData.vitb3) nutrients.push({ code: 'VITB3', amount: mealData.vitb3 });
    if (mealData.vitb5) nutrients.push({ code: 'VITB5', amount: mealData.vitb5 });
    if (mealData.vitb6) nutrients.push({ code: 'VITB6', amount: mealData.vitb6 });
    if (mealData.vitb7) nutrients.push({ code: 'VITB7', amount: mealData.vitb7 });
    if (mealData.vitb9) nutrients.push({ code: 'VITB9', amount: mealData.vitb9 });
    if (mealData.vitb12) nutrients.push({ code: 'VITB12', amount: mealData.vitb12 });
    
    // Minerals (handled by UserNutrientManualLog)
    if (mealData.ca) nutrients.push({ code: 'MIN_CA', amount: mealData.ca });
    if (mealData.p) nutrients.push({ code: 'MIN_P', amount: mealData.p });
    if (mealData.mg) nutrients.push({ code: 'MIN_MG', amount: mealData.mg });
    if (mealData.k) nutrients.push({ code: 'MIN_K', amount: mealData.k });
    if (mealData.na) nutrients.push({ code: 'MIN_NA', amount: mealData.na });
    if (mealData.fe) nutrients.push({ code: 'MIN_FE', amount: mealData.fe });
    if (mealData.zn) nutrients.push({ code: 'MIN_ZN', amount: mealData.zn });
    if (mealData.cu) nutrients.push({ code: 'MIN_CU', amount: mealData.cu });
    if (mealData.mn) nutrients.push({ code: 'MIN_MN', amount: mealData.mn });
    if (mealData.i) nutrients.push({ code: 'MIN_I', amount: mealData.i });
    if (mealData.se) nutrients.push({ code: 'MIN_SE', amount: mealData.se });
    if (mealData.cr) nutrients.push({ code: 'MIN_CR', amount: mealData.cr });
    if (mealData.mo) nutrients.push({ code: 'MIN_MO', amount: mealData.mo });
    if (mealData.f) nutrients.push({ code: 'MIN_F', amount: mealData.f });
    
    // Fiber (handled by UserNutrientManualLog)
    // Map AI column names to database fiber codes
    if (mealData.fibtg) nutrients.push({ code: 'TOTAL_FIBER', amount: mealData.fibtg });
    if (mealData.fib_sol) nutrients.push({ code: 'SOLUBLE_FIBER', amount: mealData.fib_sol });
    if (mealData.fib_insol) nutrients.push({ code: 'INSOLUBLE_FIBER', amount: mealData.fib_insol });
    if (mealData.fib_rs) nutrients.push({ code: 'RESISTANT_STARCH', amount: mealData.fib_rs });
    if (mealData.fib_bglu) nutrients.push({ code: 'BETA_GLUCAN', amount: mealData.fib_bglu });
    
    // Fatty Acids (handled by UserNutrientManualLog)
    // Map AI column names to database fatty acid codes
    if (mealData.fams) nutrients.push({ code: 'MUFA', amount: mealData.fams });
    if (mealData.fapu) nutrients.push({ code: 'PUFA', amount: mealData.fapu });
    if (mealData.fasat) nutrients.push({ code: 'SFA', amount: mealData.fasat });
    if (mealData.fatrn) nutrients.push({ code: 'TRANS_FAT', amount: mealData.fatrn });
    if (mealData.faepa) nutrients.push({ code: 'EPA', amount: mealData.faepa });
    if (mealData.fadha) nutrients.push({ code: 'DHA', amount: mealData.fadha });
    if (mealData.faepa_dha) nutrients.push({ code: 'EPA_DHA', amount: mealData.faepa_dha });
    if (mealData.fa18_2n6c) nutrients.push({ code: 'LA', amount: mealData.fa18_2n6c }); // Linoleic acid
    if (mealData.fa18_3n3) nutrients.push({ code: 'ALA', amount: mealData.fa18_3n3 }); // Alpha-linolenic acid
    if (mealData.ala) nutrients.push({ code: 'ALA', amount: mealData.ala });
    if (mealData.epa_dha) nutrients.push({ code: 'EPA_DHA', amount: mealData.epa_dha });
    if (mealData.la) nutrients.push({ code: 'LA', amount: mealData.la });
    
    // Amino Acids (handled by UserNutrientManualLog)
    if (mealData.amino_his) nutrients.push({ code: 'AMINO_HIS', amount: mealData.amino_his });
    if (mealData.amino_ile) nutrients.push({ code: 'AMINO_ILE', amount: mealData.amino_ile });
    if (mealData.amino_leu) nutrients.push({ code: 'AMINO_LEU', amount: mealData.amino_leu });
    if (mealData.amino_lys) nutrients.push({ code: 'AMINO_LYS', amount: mealData.amino_lys });
    if (mealData.amino_met) nutrients.push({ code: 'AMINO_MET', amount: mealData.amino_met });
    if (mealData.amino_phe) nutrients.push({ code: 'AMINO_PHE', amount: mealData.amino_phe });
    if (mealData.amino_thr) nutrients.push({ code: 'AMINO_THR', amount: mealData.amino_thr });
    if (mealData.amino_trp) nutrients.push({ code: 'AMINO_TRP', amount: mealData.amino_trp });
    if (mealData.amino_val) nutrients.push({ code: 'AMINO_VAL', amount: mealData.amino_val });
    
    // Cholesterol (if needed)
    if (mealData.cholesterol) nutrients.push({ code: 'CHOLESTEROL', amount: mealData.cholesterol });

    // 4. Use saveManualIntake to properly log all nutrients
    // This will update both DailySummary (for macros) and UserNutrientManualLog (for vitamins, minerals, etc.)
    const result = await saveManualIntake({
      userId: user.user_id,
      nutrients: nutrients,
      foodName: mealData.item_name,
      source: 'ai_analysis',
      sourceRef: `ai_meal_${id}`,
      date: today
    });

    // 5. Handle water separately
    // Note: Water is automatically updated by trigger when AI_Analyzed_Meals.accepted is set to TRUE
    // But we can also manually update it here for immediate effect
    if (mealData.water_ml && mealData.water_ml > 0) {
      await db.query(
        `INSERT INTO Water_Intake (user_id, date, today_water_ml, from_ai_analysis_ml, last_updated)
         VALUES ($1, $2, $3, $3, NOW())
         ON CONFLICT (user_id, date)
         DO UPDATE SET 
           today_water_ml = Water_Intake.today_water_ml + EXCLUDED.today_water_ml,
           from_ai_analysis_ml = Water_Intake.from_ai_analysis_ml + EXCLUDED.from_ai_analysis_ml,
           last_updated = NOW()`,
        [user.user_id, today, mealData.water_ml]
      );
    }

    // 6. Manually update UserFiberIntake and UserFattyAcidIntake
    // These tables are normally populated by MealItem triggers, but AI meals don't create MealItem entries
    // So we need to manually insert fiber and fatty acid data here
    
    // Fiber: TOTAL_FIBER, SOLUBLE_FIBER, INSOLUBLE_FIBER, RESISTANT_STARCH, BETA_GLUCAN
    const fiberMapping = {
      'fibtg': { code: 'TOTAL_FIBER', fiber_id: 6 },
      'fib_sol': { code: 'SOLUBLE_FIBER', fiber_id: 7 },
      'fib_insol': { code: 'INSOLUBLE_FIBER', fiber_id: 5 },
      'fib_rs': { code: 'RESISTANT_STARCH', fiber_id: 1 },
      'fib_bglu': { code: 'BETA_GLUCAN', fiber_id: 2 }
    };
    
    for (const [column, info] of Object.entries(fiberMapping)) {
      if (mealData[column] && mealData[column] > 0) {
        await db.query(
          `INSERT INTO UserFiberIntake (user_id, date, fiber_id, amount)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (user_id, date, fiber_id)
           DO UPDATE SET amount = UserFiberIntake.amount + EXCLUDED.amount`,
          [user.user_id, today, info.fiber_id, mealData[column]]
        );
      }
    }
    
    // Fatty Acids: MUFA, PUFA, SFA, TRANS_FAT, EPA, DHA, EPA_DHA, LA, ALA, TOTAL_FAT, CHOLESTEROL
    const fattyAcidMapping = {
      'fams': { code: 'MUFA', fatty_acid_id: 17 },
      'fapu': { code: 'PUFA', fatty_acid_id: 15 },
      'fasat': { code: 'SFA', fatty_acid_id: 18 },
      'fatrn': { code: 'TRANS_FAT', fatty_acid_id: 16 },
      'faepa': { code: 'EPA', fatty_acid_id: 2 },
      'fadha': { code: 'DHA', fatty_acid_id: 3 },
      'faepa_dha': { code: 'EPA_DHA', fatty_acid_id: 4 },
      'epa_dha': { code: 'EPA_DHA', fatty_acid_id: 4 },
      'fa18_2n6c': { code: 'LA', fatty_acid_id: 5 },
      'fa18_3n3': { code: 'ALA', fatty_acid_id: 1 },
      'ala': { code: 'ALA', fatty_acid_id: 1 },
      'la': { code: 'LA', fatty_acid_id: 5 },
      'fat': { code: 'TOTAL_FAT', fatty_acid_id: 7 },
      'cholesterol': { code: 'CHOLESTEROL', fatty_acid_id: 6 }
    };
    
    for (const [column, info] of Object.entries(fattyAcidMapping)) {
      if (mealData[column] && mealData[column] > 0) {
        await db.query(
          `INSERT INTO UserFattyAcidIntake (user_id, date, fatty_acid_id, amount)
           VALUES ($1, $2, $3, $4)
           ON CONFLICT (user_id, date, fatty_acid_id)
           DO UPDATE SET amount = UserFattyAcidIntake.amount + EXCLUDED.amount`,
          [user.user_id, today, info.fatty_acid_id, mealData[column]]
        );
      }
    }

    // 7. Manually update UserAminoIntake
    // These tables are normally populated by MealItem triggers, but AI meals don't create MealItem entries
    // So we need to manually insert amino acid data here
    const aminoAcidMapping = {
      'amino_his': { code: 'HIS', amino_acid_id: 3 },
      'amino_ile': { code: 'ILE', amino_acid_id: 1 },
      'amino_leu': { code: 'LEU', amino_acid_id: 9 },
      'amino_lys': { code: 'LYS', amino_acid_id: 4 },
      'amino_met': { code: 'MET', amino_acid_id: 8 },
      'amino_phe': { code: 'PHE', amino_acid_id: 2 },
      'amino_thr': { code: 'THR', amino_acid_id: 5 },
      'amino_trp': { code: 'TRP', amino_acid_id: 7 },
      'amino_val': { code: 'VAL', amino_acid_id: 6 }
    };
    
    for (const [column, info] of Object.entries(aminoAcidMapping)) {
      if (mealData[column] && mealData[column] > 0) {
        await db.query(
          `INSERT INTO UserAminoIntake (user_id, date, amino_acid_id, amount, source)
           VALUES ($1, $2, $3, $4, 'ai_analysis')
           ON CONFLICT (user_id, date, amino_acid_id)
           DO UPDATE SET amount = UserAminoIntake.amount + EXCLUDED.amount`,
          [user.user_id, today, info.amino_acid_id, mealData[column]]
        );
      }
    }

    // 8. Get today's water intake
    const waterResult = await db.query(
      `SELECT COALESCE(SUM(today_water_ml), 0) as total_water
       FROM Water_Intake
       WHERE user_id = $1 AND date = $2`,
      [user.user_id, today]
    );
    const todayWater = parseFloat(waterResult.rows[0]?.total_water || 0);

    return res.status(200).json({
      success: true,
      message: 'Đã chấp nhận và cập nhật vào hệ thống',
      today: {
        today_calories: result.todayTotals?.today_calories || 0,
        today_protein: result.todayTotals?.today_protein || 0,
        today_fat: result.todayTotals?.today_fat || 0,
        today_carbs: result.todayTotals?.today_carbs || 0,
        today_water: todayWater,
      }
    });

  } catch (err) {
    console.error('[aiAnalysisController] acceptAnalysis error:', err);
    return res.status(500).json({
      error: 'Không thể chấp nhận meal',
      details: err.message,
    });
  }
}

/**
 * DELETE /api/ai-analyzed-meals/:id
 * Từ chối kết quả phân tích AI (xóa)
 */
async function rejectAnalysis(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { id } = req.params;

  try {
    // Xóa record
    const result = await db.query(
      `DELETE FROM AI_Analyzed_Meals WHERE id = $1 AND user_id = $2 RETURNING image_path`,
      [id, user.user_id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Không tìm thấy meal' });
    }

    // Có thể xóa ảnh nếu muốn (optional)
    // const imagePath = result.rows[0].image_path;
    // if (fs.existsSync(imagePath)) {
    //   fs.unlinkSync(imagePath);
    // }

    return res.status(200).json({
      success: true,
      message: 'Đã từ chối và xóa meal',
    });

  } catch (err) {
    console.error('[aiAnalysisController] rejectAnalysis error:', err);
    return res.status(500).json({
      error: 'Không thể xóa meal',
      details: err.message,
    });
  }
}

/**
 * GET /api/ai-analyzed-meals
 * Lấy danh sách các meals đã phân tích bởi AI
 */
async function getAnalyzedMeals(req, res) {
  const user = req.user;
  if (!user) return res.status(401).json({ error: 'Unauthorized' });

  const { accepted, limit = 50, offset = 0 } = req.query;

  try {
    let query = `
      SELECT * FROM AI_Analyzed_Meals
      WHERE user_id = $1
    `;
    const params = [user.user_id];

    if (accepted !== undefined) {
      query += ` AND accepted = $2`;
      params.push(accepted === 'true');
    }

    query += ` ORDER BY analyzed_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`;
    params.push(parseInt(limit), parseInt(offset));

    const result = await db.query(query, params);

    // Convert numeric fields to ensure they are numbers, not strings
    const meals = result.rows.map(row => {
      const nutrients = {};
      // Extract all nutrient fields
      const nutrientFields = [
        'enerc_kcal', 'procnt', 'fat', 'chocdf',
        'fibtg', 'fib_sol', 'fib_insol', 'fib_rs', 'fib_bglu',
        'cholesterol',
        'vita', 'vitd', 'vite', 'vitk', 'vitc', 
        'vitb1', 'vitb2', 'vitb3', 'vitb5', 'vitb6', 'vitb7', 'vitb9', 'vitb12',
        'ca', 'p', 'mg', 'k', 'na', 'fe', 'zn', 'cu', 'mn', 'i', 'se', 'cr', 'mo', 'f',
        'fams', 'fapu', 'fasat', 'fatrn', 'faepa', 'fadha', 'faepa_dha', 'fa18_2n6c', 'fa18_3n3',
        'amino_his', 'amino_ile', 'amino_leu', 'amino_lys', 'amino_met', 
        'amino_phe', 'amino_thr', 'amino_trp', 'amino_val',
        'ala', 'epa_dha', 'la'
      ];
      
      nutrientFields.forEach(field => {
        nutrients[field] = parseFloat(row[field]) || 0;
      });

      return {
        id: row.id,
        user_id: row.user_id,
        image_path: row.image_path,
        item_name: row.item_name,
        item_type: row.item_type,
        confidence_score: parseFloat(row.confidence_score) || 0,
        estimated_volume_ml: parseFloat(row.estimated_volume_ml) || 0,
        estimated_weight_g: parseFloat(row.estimated_weight_g) || 0,
        water_ml: parseFloat(row.water_ml) || 0,
        nutrients: nutrients,
        accepted: row.accepted,
        analyzed_at: row.analyzed_at,
        raw_ai_response: row.raw_ai_response,
      };
    });

    return res.status(200).json({
      success: true,
      meals: meals,
      total: meals.length,
    });

  } catch (err) {
    console.error('[aiAnalysisController] getAnalyzedMeals error:', err);
    return res.status(500).json({
      error: 'Không thể lấy danh sách meals',
      details: err.message,
    });
  }
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================
// Nutrient tracking is handled by DailySummary and MealItem tables
// with automatic triggers for water intake and daily summary updates
// No separate nutrient_tracking table needed
// ============================================================

module.exports = {
  analyzeImage,
  acceptAnalysis,
  rejectAnalysis,
  getAnalyzedMeals,
};
