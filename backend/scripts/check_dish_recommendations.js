const { Pool } = require('pg');

const pool = new Pool({
  user: 'postgres',
  host: 'localhost',
  database: 'Health',
  password: 'Kiet2004',
  port: 5432,
});

async function checkDishRecommendations() {
  try {
    console.log('\n='.repeat(78));
    console.log('📋 VERIFICATION REPORT: Dish Recommendations Coverage');
    console.log('='.repeat(78));
    
    // Check dish recommendation table structure
    const tableCheck = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
        AND table_name LIKE '%dish%' 
        AND table_name LIKE '%recommendation%'
    `);
    
    console.log('\n🔍 Dish Recommendation Tables:');
    console.log('-'.repeat(78));
    if (tableCheck.rows.length === 0) {
      console.log('❌ No dish recommendation table found!');
      console.log('\n💡 Available tables with "dish":');
      
      const dishTables = await pool.query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name LIKE '%dish%'
        ORDER BY table_name
      `);
      
      dishTables.rows.forEach(row => {
        console.log(`   - ${row.table_name}`);
      });
      
      console.log('\n💡 Available tables with "recommendation":');
      
      const recTables = await pool.query(`
        SELECT table_name 
        FROM information_schema.tables 
        WHERE table_schema = 'public' 
          AND table_name LIKE '%recommendation%'
        ORDER BY table_name
      `);
      
      recTables.rows.forEach(row => {
        console.log(`   - ${row.table_name}`);
      });
      
    } else {
      tableCheck.rows.forEach(row => {
        console.log(`✅ Found table: ${row.table_name}`);
      });
      
      // Show table structure
      const tableName = tableCheck.rows[0].table_name;
      const columns = await pool.query(`
        SELECT column_name, data_type 
        FROM information_schema.columns 
        WHERE table_name = $1
        ORDER BY ordinal_position
      `, [tableName]);
      
      console.log(`\n📊 Table structure for ${tableName}:`);
      columns.rows.forEach(col => {
        console.log(`   - ${col.column_name}: ${col.data_type}`);
      });
      
      // Count recommendations by condition
      const stats = await pool.query(`
        SELECT 
          hc.condition_id,
          hc.condition_name,
          COUNT(CASE WHEN cdr.recommendation_type = 'avoid' THEN 1 END) as avoid_count,
          COUNT(CASE WHEN cdr.recommendation_type = 'recommend' THEN 1 END) as recommend_count,
          COUNT(*) as total_count
        FROM healthcondition hc
        LEFT JOIN conditiondishrecommendation cdr ON hc.condition_id = cdr.condition_id
        GROUP BY hc.condition_id, hc.condition_name
        ORDER BY hc.condition_name
      `);
      
      console.log('\n🏥 HEALTH CONDITIONS - Dish Recommendations:');
      console.log('-'.repeat(78));
      
      let withoutRecs = 0;
      stats.rows.forEach(row => {
        const status = row.total_count > 0 ? '✅' : '❌';
        const conditionName = row.condition_name || `ID ${row.condition_id}`;
        const padding = ' '.repeat(Math.max(0, 40 - conditionName.length));
        console.log(`${status} ${conditionName}${padding} | Avoid: ${String(row.avoid_count).padStart(3)} | Recommend: ${String(row.recommend_count).padStart(3)} | Total: ${row.total_count}`);
        if (row.total_count === 0) withoutRecs++;
      });
      
      console.log(`\nSummary: ${stats.rows.length} conditions, ${withoutRecs} without dish recommendations`);
      
      // Show sample recommendations
      console.log('\n📋 SAMPLE DISH RECOMMENDATIONS BY CONDITION:');
      console.log('-'.repeat(78));
      
      const samples = await pool.query(`
        SELECT 
          hc.condition_name,
          cdr.recommendation_type,
          d.vietnamese_name,
          d.category
        FROM healthcondition hc
        INNER JOIN conditiondishrecommendation cdr ON hc.condition_id = cdr.condition_id
        INNER JOIN dish d ON cdr.dish_id = d.dish_id
        WHERE hc.condition_id IN (
          SELECT DISTINCT condition_id 
          FROM conditiondishrecommendation 
          WHERE recommendation_type IN ('avoid', 'recommend')
          LIMIT 5
        )
        ORDER BY hc.condition_name, cdr.recommendation_type, d.vietnamese_name
      `);
      
      let currentCondition = '';
      samples.rows.forEach(row => {
        const conditionName = row.condition_name || 'Unknown';
        if (conditionName !== currentCondition) {
          currentCondition = conditionName;
          console.log(`\n🏥 ${currentCondition}:`);
        }
        const icon = row.recommendation_type === 'avoid' ? '🚫 AVOID    ' : '✅ RECOMMEND';
        console.log(`  ${icon} - ${row.vietnamese_name} (${row.category || 'N/A'})`);
      });
      
      // Database statistics
      const dishCount = await pool.query('SELECT COUNT(*) FROM dish');
      const conditionCount = await pool.query('SELECT COUNT(*) FROM healthcondition');
      const recCount = await pool.query('SELECT COUNT(*) FROM conditiondishrecommendation');
      
      console.log('\n📦 DATABASE STATISTICS:');
      console.log('-'.repeat(78));
      console.log(`🍲 Total Dishes: ${dishCount.rows[0].count}`);
      console.log(`🏥 Total Health Conditions: ${conditionCount.rows[0].count}`);
      console.log(`📝 Total Dish Recommendations: ${recCount.rows[0].count}`);
    }
    
    console.log('\n' + '='.repeat(78));
    console.log('✅ Verification complete!');
    console.log('='.repeat(78));
    
  } catch (error) {
    console.error('Error:', error.message);
    console.error(error.stack);
  } finally {
    await pool.end();
  }
}

checkDishRecommendations();
