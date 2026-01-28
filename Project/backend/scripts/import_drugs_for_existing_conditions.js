require('dotenv').config();
const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME || 'Health',
});

async function importDrugsForConditions() {
  const client = await pool.connect();
  
  try {
    console.log('='.repeat(80));
    console.log('IMPORTING DRUGS FOR EXISTING 39 HEALTH CONDITIONS');
    console.log('='.repeat(80));

    // Step 1: Get all existing condition_ids
    const existingConditions = await client.query(`
      SELECT condition_id, name_vi, name_en 
      FROM healthcondition 
      ORDER BY condition_id
    `);

    const conditionIds = existingConditions.rows.map(r => r.condition_id);
    console.log(`\n✓ Found ${conditionIds.length} existing conditions`);
    console.log('Condition IDs:', conditionIds.slice(0, 10).join(', '), '...');

    // Step 2: Read drughealthcondition.sql to find relevant drug_ids
    const dhcPath = path.join('d:', 'App', 'new', 'dataset', 'drugbank_full_real', 'drughealthcondition.sql');
    const dhcContent = fs.readFileSync(dhcPath, 'utf8');
    
    const drugConditionMap = new Map(); // drug_id -> [condition_ids]
    const conditionDrugMap = new Map(); // condition_id -> [drug_ids]
    
    // Parse INSERT statements
    const insertPattern = /INSERT INTO drughealthcondition \(drug_id, condition_id, treatment_notes, is_primary\) VALUES \((\d+), (\d+), '([^']+)', (TRUE|FALSE)\);/g;
    let match;
    let totalMatches = 0;
    
    while ((match = insertPattern.exec(dhcContent)) !== null) {
      const drugId = parseInt(match[1]);
      const conditionId = parseInt(match[2]);
      const notes = match[3];
      const isPrimary = match[4] === 'TRUE';
      
      if (conditionIds.includes(conditionId)) {
        if (!drugConditionMap.has(drugId)) {
          drugConditionMap.set(drugId, []);
        }
        drugConditionMap.get(drugId).push({ conditionId, notes, isPrimary });
        
        if (!conditionDrugMap.has(conditionId)) {
          conditionDrugMap.set(conditionId, new Set());
        }
        conditionDrugMap.get(conditionId).add(drugId);
        totalMatches++;
      }
    }

    console.log(`\n✓ Found ${totalMatches} drug-condition relationships for our conditions`);
    console.log(`✓ Unique drugs needed: ${drugConditionMap.size}`);

    // Step 3: Read drug.sql to get drug information
    const drugPath = path.join('d:', 'App', 'new', 'dataset', 'drugbank_full_real', 'drug.sql');
    const drugContent = fs.readFileSync(drugPath, 'utf8');
    
    const drugMap = new Map(); // drug_id -> drug info
    const drugPattern = /INSERT INTO drug \(drug_id, name_en, description, source_link, is_active\) VALUES \((\d+), '([^']*)', (NULL|'[^']*'), '([^']*)', (TRUE|FALSE)\);/gs;
    
    while ((match = drugPattern.exec(drugContent)) !== null) {
      const drugId = parseInt(match[1]);
      if (drugConditionMap.has(drugId)) {
        drugMap.set(drugId, {
          drug_id: drugId,
          name_en: match[2] === 'nan' ? null : match[2],
          description: match[3] === 'NULL' ? null : match[3].replace(/^'|'$/g, ''),
          source_link: match[4] === 'nan' ? null : match[4],
          is_active: match[5] === 'TRUE'
        });
      }
    }

    console.log(`✓ Found ${drugMap.size} drugs to import\n`);

    // Step 4: Start transaction and import
    await client.query('BEGIN');

    // Import drugs
    let drugsImported = 0;
    for (const [drugId, drugInfo] of drugMap) {
      try {
        await client.query(`
          INSERT INTO drug (drug_id, name_en, name_vi, description, source_link, is_active, created_at)
          VALUES ($1, $2, $3, $4, $5, $6, NOW())
          ON CONFLICT (drug_id) DO UPDATE SET
            name_en = EXCLUDED.name_en,
            description = EXCLUDED.description,
            source_link = EXCLUDED.source_link,
            is_active = EXCLUDED.is_active,
            updated_at = NOW()
        `, [
          drugInfo.drug_id,
          drugInfo.name_en,
          drugInfo.name_en, // Use name_en as name_vi for now
          drugInfo.description,
          drugInfo.source_link,
          drugInfo.is_active
        ]);
        drugsImported++;
        if (drugsImported % 100 === 0) {
          console.log(`  Imported ${drugsImported} drugs...`);
        }
      } catch (err) {
        console.error(`  ⚠ Error importing drug ${drugId}:`, err.message);
      }
    }
    console.log(`✓ Imported ${drugsImported} drugs\n`);

    // Import drug-condition relationships
    let relationshipsImported = 0;
    for (const [drugId, conditions] of drugConditionMap) {
      for (const { conditionId, notes, isPrimary } of conditions) {
        try {
          await client.query(`
            INSERT INTO drughealthcondition (drug_id, condition_id, treatment_notes, treatment_notes_vi, is_primary, created_at)
            VALUES ($1, $2, $3, $4, $5, NOW())
            ON CONFLICT (drug_id, condition_id) DO UPDATE SET
              treatment_notes = EXCLUDED.treatment_notes,
              treatment_notes_vi = EXCLUDED.treatment_notes_vi,
              is_primary = EXCLUDED.is_primary
          `, [drugId, conditionId, notes, notes, isPrimary]);
          relationshipsImported++;
          if (relationshipsImported % 100 === 0) {
            console.log(`  Imported ${relationshipsImported} relationships...`);
          }
        } catch (err) {
          console.error(`  ⚠ Error importing relationship drug ${drugId} - condition ${conditionId}:`, err.message);
        }
      }
    }
    console.log(`✓ Imported ${relationshipsImported} drug-condition relationships\n`);

    await client.query('COMMIT');

    // Step 5: Summary report
    console.log('='.repeat(80));
    console.log('SUMMARY REPORT');
    console.log('='.repeat(80));

    const summary = await client.query(`
      SELECT 
        hc.condition_id,
        hc.name_vi,
        hc.name_en,
        COUNT(dhc.drug_id) as drug_count,
        COUNT(CASE WHEN dhc.is_primary = true THEN 1 END) as primary_drugs
      FROM healthcondition hc
      LEFT JOIN drughealthcondition dhc ON hc.condition_id = dhc.condition_id
      GROUP BY hc.condition_id, hc.name_vi, hc.name_en
      HAVING COUNT(dhc.drug_id) > 0
      ORDER BY drug_count DESC
      LIMIT 20
    `);

    console.log('\nTop 20 Conditions by Drug Count:');
    console.table(summary.rows);

    const totals = await client.query(`
      SELECT 
        COUNT(DISTINCT hc.condition_id) as conditions_with_drugs,
        COUNT(DISTINCT d.drug_id) as total_drugs,
        COUNT(*) as total_relationships,
        COUNT(CASE WHEN dhc.is_primary = true THEN 1 END) as primary_treatments
      FROM drughealthcondition dhc
      JOIN healthcondition hc ON dhc.condition_id = hc.condition_id
      JOIN drug d ON dhc.drug_id = d.drug_id
    `);

    console.log('\nOverall Statistics:');
    console.table(totals.rows);

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

importDrugsForConditions();
