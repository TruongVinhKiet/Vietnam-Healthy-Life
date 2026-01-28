# -*- coding: utf-8 -*-
import re

# Mapping ID cũ sang ID mới
id_mapping = {
    1001: 11, 1002: 12, 1003: 13, 1004: 14, 1005: 15, 
    1006: 16, 1007: 17, 1008: 18, 1009: 19, 1010: 20,
    1011: 21, 1012: 22, 1013: 23, 1014: 24, 1015: 25,
    1016: 26, 1017: 27, 1018: 28, 1019: 29, 1020: 30,
    1021: 31, 1022: 32, 1023: 33, 1024: 34, 1032: 35,
    1037: 36, 1080: 37, 1081: 38, 1088: 39
}

files_to_fix = [
    'extended_tables_vietnam.sql',
    'additional_data_extended.sql'
]

for filename in files_to_fix:
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Thay thế condition_id trong các pattern phổ biến:
        # (condition_id, food_id, ...) hoặc (condition_id, nutrient_id, ...)
        for old_id, new_id in id_mapping.items():
            # Pattern: (old_id, xxx, ...) - condition_id ở đầu
            content = re.sub(
                rf'\({old_id},',
                f'({new_id},',
                content
            )
        
        with open(filename, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"✅ Đã sửa {filename}")
    except FileNotFoundError:
        print(f"⚠️ Không tìm thấy {filename}")

print("\n✅ Hoàn tất sửa condition_id trong tất cả file!")
