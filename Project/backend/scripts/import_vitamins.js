/*
  Simple importer for recommended_nutrients.csv -> Vitamin table.
  Usage: set CSV_PATH env var to point to the CSV, then run:
    node import_vitamins.js

  The script attempts to discover sensible columns (name, unit, recommended amount).
  It upserts rows using a generated code derived from the name (e.g., "Vitamin D" -> VITD).
*/
require('dotenv').config();
const fs = require('fs');
const path = require('path');
const db = require('../db');

const csvPath = process.env.CSV_PATH || 'd:/app/usda_data/recommended_nutrients.csv';

function genCodeFromName(name) {
  // Example: "Vitamin B12 (Cobalamin)" -> VITB12
  if (!name) return null;
  const m = name.toUpperCase().match(/VITAMIN\s*([A-Z0-9]+)/);
  if (m && m[1]) return 'VIT' + m[1].replace(/[^A-Z0-9]/g, '');
  // fallback: take first words letters
  const letters = name.replace(/[^A-Z0-9 ]/ig, '').split(' ').slice(0,2).map(s => s.substring(0,3).toUpperCase()).join('');
  return 'VIT' + letters;
}

function parseCsv(content) {
  const lines = content.split(/\r?\n/).filter(l => l.trim() !== '');
  if (lines.length === 0) return [];
  const header = lines[0].split(',').map(h => h.trim().toLowerCase());
  const rows = [];
  for (let i=1;i<lines.length;i++) {
    const cols = lines[i].split(',');
    const obj = {};
    for (let j=0;j<header.length && j<cols.length;j++) {
      obj[header[j]] = (cols[j]||'').trim();
    }
    rows.push(obj);
  }
  return rows;
}

async function upsertVitamin(code, name, description, unit, recommended) {
  if (!code || !name) return;
  const q = `INSERT INTO Vitamin(code,name,description,unit,recommended_daily,created_by_admin)
    VALUES($1,$2,$3,$4,$5,NULL)
    ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, description = EXCLUDED.description, unit = EXCLUDED.unit, recommended_daily = EXCLUDED.recommended_daily`;
  await db.query(q, [code, name, description || null, unit || null, recommended || null]);
}

async function upsertVitaminRDA(vitaminCode, rdaValue, rdaUnit, sex, ageMin, ageMax) {
  if (!vitaminCode || rdaValue == null) return;
  // find vitamin_id
  const q = `SELECT vitamin_id, code FROM Vitamin WHERE upper(code) = $1 LIMIT 1`;
  const r = await db.query(q, [vitaminCode.toUpperCase()]);
  if (!r.rows || r.rows.length === 0) return;
  const vitaminId = r.rows[0].vitamin_id;
  // insert into VitaminRDA; create table if it doesn't exist (migration may not have run)
  await db.query(`CREATE TABLE IF NOT EXISTS VitaminRDA (vitamin_rda_id SERIAL PRIMARY KEY, vitamin_id INT REFERENCES Vitamin(vitamin_id), sex VARCHAR(10), age_min INT, age_max INT, rda_value NUMERIC, unit VARCHAR(20), note TEXT)`);
  const up = `INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, note)
    VALUES($1,$2,$3,$4,$5,$6,NULL)
    ON CONFLICT (vitamin_id, sex, age_min, age_max) DO UPDATE SET rda_value = EXCLUDED.rda_value, unit = EXCLUDED.unit`;
  try {
    await db.query(up, [vitaminId, sex || null, ageMin || null, ageMax || null, rdaValue, rdaUnit || null]);
  } catch (e) {
    // ignore conflicts on missing unique constraint
    await db.query(`INSERT INTO VitaminRDA(vitamin_id, sex, age_min, age_max, rda_value, unit, note) VALUES($1,$2,$3,$4,$5,$6,NULL)`, [vitaminId, sex || null, ageMin || null, ageMax || null, rdaValue, rdaUnit || null]);
  }
}

(async function main(){
  try {
    console.log('Reading CSV from', csvPath);
    const content = fs.readFileSync(csvPath, 'utf8');
    const rows = parseCsv(content);
    console.log('Parsed rows:', rows.length);

    // heuristics: look for columns
    const nameKeys = ['nutrient','nutrient_name','name','description'];
    const unitKeys = ['unit','unit_name','unit_of_measure'];
    const rdaKeys = ['recommended_daily','rda','daily_value','recommended_amount','amount'];

    let imported = 0;
    for (const r of rows) {
      // find name
      let name = null;
      for (const k of nameKeys) if (r[k]) { name = r[k]; break; }
      if (!name) continue;
      // only import vitamins
      if (!/vitamin/i.test(name)) continue;
      let unit = null;
      for (const k of unitKeys) if (r[k]) { unit = r[k]; break; }
      let rec = null;
      for (const k of rdaKeys) if (r[k]) { rec = r[k]; break; }
      // sanitize recommended number
      if (rec) {
        const m = rec.replace(/[^0-9\.]/g,'');
        rec = m === '' ? null : Number(m);
      }
      const code = genCodeFromName(name) || (name.toUpperCase().replace(/[^A-Z0-9]/g,'').slice(0,8));
      await upsertVitamin(code, name, '', unit, rec);
      // try to upsert RDA row if the CSV row contains demographic info
      // heuristics: look for sex and age related columns
      const sex = r['sex'] || r['gender'] || r['sex_group'] || null;
      let ageMin = null;
      let ageMax = null;
      const ageField = r['age_group'] || r['age_range'] || r['age'];
      if (ageField) {
        const m = String(ageField).match(/(\d{1,3})\s*[-–]\s*(\d{1,3})/);
        if (m) { ageMin = parseInt(m[1],10); ageMax = parseInt(m[2],10); }
      }
      if ((sex || ageMin != null || ageMax != null) && rec != null) {
        await upsertVitaminRDA(code, rec, unit, sex, ageMin, ageMax);
      }
      imported++;
    }
    console.log('Imported vitamins:', imported);
    process.exit(0);
  } catch (err) {
    console.error('import_vitamins error', err && err.message);
    process.exit(1);
  }
})();
