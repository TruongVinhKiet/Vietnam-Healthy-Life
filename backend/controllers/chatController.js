const db = require('../db');
const axios = require('axios');
const FormData = require('form-data');
const manualNutritionService = require('../services/manualNutritionService');
const { toVietnamDate, getVietnamDate } = require('../utils/dateHelper');

// Chatbot API base URL
const CHATBOT_API_URL = process.env.CHATBOT_API_URL || 'http://localhost:8000';

/**
 * Get or create chatbot conversation for user
 */
exports.getOrCreateConversation = async (req, res) => {
  try {
    if (!req.user || !req.user.user_id) {
      return res.status(401).json({ error: 'Authentication required' });
    }
    const userId = req.user.user_id;

    // Try to get most recent conversation
    let result = await db.query(
      `SELECT 
         conversation_id, 
         title, 
         created_at AT TIME ZONE 'UTC' AS created_at,
         updated_at AT TIME ZONE 'UTC' AS updated_at
       FROM ChatbotConversation 
       WHERE user_id = $1 
       ORDER BY updated_at DESC 
       LIMIT 1`,
      [userId]
    );

    if (result.rows.length === 0) {
      // Create new conversation
      result = await db.query(
        `INSERT INTO ChatbotConversation (user_id, title) 
         VALUES ($1, 'New conversation') 
         RETURNING 
           conversation_id, 
           title, 
           created_at AT TIME ZONE 'UTC' AS created_at,
           updated_at AT TIME ZONE 'UTC' AS updated_at`,
        [userId]
      );
    }

    res.json({ conversation: result.rows[0] });
  } catch (error) {
    console.error('Error getting/creating conversation:', error);
    res.status(500).json({ error: 'Failed to get conversation' });
  }
};

/**
 * Get messages for a conversation
 */
exports.getMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.user_id;

    // Verify conversation belongs to user
    const convCheck = await db.query(
      'SELECT 1 FROM ChatbotConversation WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const result = await db.query(
      `SELECT 
         message_id, 
         sender, 
         message_text, 
         image_url, 
         nutrition_data, 
         is_approved, 
         created_at AT TIME ZONE 'UTC' AS created_at
       FROM ChatbotMessage
       WHERE conversation_id = $1
       ORDER BY created_at ASC`,
      [conversationId]
    );

    res.json({ messages: result.rows });
  } catch (error) {
    console.error('Error getting messages:', error);
    res.status(500).json({ error: 'Failed to get messages' });
  }
};

/**
 * Send text message to chatbot
 */
exports.sendMessage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { message } = req.body;
    const userId = req.user.user_id;

    // Verify conversation belongs to user
    const convCheck = await db.query(
      'SELECT 1 FROM ChatbotConversation WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Save user message
    const userMsg = await db.query(
      `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
       VALUES ($1, 'user', $2)
       RETURNING 
         message_id, 
         sender, 
         message_text, 
         created_at AT TIME ZONE 'UTC' AS created_at`,
      [conversationId, message]
    );

    // Get conversation history for context
    const history = await db.query(
      `SELECT sender, message_text 
       FROM ChatbotMessage 
       WHERE conversation_id = $1 
       ORDER BY created_at ASC 
       LIMIT 20`,
      [conversationId]
    );

    // Call chatbot API
    try {
      const chatResponse = await axios.post(`${CHATBOT_API_URL}/chat`, {
        question: message,
        history: history.rows.map(m => ({
          role: m.sender === 'user' ? 'user' : 'assistant',
          content: m.message_text
        }))
      });

      const botReply = chatResponse.data.answer || chatResponse.data.response || 'Xin lỗi, tôi không thể xử lý yêu cầu này.';

      // Save bot response
      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
         VALUES ($1, 'bot', $2)
         RETURNING 
           message_id, 
           sender, 
           message_text, 
           created_at AT TIME ZONE 'UTC' AS created_at`,
        [conversationId, botReply]
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0]
      });
    } catch (chatError) {
      console.error('Chatbot API error:', chatError);
      
      // Fallback response
      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
         VALUES ($1, 'bot', $2)
         RETURNING 
           message_id, 
           sender, 
           message_text, 
           created_at AT TIME ZONE 'UTC' AS created_at`,
        [conversationId, 'I apologize, I am temporarily unavailable. Please try again later.']
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0]
      });
    }
  } catch (error) {
    console.error('Error sending message:', error);
    res.status(500).json({ error: 'Failed to send message' });
  }
};

/**
 * Analyze food image with AI
 */
exports.analyzeFoodImage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const userId = req.user.user_id;
    const { image } = req.body; // base64 image

    if (!image) {
      return res.status(400).json({ error: 'No image provided' });
    }

    // Verify conversation belongs to user
    const convCheck = await db.query(
      'SELECT 1 FROM ChatbotConversation WHERE conversation_id = $1 AND user_id = $2',
      [conversationId, userId]
    );

    if (convCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    // Convert base64 to buffer and save as file
    const fs = require('fs');
    const path = require('path');
    const buffer = Buffer.from(image, 'base64');
    // Use original filename from request if provided, otherwise fallback to timestamp
    const filename = req.body.filename || `food-${Date.now()}.jpg`;
    const filepath = path.join('uploads', 'chat', filename);
    
    // Ensure directory exists
    const dir = path.dirname(filepath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
    
    fs.writeFileSync(filepath, buffer);

    // Save user message with image
    const imageUrl = `/uploads/chat/${filename}`;
    const userMsg = await db.query(
      `INSERT INTO ChatbotMessage (conversation_id, sender, message_text, image_url)
       VALUES ($1, 'user', 'Phân tích dinh dưỡng ảnh này', $2)
       RETURNING 
         message_id, 
         sender, 
         message_text, 
         image_url, 
         created_at AT TIME ZONE 'UTC' AS created_at`,
      [conversationId, imageUrl]
    );

    // Call AI nutrition analysis - NOW USING MOCK ONLY
    try {
      const FormData = require('form-data');
      const formData = new FormData();
      formData.append('file', buffer, { filename: filename, contentType: 'image/jpeg' });

      console.log(`[Chatbot] Analyzing image with MOCK DATA: ${filename}`);
      
      // ALWAYS USE MOCK - NO MORE REAL API
      const analysisResponse = await axios.post(
        `${CHATBOT_API_URL}/analyze-nutrition`,
        formData,
        {
          headers: formData.getHeaders(),
          timeout: 30000
        }
      );

      const analysis = analysisResponse.data;

      if (!analysis.is_food) {
        // Not food - save bot rejection message
        const botMsg = await db.query(
          `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
           VALUES ($1, 'bot', $2)
           RETURNING 
             message_id, 
             sender, 
             message_text, 
             created_at AT TIME ZONE 'UTC' AS created_at`,
          [conversationId, 'Xin lỗi, tôi không nhận diện được thực phẩm trong ảnh này. Vui lòng thử lại với ảnh món ăn rõ ràng hơn.']
        );

        return res.json({
          userMessage: userMsg.rows[0],
          botMessage: botMsg.rows[0],
          isFood: false
        });
      }

      // Save nutrition analysis (no message_text, only nutrition_data)
      const nutritionData = {
        food_name: analysis.food_name,
        confidence: analysis.confidence,
        nutrients: analysis.nutrients
      };

      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, nutrition_data)
         VALUES ($1, 'bot', $2)
         RETURNING 
           message_id, 
           sender, 
           message_text, 
           nutrition_data, 
           created_at AT TIME ZONE 'UTC' AS created_at`,
        [
          conversationId,
          JSON.stringify(nutritionData)
        ]
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0],
        isFood: true,
        nutritionData
      });
    } catch (aiError) {
      console.error('AI analysis error:', aiError);
      
      const botMsg = await db.query(
        `INSERT INTO ChatbotMessage (conversation_id, sender, message_text)
         VALUES ($1, 'bot', $2)
         RETURNING 
           message_id, 
           sender, 
           message_text, 
           created_at AT TIME ZONE 'UTC' AS created_at`,
        [conversationId, 'Xin lỗi, đã có lỗi xảy ra khi phân tích ảnh. Vui lòng thử lại.']
      );

      res.json({
        userMessage: userMsg.rows[0],
        botMessage: botMsg.rows[0],
        isFood: false,
        error: 'Analysis failed'
      });
    }
  } catch (error) {
    console.error('Error analyzing food image:', error);
    res.status(500).json({ error: 'Failed to analyze image' });
  }
};

/**
 * Approve or reject nutrition analysis
 */
exports.approveNutrition = async (req, res) => {
  try {
    const { messageId } = req.params;
    const { approved } = req.body;
    const userId = req.user.user_id;

    // Get message with nutrition data
    const msgResult = await db.query(
      `SELECT cm.*, cc.user_id
       FROM ChatbotMessage cm
       JOIN ChatbotConversation cc ON cc.conversation_id = cm.conversation_id
       WHERE cm.message_id = $1`,
      [messageId]
    );

    if (msgResult.rows.length === 0) {
      return res.status(404).json({ error: 'Message not found' });
    }

    const message = msgResult.rows[0];

    if (message.user_id !== userId) {
      return res.status(403).json({ error: 'Access denied' });
    }

    if (!message.nutrition_data) {
      return res.status(400).json({ error: 'No nutrition data in this message' });
    }

    // Update approval status
    await db.query(
      'UPDATE ChatbotMessage SET is_approved = $1 WHERE message_id = $2',
      [approved, messageId]
    );

    if (approved) {
      const nutritionData = message.nutrition_data || {};
      const manualResult = await manualNutritionService.saveManualIntake({
        userId,
        nutrients: nutritionData.nutrients || [],
        foodName: nutritionData.food_name,
        source: 'chatbot',
        sourceRef: String(messageId),
        date: message.created_at
          ? toVietnamDate(new Date(message.created_at))
          : undefined
      });

      // Đồng bộ vào bảng AI_Analyzed_Meals để dùng cho thống kê AI & quản lý AI
      try {
        const nutrients = Array.isArray(nutritionData.nutrients)
          ? nutritionData.nutrients
          : [];

        const byCode = {};
        for (const n of nutrients) {
          const rawCode = n.nutrient_code || n.code || '';
          const code = rawCode.toLowerCase();
          if (!code) continue;
          const amount = Number(n.amount) || 0;
          byCode[code] = amount;
        }

        const itemName =
          nutritionData.food_name ||
          nutritionData.item_name ||
          message.message_text ||
          'Món ăn từ chatbot';
        const itemType =
          (nutritionData.item_type && String(nutritionData.item_type)) ||
          'food';
        const confidence =
          typeof nutritionData.confidence === 'number'
            ? nutritionData.confidence * 100
            : 90;
        const estimatedWeight =
          typeof nutritionData.estimated_weight_g === 'number'
            ? nutritionData.estimated_weight_g
            : 0;
        const estimatedVolume =
          typeof nutritionData.estimated_volume_ml === 'number'
            ? nutritionData.estimated_volume_ml
            : 0;
        const waterMl =
          typeof nutritionData.water_ml === 'number'
            ? nutritionData.water_ml
            : byCode['water'] || 0;

        await db.query(
          `
          INSERT INTO AI_Analyzed_Meals (
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
            notes, raw_ai_response,
            source, source_ref
          ) VALUES (
            $1, $2, $3, $4, $5,
            $6, $7, $8,
            $9, $10, $11, $12,
            $13, $14, $15, $16, $17,
            $18,
            $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31,
            $32, $33, $34, $35, $36, $37, $38, $39, $40, $41, $42, $43, $44, $45,
            $46, $47, $48, $49, $50, $51, $52, $53, $54,
            $55, $56, $57, $58, $59, $60, $61, $62, $63,
            $64, $65, $66,
            $67, $68,
            $69, $70
          )
        `,
          [
            userId,
            nutritionData.image_path || '',
            itemName,
            itemType,
            confidence,
            estimatedVolume,
            estimatedWeight,
            waterMl,
            byCode['enerc_kcal'] || 0,
            byCode['procnt'] || 0,
            byCode['fat'] || 0,
            byCode['chocdf'] || 0,
            byCode['fibtg'] || 0,
            byCode['fib_sol'] || 0,
            byCode['fib_insol'] || 0,
            byCode['fib_rs'] || 0,
            byCode['fib_bglu'] || 0,
            byCode['cholesterol'] || 0,
            byCode['vita'] || 0,
            byCode['vitd'] || 0,
            byCode['vite'] || 0,
            byCode['vitk'] || 0,
            byCode['vitc'] || 0,
            byCode['vitb1'] || 0,
            byCode['vitb2'] || 0,
            byCode['vitb3'] || 0,
            byCode['vitb5'] || 0,
            byCode['vitb6'] || 0,
            byCode['vitb7'] || 0,
            byCode['vitb9'] || 0,
            byCode['vitb12'] || 0,
            byCode['ca'] || 0,
            byCode['p'] || 0,
            byCode['mg'] || 0,
            byCode['k'] || 0,
            byCode['na'] || 0,
            byCode['fe'] || 0,
            byCode['zn'] || 0,
            byCode['cu'] || 0,
            byCode['mn'] || 0,
            byCode['i'] || 0,
            byCode['se'] || 0,
            byCode['cr'] || 0,
            byCode['mo'] || 0,
            byCode['f'] || 0,
            byCode['fams'] || 0,
            byCode['fapu'] || 0,
            byCode['fasat'] || 0,
            byCode['fatrn'] || 0,
            byCode['faepa'] || 0,
            byCode['fadha'] || 0,
            byCode['faepa_dha'] || 0,
            byCode['fa18_2n6c'] || 0,
            byCode['fa18_3n3'] || 0,
            byCode['amino_his'] || 0,
            byCode['amino_ile'] || 0,
            byCode['amino_leu'] || 0,
            byCode['amino_lys'] || 0,
            byCode['amino_met'] || 0,
            byCode['amino_phe'] || 0,
            byCode['amino_thr'] || 0,
            byCode['amino_trp'] || 0,
            byCode['amino_val'] || 0,
            byCode['ala'] || 0,
            byCode['epa_dha'] || 0,
            byCode['la'] || 0,
            'Approved from chatbot message',
            JSON.stringify(nutritionData),
            'chatbot',
            String(messageId)
          ]
        );
      } catch (mirrorErr) {
        // Không chặn luồng chính nếu ghi AI_Analyzed_Meals thất bại
        console.error(
          '[approveNutrition] Failed to mirror into AI_Analyzed_Meals:',
          mirrorErr
        );
      }

      res.json({
        success: true,
        approved: true,
        today: manualResult.todayTotals
      });
    } else {
      res.json({
        success: true,
        approved: false
      });
    }
  } catch (error) {
    console.error('Error approving nutrition:', error);
    res.status(500).json({ error: 'Failed to approve nutrition data' });
  }
};
