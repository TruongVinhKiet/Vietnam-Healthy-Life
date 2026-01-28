require('dotenv').config();
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

async function addMissingData() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('ADDING MISSING DATA FOR REMAINING CONDITIONS');
    console.log('='.repeat(80));

    await client.query('BEGIN');

    // Add missing drugs with corrected names
    console.log('\n📦 Adding missing drugs...');
    const missingDrugs = [
      { name_vi: 'Sắt Sulfat', name_en: 'Ferrous Sulfate', description: 'Bổ sung sắt điều trị thiếu máu do thiếu sắt', drug_class: 'Bổ sung vitamin khoáng' },
      { name_vi: 'Acid Folic', name_en: 'Folic Acid', description: 'Vitamin B9, điều trị thiếu máu do thiếu folate', drug_class: 'Bổ sung vitamin khoáng' },
      { name_vi: 'Vitamin B12', name_en: 'Cyanocobalamin', description: 'Điều trị thiếu máu do thiếu vitamin B12', drug_class: 'Bổ sung vitamin khoáng' },
      { name_vi: 'Canxi và Vitamin D', name_en: 'Calcium and Vitamin D', description: 'Bổ sung canxi và vitamin D phòng ngừa loãng xương', drug_class: 'Bổ sung vitamin khoáng' },
      { name_vi: 'ORS (Oral Rehydration Salts)', name_en: 'ORS', description: 'Dung dịch bù nước điện giải điều trị tiêu chảy', drug_class: 'Điều trị tiêu chảy' },
      { name_vi: 'Loperamide', name_en: 'Loperamide', description: 'Thuốc chống tiêu chảy', drug_class: 'Điều trị tiêu chảy' },
    ];

    for (const drug of missingDrugs) {
      const existing = await client.query('SELECT drug_id FROM drug WHERE name_en = $1', [drug.name_en]);
      if (existing.rows.length === 0) {
        await client.query(`
          INSERT INTO drug (name_vi, name_en, description, drug_class, is_active, created_at)
          VALUES ($1, $2, $3, $4, true, NOW())
        `, [drug.name_vi, drug.name_en, drug.description, drug.drug_class]);
        console.log(`  ✓ Added ${drug.name_en}`);
      }
    }

    // Get drug IDs
    const getDrugId = async (name_en) => {
      const result = await client.query('SELECT drug_id FROM drug WHERE name_en = $1', [name_en]);
      return result.rows[0]?.drug_id;
    };

    // Add drug relationships for remaining conditions
    console.log('\n💊 Adding drug relationships...');
    
    const additionalRelationships = [
      // Anemia (8, 14)
      { drugName: 'Ferrous Sulfate', conditionId: 8, notes_vi: 'Bổ sung sắt điều trị thiếu máu', isPrimary: true },
      { drugName: 'Ferrous Sulfate', conditionId: 14, notes_vi: 'Điều trị thiếu máu do thiếu sắt', isPrimary: true },
      { drugName: 'Folic Acid', conditionId: 8, notes_vi: 'Điều trị thiếu máu do thiếu acid folic', isPrimary: true },
      { drugName: 'Cyanocobalamin', conditionId: 8, notes_vi: 'Điều trị thiếu máu do thiếu B12', isPrimary: false },
      { drugName: 'Cyanocobalamin', conditionId: 14, notes_vi: 'Phối hợp sắt nếu thiếu B12', isPrimary: false },
      
      // Osteoporosis (15)
      { drugName: 'Calcium and Vitamin D', conditionId: 15, notes_vi: 'Bổ sung canxi và vitamin D hàng ngày', isPrimary: true },
      
      // Obesity (4)
      { drugName: 'Metformin', conditionId: 4, notes_vi: 'Hỗ trợ giảm cân ở bệnh nhân béo phì có kháng insulin', isPrimary: false },
      
      // Cholera (20)
      { drugName: 'ORS', conditionId: 20, notes_vi: 'Bù nước điện giải điều trị bệnh tả', isPrimary: true },
      { drugName: 'Ciprofloxacin', conditionId: 20, notes_vi: 'Kháng sinh điều trị bệnh tả nặng', isPrimary: true },
      
      // Typhoid (21)
      { drugName: 'Ciprofloxacin', conditionId: 21, notes_vi: 'Kháng sinh đầu tay điều trị sốt thương hàn', isPrimary: true },
      { drugName: 'Azithromycin', conditionId: 21, notes_vi: 'Kháng sinh thay thế khi kháng ciprofloxacin', isPrimary: true },
      
      // Malnutrition (9)
      { drugName: 'Folic Acid', conditionId: 9, notes_vi: 'Bổ sung vitamin trong suy dinh dưỡng', isPrimary: false },
      { drugName: 'Cyanocobalamin', conditionId: 9, notes_vi: 'Bổ sung vitamin B12', isPrimary: false },
      
      // Food Allergy (10) - symptomatic treatment
      { drugName: 'Paracetamol', conditionId: 10, notes_vi: 'Giảm triệu chứng sốt, đau do dị ứng nhẹ', isPrimary: false },
    ];

    for (const rel of additionalRelationships) {
      const drugId = await getDrugId(rel.drugName);
      if (drugId) {
        await client.query(`
          INSERT INTO drughealthcondition (drug_id, condition_id, treatment_notes_vi, treatment_notes, is_primary, created_at)
          VALUES ($1, $2, $3, $4, $5, NOW())
          ON CONFLICT (drug_id, condition_id) DO NOTHING
        `, [drugId, rel.conditionId, rel.notes_vi, rel.notes_vi, rel.isPrimary]);
        console.log(`  ✓ Added ${rel.drugName} for condition ${rel.conditionId}`);
      }
    }

    // Update remaining conditions with full information
    console.log('\n📝 Updating condition information...');
    
    const conditionUpdates = [
      { id: 4, image: 'https://cdn.tgdd.vn/Files/2022/03/15/1418986/beo-phi-la-gi-nguyen-nhan-va-cach-phong-ngua-202203151420581234.jpg', article_vi: 'https://vinmec.com/vie/benh/beo-phi-6350', article_en: 'https://www.mayoclinic.org/diseases-conditions/obesity/symptoms-causes/syc-20375742', prevention_vi: 'Ăn uống lành mạnh, tập thể dục đều đặn, ngủ đủ giấc, quản lý stress', severity: 'moderate', is_chronic: true },
      { id: 8, image: 'https://cdn.tgdd.vn/Files/2021/10/12/1389456/thieu-mau-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202110121105076789.jpg', article_vi: 'https://vinmec.com/vie/benh/thieu-mau-6365', article_en: 'https://www.mayoclinic.org/diseases-conditions/anemia/symptoms-causes/syc-20351360', prevention_vi: 'Ăn thực phẩm giàu sắt, vitamin B12, acid folic', severity: 'moderate', is_chronic: false },
      { id: 9, image: 'https://cdn.tgdd.vn/Files/2021/11/15/1399123/suy-dinh-duong-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202111151428099999.jpg', article_vi: 'https://vinmec.com/vie/benh/suy-dinh-duong-6370', article_en: 'https://www.mayoclinic.org/diseases-conditions/malnutrition/symptoms-causes/syc-20374428', prevention_vi: 'Chế độ ăn đa dạng, đầy đủ dinh dưỡng, theo dõi cân nặng', severity: 'severe', is_chronic: false },
      { id: 10, image: 'https://cdn.tgdd.vn/Files/2021/09/20/1383678/di-ung-thuc-pham-nguyen-nhan-trieu-chung-va-cach-phong-ngua-202109201039277777.jpg', article_vi: 'https://vinmec.com/vie/benh/di-ung-thuc-pham-6375', article_en: 'https://www.mayoclinic.org/diseases-conditions/food-allergy/symptoms-causes/syc-20355095', prevention_vi: 'Tránh tiếp xúc thực phẩm gây dị ứng, đọc nhãn thực phẩm kỹ', severity: 'mild', is_chronic: true },
    ];

    for (const update of conditionUpdates) {
      await client.query(`
        UPDATE healthcondition SET
          image_url = COALESCE(image_url, $1),
          article_link_vi = COALESCE(article_link_vi, $2),
          article_link_en = COALESCE(article_link_en, $3),
          prevention_tips_vi = COALESCE(prevention_tips_vi, $4),
          prevention_tips = COALESCE(prevention_tips, $4),
          severity_level = COALESCE(severity_level, $5),
          is_chronic = COALESCE(is_chronic, $6),
          updated_at = NOW()
        WHERE condition_id = $7
      `, [update.image, update.article_vi, update.article_en, update.prevention_vi, update.severity, update.is_chronic, update.id]);
      console.log(`  ✓ Updated condition ${update.id}`);
    }

    await client.query('COMMIT');

    // Final report
    console.log('\n' + '='.repeat(80));
    console.log('FINAL COMPREHENSIVE REPORT');
    console.log('='.repeat(80));

    const finalStats = await client.query(`
      SELECT 
        COUNT(DISTINCT hc.condition_id) as total_conditions,
        COUNT(DISTINCT CASE WHEN dhc.drug_id IS NOT NULL THEN hc.condition_id END) as conditions_with_drugs,
        COUNT(DISTINCT d.drug_id) as total_drugs,
        COUNT(*) FILTER (WHERE dhc.drug_id IS NOT NULL) as total_relationships,
        COUNT(DISTINCT CASE WHEN hc.article_link_vi IS NOT NULL THEN hc.condition_id END) as conditions_with_articles,
        COUNT(DISTINCT CASE WHEN hc.prevention_tips_vi IS NOT NULL THEN hc.condition_id END) as conditions_with_prevention,
        COUNT(DISTINCT CASE WHEN hc.image_url IS NOT NULL THEN hc.condition_id END) as conditions_with_images
      FROM healthcondition hc
      LEFT JOIN drughealthcondition dhc ON hc.condition_id = dhc.condition_id
      LEFT JOIN drug d ON dhc.drug_id = d.drug_id
    `);

    console.log('\n📊 Database Statistics:');
    console.table(finalStats.rows);

    const conditionsSummary = await client.query(`
      SELECT 
        hc.condition_id,
        hc.name_vi,
        COUNT(dhc.drug_id) as drugs,
        CASE WHEN hc.article_link_vi IS NOT NULL THEN '✓' ELSE '✗' END as article,
        CASE WHEN hc.prevention_tips_vi IS NOT NULL THEN '✓' ELSE '✗' END as prevention,
        CASE WHEN hc.image_url IS NOT NULL THEN '✓' ELSE '✗' END as image
      FROM healthcondition hc
      LEFT JOIN drughealthcondition dhc ON hc.condition_id = dhc.condition_id
      GROUP BY hc.condition_id, hc.name_vi, hc.article_link_vi, hc.prevention_tips_vi, hc.image_url
      ORDER BY hc.condition_id
    `);

    console.log('\n📋 All 39 Conditions Summary:');
    console.table(conditionsSummary.rows);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

addMissingData();
