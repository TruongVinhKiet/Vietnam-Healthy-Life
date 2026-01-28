import json
import csv
from pathlib import Path
import re
from collections import defaultdict, Counter
from difflib import SequenceMatcher

BASE = Path(__file__).resolve().parent
CACHE = BASE / 'WHO_ICD10'
OUT = BASE / 'Generated_Data'

# Load dailymed SPL
dailymed_file = CACHE / 'dailymed_spl.json'
if not dailymed_file.exists():
    raise SystemExit('Missing dailymed_spl.json in WHO_ICD10')
with open(dailymed_file, encoding='utf-8') as f:
    dailymed = json.load(f)
if isinstance(dailymed, dict):
    dlist = []
    for k,v in dailymed.items():
        if isinstance(v, dict):
            if 'setid' not in v:
                v['setid'] = k
            dlist.append(v)
    dailymed = dlist

# Load healthcondition mapping
hc_csv = OUT / 'healthcondition' / 'healthcondition.csv'
if not hc_csv.exists():
    raise SystemExit('Missing healthcondition CSV')
hc_rows = {}
hc_tokens = {}
inv_index = defaultdict(set)
word_re = re.compile(r"[a-z0-9]+")
with open(hc_csv, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cid = row['condition_id']
        code = row.get('condition_code','') or ''
        name_en = row.get('name_en','') or ''
        text = (code + ' ' + name_en).lower()
        tokens = set(word_re.findall(text))
        hc_rows[cid] = {'code': code, 'name_en': name_en, 'tokens': tokens}
        hc_tokens[cid] = tokens
        for t in tokens:
            inv_index[t].add(cid)

print(f'Loaded {len(hc_rows)} healthconditions')

# Load drug mapping from Generated_Data/drug/drug.csv
drug_csv = OUT / 'drug' / 'drug.csv'
if not drug_csv.exists():
    raise SystemExit('Missing drug CSV')
drug_map_by_name = {}
with open(drug_csv, encoding='utf-8') as f:
    reader = csv.reader(f)
    hdr = next(reader)
    for row in reader:
        if not row: continue
        did = int(row[0])
        name = row[1] if len(row)>1 else ''
        # strip quotes
        if name.startswith("'") and name.endswith("'"):
            name = name[1:-1].replace("''","'")
        drug_map_by_name[name.lower()] = did

print(f'Loaded {len(drug_map_by_name)} drugs')

# Load existing drughealthcondition to avoid duplicates
dhc_csv = OUT / 'drughealthcondition' / 'drughealthcondition.csv'
existing = set()
if dhc_csv.exists():
    with open(dhc_csv, encoding='utf-8') as f:
        reader = csv.reader(f)
        _ = next(reader)
        for row in reader:
            try:
                existing.add((int(row[0]), row[1]))
            except Exception:
                continue

# Helper normalize
def normalize_text(s):
    if not s: return ''
    return ' '.join(word_re.findall(s.lower()))

new_rows = []
added = 0

for spl in dailymed:
    if not isinstance(spl, dict):
        continue
    setid = spl.get('setid') or ''
    title = spl.get('title') or spl.get('name') or ''

    # extract potential textual fields
    text_parts = []
    if isinstance(spl.get('data'), dict):
        data = spl.get('data')
        # common keys
        for k in ['indications', 'indication', 'intended_use', 'indications_and_usage', 'indication_and_usage', 'indications_and_usage_text']:
            v = data.get(k)
            if v:
                if isinstance(v, list):
                    text_parts.extend([str(x) for x in v if x])
                else:
                    text_parts.append(str(v))
        # fallback: include all string values
        for k,v in data.items():
            if isinstance(v, str) and len(v)>20:
                text_parts.append(v)
            if isinstance(v, list):
                for it in v:
                    if isinstance(it, str) and len(it)>20:
                        text_parts.append(it)
    # also include title
    if title:
        text_parts.insert(0, title)

    combined = '\n'.join(text_parts)
    if not combined.strip():
        continue

    tokens = set(word_re.findall(combined.lower()))
    if not tokens:
        continue

    # Candidate condition ids by token overlap
    cand_counts = Counter()
    for t in tokens:
        for cid in inv_index.get(t, []):
            cand_counts[cid] += 1
    if not cand_counts:
        # fallback: fuzzy on names
        scores = []
        for cid, info in hc_rows.items():
            name = info['name_en']
            if not name: continue
            s = SequenceMatcher(None, combined.lower(), name.lower()).ratio()
            if s > 0.35:
                scores.append((s, cid))
        scores.sort(reverse=True)
        top = [cid for s,cid in scores[:3]]
    else:
        # score by overlap ratio
        scored = []
        for cid, cnt in cand_counts.items():
            denom = max(1, len(hc_tokens.get(cid,[])))
            score = cnt/denom
            scored.append((score, cid, cnt))
        scored.sort(reverse=True)
        top = [cid for score,cid,cnt in scored if score>=0.2][:3]
        if not top:
            top = [cid for score,cid,cnt in scored[:3]]

    # find drug id by matching title to drug names (exact or partial)
    spl_name = title.lower().strip()
    matched_drug_id = None
    # direct exact
    if spl_name in drug_map_by_name:
        matched_drug_id = drug_map_by_name[spl_name]
    else:
        # partial match
        for dname, did in drug_map_by_name.items():
            if spl_name and (spl_name in dname or dname in spl_name):
                matched_drug_id = did
                break

    if not matched_drug_id:
        # try other data names
        if isinstance(spl.get('data'), dict):
            names = spl['data'].get('name', [])
            if isinstance(names, list):
                for n in names:
                    if not n: continue
                    nlow = str(n).lower()
                    if nlow in drug_map_by_name:
                        matched_drug_id = drug_map_by_name[nlow]
                        break

    if not matched_drug_id:
        continue

    # create rows for top candidates
    for cid in top:
        cond = hc_rows.get(cid)
        if not cond: continue
        condition_code = cond['code']
        condition_id = cid
        # avoid duplicates: existing uses (drug_id, condition_id) where condition_id may be numeric or code
        key = (matched_drug_id, str(condition_id))
        if key in existing:
            continue
        # treatment_notes: include short excerpt
        note = (combined[:200].replace('\n',' ')).replace('\r',' ')
        new_rows.append((matched_drug_id, condition_id, note, '', 'FALSE'))
        existing.add(key)
        added += 1

# Append to CSV
if not new_rows:
    print('No new mappings found')
else:
    out = OUT / 'drughealthcondition' / 'drughealthcondition.csv'
    # read header if exists
    if out.exists():
        with open(out, 'a', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            for r in new_rows:
                # format treatment note quoting to match existing
                t = r[2]
                if t is None:
                    t = 'NULL'
                else:
                    t = "'" + t.replace("'","''") + "'"
                writer.writerow([r[0], r[1], t, 'NULL', r[4]])
    else:
        # create file with header
        out.parent.mkdir(parents=True, exist_ok=True)
        with open(out, 'w', encoding='utf-8', newline='') as f:
            writer = csv.writer(f)
            writer.writerow(['drug_id','condition_id','treatment_notes','treatment_notes_vi','is_primary'])
            for r in new_rows:
                t = r[2]
                if t is None:
                    t = 'NULL'
                else:
                    t = "'" + t.replace("'","''") + "'"
                writer.writerow([r[0], r[1], t, 'NULL', r[4]])

print(f'Added {added} new drug->condition mappings')
print('Wrote/updated:', OUT / 'drughealthcondition' / 'drughealthcondition.csv')
