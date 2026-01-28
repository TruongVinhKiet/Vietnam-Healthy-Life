import json
import csv
from pathlib import Path

BASE = Path(__file__).resolve().parent
CACHE = BASE / 'WHO_ICD10'
OUT = BASE / 'Generated_Data' / 'drughealthcondition'

# Files
related_icd = CACHE / 'dailymed_related_icd10.json'
healthcondition_csv = BASE / 'Generated_Data' / 'healthcondition' / 'healthcondition.csv'
dhc_csv = OUT / 'drughealthcondition.csv'
backup_csv = OUT / 'drughealthcondition.backup.csv'

if not related_icd.exists():
    raise SystemExit('Missing WHO_ICD10/dailymed_related_icd10.json')
if not healthcondition_csv.exists():
    raise SystemExit('Missing Generated_Data/healthcondition/healthcondition.csv')
if not dhc_csv.exists():
    raise SystemExit('Missing Generated_Data/drughealthcondition/drughealthcondition.csv')

# Load related ICD codes
with open(related_icd, encoding='utf-8') as f:
    data = json.load(f)
# data is expected to be dict: spl_setid -> list of [code, name, score]
codes = set()
if isinstance(data, dict):
    for v in data.values():
        if not isinstance(v, list):
            continue
        for item in v:
            if not item:
                continue
            # item can be [code, name, score]
            code = item[0] if isinstance(item, (list, tuple)) and len(item) > 0 else None
            if code:
                codes.add(str(code).upper().replace('.', ''))
elif isinstance(data, list):
    for item in data:
        code = item.get('code') if isinstance(item, dict) else None
        if code:
            codes.add(str(code).upper().replace('.', ''))

print(f'Loaded {len(codes)} related ICD codes')

# Map condition_id -> normalized condition_code from healthcondition.csv
condid_to_code = {}
with open(healthcondition_csv, encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        cid = row.get('condition_id')
        code = row.get('condition_code') or ''
        if not cid: continue
        norm = code.upper().replace('.', '')
        condid_to_code[cid] = norm

print(f'Loaded {len(condid_to_code)} healthcondition ids')

# Determine allowed condition_ids (whose codes intersect the 200 set)
allowed_cids = {cid for cid, code in condid_to_code.items() if code in codes}
print(f'Condition IDs matching related ICD set: {len(allowed_cids)}')

total = 0
# If current dhc file is empty (likely from previous run), try to restore from backup
import shutil
if dhc_csv.exists():
    # check if file has data rows
    with open(dhc_csv, encoding='utf-8') as f:
        lines = f.readlines()
    if len(lines) <= 1 and backup_csv.exists():
        print('Current drughealthcondition is empty — restoring from backup for filtering')
        shutil.copy2(backup_csv, dhc_csv)
    else:
        # create a backup of current as well
        shutil.copy2(dhc_csv, backup_csv)
else:
    if backup_csv.exists():
        shutil.copy2(backup_csv, dhc_csv)

# Now read dhc and filter
kept = 0
total = 0
out_rows = []
with open(dhc_csv, encoding='utf-8') as f:
    reader = csv.reader(f)
    header = next(reader)
    out_rows.append(header)
    for row in reader:
        total += 1
        if not row: continue
        cid = row[1].strip() if len(row) > 1 else ''
        if cid in allowed_cids:
            out_rows.append(row)
            kept += 1

# Write filtered file (overwrite dhc_csv)
with open(dhc_csv, 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f)
    for r in out_rows:
        writer.writerow(r)

print(f'Filtered drughealthcondition: kept {kept} of {total} rows')
print('Backup saved to', backup_csv)
print('Wrote filtered:', dhc_csv)
