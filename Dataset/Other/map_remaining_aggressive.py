import json
import csv
from pathlib import Path
from difflib import SequenceMatcher
import re

BASE = Path(__file__).resolve().parent
CACHE = BASE / 'WHO_ICD10'
OUT = BASE / 'Generated_Data'

# Target codes (remaining)
TARGET_CODES = ['T446X4A','T446X4D','T446X4S','Y37A2XS']

word_re = re.compile(r"[a-z0-9]+")

# Load dailymed SPL
with open(CACHE / 'dailymed_spl.json', encoding='utf-8') as f:
    d = json.load(f)
# normalize to dict setid->entry
spl_map = {}
if isinstance(d, dict):
    for k,v in d.items():
        if isinstance(v, dict):
            spl_map[k] = v
else:
    for entry in d:
        if isinstance(entry, dict):
            sid = entry.get('setid')
            if sid:
                spl_map[sid] = entry

# Load related mapping code->spl keys
with open(CACHE / 'dailymed_related_icd10.json', encoding='utf-8') as f:
    rel = json.load(f)
code_to_spls = {}
if isinstance(rel, dict):
    for sk, items in rel.items():
        if not isinstance(items, list):
            continue
        for item in items:
            if not item: continue
            code = str(item[0]).upper().replace('.', '')
            code_to_spls.setdefault(code, set()).add(sk)

# Load drugs name map
drug_csv = OUT / 'drug' / 'drug.csv'
name_to_id = {}
id_to_name = {}
with open(drug_csv, encoding='utf-8') as f:
    reader = csv.reader(f)
    hdr = next(reader, None)
    for row in reader:
        if not row: continue
        did = int(row[0])
        name = row[1] if len(row)>1 else ''
        if name.startswith("'") and name.endswith("'"):
            name = name[1:-1].replace("''","'")
        name_to_id[name.lower()] = did
        id_to_name[did] = name

# Load healthcondition code->cids
hc_csv = OUT / 'healthcondition' / 'healthcondition.csv'
code_to_cids = {}
with open(hc_csv, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cid = row.get('condition_id')
        code = (row.get('condition_code') or '').upper().replace('.', '')
        if code:
            code_to_cids.setdefault(code, []).append(cid)

# Load existing dhc
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

# helper
def sim(a,b):
    return SequenceMatcher(None, a, b).ratio()

new_rows = []
added = 0

for code in TARGET_CODES:
    spl_keys = code_to_spls.get(code, set())
    cids = code_to_cids.get(code, [])
    print(f'Processing code {code}: {len(spl_keys)} SPLs, {len(cids)} condition_ids')
    # gather text candidates from SPLs
    spl_texts = []
    for sk in spl_keys:
        entry = spl_map.get(sk)
        if not entry:
            continue
        title = entry.get('title') or entry.get('name') or ''
        data = entry.get('data') or {}
        parts = []
        if isinstance(data, dict):
            # collect strings
            for v in data.values():
                if isinstance(v, str) and len(v)>10:
                    parts.append(v)
                elif isinstance(v, list):
                    for it in v:
                        if isinstance(it, str) and len(it)>5:
                            parts.append(it)
        combined = ' '.join([title] + parts)
        if combined.strip():
            spl_texts.append((sk, title, combined))

    # For each SPL text, attempt to match to drug names aggressively
    for sk, title, text in spl_texts:
        tnorm = ' '.join(word_re.findall(text.lower()))
        # Candidate by direct substring in drug names
        for dname, did in name_to_id.items():
            if tnorm and (tnorm in dname or dname in tnorm):
                for cid in cids:
                    key = (did, cid)
                    if key in existing: continue
                    note = f"Matched by substring from SPL {sk}: {title}"
                    new_rows.append((did, cid, note))
                    existing.add(key)
                    added += 1
        # Fuzzy match: compare SPL title & text to drug names
        for dname, did in list(name_to_id.items()):
            score_title = sim(title.lower(), dname)
            score_text = sim(tnorm, dname)
            if score_title >= 0.28 or score_text >= 0.30:
                for cid in cids:
                    key = (did, cid)
                    if key in existing: continue
                    note = f"Fuzzy SPL->drug {sk}: t={score_title:.2f},x={score_text:.2f}"
                    new_rows.append((did, cid, note))
                    existing.add(key)
                    added += 1

# If still no mapping for a code, try fuzzy match condition name -> drug names
for code in TARGET_CODES:
    cids = code_to_cids.get(code, [])
    mapped = any((key[1] in [cid for cid in cids]) for key in existing)
    if mapped:
        continue
    # get condition name(s)
    names = []
    with open(hc_csv, encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            cid = row.get('condition_id')
            if cid in cids:
                nm = (row.get('name_en') or row.get('name_vi') or '')
                names.append(nm.lower())
    for nm in names:
        for dname, did in name_to_id.items():
            s = sim(nm, dname)
            if s >= 0.30:
                for cid in cids:
                    key = (did, cid)
                    if key in existing: continue
                    note = f"Fuzzy condition->drug: {nm} -> {dname} ({s:.2f})"
                    new_rows.append((did, cid, note))
                    existing.add(key)
                    added += 1

# Append new rows
if new_rows:
    with open(dhc_csv, 'a', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        for did, cid, note in new_rows:
            t = "'" + note.replace("'","''") + "'"
            w.writerow([did, cid, t, 'NULL', 'FALSE'])

print('Added mappings for remaining codes:', added)
