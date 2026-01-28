const db = require('../db');

class RoleService {
  /**
   * Get all roles for a specific admin
   */
  static async getAdminRoles(adminId) {
    const query = `
      SELECT r.role_id, r.role_name
      FROM role r
      INNER JOIN adminrole ar ON ar.role_id = r.role_id
      WHERE ar.admin_id = $1
    `;
    const result = await db.query(query, [adminId]);
    return result.rows;
  }

  /**
   * Check if admin has a specific role
   */
  static async hasRole(adminId, roleName) {
    const query = `
      SELECT 1
      FROM role r
      INNER JOIN adminrole ar ON ar.role_id = r.role_id
      WHERE ar.admin_id = $1 AND r.role_name = $2
      LIMIT 1
    `;
    const result = await db.query(query, [adminId, roleName]);
    return result.rows.length > 0;
  }

  /**
   * Check if admin has ANY of the specified roles
   */
  static async hasAnyRole(adminId, roleNames) {
    if (!roleNames || roleNames.length === 0) return false;
    
    const query = `
      SELECT 1
      FROM role r
      INNER JOIN adminrole ar ON ar.role_id = r.role_id
      WHERE ar.admin_id = $1 AND r.role_name = ANY($2)
      LIMIT 1
    `;
    const result = await db.query(query, [adminId, roleNames]);
    return result.rows.length > 0;
  }

  /**
   * Assign role to admin
   */
  static async assignRole(adminId, roleName) {
    const query = `
      INSERT INTO adminrole (admin_id, role_id)
      SELECT $1, role_id FROM role WHERE role_name = $2
      ON CONFLICT (admin_id, role_id) DO NOTHING
      RETURNING *
    `;
    const result = await db.query(query, [adminId, roleName]);
    return result.rows[0];
  }

  /**
   * Remove role from admin
   */
  static async removeRole(adminId, roleName) {
    const query = `
      DELETE FROM adminrole
      WHERE admin_id = $1
        AND role_id = (SELECT role_id FROM role WHERE role_name = $2)
      RETURNING *
    `;
    const result = await db.query(query, [adminId, roleName]);
    return result.rows[0];
  }

  /**
   * Get all available roles
   */
  static async getAllRoles() {
    const query = `SELECT * FROM role ORDER BY role_name`;
    const result = await db.query(query);
    return result.rows;
  }

  /**
   * Get admin with roles
   */
  static async getAdminWithRoles(adminId) {
    const adminQuery = `SELECT * FROM admin WHERE admin_id = $1`;
    const rolesQuery = `
      SELECT r.role_id, r.role_name
      FROM role r
      INNER JOIN adminrole ar ON ar.role_id = r.role_id
      WHERE ar.admin_id = $1
    `;
    
    const [adminResult, rolesResult] = await Promise.all([
      db.query(adminQuery, [adminId]),
      db.query(rolesQuery, [adminId])
    ]);

    if (adminResult.rows.length === 0) return null;

    return {
      ...adminResult.rows[0],
      roles: rolesResult.rows.map(r => r.role_name)
    };
  }
}

module.exports = RoleService;
