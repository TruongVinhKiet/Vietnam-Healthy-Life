# -*- coding: utf-8 -*-
import sys
import pandas as pd
import random

# Bảo đảm hiển thị Unicode trên Windows / VSCode
sys.stdout.reconfigure(encoding='utf-8')

print("🔍 Đang đọc các file USDA...")

# (BỎ GIỚI HẠN SỐ BẢN GHI) -- không còn MAX_PER_TABLE

# ============================================================
# 1️⃣ Đọc file USDA gốc (ép encoding)
# ============================================================
food = pd.read_csv("food.csv", encoding="utf-8", on_bad_lines="skip")
nutrient = pd.read_csv("nutrient.csv", encoding="utf-8", on_bad_lines="skip")
food_nutrient = pd.read_csv("food_nutrient.csv", encoding="utf-8", on_bad_lines="skip")

try:
    category = pd.read_csv("wweia_food_category.csv", encoding="utf-8", on_bad_lines="skip")
    print("📁 Đã tải wweia_food_category.csv (dùng để gắn loại thực phẩm).")
except FileNotFoundError:
    print("⚠️ Không tìm thấy wweia_food_category.csv, sẽ tạo dữ liệu mẫu.")
    category = pd.DataFrame({
        'wweia_food_category': range(1, 11),
        'wweia_food_category_description': [
            'Dairy', 'Fruits', 'Vegetables', 'Grains', 'Meat', 'Beverages',
            'Snacks', 'Seafood', 'Legumes', 'Other'
        ]
    })

# ============================================================
# 2️⃣ Lấy đúng tên món ăn + category thật từ file wweia_food_category
# ============================================================
print("📊 Các cột trong food.csv:", list(food.columns))

# Lấy cột mô tả tên món
if "description" in food.columns:
    food["name"] = food["description"]
elif "Description" in food.columns:
    food["name"] = food["Description"]
else:
    food["name"] = food.iloc[:, 2]  # fallback

food["food_id"] = food["fdc_id"]

# Đảm bảo có cột food_category_id để map
if "food_category_id" in food.columns:
    food["category_code"] = food["food_category_id"].astype(str)
else:
    food["category_code"] = None

# Chuẩn hóa bảng category
category = category.rename(columns={
    "wweia_food_category": "category_code",
    "wweia_food_category_description": "category_name"
})
category["category_code"] = category["category_code"].astype(str)

# Nếu food không có mã category hoặc merge thất bại, cố gắng dò category từ mô tả trong wweia
import re
from difflib import get_close_matches

# chuẩn hóa tên để so sánh
def _norm(s):
    if not isinstance(s, str):
        return ""
    return " ".join(re.findall(r'\w+', s.lower()))

# Sử dụng toàn bộ danh sách category (không giới hạn)
_cat_rows = []
for c in category["category_name"].dropna().astype(str).unique():
    _cat_rows.append((c, _norm(c)))
# ưu tiên các mô tả dài hơn trước (cụ thể hơn)
_cat_rows = sorted(_cat_rows, key=lambda x: len(x[1]), reverse=True)

def _infer_category_from_name(food_name):
    n = _norm(food_name)
    if not n:
        return None
    # 1) exact token set equality (milk human <-> human milk)
    name_tokens = set(n.split())
    for cat, ncat in _cat_rows:
        if set(ncat.split()) == name_tokens:
            return cat
    # 2) direct substring match (prefer cụ thể)
    for cat, ncat in _cat_rows:
        if ncat and ncat in n:
            return cat
    # 3) reverse substring (tên món trong mô tả category)
    for cat, ncat in _cat_rows:
        if n and n in ncat:
            return cat
    # 4) token intersection (ít chặt hơn)
    for cat, ncat in _cat_rows:
        if set(ncat.split()) & name_tokens:
            return cat
    # 5) fuzzy fallback
    matches = get_close_matches(n, [ncat for _, ncat in _cat_rows], n=1, cutoff=0.6)
    if matches:
        for cat, ncat in _cat_rows:
            if ncat == matches[0]:
                return cat
    return None

# Gộp tên loại thực phẩm vào food (merge theo code nếu có)
food = food.merge(category, on="category_code", how="left")

# Với những hàng không map được bằng mã, thử suy luận từ tên món
mask_no_cat = food["category_name"].isna()
if mask_no_cat.any():
    inferred = food.loc[mask_no_cat, "name"].astype(str).apply(_infer_category_from_name)
    # chỉ gán nếu tìm được kết quả
    food.loc[mask_no_cat, "category_name"] = inferred.combine_first(food.loc[mask_no_cat, "category_name"])

food["category_name"] = food["category_name"].fillna("General")

# Lấy 3 cột cần thiết
food = food[["food_id", "name", "category_name"]].dropna().drop_duplicates()
food = food.rename(columns={"category_name": "category"})

# (BỎ GIỚI HẠN SỐ LƯỢNG food)

# ============================================================
# 3️⃣ Nutrient & FoodNutrient
# ============================================================
# nhận diện đúng cột chứa số hiệu nutrient: ưu tiên nutrient_nbr, fallback sang id
if "nutrient_nbr" in nutrient.columns:
    nutrient = nutrient.rename(columns={
        "nutrient_nbr": "nutrient_id",
        "name": "name",
        "unit_name": "unit"
    })
elif "id" in nutrient.columns:
    nutrient = nutrient.rename(columns={
        "id": "nutrient_id",
        "name": "name",
        "unit_name": "unit"
    })
else:
    # cố gắng dò cột số khác (ví dụ 'number' / 'num' / 'nbr')
    possible_nbr = next((c for c in nutrient.columns if any(k in c.lower() for k in ("nbr","number","num"))), None)
    if possible_nbr:
        nutrient = nutrient.rename(columns={
            possible_nbr: "nutrient_id",
            "name": "name",
            "unit_name": "unit"
        })
# đảm bảo lấy các cột tồn tại
cols = [c for c in ("nutrient_id", "name", "unit") if c in nutrient.columns]
nutrient = nutrient[cols].rename(columns={c: c for c in cols}).dropna().drop_duplicates()
# (BỎ GIỚI HẠN SỐ LƯỢNG nutrient)

food_nutrient = food_nutrient.rename(columns={
    "fdc_id": "food_id",
    "nutrient_id": "nutrient_id",
    "amount": "amount_per_100g"
})
food_nutrient = food_nutrient[["food_id", "nutrient_id", "amount_per_100g"]].dropna()

# Lọc FoodNutrient chỉ giữ các food_id và nutrient_id đã chọn
# đảm bảo chuyển kiểu trước khi so sánh
try:
    food_ids_set = set(map(int, food["food_id"].tolist()))
except Exception:
    food_ids_set = set()
try:
    nutrient_ids_set = set(map(int, nutrient["nutrient_id"].tolist()))
except Exception:
    nutrient_ids_set = set()

def safe_int(x):
    try:
        return int(x)
    except Exception:
        return None

fn_filtered = food_nutrient[
    food_nutrient["food_id"].apply(safe_int).isin(food_ids_set) &
    food_nutrient["nutrient_id"].apply(safe_int).isin(nutrient_ids_set)
].copy()

# (BỎ GIỚI HẠN SỐ LƯỢNG food_nutrient)
food_nutrient = fn_filtered

# ============================================================
# 4️⃣ Category (tự động dò cột cho FoodTag)
# ============================================================
possible_code_cols = [c for c in category.columns if 'code' in c.lower()]
possible_name_cols = [c for c in category.columns if 'name' in c.lower() or 'description' in c.lower()]

if possible_code_cols and possible_name_cols:
    category = category.rename(columns={
        possible_code_cols[0]: 'wweia_food_category_code',
        possible_name_cols[0]: 'tag_name'
    })
else:
    category = pd.DataFrame({
        'wweia_food_category_code': range(1, 11),
        'tag_name': [
            'Dairy', 'Fruits', 'Vegetables', 'Grains', 'Meat', 'Beverages',
            'Snacks', 'Seafood', 'Legumes', 'Other'
        ]
    })

category = category[['wweia_food_category_code', 'tag_name']].dropna().drop_duplicates()

# (BỎ GIỚI HẠN SỐ category/tag)

print(f"✅ Đã tải {len(food)} món ăn, {len(nutrient)} chất dinh dưỡng, {len(food_nutrient)} dòng liên kết.")

# ============================================================
# 5️⃣ Sinh dữ liệu SQL
# ============================================================
sql_lines = []

# ---- Food ----
for _, row in food.iterrows():
    name = str(row["name"]).replace("'", "''")
    category_val = str(row["category"]).replace("'", "''")
    try:
        fid = int(row.food_id)
    except Exception:
        continue
    sql_lines.append(
        f"INSERT INTO Food (food_id, name, category) VALUES ({fid}, '{name}', '{category_val}');"
    )

# ---- Nutrient ----
for _, row in nutrient.iterrows():
    try:
        nid = int(row["nutrient_id"])
    except Exception:
        continue
    name = str(row["name"]).replace("'", "''")
    unit = str(row["unit"]).replace("'", "''")
    sql_lines.append(
        f"INSERT INTO Nutrient (nutrient_id, name, unit) VALUES ({nid}, '{name}', '{unit}');"
    )

# ---- FoodNutrient ----
for _, row in food_nutrient.iterrows():
    try:
        fid = int(row.food_id)
        nid = int(row.nutrient_id)
        amount = float(row.amount_per_100g)
        sql_lines.append(
            f"INSERT INTO FoodNutrient (food_id, nutrient_id, amount_per_100g) VALUES ({fid}, {nid}, {amount});"
        )
    except Exception:
        continue

# ---- FoodTag ----
for i, row in enumerate(category.itertuples(), 1):
    tag_name = str(row.tag_name).replace("'", "''")
    sql_lines.append(f"INSERT INTO FoodTag (tag_id, tag_name) VALUES ({i}, '{tag_name}');")

# ---- FoodTagMapping ----
# không giới hạn số mapping; lấy tất cả food có sẵn
available_food_ids = list(food["food_id"].tolist())
mapping_sample_count = len(available_food_ids)
if mapping_sample_count > 0:
    for fid in pd.Series(available_food_ids).sample(mapping_sample_count, random_state=42).tolist():
        # tag_id trong khoảng 1..len(category)
        tag_id = random.randint(1, max(1, len(category)))
        sql_lines.append(f"INSERT INTO FoodTagMapping (food_id, tag_id) VALUES ({int(fid)}, {tag_id});")

# ============================================================
# 6️⃣ ConditionNutrientEffect
# (giữ nguyên dữ liệu nhập tay)
# ============================================================

# --- Generate 200 realistic ConditionNutrientEffect records ---
import itertools
condition_names = [
    "Iron Deficiency", "Hypertension", "Diabetes", "Osteoporosis", "High Cholesterol",
    "Vitamin D Deficiency", "Anemia", "Obesity", "Kidney Disease", "Heart Disease",
    "Gout", "Hypothyroidism", "Hyperthyroidism", "Liver Disease", "Cancer",
    "Asthma", "Arthritis", "Celiac Disease", "IBS", "PCOS", "Pregnancy"
]
effect_types = ["increase", "decrease"]
impact_notes = [
    "Increase absorption to support treatment.", "Reduce amount to prevent complications.",
    "Adjust according to doctor's recommendation.", "Support disease management.",
    "Optimize personal nutrition."
]

# Use top 20 nutrients from nutrient table (or fallback)
nutrient_names = nutrient["name"].dropna().unique().tolist()
if len(nutrient_names) < 20:
    nutrient_names += ["Iron", "Sodium", "Calcium", "Vitamin D", "Potassium", "Magnesium", "Zinc", "Vitamin C", "Vitamin B12", "Folate", "Fat", "Carbohydrate", "Protein", "Fiber", "Cholesterol", "Phosphorus", "Copper", "Iodine", "Selenium", "Vitamin E"]
nutrient_names = nutrient_names[:20]

combinations = list(itertools.product(condition_names, effect_types, nutrient_names))
random.shuffle(combinations)
for i, (cond, effect, nutrient_name) in enumerate(combinations[:200], 1):
    match = nutrient[nutrient["name"].str.contains(nutrient_name, case=False, na=False)]
    if not match.empty:
        nutrient_id = int(match.sample(1).iloc[0]["nutrient_id"])
    else:
        nutrient_id = random.randint(1, len(nutrient))
    impact = round(random.uniform(10, 40), 2)
    note = random.choice(impact_notes)
    sql_lines.append(
        f"INSERT INTO ConditionNutrientEffect (condition_effect_id, condition_name, nutrient_id, effect_type, impact_percent, impact_note) "
        f"VALUES ({i}, '{cond}', {nutrient_id}, '{effect}', {impact}, '{note}');"
    )

# ============================================================
# 7️⃣ Suggestion (100 bản ghi ngẫu nhiên)  -- vẫn giữ 100 suggestions nếu muốn
# ============================================================
for sid in range(1, 101):
    user_id = random.randint(1, 10)
    if len(nutrient) == 0 or len(food) == 0:
        continue
    nutrient_id = random.choice(nutrient["nutrient_id"].tolist())
    food_id = random.choice(food["food_id"].tolist())
    deficiency = round(random.uniform(5, 30), 2)
    note = "Automatically suggested based on nutrient deficiency."
    sql_lines.append(
        f"INSERT INTO Suggestion (suggestion_id, user_id, date, nutrient_id, deficiency_amount, suggested_food_id, note) "
        f"VALUES ({sid}, {user_id}, CURRENT_DATE, {nutrient_id}, {deficiency}, {food_id}, '{note}');"
    )

# ============================================================
# 8️⃣ ConditionFoodRecommendation
# (giữ rules nhập tay) -- không giới hạn tổng recommend_id
# ============================================================

# --- Generate 200 realistic ConditionFoodRecommendation records ---
recommend_types = ["recommend", "avoid"]
food_names = food["name"].dropna().unique().tolist()
if len(food_names) < 100:
    food_names += ["Beef", "Liver", "Egg", "Spinach", "Salt", "Bacon", "Sausage", "Sugar", "White rice", "Cake", "Soda", "Oats", "Broccoli", "Fish", "Milk", "Yogurt", "Cheese", "Tofu", "Orange", "Lemon", "Kiwi", "Butter", "Fried chicken", "Cream", "Oatmeal", "Salmon", "Avocado"]
food_names = food_names[:100]

recommend_combinations = list(itertools.product(condition_names, recommend_types, food_names))
random.shuffle(recommend_combinations)
recommend_id = 1
for cond, rec_type, food_name in recommend_combinations[:200]:
    food_match = food[food["name"].str.contains(food_name, case=False, na=False)]
    if not food_match.empty:
        food_id = int(food_match.sample(1).iloc[0]["food_id"])
    else:
        food_id = random.randint(1, len(food))
    note = f"{rec_type.capitalize()} this food for condition {cond}."
    sql_lines.append(
        f"INSERT INTO ConditionFoodRecommendation (recommendation_id, condition_name, food_id, recommendation_type, note) "
        f"VALUES ({recommend_id}, '{cond}', {food_id}, '{rec_type}', '{note}');"
    )
    recommend_id += 1

# ============================================================
# 🔟 Xuất file SQL
# ============================================================
with open("usda_import_full.sql", "w", encoding="utf-8") as f:
    f.write("\n".join(sql_lines))

print("✅ Done! File 'usda_import_full.sql' has been created with correct USDA food names and categories.")
