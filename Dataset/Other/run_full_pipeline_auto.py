#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Automatic pipeline runner for real data processing
Runs all steps in sequence until successful
"""
import os
import sys
import subprocess
from pathlib import Path

# Fix encoding for Windows console
if sys.platform == 'win32':
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')

# Get script directory
SCRIPT_DIR = Path(__file__).resolve().parent
CACHE_DIR = SCRIPT_DIR / "WHO_ICD10"
DRUGBANK_CSV = SCRIPT_DIR / "DRUGBANK" / "drugbank_clean.csv"

def run_command(cmd, description):
    """Run a command and return success status"""
    print("\n" + "="*60)
    print(f"[RUNNING] {description}")
    print("="*60)
    print(f"Command: {' '.join(cmd)}")
    print()
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=False, text=True)
        print(f"\n[SUCCESS] {description} - SUCCESS")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n[FAILED] {description} - FAILED (exit code: {e.returncode})")
        return False
    except Exception as e:
        print(f"\n[ERROR] {description} - ERROR: {e}")
        return False

def check_file_exists(filepath, description):
    """Check if a file exists"""
    if Path(filepath).exists():
        print(f"[OK] {description} exists: {filepath}")
        return True
    else:
        print(f"[MISSING] {description} NOT found: {filepath}")
        return False

def main():
    print("="*60)
    print("AUTOMATIC PIPELINE RUNNER")
    print("="*60)
    print(f"Working directory: {SCRIPT_DIR}")
    print(f"Cache directory: {CACHE_DIR}")
    print()
    
    # Check prerequisites
    print("[CHECK] Checking prerequisites...")
    if not DRUGBANK_CSV.exists():
        print(f"[ERROR] DrugBank CSV not found: {DRUGBANK_CSV}")
        print("   Please ensure the file exists before running the pipeline.")
        return 1
    
    print(f"[OK] DrugBank CSV found: {DRUGBANK_CSV}")
    print()
    
    # Step 1: ICD-10
    print("\n" + "="*60)
    print("STEP 1: ICD-10 Codes")
    print("="*60)
    icd10_file = CACHE_DIR / "icd10.json"
    if icd10_file.exists():
        print(f"[OK] ICD-10 file already exists: {icd10_file}")
        print("   Skipping download...")
    else:
        success = run_command(
            [sys.executable, "fetch_data_real.py", "--icd10"],
            "Fetching ICD-10 codes"
        )
        if not success:
            print("[WARNING] ICD-10 fetch failed, but continuing...")
    
    # Step 2: DailyMed SPL
    print("\n" + "="*60)
    print("STEP 2: DailyMed SPL (200 drugs)")
    print("="*60)
    dailymed_file = CACHE_DIR / "dailymed_spl.json"
    if dailymed_file.exists():
        print(f"[OK] DailyMed file already exists: {dailymed_file}")
        print("   Skipping download...")
    else:
        success = run_command(
            [sys.executable, "fetch_data_real.py", "--dailymed", "--dailymed-limit", "200"],
            "Fetching DailyMed SPL (200 drugs)"
        )
        if not success:
            print("[ERROR] DailyMed fetch failed. Cannot continue.")
            return 1
    
    # Step 3: Extract ICD-10 from DailyMed
    print("\n" + "="*60)
    print("STEP 3: Extract ICD-10 from DailyMed")
    print("="*60)
    dailymed_icd10_file = CACHE_DIR / "dailymed_related_icd10.json"
    if dailymed_icd10_file.exists():
        print(f"[OK] DailyMed ICD-10 file already exists: {dailymed_icd10_file}")
        print("   Skipping extraction...")
    else:
        success = run_command(
            [sys.executable, "fetch_data_real.py", "--dailymed-icd10"],
            "Extracting ICD-10 codes from DailyMed"
        )
        if not success:
            print("[ERROR] DailyMed ICD-10 extraction failed. Cannot continue.")
            return 1
    
    # Step 4: Parse DrugBank food interactions
    print("\n" + "="*60)
    print("STEP 4: Parse DrugBank Food Interactions")
    print("="*60)
    drugbank_interactions_file = CACHE_DIR / "drugbank_food_interactions_parsed.json"
    if drugbank_interactions_file.exists():
        print(f"[OK] DrugBank interactions file already exists: {drugbank_interactions_file}")
        print("   Skipping parsing...")
    else:
        success = run_command(
            [sys.executable, "fetch_data_real.py", "--drugbank-food-interactions", 
             "--drugbank-csv", str(DRUGBANK_CSV)],
            "Parsing DrugBank food interactions"
        )
        if not success:
            print("[ERROR] DrugBank parsing failed. Cannot continue.")
            return 1
    
    # Step 5: Fetch targeted USDA foods
    print("\n" + "="*60)
    print("STEP 5: Fetch Targeted USDA Foods")
    print("="*60)
    usda_foods_file = CACHE_DIR / "usda_foods_targeted.json"
    if usda_foods_file.exists():
        print(f"[OK] USDA foods file already exists: {usda_foods_file}")
        print("   Skipping USDA fetch...")
    else:
        success = run_command(
            [sys.executable, "fetch_data_real.py", "--usda-targeted"],
            "Fetching targeted USDA foods"
        )
        if not success:
            print("[WARNING] USDA fetch failed, but continuing to generation step...")
    
    # Step 6: Generate database files
    print("\n" + "="*60)
    print("STEP 6: Generate Database Files")
    print("="*60)
    
    # Check if all required files exist
    required_files = {
        "ICD-10": CACHE_DIR / "icd10.json",
        "DailyMed SPL": CACHE_DIR / "dailymed_spl.json",
        "DailyMed ICD-10": CACHE_DIR / "dailymed_related_icd10.json",
        "DrugBank Interactions": CACHE_DIR / "drugbank_food_interactions_parsed.json",
        "USDA Foods": CACHE_DIR / "usda_foods_targeted.json",
    }
    
    missing_files = []
    for name, filepath in required_files.items():
        if not filepath.exists():
            missing_files.append(f"  - {name}: {filepath}")
    
    if missing_files:
        print("[ERROR] Missing required files:")
        for msg in missing_files:
            print(msg)
        print("\nPlease run the previous steps to generate these files.")
        return 1
    
    print("[OK] All required files exist. Generating database files...")
    success = run_command(
        [sys.executable, "generate_full_pipeline_real.py"],
        "Generating database files"
    )
    
    if not success:
        print("[ERROR] Database generation failed.")
        return 1
    
    # Final summary
    print("\n" + "="*60)
    print("PIPELINE COMPLETE!")
    print("="*60)
    print("\n[SUCCESS] All steps completed successfully!")
    print(f"\n[OUTPUT] Output directory: {SCRIPT_DIR / 'Generated_Data'}")
    print("\nGenerated files:")
    output_dir = SCRIPT_DIR / "Generated_Data"
    if output_dir.exists():
        for table_dir in sorted(output_dir.iterdir()):
            if table_dir.is_dir():
                csv_file = table_dir / f"{table_dir.name}.csv"
                if csv_file.exists():
                    with open(csv_file, 'r', encoding='utf-8') as f:
                        lines = sum(1 for _ in f) - 1  # Subtract header
                    print(f"  [OK] {table_dir.name}: {lines:,} rows")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())

