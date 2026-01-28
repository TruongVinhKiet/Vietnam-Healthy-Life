import requests
import csv
import json
from pathlib import Path
import zipfile
import io

# Link tải file ICD-10 CSV từ CMS (cần cập nhật nếu CMS thay đổi link)
CSV_URL = "https://data.cms.gov/provider-data/sites/default/files/resources/2z4k-pj9g/ICD10CM_FY2024_FullCodes.csv"
CACHE_DIR = Path(r"D:\dataset\real_data_cache")
CSV_PATH = CACHE_DIR / "icd10cm_codes_full.csv"
JSON_PATH = CACHE_DIR / "icd10.json"

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
        # CMS file: Code, Description
        code = row.get("Code")
        desc = row.get("Description")
        if code and desc:
            result.append({"code": code, "desc": desc})

with open(JSON_PATH, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print(f"Converted {CSV_PATH} to {JSON_PATH} ✔")
print(f"Total ICD-10 codes: {len(result)}")
