const db = require('./db');

const healthConditions = [
  {
    "condition_id": 1,
    "name_vi": "Tiểu đường type 2",
    "name_en": "Type 2 Diabetes",
    "category": "Chuyển hóa",
    "description": "Cơ thể kháng insulin làm đường huyết tăng cao.",
    "causes": "Thừa cân, ít vận động, ăn nhiều tinh bột tinh chế.",
    "nutrients_increase": [
      { "name": "Total Dietary Fiber", "percent": 40 },
      { "name": "Soluble Fiber", "percent": 30 },
      { "name": "Beta-Glucan", "percent": 20 },
      { "name": "Magnesium (Mg)", "percent": 15 },
      { "name": "Potassium (K)", "percent": 15 }
    ],
    "nutrients_decrease": [
      { "name": "Saturated Fat (SFA)", "percent": -20 }
    ],
    "treatment_duration": "Dài hạn",
    "foods_avoid": [
      "Cơm trắng", "Bánh mì", "Phở", "Bún", "Miến",
      "Bánh phở", "Đường", "Gạo nếp", "Bánh tráng"
    ]
  },
  {
    "condition_id": 2,
    "name_vi": "Cao huyết áp",
    "name_en": "Hypertension",
    "category": "Tim mạch",
    "description": "Huyết áp tăng cao mạn tính.",
    "causes": "Ăn mặn, ít kali, stress, di truyền.",
    "nutrients_increase": [
      { "name": "Potassium (K)", "percent": 30 },
      { "name": "Magnesium (Mg)", "percent": 20 },
      { "name": "Calcium (Ca)", "percent": 15 },
      { "name": "Total Dietary Fiber", "percent": 20 }
    ],
    "nutrients_decrease": [
      { "name": "Sodium (Na)", "percent": -50 }
    ],
    "treatment_duration": "Dài hạn",
    "foods_avoid": [
      "Nước mắm", "Hành phi", "Thịt lợn", "Đường"
    ]
  },
  {
    "condition_id": 3,
    "name_vi": "Mỡ máu cao",
    "name_en": "High Cholesterol",
    "category": "Tim mạch",
    "description": "LDL và Cholesterol cao dẫn đến xơ vữa mạch.",
    "causes": "Ăn nhiều mỡ bão hòa, trans fat, ít vận động.",
    "nutrients_increase": [
      { "name": "Monounsaturated Fat (MUFA)", "percent": 25 },
      { "name": "Polyunsaturated Fat (PUFA)", "percent": 25 },
      { "name": "EPA + DHA (combined)", "percent": 15 },
      { "name": "Total Dietary Fiber", "percent": 30 }
    ],
    "nutrients_decrease": [
      { "name": "Saturated Fat (SFA)", "percent": -40 },
      { "name": "Trans Fat (total)", "percent": -90 },
      { "name": "Cholesterol", "percent": -30 }
    ],
    "treatment_duration": "3–6 tháng",
    "foods_avoid": [
      "Thịt bò", "Thịt lợn", "Hành phi", "Trứng gà", "Đường"
    ]
  },
  {
    "condition_id": 4,
    "name_vi": "Béo phì",
    "name_en": "Obesity",
    "category": "Chuyển hóa",
    "description": "Tích lũy mỡ thừa do thừa năng lượng.",
    "causes": "Ăn nhiều tinh bột tinh chế, chất béo, ít hoạt động.",
    "nutrients_increase": [
      { "name": "Total Dietary Fiber", "percent": 50 },
      { "name": "Leucine", "percent": 20 },
      { "name": "Lysine", "percent": 20 },
      { "name": "Isoleucine", "percent": 20 }
    ],
    "nutrients_decrease": [
      { "name": "Total Fat", "percent": -30 },
      { "name": "Saturated Fat (SFA)", "percent": -30 }
    ],
    "treatment_duration": "3–12 tháng",
    "foods_avoid": [
      "Cơm trắng", "Bánh mì", "Phở", "Bún", "Miến",
      "Bánh tráng", "Đường", "Hành phi"
    ]
  },
  {
    "condition_id": 5,
    "name_vi": "Gout",
    "name_en": "Gout",
    "category": "Chuyển hóa",
    "description": "Acid uric cao gây viêm khớp.",
    "causes": "Ăn nhiều purine: thịt đỏ, hải sản.",
    "nutrients_increase": [
      { "name": "Total Dietary Fiber", "percent": 20 },
      { "name": "Vitamin C", "percent": 20 }
    ],
    "nutrients_decrease": [],
    "treatment_duration": "1–3 tháng (duy trì lâu dài)",
    "foods_avoid": [
      "Thịt bò", "Thịt lợn", "Tôm", "Cá"
    ]
  },
  {
    "condition_id": 6,
    "name_vi": "Gan nhiễm mỡ",
    "name_en": "Fatty Liver",
    "category": "Gan",
    "description": "Mỡ tích tụ trong gan.",
    "causes": "Dư đường, chất béo bão hòa, béo phì.",
    "nutrients_increase": [
      { "name": "Total Dietary Fiber", "percent": 30 },
      { "name": "EPA + DHA (combined)", "percent": 15 },
      { "name": "Vitamin E", "percent": 10 }
    ],
    "nutrients_decrease": [
      { "name": "Saturated Fat (SFA)", "percent": -30 },
      { "name": "Trans Fat (total)", "percent": -90 }
    ],
    "treatment_duration": "2–6 tháng",
    "foods_avoid": [
      "Đường", "Hành phi", "Thịt lợn", "Cơm trắng", "Gạo nếp"
    ]
  },
  {
    "condition_id": 7,
    "name_vi": "Viêm dạ dày",
    "name_en": "Gastritis",
    "category": "Tiêu hóa",
    "description": "Viêm niêm mạc dạ dày.",
    "causes": "HP, stress, đồ chua và dầu mỡ.",
    "nutrients_increase": [
      { "name": "Vitamin B12", "percent": 10 }
    ],
    "nutrients_decrease": [
      { "name": "Total Fat", "percent": -30 }
    ],
    "treatment_duration": "2–8 tuần",
    "foods_avoid": [
      "Dứa", "Hành phi"
    ]
  },
  {
    "condition_id": 8,
    "name_vi": "Thiếu máu",
    "name_en": "Anemia",
    "category": "Huyết học",
    "description": "Thiếu hồng cầu do thiếu sắt, B12 hoặc folate.",
    "causes": "Ăn thiếu sắt, thiếu vitamin B12 hoặc B9.",
    "nutrients_increase": [
      { "name": "Iron (Fe)", "percent": 50 },
      { "name": "Vitamin B12", "percent": 40 },
      { "name": "Vitamin B9 (Folate)", "percent": 30 },
      { "name": "Vitamin C", "percent": 30 }
    ],
    "nutrients_decrease": [],
    "treatment_duration": "1–3 tháng",
    "foods_avoid": []
  },
  {
    "condition_id": 9,
    "name_vi": "Suy dinh dưỡng",
    "name_en": "Malnutrition",
    "category": "Dinh dưỡng",
    "description": "Thiếu năng lượng và đạm.",
    "causes": "Ăn không đủ protein và năng lượng.",
    "nutrients_increase": [
      { "name": "Leucine", "percent": 50 },
      { "name": "Lysine", "percent": 50 },
      { "name": "Isoleucine", "percent": 50 },
      { "name": "Calcium (Ca)", "percent": 20 },
      { "name": "Phosphorus (P)", "percent": 20 }
    ],
    "nutrients_decrease": [],
    "treatment_duration": "1–3 tháng",
    "foods_avoid": []
  },
  {
    "condition_id": 10,
    "name_vi": "Dị ứng thực phẩm",
    "name_en": "Food Allergy",
    "category": "Miễn dịch",
    "description": "Phản ứng miễn dịch với protein thực phẩm.",
    "causes": "Cơ địa dị ứng, di truyền.",
    "nutrients_increase": [
      { "name": "Vitamin D", "percent": 10 },
      { "name": "Vitamin A", "percent": 10 }
    ],
    "nutrients_decrease": [],
    "treatment_duration": "Lâu dài",
    "foods_avoid": [
      "Trứng gà", "Tôm", "Sữa tươi", "Sữa chua"
    ]
  }
];

async function seedHealthConditions() {
  try {
    console.log('🏥 Starting health conditions seeding...\n');
    
    // Clear existing data
    console.log('Clearing existing data...');
    await db.query('TRUNCATE TABLE HealthCondition RESTART IDENTITY CASCADE');
    
    for (const condition of healthConditions) {
      console.log(`\n📋 Processing: ${condition.name_vi}`);
      
      // 1. Insert condition
      const conditionResult = await db.query(`
        INSERT INTO HealthCondition (name_vi, name_en, category, description, causes, treatment_duration_reference)
        VALUES ($1, $2, $3, $4, $5, $6)
        RETURNING condition_id
      `, [condition.name_vi, condition.name_en, condition.category, condition.description, condition.causes, condition.treatment_duration]);
      
      const conditionId = conditionResult.rows[0].condition_id;
      console.log(`  ✅ Created condition ID: ${conditionId}`);
      
      // 2. Insert nutrient effects (increase)
      for (const nutrient of condition.nutrients_increase) {
        const nutrientResult = await db.query(`
          SELECT nutrient_id FROM Nutrient WHERE name ILIKE $1 LIMIT 1
        `, [nutrient.name]);
        
        if (nutrientResult.rows.length > 0) {
          await db.query(`
            INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, adjustment_percent)
            VALUES ($1, $2, $3)
          `, [conditionId, nutrientResult.rows[0].nutrient_id, nutrient.percent]);
          console.log(`  ✅ Added nutrient effect: ${nutrient.name} +${nutrient.percent}%`);
        } else {
          console.log(`  ⚠️  Nutrient not found: ${nutrient.name}`);
        }
      }
      
      // 3. Insert nutrient effects (decrease)
      for (const nutrient of condition.nutrients_decrease) {
        const nutrientResult = await db.query(`
          SELECT nutrient_id FROM Nutrient WHERE name ILIKE $1 LIMIT 1
        `, [nutrient.name]);
        
        if (nutrientResult.rows.length > 0) {
          await db.query(`
            INSERT INTO ConditionNutrientEffect (condition_id, nutrient_id, adjustment_percent)
            VALUES ($1, $2, $3)
          `, [conditionId, nutrientResult.rows[0].nutrient_id, nutrient.percent]);
          console.log(`  ✅ Added nutrient effect: ${nutrient.name} ${nutrient.percent}%`);
        } else {
          console.log(`  ⚠️  Nutrient not found: ${nutrient.name}`);
        }
      }
      
      // 4. Insert food restrictions
      for (const foodName of condition.foods_avoid) {
        const foodResult = await db.query(`
          SELECT food_id FROM Food WHERE name ILIKE $1 LIMIT 1
        `, [foodName]);
        
        if (foodResult.rows.length > 0) {
          await db.query(`
            INSERT INTO ConditionFoodRecommendation (condition_id, food_id, recommendation_type, notes)
            VALUES ($1, $2, 'avoid', $3)
          `, [conditionId, foodResult.rows[0].food_id, `${foodName} không tốt cho ${condition.name_vi}`]);
          console.log(`  ✅ Added food restriction: ${foodName}`);
        } else {
          console.log(`  ⚠️  Food not found: ${foodName}`);
        }
      }
    }
    
    console.log('\n✅ ====== SEEDING COMPLETE ======');
    console.log('Total conditions created: 10');
    
    // Summary
    const stats = await db.query(`
      SELECT 
        (SELECT COUNT(*) FROM HealthCondition) as conditions,
        (SELECT COUNT(*) FROM ConditionNutrientEffect) as nutrient_effects,
        (SELECT COUNT(*) FROM ConditionFoodRecommendation) as food_restrictions
    `);
    
    console.log('\n📊 Summary:');
    console.log(`  - Conditions: ${stats.rows[0].conditions}`);
    console.log(`  - Nutrient Effects: ${stats.rows[0].nutrient_effects}`);
    console.log(`  - Food Restrictions: ${stats.rows[0].food_restrictions}`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding health conditions:', error);
    process.exit(1);
  }
}

seedHealthConditions();
