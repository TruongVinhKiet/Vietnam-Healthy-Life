const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/portions/food/:foodId - Get portion sizes for a specific food
router.get('/food/:foodId', async (req, res) => {
  try {
    const { foodId } = req.params;
    
    const result = await db.query(`
      SELECT 
        p.portion_id,
        p.portion_name,
        p.portion_name_vi,
        p.weight_g,
        p.is_common,
        f.name as food_name
      FROM PortionSize p
      JOIN Food f ON p.food_id = f.food_id
      WHERE p.food_id = $1
      ORDER BY p.is_common DESC, p.weight_g ASC
    `, [foodId]);
    
    res.json({
      success: true,
      portions: result.rows
    });
  } catch (error) {
    console.error('Error fetching portion sizes:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy khẩu phần',
      error: error.message
    });
  }
});

// POST /api/portions - Create new portion size (admin only)
router.post('/', async (req, res) => {
  try {
    const { food_id, portion_name, portion_name_vi, weight_g, is_common } = req.body;
    
    if (!food_id || !portion_name || !weight_g) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu thông tin bắt buộc'
      });
    }
    
    const result = await db.query(`
      INSERT INTO PortionSize (food_id, portion_name, portion_name_vi, weight_g, is_common)
      VALUES ($1, $2, $3, $4, $5)
      RETURNING *
    `, [food_id, portion_name, portion_name_vi || portion_name, weight_g, is_common || false]);
    
    res.json({
      success: true,
      portion: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating portion size:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo khẩu phần',
      error: error.message
    });
  }
});

// PUT /api/portions/:id - Update portion size (admin only)
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { portion_name, portion_name_vi, weight_g, is_common } = req.body;
    
    const result = await db.query(`
      UPDATE PortionSize
      SET 
        portion_name = COALESCE($1, portion_name),
        portion_name_vi = COALESCE($2, portion_name_vi),
        weight_g = COALESCE($3, weight_g),
        is_common = COALESCE($4, is_common)
      WHERE portion_id = $5
      RETURNING *
    `, [portion_name, portion_name_vi, weight_g, is_common, id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy khẩu phần'
      });
    }
    
    res.json({
      success: true,
      portion: result.rows[0]
    });
  } catch (error) {
    console.error('Error updating portion size:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi cập nhật khẩu phần',
      error: error.message
    });
  }
});

// DELETE /api/portions/:id - Delete portion size (admin only)
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(`
      DELETE FROM PortionSize WHERE portion_id = $1
      RETURNING portion_id
    `, [id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy khẩu phần'
      });
    }
    
    res.json({
      success: true,
      message: 'Đã xóa khẩu phần'
    });
  } catch (error) {
    console.error('Error deleting portion size:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi xóa khẩu phần',
      error: error.message
    });
  }
});

module.exports = router;
