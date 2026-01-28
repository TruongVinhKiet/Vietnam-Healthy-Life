import re
import random
from pathlib import Path

# Keep all nutrients unchanged
KEPT_NUTRIENT_IDS = {
    276, 283, 291, 295, 297, 293, 298,
    301, 303, 304, 305, 306, 307, 309, 310, 312, 313, 314, 315, 316, 317,
    318, 320, 323, 324, 325, 326, 328, 401, 405, 417, 428, 429, 430,
    500, 601, 621, 629, 645, 646
}

BASE = Path(__file__).resolve().parents[1]
INPUT = BASE / "usda_data" / "usda_import_full.sql"
OUTPUT = BASE / "usda_data" / "usda_filtered_import.sql"

# Limits and randomness
MAX_FOODNUTRIENT_ROWS = 1000
random.seed()

# Regex patterns
re_nutrient = re.compile(r"INSERT INTO\s+Nutrient.*VALUES\s*\(\s*(\d+)\s*,", re.IGNORECASE)
# capture id, name, category for Food to detect 'milk'
re_food = re.compile(r"INSERT INTO\s+Food\s*\(.*\)\s*VALUES\s*\(\s*(\d+)\s*,\s*'([^']*)'\s*,\s*'([^']*)'\s*\)", re.IGNORECASE)
re_food_simple = re.compile(r"INSERT INTO\s+Food\s*\(.*\)\s*VALUES\s*\(\s*(\d+)\s*,", re.IGNORECASE)
re_foodnutrient = re.compile(r"INSERT INTO\s+FoodNutrient.*VALUES\s*\(\s*(\d+)\s*,\s*(\d+)\s*,", re.IGNORECASE)

nutrient_lines = []
food_lines_map = {}        # fid -> full Food INSERT line
foodnutrient_map = {}     # fid -> list of FoodNutrient INSERT lines

if not INPUT.exists():
    print(f"Input file not found: {INPUT}")
    raise SystemExit(1)

# First pass: collect all Nutrient INSERTs, Food INSERTs and FoodNutrient INSERTs
with INPUT.open('r', encoding='utf-8', errors='replace') as f:
    for line in f:
        ln = line.rstrip('\n')

        m_n = re_nutrient.search(ln)
        if m_n:
            # keep all rows for Nutrient that match any of KEPT_NUTRIENT_IDS (set already defines kept IDs)
            nid = int(m_n.group(1))
            if nid in KEPT_NUTRIENT_IDS:
                nutrient_lines.append(ln)
            continue

        m_f = re_food.search(ln)
        if m_f:
            fid = int(m_f.group(1))
            food_lines_map[fid] = ln
            continue

        # fallback for Food lines that might not match the full pattern
        m_f_simple = re_food_simple.search(ln)
        if m_f_simple and (m_f_simple and int(m_f_simple.group(1)) not in food_lines_map):
            fid = int(m_f_simple.group(1))
            food_lines_map.setdefault(fid, ln)
            continue

        m_fn = re_foodnutrient.search(ln)
        if m_fn:
            fid = int(m_fn.group(1))
            # group FoodNutrient lines by food id
            foodnutrient_map.setdefault(fid, []).append(ln)
            continue

# Candidate food ids that have FoodNutrient rows
candidate_fids = [fid for fid, lst in foodnutrient_map.items() if lst]

# Find milk food ids by looking at Food name (case-insensitive)
milk_fids = []
for fid, fln in food_lines_map.items():
    m = re_food.search(fln)
    if m:
        name = m.group(2)
        if 'milk' in name.lower():
            milk_fids.append(fid)

selected_food_ids = set()
selected_foodnutrient_lines = []
total_lines = 0

# Ensure at least one milk food is included if available
if milk_fids:
    milk_choice = random.choice(milk_fids)
    milk_group = foodnutrient_map.get(milk_choice, [])
    if milk_group:
        take = min(len(milk_group), MAX_FOODNUTRIENT_ROWS - total_lines)
        if take > 0:
            selected_foodnutrient_lines.extend(milk_group[:take])
            total_lines += take
        selected_food_ids.add(milk_choice)
    else:
        # include the milk Food row even if it has no FoodNutrient lines
        selected_food_ids.add(milk_choice)

# Shuffle other candidate foods and add their whole groups while staying under the limit
other_fids = [fid for fid in candidate_fids if fid not in selected_food_ids]
random.shuffle(other_fids)

for fid in other_fids:
    group = foodnutrient_map.get(fid, [])
    if not group:
        continue
    if total_lines + len(group) <= MAX_FOODNUTRIENT_ROWS:
        selected_foodnutrient_lines.extend(group)
        selected_food_ids.add(fid)
        total_lines += len(group)
        if total_lines == MAX_FOODNUTRIENT_ROWS:
            break
    else:
        # skip this food to avoid exceeding the limit
        continue

# Fallback: if still nothing selected (small datasets), try adding partial groups up to the limit
if total_lines < MAX_FOODNUTRIENT_ROWS and not selected_foodnutrient_lines and candidate_fids:
    random_fids = candidate_fids[:]
    random.shuffle(random_fids)
    for fid in random_fids:
        group = foodnutrient_map.get(fid, [])
        if not group:
            continue
        take = min(len(group), MAX_FOODNUTRIENT_ROWS - total_lines)
        if take > 0:
            selected_foodnutrient_lines.extend(group[:take])
            selected_food_ids.add(fid)
            total_lines += take
        if total_lines >= MAX_FOODNUTRIENT_ROWS:
            break

# Collect Food INSERT lines for selected foods (preserve order by id)
selected_food_lines = [food_lines_map[fid] for fid in sorted(selected_food_ids) if fid in food_lines_map]

# Write output file
with OUTPUT.open('w', encoding='utf-8') as out:
    out.write('-- Filtered USDA import: nutrients kept, sampled foods (include one milk if present), and FoodNutrient rows limited to ' + str(MAX_FOODNUTRIENT_ROWS) + '\n')
    out.write('-- MAX_FOODNUTRIENT_ROWS: ' + str(MAX_FOODNUTRIENT_ROWS) + '\n\n')

    if nutrient_lines:
        out.write('-- Nutrient rows (kept)\n')
        for ln in nutrient_lines:
            out.write(ln + '\n')
        out.write('\n')
    else:
        out.write('-- No nutrient rows found\n\n')

    if selected_food_lines:
        out.write('-- Food rows (sampled)\n')
        for ln in selected_food_lines:
            out.write(ln + '\n')
        out.write('\n')
    else:
        out.write('-- No Food rows selected\n\n')

    if selected_foodnutrient_lines:
        out.write('-- FoodNutrient rows (sampled)\n')
        for ln in selected_foodnutrient_lines:
            out.write(ln + '\n')
        out.write('\n')
    else:
        out.write('-- No FoodNutrient rows selected\n\n')

print(f"Wrote filtered SQL to: {OUTPUT}")
print(f"Nutrient rows kept: {len(nutrient_lines)}, Foods kept: {len(selected_food_lines)}, FoodNutrient rows kept: {len(selected_foodnutrient_lines)}")
