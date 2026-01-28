const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD
});

async function seedBasicData() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    
    console.log('🌱 Seeding basic data...\n');
    
    // 1. Seed Nutrients
    console.log('📝 Seeding Nutrients...');
    const nutrients = [
      ['Fiber', 'FIBTG', 'g', 'Carbohydrates'],
      ['Magnesium', 'MG', 'mg', 'Minerals'],
      ['Saturated Fat', 'FASAT', 'g', 'Fats'],
      ['Potassium', 'K', 'mg', 'Minerals'],
      ['Calcium', 'CA', 'mg', 'Minerals'],
      ['Sodium', 'NA', 'mg', 'Minerals'],
      ['Polyunsaturated Fat', 'FAPU', 'g', 'Fats'],
      ['Cholesterol', 'CHOLESTEROL', 'mg', 'Fats'],
      ['Protein', 'PROCNT', 'g', 'Macronutrients'],
      ['Total Fat', 'FAT', 'g', 'Macronutrients'],
      ['Vitamin C', 'VITC', 'mg', 'Vitamins'],
      ['Vitamin E', 'VITE', 'mg', 'Vitamins'],
      ['Vitamin B12', 'VITB12', 'mcg', 'Vitamins'],
      ['Folate', 'FOL', 'mcg', 'Vitamins'],
      ['Iron', 'FE', 'mg', 'Minerals'],
      ['Phosphorus', 'P', 'mg', 'Minerals'],
      ['Zinc', 'ZN', 'mg', 'Minerals']
    ];
    
    for (const [name, code, unit, category] of nutrients) {
      await client.query(`
        INSERT INTO Nutrient (name, nutrient_code, unit, category)
        VALUES ($1, $2, $3, $4)
        ON CONFLICT (nutrient_code) DO NOTHING
      `, [name, code, unit, category]);
    }
    console.log(`✅ Seeded ${nutrients.length} nutrients\n`);
    
    // 2. Seed Vitamins
    console.log('📝 Seeding Vitamins...');
    const vitamins = [
      ['Vitamin A', 'VIT_A', 'Fat-soluble vitamin'],
      ['Vitamin C', 'VIT_C', 'Water-soluble vitamin'],
      ['Vitamin D', 'VIT_D', 'Fat-soluble vitamin'],
      ['Vitamin E', 'VIT_E', 'Fat-soluble vitamin'],
      ['Vitamin K', 'VIT_K', 'Fat-soluble vitamin'],
      ['Vitamin B1 (Thiamin)', 'VIT_B1', 'Water-soluble vitamin'],
      ['Vitamin B2 (Riboflavin)', 'VIT_B2', 'Water-soluble vitamin'],
      ['Vitamin B3 (Niacin)', 'VIT_B3', 'Water-soluble vitamin'],
      ['Vitamin B6', 'VIT_B6', 'Water-soluble vitamin'],
      ['Vitamin B12', 'VIT_B12', 'Water-soluble vitamin'],
      ['Folate (B9)', 'VIT_B9', 'Water-soluble vitamin'],
      ['Biotin (B7)', 'VIT_B7', 'Water-soluble vitamin'],
      ['Pantothenic Acid (B5)', 'VIT_B5', 'Water-soluble vitamin']
    ];
    
    for (const [name, code, description] of vitamins) {
      await client.query(`
        INSERT INTO Vitamin (name, code, description)
        VALUES ($1, $2, $3)
        ON CONFLICT (code) DO NOTHING
      `, [name, code, description]);
    }
    console.log(`✅ Seeded ${vitamins.length} vitamins\n`);
    
    // 3. Seed Minerals
    console.log('📝 Seeding Minerals...');
    const minerals = [
      ['Calcium', 'MIN_CA', 'Essential for bones'],
      ['Iron', 'MIN_FE', 'Essential for blood'],
      ['Magnesium', 'MIN_MG', 'Essential for muscles'],
      ['Phosphorus', 'MIN_P', 'Essential for bones'],
      ['Potassium', 'MIN_K', 'Essential for heart'],
      ['Sodium', 'MIN_NA', 'Electrolyte'],
      ['Zinc', 'MIN_ZN', 'Immune support'],
      ['Copper', 'MIN_CU', 'Enzyme function'],
      ['Manganese', 'MIN_MN', 'Metabolism'],
      ['Selenium', 'MIN_SE', 'Antioxidant'],
      ['Iodine', 'MIN_I', 'Thyroid function'],
      ['Chromium', 'MIN_CR', 'Blood sugar'],
      ['Molybdenum', 'MIN_MO', 'Enzyme function'],
      ['Fluoride', 'MIN_F', 'Dental health']
    ];
    
    for (const [name, code, description] of minerals) {
      await client.query(`
        INSERT INTO Mineral (name, code, description)
        VALUES ($1, $2, $3)
        ON CONFLICT (code) DO NOTHING
      `, [name, code, description]);
    }
    console.log(`✅ Seeded ${minerals.length} minerals\n`);
    
    // 4. Seed Health Conditions
    console.log('📝 Seeding Health Conditions...');
    const conditions = [
      ['Type 2 Diabetes', 'Tiểu đường type 2', 'High blood sugar levels', 'high'],
      ['Hypertension', 'Cao huyết áp', 'High blood pressure', 'high'],
      ['High Cholesterol', 'Mỡ máu cao', 'High cholesterol levels', 'medium'],
      ['Obesity', 'Béo phì', 'Excessive body fat', 'medium'],
      ['Gout', 'Gout', 'High uric acid', 'medium'],
      ['Fatty Liver', 'Gan nhiễm mỡ', 'Fat buildup in liver', 'medium'],
      ['Kidney Disease', 'Bệnh thận', 'Impaired kidney function', 'high'],
      ['Anemia', 'Thiếu máu', 'Low red blood cells', 'medium'],
      ['Osteoporosis', 'Loãng xương', 'Weak bones', 'medium'],
      ['Heart Disease', 'Bệnh tim', 'Cardiovascular problems', 'high']
    ];
    
    for (const [name_en, name_vi, description, severity] of conditions) {
      await client.query(`
        INSERT INTO HealthCondition (name_en, name_vi, description, severity)
        VALUES ($1, $2, $3, $4)
      `, [name_en, name_vi, description, severity]);
    }
    console.log(`✅ Seeded ${conditions.length} health conditions\n`);
    
    // 5. Seed Fiber types
    console.log('📝 Seeding Fiber types...');
    await client.query(`
      INSERT INTO Fiber (name, code, description) VALUES
      ('Total Dietary Fiber', 'TOTAL_FIBER', 'Total fiber from all sources'),
      ('Soluble Fiber', 'SOLUBLE_FIBER', 'Fiber that dissolves in water')
      ON CONFLICT (code) DO NOTHING
    `);
    console.log('✅ Seeded 2 fiber types\n');
    
    // 6. Seed FoodCategories
    console.log('📝 Seeding Food Categories...');
    const categories = [
      ['Vegetables', 'Rau củ quả', 'Fresh and cooked vegetables'],
      ['Fruits', 'Trái cây', 'Fresh and dried fruits'],
      ['Grains', 'Ngũ cốc', 'Rice, bread, pasta, cereals'],
      ['Protein', 'Thực phẩm giàu đạm', 'Meat, fish, eggs, legumes'],
      ['Dairy', 'Sữa và chế phẩm', 'Milk, cheese, yogurt'],
      ['Fats & Oils', 'Chất béo & dầu', 'Cooking oils, butter, nuts'],
      ['Beverages', 'Đồ uống', 'Water, juice, tea, coffee'],
      ['Snacks', 'Đồ ăn vặt', 'Chips, crackers, candy'],
      ['Seafood', 'Hải sản', 'Fish, shellfish, seaweed'],
      ['Herbs & Spices', 'Gia vị', 'Herbs, spices, seasonings']
    ];
    
    for (const [name, name_vi, description] of categories) {
      await client.query(`
        INSERT INTO FoodCategory (name, name_vi, description)
        VALUES ($1, $2, $3)
        ON CONFLICT (name) DO NOTHING
      `, [name, name_vi, description]);
    }
    console.log(`✅ Seeded ${categories.length} food categories\n`);
    
    await client.query('COMMIT');
    
    console.log('\n✅ Basic seeding completed!\n');
    
    // Verify
    console.log('📊 Verification:\n');
    const tables = ['Nutrient', 'Vitamin', 'Mineral', 'HealthCondition', 'Fiber', 'FoodCategory'];
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

seedBasicData();
