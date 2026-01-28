const RoleService = require('../services/roleService');

/**
 * Middleware factory to check if admin has required role(s)
 * Usage: 
 *   router.get('/users', adminMiddleware, requireRole('user_manager'), handler)
 *   router.delete('/users/:id', adminMiddleware, requireRole(['super_admin', 'user_manager']), handler)
 */
function requireRole(roles) {
  // Normalize to array
  const requiredRoles = Array.isArray(roles) ? roles : [roles];

  return async (req, res, next) => {
    try {
      // Admin object should be set by adminMiddleware
      if (!req.admin || !req.admin.admin_id) {
        return res.status(401).json({ error: 'Authentication required' });
      }

      const adminId = req.admin.admin_id;

      // Check if admin has super_admin role (bypass all checks)
      const isSuperAdmin = await RoleService.hasRole(adminId, 'super_admin');
      if (isSuperAdmin) {
        req.admin.isSuperAdmin = true;
        return next();
      }

      // Check if admin has any of the required roles
      const hasPermission = await RoleService.hasAnyRole(adminId, requiredRoles);
      if (!hasPermission) {
        return res.status(403).json({ 
          error: 'Insufficient permissions',
          required_roles: requiredRoles,
          message: `This action requires one of the following roles: ${requiredRoles.join(', ')}`
        });
      }

      // Load and attach all admin roles to request
      const adminRoles = await RoleService.getAdminRoles(adminId);
      req.admin.roles = adminRoles.map(r => r.role_name);

      next();
    } catch (error) {
      console.error('Role check error:', error);
      return res.status(500).json({ error: 'Role verification failed' });
    }
  };
}

/**
 * Middleware to check if admin is super admin
 */
function requireSuperAdmin(req, res, next) {
  return requireRole('super_admin')(req, res, next);
}

/**
 * Middleware to attach roles to admin object (doesn't block)
 */
async function attachRoles(req, res, next) {
  try {
    if (req.admin && req.admin.admin_id) {
      const roles = await RoleService.getAdminRoles(req.admin.admin_id);
      req.admin.roles = roles.map(r => r.role_name);
      req.admin.isSuperAdmin = req.admin.roles.includes('super_admin');
    }
    next();
  } catch (error) {
    console.error('Attach roles error:', error);
    next(); // Continue even if role attachment fails
  }
}

module.exports = {
  requireRole,
  requireSuperAdmin,
  attachRoles
};
