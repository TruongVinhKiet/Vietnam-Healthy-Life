import requests
import csv
import json
from pathlib import Path
import zipfile
import io

# Nguồn ICD-10 CSV công khai (WHO, CMS, hoặc openhealthcare)
CSV_URL = "https://raw.githubusercontent.com/openhealthcare/icd10/master/codes.csv"
CACHE_DIR = Path(r"D:\dataset\real_data_cache")
CSV_PATH = CACHE_DIR / "icd10cm_codes_full.csv"
JSON_PATH = CACHE_DIR / "icd10.json"

# Tải file CSV ICD-10
print("Downloading ICD-10 CSV from:", CSV_URL)
r = requests.get(CSV_URL)
r.raise_for_status()
with open(CSV_PATH, "wb") as f:
    f.write(r.content)
print(f"Saved to {CSV_PATH}")

# Chuyển đổi sang JSON
result = []
with open(CSV_PATH, encoding="utf-8") as f:
    reader = csv.DictReader(f)
    for row in reader:
        # Tùy nguồn, có thể cần đổi tên trường
        code = row.get("code") or row.get("Code")
        desc = row.get("desc") or row.get("Description") or row.get("title")
        if code and desc:
            result.append({"code": code, "desc": desc})

with open(JSON_PATH, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print(f"Converted {CSV_PATH} to {JSON_PATH} ✔")
print(f"Total ICD-10 codes: {len(result)}")
