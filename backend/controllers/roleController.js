const RoleService = require('../services/roleService');

/**
 * Admin Role Management Controller
 */

/**
 * GET /admin/roles/all
 * Get all available roles in the system
 */
async function getAllRoles(req, res) {
  try {
    const roles = await RoleService.getAllRoles();
    return res.json({ 
      success: true,
      roles 
    });
  } catch (error) {
    console.error('Get all roles error:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Failed to fetch roles' 
    });
  }
}

/**
 * GET /admin/roles/my-roles
 * Get current admin's roles
 */
async function getMyRoles(req, res) {
  try {
    const adminId = req.admin.admin_id;
    const roles = await RoleService.getAdminRoles(adminId);
    
    return res.json({ 
      success: true,
      admin_id: adminId,
      roles: roles.map(r => r.role_name)
    });
  } catch (error) {
    console.error('Get my roles error:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Failed to fetch your roles' 
    });
  }
}

/**
 * GET /admin/roles/admins/:adminId
 * Get roles for a specific admin
 */
async function getAdminRoles(req, res) {
  try {
    const { adminId } = req.params;
    const adminWithRoles = await RoleService.getAdminWithRoles(adminId);
    
    if (!adminWithRoles) {
      return res.status(404).json({ 
        success: false,
        error: 'Admin not found' 
      });
    }

    return res.json({ 
      success: true,
      admin: adminWithRoles
    });
  } catch (error) {
    console.error('Get admin roles error:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Failed to fetch admin roles' 
    });
  }
}

/**
 * POST /admin/roles/admins/:adminId/assign
 * Assign role to admin
 * Body: { role_name: 'user_manager' }
 */
async function assignRoleToAdmin(req, res) {
  try {
    const { adminId } = req.params;
    const { role_name } = req.body;

    if (!role_name) {
      return res.status(400).json({ 
        success: false,
        error: 'role_name is required' 
      });
    }

    await RoleService.assignRole(adminId, role_name);
    
    // Return updated admin with roles
    const adminWithRoles = await RoleService.getAdminWithRoles(adminId);

    return res.json({ 
      success: true,
      message: `Role '${role_name}' assigned successfully`,
      admin: adminWithRoles
    });
  } catch (error) {
    console.error('Assign role error:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Failed to assign role' 
    });
  }
}

/**
 * DELETE /admin/roles/admins/:adminId/remove
 * Remove role from admin
 * Body: { role_name: 'user_manager' }
 */
async function removeRoleFromAdmin(req, res) {
  try {
    const { adminId } = req.params;
    const { role_name } = req.body;

    if (!role_name) {
      return res.status(400).json({ 
        success: false,
        error: 'role_name is required' 
      });
    }

    // Prevent removing super_admin from self
    if (req.admin.admin_id === parseInt(adminId) && role_name === 'super_admin') {
      return res.status(403).json({ 
        success: false,
        error: 'Cannot remove super_admin role from yourself' 
      });
    }

    await RoleService.removeRole(adminId, role_name);
    
    // Return updated admin with roles
    const adminWithRoles = await RoleService.getAdminWithRoles(adminId);

    return res.json({ 
      success: true,
      message: `Role '${role_name}' removed successfully`,
      admin: adminWithRoles
    });
  } catch (error) {
    console.error('Remove role error:', error);
    return res.status(500).json({ 
      success: false,
      error: 'Failed to remove role' 
    });
  }
}

/**
 * GET /admin/roles/permissions
 * Get permission map for all roles
 */
function getRolePermissions(req, res) {
  const permissions = {
    super_admin: {
      description: 'Toàn quyền hệ thống - Truy cập tất cả tính năng',
      permissions: ['Tất cả quyền']
    },
    user_manager: {
      description: 'Quản lý người dùng',
      permissions: [
        'Xem danh sách người dùng',
        'Xem chi tiết người dùng',
        'Chặn/gỡ chặn tài khoản',
        'Xóa tài khoản người dùng',
        'Xem lịch sử hoạt động',
        'Ghi log hoạt động',
        'Xem analytics hành vi user'
      ]
    },
    content_manager: {
      description: 'Quản lý nội dung',
      permissions: [
        'Tạo thực phẩm mới',
        'Cập nhật thông tin thực phẩm',
        'Xóa thực phẩm',
        'Xem danh sách thực phẩm',
        'Tạo chất dinh dưỡng',
        'Cập nhật chất dinh dưỡng',
        'Xóa chất dinh dưỡng',
        'Quản lý bệnh lý',
        'Import dữ liệu hàng loạt'
      ]
    },
    analyst: {
      description: 'Xem analytics và báo cáo',
      permissions: [
        'Xem analytics',
        'Xem lịch sử hoạt động',
        'Xem dashboard thống kê',
        'Xem danh sách người dùng (chỉ đọc)',
        'Xem danh sách thực phẩm (chỉ đọc)'
      ]
    },
    support: {
      description: 'Hỗ trợ người dùng',
      permissions: [
        'Xem danh sách người dùng',
        'Xem yêu cầu gỡ chặn',
        'Phê duyệt gỡ chặn',
        'Xem lịch sử hoạt động'
      ]
    }
  };

  return res.json({ 
    success: true,
    permissions 
  });
}

module.exports = {
  getAllRoles,
  getMyRoles,
  getAdminRoles,
  assignRoleToAdmin,
  removeRoleFromAdmin,
  getRolePermissions
};
