import json
import random
from pathlib import Path

# Load drugbank để lấy drug names
import pandas as pd
df_drug = pd.read_csv(r'd:\dataset\drugbank\drugbank_clean.csv', low_memory=False)

# Load ICD10
icd10 = json.load(open(r'd:\dataset\real_data_cache\icd10.json'))

# Tạo mock DailyMed SPL data
spl_details = {}

# Danh sách các indications và warnings phổ biến
COMMON_INDICATIONS = [
    "Treatment of bacterial infections",
    "Treatment of hypertension",
    "Treatment of diabetes mellitus type 2",
    "Treatment of pain and inflammation",
    "Treatment of depression and anxiety",
    "Treatment of heart failure",
    "Treatment of chronic pain",
    "Treatment of allergic rhinitis",
    "Treatment of asthma",
    "Treatment of rheumatoid arthritis",
]

COMMON_WARNINGS = [
    "Do not take with calcium supplements",
    "Avoid iron-rich foods",
    "May interact with vitamin K",
    "Limit protein intake",
    "Avoid high-fat meals",
    "Do not consume with magnesium",
    "May deplete zinc levels",
    "Avoid fiber supplements",
    "Limit vitamin C intake",
    "May interact with calcium carbonate",
]

# Lấy 200 drugs ngẫu nhiên từ drugbank
valid_drugs = df_drug[df_drug['name'].notna()].sample(min(200, len(df_drug)), random_state=42)

for idx, row in valid_drugs.iterrows():
    spl_id = f"mock-{idx:04d}"
    drug_name = row['name']
    
    # Random chọn indications
    num_indications = random.randint(1, 3)
    indications = random.sample(COMMON_INDICATIONS, num_indications)
    
    # Random chọn warnings
    num_warnings = random.randint(1, 4)
    warnings = random.sample(COMMON_WARNINGS, num_warnings)
    
    spl_details[spl_id] = {
        "data": {
            "name": [drug_name, f"{drug_name} tablets", f"{drug_name} oral"],
            "indications": indications,
            "warnings": warnings,
            "interactions": [w for w in warnings if "interact" in w.lower()],
            "dosage_and_administration": [
                f"Take {drug_name} as directed by physician"
            ]
        }
    }

# Save
output_path = Path(r'd:\dataset\real_data_cache\dailymed_spl.json')
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(spl_details, f, indent=2)

print(f"✔ Created mock DailyMed SPL data with {len(spl_details)} records")
print(f"  Saved to: {output_path}")
