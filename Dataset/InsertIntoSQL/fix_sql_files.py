# -*- coding: utf-8 -*-
import re

# Đọc và sửa extended_tables_vietnam.sql
with open('extended_tables_vietnam.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# Thêm ON CONFLICT cho dishingredient
content = re.sub(
    r"(\(30, 3017, 80, 'Rau củ khác', 2\);)",
    r"\1\nON CONFLICT (dish_id, food_id) DO UPDATE SET weight_g = EXCLUDED.weight_g, notes = EXCLUDED.notes;",
    content
)

# Thêm ON CONFLICT cho dishnutrient (đã có trong file chính)
content = re.sub(
    r"(\(30, 1, 55\.0\), \(30, 2, 3\.5\)[^\n]+\(30, 24, 60\.0\);)",
    r"\1\nON CONFLICT (dish_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;",
    content
)

# Thêm ON CONFLICT cho drink
content = re.sub(
    r"(\(40, 'Grass Jelly Drink'[^\n]+1\);)",
    r"\1\nON CONFLICT (drink_id) DO UPDATE SET name_vi = EXCLUDED.name_vi, description = EXCLUDED.description;",
    content
)

# Thêm ON CONFLICT cho drinkingredient
content = re.sub(
    r"(\(19, 3017, 80, 'g', 1, 'Rau má tươi'\);)",
    r"\1\nON CONFLICT (drink_id, food_id) DO UPDATE SET weight_g = EXCLUDED.weight_g, notes = EXCLUDED.notes;",
    content
)

# Thêm ON CONFLICT cho drinknutrient
content = re.sub(
    r"(\(20, 1, 0\.0\), \(20, 4, 0\.0\);)",
    r"\1\nON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;",
    content
)

# Thêm ON CONFLICT cho portionsize
content = re.sub(
    r"(\(3013, '1 plate', '1 dĩa', 400, TRUE\);)",
    r"\1\nON CONFLICT (food_id, portion_name) DO UPDATE SET vietnamese_name = EXCLUDED.vietnamese_name, grams = EXCLUDED.grams;",
    content
)

# Thêm ON CONFLICT cho conditionfoodrecommendation
content = re.sub(
    r"(\(1008, 18, 'Recommended', 'Rau củ luộc nhẹ bụng'\);)",
    r"\1\nON CONFLICT (condition_id, food_id) DO UPDATE SET recommendation_vi = EXCLUDED.recommendation_vi;",
    content
)

# Thêm ON CONFLICT cho conditionnutrienteffect
content = re.sub(
    r"(\(1008, 5, 'Increase', 10\.0, 'Tăng chất xơ nhưng không quá nhiều'\);)",
    r"\1\nON CONFLICT (condition_id, nutrient_id) DO UPDATE SET recommendation_vi = EXCLUDED.recommendation_vi;",
    content
)

# Thêm ON CONFLICT cho recipe
content = re.sub(
    r"(Bước 6: Cho gà xé vào, rắc hành, gừng', TRUE\);)",
    r"\1\nON CONFLICT (dish_id) DO UPDATE SET instructions = EXCLUDED.instructions;",
    content
)

with open('extended_tables_vietnam.sql', 'w', encoding='utf-8') as f:
    f.write(content)

# Đọc và sửa additional_data_extended.sql
with open('additional_data_extended.sql', 'r', encoding='utf-8') as f:
    content2 = f.read()

# Xóa DELETE
content2 = re.sub(r'DELETE FROM \w+ WHERE [^\n]+\n', '', content2)

# Thêm ON CONFLICT cho các bảng trong additional_data_extended.sql
content2 = re.sub(
    r"(\([0-9]+, [0-9]+, [0-9.]+\);)\n(-- =|$)",
    r"\1\nON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;\n\2",
    content2, count=1
)

with open('additional_data_extended.sql', 'w', encoding='utf-8') as f:
    f.write(content2)

# Đọc và sửa dishnutrient_data.sql
with open('dishnutrient_data.sql', 'r', encoding='utf-8') as f:
    content3 = f.read()

# Xóa DELETE
content3 = re.sub(r'DELETE FROM \w+ WHERE [^\n]+\n', '', content3)

# Thêm ON CONFLICT cuối file
content3 = re.sub(
    r"(\([0-9]+, [0-9]+, [0-9.]+\);)(\s*)$",
    r"\1\nON CONFLICT (dish_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;\2",
    content3
)

with open('dishnutrient_data.sql', 'w', encoding='utf-8') as f:
    f.write(content3)

# Đọc và sửa drinknutrient_data.sql
with open('drinknutrient_data.sql', 'r', encoding='utf-8') as f:
    content4 = f.read()

# Xóa DELETE
content4 = re.sub(r'DELETE FROM \w+ WHERE [^\n]+\n', '', content4)

# Thêm ON CONFLICT cuối file
content4 = re.sub(
    r"(\([0-9]+, [0-9]+, [0-9.]+\);)(\s*)$",
    r"\1\nON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;\2",
    content4
)

with open('drinknutrient_data.sql', 'w', encoding='utf-8') as f:
    f.write(content4)

print("✅ Đã sửa tất cả file SQL thành công!")
print("- extended_tables_vietnam.sql: Đã thêm ON CONFLICT cho tất cả INSERT")
print("- additional_data_extended.sql: Đã xóa DELETE và thêm ON CONFLICT")
print("- dishnutrient_data.sql: Đã xóa DELETE và thêm ON CONFLICT")
print("- drinknutrient_data.sql: Đã xóa DELETE và thêm ON CONFLICT")
