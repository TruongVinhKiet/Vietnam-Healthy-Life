# Copilot Instructions for USDA Data Import Project

## Project Overview
This project processes USDA food and nutrient data from CSV files and generates SQL scripts for database import. The main workflow is implemented in `usda_import_full_all.py`, which reads, cleans, merges, and transforms data from multiple sources, then outputs SQL insert statements to `usda_import_full.sql`.

## Key Files
- `usda_import_full_all.py`: Main ETL script. Reads all CSVs, processes data, and writes SQL.
- `food.csv`, `nutrient.csv`, `food_nutrient.csv`, `wweia_food_category.csv`: Source data files. Schema may vary; script auto-detects columns.
- `usda_import_full.sql`: Output SQL file for database import.
- Other `.sql` files: Partial import scripts for specific tables.

## Data Flow & Architecture
- All processing is done in-memory using pandas.
- Data normalization and merging are robust to missing columns and inconsistent schemas.
- Food categories are inferred using fuzzy matching if direct mapping fails.
- SQL output covers all major tables: Food, Nutrient, FoodNutrient, FoodTag, FoodTagMapping, ConditionNutrientEffect, Suggestion, ConditionFoodRecommendation.
- No hard record limits; all available data is processed.

## Developer Workflow
- **Run the ETL:**
  - Execute `usda_import_full_all.py` in the workspace directory.
  - Output is written to `usda_import_full.sql`.
- **CSV Schema Flexibility:**
  - The script auto-detects and adapts to column names (e.g., `description` vs `Description`).
  - If `wweia_food_category.csv` is missing, a default category set is generated.
- **Debugging:**
  - Print statements provide progress and warnings for missing files or columns.
  - Unicode output is enabled for Windows compatibility.
- **Customization:**
  - Modify the Python script to adjust mappings, add new rules, or change output format.

## Project-Specific Patterns
- Fuzzy matching and token-based inference for category assignment.
- Defensive coding: fallback logic for missing columns and files.
- SQL generation uses string formatting with escaping for single quotes.
- All random sampling uses fixed seeds for reproducibility where relevant.

## Integration Points
- No external dependencies beyond pandas.
- Output SQL is compatible with standard relational databases (tested with MSSQL).

## Example: Adding a New Data Source
1. Add the new CSV to the workspace.
2. Update `usda_import_full_all.py` to read and process the new file.
3. Extend SQL generation logic as needed.

## Conventions
- All scripts and data files are expected in the workspace root.
- Column names and schemas may change; always use auto-detection and fallback logic.
- All output is written in UTF-8 encoding.

---
For questions or unclear patterns, review `usda_import_full_all.py` for implementation details. Update this file if new workflows or conventions are introduced.
