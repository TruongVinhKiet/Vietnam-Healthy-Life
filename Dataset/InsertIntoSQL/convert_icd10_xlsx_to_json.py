import pandas as pd
import json
from pathlib import Path

xlsx_path = Path(r"D:\dataset\real_data_cache\icd10cm_codes_full.xlsx")
json_path = Path(r"D:\dataset\real_data_cache\icd10.json")

# Đọc file Excel ICD-10
# Tùy cấu trúc file, có thể cần chỉnh lại tên cột
# Thường là 'Code' và 'Description' hoặc tương tự

df = pd.read_excel(xlsx_path)

# Tìm cột mã và mô tả
code_col = None
desc_col = None
for col in df.columns:
    if 'code' in col.lower():
        code_col = col
    if 'desc' in col.lower() or 'description' in col.lower() or 'title' in col.lower():
        desc_col = col
if not code_col or not desc_col:
    raise Exception(f"Không tìm thấy cột mã hoặc mô tả trong file: {df.columns}")

result = []
for _, row in df.iterrows():
    code = str(row[code_col]).strip()
    desc = str(row[desc_col]).strip()
    if code and desc:
        result.append({"code": code, "desc": desc})

with open(json_path, "w", encoding="utf-8") as f:
    json.dump(result, f, indent=2, ensure_ascii=False)
print(f"Converted {xlsx_path} to {json_path} ✔")
print(f"Total ICD-10 codes: {len(result)}")
