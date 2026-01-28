# -*- coding: utf-8 -*-
import re

# Sửa extended_tables_vietnam.sql với tên cột đúng
with open('extended_tables_vietnam.sql', 'r', encoding='utf-8') as f:
    content = f.read()

# Sửa drink: name_vi -> vietnamese_name
content = content.replace(
    "ON CONFLICT (drink_id) DO UPDATE SET name_vi = EXCLUDED.name_vi, description = EXCLUDED.description;",
    "ON CONFLICT (drink_id) DO UPDATE SET vietnamese_name = EXCLUDED.vietnamese_name, description = EXCLUDED.description;"
)

# Sửa drinkingredient: weight_g -> amount_g
content = content.replace(
    "ON CONFLICT (drink_id, food_id) DO UPDATE SET weight_g = EXCLUDED.weight_g, notes = EXCLUDED.notes;",
    "ON CONFLICT (drink_id, food_id) DO UPDATE SET amount_g = EXCLUDED.amount_g, notes = EXCLUDED.notes;"
)

# Sửa drinknutrient: amount_per_100g -> amount_per_100ml
content = content.replace(
    "ON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100g = EXCLUDED.amount_per_100g;",
    "ON CONFLICT (drink_id, nutrient_id) DO UPDATE SET amount_per_100ml = EXCLUDED.amount_per_100ml;"
)

# Sửa portionsize: vietnamese_name -> name_vi
content = content.replace(
    "ON CONFLICT (food_id, portion_name) DO UPDATE SET vietnamese_name = EXCLUDED.vietnamese_name, grams = EXCLUDED.grams;",
    "ON CONFLICT (food_id, portion_name) DO UPDATE SET name_vi = EXCLUDED.name_vi, grams = EXCLUDED.grams;"
)

# Sửa conditionfoodrecommendation: recommendation_vi -> notes_vi
content = content.replace(
    "ON CONFLICT (condition_id, food_id) DO UPDATE SET recommendation_vi = EXCLUDED.recommendation_vi;",
    "ON CONFLICT (condition_id, food_id) DO UPDATE SET notes_vi = EXCLUDED.notes_vi;"
)

# Sửa conditionnutrienteffect: recommendation_vi -> notes_vi  
content = content.replace(
    "ON CONFLICT (condition_id, nutrient_id) DO UPDATE SET recommendation_vi = EXCLUDED.recommendation_vi;",
    "ON CONFLICT (condition_id, nutrient_id) DO UPDATE SET notes_vi = EXCLUDED.notes_vi;"
)

# Sửa recipe: dish_id không phải primary key, dùng recipe_id
content = content.replace(
    "ON CONFLICT (dish_id) DO UPDATE SET instructions = EXCLUDED.instructions;",
    "ON CONFLICT (recipe_id) DO UPDATE SET instructions = EXCLUDED.instructions;"
)

with open('extended_tables_vietnam.sql', 'w', encoding='utf-8') as f:
    f.write(content)

print("✅ Đã sửa extended_tables_vietnam.sql với tên cột đúng!")
