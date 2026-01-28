const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function seedMissingData() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🌱 Seeding missing critical data...\n');
    
    // 1. Seed Vitamins (13 vitamins)
    console.log('📝 Seeding Vitamins...');
    const vitamins = [
      ['VIT_A', 'Vitamin A', 'Essential for vision and immune function'],
      ['VIT_B1', 'Vitamin B1 (Thiamine)', 'Energy metabolism'],
      ['VIT_B2', 'Vitamin B2 (Riboflavin)', 'Energy production'],
      ['VIT_B3', 'Vitamin B3 (Niacin)', 'Cellular metabolism'],
      ['VIT_B5', 'Vitamin B5 (Pantothenic Acid)', 'Fatty acid synthesis'],
      ['VIT_B6', 'Vitamin B6', 'Protein metabolism'],
      ['VIT_B7', 'Vitamin B7 (Biotin)', 'Metabolism of carbs and fats'],
      ['VIT_B9', 'Vitamin B9 (Folate)', 'DNA synthesis'],
      ['VIT_B12', 'Vitamin B12', 'Red blood cell formation'],
      ['VIT_C', 'Vitamin C', 'Antioxidant and immune support'],
      ['VIT_D', 'Vitamin D', 'Bone health and calcium absorption'],
      ['VIT_E', 'Vitamin E', 'Antioxidant protection'],
      ['VIT_K', 'Vitamin K', 'Blood clotting']
    ];
    
    for (const [code, name, desc] of vitamins) {
      await client.query(`
        INSERT INTO Vitamin (code, name, description)
        VALUES ($1, $2, $3)
        ON CONFLICT (code) DO NOTHING
      `, [code, name, desc]);
    }
    console.log(`✅ Seeded ${vitamins.length} vitamins\n`);
    
    // 2. Seed Minerals (already have 14)
    console.log('📝 Checking Minerals...');
    const mineralCount = await client.query('SELECT COUNT(*) FROM Mineral');
    console.log(`✅ ${mineralCount.rows[0].count} minerals already exist\n`);
    
    // 3. Seed VitaminNutrient mappings
    console.log('📝 Seeding VitaminNutrient mappings...');
    const vitNutMappings = [
      ['VIT_A', 'VITA_RAE'],
      ['VIT_B1', 'THIA'],
      ['VIT_B2', 'RIBF'],
      ['VIT_B3', 'NIA'],
      ['VIT_B6', 'VITB6A'],
      ['VIT_B9', 'FOL'],
      ['VIT_B12', 'VITB12'],
      ['VIT_C', 'VITC'],
      ['VIT_D', 'VITD'],
      ['VIT_E', 'TOCPHA'],
      ['VIT_K', 'VITK1']
    ];
    
    for (const [vitCode, nutCode] of vitNutMappings) {
      await client.query(`
        INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, amount)
        SELECT v.vitamin_id, n.nutrient_id, 1.0
        FROM Vitamin v, Nutrient n
        WHERE v.code = $1 AND n.nutrient_code = $2
        ON CONFLICT DO NOTHING
      `, [vitCode, nutCode]);
    }
    console.log(`✅ Seeded ${vitNutMappings.length} vitamin-nutrient mappings\n`);
    
    // 4. Seed MineralNutrient mappings
    console.log('📝 Seeding MineralNutrient mappings...');
    const minNutMappings = [
      ['MIN_CA', 'CA'],
      ['MIN_FE', 'FE'],
      ['MIN_MG', 'MG'],
      ['MIN_P', 'P'],
      ['MIN_K', 'K'],
      ['MIN_NA', 'NA'],
      ['MIN_ZN', 'ZN'],
      ['MIN_CU', 'CU'],
      ['MIN_MN', 'MN'],
      ['MIN_SE', 'SE'],
      ['MIN_I', 'ID'],
      ['MIN_CR', 'CR'],
      ['MIN_MO', 'MO'],
      ['MIN_F', 'FLD']
    ];
    
    for (const [minCode, nutCode] of minNutMappings) {
      await client.query(`
        INSERT INTO MineralNutrient (mineral_id, nutrient_id, amount)
        SELECT m.mineral_id, n.nutrient_id, 1.0
        FROM Mineral m, Nutrient n
        WHERE m.code = $1 AND n.nutrient_code = $2
        ON CONFLICT DO NOTHING
      `, [minCode, nutCode]);
    }
    console.log(`✅ Seeded ${minNutMappings.length} mineral-nutrient mappings\n`);
    
    // 5. Seed Roles
    console.log('📝 Seeding Roles...');
    const roles = [
      ['super_admin', 'Super Administrator with full access'],
      ['admin', 'Administrator with most privileges'],
      ['moderator', 'Content moderator'],
      ['user', 'Regular user']
    ];
    
    for (const [name, desc] of roles) {
      await client.query(`
        INSERT INTO Role (role_name, description)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING
      `, [name, desc]);
    }
    console.log(`✅ Seeded ${roles.length} roles\n`);
    
    // 6. Seed Permissions
    console.log('📝 Seeding Permissions...');
    const permissions = [
      ['manage_users', 'Create, edit, delete users'],
      ['manage_foods', 'Manage food database'],
      ['manage_nutrients', 'Manage nutrient database'],
      ['manage_conditions', 'Manage health conditions'],
      ['manage_roles', 'Manage roles and permissions'],
      ['view_analytics', 'View system analytics'],
      ['moderate_content', 'Moderate user content'],
      ['manage_recipes', 'Manage recipe database']
    ];
    
    for (const [name, desc] of permissions) {
      await client.query(`
        INSERT INTO Permission (permission_name, description)
        VALUES ($1, $2)
        ON CONFLICT DO NOTHING
      `, [name, desc]);
    }
    console.log(`✅ Seeded ${permissions.length} permissions\n`);
    
    // 7. Assign permissions to super_admin role
    console.log('📝 Assigning permissions to super_admin...');
    await client.query(`
      INSERT INTO RolePermission (role_id, permission_id)
      SELECT r.role_id, p.permission_id
      FROM Role r, Permission p
      WHERE r.role_name = 'super_admin'
      ON CONFLICT DO NOTHING
    `);
    const rpCount = await client.query(`
      SELECT COUNT(*) FROM RolePermission rp
      JOIN Role r ON rp.role_id = r.role_id
      WHERE r.role_name = 'super_admin'
    `);
    console.log(`✅ Assigned ${rpCount.rows[0].count} permissions to super_admin\n`);
    
    await client.query('COMMIT');
    
    console.log('\n✅ All critical data seeded!\n');
    
    // Verify
    console.log('📊 Final counts:\n');
    const tables = [
      'Vitamin',
      'Mineral',
      'VitaminNutrient',
      'MineralNutrient',
      'Role',
      'Permission',
      'RolePermission'
    ];
    
    for (const table of tables) {
      const tableName = table === 'User' ? '"User"' : table;
      const result = await client.query(`SELECT COUNT(*) as count FROM ${tableName}`);
      console.log(`  ${table}: ${result.rows[0].count}`);
    }
    
  } catch (error) {
    await client.query('ROLLBACK');
    console.error('\n❌ Error:', error);
  } finally {
    client.release();
    await pool.end();
  }
}

seedMissingData();
