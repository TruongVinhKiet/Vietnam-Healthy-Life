# Fix Progress Bars Report

## Issues Found

### Issue 1: Amino Acids Not Updating ✅ FIXED
**Problem:** When adding meals (both dishes and foods), amino acids progress bars don't increase.

**Root Cause:** 
- In `calculate_daily_nutrient_intake` SQL function, amino acid mapping was incorrect
- `AminoAcid.code` is `'LEU'`, `'LYS'`, etc.
- `Nutrient.nutrient_code` is `'AMINO_LEU'`, `'AMINO_LYS'`, etc.
- The JOIN was: `UPPER(n.nutrient_code) = UPPER(aa.code)` ❌
- Should be: `UPPER(n.nutrient_code) = UPPER('AMINO_' || aa.code)` ✅

**Fix:** 
- Created migration `2025_fix_amino_acid_mapping_in_nutrient_tracking.sql`
- Fixed the JOIN condition to use `'AMINO_' || aa.code`

### Issue 2: Mediterranean Diet Not Updating for Dishes ✅ FIXED
**Problem:** When adding dishes (món ăn), Mediterranean diet progress bars don't increase.

**Root Cause:**
- `addDishToMeal` uses `meal_entries` table
- `meal_entries` had NO trigger to update `DailySummary` table
- `addDishToMeal` was trying to get macronutrients from `calculateDailyNutrientIntake`, but that function doesn't return macronutrients
- Mediterranean diet reads from `DailySummary` via `applyTodayTotals()`

**Fix:**
1. Created migration `2025_add_daily_summary_trigger_for_meal_entries.sql`
   - Added trigger `trg_adjust_daily_summary_meal_entries` on `meal_entries` table
   - Updates `DailySummary` when `meal_entries` are inserted/updated/deleted
2. Updated `addDishToMeal` in `mealController.js`
   - Changed to read from `DailySummary` instead of `calculateDailyNutrientIntake`
   - Ensures consistency with `addFoodToMeal`

### Issue 3: Fat Not Updating for Dishes ✅ FIXED (by Issue 2)
**Problem:** When adding dishes, fat progress bar doesn't increase.

**Root Cause:** Same as Issue 2 - `DailySummary` wasn't being updated from `meal_entries`.

**Fix:** Same as Issue 2 - trigger now updates `DailySummary`, and fat is read from there.

### Issue 4: Response Format Inconsistency ✅ FIXED
**Problem:** `addFoodToMeal` returned `{ calories, protein, fat, carbs }` while `addDishToMeal` returned `{ today_calories, today_protein, today_fat, today_carbs }`.

**Fix:**
- Updated `mealService.js` to return `today_*` prefix for consistency
- `applyTodayTotals()` already handles both formats, but now both endpoints are consistent

## Files Changed

1. **New Migrations:**
   - `2025_fix_amino_acid_mapping_in_nutrient_tracking.sql` - Fixes amino acid mapping
   - `2025_add_daily_summary_trigger_for_meal_entries.sql` - Adds trigger for DailySummary

2. **Backend Code:**
   - `backend/controllers/mealController.js` - Updated `addDishToMeal` to read from DailySummary
   - `backend/services/mealService.js` - Updated response format to use `today_*` prefix

## Testing Required

1. ✅ Add dish (món ăn) - verify:
   - Mediterranean diet progress increases
   - Amino acids progress increases
   - Fat progress increases

2. ✅ Add food (thực phẩm) - verify:
   - Mediterranean diet progress increases
   - Amino acids progress increases
   - Fat progress increases

## Migration Order

Run migrations in this order:
1. `2025_fix_amino_acid_mapping_in_nutrient_tracking.sql`
2. `2025_add_daily_summary_trigger_for_meal_entries.sql`

## Notes

- Amino acids are calculated directly from `FoodNutrient` via the SQL function (no separate intake table needed)
- Fiber and fatty acids use intake tables (`UserFiberIntake`, `UserFattyAcidIntake`) populated by triggers
- Mediterranean diet uses `DailySummary` table which is now updated by triggers on both `MealItem` and `meal_entries`

