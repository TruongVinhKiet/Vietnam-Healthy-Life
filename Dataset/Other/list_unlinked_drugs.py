import csv
from pathlib import Path

BASE = Path(__file__).resolve().parent
OUT = BASE / "Generated_Data"

drug_csv = OUT / "drug" / "drug.csv"
dhc_csv = OUT / "drughealthcondition" / "drughealthcondition.csv"
output_csv = OUT / "unlinked_drugs.csv"

if not drug_csv.exists():
    print("Missing:", drug_csv)
    raise SystemExit(1)
if not dhc_csv.exists():
    print("Missing:", dhc_csv)
    raise SystemExit(1)

# Read drug IDs and metadata
all_drugs = {}
with open(drug_csv, newline='', encoding='utf-8') as f:
    reader = csv.reader(f, delimiter=',', quotechar='\'')
    header = next(reader, None)
    for row in reader:
        if not row:
            continue
        try:
            drug_id = int(row[0])
        except Exception:
            continue
        # name and source may be quoted or NULL
        name = row[1] if len(row) > 1 else ''
        source = row[2] if len(row) > 2 else ''
        # strip surrounding single quotes if present
        if name and name.startswith("'") and name.endswith("'"):
            name = name[1:-1].replace("''", "'")
        if source and source.startswith("'") and source.endswith("'"):
            source = source[1:-1].replace("''", "'")
        all_drugs[drug_id] = (name, source)

# Read drug IDs that appear in drughealthcondition
linked = set()
with open(dhc_csv, newline='', encoding='utf-8') as f:
    reader = csv.reader(f, delimiter=',', quotechar='\'')
    header = next(reader, None)
    for row in reader:
        if not row:
            continue
        try:
            did = int(row[0])
            linked.add(did)
        except Exception:
            continue

unlinked = sorted([d for d in all_drugs.keys() if d not in linked])

print(f"Total drugs: {len(all_drugs)}")
print(f"Linked drugs (in drughealthcondition): {len(linked)}")
print(f"Unlinked drugs: {len(unlinked)}")

# Write output CSV
with open(output_csv, 'w', newline='', encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(["drug_id", "name", "source_link"])
    for did in unlinked:
        name, source = all_drugs.get(did, ('', ''))
        writer.writerow([did, name, source])

# Print sample
print('\nSample unlinked drugs (first 20):')
for did in unlinked[:20]:
    name, source = all_drugs.get(did, ('', ''))
    print(did, name)

print('\nWrote:', output_csv)
