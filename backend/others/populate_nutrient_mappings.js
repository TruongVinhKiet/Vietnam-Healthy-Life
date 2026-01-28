require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT || '5432', 10),
  user: process.env.DB_USER || 'postgres',
  password: String(process.env.DB_PASSWORD || ''),
  database: process.env.DB_DATABASE || 'Health',
});

async function populateNutrientMappings() {
  const client = await pool.connect();
  
  try {
    console.log('🔍 Analyzing existing nutrients in database...\n');
    
    // Get all nutrients
    const nutrients = await client.query(`
      SELECT nutrient_id, nutrient_code, name, unit 
      FROM Nutrient 
      WHERE nutrient_code IS NOT NULL
      ORDER BY nutrient_code
    `);
    
    console.log(`Found ${nutrients.rows.length} nutrients with codes\n`);
    
    // Get all vitamins
    const vitamins = await client.query(`
      SELECT vitamin_id, code, name 
      FROM Vitamin 
      ORDER BY vitamin_id
    `);
    
    console.log(`Found ${vitamins.rows.length} vitamins\n`);
    
    // Get all minerals
    const minerals = await client.query(`
      SELECT mineral_id, code, name 
      FROM Mineral 
      ORDER BY mineral_id
    `);
    
    console.log(`Found ${minerals.rows.length} minerals\n`);
    
    // Display some nutrients to help with mapping
    console.log('📋 Sample nutrients (first 30):');
    nutrients.rows.slice(0, 30).forEach(n => {
      console.log(`  ${n.nutrient_code.padEnd(15)} | ${n.name.substring(0, 50)}`);
    });
    
    console.log('\n📋 Vitamins:');
    vitamins.rows.forEach(v => {
      console.log(`  ${v.code.padEnd(10)} | ${v.name}`);
    });
    
    console.log('\n📋 Minerals:');
    minerals.rows.forEach(m => {
      console.log(`  ${m.code.padEnd(10)} | ${m.name}`);
    });
    
    // Create smarter mappings based on name matching
    console.log('\n\n🔧 Creating intelligent nutrient mappings...\n');
    
    let vitaminMappingsCreated = 0;
    let mineralMappingsCreated = 0;
    
    // Vitamin mappings with fuzzy matching
    const vitaminMappings = {
      'VITA': ['VITA_RAE', 'RETOL', 'VITA', 'VITAMIN A'],
      'VITD': ['VITD', 'CHOCAL', 'VITAMIN D'],
      'VITE': ['TOCPHA', 'VITE', 'VITAMIN E'],
      'VITK': ['VITK1', 'VITK', 'VITAMIN K'],
      'VITC': ['VITC', 'ASC', 'VITAMIN C'],
      'VITB1': ['THIA', 'VITB1', 'THIAMIN'],
      'VITB2': ['RIBF', 'VITB2', 'RIBOFLAVIN'],
      'VITB3': ['NIA', 'VITB3', 'NIACIN'],
      'VITB5': ['PANTAC', 'VITB5', 'PANTOTHENIC'],
      'VITB6': ['VITB6A', 'VITB6', 'PYRIDOXINE'],
      'VITB7': ['BIOT', 'VITB7', 'BIOTIN'],
      'VITB9': ['FOL', 'FOLAC', 'FOLDFE', 'FOLATE'],
      'VITB12': ['VITB12', 'COBA', 'COBALAMIN']
    };
    
    for (const [vitCode, nutrientCodes] of Object.entries(vitaminMappings)) {
      const vitamin = vitamins.rows.find(v => v.code === vitCode);
      if (!vitamin) continue;
      
      for (const nCode of nutrientCodes) {
        const nutrient = nutrients.rows.find(n => 
          n.nutrient_code === nCode || 
          n.name.toUpperCase().includes(nCode) ||
          n.nutrient_code.toUpperCase().includes(nCode)
        );
        
        if (nutrient) {
          try {
            await client.query(`
              INSERT INTO VitaminNutrient (vitamin_id, nutrient_id, factor, notes)
              VALUES ($1, $2, 1.0, $3)
              ON CONFLICT (vitamin_id, nutrient_id) DO NOTHING
            `, [vitamin.vitamin_id, nutrient.nutrient_id, `Auto-mapped: ${nutrient.nutrient_code} -> ${vitCode}`]);
            
            vitaminMappingsCreated++;
            console.log(`✓ Mapped ${nutrient.nutrient_code} -> ${vitamin.name}`);
          } catch (err) {
            // Ignore duplicates
          }
        }
      }
    }
    
    // Mineral mappings
    const mineralMappings = {
      'MIN_CA': ['CA', 'CALCIUM'],
      'MIN_P': ['P', 'PHOS', 'PHOSPHORUS'],
      'MIN_MG': ['MG', 'MAGNESIUM'],
      'MIN_K': ['K', 'POTASSIUM'],
      'MIN_NA': ['NA', 'SODIUM'],
      'MIN_FE': ['FE', 'IRON'],
      'MIN_ZN': ['ZN', 'ZINC'],
      'MIN_CU': ['CU', 'COPPER'],
      'MIN_MN': ['MN', 'MANGANESE'],
      'MIN_SE': ['SE', 'SELENIUM'],
      'MIN_I': ['ID', 'IODINE'],
      'MIN_CR': ['CR', 'CHROMIUM'],
      'MIN_MO': ['MO', 'MOLYBDENUM'],
      'MIN_F': ['F', 'FLUORIDE', 'FLUOR']
    };
    
    for (const [minCode, nutrientCodes] of Object.entries(mineralMappings)) {
      const mineral = minerals.rows.find(m => m.code === minCode);
      if (!mineral) continue;
      
      for (const nCode of nutrientCodes) {
        const nutrient = nutrients.rows.find(n => 
          n.nutrient_code === nCode || 
          n.name.toUpperCase().includes(nCode) ||
          n.nutrient_code.toUpperCase().includes(nCode)
        );
        
        if (nutrient) {
          try {
            await client.query(`
              INSERT INTO MineralNutrient (mineral_id, nutrient_id, factor, notes)
              VALUES ($1, $2, 1.0, $3)
              ON CONFLICT (mineral_id, nutrient_id) DO NOTHING
            `, [mineral.mineral_id, nutrient.nutrient_id, `Auto-mapped: ${nutrient.nutrient_code} -> ${minCode}`]);
            
            mineralMappingsCreated++;
            console.log(`✓ Mapped ${nutrient.nutrient_code} -> ${mineral.name}`);
          } catch (err) {
            // Ignore duplicates
          }
        }
      }
    }
    
    console.log(`\n✅ Created ${vitaminMappingsCreated} vitamin mappings`);
    console.log(`✅ Created ${mineralMappingsCreated} mineral mappings`);
    
    // Verify final counts
    const vitCount = await client.query('SELECT COUNT(*) FROM VitaminNutrient');
    const minCount = await client.query('SELECT COUNT(*) FROM MineralNutrient');
    
    console.log(`\n📊 Total mappings in database:`);
    console.log(`   VitaminNutrient: ${vitCount.rows[0].count}`);
    console.log(`   MineralNutrient: ${minCount.rows[0].count}`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

populateNutrientMappings()
  .then(() => {
    console.log('\n🎉 Nutrient mapping population complete!');
    process.exit(0);
  })
  .catch((err) => {
    console.error('\n💥 Failed:', err);
    process.exit(1);
  });
