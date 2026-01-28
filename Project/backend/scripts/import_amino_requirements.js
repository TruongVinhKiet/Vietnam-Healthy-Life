const fs = require('fs');
const path = require('path');
const { parse: csv } = require('csv-parse/sync');
const db = require('../db');

// Usage: node import_amino_requirements.js /path/to/recommended_nutrients.csv
// The CSV should contain at least columns: nutrient_name, sex, min_age_years, max_age_years, per_kg, amount, unit
// The script is forgiving: it will try to map column names case-insensitively.

async function main() {
  const file = process.argv[2] || path.resolve(__dirname, '../../usda_data/recommended_nutrients.csv');
  if (!fs.existsSync(file)) {
    console.error('CSV file not found:', file);
    process.exit(2);
  }
  const raw = fs.readFileSync(file, 'utf8');
  const records = csv(raw, { columns: true, skip_empty_lines: true });
  console.log('Parsed', records.length, 'rows');

  // Normalize headers
  const mapKey = (k) => (k || '').toLowerCase().trim();

  for (const r of records) {
    const low = {};
    for (const k of Object.keys(r)) low[mapKey(k)] = (r[k] || '').trim();

    const nutrient = low['nutrient_name'] || low['nutrient'] || low['name'];
    if (!nutrient) continue;
    // Try to map the row to a known amino acid and insert a recommendation row
    try {
      // Try a few candidate table names/column combinations to be resilient to migration naming
      const candidates = [
        { table: 'amino_acids', idcol: 'id', namecol: 'name' },
        { table: 'amino_acid', idcol: 'amino_acid_id', namecol: 'name' },
        { table: 'aminoacid', idcol: 'amino_acid_id', namecol: 'name' },
        { table: 'aminoacids', idcol: 'amino_acid_id', namecol: 'name' }
      ];
      let amino_id = null;
      for (const c of candidates) {
        try {
          const q = `SELECT ${c.idcol} as id FROM ${c.table} WHERE LOWER(${c.namecol}) = LOWER($1) LIMIT 1`;
          const a = await db.query(q, [nutrient]);
          if (a.rows && a.rows.length) { amino_id = a.rows[0].id; break; }
        } catch (e) {
          // ignore and try next candidate
        }
      }
      if (!amino_id) continue; // not an amino acid row

      const sex = low['sex'] || low['gender'] || 'both';
      const min_age = low['min_age_years'] || low['min_age'] || null;
      const max_age = low['max_age_years'] || low['max_age'] || null;
      const per_kg = (String(low['per_kg'] || low['perkg'] || '').toLowerCase() === 'true') || false;
      const amount = low['amount'] || low['value'] || low['recommended'] || null;
      const unit = low['unit'] || 'mg';
      const notes = low['notes'] || null;

      if (!amount) {
        console.log('Skipping', nutrient, 'missing amount');
        continue;
      }

      // Insert into the project's AminoRequirement table (try several names)
      const insertCandidates = [ 'AminoRequirement', 'aminorequirement', 'recommended_amino_requirements', 'recommendedaminorequirements' ];
      let inserted = false;
      for (const t of insertCandidates) {
        try {
          const insertSql = `INSERT INTO ${t} (amino_acid_id, sex, age_min, age_max, per_kg, amount, unit, notes) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)`;
          await db.query(insertSql, [amino_id, sex, min_age || null, max_age || null, per_kg, amount, unit, notes]);
          console.log('Inserted recommended row for', nutrient, 'into', t, 'sex=', sex, 'amount=', amount, unit);
          inserted = true;
          break;
        } catch (e) {
          // try next candidate
        }
      }
      if (!inserted) {
        console.warn('Failed to insert recommended row for', nutrient, '- no matching table found');
      }
    } catch (e) {
      console.error('Error processing row', nutrient, e && e.message);
    }
  }
  console.log('Import finished');
  process.exit(0);
}

main();
