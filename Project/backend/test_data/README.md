# SuperFood Complete™ Test Data

## Overview
SuperFood Complete™ is a comprehensive test food designed to validate the nutrient tracking system across all categories:
- **13 Vitamins** (VITA, VITB1-B12, VITC, VITD, VITE, VITK)
- **14 Minerals** (MIN_CA, MIN_P, MIN_MG, MIN_K, MIN_NA, MIN_FE, MIN_ZN, MIN_CU, MIN_MN, MIN_I, MIN_SE, MIN_CR, MIN_MO, MIN_F)
- **9 Essential Amino Acids** (HIS, ILE, LEU, LYS, MET, PHE, THR, TRP, VAL)
- **2 Fiber Types** (SOLUBLE, INSOLUBLE)
- **4 Fatty Acid Types** (OMEGA3, OMEGA6, SATURATED, UNSATURATED)

## Installation

### Option 1: Using psql
```powershell
# Navigate to backend directory
cd D:\new\my_diary\backend

# Connect to PostgreSQL
psql -U postgres -d Health

# Run the SQL script
\i test_data/create_superfood_complete.sql
```

### Option 2: Using pgAdmin
1. Open pgAdmin and connect to the "Health" database
2. Click Tools → Query Tool
3. Open `backend/test_data/create_superfood_complete.sql`
4. Execute the script (F5)

### Option 3: Using PowerShell
```powershell
cd D:\new\my_diary\backend
psql -U postgres -d Health -f test_data/create_superfood_complete.sql
```

## Nutrient Values

### Vitamins (600-700% RDA)
- **Vitamin A**: 5400 mcg (600% of 900 mcg RDA)
- **Vitamin B1**: 7.2 mg (600% of 1.2 mg RDA)
- **Vitamin B2**: 9.1 mg (700% of 1.3 mg RDA)
- **Vitamin B3**: 112 mg (700% of 16 mg RDA)
- **Vitamin B5**: 35 mg (700% of 5 mg RDA)
- **Vitamin B6**: 10.2 mg (600% of 1.7 mg RDA)
- **Vitamin B7**: 210 mcg (700% of 30 mcg RDA)
- **Vitamin B9**: 2400 mcg (600% of 400 mcg RDA)
- **Vitamin B12**: 16.8 mcg (700% of 2.4 mcg RDA)
- **Vitamin C**: 630 mg (700% of 90 mg RDA)
- **Vitamin D**: 120 mcg (600% of 20 mcg RDA)
- **Vitamin E**: 90 mg (600% of 15 mg RDA)
- **Vitamin K**: 840 mcg (700% of 120 mcg RDA)

### Minerals (600-700% RDA)
- **Calcium**: 6000 mg (600% of 1000 mg RDA)
- **Phosphorus**: 4900 mg (700% of 700 mg RDA)
- **Magnesium**: 2520 mg (600% of 420 mg RDA)
- **Potassium**: 20400 mg (600% of 3400 mg RDA)
- **Sodium**: 10500 mg (700% of 1500 mg RDA)
- **Iron**: 126 mg (700% of 18 mg RDA)
- **Zinc**: 66 mg (600% of 11 mg RDA)
- **Copper**: 6.3 mg (700% of 0.9 mg RDA)
- **Manganese**: 13.8 mg (600% of 2.3 mg RDA)
- **Iodine**: 1050 mcg (700% of 150 mcg RDA)
- **Selenium**: 330 mcg (600% of 55 mcg RDA)
- **Chromium**: 245 mcg (700% of 35 mcg RDA)
- **Molybdenum**: 270 mcg (600% of 45 mcg RDA)
- **Fluoride**: 28 mg (700% of 4 mg RDA)

### Essential Amino Acids (High Values)
- **Histidine**: 3000 mg
- **Isoleucine**: 4000 mg
- **Leucine**: 6000 mg
- **Lysine**: 5000 mg
- **Methionine**: 3000 mg
- **Phenylalanine**: 4500 mg
- **Threonine**: 3500 mg
- **Tryptophan**: 1500 mg
- **Valine**: 4500 mg

### Fiber (600% RDA)
- **Soluble Fiber**: 90 g (600% of ~15 g RDA)
- **Insoluble Fiber**: 120 g (600% of ~20 g RDA)

### Fatty Acids (High Values)
- **Omega-3**: 10 g (625% of 1.6 g RDA)
- **Omega-6**: 100 g (600% of ~17 g RDA)
- **Saturated**: 12 g
- **Unsaturated**: 50 g

## Usage in App

### Adding to a Meal
1. Login to the app as user 9 (hello@gmail.com / 123456)
2. Navigate to Add Food → Search
3. Search for "SuperFood Complete"
4. Add 100g to any meal (breakfast, lunch, dinner, or snack)
5. Save the meal

### Expected Results
After adding SuperFood Complete™ to a meal:
- **Vitamins**: All 13 vitamins should show **100%** (clamped from 600-700%)
- **Minerals**: All 14 minerals should show **100%** (clamped from 600-700%)
- **Amino Acids**: Will show 0% until tracking function is updated
- **Fiber**: Will show 0% until tracking function is updated
- **Fatty Acids**: Will show 0% until tracking function is updated

### UI Verification Points
1. **Home Screen Pills** (Vitamins & Minerals only):
   - All pills should fill completely with wave animation
   - Percentage text should show "100%" on right side
   - Vitamin/mineral names on left side
   - Wave should reach top of pill capsule

2. **List Screens**:
   - Vitamins list: All items show 100% in circular WaveView
   - Minerals list: All items show 100% in circular WaveView

3. **Detail Screens** (All Categories):
   - Large circular wave meter (140x140px) fully filled
   - Percentage display shows "100%"
   - Summary text: "Daily goal achieved!"
   - Gradient background using nutrient color

## Notes
- The clamping at 100% is intentional to prevent UI overflow
- Actual consumption percentages (600-700%) are stored but displayed as 100%
- SuperFood Complete™ uses ON CONFLICT clause, so running the script multiple times is safe
- The script automatically deletes and re-creates nutrient mappings
- Amino acids, fiber, and fatty acids are included for future backend updates

## Future Backend Updates
To enable tracking for amino acids, fiber, and fatty acids:
1. Update `calculate_daily_nutrient_intake()` function in:
   `backend/migrations/2025_add_nutrient_tracking_notifications.sql`
2. Add CTEs for:
   - `amino_acid_intake` (9 essential amino acids)
   - `fiber_intake` (SOLUBLE, INSOLUBLE)
   - `fatty_acid_intake` (OMEGA3, OMEGA6, SATURATED, UNSATURATED)
3. Add UNION ALL clauses to include these in the final result
4. Update nutrient_type filter in frontend where needed

## Troubleshooting
- **"Food not found"**: Ensure script ran successfully, check PostgreSQL logs
- **"Nutrient not showing"**: Verify nutrient_code exists in Nutrient table
- **"Percentage still 0%"**: Check that:
  - User 9 has the meal added for today
  - Backend server is running
  - API endpoint `/nutrients/tracking/daily` returns data
  - Nutrient type is 'vitamin' or 'mineral' (others not tracked yet)
