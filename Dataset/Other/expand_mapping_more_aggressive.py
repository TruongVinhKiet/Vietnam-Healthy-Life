import json
import csv
from pathlib import Path
import re
from collections import defaultdict, Counter
from difflib import SequenceMatcher

BASE = Path(__file__).resolve().parent
CACHE = BASE / 'WHO_ICD10'
OUT = BASE / 'Generated_Data'

# Parameters (more aggressive)
TOKEN_SCORE_THRESHOLD = 0.05
FUZZY_THRESHOLD = 0.22
MAX_CANDIDATES = 15

word_re = re.compile(r"[a-z0-9]+")

# Load dailymed
with open(CACHE / 'dailymed_spl.json', encoding='utf-8') as f:
    d = json.load(f)
if isinstance(d, dict):
    dlist = []
    for k,v in d.items():
        if isinstance(v, dict):
            if 'setid' not in v:
                v['setid'] = k
            dlist.append(v)
    d = dlist

# Load healthcondition
hc_csv = OUT / 'healthcondition' / 'healthcondition.csv'
if not hc_csv.exists():
    raise SystemExit('Missing healthcondition CSV')
hc_rows = {}
inv_index = defaultdict(set)
with open(hc_csv, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cid = row['condition_id']
        code = (row.get('condition_code') or '').upper()
        name = (row.get('name_en') or row.get('name_vi') or '')
        text = (code + ' ' + name).lower()
        tokens = set(word_re.findall(text))
        hc_rows[cid] = {'code': code, 'name': name, 'tokens': tokens}
        for t in tokens:
            inv_index[t].add(cid)

print(f'Loaded {len(hc_rows)} healthconditions')

# Load drugs
drug_csv = OUT / 'drug' / 'drug.csv'
if not drug_csv.exists():
    raise SystemExit('Missing drug CSV')
drug_map = {}
with open(drug_csv, encoding='utf-8') as f:
    reader = csv.reader(f)
    hdr = next(reader)
    for row in reader:
        if not row: continue
        did = int(row[0])
        name = row[1] if len(row)>1 else ''
        if name.startswith("'") and name.endswith("'"):
            name = name[1:-1].replace("''","'")
        drug_map[did] = name

# Load existing dhc keys
dhc_csv = OUT / 'drughealthcondition' / 'drughealthcondition.csv'
existing = set()
if dhc_csv.exists():
    with open(dhc_csv, encoding='utf-8') as f:
        reader = csv.reader(f)
        next(reader, None)
        for row in reader:
            if not row: continue
            try:
                existing.add((int(row[0]), row[1].strip()))
            except Exception:
                continue

# Build name->did mapping for quick match
name_to_did = {v.lower(): k for k,v in drug_map.items()}

added = 0
new_rows = []

for spl in d:
    if not isinstance(spl, dict):
        continue
    title = (spl.get('title') or spl.get('name') or '').strip()
    data_blob = ''
    if isinstance(spl.get('data'), dict):
        parts = []
        for k,v in spl['data'].items():
            if isinstance(v, list):
                parts.extend([str(x) for x in v if x])
            elif isinstance(v, str) and len(v)>0:
                parts.append(v)
        data_blob = ' '.join(parts)
    combined = (title + ' ' + data_blob).strip()
    if not combined:
        continue
    tokens = set(word_re.findall(combined.lower()))
    # candidate by token overlap
    cand_counts = Counter()
    for t in tokens:
        for cid in inv_index.get(t, []):
            cand_counts[cid] += 1
    candidates = []
    if cand_counts:
        scored = []
        for cid, cnt in cand_counts.items():
            denom = max(1, len(hc_rows[cid]['tokens']))
            score = cnt/denom
            scored.append((score, cid, cnt))
        scored.sort(reverse=True)
        candidates = [cid for score,cid,cnt in scored[:MAX_CANDIDATES] if score>=TOKEN_SCORE_THRESHOLD]
        # if empty, take top MAX_CANDIDATES anyway
        if not candidates:
            candidates = [cid for score,cid,cnt in scored[:MAX_CANDIDATES]]
    else:
        # fallback: take top MAX_CANDIDATES by fuzzy similarity to names
        scores = []
        for cid, info in hc_rows.items():
            name = info['name']
            if not name: continue
            s = SequenceMatcher(None, combined.lower(), name.lower()).ratio()
            scores.append((s, cid))
        scores.sort(reverse=True)
        candidates = [cid for s,cid in scores[:MAX_CANDIDATES] if s>=FUZZY_THRESHOLD]

    # additional fuzzy pass: compare to hc name even if not in candidates
    # and accept if SequenceMatcher > lower threshold
    extra = []
    for cid, info in hc_rows.items():
        if cid in candidates: continue
        name = info['name']
        if not name: continue
        s = SequenceMatcher(None, combined.lower(), name.lower()).ratio()
        if s >= (FUZZY_THRESHOLD - 0.05):
            extra.append((s,cid))
    extra.sort(reverse=True)
    for s,cid in extra[:3]:
        if cid not in candidates:
            candidates.append(cid)

    # find drug id
    matched_did = None
    tname = title.lower()
    if tname in name_to_did:
        matched_did = name_to_did[tname]
    else:
        for name, did in name_to_did.items():
            if tname and (tname in name or name in tname):
                matched_did = did
                break
    if not matched_did:
        # try data.name list
        if isinstance(spl.get('data'), dict):
            names = spl['data'].get('name', [])
            if isinstance(names, list):
                for n in names:
                    if not n: continue
                    nlow = str(n).lower()
                    if nlow in name_to_did:
                        matched_did = name_to_did[nlow]
                        break
    if not matched_did:
        continue

    # create rows for candidates with some checks
    for cid in candidates:
        key = (matched_did, str(cid))
        if key in existing:
            continue
        # compute fuzzy score to HC name for info
        hcname = hc_rows[cid]['name']
        score = SequenceMatcher(None, combined.lower(), (hcname or '').lower()).ratio()
        # accept if token overlap >= TOKEN_SCORE_THRESHOLD OR fuzzy >= FUZZY_THRESHOLD
        overlap_cnt = len(tokens & hc_rows[cid]['tokens'])
        denom = max(1, len(hc_rows[cid]['tokens']))
        overlap_score = overlap_cnt/denom
        if overlap_score >= TOKEN_SCORE_THRESHOLD or score >= FUZZY_THRESHOLD - 0.05:
            note = (combined[:200].replace('\n',' ').replace('\r',' '))
            new_rows.append((matched_did, cid, note, '', 'FALSE'))
            existing.add(key)
            added += 1

# append new rows
if new_rows:
    out = OUT / 'drughealthcondition' / 'drughealthcondition.csv'
    with open(out, 'a', encoding='utf-8', newline='') as f:
        writer = csv.writer(f)
        for r in new_rows:
            t = r[2]
            t = "'" + t.replace("'","''") + "'"
            writer.writerow([r[0], r[1], t, 'NULL', r[4]])

print('Aggressive mapping added:', added)
print('Updated file:', OUT / 'drughealthcondition' / 'drughealthcondition.csv')
