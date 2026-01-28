const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/permissions - Get all permissions
router.get('/', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT * FROM Permission
      ORDER BY permission_name
    `);
    
    res.json({
      success: true,
      permissions: result.rows
    });
  } catch (error) {
    console.error('Error fetching permissions:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy danh sách quyền',
      error: error.message
    });
  }
});

// GET /api/permissions/role/:roleId - Get permissions for a role
router.get('/role/:roleId', async (req, res) => {
  try {
    const { roleId } = req.params;
    
    const result = await db.query(`
      SELECT 
        p.*,
        CASE WHEN rp.role_id IS NOT NULL THEN true ELSE false END as is_assigned
      FROM Permission p
      LEFT JOIN RolePermission rp ON p.permission_id = rp.permission_id 
        AND rp.role_id = $1
      ORDER BY p.permission_name
    `, [roleId]);
    
    res.json({
      success: true,
      permissions: result.rows
    });
  } catch (error) {
    console.error('Error fetching role permissions:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy quyền của vai trò',
      error: error.message
    });
  }
});

// POST /api/permissions - Create new permission (super_admin only)
router.post('/', async (req, res) => {
  try {
    const { permission_name, description } = req.body;
    
    if (!permission_name) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu tên quyền'
      });
    }
    
    const result = await db.query(`
      INSERT INTO Permission (permission_name, description)
      VALUES ($1, $2)
      RETURNING *
    `, [permission_name, description]);
    
    res.json({
      success: true,
      permission: result.rows[0]
    });
  } catch (error) {
    console.error('Error creating permission:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi tạo quyền',
      error: error.message
    });
  }
});

// POST /api/permissions/assign - Assign permission to role
router.post('/assign', async (req, res) => {
  try {
    const { role_id, permission_id } = req.body;
    
    if (!role_id || !permission_id) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu role_id hoặc permission_id'
      });
    }
    
    // Check if already assigned
    const checkResult = await db.query(`
      SELECT * FROM RolePermission
      WHERE role_id = $1 AND permission_id = $2
    `, [role_id, permission_id]);
    
    if (checkResult.rows.length > 0) {
      return res.status(400).json({
        success: false,
        message: 'Quyền đã được gán cho vai trò này'
      });
    }
    
    const result = await db.query(`
      INSERT INTO RolePermission (role_id, permission_id)
      VALUES ($1, $2)
      RETURNING *
    `, [role_id, permission_id]);
    
    res.json({
      success: true,
      assignment: result.rows[0]
    });
  } catch (error) {
    console.error('Error assigning permission:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi gán quyền',
      error: error.message
    });
  }
});

// DELETE /api/permissions/revoke - Revoke permission from role
router.delete('/revoke', async (req, res) => {
  try {
    const { role_id, permission_id } = req.body;
    
    if (!role_id || !permission_id) {
      return res.status(400).json({
        success: false,
        message: 'Thiếu role_id hoặc permission_id'
      });
    }
    
    const result = await db.query(`
      DELETE FROM RolePermission
      WHERE role_id = $1 AND permission_id = $2
      RETURNING *
    `, [role_id, permission_id]);
    
    if (result.rows.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Không tìm thấy phân quyền'
      });
    }
    
    res.json({
      success: true,
      message: 'Đã thu hồi quyền'
    });
  } catch (error) {
    console.error('Error revoking permission:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi thu hồi quyền',
      error: error.message
    });
  }
});

// GET /api/permissions/user/:userId - Get all permissions for a user (via their role)
router.get('/user/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    
    const result = await db.query(`
      SELECT DISTINCT p.*
      FROM Permission p
      JOIN RolePermission rp ON p.permission_id = rp.permission_id
      JOIN Admin a ON rp.role_id = a.role_id
      WHERE a.user_id = $1 AND a.is_deleted = false
      ORDER BY p.permission_name
    `, [userId]);
    
    res.json({
      success: true,
      permissions: result.rows
    });
  } catch (error) {
    console.error('Error fetching user permissions:', error);
    res.status(500).json({
      success: false,
      message: 'Lỗi khi lấy quyền của người dùng',
      error: error.message
    });
  }
});

module.exports = router;
