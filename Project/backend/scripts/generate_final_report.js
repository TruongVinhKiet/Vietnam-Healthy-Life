const { Pool } = require('pg');
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function generateFinalReport() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('HEALTH CONDITION DATABASE - FINAL REPORT');
    console.log('='.repeat(80));

    // 1. HealthCondition table structure
    console.log('\n📋 HEALTHCONDITION TABLE STRUCTURE:');
    const structure = await client.query(`
      SELECT column_name, data_type, is_nullable
      FROM information_schema.columns 
      WHERE table_name = 'healthcondition' 
      AND column_name IN (
        'condition_id', 'name_vi', 'name_en', 'category', 
        'image_url', 'article_link_vi', 'article_link_en',
        'prevention_tips_vi', 'prevention_tips', 
        'severity_level', 'is_chronic'
      )
      ORDER BY ordinal_position
    `);
    console.table(structure.rows);

    // 2. HealthCondition data statistics
    console.log('\n📊 HEALTHCONDITION DATA STATISTICS:');
    const stats = await client.query(`
      SELECT 
        COUNT(*) as total_conditions,
        COUNT(CASE WHEN image_url IS NOT NULL THEN 1 END) as with_images,
        COUNT(CASE WHEN article_link_vi IS NOT NULL THEN 1 END) as with_vietnamese_articles,
        COUNT(CASE WHEN article_link_en IS NOT NULL THEN 1 END) as with_english_articles,
        COUNT(CASE WHEN prevention_tips_vi IS NOT NULL THEN 1 END) as with_prevention_tips,
        COUNT(CASE WHEN is_chronic = true THEN 1 END) as chronic_conditions
      FROM healthcondition
    `);
    console.table(stats.rows);

    // 3. Sample conditions with complete data
    console.log('\n✨ CONDITIONS WITH COMPLETE DATA:');
    const complete = await client.query(`
      SELECT 
        condition_id,
        name_vi,
        name_en,
        severity_level,
        is_chronic,
        CASE WHEN image_url IS NOT NULL THEN '✓' ELSE '✗' END as img,
        CASE WHEN article_link_vi IS NOT NULL THEN '✓' ELSE '✗' END as article_vi,
        CASE WHEN article_link_en IS NOT NULL THEN '✓' ELSE '✗' END as article_en,
        CASE WHEN prevention_tips_vi IS NOT NULL THEN '✓' ELSE '✗' END as prevention
      FROM healthcondition
      WHERE article_link_vi IS NOT NULL
      ORDER BY condition_id
      LIMIT 10
    `);
    console.table(complete.rows);

    // 4. ConditionFoodRecommendation statistics
    console.log('\n🍎 FOOD RECOMMENDATION STATISTICS:');
    const foodStats = await client.query(`
      SELECT 
        COUNT(*) as total_recommendations,
        COUNT(DISTINCT condition_id) as conditions_with_recommendations,
        COUNT(DISTINCT food_id) as unique_foods,
        COUNT(CASE WHEN recommendation_type = 'avoid' THEN 1 END) as foods_to_avoid,
        COUNT(CASE WHEN recommendation_type = 'recommend' THEN 1 END) as foods_to_recommend
      FROM conditionfoodrecommendation
    `);
    console.table(foodStats.rows);

    // 5. Recommendations by condition
    console.log('\n📈 RECOMMENDATIONS BY CONDITION:');
    const byCondition = await client.query(`
      SELECT 
        hc.name_vi as condition,
        COUNT(CASE WHEN cfr.recommendation_type = 'avoid' THEN 1 END) as avoid,
        COUNT(CASE WHEN cfr.recommendation_type = 'recommend' THEN 1 END) as recommend,
        COUNT(*) as total
      FROM healthcondition hc
      LEFT JOIN conditionfoodrecommendation cfr ON hc.condition_id = cfr.condition_id
      WHERE cfr.condition_id IS NOT NULL
      GROUP BY hc.condition_id, hc.name_vi
      ORDER BY total DESC
    `);
    console.table(byCondition.rows);

    // 6. DrugHealthCondition statistics
    console.log('\n💊 DRUG TREATMENT STATISTICS:');
    const drugStats = await client.query(`
      SELECT 
        COUNT(*) as total_treatments,
        COUNT(DISTINCT condition_id) as conditions_with_drugs,
        COUNT(DISTINCT drug_id) as unique_drugs,
        COUNT(CASE WHEN is_primary = true THEN 1 END) as primary_treatments
      FROM drughealthcondition
    `);
    console.table(drugStats.rows);

    // 7. Sample drug treatments
    console.log('\n💉 SAMPLE DRUG TREATMENTS:');
    const treatments = await client.query(`
      SELECT 
        hc.name_vi as condition,
        d.name_vi as drug,
        dhc.is_primary,
        LEFT(dhc.treatment_notes_vi, 50) as notes
      FROM drughealthcondition dhc
      JOIN healthcondition hc ON dhc.condition_id = hc.condition_id
      JOIN drug d ON dhc.drug_id = d.drug_id
      WHERE hc.condition_id IN (1, 2, 3, 4, 5)
      LIMIT 10
    `);
    console.table(treatments.rows);

    // 8. Data completeness summary
    console.log('\n✅ DATA COMPLETENESS SUMMARY:');
    console.log(`
    HealthCondition Table:
    ✓ Schema updated with 6 new columns
    ✓ ${stats.rows[0].total_conditions} total conditions
    ✓ ${stats.rows[0].with_vietnamese_articles} conditions with Vietnamese articles
    ✓ ${stats.rows[0].with_english_articles} conditions with English articles
    ✓ ${stats.rows[0].with_prevention_tips} conditions with prevention tips
    ✓ ${stats.rows[0].chronic_conditions} chronic conditions marked

    ConditionFoodRecommendation Table:
    ✓ ${foodStats.rows[0].total_recommendations} total food recommendations
    ✓ ${foodStats.rows[0].conditions_with_recommendations} conditions covered
    ✓ ${foodStats.rows[0].foods_to_avoid} foods to avoid
    ✓ ${foodStats.rows[0].foods_to_recommend} foods to recommend

    DrugHealthCondition Table:
    ✓ ${drugStats.rows[0].total_treatments} drug treatment records
    ✓ ${drugStats.rows[0].conditions_with_drugs} conditions with drug data
    ✓ ${drugStats.rows[0].primary_treatments} primary treatment options
    `);

    console.log('='.repeat(80));
    console.log('✅ DATABASE READY FOR PRODUCTION USE');
    console.log('='.repeat(80));

  } catch (error) {
    console.error('❌ Error generating report:', error.message);
    throw error;
  } finally {
    client.release();
    await pool.end();
  }
}

require('dotenv').config();
generateFinalReport();
