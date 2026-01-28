const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function addSampleHealthConditions() {
  const client = await pool.connect();
  
  try {
    await client.query('BEGIN');

    // Update Cao huyết áp
    await client.query(`
      UPDATE healthcondition SET
        article_link_vi = 'https://vinmec.com/vie/benh/cao-huyet-ap-6314',
        article_link_en = 'https://www.mayoclinic.org/diseases-conditions/high-blood-pressure/symptoms-causes/syc-20373410',
        prevention_tips_vi = 'Hạn chế muối, tăng cường kali, tập thể dục đều đặn, giảm stress, tránh rượu bia.',
        prevention_tips = 'Limit salt intake, increase potassium, regular exercise, reduce stress, avoid alcohol.',
        severity_level = 'moderate',
        is_chronic = true,
        image_url = COALESCE(image_url, 'https://cdn.tgdd.vn/Files/2021/06/15/1358975/cao-huyet-ap-nguyen-nhan-trieu-chung-dieu-tri-va-phong-ngua-202106151442072634.jpg')
      WHERE name_vi = 'Cao huyết áp'
    `);
    console.log('✓ Updated Cao huyết áp');

    // Update Tiểu đường
    await client.query(`
      UPDATE healthcondition SET
        article_link_vi = 'https://vinmec.com/vie/benh/dai-thao-duong-type-2-6521',
        article_link_en = 'https://www.mayoclinic.org/diseases-conditions/type-2-diabetes/symptoms-causes/syc-20351193',
        prevention_tips_vi = 'Duy trì cân nặng hợp lý, tập thể dục, ăn ít đường và tinh bột tinh chế, tăng chất xơ.',
        prevention_tips = 'Maintain healthy weight, regular exercise, limit sugar and refined carbs, increase fiber.',
        severity_level = 'moderate',
        is_chronic = true,
        image_url = COALESCE(image_url, 'https://cdn.tgdd.vn/Files/2022/02/01/1414070/tieu-duong-type-2-la-gi-nguyen-nhan-va-cach-phong-ngua-202202011434196274.jpg')
      WHERE name_vi LIKE '%Tiểu đường%' OR name_vi LIKE '%Đái tháo đường%'
    `);
    console.log('✓ Updated Diabetes');

    // Update Mỡ máu cao
    await client.query(`
      UPDATE healthcondition SET
        article_link_vi = 'https://vinmec.com/vie/benh/cholesterol-6325',
        article_link_en = 'https://www.mayoclinic.org/diseases-conditions/high-blood-cholesterol/symptoms-causes/syc-20350800',
        prevention_tips_vi = 'Ăn ít chất béo bão hòa, tăng omega-3, tập thể dục, giảm cân nếu thừa cân.',
        prevention_tips = 'Reduce saturated fats, increase omega-3, exercise regularly, lose weight if overweight.',
        severity_level = 'moderate',
        is_chronic = true,
        image_url = COALESCE(image_url, 'https://cdn.tgdd.vn/Files/2021/07/21/1367511/mo-mau-cao-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202107211537588654.jpg')
      WHERE name_vi = 'Mỡ máu cao'
    `);
    console.log('✓ Updated High Cholesterol');

    // Update Gout
    await client.query(`
      UPDATE healthcondition SET
        article_link_vi = 'https://vinmec.com/vie/benh/gout-6336',
        article_link_en = 'https://www.mayoclinic.org/diseases-conditions/gout/symptoms-causes/syc-20372897',
        prevention_tips_vi = 'Hạn chế thực phẩm giàu purin (nội tạng, hải sản), uống nhiều nước, giảm rượu bia.',
        prevention_tips = 'Limit purine-rich foods (organ meats, seafood), drink plenty of water, reduce alcohol.',
        severity_level = 'moderate',
        is_chronic = true,
        image_url = COALESCE(image_url, 'https://cdn.tgdd.vn/Files/2021/08/11/1374175/benh-gout-la-gi-nguyen-nhan-trieu-chung-va-cach-dieu-tri-202108111051177484.jpg')
      WHERE name_vi = 'Gout'
    `);
    console.log('✓ Updated Gout');

    // Update Béo phì
    await client.query(`
      UPDATE healthcondition SET
        article_link_vi = 'https://vinmec.com/vie/benh/beo-phi-6350',
        article_link_en = 'https://www.mayoclinic.org/diseases-conditions/obesity/symptoms-causes/syc-20375742',
        prevention_tips_vi = 'Ăn uống lành mạnh, tập thể dục đều đặn, ngủ đủ giấc, quản lý stress.',
        prevention_tips = 'Healthy eating, regular exercise, adequate sleep, stress management.',
        severity_level = 'moderate',
        is_chronic = true,
        image_url = COALESCE(image_url, 'https://cdn.tgdd.vn/Files/2022/03/15/1418986/beo-phi-la-gi-nguyen-nhan-va-cach-phong-ngua-202203151420581234.jpg')
      WHERE name_vi = 'Béo phì'
    `);
    console.log('✓ Updated Obesity');

    await client.query('COMMIT');
    console.log('\n✅ All health conditions updated successfully!');

    // Display results
    const result = await client.query(`
      SELECT 
        condition_id, 
        name_vi, 
        name_en,
        severity_level, 
        is_chronic,
        CASE WHEN article_link_vi IS NOT NULL THEN 'Yes' ELSE 'No' END as has_article,
        CASE WHEN prevention_tips_vi IS NOT NULL THEN 'Yes' ELSE 'No' END as has_prevention
      FROM healthcondition 
      WHERE name_vi IN ('Cao huyết áp', 'Mỡ máu cao', 'Gout', 'Béo phì')
         OR name_vi LIKE '%Tiểu đường%'
         OR name_vi LIKE '%Đái tháo đường%'
      ORDER BY condition_id
    `);

    console.log('\nUpdated Conditions:');
    console.table(result.rows);

  } catch (error) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

require('dotenv').config();
addSampleHealthConditions();
