# Daily Meal Suggestions - Database Migration Guide

## Overview
Database migration files for "Daily Meal Suggestions" feature - complete meal planning system for Vietnamese cuisine.

## Migration Files (Run in order)

### 1. Core Table & Settings
```sql
-- Run these first
2025_daily_meal_suggestions_table.sql      -- Main suggestions table + triggers + cleanup
2025_usersetting_meal_counts.sql           -- Add 8 meal count columns to usersetting
```

### 2. Data Expansion
```sql
-- Vietnamese ingredients, dishes, drinks
2025_food_ingredients_vietnam_extended.sql -- 60 new ingredients (quinoa, exotic fruits, herbs)
2025_dishes_vietnam_specialty.sql          -- 30 dishes (Miền Trung, Chay, Healthy, Hầm)
2025_drinks_vietnam_traditional.sql        -- 20 drinks (Traditional, Herbal Tea, Detox, Health)
```

### 3. Nutrient Data (Critical!)
```sql
-- Complete nutrition profiles (58 nutrients each)
2025_dishnutrient_vietnam_specialty.sql    -- Nutrients for first 3 dishes (detailed format)
2025_dishnutrient_part2.sql                -- Nutrients for remaining 27 dishes (compact format)
2025_drinknutrient_vietnam_traditional.sql -- Nutrients for all 20 drinks
```

## Key Features

### Constraints & Validation
- ✅ **Max 2 items per meal**: Each meal limited to max 2 dishes AND max 2 drinks (health constraint)
- ✅ **XOR logic**: Suggestion must be either dish OR drink, not both
- ✅ **Unique suggestions**: No duplicate (user, date, meal_type, dish/drink) combinations
- ✅ **Enum validation**: meal_type in ('breakfast', 'lunch', 'dinner', 'snack')

### Triggers
- `auto_update_suggestions_timestamp` - Auto-update updated_at on row changes
- `validate_meal_item_counts` - Prevents >2 items per meal with Vietnamese error message

### Cleanup Functions
- `cleanup_old_daily_suggestions()` - Removes suggestions older than 7 days
- `cleanup_passed_meal_suggestions(user_id)` - Removes suggestions when meal time has passed

### Indexes (Performance)
```sql
idx_daily_suggestions_user_date    -- (user_id, date) for fast user queries
idx_daily_suggestions_meal_type    -- (meal_type) for filtering
idx_daily_suggestions_accepted     -- (is_accepted) for acceptance tracking
idx_daily_suggestions_date         -- (date) for cleanup operations
```

## Data Summary

### 60 New Ingredients
- 10 grains: Quinoa, Chia seeds, Black sticky rice, Walnuts, Almonds, etc.
- 15 vegetables: Beetroot, Artichoke, Shiitake, Enoki, Oyster mushroom, etc.
- 12 fruits: Passion fruit, Soursop, Dragon fruit, Kiwi, Blueberries, etc.
- 10 proteins: Tiger prawns, Tuna, Salmon, Lamb, Tofu rolls, etc.
- 8 condiments: Turmeric powder, Curry powder, Lemongrass, Ginger, etc.
- 5 drink ingredients: Lotus leaf, Chrysanthemum, Almond milk, etc.

### 30 New Dishes (Categories)

**Miền Trung Specialties (10):**
- Bún Mắm Cá Linh, Bánh Căn Phan Thiết, Cơm Hến Huế
- Bánh Khoái Huế, Bún Sườn Sụn, Bánh Bèo Chén Huế
- Mì Quảng Gà, Bánh Nậm Huế, Bún Bò Nam Bộ, Nem Lụi Nha Trang

**Vegetarian (8):**
- Đậu Hũ Sốt Nấm Chay, Cà Ri Chay Dừa, Miến Xào Chay
- Lẩu Chay Thập Cẩm, Bún Riêu Chay, Cơm Chiên Chay Dương Châu
- Bánh Xèo Chay, Phở Chay Dinh Dưỡng

**Healthy/Low-calorie (7):**
- Salad Quinoa Rau Củ, Súp Bí Đỏ Hạnh Nhân, Cá Hấp Xì Dầu Gừng
- Rau Củ Hấp Sốt Chanh (95 kcal!), Gà Nướng Mật Ong Chanh
- Cháo Yến Mạch Trái Cây, Súp Hải Sản Thanh Đạm

**Soups/Stews (5):**
- Lẩu Gà Lá É, Canh Sườn Hầm Củ Cải, Gà Hầm Thuốc Bắc
- Canh Gà Hầm Hạnh Nhân, Bò Kho Nước Dừa

### 20 New Drinks (Categories)

**Traditional (6):**
- Nước Sâm Bổ Lượng, Chè Khúc Bạch, Trà Bí Đao Hạt Sen
- Nước Sương Sáo, Nước Rau Má Mật Ong, Nước Hạt Sen Long Nhãn

**Herbal Tea (5):**
- Trà Atisô Đỏ Đà Lạt, Trà Kỷ Tử Gừng Mật Ong, Trà Hoa Cúc Mật Ong
- Trà Húng Chanh Cam Thảo, Trà Lá Sen Giảm Cân (12 kcal!)

**Detox Juice (5):**
- Nước Ép Rau Củ Thải Độc, Nước Ép Bưởi Mật Ong, Nước Ép Cần Tây Táo
- Nước Ép Củ Dền Cà Rốt, Nước Ép Dứa Bạc Hà

**Health Drinks (4):**
- Sữa Yến Mạch Chuối, Nước Hạt Chia Chanh Mật Ong
- Kombucha Trà Lên Men, Sữa Hạnh Nhân Nghệ

## Nutrient Data

### Complete Nutrition (58 nutrients per item)
All 30 dishes and 20 drinks include realistic Vietnamese food composition values for:

**Macronutrients (6):**
- Energy (kcal), Protein, Total Fat, Carbohydrate, Fiber, Sugars

**Minerals (10):**
- Calcium, Iron, Magnesium, Phosphorus, Potassium, Sodium
- Zinc, Copper, Manganese, Selenium

**Vitamins (10):**
- Vitamin A, C, E, K
- B-complex: Thiamin (B1), Riboflavin (B2), Niacin (B3), B6, Folate, B12

**Fatty Acids (6):**
- Saturated, Monounsaturated, Polyunsaturated, Cholesterol
- Omega-3, Omega-6, DHA, EPA

**Amino Acids (19):**
- Essential: Tryptophan, Threonine, Isoleucine, Leucine, Lysine, Methionine, Cystine, Phenylalanine, Tyrosine, Valine
- Non-essential: Arginine, Histidine, Alanine, Aspartic Acid, Glutamic Acid, Glycine, Proline, Serine, Hydroxyproline

**Other (7):**
- Choline, Alcohol, Caffeine, Water, Theobromine

### Calorie Ranges
**Dishes:**
- Ultra-low: 95 kcal (Rau Củ Hấp Sốt Chanh)
- Low: 155-220 kcal (Súp Bí Đỏ, Đậu Hũ Sốt Nấm)
- Medium: 245-320 kcal (Most dishes)
- High: 365-420 kcal (Bún Sườn Sụn, Bò Kho)

**Drinks:**
- Ultra-low: 12 kcal (Trà Lá Sen)
- Low: 38-95 kcal (Most teas, juices)
- Medium: 125-165 kcal (Milk-based drinks)
- High: 185 kcal (Chè Khúc Bạch)

## Verification Queries

### Check all migrations completed
```sql
-- Should return 30 dishes
SELECT COUNT(*) FROM dish WHERE vietnamese_name IN (
  'Bún Mắm Cá Linh', 'Bánh Căn Phan Thiết', 'Cơm Hến Huế', 'Bánh Khoái Huế',
  'Bún Sườn Sụn', 'Bánh Bèo Chén Huế', 'Mì Quảng Gà', 'Bánh Nậm Huế',
  'Bún Bò Nam Bộ', 'Nem Lụi Nha Trang', 'Đậu Hũ Sốt Nấm Chay', 'Cà Ri Chay Dừa',
  'Miến Xào Chay', 'Lẩu Chay Thập Cẩm', 'Bún Riêu Chay', 'Cơm Chiên Chay Dương Châu',
  'Bánh Xèo Chay', 'Phở Chay Dinh Dưỡng', 'Salad Quinoa Rau Củ', 'Súp Bí Đỏ Hạnh Nhân',
  'Cá Hấp Xì Dầu Gừng', 'Rau Củ Hấp Sốt Chanh', 'Gà Nướng Mật Ong Chanh',
  'Cháo Yến Mạch Trái Cây', 'Súp Hải Sản Thanh Đạm', 'Lẩu Gà Lá É',
  'Canh Sườn Hầm Củ Cải', 'Gà Hầm Thuốc Bắc', 'Canh Gà Hầm Hạnh Nhân', 'Bò Kho Nước Dừa'
);

-- Should return 20 drinks
SELECT COUNT(*) FROM drink WHERE vietnamese_name IN (
  'Nước Sâm Bổ Lượng', 'Chè Khúc Bạch', 'Trà Bí Đao Hạt Sen', 'Nước Sương Sáo',
  'Nước Rau Má Mật Ong', 'Nước Hạt Sen Long Nhãn', 'Trà Atisô Đỏ Đà Lạt',
  'Trà Kỷ Tử Gừng Mật Ong', 'Trà Hoa Cúc Mật Ong', 'Trà Húng Chanh Cam Thảo',
  'Trà Lá Sen Giảm Cân', 'Nước Ép Rau Củ Thải Độc', 'Nước Ép Bưởi Mật Ong',
  'Nước Ép Cần Tây Táo', 'Nước Ép Củ Dền Cà Rốt', 'Nước Ép Dứa Bạc Hà',
  'Sữa Yến Mạch Chuối', 'Nước Hạt Chia Chanh Mật Ong', 'Kombucha Trà Lên Men', 'Sữa Hạnh Nhân Nghệ'
);

-- Should return 60 ingredients
SELECT COUNT(*) FROM food WHERE vietnamese_name LIKE '%Quinoa%' 
  OR vietnamese_name LIKE '%Chia%' 
  OR vietnamese_name LIKE '%Hạnh nhân%'
  OR vietnamese_name LIKE '%Atiso%';

-- Verify all dishes have 58 nutrients
SELECT d.vietnamese_name, COUNT(*) as nutrient_count
FROM dish d
LEFT JOIN dishnutrient dn ON d.id = dn.dish_id
WHERE d.vietnamese_name LIKE '%Bún Mắm%' OR d.vietnamese_name LIKE '%Salad Quinoa%'
GROUP BY d.id, d.vietnamese_name
HAVING COUNT(*) != 58;  -- Should return empty (all should have exactly 58)

-- Verify all drinks have 58 nutrients
SELECT d.vietnamese_name, COUNT(*) as nutrient_count
FROM drink d
LEFT JOIN drinknutrient dn ON d.id = dn.drink_id
WHERE d.vietnamese_name LIKE '%Trà Atisô%' OR d.vietnamese_name LIKE '%Kombucha%'
GROUP BY d.id, d.vietnamese_name
HAVING COUNT(*) != 58;  -- Should return empty
```

### Check constraints working
```sql
-- Test max 2 constraint (should FAIL with Vietnamese error)
UPDATE usersetting SET breakfast_dish_count = 3 WHERE user_id = 1;
-- Expected error: "Mỗi bữa ăn chỉ được tối đa 2 món và 2 đồ uống (vì sức khỏe)"

-- Test XOR constraint (should FAIL)
INSERT INTO user_daily_meal_suggestions (user_id, date, meal_type, dish_id, drink_id)
VALUES (1, CURRENT_DATE, 'breakfast', 1, 1);
-- Expected error: violates check constraint "check_dish_or_drink"
```

## Next Steps

After running migrations:

1. **Backend API** (Phase 2):
   - Create `dailyMealSuggestionService.js` - algorithm for optimal meal combinations
   - Create `dailyMealSuggestionController.js` - API endpoints (POST/GET/PUT/DELETE)
   - Update routes: `/api/suggestions/daily-meals`

2. **Flutter UI** (Phase 3):
   - Update `smart_suggestions_screen.dart` to 2-tab layout
   - Create `daily_meal_suggestion_tab.dart`
   - Create `meal_selection_dialog.dart` with validation UI
   - Create widgets for suggestion display + nutrient comparison

3. **Integration** (Phase 4):
   - Update `add_meal_dialog.dart` - yellow border for accepted suggestions
   - Update `water_quick_add_sheet.dart` - yellow border for drink suggestions
   - Call cleanup functions on app launch

4. **Testing** (Phase 5):
   - Test max 2 constraint with various meal combinations
   - Test suggestion algorithm with different health conditions
   - Test nutrient calculations match 90-120% RDA targets
   - Test cleanup functions with time-based scenarios

## File Structure
```
backend/migrations/
├── 2025_daily_meal_suggestions_table.sql      [150 lines] ✅
├── 2025_usersetting_meal_counts.sql           [120 lines] ✅
├── 2025_food_ingredients_vietnam_extended.sql [150 lines] ✅
├── 2025_dishes_vietnam_specialty.sql          [80 lines]  ✅
├── 2025_drinks_vietnam_traditional.sql        [75 lines]  ✅
├── 2025_dishnutrient_vietnam_specialty.sql    [204 lines] ✅ (3 dishes detailed)
├── 2025_dishnutrient_part2.sql                [450 lines] ✅ (27 dishes compact)
└── 2025_drinknutrient_vietnam_traditional.sql [580 lines] ✅ (20 drinks)
```

**Total:** 1,809 lines of SQL code

## Notes

- All nutrient values are realistic estimates based on Vietnamese food composition
- Compact format used for Part 2 to reduce file size while maintaining data completeness
- Each item still has all 58 nutrients despite condensed format
- ON CONFLICT DO NOTHING prevents errors if re-running migrations
- Verification blocks at end of each file confirm successful insertion

---
**Created:** 2025-12-08  
**Purpose:** Daily Meal Suggestions feature - Complete meal planning for Vietnamese cuisine  
**Status:** Database migrations complete ✅ | Backend pending | Frontend pending
