import os
import re
import json
import pandas as pd
from pathlib import Path
from difflib import get_close_matches

BASE = Path(r"D:\dataset")
CACHE = BASE / "real_data_cache"

# Load data
usda_foods = json.load(open(CACHE/"usda_foods.json", encoding="utf-8"))
usda_nutrients = json.load(open(CACHE/"usda_nutrients.json", encoding="utf-8"))

def normalize(t):
    if not t:
        return ""
    t = t.lower()
    t = re.sub(r"[^a-z0-9 ]+", " ", t)
    t = re.sub(r"\s+", " ", t).strip()
    return t

NUTRIENT_MAP = {
    "calcium": 24,
    "magnesium": 26,
    "iron": 29, "ferrous": 29, "ferric": 29,
    "zinc": 30,
    "fiber": 5, "dietary fiber": 5,
    "fat": 3, "total lipid": 3, "fatty": 3,
    "protein": 2,
    "vitamin k": 14,
    "vitamin c": 15, "ascorbic": 15,
    "carbohydrate": 4, "carb": 4,
    "sodium": 27, "potassium": 28,
}

nut_keys = list(NUTRIENT_MAP.keys())

def match_nutrient(nname):
    """Match nutrient by fuzzy or substring"""
    # Try fuzzy first
    fuzzy = get_close_matches(nname, nut_keys, cutoff=0.5, n=1)
    if fuzzy:
        return NUTRIENT_MAP[fuzzy[0]]
    # Try substring match
    for key in nut_keys:
        if key in nname or nname in key:
            return NUTRIENT_MAP[key]
    return None

# Test
fn_sql = []
fid = 1

for food in usda_foods[:10]:
    nutrient_detail = usda_nutrients.get(food["fdcId"], {})
    print(f"\nFood {fid}: {food['description'][:50]}")
    print(f"  Nutrient detail keys: {list(nutrient_detail.keys())}")
    print(f"  foodNutrients count: {len(nutrient_detail.get('foodNutrients', []))}")
    
    for nitem in nutrient_detail.get("foodNutrients", []):
        nname_orig = nitem["nutrient"]["name"]
        nname = normalize(nname_orig)
        amount = nitem.get("amount", 0)
        
        nid = match_nutrient(nname)
        print(f"    {nname_orig} -> {nname} -> nid={nid}")
        
        if nid:
            fn_sql.append(f"INSERT ... VALUES ({fid}, {nid}, {amount});")
    
    fid += 1

print(f"\n\nTotal fn_sql: {len(fn_sql)}")
print(f"Sample: {fn_sql[:3]}")
