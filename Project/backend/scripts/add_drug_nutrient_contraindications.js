const { Pool } = require('pg');
require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });

// ============================================================================
// DRUG-NUTRIENT CONTRAINDICATIONS
// Based on common medical knowledge about drug interactions
// ============================================================================

const DRUG_NUTRIENT_CONTRAINDICATIONS = [
  // WARFARIN - Vitamin K interaction (critically important)
  { drug: 'Warfarin', nutrient: 'Vitamin K', nutrient_id: 14, avoid_before: 0, avoid_after: 0, severity: 'high',
    warning_vi: 'Vitamin K có thể làm giảm hiệu quả của thuốc chống đông máu. Tránh thay đổi đột ngột lượng rau xanh trong chế độ ăn.',
    warning_en: 'Vitamin K can reduce anticoagulant effectiveness. Avoid sudden changes in green vegetable intake.' },
  
  // LEVOTHYROXINE - Calcium, Iron
  { drug: 'Levothyroxine', nutrient: 'Calcium (Ca)', nutrient_id: 24, avoid_before: 4, avoid_after: 4, severity: 'high',
    warning_vi: 'Canxi làm giảm hấp thu hormone tuyến giáp. Uống thuốc cách xa sữa, phô mai 4 giờ.',
    warning_en: 'Calcium reduces thyroid hormone absorption. Take medication 4 hours away from dairy.' },
  { drug: 'Levothyroxine', nutrient: 'Iron (Fe)', nutrient_id: 29, avoid_before: 4, avoid_after: 4, severity: 'high',
    warning_vi: 'Sắt làm giảm hấp thu hormone tuyến giáp. Uống thuốc cách xa thực phẩm giàu sắt 4 giờ.',
    warning_en: 'Iron reduces thyroid hormone absorption. Take medication 4 hours away from iron-rich foods.' },
  
  // ISONIAZID (Tuberculosis) - Vitamin B6
  { drug: 'Isoniazid', nutrient: 'Vitamin B6 (Pyridoxine)', nutrient_id: 20, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Isoniazid làm giảm Vitamin B6. Bác sĩ có thể kê bổ sung Vitamin B6.',
    warning_en: 'Isoniazid depletes Vitamin B6. Doctor may prescribe B6 supplement.' },
  
  // METFORMIN - Vitamin B12
  { drug: 'Metformin', nutrient: 'Vitamin B12 (Cobalamin)', nutrient_id: 23, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Sử dụng lâu dài có thể làm giảm Vitamin B12. Kiểm tra định kỳ.',
    warning_en: 'Long-term use may reduce Vitamin B12. Regular monitoring recommended.' },
  
  // STATINS (Atorvastatin, Simvastatin) - Grapefruit effect (use Vitamin C as proxy)
  { drug: 'Atorvastatin', nutrient: 'Vitamin C', nutrient_id: 15, avoid_before: 2, avoid_after: 2, severity: 'medium',
    warning_vi: 'Bưởi có thể tăng nồng độ thuốc trong máu. Tránh bưởi và nước ép bưởi.',
    warning_en: 'Grapefruit can increase drug levels. Avoid grapefruit and grapefruit juice.' },
  { drug: 'Simvastatin', nutrient: 'Vitamin C', nutrient_id: 15, avoid_before: 2, avoid_after: 2, severity: 'high',
    warning_vi: 'Bưởi có thể tăng nguy cơ tác dụng phụ. Hoàn toàn tránh bưởi.',
    warning_en: 'Grapefruit can increase side effect risk. Completely avoid grapefruit.' },
  
  // ACE INHIBITORS (Enalapril, Losartan) - Potassium
  { drug: 'Enalapril', nutrient: 'Potassium (K)', nutrient_id: 27, avoid_before: 0, avoid_after: 0, severity: 'medium',
    warning_vi: 'Có thể làm tăng kali máu. Hạn chế thực phẩm giàu kali như chuối, khoai tây.',
    warning_en: 'May increase blood potassium. Limit potassium-rich foods like bananas, potatoes.' },
  { drug: 'Losartan', nutrient: 'Potassium (K)', nutrient_id: 27, avoid_before: 0, avoid_after: 0, severity: 'medium',
    warning_vi: 'Có thể làm tăng kali máu. Hạn chế thực phẩm giàu kali.',
    warning_en: 'May increase blood potassium. Limit potassium-rich foods.' },
  
  // SPIRONOLACTONE - Potassium
  { drug: 'Spironolactone', nutrient: 'Potassium (K)', nutrient_id: 27, avoid_before: 0, avoid_after: 0, severity: 'high',
    warning_vi: 'Thuốc giữ kali. Tránh bổ sung kali và hạn chế thực phẩm giàu kali.',
    warning_en: 'Potassium-sparing diuretic. Avoid potassium supplements and limit potassium-rich foods.' },
  
  // DIGOXIN - Calcium, Magnesium
  { drug: 'Digoxin', nutrient: 'Calcium (Ca)', nutrient_id: 24, avoid_before: 2, avoid_after: 2, severity: 'high',
    warning_vi: 'Canxi cao có thể gây rối loạn nhịp tim. Tránh bổ sung canxi liều cao.',
    warning_en: 'High calcium may cause heart rhythm problems. Avoid high-dose calcium supplements.' },
  { drug: 'Digoxin', nutrient: 'Magnesium (Mg)', nutrient_id: 26, avoid_before: 2, avoid_after: 2, severity: 'medium',
    warning_vi: 'Magie thấp có thể tăng độc tính digoxin. Duy trì mức magie bình thường.',
    warning_en: 'Low magnesium may increase digoxin toxicity. Maintain normal magnesium levels.' },
  
  // QUINOLONE ANTIBIOTICS (Ciprofloxacin) - Calcium, Iron, Zinc
  { drug: 'Ciprofloxacin', nutrient: 'Calcium (Ca)', nutrient_id: 24, avoid_before: 2, avoid_after: 6, severity: 'high',
    warning_vi: 'Canxi làm giảm mạnh hấp thu kháng sinh. Tránh sữa 2 giờ trước, 6 giờ sau uống thuốc.',
    warning_en: 'Calcium significantly reduces antibiotic absorption. Avoid dairy 2h before, 6h after.' },
  { drug: 'Ciprofloxacin', nutrient: 'Iron (Fe)', nutrient_id: 29, avoid_before: 2, avoid_after: 6, severity: 'high',
    warning_vi: 'Sắt làm giảm hấp thu kháng sinh. Tránh thực phẩm giàu sắt 2-6 giờ.',
    warning_en: 'Iron reduces antibiotic absorption. Avoid iron-rich foods 2-6 hours.' },
  { drug: 'Ciprofloxacin', nutrient: 'Zinc (Zn)', nutrient_id: 30, avoid_before: 2, avoid_after: 6, severity: 'medium',
    warning_vi: 'Kẽm làm giảm hấp thu kháng sinh. Tránh bổ sung kẽm 2-6 giờ.',
    warning_en: 'Zinc reduces antibiotic absorption. Avoid zinc supplements 2-6 hours.' },
  
  // ALENDRONATE (Osteoporosis) - Calcium
  { drug: 'Alendronate', nutrient: 'Calcium (Ca)', nutrient_id: 24, avoid_before: 0.5, avoid_after: 2, severity: 'high',
    warning_vi: 'Uống thuốc lúc đói, 30 phút trước ăn sáng. Tránh canxi 2 giờ sau uống thuốc.',
    warning_en: 'Take on empty stomach, 30 min before breakfast. Avoid calcium 2 hours after.' },
  
  // IRON SUPPLEMENTS - Calcium
  { drug: 'Sắt sulfat', nutrient: 'Calcium (Ca)', nutrient_id: 24, avoid_before: 2, avoid_after: 2, severity: 'medium',
    warning_vi: 'Canxi cản trở hấp thu sắt. Uống thuốc sắt cách xa sữa 2 giờ.',
    warning_en: 'Calcium interferes with iron absorption. Take iron 2 hours away from dairy.' },
  
  // METHOTREXATE - Folic Acid
  { drug: 'Methotrexate', nutrient: 'Vitamin B9 (Folate)', nutrient_id: 22, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Thuốc làm giảm folate. Bác sĩ thường kê bổ sung acid folic.',
    warning_en: 'Drug depletes folate. Doctor usually prescribes folic acid supplement.' },
  
  // FUROSEMIDE - Potassium, Magnesium
  { drug: 'Furosemide', nutrient: 'Potassium (K)', nutrient_id: 27, avoid_before: 0, avoid_after: 0, severity: 'medium',
    warning_vi: 'Thuốc lợi tiểu làm mất kali. Ăn nhiều thực phẩm giàu kali hoặc bổ sung theo chỉ định.',
    warning_en: 'Diuretic causes potassium loss. Eat potassium-rich foods or supplement as directed.' },
  { drug: 'Furosemide', nutrient: 'Magnesium (Mg)', nutrient_id: 26, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Có thể làm giảm magie. Xem xét bổ sung nếu có triệu chứng.',
    warning_en: 'May reduce magnesium. Consider supplement if symptoms occur.' },
  
  // OMEPRAZOLE/ESOMEPRAZOLE - Vitamin B12, Magnesium
  { drug: 'Omeprazole', nutrient: 'Vitamin B12 (Cobalamin)', nutrient_id: 23, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Sử dụng lâu dài có thể giảm hấp thu Vitamin B12. Kiểm tra định kỳ.',
    warning_en: 'Long-term use may reduce B12 absorption. Regular monitoring recommended.' },
  { drug: 'Omeprazole', nutrient: 'Magnesium (Mg)', nutrient_id: 26, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Sử dụng lâu dài có thể làm giảm magie. Xét nghiệm nếu có triệu chứng.',
    warning_en: 'Long-term use may reduce magnesium. Test if symptoms occur.' },
  { drug: 'Esomeprazole', nutrient: 'Vitamin B12 (Cobalamin)', nutrient_id: 23, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Sử dụng lâu dài có thể giảm hấp thu Vitamin B12.',
    warning_en: 'Long-term use may reduce B12 absorption.' },
  { drug: 'Esomeprazole', nutrient: 'Magnesium (Mg)', nutrient_id: 26, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Sử dụng lâu dài có thể làm giảm magie.',
    warning_en: 'Long-term use may reduce magnesium.' },
  
  // RIFAMPICIN - Vitamin D
  { drug: 'Rifampicin', nutrient: 'Vitamin D', nutrient_id: 12, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Có thể làm giảm Vitamin D. Xem xét bổ sung Vitamin D.',
    warning_en: 'May reduce Vitamin D. Consider Vitamin D supplementation.' },
  
  // AZITHROMYCIN - Magnesium
  { drug: 'Azithromycin', nutrient: 'Magnesium (Mg)', nutrient_id: 26, avoid_before: 2, avoid_after: 2, severity: 'low',
    warning_vi: 'Magie có thể làm giảm hấp thu kháng sinh. Uống cách xa 2 giờ.',
    warning_en: 'Magnesium may reduce antibiotic absorption. Take 2 hours apart.' },
  
  // AMOXICILLIN - Vitamin K
  { drug: 'Amoxicillin', nutrient: 'Vitamin K', nutrient_id: 14, avoid_before: 0, avoid_after: 0, severity: 'low',
    warning_vi: 'Kháng sinh có thể giảm vi khuẩn đường ruột sản xuất Vitamin K.',
    warning_en: 'Antibiotic may reduce gut bacteria producing Vitamin K.' },
];

async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432'),
    database: process.env.DB_NAME || 'Health',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'Kiet2004',
  });

  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');
    console.log('🚀 Adding drug-nutrient contraindications...\n');

    // Get all drugs and nutrients
    const drugResult = await client.query('SELECT drug_id, name_vi, name_en, generic_name FROM drug');
    const drugMap = new Map();
    drugResult.rows.forEach(d => {
      const names = [d.name_vi, d.name_en, d.generic_name].filter(n => n);
      names.forEach(name => drugMap.set(name, d.drug_id));
    });

    const nutrientResult = await client.query('SELECT nutrient_id, name, name_vi FROM nutrient');
    const nutrientMap = new Map();
    nutrientResult.rows.forEach(n => {
      if (n.name) nutrientMap.set(n.name, n.nutrient_id);
      if (n.name_vi) nutrientMap.set(n.name_vi, n.nutrient_id);
    });

    console.log(`Found ${drugMap.size} drug name mappings`);
    console.log(`Found ${nutrientMap.size} nutrient name mappings\n`);

    let addedCount = 0;
    let skippedDrug = 0;
    let skippedNutrient = 0;

    for (const contra of DRUG_NUTRIENT_CONTRAINDICATIONS) {
      const drugId = drugMap.get(contra.drug);
      if (!drugId) {
        console.log(`⚠️  Drug not found: ${contra.drug}`);
        skippedDrug++;
        continue;
      }

      const nutrientId = contra.nutrient_id; // Use hardcoded nutrient_id

      // Check if already exists
      const existing = await client.query(
        'SELECT contra_id FROM drugnutrientcontraindication WHERE drug_id = $1 AND nutrient_id = $2',
        [drugId, nutrientId]
      );

      if (existing.rows.length > 0) {
        console.log(`⏭️  Already exists: ${contra.drug} + ${contra.nutrient}`);
        continue;
      }

      // Insert contraindication
      await client.query(
        `INSERT INTO drugnutrientcontraindication 
         (drug_id, nutrient_id, avoid_hours_before, avoid_hours_after, warning_message_vi, warning_message_en, severity, created_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, CURRENT_TIMESTAMP)`,
        [drugId, nutrientId, contra.avoid_before, contra.avoid_after, contra.warning_vi, contra.warning_en, contra.severity]
      );

      addedCount++;
      console.log(`✅ Added: ${contra.drug} + ${contra.nutrient} (${contra.severity})`);
    }

    await client.query('COMMIT');

    console.log(`\n📊 Summary:`);
    console.log(`✅ Added ${addedCount} contraindications`);
    console.log(`⚠️  Skipped ${skippedDrug} (drug not found)`);
    console.log(`⚠️  Skipped ${skippedNutrient} (nutrient not found)`);

    // Verify
    const totalContras = await client.query('SELECT COUNT(*) FROM drugnutrientcontraindication');
    console.log(`\n📈 Total contraindications in database: ${totalContras.rows[0].count}`);

    // Show stats by severity
    const bySeverity = await client.query(`
      SELECT severity, COUNT(*) as count
      FROM drugnutrientcontraindication
      GROUP BY severity
      ORDER BY 
        CASE severity 
          WHEN 'high' THEN 1 
          WHEN 'medium' THEN 2 
          WHEN 'low' THEN 3 
        END
    `);
    
    console.log(`\nBy severity:`);
    bySeverity.rows.forEach(row => {
      console.log(`  ${row.severity.toUpperCase()}: ${row.count}`);
    });

    console.log('\n✅ Drug-nutrient contraindications added successfully! 🎉');

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(console.error);
