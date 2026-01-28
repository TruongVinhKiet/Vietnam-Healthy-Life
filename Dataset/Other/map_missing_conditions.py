import json
import csv
from pathlib import Path
from difflib import SequenceMatcher

BASE = Path(__file__).resolve().parent
CACHE = BASE / 'WHO_ICD10'
OUT = BASE / 'Generated_Data'

# Load related ICD -> list mapping
with open(CACHE / 'dailymed_related_icd10.json', encoding='utf-8') as f:
    rel = json.load(f)

# Build inverted map: code -> set of spl keys
code_to_spls = {}
if isinstance(rel, dict):
    for spl_key, items in rel.items():
        if not isinstance(items, list):
            continue
        for item in items:
            if isinstance(item, (list, tuple)) and len(item) > 0:
                code = str(item[0]).upper().replace('.', '')
                code_to_spls.setdefault(code, set()).add(spl_key)

# Determine missing codes from condition coverage summary if present
summary = OUT / 'condition_coverage_summary.csv'
missing_codes = []
if summary.exists():
    with open(summary, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            total = int(row.get('total_condition_ids') or 0)
            linked = int(row.get('linked_condition_ids') or 0)
            code = (row.get('icd_code') or '').upper().replace('.', '')
            if total >= 0 and linked == 0:
                missing_codes.append(code)

# Fallback: if none found, use a small manual list from prior run
if not missing_codes:
    missing_codes = ['T362X4D','T446X4A','T446X4D','T446X4S','Y37A2XS']

print('Missing codes to map:', missing_codes)

# Load SPLs details to get titles
dailymed = CACHE / 'dailymed_spl.json'
if not dailymed.exists():
    raise SystemExit('Missing dailymed_spl.json')
with open(dailymed, encoding='utf-8') as f:
    d = json.load(f)
# d may be dict or list
spl_map = {}
if isinstance(d, dict):
    for k,v in d.items():
        title = ''
        if isinstance(v, dict):
            title = v.get('title') or v.get('name') or ''
        spl_map[k] = title
else:
    for entry in d:
        if isinstance(entry, dict):
            setid = entry.get('setid')
            title = entry.get('title') or entry.get('name') or ''
            if setid:
                spl_map[setid] = title

# Load drugs name mapping
drug_csv = OUT / 'drug' / 'drug.csv'
name_to_id = {}
id_to_name = {}
with open(drug_csv, encoding='utf-8') as f:
    reader = csv.reader(f)
    hdr = next(reader)
    for row in reader:
        if not row: continue
        did = int(row[0])
        name = row[1] if len(row) > 1 else ''
        if name.startswith("'") and name.endswith("'"):
            name = name[1:-1].replace("''","'")
        name_lower = name.lower()
        name_to_id[name_lower] = did
        id_to_name[did] = name

# Load healthcondition mapping of code->condition_id(s)
hc_csv = OUT / 'healthcondition' / 'healthcondition.csv'
code_to_cids = {}
with open(hc_csv, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cid = row.get('condition_id')
        code = (row.get('condition_code') or '').upper().replace('.', '')
        if code:
            code_to_cids.setdefault(code, []).append(cid)

# Load existing dhc keys to avoid duplicates
dhc_csv = OUT / 'drughealthcondition' / 'drughealthcondition.csv'
existing = set()
if dhc_csv.exists():
    with open(dhc_csv, encoding='utf-8') as f:
        r = csv.reader(f)
        next(r, None)
        for row in r:
            if not row: continue
            try:
                existing.add((int(row[0]), row[1].strip()))
            except Exception:
                continue

# Helper fuzzy match
def fuzzy_match(name, candidates):
    name = name.lower()
    best = []
    for cand in candidates:
        s = SequenceMatcher(None, name, cand).ratio()
        if s >= 0.35:
            best.append((s, cand))
    best.sort(reverse=True)
    return [c for s,c in best[:3]]

added = 0
new_rows = []

for code in missing_codes:
    spls = code_to_spls.get(code, set())
    print('Code', code, 'found in', len(spls), 'SPL entries')
    # Collect possible drug names from SPL titles
    candidate_drug_names = set()
    for sk in spls:
        title = spl_map.get(sk,'')
        if title:
            candidate_drug_names.add(title.lower())
    # For each candidate title try to match to drug list
    for title in candidate_drug_names:
        # exact or partial
        if title in name_to_id:
            did = name_to_id[title]
            # attach to all condition_ids for this code
            for cid in code_to_cids.get(code,[]):
                key = (did, cid)
                if key in existing:
                    continue
                note = f"Mapped from SPL title: {title}"
                new_rows.append((did, cid, note))
                existing.add(key)
                added += 1
        else:
            # fuzzy match with drug names
            candidates = fuzzy_match(title, name_to_id.keys())
            for cand in candidates:
                did = name_to_id[cand]
                for cid in code_to_cids.get(code,[]):
                    key = (did, cid)
                    if key in existing:
                        continue
                    note = f"Fuzzy-mapped from SPL title: {title} -> {cand}"
                    new_rows.append((did, cid, note))
                    existing.add(key)
                    added += 1

# If still none found for a code, try fuzzy match between condition name and drug names
if added == 0:
    for code in missing_codes:
        cids = code_to_cids.get(code, [])
        for cid in cids:
            # get condition name
            # read healthcondition row
            cname = ''
            with open(hc_csv, encoding='utf-8') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    if row.get('condition_id') == cid:
                        cname = (row.get('name_en') or row.get('name_vi') or '').lower()
                        break
            if not cname:
                continue
            # fuzzy match cname to drug names
            candidates = fuzzy_match(cname, name_to_id.keys())
            for cand in candidates:
                did = name_to_id[cand]
                key = (did, cid)
                if key in existing:
                    continue
                note = f"Fuzzy-mapped from condition name: {cname} -> {cand}"
                new_rows.append((did, cid, note))
                existing.add(key)
                added += 1

# Append to dhc CSV
if new_rows:
    with open(dhc_csv, 'a', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        for did, cid, note in new_rows:
            t = "'" + note.replace("'","''") + "'"
            writer.writerow([did, cid, t, 'NULL', 'FALSE'])

print('Added mappings:', added)
if added > 0:
    print('Updated', dhc_csv)
else:
    print('No mappings added')
