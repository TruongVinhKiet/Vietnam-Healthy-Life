import csv
from pathlib import Path
from collections import Counter

BASE = Path(__file__).resolve().parent
GD = BASE / 'Generated_Data'

files = {
    'drug': GD / 'drug' / 'drug.csv',
    'drughealthcondition': GD / 'drughealthcondition' / 'drughealthcondition.csv',
    'healthcondition': GD / 'healthcondition' / 'healthcondition.csv',
    'food': GD / 'food' / 'food.csv',
    'foodnutrient': GD / 'foodnutrient' / 'foodnutrient.csv',
    'nutrient': GD / 'nutrient' / 'nutrient.csv',
    'drugnutrientcontraindication': GD / 'drugnutrientcontraindication' / 'drugnutrientcontraindication.csv',
    'unlinked_drugs': GD / 'unlinked_drugs.csv',
    'condition_coverage': GD / 'condition_coverage_summary.csv'
}

summary = {}

for k,p in files.items():
    if not p.exists():
        summary[k] = None
        continue
    with open(p, encoding='utf-8') as f:
        reader = csv.reader(f)
        rows = list(reader)
        if len(rows)==0:
            summary[k] = 0
        else:
            summary[k] = max(0, len(rows)-1)

# Additional stats from drughealthcondition
dhc_path = files['drughealthcondition']
linked_drugs = set()
linked_conditions = set()
drug_link_counts = Counter()
cond_link_counts = Counter()
if dhc_path.exists():
    with open(dhc_path, encoding='utf-8') as f:
        r = csv.reader(f)
        hdr = next(r, None)
        for row in r:
            if not row: continue
            try:
                did = int(row[0])
                cid = row[1].strip()
            except Exception:
                continue
            linked_drugs.add(did)
            linked_conditions.add(cid)
            drug_link_counts[did]+=1
            cond_link_counts[cid]+=1

# Top linked drugs (ids)
top_drugs = drug_link_counts.most_common(10)
# Top linked conditions
top_conds = cond_link_counts.most_common(10)

out_lines = []
out_lines.append('Data summary report')
out_lines.append('-------------------')
for k in ['drug','healthcondition','drughealthcondition','food','foodnutrient','nutrient','drugnutrientcontraindication','unlinked_drugs']:
    v = summary.get(k)
    out_lines.append(f'- {k}: {v if v is not None else "missing"} rows')

out_lines.append('')
out_lines.append(f'- Linked distinct drugs in drughealthcondition: {len(linked_drugs)}')
out_lines.append(f'- Linked distinct condition_ids in drughealthcondition: {len(linked_conditions)}')

out_lines.append('')
out_lines.append('Top 10 drugs by number of linked conditions (drug_id: count):')
for did,cnt in top_drugs:
    out_lines.append(f'  - {did}: {cnt}')

out_lines.append('Top 10 condition_ids by linked drug count (condition_id: count):')
for cid,cnt in top_conds:
    out_lines.append(f'  - {cid}: {cnt}')

# coverage file preview
covp = files['condition_coverage']
if covp.exists():
    out_lines.append('')
    out_lines.append(f'- Condition coverage summary: {covp.name} present ({summary.get("condition_coverage",0)} rows)')

# write file
outp = GD / 'data_summary.txt'
with open(outp, 'w', encoding='utf-8') as f:
    f.write('\n'.join(out_lines))

print('\n'.join(out_lines))
print('\nWrote summary to', str(outp))
