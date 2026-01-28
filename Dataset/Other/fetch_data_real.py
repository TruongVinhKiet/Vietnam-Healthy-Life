import os
import json
import time
import re
import argparse
import csv
import requests
from pathlib import Path
from xml.etree import ElementTree as ET

try:
    import pandas as pd
except ImportError:
    pd = None

# =========================
# CONFIG
# =========================
_SCRIPT_DIR = Path(__file__).resolve().parent
_DATASET_DIR = _SCRIPT_DIR  # Dataset folder is where the script is located
_DEFAULT_CACHE_DIR = _DATASET_DIR / "WHO_ICD10"
_DEFAULT_EXPORT_DIR = _DATASET_DIR / "Real Data"

_env_cache_dir = os.environ.get("REAL_DATA_CACHE_DIR") or os.environ.get("CSDL_CACHE_DIR")
CACHE_DIR = Path(_env_cache_dir) if _env_cache_dir else _DEFAULT_CACHE_DIR
CACHE_DIR.mkdir(parents=True, exist_ok=True)

_env_export_dir = os.environ.get("REAL_DATA_EXPORT_DIR") or os.environ.get("REAL_DATA_OUT_DIR")
EXPORT_DIR = Path(_env_export_dir) if _env_export_dir else _DEFAULT_EXPORT_DIR
EXPORT_DIR.mkdir(parents=True, exist_ok=True)

USDA_API_KEY = os.environ.get("USDA_API_KEY") or "k0k7T0dzmxj1WRo80WXWkGCKCTxbxLcM98ZqhaOE"
DAILYMED_BASE = "https://dailymed.nlm.nih.gov/dailymed/services/v2/spls.json"
DAILYMED_SPL_URL = "https://dailymed.nlm.nih.gov/dailymed/services/v2/spls/"
ICD10_URLS = [
    "https://raw.githubusercontent.com/kamillmagdy/ICD-10-CM-Codes/master/2023/icd10cm.json",
    "https://cdn.jsdelivr.net/gh/kamillmagdy/ICD-10-CM-Codes/master/2023/icd10cm.json",
]
ICD10_URL = ICD10_URLS[0]

# =========================
# HELPERS
# =========================
def cache_save(name, obj):
    with open(CACHE_DIR / name, "w", encoding="utf-8") as f:
        json.dump(obj, f, indent=2, ensure_ascii=False)

def cache_load(name):
    p = CACHE_DIR / name
    if not p.exists():
        return None
    try:
        with open(p, encoding="utf-8") as f:
            return json.load(f)
    except Exception as e:
        print(f"[WARNING] Failed to load cache file {name}: {e}")
        return None


def load_nutrient_filter_codes():
    """Load nutrient codes from filter list"""
    filter_path = _SCRIPT_DIR / "nutrient_filter_list.txt"
    if not filter_path.exists():
        legacy_filter = Path(r"D:\dataset\drugbank\nutrient_filter_list.txt")
        if legacy_filter.exists():
            filter_path = legacy_filter
        else:
            print("[WARNING] nutrient_filter_list.txt not found. Using default list.")
            return {
                "ENERC_KCAL", "PROCNT", "FAT", "CHOCDF", "FIBTG", "FIB_SOL", "FIB_INSOL",
                "FIB_RS", "FIB_BGLU", "CHOLESTEROL", "VITA", "VITD", "VITE", "VITK", "VITC",
                "VITB1", "VITB2", "VITB3", "VITB5", "VITB6", "VITB7", "VITB9", "VITB12",
                "CA", "P", "MG", "K", "NA", "FE", "ZN", "CU", "MN", "I", "SE", "CR", "MO", "F",
                "FAMS", "FAPU", "FASAT", "FATRN", "FAEPA", "FADHA", "FAEPA_DHA",
                "FA18_2N6C", "FA18_3N3", "AMINO_HIS", "AMINO_ILE", "AMINO_LEU", "AMINO_LYS",
                "AMINO_MET", "AMINO_PHE", "AMINO_THR", "AMINO_TRP", "AMINO_VAL",
                "ALA", "EPA_DHA", "LA", "TOTAL_FIBER", "WATER"
            }
    
    with open(filter_path, encoding="utf-8") as f:
        return {line.strip().upper() for line in f if line.strip()}


def matches_nutrient_filter(nutrient_obj, nutrient_codes):
    """Check if a nutrient matches our filter list"""
    if not nutrient_obj:
        return False
    
    nutrient_number = str(nutrient_obj.get("number", "")).strip().upper()
    nutrient_name = str(nutrient_obj.get("name", "")).strip().upper()
    
    if nutrient_number in nutrient_codes:
        return True
    
    if nutrient_name:
        normalized_name = re.sub(r'[^\w\s]', '', nutrient_name).strip()
        
        name_to_code_map = {
            "ENERGY": "ENERC_KCAL", "CALORIE": "ENERC_KCAL",
            "PROTEIN": "PROCNT",
            "FAT": "FAT", "LIPID": "FAT", "TOTAL LIPID": "FAT",
            "CARBOHYDRATE": "CHOCDF",
            "FIBER": "FIBTG", "DIETARY FIBER": "FIBTG",
            "TOTAL DIETARY FIBER": "TOTAL_FIBER",
            "SOLUBLE FIBER": "FIB_SOL", "INSOLUBLE FIBER": "FIB_INSOL",
            "RESISTANT STARCH": "FIB_RS", "BETA GLUCAN": "FIB_BGLU",
            "CHOLESTEROL": "CHOLESTEROL",
            "VITAMIN A": "VITA", "VITAMIN D": "VITD", "VITAMIN E": "VITE",
            "VITAMIN K": "VITK", "VITAMIN C": "VITC", "ASCORBIC": "VITC",
            "THIAMINE": "VITB1", "VITAMIN B1": "VITB1",
            "RIBOFLAVIN": "VITB2", "VITAMIN B2": "VITB2",
            "NIACIN": "VITB3", "VITAMIN B3": "VITB3",
            "PANTOTHENIC": "VITB5", "VITAMIN B5": "VITB5",
            "PYRIDOXINE": "VITB6", "VITAMIN B6": "VITB6",
            "BIOTIN": "VITB7", "VITAMIN B7": "VITB7",
            "FOLATE": "VITB9", "FOLIC": "VITB9", "VITAMIN B9": "VITB9",
            "COBALAMIN": "VITB12", "VITAMIN B12": "VITB12",
            "CALCIUM": "CA", "PHOSPHORUS": "P", "MAGNESIUM": "MG",
            "POTASSIUM": "K", "SODIUM": "NA", "IRON": "FE", "ZINC": "ZN",
            "COPPER": "CU", "MANGANESE": "MN", "IODINE": "I", "SELENIUM": "SE",
            "CHROMIUM": "CR", "MOLYBDENUM": "MO", "FLUORIDE": "F",
            "MONOUNSATURATED": "FAMS", "MUFA": "FAMS",
            "POLYUNSATURATED": "FAPU", "PUFA": "FAPU",
            "SATURATED": "FASAT", "SFA": "FASAT",
            "TRANS": "FATRN",
            "EPA": "FAEPA", "EICOSAPENTAENOIC": "FAEPA",
            "DHA": "FADHA", "DOCOSAHEXAENOIC": "FADHA",
            "LINOLEIC": "FA18_2N6C", "LA 18:2": "FA18_2N6C",
            "ALPHA LINOLENIC": "FA18_3N3", "ALA 18:3": "FA18_3N3",
            "HISTIDINE": "AMINO_HIS", "ISOLEUCINE": "AMINO_ILE",
            "LEUCINE": "AMINO_LEU", "LYSINE": "AMINO_LYS",
            "METHIONINE": "AMINO_MET", "PHENYLALANINE": "AMINO_PHE",
            "THREONINE": "AMINO_THR", "TRYPTOPHAN": "AMINO_TRP",
            "VALINE": "AMINO_VAL", "WATER": "WATER",
        }
        
        for key, code in name_to_code_map.items():
            if key in normalized_name and code in nutrient_codes:
                return True
    
    return False


# =========================
# FETCH ICD-10 CODES
# =========================
def fetch_icd10():
    """Download ICD-10 codes from GitHub"""
    cached = cache_load("icd10.json")
    if cached:
        print(f"[OK] ICD-10 cached: {len(cached)} codes")
        return cached
    
    # Check if file exists locally even if not in cache
    local_file = CACHE_DIR / "icd10.json"
    if local_file.exists():
        try:
            with open(local_file, encoding="utf-8") as f:
                data = json.load(f)
            print(f"[OK] ICD-10 loaded from local file: {len(data)} codes")
            return data
        except Exception as e:
            print(f"[WARNING] Failed to load local ICD-10 file: {e}")
    
    print(f"[INFO] Fetching ICD-10 from {ICD10_URL}...")
    for url in ICD10_URLS:
        try:
            r = requests.get(url, timeout=30)
            if r.status_code == 200:
                data = r.json()
                cache_save("icd10.json", data)
                print(f"[OK] ICD-10 downloaded: {len(data)} codes")
                return data
        except Exception as e:
            print(f"[ERROR] Failed to fetch from {url}: {e}")
            continue
    
    # If all URLs fail but local file exists, try loading it one more time
    if local_file.exists():
        try:
            with open(local_file, encoding="utf-8") as f:
                data = json.load(f)
            print(f"[OK] Using existing local ICD-10 file: {len(data)} codes")
            return data
        except Exception as e:
            print(f"[ERROR] Failed to load local ICD-10 file: {e}")
    
    raise Exception("Failed to fetch ICD-10 from all URLs and no valid local file found")


# =========================
# FETCH DAILYMED SPL (200 DRUGS)
# =========================
def fetch_dailymed(limit=200, force=False):
    """Fetch DailyMed SPL data for specified number of drugs"""
    cache_file = "dailymed_spl.json"
    
    if not force:
        cached = cache_load(cache_file)
        if cached:
            print(f"[OK] DailyMed SPL cached: {len(cached)} drugs")
            return cached
    
    print(f"[INFO] Fetching DailyMed SPL (limit={limit})...")
    
    all_spls = []
    page = 1
    
    while len(all_spls) < limit:
        try:
            url = f"{DAILYMED_BASE}?page={page}&pagesize=100"
            r = requests.get(url, timeout=30)
            if r.status_code != 200:
                break
            
            data = r.json()
            spls = data.get("data", [])
            if not spls:
                break
            
            all_spls.extend(spls)
            print(f"  Page {page}: {len(spls)} drugs (total: {len(all_spls)})")
            
            if len(all_spls) >= limit:
                all_spls = all_spls[:limit]
                break
            
            page += 1
            time.sleep(0.5)
            
        except Exception as e:
            print(f"[ERROR] Page {page}: {e}")
            break
    
    cache_save(cache_file, all_spls)
    print(f"[OK] DailyMed SPL fetched: {len(all_spls)} drugs")
    return all_spls


# =========================
# EXTRACT ICD-10 FROM DAILYMED
# =========================
def extract_related_icd10_from_dailymed(force=False):
    """Extract ICD-10 codes mentioned in DailyMed SPL documents"""
    cache_file = "dailymed_related_icd10.json"
    
    if not force:
        cached = cache_load(cache_file)
        if cached:
            print(f"[OK] Related ICD-10 cached: {len(cached)} codes")
            return cached
    
    dailymed_spl = cache_load("dailymed_spl.json")
    if not dailymed_spl:
        # Try loading directly from file
        dailymed_file = CACHE_DIR / "dailymed_spl.json"
        if dailymed_file.exists():
            try:
                with open(dailymed_file, encoding="utf-8") as f:
                    dailymed_spl = json.load(f)
                print(f"[OK] Loaded DailyMed SPL from local file: {len(dailymed_spl)} drugs")
            except Exception as e:
                print(f"[ERROR] Failed to load DailyMed SPL file: {e}")
                return {}
        else:
            print("[ERROR] Missing dailymed_spl.json. Run --dailymed first.")
            return {}
    
    icd10_data = cache_load("icd10.json")
    if not icd10_data:
        # Try loading directly from file
        icd10_file = CACHE_DIR / "icd10.json"
        if icd10_file.exists():
            try:
                with open(icd10_file, encoding="utf-8") as f:
                    icd10_data = json.load(f)
                print(f"[OK] Loaded ICD-10 from local file: {len(icd10_data)} codes")
            except Exception as e:
                print(f"[ERROR] Failed to load ICD-10 file: {e}")
                return {}
        else:
            print("[ERROR] Missing icd10.json. Run --icd10 first.")
            return {}
    
    # Handle both list and dict formats
    if isinstance(dailymed_spl, dict):
        # Convert dict to list of values. Handle both real SPL entries and
        # mock/test entries that store content under a 'data' dict.
        spl_list = []
        for key, value in dailymed_spl.items():
            if isinstance(value, dict):
                if "setid" in value:
                    spl_list.append(value)
                elif "data" in value:
                    # Mock format: attach setid so we can process without HTTP
                    value["setid"] = key
                    spl_list.append(value)
                else:
                    value["setid"] = key
                    spl_list.append(value)
        dailymed_spl = spl_list
        print(f"[INFO] Converted DailyMed SPL from dict to list: {len(dailymed_spl)} items")
    
    if not isinstance(dailymed_spl, list):
        print(f"[ERROR] Unexpected DailyMed SPL format: {type(dailymed_spl)}")
        return {}
    
    print(f"[INFO] Extracting ICD-10 from {len(dailymed_spl)} SPL documents...")
    
    icd10_codes = {item.get("code", "").upper(): item for item in icd10_data if item.get("code")}
    
    related_icd10 = {}
    icd_pattern = re.compile(r'\b([A-Z]\d{2}(?:\.\d{1,4})?)\b')
    
    for idx, spl in enumerate(dailymed_spl, 1):
        if not isinstance(spl, dict):
            continue
        setid = spl.get("setid")
        
        try:
            # If this SPL entry contains a 'data' dict (mock/test data), build a
            # synthetic text blob from its fields instead of fetching XML.
            if isinstance(spl, dict) and 'data' in spl and isinstance(spl['data'], dict):
                data_blob_parts = []
                for k, v in spl['data'].items():
                    if isinstance(v, list):
                        data_blob_parts.extend([str(x) for x in v if x])
                    elif v:
                        data_blob_parts.append(str(v))
                xml_content = ' '.join(data_blob_parts)
            else:
                spl_url = f"{DAILYMED_SPL_URL}{setid}.xml"
                r = requests.get(spl_url, timeout=15)
                if r.status_code != 200:
                    # Unable to fetch remote XML for this SPL
                    if idx % 10 == 0:
                        print(f"  Skipped fetching SPL {setid} (status {r.status_code})")
                    time.sleep(0.3)
                    continue
                xml_content = r.text

            matches = icd_pattern.findall(xml_content)
            for code in matches:
                code_upper = code.upper()
                # Normalize: remove dots (E11.9 -> E119) to match icd10 dataset keys
                norm_code = code_upper.replace('.', '')
                alt_code = None
                if len(norm_code) == 3:
                    alt_code = norm_code + '0'

                if norm_code in icd10_codes and norm_code not in related_icd10:
                    related_icd10[norm_code] = icd10_codes[norm_code]
                elif alt_code and alt_code in icd10_codes and alt_code not in related_icd10:
                    related_icd10[alt_code] = icd10_codes[alt_code]

            if idx % 10 == 0:
                print(f"  Processed {idx}/{len(dailymed_spl)} SPLs, found {len(related_icd10)} ICD codes")

            time.sleep(0.3)

        except Exception as e:
            print(f"[ERROR] Failed to process SPL {setid}: {e}")
            continue
    
    cache_save(cache_file, related_icd10)
    print(f"[OK] Related ICD-10 extracted: {len(related_icd10)} codes")
    return related_icd10


# =========================
# SEARCH USDA FOODS BY NAME (NEW LOGIC)
# =========================
def search_usda_food_by_name(food_name, nutrient_codes):
    """
    Search USDA FoodData Central for a specific food by name
    Returns: dict with fdcId, description, and filtered nutrients
    """
    if not food_name or len(food_name) < 3:
        return None
    
    food_name = food_name.strip().lower()
    
    search_url = f"https://api.nal.usda.gov/fdc/v1/foods/search"
    params = {
        "api_key": USDA_API_KEY,
        "query": food_name,
        "pageSize": 5,
        "dataType": ["Survey (FNDDS)", "Foundation", "SR Legacy"]
    }
    
    try:
        r = requests.get(search_url, params=params, timeout=15)
        if r.status_code != 200:
            return None
        
        data = r.json()
        foods = data.get("foods", [])
        
        if not foods:
            return None
        
        best_match = foods[0]
        fdc_id = best_match.get("fdcId")
        description = best_match.get("description", "")
        
        detail_url = f"https://api.nal.usda.gov/fdc/v1/food/{fdc_id}"
        r2 = requests.get(detail_url, params={"api_key": USDA_API_KEY}, timeout=15)
        
        if r2.status_code != 200:
            return None
        
        food_detail = r2.json()
        
        filtered_nutrients = []
        for nutrient_obj in food_detail.get("foodNutrients", []):
            if matches_nutrient_filter(nutrient_obj.get("nutrient", {}), nutrient_codes):
                filtered_nutrients.append(nutrient_obj)
        
        return {
            "fdcId": fdc_id,
            "description": description,
            "foodNutrients": filtered_nutrients
        }
        
    except Exception as e:
        print(f"[WARNING] Failed to search '{food_name}': {e}")
        return None


def search_usda_foods_by_category(category_terms, nutrient_codes, max_per_category=50):
    """
    Search USDA for foods in a category (e.g., "grapefruit", "dairy", "leafy greens")
    Returns list of food data sorted by number of nutrients
    """
    all_foods = []
    
    for term in category_terms:
        search_url = f"https://api.nal.usda.gov/fdc/v1/foods/search"
        params = {
            "api_key": USDA_API_KEY,
            "query": term,
            "pageSize": max_per_category,
            "dataType": ["Survey (FNDDS)", "Foundation", "SR Legacy"]
        }
        
        try:
            r = requests.get(search_url, params=params, timeout=15)
            if r.status_code == 200:
                data = r.json()
                foods = data.get("foods", [])
                
                for food in foods:
                    fdc_id = food.get("fdcId")
                    if not fdc_id:
                        continue
                    
                    # Get detailed nutrient data
                    detail_url = f"https://api.nal.usda.gov/fdc/v1/food/{fdc_id}"
                    r2 = requests.get(detail_url, params={"api_key": USDA_API_KEY}, timeout=15)
                    
                    if r2.status_code == 200:
                        food_detail = r2.json()
                        
                        # Count matching nutrients
                        filtered_nutrients = []
                        for nutrient_obj in food_detail.get("foodNutrients", []):
                            if matches_nutrient_filter(nutrient_obj.get("nutrient", {}), nutrient_codes):
                                filtered_nutrients.append(nutrient_obj)
                        
                        if len(filtered_nutrients) > 0:
                            all_foods.append({
                                "fdcId": fdc_id,
                                "description": food_detail.get("description", food.get("description", "")),
                                "foodNutrients": filtered_nutrients,
                                "nutrient_count": len(filtered_nutrients)
                            })
                    
                    time.sleep(0.3)
            
            time.sleep(0.5)
        except Exception as e:
            print(f"[WARNING] Failed to search category '{term}': {e}")
            continue
    
    # Sort by number of nutrients (descending) and remove duplicates
    seen_fdc_ids = set()
    unique_foods = []
    for food in sorted(all_foods, key=lambda x: x.get("nutrient_count", 0), reverse=True):
        fdc_id = food.get("fdcId")
        if fdc_id not in seen_fdc_ids:
            seen_fdc_ids.add(fdc_id)
            unique_foods.append(food)
    
    return unique_foods


# USDA nutrient number to our code mapping
USDA_NUTRIENT_NBR_TO_CODE = {
    "1008": "ENERC_KCAL", "208": "ENERC_KCAL", "268": "ENERC_KCAL",
    "1003": "PROCNT", "203": "PROCNT",
    "1004": "FAT", "204": "FAT",
    "1005": "CHOCDF", "205": "CHOCDF",
    "1079": "FIBTG", "291": "FIBTG",
    "1087": "CA", "301": "CA",
    "1089": "FE", "303": "FE",
    "1090": "MG", "304": "MG",
    "1092": "K", "306": "K",
    "1093": "NA", "307": "NA",
    "1095": "ZN", "309": "ZN",
    "1162": "VITC", "401": "VITC",
    "1185": "VITK", "430": "VITK",
    "1106": "VITA", "320": "VITA",
    "1114": "VITD", "328": "VITD",
    "1109": "VITE", "323": "VITE",
    "1051": "WATER", "255": "WATER",
    "1253": "CHOLESTEROL",
    "1165": "VITB1", "1166": "VITB2", "1167": "VITB3",
    "1170": "VITB5", "1175": "VITB6", "1176": "VITB7",
    "1177": "VITB9", "1178": "VITB12",
    "1091": "P", "1082": "FIB_SOL", "1084": "FIB_INSOL",
    "1098": "CU", "1101": "MN", "1100": "I", "1103": "SE",
    "1096": "CR", "1102": "MO", "1099": "F",
}

def load_usda_foods_from_csv(food_names_list, target_count=500):
    """
    Load USDA foods from CSV files instead of API
    Filters by DrugBank food names and selects top foods by nutrient count
    """
    usda_data_dir = _DATASET_DIR / "USDA" / "usda_data"
    food_csv = usda_data_dir / "food.csv"
    food_nutrient_csv = usda_data_dir / "food_nutrient.csv"
    nutrient_csv = usda_data_dir / "nutrient.csv"
    
    if not food_csv.exists() or not food_nutrient_csv.exists():
        print(f"[WARNING] USDA CSV files not found. Falling back to API.")
        return None
    
    print(f"[INFO] Loading USDA foods from CSV files (target: ~{target_count} foods)...")
    
    try:
        # Load CSV files
        df_food = pd.read_csv(food_csv, low_memory=False)
        df_food_nutrient = pd.read_csv(food_nutrient_csv, low_memory=False)
        df_nutrient = pd.read_csv(nutrient_csv, low_memory=False) if nutrient_csv.exists() else None
        
        print(f"  Loaded {len(df_food)} foods, {len(df_food_nutrient)} food-nutrient relationships")
        
        # Get nutrient filter codes
        nutrient_codes = load_nutrient_filter_codes()
        
        # IMPORTANT: In food_nutrient.csv, nutrient_id is actually nutrient_nbr, not nutrient.id!
        # Map nutrient_nbr directly to our codes
        nutrient_nbr_to_code = {}
        
        if df_nutrient is not None:
            for _, row in df_nutrient.iterrows():
                nutrient_nbr = str(row.get("nutrient_nbr", "")).strip()
                nutrient_name = str(row.get("name", "")).upper()
                
                if nutrient_nbr:
                    # Try to map by nutrient number
                    if nutrient_nbr in USDA_NUTRIENT_NBR_TO_CODE:
                        code = USDA_NUTRIENT_NBR_TO_CODE[nutrient_nbr]
                        if code in nutrient_codes:
                            nutrient_nbr_to_code[nutrient_nbr] = code
                    elif nutrient_name:
                        # Try name matching
                        for key, code in {
                            "ENERGY": "ENERC_KCAL", "PROTEIN": "PROCNT", "FAT": "FAT",
                            "CARBOHYDRATE": "CHOCDF", "FIBER": "FIBTG",
                            "CALCIUM": "CA", "IRON": "FE", "MAGNESIUM": "MG",
                            "POTASSIUM": "K", "SODIUM": "NA", "ZINC": "ZN",
                            "VITAMIN C": "VITC", "VITAMIN K": "VITK",
                            "VITAMIN A": "VITA", "VITAMIN D": "VITD", "VITAMIN E": "VITE",
                            "WATER": "WATER", "CHOLESTEROL": "CHOLESTEROL",
                        }.items():
                            if key in nutrient_name and code in nutrient_codes:
                                nutrient_nbr_to_code[nutrient_nbr] = code
                                break
        
        print(f"  Mapped {len(nutrient_nbr_to_code)} nutrients to our codes")
        
        # Count nutrients per food (only filtered nutrients)
        food_nutrient_counts = {}
        food_nutrient_data = {}
        
        for _, row in df_food_nutrient.iterrows():
            fdc_id = str(row.get("fdc_id", ""))
            nutrient_nbr = str(row.get("nutrient_id", ""))  # This is actually nutrient_nbr!
            amount = row.get("amount", 0)
            
            if not fdc_id or not nutrient_nbr or pd.isna(amount) or amount <= 0:
                continue
            
            # Check if this nutrient is in our filter (nutrient_id in CSV = nutrient_nbr)
            if nutrient_nbr in nutrient_nbr_to_code:
                nutrient_code = nutrient_nbr_to_code[nutrient_nbr]
                if nutrient_code in nutrient_codes:
                    if fdc_id not in food_nutrient_counts:
                        food_nutrient_counts[fdc_id] = 0
                        food_nutrient_data[fdc_id] = []
                    
                    food_nutrient_counts[fdc_id] += 1
                    food_nutrient_data[fdc_id].append({
                        "nutrient": {
                            "id": int(nutrient_nbr) if nutrient_nbr.isdigit() else 0,
                            "number": nutrient_nbr,
                            "name": ""
                        },
                        "amount": float(amount)
                    })
        
        print(f"  Found {len(food_nutrient_counts)} foods with filtered nutrients")
        
        # Filter foods by DrugBank terms (but include all if needed to reach target)
        food_names_lower = {name.lower().strip() for name in food_names_list}
        matched_foods = []
        all_foods = []
        
        for _, row in df_food.iterrows():
            fdc_id = str(row.get("fdc_id", ""))
            description = str(row.get("description", "")).lower()
            description_orig = str(row.get("description", ""))
            
            if not fdc_id or fdc_id not in food_nutrient_counts:
                continue
            
            # Check if food matches any DrugBank term
            matches = False
            for term in food_names_lower:
                if term in description or description in term:
                    matches = True
                    break
            
            # Also check common food categories
            if not matches:
                category_keywords = [
                    "grapefruit", "citrus", "orange", "lemon",
                    "dairy", "milk", "cheese", "yogurt",
                    "spinach", "kale", "broccoli", "leafy",
                    "fish", "salmon", "tuna", "seafood",
                    "grain", "bread", "rice", "pasta",
                    "nut", "almond", "walnut",
                    "berry", "blueberry", "strawberry",
                    "chicken", "beef", "meat",
                    "bean", "lentil", "legume",
                    "tomato", "carrot", "potato", "vegetable",
                    "coffee", "tea", "beverage",
                ]
                for keyword in category_keywords:
                    if keyword in description:
                        matches = True
                        break
            
            food_item = {
                "fdcId": int(fdc_id),
                "description": description_orig,
                "nutrient_count": food_nutrient_counts[fdc_id],
                "foodNutrients": food_nutrient_data[fdc_id],
                "matched": matches
            }
            
            if matches:
                matched_foods.append(food_item)
            else:
                all_foods.append(food_item)
        
        # Combine: matched foods first, then top foods by nutrient count
        all_foods.sort(key=lambda x: -x["nutrient_count"])
        selected_foods = matched_foods + all_foods[:target_count]
        selected_foods = selected_foods[:target_count]  # Limit to target
        
        print(f"  Matched foods: {len(matched_foods)}, All foods: {len(all_foods)}, Selected: {len(selected_foods)}")
        
        # Convert to expected format
        usda_foods = {}
        for idx, food in enumerate(selected_foods):
            # Use unique key to avoid duplicates
            key = f"{food['description']}_{food['fdcId']}" if food["description"] in usda_foods else food["description"]
            usda_foods[key] = {
                "fdcId": food["fdcId"],
                "description": food["description"],
                "foodNutrients": food["foodNutrients"]
            }
        
        if selected_foods:
            avg_nutrients = sum(f['nutrient_count'] for f in selected_foods) / len(selected_foods)
            print(f"[OK] Selected {len(usda_foods)} foods from CSV (avg {avg_nutrients:.1f} nutrients per food)")
        else:
            print(f"[WARNING] No foods selected from CSV")
        return usda_foods
        
    except Exception as e:
        print(f"[ERROR] Failed to load from CSV: {e}")
        import traceback
        traceback.print_exc()
        return None


def fetch_usda_foods_from_drugbank_list(food_names_list, force=False, target_count=500):
    """
    Fetch USDA foods for foods mentioned in DrugBank avoid/recommend
    Uses CSV files first, falls back to API if needed
    """
    cache_file = "usda_foods_targeted.json"
    
    if not force:
        cached = cache_load(cache_file)
        if cached and len(cached) >= target_count * 0.8:  # Allow 80% of target
            print(f"[OK] Targeted USDA foods cached: {len(cached)} foods")
            return cached
    
    # Try loading from CSV first (faster and more reliable)
    csv_foods = load_usda_foods_from_csv(food_names_list, target_count)
    if csv_foods and len(csv_foods) >= target_count * 0.8:
        cache_save(cache_file, csv_foods)
        return csv_foods
    
    # Fall back to API if CSV doesn't have enough
    nutrient_codes = load_nutrient_filter_codes()
    
    print(f"[INFO] Searching USDA API for foods from DrugBank list (target: ~{target_count} foods)...")
    
    usda_foods = csv_foods if csv_foods else {}
    success_count = len(usda_foods)
    
    # Step 1: Search for specific foods mentioned in DrugBank
    print(f"[STEP 1] Searching for {len(food_names_list)} specific foods...")
    for idx, food_name in enumerate(sorted(set(food_names_list)), 1):
        if food_name in usda_foods:
            continue
            
        print(f"  [{idx}/{len(food_names_list)}] Searching: {food_name}")
        
        food_data = search_usda_food_by_name(food_name, nutrient_codes)
        
        if food_data:
            usda_foods[food_name] = food_data
            success_count += 1
            print(f"    [OK] Found: {food_data['description']} (FDC ID: {food_data['fdcId']})")
        else:
            print(f"    [NOT FOUND] Not found in USDA")
        
        time.sleep(0.5)
        
        if idx % 10 == 0:
            cache_save(cache_file, usda_foods)
    
    # Do NOT expand search — only use USDA foods explicitly found from DrugBank terms.
    # User requested to avoid broad category expansion; keep only the foods
    # discovered in Step 1 (and any CSV matches) to preserve scientific quality.
    cache_save(cache_file, usda_foods)
    avg_nutrients = sum(len(f.get("foodNutrients", [])) for f in usda_foods.values()) / len(usda_foods) if usda_foods else 0
    print(f"[OK] USDA foods fetched: {len(usda_foods)} foods (avg {avg_nutrients:.1f} nutrients per food)")
    return usda_foods


# =========================
# PARSE DRUGBANK FOOD INTERACTIONS
# =========================
def parse_drugbank_food_interactions(drugbank_csv_path=None, force=False, max_drugs=None):
    """Parse DrugBank CSV to extract food interactions"""
    out_json = "drugbank_food_interactions_parsed.json"
    out_csv = "drugbank_food_interactions.csv"
    out_csv_by_drug_id = "drugbank_food_interactions_by_drug_id.csv"
    
    if not force:
        cached = cache_load(out_json)
        if cached:
            print(f"[OK] DrugBank interactions cached: {len(cached)} drugs")
            return cached
    
    if not drugbank_csv_path or drugbank_csv_path == "path/to/drugbank.csv":
        # Try multiple possible locations
        possible_paths = [
            os.environ.get("REALDATA_DRUGBANK"),
            str(_SCRIPT_DIR / "DRUGBANK" / "drugbank_clean.csv"),
            str(_DATASET_DIR / "DRUGBANK" / "drugbank_clean.csv"),
        ]
        for path in possible_paths:
            if path and Path(path).exists():
                drugbank_csv_path = path
                break
        else:
            raise Exception(f"DrugBank CSV not found. Tried: {possible_paths}")
    
    if not Path(drugbank_csv_path).exists():
        raise Exception(f"DrugBank CSV not found: {drugbank_csv_path}")
    
    print(f"[INFO] Parsing DrugBank food interactions from: {drugbank_csv_path}")
    
    df = pd.read_csv(drugbank_csv_path, low_memory=False)
    
    if max_drugs:
        df = df.head(max_drugs)
        print(f"[INFO] Limited to {max_drugs} drugs for testing")
    
    parsed = {}
    interaction_rows = []
    interaction_rows_by_source = []
    
    def norm_ws(s):
        return re.sub(r'\s+', ' ', s).strip()
    
    def find_severity(text):
        text_lower = text.lower()
        if any(w in text_lower for w in ["severe", "major", "serious", "contraindicated"]):
            return "major"
        elif any(w in text_lower for w in ["moderate", "monitor"]):
            return "moderate"
        else:
            return "minor"
    
    for idx, row in df.iterrows():
        # Try different column name variations
        dbid = str(row.get("drugbank-id", row.get("drugbank_id", ""))).strip()
        if not dbid or dbid == "nan":
            continue
        drug_id = row.get("drug_id")
        drug_name = str(row.get("name", "")).strip()
        if not drug_name or drug_name == "nan":
            continue
        
        if not dbid or pd.isna(drug_id):
            continue
        
        food_interactions_text = row.get("food_interactions", "")
        if pd.isna(food_interactions_text) or not food_interactions_text:
            continue
        
        avoid_food = []
        recommend_food = []
        term_info = {}
        
        sentences = re.split(r'[.!?]+', str(food_interactions_text))
        
        for sent in sentences:
            sent = sent.strip()
            if len(sent) < 10:
                continue
            
            sent_lower = sent.lower()
            
            food_terms = []
            
            food_patterns = [
                r'\b(grapefruit|orange|apple|banana|milk|cheese|yogurt|beef|chicken|fish|salmon|tuna|spinach|kale|broccoli|carrot|tomato|potato|rice|bread|pasta|egg|alcohol|wine|beer|caffeine|coffee|tea|chocolate|nuts|soy|tofu|beans|lentils|avocado|berries|citrus)\b',
                r'\b(dairy products?|citrus fruits?|leafy greens?|fatty fish|red meat|whole grains?|fermented foods?|high-fat foods?|high-fiber foods?|vitamin k[- ]rich foods?)\b',
            ]
            
            for pattern in food_patterns:
                matches = re.findall(pattern, sent_lower)
                food_terms.extend(matches)
            
            is_avoid = any(w in sent_lower for w in ["avoid", "not", "don't", "do not", "shouldn't", "should not", "limit", "restrict", "reduce", "minimize"])
            is_recommend = any(w in sent_lower for w in ["take with", "consume with", "eat with", "recommended", "should take", "better with", "increase"])
            
            severity = find_severity(sent)
            
            for term in set(food_terms):
                if term not in term_info:
                    term_info[term] = {
                        "severity": severity,
                        "actions": [],
                        "management": "",
                        "sentences": []
                    }
                
                term_info[term]["sentences"].append(sent)
                
                if is_avoid:
                    term_info[term]["actions"].append("avoid")
                    avoid_food.append(term)
                elif is_recommend:
                    term_info[term]["actions"].append("recommend")
                    recommend_food.append(term)
                else:
                    term_info[term]["actions"].append("monitor")
        
        for term, info in term_info.items():
            desc = norm_ws(" ".join(info["sentences"]))[:2000]
            
            interaction_rows.append([
                drug_id, "food", term,
                info["severity"] or "moderate", desc, info["management"] or ""
            ])
            interaction_rows_by_source.append([
                dbid, "food", term,
                info["severity"] or "moderate", desc, info["management"] or ""
            ])
        
        parsed[dbid] = {
            "drug_id": drug_id,
            "name": drug_name,
            "avoid_food": sorted(set(avoid_food)),
            "recommend_food": sorted(set(recommend_food)),
            "terms": {
                term: {
                    "severity": info["severity"] or "moderate",
                    "actions": sorted(info["actions"]),
                    "management": info["management"] or "",
                    "description": norm_ws(" ".join(info["sentences"]))[:2000],
                }
                for term, info in term_info.items()
            },
        }
    
    cache_save(out_json, parsed)
    
    csv_by_drug_id_path_out = EXPORT_DIR / out_csv_by_drug_id
    with open(csv_by_drug_id_path_out, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["drug_id", "interaction_type", "interacts_with", "severity", "description_en", "management_en"])
        w.writerows(interaction_rows)
    
    csv_path_out = EXPORT_DIR / out_csv
    with open(csv_path_out, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["source_link", "interaction_type", "interacts_with", "severity", "description_en", "management_en"])
        w.writerows(interaction_rows_by_source)
    
    total_avoid = sum(len(info.get("avoid_food", [])) for info in parsed.values())
    total_recommend = sum(len(info.get("recommend_food", [])) for info in parsed.values())
    total_terms = sum(len(info.get("terms", {})) for info in parsed.values())
    
    print(f"\n[OK] DrugBank food interactions parsed: {len(parsed)} drugs")
    print(f"  - Total interaction terms: {total_terms}")
    print(f"  - Foods to AVOID: {total_avoid}")
    print(f"  - Foods to RECOMMEND: {total_recommend}")
    print(f"[OK] CSV exported: {csv_path_out}")
    
    return parsed


# =========================
# EXTRACT FOOD NAMES FROM DRUGBANK
# =========================
def extract_food_names_from_drugbank():
    """Extract all unique food names from DrugBank avoid/recommend lists"""
    drugbank_interactions = cache_load("drugbank_food_interactions_parsed.json")
    if not drugbank_interactions:
        print("[ERROR] Missing drugbank_food_interactions_parsed.json")
        return []
    
    all_food_names = set()
    
    for dbid, info in drugbank_interactions.items():
        avoid_foods = info.get("avoid_food", [])
        all_food_names.update(avoid_foods)
        
        recommend_foods = info.get("recommend_food", [])
        all_food_names.update(recommend_foods)
        
        terms = info.get("terms", {})
        all_food_names.update(terms.keys())
    
    food_names_list = sorted(all_food_names)
    # Filter out non-food or overly-generic terms that cause noisy API searches
    blacklist_substrings = [
        "high ", "low ", "meal", "product", "products", "containing",
        "contains", "antacid", "antacids", "piracetam", "fluids", "water",
        "supplement", "tablet", "capsule", "dose", "high-fat", "high fat",
        "high fiber", "high-fiber", "potassium-containing", "potassium containing",
        "fat meal", "fiber foods", "st. john", "st john", "st\. john",
    ]

    filtered = []
    removed = []
    for name in food_names_list:
        lname = name.lower().strip()
        if not lname or len(lname) < 2:
            removed.append(name)
            continue
        if any(sub in lname for sub in blacklist_substrings):
            removed.append(name)
            continue
        # Exclude names that are clearly not single foods (contain "/" or "," with many tokens)
        if "/" in name or "\n" in name:
            removed.append(name)
            continue
        # Exclude very long descriptors (>6 words)
        if len(lname.split()) > 6:
            removed.append(name)
            continue
        filtered.append(name)

    print(f"[OK] Extracted {len(filtered)} unique food names from DrugBank (filtered from {len(food_names_list)})")
    print(f"  Sample foods: {filtered[:10]}")
    if removed:
        print(f"  Removed {len(removed)} noisy terms (examples): {removed[:8]}")

    cache_save("drugbank_extracted_food_names.json", filtered)

    return filtered


# =========================
# MAIN
# =========================
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Fetch real data - TARGETED approach")
    parser.add_argument("--dailymed", action="store_true")
    parser.add_argument("--dailymed-limit", type=int, default=200)
    parser.add_argument("--dailymed-force", action="store_true")
    parser.add_argument("--dailymed-icd10", action="store_true")
    parser.add_argument("--dailymed-icd10-force", action="store_true")
    parser.add_argument("--icd10", action="store_true")
    parser.add_argument("--drugbank-food-interactions", action="store_true")
    parser.add_argument("--drugbank-food-interactions-force", action="store_true")
    parser.add_argument("--drugbank-csv", type=str, default=None)
    parser.add_argument("--drugbank-max-drugs", type=int, default=None)
    parser.add_argument("--usda-targeted", action="store_true", help="NEW: Fetch USDA only for DrugBank foods")
    parser.add_argument("--usda-targeted-force", action="store_true")
    args = parser.parse_args()
    
    ran_any = False
    
    if args.icd10:
        local_icd10 = CACHE_DIR / "icd10.json"
        if local_icd10.exists():
            print(f"[OK] Found local ICD-10 file")
        else:
            fetch_icd10()
        ran_any = True
    
    if args.dailymed:
        local_dailymed = CACHE_DIR / "dailymed_spl.json"
        if local_dailymed.exists() and not args.dailymed_force:
            print(f"[OK] Found local DailyMed file")
        else:
            fetch_dailymed(limit=args.dailymed_limit, force=args.dailymed_force)
        ran_any = True
    
    if args.dailymed_icd10:
        extract_related_icd10_from_dailymed(force=args.dailymed_icd10_force)
        ran_any = True
    
    if args.drugbank_food_interactions:
        local_drugbank = CACHE_DIR / "drugbank_food_interactions_parsed.json"
        if local_drugbank.exists() and not args.drugbank_food_interactions_force:
            print(f"[OK] Found local DrugBank interactions file")
        else:
            parse_drugbank_food_interactions(
                drugbank_csv_path=args.drugbank_csv,
                force=args.drugbank_food_interactions_force,
                max_drugs=args.drugbank_max_drugs,
            )
        ran_any = True
    
    if args.usda_targeted:
        food_names_list = extract_food_names_from_drugbank()
        
        if food_names_list:
            fetch_usda_foods_from_drugbank_list(food_names_list, force=args.usda_targeted_force, target_count=500)
        else:
            print("[ERROR] No food names extracted")
        ran_any = True
    
    if not ran_any:
        print("\n[WORKFLOW]:")
        print("  1. python fetch_data_real.py --icd10")
        print("  2. python fetch_data_real.py --dailymed --dailymed-limit 200")
        print("  3. python fetch_data_real.py --dailymed-icd10")
        print("  4. python fetch_data_real.py --drugbank-food-interactions --drugbank-csv DRUGBANK/drugbank_clean.csv")
        print("  5. python fetch_data_real.py --usda-targeted  # NEW!")
        print("\n[OR RUN ALL STEPS AUTOMATICALLY]:")
        print("  python run_full_pipeline_auto.py")
    
    print("\n[COMPLETE] All steps finished")