"""
Mock nutrition data for different Vietnamese foods based on filename
"""

MOCK_NUTRITION_DATABASE = {
    "pho-bo": {
        "food_name": "Phở Bò",
        "confidence": 0.92,
        "nutrients": {
            "ENERC_KCAL": 450,
            "PROCNT": 28,
            "CHOCDF": 55,
            "FAT": 12,
            "WATER": 450,
            # Vitamins
            "VITD": 0.3,
            "VITC": 8,
            "VITB12": 2.5,
            "VITA": 150,
            "VITE": 1.5,
            "VITK": 8,
            "VITB1": 0.2,
            "VITB2": 0.3,
            "VITB3": 4.5,
            "VITB5": 0.8,
            "VITB6": 0.4,
            "VITB7": 3.5,
            "VITB9": 45,
            # Minerals (all 14)
            "MIN_CA": 80,
            "MIN_P": 220,
            "MIN_MG": 45,
            "MIN_K": 380,
            "MIN_NA": 950,
            "MIN_FE": 3.5,
            "MIN_ZN": 4.2,
            "MIN_CU": 0.15,
            "MIN_MN": 0.8,
            "MIN_I": 12,
            "MIN_SE": 22,
            "MIN_CR": 8,
            "MIN_MO": 15,
            "MIN_F": 0.5,
            # Amino Acids (all 9)
            "AMINO_HIS": 450,
            "AMINO_ILE": 820,
            "AMINO_LEU": 1450,
            "AMINO_LYS": 1280,
            "AMINO_MET": 420,
            "AMINO_PHE": 780,
            "AMINO_THR": 680,
            "AMINO_TRP": 210,
            "AMINO_VAL": 950,
            # Fiber & Fat
            "TOTAL_FAT": 12,
            "FIBTG": 2.5
        }
    },
    "banhxeo": {
        "food_name": "Bánh Xèo",
        "confidence": 0.88,
        "nutrients": {
            "ENERC_KCAL": 380,
            "PROCNT": 18,
            "CHOCDF": 42,
            "FAT": 16,
            "WATER": 200,
            "VITD": 0.4,
            "VITC": 25,
            "VITB12": 1.2,
            "VITA": 320,
            "VITE": 2.5,
            "VITK": 12,
            "MIN_CA": 95,
            "MIN_P": 180,
            "MIN_MG": 38,
            "MIN_K": 420,
            "MIN_NA": 680,
            "MIN_FE": 2.8,
            "TOTAL_FAT": 16,
            "FIBTG": 3.2
        }
    },
    "nuocchanh": {
        "food_name": "Nước Chanh",
        "confidence": 0.95,
        "nutrients": {
            "ENERC_KCAL": 45,
            "PROCNT": 0.5,
            "CHOCDF": 11,
            "FAT": 0.2,
            "WATER": 350,
            "VITD": 0,
            "VITC": 38,
            "VITB12": 0,
            "VITA": 5,
            "VITE": 0.3,
            "VITK": 0.5,
            "MIN_CA": 12,
            "MIN_P": 8,
            "MIN_MG": 6,
            "MIN_K": 125,
            "MIN_NA": 2,
            "MIN_FE": 0.3,
            "TOTAL_FAT": 0.2,
            "FIBTG": 0.5
        }
    },
    "nuocrauma": {
        "food_name": "Nước Rau Má",
        "confidence": 0.90,
        "nutrients": {
            "ENERC_KCAL": 35,
            "PROCNT": 1.2,
            "CHOCDF": 7,
            "FAT": 0.3,
            "WATER": 320,
            "VITD": 0,
            "VITC": 18,
            "VITB12": 0,
            "VITA": 280,
            "VITE": 1.8,
            "VITK": 15,
            "MIN_CA": 45,
            "MIN_P": 28,
            "MIN_MG": 22,
            "MIN_K": 180,
            "MIN_NA": 8,
            "MIN_FE": 1.5,
            "TOTAL_FAT": 0.3,
            "FIBTG": 1.8
        }
    },
    "duongdua": {
        "food_name": "Đuông dừa",
        "confidence": 0.85,
        "nutrients": {
            "ENERC_KCAL": 520,
            "PROCNT": 8,
            "CHOCDF": 68,
            "FAT": 24,
            "WATER": 280,
            "VITD": 0.2,
            "VITC": 12,
            "VITB12": 0.3,
            "VITA": 45,
            "VITE": 1.2,
            "VITK": 3,
            "MIN_CA": 38,
            "MIN_P": 95,
            "MIN_MG": 42,
            "MIN_K": 380,
            "MIN_NA": 420,
            "MIN_FE": 1.8,
            "TOTAL_FAT": 24,
            "FIBTG": 4.5
        }
    },
    "burger-combo": {
        "food_name": "Combo Jollibee",
        "confidence": 0.92,
        "nutrients": {
            "ENERC_KCAL": 850,
            "PROCNT": 35,
            "CHOCDF": 95,
            "FAT": 38,
            "WATER": 180,
            "VITD": 0.5,
            "VITC": 12,
            "VITB12": 2.8,
            "VITA": 120,
            "VITE": 2.2,
            "VITK": 6,
            "MIN_CA": 180,
            "MIN_P": 320,
            "MIN_MG": 55,
            "MIN_K": 480,
            "MIN_NA": 1450,
            "MIN_FE": 4.5,
            "TOTAL_FAT": 38,
            "FIBTG": 5.2
        }
    },
    "default": {
        "food_name": "Món ăn chưa xác định",
        "confidence": 0.90,
        "nutrients": {
            "ENERC_KCAL": 350,
            "PROCNT": 15,
            "CHOCDF": 45,
            "FAT": 12,
            "WATER": 250,
            # All Vitamins
            "VITD": 0.5,
            "VITC": 10,
            "VITB12": 1.0,
            "VITA": 150,
            "VITE": 2,
            "VITK": 5,
            "VITB1": 0.18,
            "VITB2": 0.22,
            "VITB3": 3.2,
            "VITB5": 0.5,
            "VITB6": 0.28,
            "VITB7": 2.5,
            "VITB9": 32,
            # All Minerals (14)
            "MIN_CA": 100,
            "MIN_P": 200,
            "MIN_MG": 35,
            "MIN_K": 350,
            "MIN_NA": 800,
            "MIN_FE": 3,
            "MIN_ZN": 2.5,
            "MIN_CU": 0.18,
            "MIN_MN": 0.55,
            "MIN_I": 10,
            "MIN_SE": 15,
            "MIN_CR": 5,
            "MIN_MO": 10,
            "MIN_F": 0.3,
            # All Amino Acids (9)
            "AMINO_HIS": 320,
            "AMINO_ILE": 650,
            "AMINO_LEU": 1100,
            "AMINO_LYS": 950,
            "AMINO_MET": 310,
            "AMINO_PHE": 580,
            "AMINO_THR": 490,
            "AMINO_TRP": 160,
            "AMINO_VAL": 720,
            # Fiber & Fat
            "TOTAL_FAT": 12,
            "FIBTG": 2.5
        }
    },
    "cuacamau": {
        "food_name": "Cua Cà Mau",
        "confidence": 0.91,
        "nutrients": {
            "ENERC_KCAL": 285,
            "PROCNT": 42,
            "CHOCDF": 8,
            "FAT": 10,
            "WATER": 180,
            "VITD": 0.8,
            "VITC": 4,
            "VITB12": 8.5,
            "VITA": 85,
            "VITE": 2.8,
            "VITK": 0.5,
            "MIN_CA": 320,
            "MIN_P": 380,
            "MIN_MG": 85,
            "MIN_K": 450,
            "MIN_NA": 850,
            "MIN_FE": 2.8,
            "TOTAL_FAT": 10,
            "FIBTG": 0.8
        }
    },
    "buaangiadinh": {
        "food_name": "Bữa Ăn Gia Đình",
        "confidence": 0.89,
        "nutrients": {
            "ENERC_KCAL": 820,
            "PROCNT": 48,
            "CHOCDF": 95,
            "FAT": 25,
            "WATER": 650,
            "VITD": 1.2,
            "VITC": 38,
            "VITB12": 3.8,
            "VITA": 580,
            "VITE": 4.5,
            "VITK": 42,
            "MIN_CA": 285,
            "MIN_P": 420,
            "MIN_MG": 125,
            "MIN_K": 780,
            "MIN_NA": 1280,
            "MIN_FE": 6.2,
            "TOTAL_FAT": 25,
            "FIBTG": 8.5
        }
    },
    "lauthai": {
        "food_name": "Lẩu Thái",
        "confidence": 0.93,
        "nutrients": {
            "ENERC_KCAL": 420,
            "PROCNT": 35,
            "CHOCDF": 38,
            "FAT": 15,
            "WATER": 850,
            "VITD": 0.5,
            "VITC": 45,
            "VITB12": 4.2,
            "VITA": 320,
            "VITE": 3.2,
            "VITK": 28,
            "MIN_CA": 180,
            "MIN_P": 290,
            "MIN_MG": 95,
            "MIN_K": 620,
            "MIN_NA": 1850,
            "MIN_FE": 4.5,
            "TOTAL_FAT": 15,
            "FIBTG": 5.8
        }
    },
    "banhtamcaycamau": {
        "food_name": "Bánh Tầm Cay Cà Mau",
        "confidence": 0.87,
        "nutrients": {
            "ENERC_KCAL": 485,
            "PROCNT": 22,
            "CHOCDF": 68,
            "FAT": 14,
            "WATER": 280,
            # Vitamins
            "VITD": 0.3,
            "VITC": 18,
            "VITB12": 2.5,
            "VITA": 220,
            "VITE": 2.2,
            "VITK": 12,
            "VITB1": 0.25,
            "VITB2": 0.18,
            "VITB3": 3.8,
            "VITB5": 0.6,
            "VITB6": 0.32,
            "VITB7": 2.8,
            "VITB9": 38,
            # Minerals (all 14)
            "MIN_CA": 95,
            "MIN_P": 185,
            "MIN_MG": 52,
            "MIN_K": 380,
            "MIN_NA": 1120,
            "MIN_FE": 3.2,
            "MIN_ZN": 2.8,
            "MIN_CU": 0.22,
            "MIN_MN": 0.65,
            "MIN_I": 15,
            "MIN_SE": 18,
            "MIN_CR": 6,
            "MIN_MO": 12,
            "MIN_F": 0.4,
            # Amino Acids (all 9)
            "AMINO_HIS": 380,
            "AMINO_ILE": 720,
            "AMINO_LEU": 1250,
            "AMINO_LYS": 1080,
            "AMINO_MET": 360,
            "AMINO_PHE": 680,
            "AMINO_THR": 580,
            "AMINO_TRP": 185,
            "AMINO_VAL": 820,
            # Fiber & Fat
            "TOTAL_FAT": 14,
            "FIBTG": 4.2
        }
    },
    "banhcongcamau": {
        "food_name": "Bánh Cống Cà Mau",
        "confidence": 0.90,
        "nutrients": {
            "ENERC_KCAL": 320,
            "PROCNT": 16,
            "CHOCDF": 42,
            "FAT": 11,
            "WATER": 150,
            "VITD": 0.4,
            "VITC": 12,
            "VITB12": 1.8,
            "VITA": 180,
            "VITE": 1.8,
            "VITK": 8,
            "MIN_CA": 85,
            "MIN_P": 145,
            "MIN_MG": 42,
            "MIN_K": 280,
            "MIN_NA": 680,
            "MIN_FE": 2.5,
            "TOTAL_FAT": 11,
            "FIBTG": 3.2
        }
    },
    # Direct mappings for scaled files from Android
    "scaled33": "pho-bo",
    "scaled34": "nuocchanh",
    "scaled35": "banhxeo",
    "scaled40": "duongdua",
    "scaled43": "nuocrauma",
    "scaled48": "burger-combo",
    "scaled49": "cuacamau",
    "scaled50": "buaangiadinh",
    "scaled51": "lauthai",
    "scaled53": "banhtamcaycamau",
    "scaled54": "banhcongcamau"
}

NUTRIENT_INFO = {
    "ENERC_KCAL": {"name": "Calories", "unit": "kcal"},
    "PROCNT": {"name": "Protein", "unit": "g"},
    "CHOCDF": {"name": "Total Carbohydrate", "unit": "g"},
    "FAT": {"name": "Total Fat", "unit": "g"},
    "WATER": {"name": "Water", "unit": "ml"},
    # All Vitamins
    "VITD": {"name": "Vitamin D", "unit": "IU"},
    "VITC": {"name": "Vitamin C", "unit": "mg"},
    "VITB12": {"name": "Vitamin B12", "unit": "µg"},
    "VITA": {"name": "Vitamin A", "unit": "µg"},
    "VITE": {"name": "Vitamin E", "unit": "mg"},
    "VITK": {"name": "Vitamin K", "unit": "mg"},
    "VITB1": {"name": "Vitamin B1", "unit": "mg"},
    "VITB2": {"name": "Vitamin B2", "unit": "mg"},
    "VITB3": {"name": "Vitamin B3", "unit": "mg"},
    "VITB5": {"name": "Vitamin B5", "unit": "mg"},
    "VITB6": {"name": "Vitamin B6", "unit": "mg"},
    "VITB7": {"name": "Vitamin B7", "unit": "µg"},
    "VITB9": {"name": "Vitamin B9", "unit": "µg"},
    # All Minerals (14)
    "MIN_CA": {"name": "Calcium", "unit": "mg"},
    "MIN_P": {"name": "Phosphorus", "unit": "mg"},
    "MIN_MG": {"name": "Magnesium", "unit": "mg"},
    "MIN_K": {"name": "Potassium", "unit": "mg"},
    "MIN_NA": {"name": "Sodium", "unit": "mg"},
    "MIN_FE": {"name": "Iron", "unit": "mg"},
    "MIN_ZN": {"name": "Zinc", "unit": "mg"},
    "MIN_CU": {"name": "Copper", "unit": "mg"},
    "MIN_MN": {"name": "Manganese", "unit": "mg"},
    "MIN_I": {"name": "Iodine", "unit": "µg"},
    "MIN_SE": {"name": "Selenium", "unit": "µg"},
    "MIN_CR": {"name": "Chromium", "unit": "µg"},
    "MIN_MO": {"name": "Molybdenum", "unit": "µg"},
    "MIN_F": {"name": "Fluoride", "unit": "mg"},
    # All Amino Acids (9)
    "AMINO_HIS": {"name": "Histidine", "unit": "mg"},
    "AMINO_ILE": {"name": "Isoleucine", "unit": "mg"},
    "AMINO_LEU": {"name": "Leucine", "unit": "mg"},
    "AMINO_LYS": {"name": "Lysine", "unit": "mg"},
    "AMINO_MET": {"name": "Methionine", "unit": "mg"},
    "AMINO_PHE": {"name": "Phenylalanine", "unit": "mg"},
    "AMINO_THR": {"name": "Threonine", "unit": "mg"},
    "AMINO_TRP": {"name": "Tryptophan", "unit": "mg"},
    "AMINO_VAL": {"name": "Valine", "unit": "mg"},
    # Fiber & Fat
    "TOTAL_FAT": {"name": "Tổng chất béo", "unit": "g"},
    "FIBTG": {"name": "Total Fiber", "unit": "g"}
}


def get_mock_nutrition_by_filename(filename: str) -> dict:
    """
    Get mock nutrition data based on filename
    Matches filename to food type (case-insensitive, removes extensions and special chars)
    If no match, randomly select a food based on filename hash
    """
    # Normalize filename: lowercase, remove extension
    normalized = filename.lower().replace('.jpg', '').replace('.jpeg', '').replace('.png', '').replace('-', '').replace('_', '')
    
    # Check if it's a mapped scaled file
    if normalized in MOCK_NUTRITION_DATABASE and isinstance(MOCK_NUTRITION_DATABASE[normalized], str):
        # It's a mapping, get the actual food key
        actual_key = MOCK_NUTRITION_DATABASE[normalized]
        food_data = MOCK_NUTRITION_DATABASE[actual_key]
    else:
        # Try to match with database keys
        food_data = None
        for key in MOCK_NUTRITION_DATABASE.keys():
            if isinstance(MOCK_NUTRITION_DATABASE[key], dict) and key.replace('-', '') in normalized:
                food_data = MOCK_NUTRITION_DATABASE[key]
                break
        
        if food_data is None:
            # Use filename hash to consistently select a food (same filename = same food)
            import hashlib
            hash_value = int(hashlib.md5(filename.encode()).hexdigest(), 16)
            food_keys = [k for k in MOCK_NUTRITION_DATABASE.keys() if isinstance(MOCK_NUTRITION_DATABASE[k], dict) and k != "default"]
            selected_key = food_keys[hash_value % len(food_keys)]
            food_data = MOCK_NUTRITION_DATABASE[selected_key]
    
    # Format response
    nutrients_list = []
    for code, amount in food_data["nutrients"].items():
        info = NUTRIENT_INFO.get(code, {"name": code, "unit": "g"})
        nutrients_list.append({
            "nutrient_code": code,
            "nutrient_name": info["name"],
            "amount": amount,
            "unit": info["unit"]
        })
    
    # Random confidence between 90-95%
    import random
    random_confidence = random.uniform(0.90, 0.95)
    
    return {
        "is_food": True,
        "food_name": food_data["food_name"],
        "confidence": random_confidence,
        "nutrients": nutrients_list
    }
