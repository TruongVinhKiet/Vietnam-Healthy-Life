#!/usr/bin/env python3
"""
Master script to run full data pipeline:
1. Fetch data from APIs (fetch_data_real.py)
2. Generate CSV/SQL files with proper schema mapping (generate_full_pipeline_real.py)
3. Add Vietnamese translations
4. Export everything to Dataset/Generated_Data folder

Usage:
    python run_full_pipeline.py --all
    python run_full_pipeline.py --icd10 --usda --dailymed --drugbank
    python run_full_pipeline.py --generate-only  # Skip fetching, only generate
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path

# Setup paths
SCRIPT_DIR = Path(__file__).resolve().parent
DATASET_DIR = SCRIPT_DIR
OUTPUT_DIR = DATASET_DIR / "Generated_Data"

# Ensure output directory exists
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

def run_script(script_path, args=None):
    """Run a Python script and return success status"""
    script_path = Path(script_path)
    if not script_path.exists():
        print(f"ERROR: Script not found: {script_path}")
        return False
    
    cmd = [sys.executable, str(script_path)]
    if args:
        cmd.extend(args)
    
    print(f"\n{'='*60}")
    print(f"Running: {script_path.name}")
    print(f"Command: {' '.join(cmd)}")
    print(f"{'='*60}\n")
    
    try:
        result = subprocess.run(cmd, cwd=SCRIPT_DIR, check=True, capture_output=False)
        print(f"\n[OK] {script_path.name} completed successfully\n")
        return True
    except subprocess.CalledProcessError as e:
        print(f"\n[ERROR] {script_path.name} failed with exit code {e.returncode}\n")
        return False
    except Exception as e:
        print(f"\n[ERROR] Failed to run {script_path.name}: {e}\n")
        return False

def check_dependencies():
    """Check if required Python packages are installed"""
    missing = []
    try:
        import pandas
    except ImportError:
        missing.append("pandas")
    
    try:
        import requests
    except ImportError:
        missing.append("requests")
    
    if missing:
        print(f"\n[ERROR] Missing required packages: {', '.join(missing)}")
        print(f"  Please install with: pip install {' '.join(missing)}")
        print(f"  Or install all dependencies: pip install -r requirements.txt")
        return False
    
    return True

def main():
    parser = argparse.ArgumentParser(description="Run full data pipeline")
    parser.add_argument("--fetch-only", action="store_true", help="Only fetch data, skip generation")
    parser.add_argument("--generate-only", action="store_true", help="Only generate files, skip fetching")
    parser.add_argument("--icd10", action="store_true", help="Fetch ICD-10 data")
    parser.add_argument("--usda", action="store_true", help="Fetch USDA data")
    parser.add_argument("--dailymed", action="store_true", help="Fetch DailyMed data")
    parser.add_argument("--dailymed-limit", type=int, default=200, help="DailyMed limit")
    parser.add_argument("--drugbank", action="store_true", help="Parse DrugBank data")
    parser.add_argument("--all", action="store_true", help="Run all fetch operations")
    parser.add_argument("--skip-dependency-check", action="store_true", help="Skip dependency check")
    
    args = parser.parse_args()
    
    # Check dependencies before running
    if not args.skip_dependency_check and not check_dependencies():
        return 1
    
    print("="*60)
    print("FULL DATA PIPELINE")
    print("="*60)
    print(f"Working directory: {SCRIPT_DIR}")
    print(f"Output directory: {OUTPUT_DIR}")
    print("="*60)
    
    success = True
    
    # Step 1: Fetch data
    if not args.generate_only:
        print("\n[STEP 1] Fetching data from APIs...")
        fetch_script = SCRIPT_DIR / "fetch_data_real.py"
        
        fetch_args = []
        if args.all or args.icd10:
            fetch_args.append("--icd10")
        if args.all or args.usda:
            # Use targeted USDA fetch to avoid ambiguous --usda option
            fetch_args.append("--usda-targeted")
            fetch_args.append("--usda-targeted-force")
        if args.all or args.dailymed:
            fetch_args.append("--dailymed")
            fetch_args.append(f"--dailymed-limit={args.dailymed_limit}")
        if args.all or args.drugbank:
            fetch_args.append("--drugbank-food-interactions")
        
        # If no specific flags, fetch everything
        if not fetch_args:
            fetch_args = ["--icd10", "--usda-targeted", "--usda-targeted-force", "--dailymed", "--drugbank-food-interactions"]
        
        if not run_script(fetch_script, fetch_args):
            print("[WARNING] Some fetch operations failed, but continuing...")
    
    # Step 2: Generate CSV/SQL files
    if not args.fetch_only:
        print("\n[STEP 2] Generating CSV/SQL files...")
        generate_script = SCRIPT_DIR / "generate_full_pipeline_real.py"
        
        if not run_script(generate_script):
            print("[ERROR] Generation failed!")
            success = False
    
    if success:
        print("\n" + "="*60)
        print("[SUCCESS] Full pipeline completed!")
        print("="*60)
        print(f"Check output in: {OUTPUT_DIR}")
        return 0
    else:
        print("\n" + "="*60)
        print("[ERROR] Pipeline completed with errors")
        print("="*60)
        return 1

if __name__ == "__main__":
    sys.exit(main())

