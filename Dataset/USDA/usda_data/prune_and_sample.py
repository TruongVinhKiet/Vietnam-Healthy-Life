import re
import random
import os

random.seed(42)

# Simple translation mapping (English -> Vietnamese) for common food/category terms
TRANSLATIONS = {
    'milk': 'sữa',
    'human': 'người',
    'whole': 'nguyên béo',
    'reduced fat': 'ít béo',
    'low fat': 'ít béo',
    'fat free': 'không béo',
    'skim': 'tách béo',
    'lactose free': 'không chứa lactose',
    'flavored': 'hương vị',
    'cheese': 'phô mai',
    'yogurt': 'sữa chua',
    'beef': 'bò',
    'chicken': 'gà',
    'fish': 'cá',
    'egg': 'trứng',
    'eggs': 'trứng',
    'human milk': 'sữa mẹ',
    'plant-based': 'thực vật',
    'plant-based milk': 'sữa thực vật',
    'protein': 'protein',
    'water': 'nước',
}

# Basic case-insensitive token replace using longest-first
def translate_text(text):
    t = text
    lower = t.lower()
    # replace multi-word keys first
    for key in sorted(TRANSLATIONS.keys(), key=lambda k: -len(k)):
        if key in lower:
            # Do a case-preserving replacement by searching occurrences
            pattern = re.compile(re.escape(key), flags=re.IGNORECASE)
            t = pattern.sub(TRANSLATIONS[key], t)
            lower = t.lower()
    return t


def parse_insert_values(line, table_name):
    # Extract the contents inside VALUES ( ... );
    # Return raw inner text or None
    m = re.search(r"INSERT INTO\s+%s\s*\([^)]*\)\s*VALUES\s*\((.*)\)\s*;" % re.escape(table_name), line, flags=re.IGNORECASE)
    if m:
        return m.group(1)
    return None


def split_sql_values(s):
    # Split a SQL VALUES tuple into top-level comma-separated parts, handling single-quoted strings with escaped single quotes ('')
    parts = []
    cur = []
    i = 0
    L = len(s)
    in_quote = False
    while i < L:
        ch = s[i]
        if ch == "'":
            cur.append(ch)
            i += 1
            # read until closing quote (handle doubled '' for escaped quote)
            while i < L:
                cur.append(s[i])
                if s[i] == "'":
                    # if next is also quote, it's escaped
                    if i+1 < L and s[i+1] == "'":
                        cur.append(s[i+1])
                        i += 2
                        continue
                    else:
                        i += 1
                        break
                i += 1
        elif ch == ',' and not in_quote:
            parts.append(''.join(cur).strip())
            cur = []
            i += 1
        else:
            cur.append(ch)
            i += 1
    if cur:
        parts.append(''.join(cur).strip())
    return parts


def parse_foods(food_sql_path):
    foods = []
    if not os.path.exists(food_sql_path):
        print('Missing', food_sql_path)
        return foods
    with open(food_sql_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            val = parse_insert_values(line, 'Food')
            if val:
                parts = split_sql_values(val)
                if len(parts) >= 3:
                    try:
                        fid = int(parts[0])
                    except:
                        continue
                    name = parts[1].strip()
                    if name.startswith("'") and name.endswith("'"):
                        name = name[1:-1].replace("''", "'")
                    category = parts[2].strip()
                    if category.startswith("'") and category.endswith("'"):
                        category = category[1:-1].replace("''", "'")
                    foods.append({'id': fid, 'name': name, 'category': category, 'raw_values': val})
    return foods


def parse_foodnutrients(fn_sql_path):
    rows = []
    if not os.path.exists(fn_sql_path):
        print('Missing', fn_sql_path)
        return rows
    with open(fn_sql_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            val = parse_insert_values(line, 'FoodNutrient')
            if val:
                parts = split_sql_values(val)
                if len(parts) >= 3:
                    try:
                        fid = int(parts[0])
                        nid = int(parts[1])
                    except:
                        continue
                    amount = parts[2].strip()
                    rows.append({'food_id': fid, 'nutrient_id': nid, 'amount_raw': amount, 'line': line.strip()})
    return rows


def parse_nutrients(n_sql_path):
    nutrients = {}
    if not os.path.exists(n_sql_path):
        print('Missing', n_sql_path)
        return nutrients
    with open(n_sql_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            val = parse_insert_values(line, 'Nutrient')
            if val:
                parts = split_sql_values(val)
                if len(parts) >= 3:
                    try:
                        nid = int(parts[0])
                    except:
                        continue
                    name = parts[1].strip()
                    if name.startswith("'") and name.endswith("'"):
                        name = name[1:-1].replace("''", "'")
                    unit = parts[2].strip()
                    if unit.startswith("'") and unit.endswith("'"):
                        unit = unit[1:-1].replace("''", "'")
                    nutrients[nid] = {'id': nid, 'name': name, 'unit': unit, 'raw_values': val}
    return nutrients


def main():
    base = os.path.dirname(__file__) or '.'
    food_sql = os.path.join(base, 'usda_import_food.sql')
    fn_sql = os.path.join(base, 'usda_import_foodnutrient.sql')
    n_sql = os.path.join(base, 'usda_import_nutrient.sql')

    print('Parsing foods...')
    foods = parse_foods(food_sql)
    print('Found', len(foods), 'food INSERT lines')

    # Deduplicate by name -> group
    name_map = {}
    for f in foods:
        key = f['name'].strip().lower()
        name_map.setdefault(key, []).append(f)

    unique_names = list(name_map.keys())
    print('Unique food names:', len(unique_names))

    # pick up to 10 unique names randomly
    if len(unique_names) <= 10:
        chosen_names = unique_names
    else:
        chosen_names = random.sample(unique_names, 10)

    # For each chosen name, choose one random entry among duplicates
    chosen_foods = []
    for nm in chosen_names:
        entries = name_map[nm]
        chosen = random.choice(entries)
        chosen_foods.append(chosen)

    chosen_ids = set(f['id'] for f in chosen_foods)
    print('Selected', len(chosen_foods), 'foods')

    # Parse FoodNutrient and pick those matching chosen_ids
    print('Parsing foodnutrients...')
    fns = parse_foodnutrients(fn_sql)
    matched_fns = [r for r in fns if r['food_id'] in chosen_ids]
    print('Found', len(matched_fns), 'FoodNutrient rows for chosen foods')

    # gather nutrient ids
    nutrient_ids = sorted({r['nutrient_id'] for r in matched_fns})
    print('Need', len(nutrient_ids), 'distinct nutrients')

    # Parse Nutrients and filter
    nutrients = parse_nutrients(n_sql)
    selected_nutrients = {nid: nutrients.get(nid) for nid in nutrient_ids if nid in nutrients}
    missing_n = [nid for nid in nutrient_ids if nid not in nutrients]
    if missing_n:
        print('Warning: missing nutrient definitions for', missing_n)

    # Write outputs
    out_food = os.path.join(base, 'sampled_food.sql')
    out_fn = os.path.join(base, 'sampled_foodnutrient.sql')
    out_n = os.path.join(base, 'sampled_nutrient.sql')

    with open(out_food, 'w', encoding='utf-8') as fo:
        fo.write('-- INSERTs for sampled Food (10 random unique names), names/categories translated to Vietnamese where possible\n')
        for f in chosen_foods:
            vid = f['id']
            vname = translate_text(f['name'])
            vcat = translate_text(f['category']) if f.get('category') else ''
            # escape single quotes
            vname_sql = vname.replace("'", "''")
            vcat_sql = vcat.replace("'", "''")
            fo.write(f"INSERT INTO Food (food_id, name, category) VALUES ({vid}, '{vname_sql}', '{vcat_sql}');\n")

    with open(out_fn, 'w', encoding='utf-8') as fno:
        fno.write('-- INSERTs for FoodNutrient rows matching the sampled Food rows\n')
        for r in matched_fns:
            # reuse original amount token exactly
            fid = r['food_id']
            nid = r['nutrient_id']
            amt = r['amount_raw']
            fno.write(f"INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES ({fid}, {nid}, {amt});\n")

    with open(out_n, 'w', encoding='utf-8') as no:
        no.write('-- INSERTs for Nutrient rows required by sampled FoodNutrient\n')
        for nid in sorted(selected_nutrients.keys()):
            n = selected_nutrients[nid]
            if not n:
                continue
            nid = n['id']
            name = n['name'].replace("'", "''")
            unit = n['unit'].replace("'", "''")
            no.write(f"INSERT INTO Nutrient (nutrient_id, name, unit) VALUES ({nid}, '{name}', '{unit}');\n")

    print('\nOutputs written:')
    print(' -', out_food)
    print(' -', out_n)
    print(' -', out_fn)
    print('\nSummary:')
    for f in chosen_foods:
        print(f" {f['id']} - {f['name']} -> {translate_text(f['name'])}")
    print('Total FoodNutrient rows exported:', len(matched_fns))

if __name__ == '__main__':
    main()
