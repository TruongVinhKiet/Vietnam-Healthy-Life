const db = require('./db');

async function seedRoles() {
  console.log('=== Seeding Admin Roles ===\n');

  try {
    // Insert roles
    console.log('1. Creating roles...');
    await db.query(`
      INSERT INTO Role (role_name) VALUES 
        ('super_admin'),
        ('user_manager'),
        ('content_manager'),
        ('analyst'),
        ('support')
      ON CONFLICT (role_name) DO NOTHING
    `);
    console.log('✅ Roles created\n');

    // Show all roles
    const rolesResult = await db.query('SELECT * FROM Role ORDER BY role_name');
    console.log('2. Available roles:');
    rolesResult.rows.forEach(role => {
      console.log(`   - ${role.role_name} (ID: ${role.role_id})`);
    });
    console.log('');

    // Get first admin
    const adminResult = await db.query('SELECT * FROM Admin LIMIT 1');
    if (adminResult.rows.length === 0) {
      console.log('⚠️  No admin found. Please register an admin first.');
      return;
    }

    const admin = adminResult.rows[0];
    console.log(`3. Found admin: ${admin.username} (ID: ${admin.admin_id})`);

    // Assign super_admin role to first admin
    await db.query(`
      INSERT INTO AdminRole (admin_id, role_id)
      SELECT $1, role_id FROM Role WHERE role_name = 'super_admin'
      ON CONFLICT (admin_id, role_id) DO NOTHING
    `, [admin.admin_id]);
    console.log(`✅ Assigned 'super_admin' role to ${admin.username}\n`);

    // Show admin's roles
    const adminRolesResult = await db.query(`
      SELECT r.role_name
      FROM Role r
      INNER JOIN AdminRole ar ON ar.role_id = r.role_id
      WHERE ar.admin_id = $1
    `, [admin.admin_id]);

    console.log('4. Admin roles:');
    adminRolesResult.rows.forEach(role => {
      console.log(`   - ${role.role_name}`);
    });
    console.log('');

    console.log('🎉 Role seeding completed!');
    console.log('\nNext steps:');
    console.log('  - Use POST /admin/roles/admins/:adminId/assign to assign roles');
    console.log('  - Use GET /admin/roles/my-roles to check your roles');
    console.log('  - Use GET /admin/roles/permissions to see role permissions');

  } catch (error) {
    console.error('❌ Error seeding roles:', error.message);
    console.error(error);
  } finally {
    process.exit(0);
  }
}

seedRoles();
