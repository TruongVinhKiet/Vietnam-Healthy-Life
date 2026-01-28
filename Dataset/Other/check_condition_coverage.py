import json
import csv
from pathlib import Path

BASE = Path(__file__).resolve().parent
CACHE = BASE / 'WHO_ICD10'
OUT = BASE / 'Generated_Data'

# Load related ICD codes
with open(CACHE / 'dailymed_related_icd10.json', encoding='utf-8') as f:
    d = json.load(f)
codes = set()
if isinstance(d, dict):
    for v in d.values():
        if not isinstance(v, list):
            continue
        for item in v:
            if not item:
                continue
            code = item[0] if isinstance(item, (list, tuple)) and len(item) > 0 else None
            if code:
                codes.add(str(code).upper().replace('.', ''))

print(f'Total related ICD codes (unique): {len(codes)}')

# Load healthcondition to map codes -> condition_id, name
hc_path = OUT / 'healthcondition' / 'healthcondition.csv'
code_to_cids = {}
cid_to_name = {}
with open(hc_path, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cid = row.get('condition_id')
        code = (row.get('condition_code') or '').upper().replace('.', '')
        name = row.get('name_en') or row.get('name_vi') or ''
        cid_to_name[cid] = name
        if code:
            code_to_cids.setdefault(code, []).append(cid)

# Load drughealthcondition condition ids linked
dhc_path = OUT / 'drughealthcondition' / 'drughealthcondition.csv'
linked_cids = set()
with open(dhc_path, encoding='utf-8') as f:
    reader = csv.reader(f)
    next(reader, None)
    for row in reader:
        if not row or len(row) < 2:
            continue
        linked_cids.add(row[1].strip())

# For each related code, find mapped cids and check link
covered = 0
missing = []
coverage_counts = {}
for code in sorted(codes):
    cids = code_to_cids.get(code, [])
    total_for_code = 0
    linked_for_code = 0
    for cid in cids:
        # count how many links for this cid
        # we can count occurrences in dhc file
        total_for_code += 1
        if cid in linked_cids:
            linked_for_code += 1
    coverage_counts[code] = {'cids': cids, 'total_cids': total_for_code, 'linked_cids': linked_for_code}
    if linked_for_code > 0:
        covered += 1
    else:
        missing.append((code, cids))

print(f'Conditions with at least one linked drug: {covered} / {len(codes)}')
print('\nCodes with no linked drug:')
for code, cids in missing:
    names = [cid_to_name.get(cid, '') for cid in cids]
    print(f'- {code}: condition_ids={cids} names={names}')

# Also print top covered conditions by number of linked cids
print('\nTop mapped conditions (by linked condition_id count):')
rank = []
for code, info in coverage_counts.items():
    rank.append((info['linked_cids'], code, info))
rank.sort(reverse=True)
for cnt, code, info in rank[:10]:
    print(f'{code}: linked_condition_ids={cnt}, total_condition_ids={info["total_cids"]}, cids={info["cids"]}')

# Write summary CSV
with open(OUT / 'condition_coverage_summary.csv', 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['icd_code','total_condition_ids','linked_condition_ids','condition_ids','names'])
    for code, info in coverage_counts.items():
        names = [cid_to_name.get(cid,'') for cid in info['cids']]
        writer.writerow([code, info['total_cids'], info['linked_cids'], '|'.join(info['cids']), '|'.join(names)])
print('\nWrote summary to Generated_Data/condition_coverage_summary.csv')
