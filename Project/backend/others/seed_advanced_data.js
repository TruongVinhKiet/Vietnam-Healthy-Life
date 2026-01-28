const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function seedAdvancedData() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🌱 Seeding advanced features data...\n');
    
    // 1. ConditionNutrientEffect
    console.log('📝 Seeding ConditionNutrientEffect...');
    
    const effects = [
      // Diabetes (1)
      [1, 'FIBTG', 'increase', 40, 'Tăng chất xơ giúp kiểm soát đường huyết'],
      [1, 'MG', 'increase', 15, 'Magnesium hỗ trợ chuyển hóa glucose'],
      [1, 'FASAT', 'decrease', -20, 'Giảm chất béo bão hòa'],
      // Hypertension (2)
      [2, 'K', 'increase', 30, 'Potassium giúp giảm huyết áp'],
      [2, 'MG', 'increase', 20, 'Magnesium giúp giãn mạch máu'],
      [2, 'CA', 'increase', 15, 'Calcium hỗ trợ kiểm soát huyết áp'],
      [2, 'NA', 'decrease', -50, 'Giảm natri rất quan trọng'],
      // High Cholesterol (3)
      [3, 'FIBTG', 'increase', 35, 'Chất xơ giúp giảm cholesterol'],
      [3, 'FAPU', 'increase', 25, 'Omega-3 giảm triglyceride'],
      [3, 'FASAT', 'decrease', -30, 'Giảm chất béo bão hòa'],
      [3, 'CHOLESTEROL', 'decrease', -40, 'Hạn chế cholesterol'],
      // Obesity (4)
      [4, 'FIBTG', 'increase', 30, 'Chất xơ tạo cảm giác no'],
      [4, 'PROCNT', 'increase', 20, 'Protein giúp giữ cơ khi giảm cân'],
      [4, 'FAT', 'decrease', -15, 'Giảm tổng lượng chất béo'],
      // Gout (5)
      [5, 'VITC', 'increase', 50, 'Vitamin C giúp giảm acid uric'],
      [5, 'K', 'increase', 20, 'Potassium giúp thải acid uric'],
      // Fatty Liver (6)
      [6, 'VITC', 'increase', 30, 'Chống oxy hóa bảo vệ gan'],
      [6, 'VITE', 'increase', 40, 'Vitamin E giảm viêm gan'],
      [6, 'FASAT', 'decrease', -35, 'Giảm chất béo bão hòa'],
      // Anemia (8)
      [8, 'FE', 'increase', 100, 'Tăng gấp đôi sắt'],
      [8, 'VITC', 'increase', 50, 'Vitamin C giúp hấp thu sắt'],
      [8, 'VITB12', 'increase', 80, 'B12 cần cho hồng cầu'],
      [8, 'FOL', 'increase', 60, 'Folate cần cho tạo máu']
    ];
    
    for (const [cond_id, nut_code, effect_type, adjustment, notes] of effects) {
      await client.query(`
        INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, effect_type, adjustment_percent, notes)
        SELECT $1, nutrient_id, $2, $3, $4
        FROM Nutrient 
        WHERE nutrient_code = $5
        LIMIT 1
      `, [cond_id, effect_type, adjustment, notes, nut_code]);
    }
    console.log(`✅ Seeded ${effects.length} nutrient effects\n`);
    
    // 2. FiberRequirement
    console.log('📝 Seeding FiberRequirement...');
    
    const fiberReqs = [
      ['TOTAL_FIBER', 'male', 19, 50, 38.0],
      ['TOTAL_FIBER', 'male', 51, 999, 30.0],
      ['TOTAL_FIBER', 'female', 19, 50, 25.0],
      ['TOTAL_FIBER', 'female', 51, 999, 21.0],
      ['SOLUBLE_FIBER', 'male', 19, 50, 10.0],
      ['SOLUBLE_FIBER', 'male', 51, 999, 8.0],
      ['SOLUBLE_FIBER', 'female', 19, 50, 7.0],
      ['SOLUBLE_FIBER', 'female', 51, 999, 6.0]
    ];
    
    for (const [fiber_code, sex, age_min, age_max, rda] of fiberReqs) {
      await client.query(`
        INSERT INTO FiberRequirement (fiber_id, sex, age_min, age_max, rda_value, unit)
        SELECT fiber_id, $1, $2, $3, $4, 'g'
        FROM Fiber
        WHERE code = $5
        LIMIT 1
      `, [sex, age_min, age_max, rda, fiber_code]);
    }
    console.log(`✅ Seeded ${fiberReqs.length} fiber requirements\n`);
    
    await client.query('COMMIT');
    
    console.log('\n✅ Advanced seeding completed!\n');
    
    // Verify
    console.log('📊 Verification:\n');
    const tables = ['ConditionNutrientEffect', 'FiberRequirement'];
    for (const table of tables) {
      const result = await client.query(`SELECT COUNT(*) as count FROM ${table}`);
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

seedAdvancedData();
