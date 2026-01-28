const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/fiber - Get all fiber types
router.get('/', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT * FROM Fiber
      ORDER BY fiber_id
    `);
    
    res.json({
      success: true,
      fibers: result.rows
    });
  } catch (error) {
    console.error('Error fetching fibers:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách chất xơ',
      error: error.message
    });
  }
});

// GET /api/fiber/:id/requirements - Get RDA for specific fiber type
router.get('/:id/requirements', async (req, res) => {
  try {
    const { id } = req.params;
    
    const result = await db.query(`
      SELECT 
        fr.*,
        f.name as fiber_name,
        f.code
      FROM FiberRequirement fr
      JOIN Fiber f ON fr.fiber_id = f.fiber_id
      WHERE fr.fiber_id = $1
      ORDER BY fr.sex, fr.age_min
    `, [id]);
    
    res.json({
      success: true,
      requirements: result.rows
    });
  } catch (error) {
    console.error('Error fetching fiber requirements:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy nhu cầu chất xơ',
      error: error.message
    });
  }
});

// GET /api/fiber/user/:userId - Get fiber requirements for specific user
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    // Get user info
    const userResult = await db.query(`
      SELECT user_id, date_of_birth, sex FROM "User"
      WHERE user_id = $1
    `, [userId]);
    
    if (userResult.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy người dùng'
      });
    }
    
    const user = userResult.rows[0];
    const age = Math.floor((Date.now() - new Date(user.date_of_birth)) / (365.25 * 24 * 60 * 60 * 1000));
    
    // Get fiber requirements
    const requirementsResult = await db.query(`
      SELECT 
        f.fiber_id,
        f.name,
        f.code,
        fr.rda_value,
        fr.unit,
        fr.notes
      FROM Fiber f
      LEFT JOIN FiberRequirement fr ON f.fiber_id = fr.fiber_id
        AND fr.sex = $1
        AND $2 BETWEEN fr.age_min AND fr.age_max
      ORDER BY f.fiber_id
    `, [user.sex, age]);
    
    res.json({
      success: true,
      user_age: age,
      user_sex: user.sex,
      requirements: requirementsResult.rows
    });
  } catch (error) {
    console.error('Error fetching user fiber requirements:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy nhu cầu chất xơ của người dùng',
      error: error.message
    });
  }
});

module.exports = router;
