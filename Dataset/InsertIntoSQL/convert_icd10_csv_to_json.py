import csv
import json
from pathlib import Path

csv_path = Path(r"D:\dataset\real_data_cache\icd10cm_codes_sample.csv")
json_path = Path(r"D:\dataset\real_data_cache\icd10.json")

result = []
with open(csv_path, encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        result.append({"code": row["code"], "desc": row["desc"]})

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)

print(f"Converted {csv_path} to {json_path} ✔")
