import json
import random
from pathlib import Path

# Load existing foods
foods = json.load(open(r'd:\dataset\real_data_cache\usda_foods.json'))

# Danh sách nutrients phổ biến
NUTRIENTS = [
    {"name": "Protein", "number": "203", "unit": "g"},
    {"name": "Total lipid (fat)", "number": "204", "unit": "g"},
    {"name": "Carbohydrate, by difference", "number": "205", "unit": "g"},
    {"name": "Fiber, total dietary", "number": "291", "unit": "g"},
    {"name": "Calcium, Ca", "number": "301", "unit": "mg"},
    {"name": "Magnesium, Mg", "number": "304", "unit": "mg"},
    {"name": "Sodium, Na", "number": "307", "unit": "mg"},
    {"name": "Potassium, K", "number": "306", "unit": "mg"},
    {"name": "Iron, Fe", "number": "303", "unit": "mg"},
    {"name": "Zinc, Zn", "number": "309", "unit": "mg"},
    {"name": "Vitamin C, total ascorbic acid", "number": "401", "unit": "mg"},
    {"name": "Vitamin K (phylloquinone)", "number": "430", "unit": "µg"},
]

nutrients = {}

print(f"Creating mock nutrients for {min(len(foods), 200)} foods...")

for idx, food in enumerate(foods[:200], 1):
    fdc_id = food["fdcId"]
    
    # Random chọn 3-8 nutrients
    num_nutrients = random.randint(3, 8)
    selected = random.sample(NUTRIENTS, num_nutrients)
    
    food_nutrients = []
    for nut in selected:
        amount = round(random.uniform(0.1, 50.0), 2)
        food_nutrients.append({
            "nutrient": {
                "name": nut["name"],
                "number": nut["number"],
                "unitName": nut["unit"]
            },
            "amount": amount
        })
    
    nutrients[fdc_id] = {
        "fdcId": fdc_id,
        "description": food.get("description", "Unknown"),
        "foodNutrients": food_nutrients
    }
    
    if idx % 50 == 0:
        print(f"  Progress: {idx}/200")

# Save
output_path = Path(r'd:\dataset\real_data_cache\usda_nutrients.json')
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(nutrients, f, indent=2)

print(f"\n✔ Created mock USDA nutrients for {len(nutrients)} foods")
print(f"  Saved to: {output_path}")
